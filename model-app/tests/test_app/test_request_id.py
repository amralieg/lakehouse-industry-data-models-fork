"""Tests for the request-id correlation middleware (PLAN #53).

Covers four behaviours of ``RequestIdMiddleware``:
  1. Generates a UUID4 when no inbound ``X-Request-Id`` header is present.
  2. Echoes back an inbound id unchanged so clients can correlate.
  3. Sets and resets the ``current_request_id`` ContextVar around the
     request, so log records emitted from a handler pick the id up.
  4. The ContextVar is empty before / after the request — no bleed across
     requests.
"""

from __future__ import annotations

import os
import sys
import uuid

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

import logging
from fastapi import FastAPI
from fastapi.testclient import TestClient

from vibe_modeling.backend.core._request_id import (
    RequestIdMiddleware,
    RequestIdLogFilter,
    current_request_id,
    get_request_id,
)


def _make_app(observed: list[str]) -> FastAPI:
    app = FastAPI()
    app.add_middleware(RequestIdMiddleware)

    @app.get("/probe")
    def probe():
        # Snapshot the contextvar from inside the request so the test can
        # assert what the handler sees (rather than what the response
        # header echoes).
        observed.append(current_request_id.get())
        return {"rid": current_request_id.get()}

    return app


class TestRequestIdMiddleware:
    def test_generates_uuid_when_header_absent(self):
        observed: list[str] = []
        client = TestClient(_make_app(observed))
        resp = client.get("/probe")
        assert resp.status_code == 200
        rid = resp.headers["x-request-id"]
        # UUID4 — parses cleanly. The handler saw the same id.
        assert uuid.UUID(rid)
        assert observed == [rid]
        # Body matches the header — handler ContextVar matches client view.
        assert resp.json() == {"rid": rid}

    def test_echoes_inbound_header(self):
        observed: list[str] = []
        client = TestClient(_make_app(observed))
        inbound = "test-correlation-id-12345"
        resp = client.get("/probe", headers={"X-Request-Id": inbound})
        assert resp.status_code == 200
        assert resp.headers["x-request-id"] == inbound
        assert observed == [inbound]

    def test_inbound_header_case_insensitive(self):
        """HTTP headers are case-insensitive; Starlette normalises to lowercase
        but we assert the contract works regardless of how the client sent it."""
        observed: list[str] = []
        client = TestClient(_make_app(observed))
        resp = client.get("/probe", headers={"x-REQUEST-id": "abc-123"})
        assert resp.status_code == 200
        assert observed == ["abc-123"]

    def test_context_resets_between_requests(self):
        """Two sequential requests must each see only their own id —
        the middleware must reset the ContextVar in its ``finally`` even
        if the handler raised."""
        observed: list[str] = []
        client = TestClient(_make_app(observed))
        client.get("/probe", headers={"X-Request-Id": "first"})
        client.get("/probe", headers={"X-Request-Id": "second"})
        assert observed == ["first", "second"]

    def test_get_request_id_outside_request_returns_empty(self):
        # No middleware ran in this test scope — ContextVar is at its
        # default and helper returns "".
        assert get_request_id() == ""


class TestRequestIdLogFilter:
    def test_attaches_request_id_attribute(self):
        flt = RequestIdLogFilter()
        record = logging.LogRecord(
            "test", logging.INFO, __file__, 1, "msg", None, None
        )
        token = current_request_id.set("rid-from-test")
        try:
            assert flt.filter(record) is True
            assert record.request_id == "rid-from-test"
        finally:
            current_request_id.reset(token)

    def test_default_empty_string_outside_request(self):
        flt = RequestIdLogFilter()
        record = logging.LogRecord(
            "test", logging.INFO, __file__, 1, "msg", None, None
        )
        # No token set — the ContextVar default is "".
        assert flt.filter(record) is True
        assert record.request_id == ""
