"""Unit tests for run_version_semantics — input/output version helpers."""

import pytest

from vibe_modeling.backend.models import Intent
from vibe_modeling.backend.run_version_semantics import (
    input_version_for,
    output_version_for,
    parse_version,
)


class TestParseVersion:
    @pytest.mark.parametrize(
        "value,expected",
        [
            ("v3", 3),
            ("V4", 4),
            ("3", 3),
            (3, 3),
            ("v0", 0),
            (" v7 ", 7),
            (None, None),
            ("", None),
            ("   ", None),
            ("not-a-version", None),
            ("v", None),
        ],
    )
    def test_parses_expected(self, value, expected):
        assert parse_version(value) == expected


class TestInputVersionFor:
    def test_new_base_model_has_no_input(self):
        params = {"model_version": "v1"}
        assert input_version_for(Intent.NEW_BASE_MODEL.value, params) is None

    def test_vibe_input_is_base_version_from_widget(self):
        params = {"model_version": "v3"}
        assert input_version_for(Intent.VIBE_ITERATE.value, params) == 3

    def test_install_target_is_input(self):
        params = {"model_version": "v4"}
        assert input_version_for(Intent.INSTALL.value, params) == 4

    def test_missing_widget_is_none(self):
        assert input_version_for(Intent.VIBE_ITERATE.value, {}) is None


class TestOutputVersionFor:
    def test_new_base_model_returns_widget_value(self):
        params = {"model_version": "v1"}
        assert (
            output_version_for(Intent.NEW_BASE_MODEL.value, params, new_version_num=99)
            == 1
        )

    def test_new_base_model_defaults_to_one_when_missing(self):
        assert output_version_for(Intent.NEW_BASE_MODEL.value, {}) == 1

    def test_vibe_returns_new_version_num_not_widget_base(self):
        # The classic bug: widget carries the base, app allocated v4 for the output.
        params = {"model_version": "v3"}
        assert (
            output_version_for(Intent.VIBE_ITERATE.value, params, new_version_num=4)
            == 4
        )

    def test_vibe_without_new_version_num_is_none(self):
        params = {"model_version": "v3"}
        assert output_version_for(Intent.VIBE_ITERATE.value, params) is None

    @pytest.mark.parametrize(
        "intent",
        [
            Intent.INSTALL,
            Intent.UNINSTALL,
            Intent.GENERATE_SAMPLES,
            Intent.REVERT,
        ],
    )
    def test_lifecycle_ops_have_no_output_version(self, intent):
        assert output_version_for(intent.value, {"model_version": "v2"}, new_version_num=99) is None
