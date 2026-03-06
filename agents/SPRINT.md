# Current Sprint

Sprint: S06-battle-completions-and-scenes
Milestone: M1
Goal: Complete battle system gaps (elemental damage, AoE, echo combat) and build remaining Act I scenes
Started: 2026-03-05
Closed: —

## Velocity
- Completed: 7
- Added mid-sprint: 0
- Rolled over: 0

---

## Active

*(none)*

---

## Queue

### Battle System (high priority)

### Scene & Flow (medium priority)

### T-0282
- Title: Wire Verdant Forest → Prismfall Approach transition
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: scene, flow
- Depends: —
- Blocked-by: —
- Refs: game/scenes/verdant_forest/verdant_forest.gd, game/scenes/prismfall_approach/prismfall_approach.gd
- Notes: Add zone marker on south edge of Verdant Forest connecting to Prismfall Approach. Add corresponding north entry zone. Add transition type to GameManager. 3+ tests.

### T-0281
- Title: Wire Overgrown Capital → Verdant Forest return path
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: scene, flow
- Depends: —
- Blocked-by: —
- Refs: game/scenes/overgrown_capital/overgrown_capital.gd
- Notes: Exit zone in Overgrown Capital back to Verdant Forest. May already exist — verify first. 2+ tests.

### Enemies (medium priority)

### T-0289
- Title: Create Shard Serpent enemy — Crystalline Steppes construct
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: battle, data, enemy
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/02-enemy-design.md, game/data/enemies/
- Notes: BASIC AI, ~80 HP. Crystal Strike + Burrow + Shatter. Weak to blunt. Add to Prismfall Approach. 3+ tests.

---

## Done This Sprint

- T-0272: Implement elemental weakness/resistance in damage calculation — compute_elemental_modifier() in BattlerDamage, wired into BattleActionExecutor, "Weak!"/"Resist!" battle log tags, ELEMENTAL_WEAKNESS_MULT (1.5x) and ELEMENTAL_RESISTANCE_MULT (0.5x) in GameBalance, 8 new tests
- T-0273: Implement AoE ability targeting — is_aoe()/is_auto_target() helpers in BAX, _execute_aoe_ability() in ActionExecuteState (EE once, damage per target), TargetSelectState auto-skips for AoE/SELF, 8 new tests
- T-0276: Create status effect .tres data files — poison, burn, stun, haste, slow, shield, weakness, regen; 8 new tests validating all fields
- T-0274: Implement Echo combat system — equip/unequip (max 6 slots) in EchoManager, per-battle use tracking, "echo" command in PlayerTurnState, echo mode in ActionSelectState, echo execution (DAMAGE/HEAL/BUFF/DEBUFF) in ActionExecuteState, BattleAction.ECHO type, auto-target for AoE/SELF echoes, serialize equipped echoes, 10 new tests
- T-0277: Implement heal-targeting for support abilities — is_ally_target() helper in BAX, execute_ability() heals allies instead of damaging, 6 new tests
- T-0288: Create Thornback Bear enemy — 120 HP AGGRESSIVE AI, maul/thorn_volley/roar abilities, weak to FIRE resists EARTH, added to Verdant Forest + Overgrown Ruins as rare encounter, 9 new tests
- T-0275: Add Ground command — BattleAction.GROUND type, "ground" command in PlayerTurnState, Hollow ally targeting in TargetSelectState, _execute_ground in ActionExecuteState (25% resonance cost, cure Hollow, 25% HP heal), GROUND_RESONANCE_COST/GROUND_HEAL_PERCENT constants, 6 new tests
