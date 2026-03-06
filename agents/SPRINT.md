# Current Sprint

Sprint: S06-battle-completions-and-scenes
Milestone: M1
Goal: Complete battle system gaps (elemental damage, AoE, echo combat) and build remaining Act I scenes
Started: 2026-03-05
Closed: —

## Velocity
- Completed: 1
- Added mid-sprint: 0
- Rolled over: 0

---

## Active

*(none)*

---

## Queue

### Battle System (high priority)

### T-0273
- Title: Implement AoE ability targeting (ALL_ENEMIES, ALL_ALLIES)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: battle, core
- Depends: —
- Blocked-by: —
- Refs: game/systems/battle/states/action_execute_state.gd, game/resources/ability_data.gd
- Notes: AbilityData defines TargetType enum (SINGLE_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES, SELF) but ActionExecuteState only handles single-target execution. When target_type is ALL_ENEMIES, iterate `battle_scene.get_living_enemies()` and apply damage/status to each. Same for ALL_ALLIES with `get_living_party()`. SELF targets the caster. Update TargetSelectState to auto-select all valid targets for AoE. Update BattleUI to show AoE indicator. 6+ tests.

### T-0274
- Title: Implement Echo combat system — equip and use echoes in battle
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: battle, echo, ui
- Depends: —
- Blocked-by: —
- Refs: game/resources/echo_data.gd, game/autoloads/echo_manager.gd, game/systems/battle/states/player_turn_state.gd
- Notes: Design doc specifies 6 shared Echo Slots the party equips before battle. EchoData already has `uses_per_battle`, `effect_type`, `effect_value`, `element`, `target_type`. Implementation: (1) Add `equipped_echoes: Array[EchoData]` (max 6) to EchoManager with equip/unequip methods. (2) Add "echo" command to PlayerTurnState command menu. (3) Create EchoSelectState or reuse ActionSelect to show equipped echoes. (4) Execute echo effects in ActionExecuteState (DAMAGE, HEAL, BUFF, DEBUFF). (5) Track per-battle uses remaining. (6) Serialize equipped echoes in SaveManager. 8+ tests.

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

### T-0276
- Title: Create status effect .tres data files for core effects
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: battle, data
- Depends: —
- Blocked-by: —
- Refs: game/resources/status_effect_data.gd, game/data/
- Notes: Create: poison.tres, burn.tres, stun.tres, haste.tres, slow.tres, shield.tres, weakness.tres, regen.tres. Wire abilities that reference these. 4+ tests.

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
