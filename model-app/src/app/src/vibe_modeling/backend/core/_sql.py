"""Safe SQL construction helpers.

Use these instead of f-stringing values into Spark/Unity Catalog SQL. They
sit alongside :mod:`core._names` (which sanitizes/coerces unsafe inputs)
and provide the *assertion* + *parameterisation* layer:

- :func:`safe_identifier` — assert a value already IS a UC identifier and
  backtick-quote it for embedding in SQL. Never sanitizes silently.
- :func:`like_pattern` — escape ``%`` / ``_`` / ``\\`` for safe inclusion
  in a ``LIKE`` clause. Caller adds the wildcards they actually want.
- :func:`execute` — run a parameterised statement via the Databricks SQL
  Statement Execution API, with named placeholders bound through the SDK
  rather than f-stringed into the SQL text.

Phase 1 only ADDS this module. Existing call sites still build SQL with
f-strings; Phase 2 primitives use these helpers, and a follow-up sweep
migrates the rest.
"""

from __future__ import annotations

import re
from typing import Any, Mapping

# Unity Catalog identifiers: a letter or underscore followed by letters,
# digits, or underscores. We backtick-quote on output but reject anything
# that wouldn't be a plain identifier — dots, semicolons, spaces, empty
# strings, etc. NEVER silently sanitize; sanitation belongs in
# :mod:`core._names`.
_IDENT_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def safe_identifier(name: str) -> str:
    """Validate and backtick-quote a UC identifier (catalog/schema/table/column).

    Raises :class:`ValueError` on anything that isn't a plain identifier.
    Use :func:`core._names.sanitize_catalog_segment` (or similar) if you
    need to MAKE a name safe; this function is for ASSERTING a name
    already is safe before embedding it in SQL.

    >>> safe_identifier("my_catalog")
    '`my_catalog`'
    """
    if not isinstance(name, str) or not _IDENT_RE.match(name):
        raise ValueError(f"unsafe SQL identifier: {name!r}")
    return f"`{name}`"


def like_pattern(literal: str) -> str:
    """Escape ``%``, ``_`` and ``\\`` so ``literal`` is safe in a LIKE clause.

    The caller is responsible for adding any leading/trailing ``%`` they
    actually intend (i.e. this function only escapes — it never wraps).

    >>> like_pattern("100% off_now")
    '100\\\\% off\\\\_now'
    """
    return (
        (literal or "")
        .replace("\\", "\\\\")
        .replace("%", "\\%")
        .replace("_", "\\_")
    )


def execute(
    ws: Any,
    warehouse_id: str,
    sql: str,
    params: Mapping[str, Any] | None = None,
    wait_timeout: str = "50s",
) -> Any:
    """Run a parameterised SQL statement via the Databricks SQL API.

    ``sql`` should use named placeholders (e.g. ``:biz``) and ``params``
    binds them. The wrapper hands the bindings to the SDK as
    :class:`StatementParameterListItem` so the server does proper
    escaping — never f-string user-controlled values into the SQL text.

    Returns the SDK's ``StatementResponse``. The caller decides whether
    to poll or treat as terminal — this helper is intentionally thin.
    """
    from databricks.sdk.service.sql import StatementParameterListItem

    sdk_params: list[StatementParameterListItem] | None = None
    if params:
        sdk_params = [
            StatementParameterListItem(
                name=k,
                value=str(v) if v is not None else None,
            )
            for k, v in params.items()
        ]
    return ws.statement_execution.execute_statement(
        statement=sql,
        warehouse_id=warehouse_id,
        wait_timeout=wait_timeout,
        parameters=sdk_params,
    )
