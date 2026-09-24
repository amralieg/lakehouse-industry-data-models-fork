"""Blocker-A: empty task lists must not crash the parallel-execution helpers.

When a smart-worker stage is handed an empty task list, ``actual_workers``
collapses to ``min(max_workers, 0) == 0`` and the pool factory is asked for a
``ThreadPoolExecutor(max_workers=0)``, which the stdlib rejects with
``ValueError: max_workers must be greater than 0``. This surfaced at
``step_create_logical_schema`` when a stage legitimately had zero tasks to run.

Two independent guards fix it; both are exercised here against the real
notebook code (loaded by conftest into ``agent_helpers``):

  1. ``run_parallel_smart_workers`` returns ``[]`` immediately for empty tasks.
  2. ``guarded_thread_pool_executor`` floors ``max_workers`` at 1, defending
     every other caller when the global LLM pool is not active.

Both assertions raise ``ValueError`` on the pre-fix code and pass on the fix.
"""
import logging
from concurrent.futures import ThreadPoolExecutor
from contextlib import contextmanager

import pytest


@contextmanager
def _global_pool_disabled():
    """Force the ``_GLOBAL_LLM_POOL`` size to 0 so the factory takes the plain
    ``ThreadPoolExecutor`` branch (the branch the bug lived in), then restore."""
    import agent_helpers as ah

    pool = getattr(ah, "_GLOBAL_LLM_POOL", None)
    prev = pool.get("size") if isinstance(pool, dict) else None
    if isinstance(pool, dict):
        pool["size"] = 0
    try:
        yield
    finally:
        if isinstance(pool, dict) and prev is not None:
            pool["size"] = prev


def test_guarded_thread_pool_executor_floors_max_workers_at_one():
    from agent_helpers import guarded_thread_pool_executor

    with _global_pool_disabled():
        ex = guarded_thread_pool_executor(0, pool_name="blocker_a")
    try:
        assert isinstance(ex, ThreadPoolExecutor)
        assert ex.submit(lambda x: x + 1, 41).result() == 42
    finally:
        ex.shutdown(wait=False)


def test_run_parallel_smart_workers_empty_tasks_returns_empty():
    from agent_helpers import run_parallel_smart_workers

    logger = logging.getLogger("blocker_a_test")
    logger.addHandler(logging.NullHandler())

    called = {"n": 0}

    def _worker(task):
        called["n"] += 1
        return task

    with _global_pool_disabled():
        result = run_parallel_smart_workers(
            tasks=[],
            worker_func=_worker,
            max_workers=4,
            logger=logger,
            task_description="blocker_a_empty",
        )

    assert result == []
    assert called["n"] == 0
