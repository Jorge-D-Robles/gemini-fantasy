# Current Sprint

Sprint: S06-battle-completions-and-scenes
Milestone: M1
Goal: Complete battle system gaps (elemental damage, AoE, echo combat) and build remaining Act I scenes
Started: 2026-03-05
Closed: —

## Velocity
- Completed: 12
- Added mid-sprint: 0
- Rolled over: 0

---

## Active

*(none)*

---

## Queue

### T-0294 (already implemented)
- Title: Add party management UI — swap active and reserve members
- Status: done
- Assigned: claude

### T-0293 (done)
- Title: Create Roothollow tutorial quests — help villagers
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Tags: ui
- Depends: —
- Blocked-by: —
- Refs: game/ui/party_ui/, game/autoloads/party_manager.gd
- Notes: PartyManager supports 4 active + 4 reserve, but no UI to swap. Add party management screen from pause menu. Show recruited characters with stats. Swap between active/reserve. Cannot remove below 1 active. 5+ tests.

---

## Done This Sprint

- T-0272: Implement elemental weakness/resistance in damage calculation — compute_elemental_modifier() in BattlerDamage, wired into BattleActionExecutor, "Weak!"/"Resist!" battle log tags, ELEMENTAL_WEAKNESS_MULT (1.5x) and ELEMENTAL_RESISTANCE_MULT (0.5x) in GameBalance, 8 new tests
- T-0273: Implement AoE ability targeting — is_aoe()/is_auto_target() helpers in BAX, _execute_aoe_ability() in ActionExecuteState (EE once, damage per target), TargetSelectState auto-skips for AoE/SELF, 8 new tests
- T-0276: Create status effect .tres data files — poison, burn, stun, haste, slow, shield, weakness, regen; 8 new tests validating all fields
- T-0274: Implement Echo combat system — equip/unequip (max 6 slots) in EchoManager, per-battle use tracking, "echo" command in PlayerTurnState, echo mode in ActionSelectState, echo execution (DAMAGE/HEAL/BUFF/DEBUFF) in ActionExecuteState, BattleAction.ECHO type, auto-target for AoE/SELF echoes, serialize equipped echoes, 10 new tests
- T-0277: Implement heal-targeting for support abilities — is_ally_target() helper in BAX, execute_ability() heals allies instead of damaging, 6 new tests
- T-0293: Create Roothollow tutorial quests — lost_pendant.tres (Wren's Lost Pendant) + elders_request.tres (Elder's Request), 8 tests
- T-0294: Party management UI already implemented — party_ui.gd with swap, detail panel, equipment display, error feedback, focus navigation, data helpers
- T-0281: Verify Overgrown Capital → Verdant Forest return path — already wired (ExitToRuins → SP.VERDANT_FOREST, spawn_from_capital), 3 verification tests
- T-0282: Wire Verdant Forest → Prismfall Approach transition — ExitToPrismfall Area2D + SpawnFromPrismfall Marker2D in Forest, zone marker, bidirectional wiring verified, 8 new tests
- T-0289: Create Shard Serpent enemy — 80 HP BASIC AI, crystal_strike (stun)/burrow (self def)/shatter (AoE earth), weak to EARTH, added to Prismfall Approach encounters, 10 new tests
- T-0288: Create Thornback Bear enemy — 120 HP AGGRESSIVE AI, maul/thorn_volley/roar abilities, weak to FIRE resists EARTH, added to Verdant Forest + Overgrown Ruins as rare encounter, 9 new tests
- T-0275: Add Ground command — BattleAction.GROUND type, "ground" command in PlayerTurnState, Hollow ally targeting in TargetSelectState, _execute_ground in ActionExecuteState (25% resonance cost, cure Hollow, 25% HP heal), GROUND_RESONANCE_COST/GROUND_HEAL_PERCENT constants, 6 new tests
