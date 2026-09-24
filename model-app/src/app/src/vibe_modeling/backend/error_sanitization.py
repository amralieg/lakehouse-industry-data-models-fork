"""Error message sanitization — strips sensitive information from API error responses."""

import logging
import re

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

logger = logging.getLogger(__name__)

# Maximum length for error messages returned to clients
MAX_ERROR_LENGTH = 500

# Patterns to strip from error messages
_PATTERNS = [
    # Workspace and Volume paths
    re.compile(r"/Workspace/[^\s,;\"']+"),
    re.compile(r"/Volumes/[^\s,;\"']+"),
    # DBFS paths
    re.compile(r"dbfs:/[^\s,;\"']+"),
    # Email addresses
    re.compile(r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"),
    # API tokens (dapi… or similar bearer tokens)
    re.compile(r"\bdapi[a-f0-9]{32,}\b"),
    re.compile(r"\bBearer\s+[A-Za-z0-9_\-.]+", re.IGNORECASE),
    # Generic long hex strings that may be tokens (40+ hex chars)
    re.compile(r"\b[a-f0-9]{40,}\b"),
]

_REDACTED = "[REDACTED]"


def sanitize_error_message(message: str) -> str:
    """Remove sensitive information from an error message and cap its length."""
    for pattern in _PATTERNS:
        message = pattern.sub(_REDACTED, message)
    if len(message) > MAX_ERROR_LENGTH:
        message = message[:MAX_ERROR_LENGTH] + "..."
    return message


def register_error_handlers(app: FastAPI) -> None:
    """Register global exception handlers that sanitize error messages."""

    @app.exception_handler(StarletteHTTPException)
    async def http_exception_handler(request: Request, exc: StarletteHTTPException):
        # 4xx is expected behaviour — log at INFO, no stack trace. 5xx from
        # explicit HTTPException(status_code=5xx) is rare but worth a traceback.
        if exc.status_code >= 500:
            logger.exception(
                "HTTPException %s on %s %s", exc.status_code, request.method, request.url.path
            )
        else:
            logger.info(
                "HTTPException %s on %s %s: %s",
                exc.status_code, request.method, request.url.path, exc.detail,
            )
        detail = str(exc.detail) if exc.detail else "An error occurred"
        return JSONResponse(
            status_code=exc.status_code,
            content={"detail": sanitize_error_message(detail)},
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception):
        # Always log the full traceback server-side; the sanitized body hides
        # sensitive detail from the client but operators need the real error
        # to debug. Without this, every 500 in production is opaque.
        logger.exception(
            "Unhandled %s on %s %s", type(exc).__name__, request.method, request.url.path
        )
        detail = str(exc) if str(exc) else "Internal server error"
        return JSONResponse(
            status_code=500,
            content={"detail": sanitize_error_message(detail)},
        )
