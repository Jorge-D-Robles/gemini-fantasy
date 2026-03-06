# Current Sprint

Sprint: S05-code-health
Milestone: M1
Goal: Code health sweep — remove dead code, consolidate duplicated logic, de-bloat test suite
Started: 2026-03-05
Closed: —

## Velocity
- Completed: 6
- Added mid-sprint: 0
- Rolled over: 0

---

## Active

- T-0271: Simplify MemorialEchoStrategy.execute() with early returns (Assigned: claude, Started: 2026-03-05)

---

## Queue

### Code Health (high priority)

- T-0266: Remove dead functions — get_failed_quests() and compute_echo_count()
- T-0267: Consolidate duplicated dialogue pair-builder into DialogueLine.build_from_pairs()
- T-0269: Test suite de-bloat round 2 — remove ~78 trivial/redundant test functions

### Code Health (medium priority)

- T-0268: De-duplicate quest restore functions in QuestManager
- T-0270: Simplify BattleActionExecutor.execute_attack() — extract crit/non-crit branches

### Code Health (low priority)

- T-0271: Simplify MemorialEchoStrategy.execute() with early returns

---

## Done This Sprint

- T-0265: Remove unused signals from EventBus and PartyManager — removed 5 signals + emit helpers + call sites, 7 tests removed
- T-0266: Remove dead functions — get_failed_quests() and compute_echo_count() — zero production callers, 2 tests removed
- T-0267: Consolidate duplicated dialogue pair-builder into DialogueLine.build_from_pairs() — replaced 4 implementations with 1 static method, 3 new tests
- T-0269: Test suite de-bloat round 2 — removed 72 trivial tests across 12 files (1682→1610), 1 file deleted
- T-0268: De-duplicate quest restore functions in QuestManager — merged 2 identical restore funcs into 1 parameterized _restore_quests_by_state()
- T-0270: Simplify BattleActionExecutor.execute_attack() — extracted duplicated crit/non-crit branches, 56→42 lines
