"""Publish an exported model version to GitHub as a single pull request.

The publish flow is the write-side sibling of the read-only bundle export
(``model_export.build_bundle_zip_bytes``): it reconstructs the version's
``model.json`` + companion artifacts via the SAME single-source iterator
(:func:`model_export.iter_bundle_files`) so the published tree and the
downloadable zip can never diverge, then pushes every file to a fresh branch
on the configured GitHub repo through the Unity Catalog HTTP connection and
opens one PR.

Auth is OAuth U2M only for now: the request is shaped through the user's
own WorkspaceClient (OBO) against a UC HTTP connection
(``AgentConfig.github_connection_name``) so the commits are attributed to the
acting user. The secret-PAT fallback is NOT implemented yet — it returns a
clear 422 rather than silently doing nothing.

This module deliberately does the HTTP shaping itself (rather than reusing the
read-side ``sources/github.py`` client) because that client speaks the SDK's
plain ``requests`` path against the public read mirror, whereas publish must go
through the UC connection's ``serving_endpoints.http_request`` so the token
never touches the app. The two share only the default-repo constants.
"""

from __future__ import annotations

import base64
import json
from dataclasses import dataclass, field
from datetime import datetime, timezone

from databricks.sdk.service.serving import ExternalFunctionRequestHttpMethod
from fastapi import HTTPException
from sqlmodel import Session, select

from ..db_models import AgentConfig, Business, ModelVersion, Run, RunArtifact
from ..model_export import (
    bundle_layout,
    export_model_json,
    iter_bundle_files,
    resolve_bundle_root,
)
from ..sources.github import DEFAULT_REPO_NAME, DEFAULT_REPO_OWNER


@dataclass(frozen=True)
class PublishResult:
    """Outcome of a successful publish."""

    branch: str
    pr_number: int
    pr_url: str
    files: list[str] = field(default_factory=list)
    target_path: str = ""


def _http_json(resp) -> dict:
    """Parse the JSON body of a UC ``http_request`` response.

    ``ServingEndpointsExt.http_request`` returns a ``requests.Response`` whose
    body is on ``.text``. A base ``HttpRequestResponse`` instead exposes a
    ``contents`` stream. Handle both; returns ``{}`` on an empty/unparseable body.
    """
    text = getattr(resp, "text", None)
    if isinstance(text, str):
        if not text:
            return {}
        try:
            return json.loads(text)
        except (ValueError, TypeError):
            return {}
    contents = getattr(resp, "contents", None)
    if contents is None:
        return {}
    raw = contents.read() if hasattr(contents, "read") else contents
    if isinstance(raw, bytes):
        raw = raw.decode("utf-8", errors="replace")
    if not raw:
        return {}
    try:
        return json.loads(raw)
    except (ValueError, TypeError):
        return {}


def publish_model_version(
    user_ws,
    cfg: AgentConfig,
    *,
    session: Session,
    business_id: str,
    version_id: str,
    target_path: str | None = None,
) -> PublishResult:
    """Publish a model version's bundle to GitHub as a single PR.

    Resolves the GitHub config off ``cfg`` and GUARDS hard:

    * ``github_auth_mode != "oauth_u2m"`` or no ``github_connection_name`` ->
      ``HTTPException(422, github_connection_missing)``. This is the
      human-gated boundary: the UC HTTP connection must be created by an
      operator and named in Settings before publish can work.
    * ``github_auth_mode == "secret_pat"`` -> ``HTTPException(422,
      github_pat_not_implemented)``; the PAT publish path is deferred.

    On the happy path it reconstructs ``model.json`` + artifacts via
    :func:`iter_bundle_files`, PUTs each file to a new branch via the GitHub
    Contents API (routed through the UC connection), opens one PR, and records
    an audit :class:`Run`.
    """
    if cfg.github_auth_mode == "secret_pat":
        raise HTTPException(
            status_code=422,
            detail={
                "error": "github_pat_not_implemented",
                "message": "Secret-PAT GitHub publish is not implemented yet. "
                "Use the OAuth U2M UC HTTP connection.",
            },
        )

    if cfg.github_auth_mode != "oauth_u2m" or not cfg.github_connection_name:
        raise HTTPException(
            status_code=422,
            detail={
                "error": "github_connection_missing",
                "message": "Create the github_pr UC HTTP connection and set it "
                "in Settings.",
            },
        )

    owner = cfg.github_repo_owner or DEFAULT_REPO_OWNER
    repo = cfg.github_repo_name or DEFAULT_REPO_NAME
    connection_name = cfg.github_connection_name

    mv = session.get(ModelVersion, version_id)
    if mv is None or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="ModelVersion not found")

    business = session.get(Business, business_id)
    root = resolve_bundle_root(
        override=target_path,
        business=business,
        scope=mv.scope or "",
        version=mv.version,
    )

    model_json = export_model_json(session, version_id)
    layout = bundle_layout(
        mv.scope or "", mv.scope or "", mv.version, dir_override=root
    )
    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.model_version_id == version_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()

    base_branch = _default_branch(user_ws, connection_name, owner, repo)
    base_sha = _branch_head_sha(
        user_ws, connection_name, owner, repo, base_branch
    )

    ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    branch = f"publish/{layout.industry}-{layout.scope}-v{layout.version}-{ts}"

    _create_branch_ref(user_ws, connection_name, owner, repo, branch, base_sha)

    published: list[str] = []
    for bundle_path, data in iter_bundle_files(
        user_ws, layout, model_json, artifacts
    ):
        _put_file(
            user_ws,
            connection_name,
            owner,
            repo,
            branch,
            bundle_path,
            data,
        )
        published.append(bundle_path)

    pr = _open_pull_request(
        user_ws,
        connection_name,
        owner,
        repo,
        head=branch,
        base=base_branch,
        title=f"Publish {layout.industry} {layout.scope} v{layout.version}",
        body=(
            f"Automated publish of model version `{version_id}` "
            f"({len(published)} files)."
        ),
    )
    pr_number = int(pr.get("number", 0))
    pr_url = pr.get("html_url", "")

    _record_audit(
        session,
        business_id=business_id,
        version_id=version_id,
        branch=branch,
        pr_number=pr_number,
        pr_url=pr_url,
        files=published,
    )

    return PublishResult(
        branch=branch,
        pr_number=pr_number,
        pr_url=pr_url,
        files=published,
        target_path=layout.dir,
    )


# --- GitHub Contents/Git API calls (all via the UC HTTP connection) --------


def _default_branch(user_ws, connection_name, owner, repo) -> str:
    resp = user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.GET,
        f"/repos/{owner}/{repo}",
    )
    return _http_json(resp).get("default_branch") or "main"


def _branch_head_sha(user_ws, connection_name, owner, repo, branch) -> str:
    resp = user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.GET,
        f"/repos/{owner}/{repo}/git/ref/heads/{branch}",
    )
    obj = _http_json(resp).get("object") or {}
    sha = obj.get("sha")
    if not sha:
        raise HTTPException(
            status_code=502,
            detail=f"Could not resolve head SHA of {branch!r} on {owner}/{repo}",
        )
    return sha


def _create_branch_ref(user_ws, connection_name, owner, repo, branch, base_sha):
    user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.POST,
        f"/repos/{owner}/{repo}/git/refs",
        json={"ref": f"refs/heads/{branch}", "sha": base_sha},
    )


def _put_file(user_ws, connection_name, owner, repo, branch, bundle_path, data):
    user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.PUT,
        f"/repos/{owner}/{repo}/contents/{bundle_path}",
        json={
            "message": f"Publish {bundle_path}",
            "content": base64.b64encode(data).decode("ascii"),
            "branch": branch,
        },
    )


def _open_pull_request(
    user_ws, connection_name, owner, repo, *, head, base, title, body
) -> dict:
    resp = user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.POST,
        f"/repos/{owner}/{repo}/pulls",
        json={"title": title, "head": head, "base": base, "body": body},
    )
    return _http_json(resp)


def _record_audit(
    session: Session,
    *,
    business_id: str,
    version_id: str,
    branch: str,
    pr_number: int,
    pr_url: str,
    files: list[str],
) -> None:
    """Record a terminal-success audit ``Run`` for the publish.

    Publish is synchronous (no Databricks job), so the Run is stamped
    completed inline; its ``parameters_json`` carries the PR provenance so the
    run history reads as "published version X to PR #Y".
    """
    now = datetime.now(timezone.utc)
    run = Run(
        business_id=business_id,
        version_id=version_id,
        intent="publish-to-github",
        status="completed",
        progress_percent=100,
        progress_message=f"Published to PR #{pr_number}",
        parameters_json=json.dumps(
            {
                "source": "github_publish",
                "branch": branch,
                "pr_number": pr_number,
                "pr_url": pr_url,
                "files": files,
            }
        ),
        started_at=now,
        completed_at=now,
    )
    session.add(run)
    session.commit()
