"""Client gateway-error telemetry endpoint (E-04 observability).

The kickstart POST auto-retries transient edge-proxy 502/503/504s client-side.
A browser-only retry never reaches ``databricks apps logs``, so the client
beacons every occurrence here and the endpoint logs a WARNING - keeping a real
502 recurrence diagnosable server-side even when a retry recovers it.
"""

import logging


class TestClientGatewayErrorTelemetry:
    def test_logs_warning_and_acks(self, client, caplog):
        with caplog.at_level(
            logging.WARNING, logger="vibe_modeling.backend.routes.platform"
        ):
            resp = client.post(
                "/api/client-telemetry/gateway-error",
                json={
                    "status": 502,
                    "path": "/api/industry-models/ind-1/kickstart",
                    "attempt": 1,
                    "will_retry": True,
                    "context": "kickstart industry=ind-1 name=\"Acme\"",
                },
            )
        assert resp.status_code == 200
        assert resp.json() == {"logged": True}

        # The occurrence is recorded in the app logs with its context.
        records = [
            r for r in caplog.records
            if "client-reported gateway error" in r.getMessage()
        ]
        assert len(records) == 1
        msg = records[0].getMessage()
        assert "status=502" in msg
        assert "attempt=1" in msg
        assert "will_retry=True" in msg
        assert "/api/industry-models/ind-1/kickstart" in msg

    def test_will_retry_defaults_false_and_context_optional(self, client, caplog):
        with caplog.at_level(
            logging.WARNING, logger="vibe_modeling.backend.routes.platform"
        ):
            resp = client.post(
                "/api/client-telemetry/gateway-error",
                json={
                    "status": 504,
                    "path": "/api/x",
                    "attempt": 3,
                },
            )
        assert resp.status_code == 200
        assert resp.json() == {"logged": True}
        msg = next(
            r.getMessage()
            for r in caplog.records
            if "client-reported gateway error" in r.getMessage()
        )
        assert "will_retry=False" in msg

    def test_rejects_missing_required_field(self, client):
        # `status` is required — a malformed beacon is a 422, not a silent 200.
        resp = client.post(
            "/api/client-telemetry/gateway-error",
            json={"path": "/api/x", "attempt": 1},
        )
        assert resp.status_code == 422
