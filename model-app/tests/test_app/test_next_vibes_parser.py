"""Wave 1 / Track E — structured next_vibes ingestion (ADR D-044).

The Model Evolution Metrics (``next_vibe_metrics.py``) count
``origin=agent_next_vibe`` VibeInputs by ``category`` and average their
``confidence_score`` (the Quality Score) over the open backlog anchored to a
version. The sync-time parser builds the structured findings directly from
``next_vibes.txt`` — there is no lossy instructions blob anymore.

These tests pin the structured contract:

* ``_parse_next_vibes_findings`` emits one finding per SA finding
  (``static_analysis``), PRIORITY line (``priority_remediation``), and
  "Other known issues" line (``other``), each with an ordinal, a severity
  (mapped to ``VibeInputPriority``), a target element name, and the
  payload's Quality Score (0..1 fraction).
* ``_next_vibes_payload_from_txt`` embeds the structured findings under
  ``_next_vibe_metadata.findings`` (no instructions blob).
* ``ModelSyncService.materialize_next_vibe_inputs`` writes one structured
  ``VibeInput(origin=agent_next_vibe)`` per finding, anchored via a
  ``VibeInputContextLink`` resolved against the version's elements (the
  D-045 anchoring pattern), idempotently.
* ``ModelSyncService.register_next_vibes_artifact`` registers the raw txt as
  a downloadable ``RunArtifact``.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    RunArtifact,
    RunInputLink,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.model_sync import (
    ModelSyncService,
    _next_vibes_payload_from_txt,
    _parse_next_vibes_findings,
)
from vibe_modeling.backend.models import NextVibeCategory, VibeInputOrigin, VibeInputPriority


# A realistic agent v0.6.x next_vibes.txt: header score, SA findings block,
# PRIORITY directives (em-dash AND double-hyphen separators both occur in
# the wild), an "Other known issues" section, and the deterministic footer.
SAMPLE_TXT = """**Model Quality Score: 76/100**

**Static Analysis Findings (3 actionable):**
  - [SA:unlinked_fk] Column customer.profile.region_id looks like an FK
  - [SA:cross_domain_duplicate] Potential SSOT violation on sale.order_line
  - [SA:denormalized_natural_key] Product 'inventory.fulfillment_location' has both FK and NK

**PRIORITY 1 — remove_fk: customer.profile** — remove FK on column fulfillment_location_id
**PRIORITY 2 -- connect_table: sale.order_line** -- add column sku_id with FK to product.sku

Other known issues from static analysis (2):
  - customer.profile has an orphaned column legacy_code
  - sale.order_line description is empty

Deterministic score: 76/100 (LLM assessment: 72/100)
"""


class TestParseNextVibesFindings:
    def test_emits_one_finding_per_source_line(self):
        findings = _parse_next_vibes_findings(SAMPLE_TXT)
        # 3 SA + 2 PRIORITY + 2 other = 7
        assert len(findings) == 7

    def test_categories_are_classified(self):
        findings = _parse_next_vibes_findings(SAMPLE_TXT)
        by_cat: dict[str, int] = {}
        for f in findings:
            by_cat[f.category.value] = by_cat.get(f.category.value, 0) + 1
        assert by_cat == {
            NextVibeCategory.STATIC_ANALYSIS.value: 3,
            NextVibeCategory.PRIORITY_REMEDIATION.value: 2,
            NextVibeCategory.OTHER.value: 2,
        }

    def test_quality_score_is_fraction_on_every_finding(self):
        findings = _parse_next_vibes_findings(SAMPLE_TXT)
        assert findings
        assert all(f.quality_score == pytest.approx(0.76) for f in findings)

    def test_priority_findings_are_high_severity(self):
        findings = _parse_next_vibes_findings(SAMPLE_TXT)
        prio = [f for f in findings if f.category == NextVibeCategory.PRIORITY_REMEDIATION]
        assert prio
        assert all(f.priority == VibeInputPriority.HIGH for f in prio)

    def test_sa_and_other_findings_are_lower_severity(self):
        findings = _parse_next_vibes_findings(SAMPLE_TXT)
        soft = [
            f for f in findings
            if f.category in (NextVibeCategory.STATIC_ANALYSIS, NextVibeCategory.OTHER)
        ]
        assert soft
        assert all(f.priority == VibeInputPriority.LOW for f in soft)

    def test_target_element_extracted_for_anchoring(self):
        findings = _parse_next_vibes_findings(SAMPLE_TXT)
        targets = {f.target for f in findings if f.target}
        # PRIORITY targets + SA-detected element references.
        assert "customer.profile" in targets
        assert "sale.order_line" in targets

    def test_ordinals_are_unique_and_stable(self):
        findings = _parse_next_vibes_findings(SAMPLE_TXT)
        ordinals = [f.ordinal for f in findings]
        assert len(ordinals) == len(set(ordinals))
        # Re-parsing yields the same ordinals (stable keying).
        again = _parse_next_vibes_findings(SAMPLE_TXT)
        assert [f.ordinal for f in again] == ordinals

    def test_no_findings_when_clean(self):
        text = "**Model Quality Score: 95/100**\nNo actionable suggestions."
        assert _parse_next_vibes_findings(text) == []


class TestPayloadFromTxtEmbedsFindings:
    def test_no_instructions_blob(self):
        """The structured payload carries no lossy instructions blob."""
        payload = _next_vibes_payload_from_txt(SAMPLE_TXT)
        assert "business_context" not in payload
        assert payload["_next_vibe_metadata"]["confidence_score"] == pytest.approx(0.76)

    def test_structured_findings_embedded(self):
        payload = _next_vibes_payload_from_txt(SAMPLE_TXT)
        findings = payload["_next_vibe_metadata"]["findings"]
        assert len(findings) == 7
        cats = {f["category"] for f in findings}
        assert cats == {
            NextVibeCategory.STATIC_ANALYSIS.value,
            NextVibeCategory.PRIORITY_REMEDIATION.value,
            NextVibeCategory.OTHER.value,
        }
        for f in findings:
            assert set(f) >= {"ordinal", "category", "priority", "title", "description", "target", "quality_score"}


def _seed_version_with_elements(engine) -> tuple[str, str]:
    """Create a business + version with the elements the SAMPLE_TXT targets."""
    with Session(engine) as session:
        b = Business(name="Acme")
        session.add(b)
        session.flush()
        mv = ModelVersion(business_id=b.id, version=1, status="completed")
        session.add(mv)
        session.flush()
        cust = Domain(version_id=mv.id, name="customer")
        sale = Domain(version_id=mv.id, name="sale")
        session.add(cust)
        session.add(sale)
        session.flush()
        session.add(Product(domain_id=cust.id, version_id=mv.id, name="profile", table_name="profile"))
        session.add(Product(domain_id=sale.id, version_id=mv.id, name="order_line", table_name="order_line"))
        session.commit()
        return b.id, mv.id


class TestMaterializeNextVibeInputs:
    def test_one_vibe_input_per_finding(self, engine):
        business_id, version_id = _seed_version_with_elements(engine)
        payload = _next_vibes_payload_from_txt(SAMPLE_TXT)
        with Session(engine) as session:
            svc = ModelSyncService(session)
            n = svc.materialize_next_vibe_inputs(version_id, business_id, payload)
            session.commit()
        assert n == 7
        with Session(engine) as session:
            rows = session.exec(
                select(VibeInput).where(VibeInput.business_id == business_id)
            ).all()
            assert len(rows) == 7
            assert all(r.origin == VibeInputOrigin.AGENT_NEXT_VIBE.value for r in rows)
            assert all(r.category is not None for r in rows)
            assert all(r.confidence_score == pytest.approx(0.76) for r in rows)

    def test_findings_anchor_to_resolved_elements(self, engine):
        business_id, version_id = _seed_version_with_elements(engine)
        payload = _next_vibes_payload_from_txt(SAMPLE_TXT)
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.materialize_next_vibe_inputs(version_id, business_id, payload)
            session.commit()
        with Session(engine) as session:
            # The PRIORITY findings target customer.profile / sale.order_line —
            # those links must resolve to a product (not model-wide).
            links = session.exec(
                select(VibeInputContextLink).where(
                    VibeInputContextLink.version_id == version_id,
                    VibeInputContextLink.product_id != None,  # noqa: E711
                )
            ).all()
            assert len(links) >= 2

    def test_idempotent(self, engine):
        business_id, version_id = _seed_version_with_elements(engine)
        payload = _next_vibes_payload_from_txt(SAMPLE_TXT)
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.materialize_next_vibe_inputs(version_id, business_id, payload)
            session.commit()
        with Session(engine) as session:
            svc = ModelSyncService(session)
            n2 = svc.materialize_next_vibe_inputs(version_id, business_id, payload)
            session.commit()
        assert n2 == 0  # nothing new on re-run
        with Session(engine) as session:
            rows = session.exec(
                select(VibeInput).where(VibeInput.business_id == business_id)
            ).all()
            assert len(rows) == 7

    def test_emitted_next_vibes_are_not_run_input_linked(self, engine):
        """Regression: a run must NOT consume the next_vibes it emits.

        Emitted next_vibes get only their ``VibeInputContextLink`` anchor —
        never a ``RunInputLink``. The run-finalize consumed-flip
        (``progress_tracker._finalize...``) marks ``consumed=true`` for every
        ``RunInputLink`` of the run, so a next_vibe that carried such a link
        was being consumed by the very run that generated it. Consume must
        require the input to have been SELECTED as input to a run (its
        ``RunInputLink`` is written at launch by
        ``router._persist_run_input_links``), so the materializer must leave
        emitted inputs unlinked and ``consumed=False``.
        """
        business_id, version_id = _seed_version_with_elements(engine)
        payload = _next_vibes_payload_from_txt(SAMPLE_TXT)
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.materialize_next_vibe_inputs(version_id, business_id, payload)
            session.commit()
        with Session(engine) as session:
            inputs = session.exec(
                select(VibeInput).where(VibeInput.business_id == business_id)
            ).all()
            assert inputs and all(vi.consumed is False for vi in inputs)
            emitted_ids = {vi.id for vi in inputs}
            run_links = session.exec(select(RunInputLink)).all()
            linked = [rl for rl in run_links if rl.input_id in emitted_ids]
            assert not linked, (
                f"emitted next_vibes must not be RunInputLinked to any run; "
                f"found {len(linked)} stray links"
            )

    def test_metrics_count_materialized_inputs(self, engine):
        from vibe_modeling.backend.next_vibe_metrics import compute_metrics

        business_id, version_id = _seed_version_with_elements(engine)
        payload = _next_vibes_payload_from_txt(SAMPLE_TXT)
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.materialize_next_vibe_inputs(version_id, business_id, payload)
            session.commit()
        with Session(engine) as session:
            metrics = compute_metrics(session, version_id)
            assert metrics.total_open == 7
            assert metrics.counts[NextVibeCategory.STATIC_ANALYSIS.value] == 3
            assert metrics.counts[NextVibeCategory.PRIORITY_REMEDIATION.value] == 2
            assert metrics.counts[NextVibeCategory.OTHER.value] == 2
            assert metrics.quality_score == pytest.approx(0.76)


class TestRegisterNextVibesArtifact:
    def test_registers_run_artifact(self, engine):
        business_id, version_id = _seed_version_with_elements(engine)
        path = "/Volumes/cat/_metamodel/vol_root/business/acme/mvm_v1/vibes/next_vibes.txt"
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.register_next_vibes_artifact(version_id, None, path)
            session.commit()
        with Session(engine) as session:
            arts = session.exec(
                select(RunArtifact).where(RunArtifact.model_version_id == version_id)
            ).all()
            assert len(arts) == 1
            assert arts[0].file_path == path
            assert arts[0].run_id is None
            assert arts[0].artifact_type == "next_vibes_txt"

    def test_idempotent_on_same_path(self, engine):
        business_id, version_id = _seed_version_with_elements(engine)
        path = "/Volumes/cat/vibes/next_vibes.txt"
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.register_next_vibes_artifact(version_id, None, path)
            svc.register_next_vibes_artifact(version_id, None, path)
            session.commit()
        with Session(engine) as session:
            arts = session.exec(
                select(RunArtifact).where(RunArtifact.model_version_id == version_id)
            ).all()
            assert len(arts) == 1
