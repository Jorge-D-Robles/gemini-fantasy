# Current Sprint

Sprint: S06-battle-completions-and-scenes
Milestone: M1
Goal: Complete battle system gaps (elemental damage, AoE, echo combat) and build remaining Act I scenes
Started: 2026-03-05
Closed: —

## Velocity
- Completed: 4
- Added mid-sprint: 0
- Rolled over: 0

---

## Active

*(none)*

---

## Queue

### Battle System (high priority)

### T-0277
- Title: Implement heal-targeting for support abilities (SINGLE_ALLY, SELF)
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: battle, core
- Depends: T-0273
- Blocked-by: —
- Refs: game/systems/battle/states/target_select_state.gd, game/systems/battle/battle_action_executor.gd
- Notes: Abilities with target_type SINGLE_ALLY or SELF should target party members, not enemies. Currently TargetSelectState likely only shows enemies. Add ally-targeting mode. Execute heal in ActionExecuteState using ability damage_base as heal amount. 5+ tests.

### Battle Data (medium priority)

### T-0275
- Title: Add Ground command to battle — cure Hollow ally
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: battle, resonance
- Depends: —
- Blocked-by: —
- Refs: game/systems/battle/states/player_turn_state.gd, docs/game-design/01-core-mechanics.md
- Notes: "Ground" command costs user's turn + 25% Resonance Gauge. Removes Hollow, restores 25% HP. Only visible when a party member is Hollow. 4+ tests.

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

### T-0288
- Title: Create Thornback Bear enemy — Verdant Tangle heavy hitter
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: battle, data, enemy
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/02-enemy-design.md, game/data/enemies/
- Notes: AGGRESSIVE AI, ~120 HP. Maul, Thorn Volley, Roar. Weak to Fire. Add to Verdant Forest and Overgrown Ruins encounter pools. 3+ tests.

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
