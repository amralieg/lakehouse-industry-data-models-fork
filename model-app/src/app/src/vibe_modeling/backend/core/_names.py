"""Shared string-safety transforms used across the backend.

Three different concerns share this module because they're all small,
related, and called from many places:

- ``sanitize_tag`` — Databricks job tag value safety.
- ``sanitize_catalog_segment`` — UC catalog-identifier safety.
- ``escape_sql_literal`` — SQL single-quoted string-literal escaping.

These are not interchangeable: a catalog segment is a UC identifier
(no quoting), a tag is a Databricks tag value, and a SQL literal is a
value we're about to wrap in ``'…'``. Mixing them produces either
broken SQL or broken identifiers. Pick the one that matches the target
grammar.
"""

import re

# Tag: A-Za-z0-9 plus -, _, . internal. Starts/ends with alphanumeric.
_TAG_RE = re.compile(r"[^A-Za-z0-9._-]")
_MULTI_UNDERSCORE = re.compile(r"_+")

# Catalog segment: lowercase [a-z0-9_], underscores collapsed.
_CATALOG_SEGMENT_NON_SAFE = re.compile(r"[^a-z0-9_]+")
_CATALOG_SEGMENT_UNDERSCORES = re.compile(r"_+")

# Per-character probe for the agent boundary warning. The agent's
# `sanitize_name(strip_stop_words=False)` rule REPLACES every
# non-[a-z0-9_] char with `_` (then collapses + strips), so a single
# match means the input wasn't pre-normalized. Plain space included.
_AGENT_SEGMENT_NON_SAFE = re.compile(r"[^a-z0-9_]")


def sanitize_tag(value: str) -> str:
    """Sanitize a string for use as a Databricks job tag value.

    Per the Integration Guide: alphanumeric start/end, only A-Za-z0-9, -, _, . in between.
    Spaces and special chars are replaced with ``_``, consecutive ``_`` collapsed,
    leading/trailing ``_``, ``.``, ``-`` stripped. Truncated to 256 chars.
    """
    result = _TAG_RE.sub("_", value)
    result = _MULTI_UNDERSCORE.sub("_", result)
    result = result.strip("_.-")
    return result[:256]


def sanitize_catalog_segment(value: str) -> str:
    """Lowercase + replace non-[a-z0-9_] with ``_`` + collapse underscores.

    Used to derive multi-catalog names from a user-provided
    ``deployment_catalog`` so the result is a legal UC catalog identifier.
    Returns ``"vibe"`` if the input is empty or reduces to nothing.
    """
    s = _CATALOG_SEGMENT_NON_SAFE.sub("_", (value or "").lower())
    s = _CATALOG_SEGMENT_UNDERSCORES.sub("_", s).strip("_")
    return s or "vibe"


def agent_business_segment(name: str) -> str:
    """Normalize a business name to the form the agent uses on Volume paths
    and as the ``business_name`` widget value.

    Mirrors the bundled agent's ``sanitize_name(strip_stop_words=False)``
    (see ``src/app/vendored/agent/vibe_modelling_agent_v4.9.9.ipynb``,
    cell defining ``def sanitize_name(name, strip_stop_words=True):  #
    GEN-RUL-002``). The strip-stop-words branch is intentionally NOT
    applied here because the app passes raw business identifiers.

    Rule (in order):

    1. Lowercase.
    2. Replace every non-[a-z0-9_] char with ``_``.
    3. Collapse runs of ``_`` to a single ``_``.
    4. Strip leading/trailing ``_``.
    5. If the result starts with a digit, prepend ``_`` (UC catalog
       identifiers can't start with a digit).

    Examples (verified against the agent's notebook):

        ``'Test Retail.'`` → ``'test_retail'``
        ``'Acme.Inc'``     → ``'acme_inc'``
        ``'Acme & Co.'``   → ``'acme_co'``
        ``'  Foo Bar  '``  → ``'foo_bar'``
        ``'7-eleven'``     → ``'_7_eleven'``

    Empty/None → ``""``. The agent itself returns ``"unnamed_model"`` for
    empty input but only after a warning; for our boundary callers we
    want a falsy sentinel so callers can detect "no name was passed"
    rather than silently route everyone to a single shared folder.

    Use this whenever passing a business name to the model-sync layer,
    constructing a Volume path, or sending the ``business_name`` widget
    value to the agent.

    Distinguishes from :func:`sanitize_catalog_segment` only in (a) the
    digit-prefix guard and (b) the empty-default. Phase 4 of the
    drift-unification plan will collapse the two helpers; for Phase 1
    they're kept separate to keep call-site semantics explicit.
    """
    if not name:
        return ""
    s = _CATALOG_SEGMENT_NON_SAFE.sub("_", str(name).lower())
    s = _CATALOG_SEGMENT_UNDERSCORES.sub("_", s).strip("_")
    if s and s[0].isdigit():
        s = "_" + s
    return s


def metamodel_display_business(name: str) -> str:
    """The value the agent stores in ``_metamodel.business.business``.

    The agent's ``step_setup_and_clean`` (Cell 120) applies ``.title()`` to
    the ``business_name`` widget value, which the app sends as
    ``agent_business_segment(name)`` (a lowercase slug).  This helper
    mirrors that chain:

        agent_business_segment(name)  →  lowercase slug (e.g. ``terranova_copy``)
        .strip().title()              →  display-cased slug (e.g. ``Terranova_Copy``)

    Python's ``.title()`` capitalises after every non-alphabetical character,
    including ``_`` AND digits.  For example ``"retail2b"`` → ``"Retail2B"``
    (the ``b`` follows the digit ``2``).

    Use for ``business`` column values in ``_metamodel.business`` INSERTs.
    Prefer ``LOWER()`` wrapping in SQL for defensive reads so that rows
    written by older app versions (lowercase) still match.

    Never use for Volume path segments — those stay lowercase via
    :func:`agent_business_segment`.
    """
    seg = agent_business_segment(name)
    return seg.strip().title() if seg else ""


def escape_sql_literal(s: object) -> str:
    """Escape a value for inclusion inside a SQL single-quoted string.

    Doubles embedded single quotes, backslash-escapes backslashes, strips
    NUL bytes that would upset Databricks SQL parsing. Input is coerced
    to string. Intended only for values we're about to wrap in ``'…'`` —
    **never for identifiers**. Use ``sanitize_catalog_segment`` for UC
    catalog names or validate-against-allowlist for other identifiers.
    """
    if s is None:
        return ""
    return str(s).replace("\\", "\\\\").replace("'", "''").replace("\x00", "")
