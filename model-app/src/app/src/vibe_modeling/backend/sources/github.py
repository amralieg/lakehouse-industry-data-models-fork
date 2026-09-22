"""GitHub source connector — reads a PUBLIC repo of industry data models.

Folder layout (per ``databricks-industry-solutions/lakehouse-industry-data-models``,
under the ``data-models/`` subtree)::

    <repo root>/data-models/
      <industry>/                 # e.g. advertising, banking, energy_utilities
        README.md                 # industry-level readme (a file, not a dir)
        <version>/                # e.g. v1, v2
          readme.md               # version-level readme (a file, not a dir)
          <scope>/                # e.g. ecm, mvm
            model.json            # the canonical model document
            schemas/  diagram/  docs/  metrics/  ontology/  vibes/

A model is addressed by the fused ``<version>_<scope>`` id (e.g. ``v1_ecm``),
which maps to the ``<version>/<scope>`` relpath beneath the industry folder.

The model tree lives under ``data-models/`` (the repo root also holds
``apps/``, ``dashboards/``, ``notebooks/``, …); :data:`DEFAULT_BASE_PATH`
scopes every read to that subtree. The tree is *flat at the industry level* —
there is no sector grouping —
so this connector declares ``provides_sectors=False`` and synthesises a
single implicit sector (the repo itself) so the three-level browse
contract from :class:`SourceConnector` still holds. ``sector_id`` is
always :data:`_REPO_SECTOR_ID`.

Read-only: uses the GitHub REST contents API for directory listings and
``raw.githubusercontent.com`` for file bytes. Writes / publish come in a
later wave via the UC connection — this connector never authenticates and
only reads public content.
"""

from __future__ import annotations

import json
import logging
import threading
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from typing import Any
from urllib.parse import quote

import jwt
import requests
from databricks.sdk.errors import NotFound, PermissionDenied, TooManyRequests
from databricks.sdk.errors.base import DatabricksError
from databricks.sdk.service.serving import ExternalFunctionRequestHttpMethod

from .base import (
    DiscoveryMode,
    MaterializationTiming,
    ModelArtifact,
    SourceCapabilities,
    SourceConnector,
    SourceError,
    SourceIndustry,
    SourceModelRef,
    SourceNotFoundError,
    SourcePermissionError,
    SourceRateLimitError,
    SourceSector,
    TargetKind,
)

logger = logging.getLogger(__name__)


def _utcnow() -> datetime:
    """Single now() seam so tests can freeze the clock for cache/refresh cases."""
    return datetime.now(timezone.utc)


def _raise_if_rate_limited(resp) -> None:
    """Map an exhausted-GitHub-rate-limit response to SourceRateLimitError.

    GitHub signals an exhausted budget with HTTP 403 (or 429) plus
    ``X-RateLimit-Remaining: 0``. Anonymous browsing gets 60 requests/hour/IP,
    and a browse-preview session costs several - so this fires in practice. We
    turn it into an actionable rate-limit error (configure a GitHub App to raise
    the limit to 5,000/hour, or wait for the reset) instead of letting it
    surface as a generic transport failure / 502.
    """
    status = getattr(resp, "status_code", None)
    if status not in (403, 429):
        return
    headers = getattr(resp, "headers", None) or {}
    remaining = str(headers.get("X-RateLimit-Remaining", "")).strip()
    body_text = (getattr(resp, "text", "") or "").lower()
    is_rate_limited = remaining == "0" or "rate limit" in body_text
    if not is_rate_limited:
        return
    reset_hint = ""
    reset_raw = str(headers.get("X-RateLimit-Reset", "")).strip()
    if reset_raw.isdigit():
        reset_dt = datetime.fromtimestamp(int(reset_raw), tz=timezone.utc)
        reset_hint = reset_dt.strftime("%Y-%m-%d %H:%M UTC")
    wait_clause = f" wait until {reset_hint}" if reset_hint else " wait for the reset"
    raise SourceRateLimitError(
        "GitHub rate limit hit - this source is running unauthenticated "
        "(60 requests/hour). Configure a GitHub App to raise the limit to "
        f"5,000/hour, or{wait_clause}.",
        reset_hint=reset_hint,
    )


DEFAULT_REPO_OWNER = "databricks-industry-solutions"
DEFAULT_REPO_NAME = "lakehouse-industry-data-models"
DEFAULT_REF = "main"
# The model tree lives under this subtree of the repo (the repo root also holds
# apps/, dashboards/, notebooks/, …). Every read is scoped beneath it. Empty
# string means "the repo root is the model tree" (the pre-move layout).
DEFAULT_BASE_PATH = "data-models"

# The synthetic sector id used for this flat repo (no native sector level).
_REPO_SECTOR_ID = "_repo"

_API_BASE = "https://api.github.com"
_RAW_BASE = "https://raw.githubusercontent.com"

# Entries inside the model-tree base path that are not industries.
_NON_INDUSTRY_ROOT = {
    ".gitignore", "readme.md", "license", "license.md", ".github", "images",
}

# Companion artifact sub-directory → the element kind it materialises.
_ARTIFACT_DIRS: dict[str, TargetKind] = {
    "schemas": TargetKind.SCHEMAS,
    "diagram": TargetKind.DIAGRAM,
    "docs": TargetKind.DOCS,
    "metrics": TargetKind.METRICS,
    "ontology": TargetKind.ONTOLOGY,
    "vibes": TargetKind.VIBES,
}

_MODEL_FILE = "model.json"

# Network timeout (seconds) for every GitHub call.
_TIMEOUT = 30

# GitHub media type that makes the Contents API return a file's RAW bytes in
# the response body (files 1-100 MB). Lets the UC-connection transport - which
# can only reach the connection's host (``api.github.com``) - fetch file
# content that the anonymous path reads from ``raw.githubusercontent.com``.
_GITHUB_RAW_MEDIA_TYPE = "application/vnd.github.raw+json"


class _UcResponse:
    """A ``requests``-shaped response over a UC ``http_request`` result.

    Exposes the same surface the connector already consumes from a ``requests``
    response (``status_code`` / ``headers`` / ``text`` / ``json()``), so the
    connector's status-code and rate-limit logic runs unchanged whether the
    transport is anonymous ``requests`` or the credentialed UC connection.

    The UC proxy exposes neither the upstream status code nor its headers and
    raises a :class:`DatabricksError` on any non-2xx, so the transport
    synthesises a status code from the exception it caught (200 on success) and
    leaves ``headers`` empty.
    """

    def __init__(self, status_code: int, *, text: str = "", headers: dict | None = None):
        self.status_code = status_code
        self.text = text
        self.headers = headers or {}

    def json(self) -> Any:
        return json.loads(self.text)


def _read_uc_contents(resp) -> str:
    """Decode the body of a UC ``http_request`` response to text.

    ``ServingEndpointsExt.http_request`` returns a ``requests.Response`` whose
    body is on ``.text``. A base ``HttpRequestResponse`` instead exposes a
    ``contents`` stream (``BinaryIO``). Handle both so the transport is agnostic
    to the SDK's response shape; the caller owns parsing (JSON listing vs. raw
    file bytes)."""
    text = getattr(resp, "text", None)
    if text is not None:
        return text or ""
    contents = getattr(resp, "contents", None)
    if contents is None:
        return ""
    raw = contents.read() if hasattr(contents, "read") else contents
    if isinstance(raw, bytes):
        raw = raw.decode("utf-8", errors="replace")
    return raw or ""


class UcConnectionTransport:
    """A ``requests``-shaped GitHub transport routed through a UC HTTP connection.

    The credentialed sibling of the default anonymous ``requests`` transport:
    exposes ``get(url, timeout=...)`` returning a :class:`_UcResponse`, but
    shapes the call through ``user_ws.serving_endpoints.http_request`` (OBO)
    against the configured UC HTTP connection so the token never touches the
    app - the same channel the publish path uses.

    The connection's host is GitHub's API host (``api.github.com``), so it
    cannot reach ``raw.githubusercontent.com``. A raw-content URL is rewritten
    to the Contents API with the ``application/vnd.github.raw+json`` Accept
    header, which returns the file's bytes in the body.
    """

    def __init__(self, user_ws, connection_name: str):
        self._ws = user_ws
        self._connection_name = connection_name

    def get(self, url: str, timeout=None):  # noqa: ARG002 - timeout is the requests seam
        path, headers = _translate_github_url(url)
        try:
            resp = self._ws.serving_endpoints.http_request(
                self._connection_name,
                ExternalFunctionRequestHttpMethod.GET,
                path,
                headers=headers or None,
            )
        except NotFound as exc:
            return _UcResponse(404, text=str(exc))
        except TooManyRequests as exc:
            # 429 + a "rate limit" body so the connector's shared
            # rate-limit mapper raises SourceRateLimitError (actionable 429).
            return _UcResponse(429, text=f"GitHub API rate limit exceeded: {exc}")
        except PermissionDenied as exc:
            # A genuine 403 (repo/scope) - NOT tagged as rate-limit, so it
            # surfaces as a generic SourceError rather than a misleading 429.
            return _UcResponse(403, text=str(exc))
        except DatabricksError as exc:
            return _UcResponse(502, text=str(exc))
        return _UcResponse(200, text=_read_uc_contents(resp))


def _translate_github_url(url: str) -> tuple[str, dict[str, str]]:
    """Map a full GitHub URL the connector built to a UC-connection-relative
    ``(path, headers)`` pair.

    * ``https://api.github.com/<path>?<query>`` -> the connection-relative
      ``/<path>?<query>`` with no extra headers (the Contents API listing is
      returned as JSON by default).
    * ``https://raw.githubusercontent.com/<owner>/<name>/<ref>/<filepath>``
      -> the Contents API ``/repos/<owner>/<name>/contents/<filepath>?ref=<ref>``
      with the raw-bytes Accept header, since the connection cannot reach the
      raw host.
    """
    if url.startswith(_API_BASE):
        return url[len(_API_BASE):] or "/", {}
    if url.startswith(_RAW_BASE + "/"):
        rest = url[len(_RAW_BASE) + 1:]
        owner, name, ref, filepath = rest.split("/", 3)
        return (
            f"/repos/{owner}/{name}/contents/{filepath}?ref={ref}",
            {"Accept": _GITHUB_RAW_MEDIA_TYPE},
        )
    # A URL the connector never builds; forward the path verbatim so a caller
    # gets a clear upstream failure rather than a silently wrong host.
    return url, {}


# --- GitHub App read transport ---------------------------------------------

# JWT lifetime bounds (GitHub caps an app JWT at 10 min; we sign a short one
# per mint). ``iat`` is backdated 60s for clock-skew tolerance.
_JWT_IAT_SKEW_S = 60
_JWT_TTL_S = 600
# Refresh the installation token this many seconds BEFORE its 1h expiry so a
# read never races the boundary.
_TOKEN_REFRESH_MARGIN_S = 300
# Sent on every api.github.com call (GitHub's recommended pinned API version).
_GITHUB_API_VERSION = "2022-11-28"
_GITHUB_JSON_MEDIA_TYPE = "application/vnd.github+json"


@dataclass(frozen=True)
class GithubAppCredentials:
    """The three values that identify + authenticate the deployment's GitHub App.

    Deployment-wide (one App per install), sourced from ``AppConfig`` env/secret,
    NOT the per-install ``AgentConfig`` row. ``private_key_pem`` is the App's RSA
    private key (PEM), populated from a Databricks app secret - never a literal.
    """

    app_id: str
    installation_id: str
    private_key_pem: str

    @property
    def complete(self) -> bool:
        return bool(self.app_id and self.installation_id and self.private_key_pem)


@dataclass
class _CachedToken:
    token: str
    expires_at: datetime


# Module-level installation-token cache, keyed by installation id, guarded by a
# lock. The app runs a single uvicorn worker (see app.yml), and a fresh
# ``GithubAppTransport`` is built per request, so the cache MUST live at module
# scope (not on the instance) for the ~55-min token to be reused across
# requests. A cold cache costs one extra POST; every subsequent read reuses the
# token.
_APP_TOKEN_CACHE: dict[str, _CachedToken] = {}
_APP_TOKEN_LOCK = threading.Lock()


def _parse_github_expires_at(value: str) -> datetime:
    """Parse GitHub's ISO-8601 ``expires_at`` (e.g. ``2016-07-11T22:14:10Z``) to
    a tz-aware datetime. Falls back to now + 1h (GitHub's fixed TTL) if the
    field is absent or unparseable, so a malformed response still caches."""
    text = (value or "").strip()
    if text:
        try:
            return datetime.fromisoformat(text.replace("Z", "+00:00"))
        except ValueError:
            pass
    return _utcnow() + timedelta(hours=1)


class GithubAppTransport:
    """A ``requests``-shaped GitHub transport authenticated as a GitHub App.

    The credentialed sibling of the anonymous ``requests`` transport and
    :class:`UcConnectionTransport`: exposes ``get(url, timeout=...)`` returning a
    ``requests``-shaped response, so the connector's status-code + rate-limit
    logic runs unchanged.

    Auth flow (all app-owned, no user account, immune to the target org's SAML
    SSO because an installation token is a server-to-server token):

    1. Sign an RS256 JWT with the App private key (``iss``=app id,
       ``iat``=now-60s, ``exp``=now+600s).
    2. Exchange it for an installation access token (1h TTL) via
       ``POST /app/installations/{id}/access_tokens``.
    3. Call the REST API with ``Authorization: Bearer <installation-token>``.

    File reads go through the Contents API with the raw-bytes Accept header (the
    shared :func:`_translate_github_url` rewrite), NOT ``raw.githubusercontent.com``,
    so every read stays on the authenticated 5,000/hr budget.
    """

    def __init__(self, credentials: GithubAppCredentials, session: Any | None = None):
        self._creds = credentials
        # ``session`` is a ``requests``-like object exposing ``get``/``post``;
        # defaults to the ``requests`` module. Injected in tests.
        self._session = session if session is not None else requests

    def get(self, url: str, timeout=None):  # noqa: ARG002 - timeout is the requests seam
        token = self._ensure_token()
        resp = self._request(url, token)
        # A 401 means the token rotated out / clock skew: refresh once and retry.
        # A second 401 is returned as-is; the connector maps 401/403 to
        # SourcePermissionError.
        if getattr(resp, "status_code", None) == 401:
            token = self._ensure_token(force_refresh=True)
            resp = self._request(url, token)
        return resp

    def _request(self, url: str, token: str):
        rel_path, extra_headers = _translate_github_url(url)
        full_url = f"{_API_BASE}{rel_path}" if rel_path.startswith("/") else rel_path
        headers = {
            "Accept": _GITHUB_JSON_MEDIA_TYPE,
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": _GITHUB_API_VERSION,
            **extra_headers,
        }
        return self._session.get(full_url, headers=headers, timeout=_TIMEOUT)

    def _ensure_token(self, *, force_refresh: bool = False) -> str:
        key = self._creds.installation_id
        with _APP_TOKEN_LOCK:
            cached = _APP_TOKEN_CACHE.get(key)
            if (
                not force_refresh
                and cached is not None
                and _utcnow() < cached.expires_at - timedelta(seconds=_TOKEN_REFRESH_MARGIN_S)
            ):
                return cached.token
            token, expires_at = self._mint_token()
            _APP_TOKEN_CACHE[key] = _CachedToken(token, expires_at)
            return token

    def _mint_token(self) -> tuple[str, datetime]:
        try:
            signed_jwt = self._sign_jwt()
        except Exception as exc:
            # A malformed / corrupt / unsupported PEM makes jwt.encode raise a
            # cryptography/ValueError that is NOT a SourceError, so it would
            # bypass the route _guard and surface as a 500. Map it to a
            # SourcePermissionError (-> HTTP 403) with a generic hint - never
            # let key material into the message.
            raise SourcePermissionError(
                "GitHub App token mint failed: the App private key is missing or "
                "invalid. Check the GitHub App configuration."
            ) from exc
        url = f"{_API_BASE}/app/installations/{self._creds.installation_id}/access_tokens"
        try:
            resp = self._session.post(
                url,
                headers={
                    "Accept": _GITHUB_JSON_MEDIA_TYPE,
                    "Authorization": f"Bearer {signed_jwt}",
                    "X-GitHub-Api-Version": _GITHUB_API_VERSION,
                },
                timeout=_TIMEOUT,
            )
        except requests.RequestException as exc:  # pragma: no cover - transport
            raise SourceError(f"GitHub App token mint request failed: {exc}") from exc
        status = getattr(resp, "status_code", None)
        if status not in (200, 201):
            raise SourcePermissionError(
                f"GitHub App token mint failed ({status}): the App id / installation "
                "id / private key may be invalid, or the App lacks the installation."
            )
        body = resp.json()
        token = body.get("token")
        if not token:
            raise SourceError("GitHub App token mint returned no token.")
        return token, _parse_github_expires_at(body.get("expires_at", ""))

    def _sign_jwt(self) -> str:
        now = int(_utcnow().timestamp())
        payload = {
            "iat": now - _JWT_IAT_SKEW_S,
            "exp": now + _JWT_TTL_S,
            "iss": self._creds.app_id,
        }
        return jwt.encode(payload, self._creds.private_key_pem, algorithm="RS256")


class GithubSourceConnector(SourceConnector):
    """Browse + fetch against a public GitHub repo of data models.

    Construct cheaply (no network); all I/O is in the methods. Inject a
    ``requests``-like session via ``http`` for testing (it must expose a
    ``get(url, timeout=...)`` returning an object with ``status_code``,
    ``.json()`` and ``.text``).
    """

    def __init__(
        self,
        repo_owner: str = DEFAULT_REPO_OWNER,
        repo_name: str = DEFAULT_REPO_NAME,
        ref: str = DEFAULT_REF,
        base_path: str = DEFAULT_BASE_PATH,
        http: Any | None = None,
    ) -> None:
        self.repo_owner = repo_owner or DEFAULT_REPO_OWNER
        self.repo_name = repo_name or DEFAULT_REPO_NAME
        self.ref = ref or DEFAULT_REF
        # "" is a valid value (model tree at the repo root), so don't coalesce
        # with `or`; only strip separators.
        self.base_path = (base_path or "").strip("/")
        self._http = http if http is not None else requests

    # --- capabilities -----------------------------------------------------

    def capabilities(self) -> SourceCapabilities:
        return SourceCapabilities(
            source_kind="github",
            target_kinds=[
                TargetKind.MODEL_JSON,
                TargetKind.SCHEMAS,
                TargetKind.DIAGRAM,
                TargetKind.DOCS,
                TargetKind.METRICS,
                TargetKind.ONTOLOGY,
                TargetKind.VIBES,
            ],
            discovery_mode=DiscoveryMode.EAGER_LISTING,
            materialization_timing=MaterializationTiming.AT_REST,
            provides_sectors=False,
            read_only=True,
            auth_mode=(
                "github_app"
                if isinstance(self._http, GithubAppTransport)
                else "anonymous"
            ),
        )

    # --- browse -----------------------------------------------------------

    def list_sectors(self) -> list[SourceSector]:
        """The repo has no native sector level; return one synthetic sector."""
        return [
            SourceSector(
                id=_REPO_SECTOR_ID,
                name=f"{self.repo_owner}/{self.repo_name}",
                synthetic=True,
            )
        ]

    def list_industries(self, sector_id: str) -> list[SourceIndustry]:
        if sector_id != _REPO_SECTOR_ID:
            raise SourceNotFoundError(f"Unknown sector '{sector_id}' for the GitHub source.")
        entries = self._list_contents(
            "",
            missing_msg=(
                f"Could not find the model tree at '{self.base_path}' — "
                "the source repo may have restructured."
            ),
        )
        industries: list[SourceIndustry] = []
        for name in _iter_named_dirs(entries):
            if name.lower() in _NON_INDUSTRY_ROOT:
                continue
            industries.append(
                SourceIndustry(id=name, sector_id=_REPO_SECTOR_ID, name=_humanize(name))
            )
        industries.sort(key=lambda i: i.name)
        return industries

    def list_models(self, industry_id: str) -> list[SourceModelRef]:
        entries = self._list_contents(industry_id, missing_msg=f"Unknown industry '{industry_id}'.")
        models: list[SourceModelRef] = []
        for version in _iter_named_dirs(entries):
            if not _is_version_dir(version):
                logger.debug(
                    "list_models: skipping non-version dir '%s' under industry '%s'",
                    version, industry_id,
                )
                continue
            try:
                version_entries = self._list_contents(f"{industry_id}/{version}")
            except SourceError as exc:
                # A flaky / empty version dir must not abort the whole walk.
                logger.debug(
                    "list_models: skipping version '%s' under '%s': %s",
                    version, industry_id, exc,
                )
                continue
            for scope in _iter_named_dirs(version_entries):
                models.append(
                    SourceModelRef(
                        id=f"{version}_{scope}",
                        industry_id=industry_id,
                        name=_humanize(f"{scope}_{version}"),
                        scope=scope,
                        version=version,
                    )
                )
        models.sort(key=lambda m: m.id)
        return models

    # --- fetch ------------------------------------------------------------

    def fetch_model_json(self, industry_id: str, model_id: str) -> str:
        path = f"{industry_id}/{model_id_to_relpath(model_id)}/{_MODEL_FILE}"
        return self._fetch_raw(path)

    def fetch_readme(self, industry_id: str, model_id: str) -> str | None:
        """Fetch the scope-level readme (``<version>/<scope>/readme.md``),
        falling back to the version-level readme (``<version>/readme.md``)
        when the scope-level file is absent. Returns ``None`` when neither
        exists. A non-404 transport error propagates as :class:`SourceError`
        (mirrors :meth:`fetch_model_json`)."""
        rel = model_id_to_relpath(model_id)
        version = rel.split("/", 1)[0]
        scope_path = f"{industry_id}/{rel}/readme.md"
        try:
            return self._fetch_raw(scope_path)
        except SourceNotFoundError:
            pass
        version_path = f"{industry_id}/{version}/readme.md"
        try:
            return self._fetch_raw(version_path)
        except SourceNotFoundError:
            return None

    def fetch_releasenotes(self, industry_id: str, model_id: str) -> str | None:
        """Fetch the scope-level release notes doc used to derive preview
        statistics (``<version>/<scope>/docs/releasenotes.txt``). This is a
        best-effort enhancement: ANY failure (404, transport error, malformed
        model id) returns ``None`` rather than raising, so a missing/unreachable
        release-notes file never breaks the preview."""
        try:
            rel = model_id_to_relpath(model_id)
        except SourceNotFoundError:
            return None
        path = f"{industry_id}/{rel}/docs/releasenotes.txt"
        try:
            return self._fetch_raw(path)
        except SourceError:
            return None

    def fetch_artifacts(self, industry_id: str, model_id: str) -> list[ModelArtifact]:
        artifacts: list[ModelArtifact] = []

        rel = model_id_to_relpath(model_id)
        model_dir = f"{industry_id}/{rel}"
        try:
            model_entries = self._list_contents(model_dir)
        except SourceError:
            model_entries = []
        model_entry = next(
            (
                e
                for e in model_entries
                if e.get("type") == "file" and e.get("name") == _MODEL_FILE
            ),
            None,
        )
        if model_entry is not None:
            model_path = f"{model_dir}/{_MODEL_FILE}"
            artifacts.append(
                ModelArtifact(
                    name=_MODEL_FILE,
                    target_kind=TargetKind.MODEL_JSON,
                    path=model_path,
                    size=model_entry.get("size"),
                    download_url=model_entry.get("download_url") or self._raw_url(model_path),
                )
            )

        for sub_dir, kind in _ARTIFACT_DIRS.items():
            dir_path = f"{model_dir}/{sub_dir}"
            try:
                entries = self._list_contents(dir_path)
            except SourceError as exc:
                # One flaky / missing sub-dir must not abort the whole
                # enumeration; yield a partial list instead.
                logger.warning("Skipping artifact sub-dir '%s': %s", dir_path, exc)
                continue
            for entry in entries:
                if entry.get("type") != "file":
                    continue
                name = entry.get("name", "")
                file_path = f"{dir_path}/{name}"
                artifacts.append(
                    ModelArtifact(
                        name=name,
                        target_kind=kind,
                        path=file_path,
                        size=entry.get("size"),
                        download_url=entry.get("download_url") or self._raw_url(file_path),
                    )
                )
        return artifacts

    # --- internals --------------------------------------------------------

    def _repo_path(self, path: str) -> str:
        """Resolve an industry-relative ``path`` to a full repo path by
        prepending :attr:`base_path` (the ``data-models/`` subtree). An empty
        ``base_path`` leaves the path at the repo root (pre-move layout)."""
        rel = path.strip("/")
        if not self.base_path:
            return rel
        return f"{self.base_path}/{rel}" if rel else self.base_path

    def _list_contents(self, path: str, missing_msg: str | None = None) -> list[dict[str, Any]]:
        """GET the GitHub contents API for ``path`` (industry-relative)."""
        owner = quote(self.repo_owner, safe="")
        name = quote(self.repo_name, safe="")
        url = f"{_API_BASE}/repos/{owner}/{name}/contents/{_encode_path(self._repo_path(path))}".rstrip("/")
        if self.ref:
            url = f"{url}?ref={quote(self.ref, safe='')}"
        resp = self._get(url)
        if resp.status_code == 404:
            raise SourceNotFoundError(missing_msg or f"Path not found in source: '{path}'.")
        if resp.status_code in (401, 403):
            # Non-rate-limit 401/403: _raise_if_rate_limited (in _get) has already
            # converted a rate-limited 403 to SourceRateLimitError, so only a
            # genuine access denial (bad App creds / private repo) reaches here.
            raise SourcePermissionError(
                f"GitHub denied access ({resp.status_code}) for '{path}'."
            )
        if resp.status_code != 200:
            raise SourceError(
                f"GitHub contents API returned {resp.status_code} for '{path}'."
            )
        try:
            body = resp.json()
        except ValueError as exc:
            raise SourceError(
                f"GitHub contents API returned a non-JSON body for '{path}'."
            ) from exc
        if not isinstance(body, list):
            # A file path returns a dict; the contract here is a directory.
            raise SourceError(f"Expected a directory listing for '{path}'.")
        return body

    def _fetch_raw(self, path: str) -> str:
        return self._fetch_url(self._raw_url(path), path)

    def fetch_repo_file(self, repo_path: str) -> str:
        """Fetch a raw file addressed from the REPO ROOT, bypassing ``base_path``.

        The three ``fetch_*`` methods above address files *inside* the model
        tree (``base_path``/industry/version/scope). This one reads a file that
        lives elsewhere in the repo — e.g. the canonical agent notebook under
        ``model-agent/`` — by its repo-root-relative path. Same status mapping
        and transport-agnostic routing as :meth:`_fetch_raw` (the App/UC
        transports rewrite the raw URL to the Contents API)."""
        rel = repo_path.strip("/")
        owner = quote(self.repo_owner, safe="")
        name = quote(self.repo_name, safe="")
        ref = quote(self.ref, safe="")
        url = f"{_RAW_BASE}/{owner}/{name}/{ref}/{_encode_path(rel)}"
        return self._fetch_url(url, rel)

    def _fetch_url(self, url: str, path: str) -> str:
        """Shared raw-file GET + status mapping for :meth:`_fetch_raw` and
        :meth:`fetch_repo_file`. Transport-agnostic: the anonymous path hits
        raw.githubusercontent, the App/UC paths hit the Contents API on
        api.github.com (via the raw-URL rewrite in ``_translate_github_url``)."""
        resp = self._get(url)
        if resp.status_code == 404:
            raise SourceNotFoundError(f"File not found in source: '{path}'.")
        if resp.status_code in (401, 403):
            raise SourcePermissionError(
                f"GitHub denied access ({resp.status_code}) for '{path}'."
            )
        if resp.status_code != 200:
            raise SourceError(f"GitHub returned {resp.status_code} for file '{path}'.")
        return resp.text

    def _raw_url(self, path: str) -> str:
        owner = quote(self.repo_owner, safe="")
        name = quote(self.repo_name, safe="")
        ref = quote(self.ref, safe="")
        return f"{_RAW_BASE}/{owner}/{name}/{ref}/{_encode_path(self._repo_path(path))}"

    def _get(self, url: str):
        try:
            resp = self._http.get(url, timeout=_TIMEOUT)
        except requests.RequestException as exc:  # pragma: no cover - transport
            raise SourceError(f"GitHub request failed: {exc}") from exc
        _raise_if_rate_limited(resp)
        return resp


def model_id_to_relpath(model_id: str) -> str:
    """Map a fused ``<version>_<scope>`` model id to its ``<version>/<scope>``
    relpath beneath the industry folder.

    The split is on the FIRST ``_`` — a ``vN`` version token never contains an
    ``_``, so everything after the first ``_`` is the scope (which MAY itself
    contain ``_``, e.g. ``v1_ecm_x`` → ``v1/ecm_x``). A model id with no scope
    segment (``"v1_"``, ``"ecm"``, ``""``) is malformed.
    """
    version, sep, scope = model_id.partition("_")
    if not sep or not scope:
        raise SourceNotFoundError(f"Malformed model id '{model_id}'.")
    return f"{version}/{scope}"


def _is_version_dir(name: str) -> bool:
    """True for a ``vN`` version directory (``v1``..``v10`` …); False for stray
    or companion dirs that share the industry level (e.g. ``images``)."""
    return _version_num(name) >= 0


def _iter_named_dirs(entries: list[dict[str, Any]]):
    """Yield the non-blank name of each directory entry in a contents listing.

    Skips non-directory entries (matching the ``type == "dir"`` filter both
    browse loops share) and any entry whose name is missing or
    blank/whitespace-only, so a nameless dir can never leak through as an
    industry/model with an empty or whitespace id.
    """
    for entry in entries:
        if entry.get("type") != "dir":
            continue
        name = (entry.get("name") or "").strip()
        if not name:
            continue
        yield name


def _encode_path(path: str) -> str:
    """URL-encode each segment of a repo-relative path, preserving the
    ``/`` separators so ``../`` / ``?`` / ``#`` cannot ride into the URL."""
    return "/".join(quote(segment, safe="") for segment in path.split("/"))


# Labels found in a release-notes "MODEL STATISTICS" block, mapped to the
# ``ModelPreviewOut`` field they populate. Matched case-insensitively; the
# block's line ORDER is not relied on - every line is mapped by its label.
_STATS_LABEL_MAP: dict[str, str] = {
    "domains": "domains",
    "subdomains": "subdomains",
    "products": "products",
    "attributes": "attributes",
    "primary keys": "primary_keys",
    "foreign keys": "foreign_keys",
    "avg attrs/product": "avg_attrs_per_product",
    "avg attrs per product": "avg_attrs_per_product",
    "metric views": "metric_views",
    "model scope": "model_scope",
}

# Statistics fields coerced to float (never int) when parsed.
_STATS_FLOAT_FIELDS = {"avg_attrs_per_product"}
# Statistics fields left as raw strings (never coerced to a number).
_STATS_STRING_FIELDS = {"model_scope"}

_STATS_FIELDS = tuple(dict.fromkeys(_STATS_LABEL_MAP.values()))


def parse_model_statistics(text: str) -> dict[str, Any]:
    """Parse the ``MODEL STATISTICS`` block out of a release-notes document.

    Starts at the line containing ``MODEL STATISTICS`` and stops at the first
    full-width ``+----`` separator line or the next section header (a
    non-blank line with no ``:``). Each remaining line is stripped of ``|``
    and whitespace, then partitioned on ``:``; the label (case-insensitive)
    is mapped to a field via :data:`_STATS_LABEL_MAP` - line order is not
    relied on. A label with a leading ``"Total "`` (the real repo's actual
    convention, e.g. ``"Total Domains"``) falls back to its bare form
    (``"domains"``) so the map itself only needs the bare labels. Numeric
    fields are coerced with a ``try/except`` fallback to ``None``;
    ``avg_attrs_per_product`` coerces to ``float``, every other numeric field
    to ``int``, and ``model_scope`` stays a string.

    Returns a dict with every field in :data:`_STATS_FIELDS` set to ``None``
    when the block is absent, malformed, or contains no recognized labels -
    never partially populated in a way that would look like a parse success.
    """
    result: dict[str, Any] = {field: None for field in _STATS_FIELDS}
    lines = text.splitlines()

    start = None
    for i, line in enumerate(lines):
        if "MODEL STATISTICS" in line:
            start = i + 1
            break
    if start is None:
        return result

    for line in lines[start:]:
        stripped = line.strip()
        if not stripped:
            continue
        if set(stripped) <= {"+", "-"}:
            break
        content = stripped.strip("|").strip()
        if not content:
            continue
        if ":" not in content:
            break
        label, _, value = content.partition(":")
        label = label.strip().lower()
        value = value.strip()
        field = _STATS_LABEL_MAP.get(label)
        if field is None and label.startswith("total "):
            # Real releasenotes.txt files prefix the count labels with
            # "Total " (e.g. "Total Domains"); the map itself stays keyed on
            # the bare label so a future doc without the prefix still matches.
            field = _STATS_LABEL_MAP.get(label.removeprefix("total ").strip())
        if field is None:
            continue
        if field in _STATS_STRING_FIELDS:
            result[field] = value
        elif field in _STATS_FLOAT_FIELDS:
            try:
                result[field] = float(value)
            except (TypeError, ValueError):
                result[field] = None
        else:
            try:
                result[field] = int(value)
            except (TypeError, ValueError):
                result[field] = None
    return result


def _humanize(slug: str) -> str:
    """``energy_utilities`` → ``Energy Utilities``; ``ecm_v1`` → ``Ecm V1``."""
    return " ".join(part.capitalize() for part in slug.replace("-", "_").split("_") if part)


def _infer_scope(model_id: str) -> str | None:
    low = model_id.lower()
    if "ecm" in low:
        return "ecm"
    if "mvm" in low:
        return "mvm"
    return None


def _infer_version(model_id: str) -> str | None:
    for part in model_id.lower().replace("-", "_").split("_"):
        if part.startswith("v") and part[1:].isdigit():
            return part
    return None


def _version_num(version: str | None) -> int:
    """The trailing int of a ``vN`` token (``"v12" -> 12``); ``-1`` for an
    un-versioned / missing token. Shared with :func:`_infer_version`'s ``vN``
    convention so the resolver orders folders the same way the browse does."""
    if not version:
        return -1
    digits = version[1:] if version[:1].lower() == "v" else version
    return int(digits) if digits.isdigit() else -1


@dataclass(frozen=True)
class BaselineResolution:
    """The repo model a publish-preview diffs against, with its tier.

    ``candidates`` is populated ONLY in the ``none`` tier (so the FE can offer
    a manual pick); it is empty for a resolved baseline.
    """

    model_id: str | None
    tier: str  # "same_scope_latest" | "fallback_unverified" | "none"
    scope_mismatch: bool
    candidates: list[SourceModelRef] = field(default_factory=list)


def find_latest_same_scope_version(
    connector: GithubSourceConnector, industry_id: str, scope: str | None
) -> BaselineResolution:
    """Resolve the baseline repo model for a publish preview, tiered:

    * **Tier 1 ``same_scope_latest``** — the highest-version folder whose
      ``_infer_scope`` matches ``scope`` (tie-break: lexical-max id).
    * **Tier 2 ``fallback_unverified``** — no same-scope folder exists; pick
      the lexically-newest folder and flag ``scope_mismatch`` when its scope
      differs. A different scope is NEVER promoted to Tier 1.
    * **Tier 3 ``none``** — the industry lists no model folders.

    ``connector.list_models`` may raise ``SourceNotFoundError`` (unknown
    industry) / ``SourceError``; the resolver does NOT swallow those — the
    caller (the preview service) is the single catch point that maps them to
    Tier 3.
    """
    models = connector.list_models(industry_id)
    if not models:
        return BaselineResolution(None, "none", False, [])

    same = [m for m in models if m.scope == scope]
    if same:
        chosen = max(same, key=lambda m: (_version_num(m.version), m.id))
        return BaselineResolution(chosen.id, "same_scope_latest", False, [])

    chosen = max(models, key=lambda m: m.id)
    return BaselineResolution(
        chosen.id, "fallback_unverified", chosen.scope != scope, []
    )


def build_github_connector(
    repo_owner: str = "",
    repo_name: str = "",
    *,
    app_credentials: GithubAppCredentials | None = None,
    http: Any | None = None,
) -> GithubSourceConnector:
    """Build a connector, falling back to the default public repo.

    ``repo_owner`` / ``repo_name`` come from ``agent_config`` when the
    installation has set them; empty strings fall back to
    :data:`DEFAULT_REPO_OWNER` / :data:`DEFAULT_REPO_NAME`.

    This is the single point where the READ transport is chosen. Precedence:

    1. ``http`` - an explicit transport override (tests); wins.
    2. ``app_credentials`` present and complete -> :class:`GithubAppTransport`
       (installation token, 5,000 req/hr, immune to the target org's SAML SSO).
    3. otherwise -> anonymous ``requests`` (60 req/hr, degraded).

    The credentials are deployment-wide (``AppConfig``), not per-install. The
    per-user ``oauth_u2m`` UC connection is NO LONGER selected for reads (it was
    EMU/SAML-blocked on the test workspace); :class:`UcConnectionTransport` stays in the module
    for the future publish-PR path, which builds its transport independently
    (``services.github_publish``) and does not go through this builder.
    """
    transport = http
    if transport is None and app_credentials is not None and app_credentials.complete:
        transport = GithubAppTransport(app_credentials)
    return GithubSourceConnector(
        repo_owner=repo_owner or DEFAULT_REPO_OWNER,
        repo_name=repo_name or DEFAULT_REPO_NAME,
        http=transport,
    )
