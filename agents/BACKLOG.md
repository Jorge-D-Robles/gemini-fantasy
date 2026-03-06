# Backlog

All tickets not in the current sprint. Sorted by milestone, then priority.
Completed and superseded tickets are in `agents/COMPLETED.md`.

---

## M1 — Act I: The Echo Thief

### Battle System Completions

### T-0272
- Title: Implement elemental weakness/resistance in damage calculation
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Tags: battle, core
- Depends: —
- Blocked-by: —
- Refs: game/systems/battle/battler_damage.gd, game/resources/enemy_data.gd, game/resources/ability_data.gd
- Notes: EnemyData already has `weaknesses` and `resistances` (Array[Element]) fields, and AbilityData has `element`. But BattlerDamage formulas don't factor in elemental matchups. Add `compute_elemental_modifier(element, weaknesses, resistances) -> float` (e.g., 1.5x weak, 0.5x resist, 1.0x neutral). Wire into `BattleActionExecutor.execute_ability()`. Show "Weak!" or "Resist!" in battle log. 5+ tests.

### T-0273
- Title: Implement AoE ability targeting (ALL_ENEMIES, ALL_ALLIES)
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Tags: battle, core
- Depends: —
- Blocked-by: —
- Refs: game/systems/battle/states/action_execute_state.gd, game/resources/ability_data.gd
- Notes: AbilityData defines TargetType enum (SINGLE_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES, SELF) but ActionExecuteState only handles single-target execution. When target_type is ALL_ENEMIES, iterate `battle_scene.get_living_enemies()` and apply damage/status to each. Same for ALL_ALLIES with `get_living_party()`. SELF targets the caster. Update TargetSelectState to auto-select all valid targets for AoE. Update BattleUI to show AoE indicator. 6+ tests.

### T-0274
- Title: Implement Echo combat system — equip and use echoes in battle
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Tags: battle, echo, ui
- Depends: —
- Blocked-by: —
- Refs: game/resources/echo_data.gd, game/autoloads/echo_manager.gd, game/systems/battle/states/player_turn_state.gd
- Notes: Design doc specifies 6 shared Echo Slots the party equips before battle. EchoData already has `uses_per_battle`, `effect_type`, `effect_value`, `element`, `target_type`. Implementation: (1) Add `equipped_echoes: Array[EchoData]` (max 6) to EchoManager with equip/unequip methods. (2) Add "echo" command to PlayerTurnState command menu. (3) Create EchoSelectState or reuse ActionSelect to show equipped echoes. (4) Execute echo effects in ActionExecuteState (DAMAGE, HEAL, BUFF, DEBUFF). (5) Track per-battle uses remaining. (6) Serialize equipped echoes in SaveManager. 8+ tests.

### T-0275
- Title: Add Ground command to battle — cure Hollow ally
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Tags: battle, resonance
- Depends: —
- Blocked-by: —
- Refs: game/systems/battle/states/player_turn_state.gd, docs/game-design/01-core-mechanics.md
- Notes: Design doc: "Ground" command available to all non-Hollowed party members when an ally is Hollow. Cost: user's turn + 25% of user's Resonance Gauge. Effect: removes Hollow state, restores 25% HP. Add "ground" command to PlayerTurnState (only visible when a party member is Hollow). Target selection filters to Hollow allies only. Execute via Battler.cure_hollow() + heal. This is thematically central — an ally sharing their "self" to bring someone back. 4+ tests.

### T-0276
- Title: Create status effect .tres data files for core effects
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Tags: battle, data
- Depends: —
- Blocked-by: —
- Refs: game/resources/status_effect_data.gd, game/data/, docs/game-design/01-core-mechanics.md
- Notes: BattleActionExecutor.try_apply_status() creates StatusEffectData on the fly from ability fields, but we have no .tres files for standalone status effects. Create: poison.tres (DOT 5/turn, 3 turns), burn.tres (DOT 8/turn, 2 turns), stun.tres (prevents_action, 1 turn), haste.tres (speed+5, 3 turns), slow.tres (speed-5, 3 turns), shield.tres (defense+8, 3 turns), weakness.tres (defense-5, 3 turns), regen.tres (HOT 10/turn, 3 turns). Wire abilities that reference these by name to use the actual .tres. 4+ tests.

### T-0277
- Title: Implement heal-targeting for support abilities (SINGLE_ALLY, SELF)
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Tags: battle, core
- Depends: T-0273
- Blocked-by: —
- Refs: game/systems/battle/states/target_select_state.gd, game/systems/battle/battle_action_executor.gd
- Notes: Abilities with target_type SINGLE_ALLY or SELF should target party members, not enemies. Currently TargetSelectState likely only shows enemies. Add ally-targeting mode: when ability target is SINGLE_ALLY, show living party members as targets. SELF auto-targets caster. Execute heal in ActionExecuteState using ability damage_base as heal amount. Several abilities already have SINGLE_ALLY/ALL_ALLIES target types (echo_mend, empathic_shield, etc.). 5+ tests.

### Scene Building

### T-0278
- Title: Build Prismfall town scene — Act I hub
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: scene, tilemap, story
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/03-world-map-and-locations.md (Prismfall), game/scenes/
- Notes: Trading hub at canyon edge, ~8000 population. Districts: Market Plaza, Canyon Edge, Caravan Quarter, The Archives. Services: inn, shops (best Echo selection), Echo Archive, Resonance Beacon. Create scene with tilemap (use TF_TERRAIN for ground, building tiles from stone/steampunk packs), NPCs (innkeeper, shopkeepers, archive scholar), zone transitions to Prismfall Approach and Beneath Prismfall. Add to ScenePaths. Create encounter-free safe zone. Shop with mid-tier equipment and items. 6+ tests.

### T-0279
- Title: Build Beneath Prismfall dungeon scene — Act I climax location
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: scene, tilemap, dungeon, story
- Depends: T-0278
- Blocked-by: —
- Refs: docs/game-design/05-dungeon-designs.md (Beneath Prismfall), docs/story/act1/09-beneath-prismfall.md
- Notes: Dungeon beneath Prismfall where party assembles Lyra's consciousness. Crystal-heavy tilemap (use crystal/dungeon tilesets). Enemies: crystal constructs and echo manifestations. Contains save point, campfire, and the Convergence reveal trigger point. Boss: could be a crystal guardian or directly lead to Ch9 event. Multiple rooms with resonance puzzles (use existing ResonanceTerminalStrategy pattern). 6+ tests.

### T-0280
- Title: Wire Prismfall Approach → Prismfall town scene transition
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: scene, flow
- Depends: T-0278
- Blocked-by: —
- Refs: game/scenes/prismfall_approach/prismfall_approach.gd, game/systems/scene_paths.gd
- Notes: Add zone marker exit in Prismfall Approach that transitions to Prismfall town. Add corresponding entry zone in Prismfall. Add transition type to GameManager.compute_transition_type(). Update ScenePaths with PRISMFALL constant. 3+ tests.

### T-0281
- Title: Wire Overgrown Capital → Verdant Forest return path
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: scene, flow
- Depends: —
- Blocked-by: —
- Refs: game/scenes/overgrown_capital/overgrown_capital.gd, game/systems/scene_paths.gd
- Notes: After completing the Overgrown Capital, the party needs to return through Verdant Forest to continue toward Prismfall. Add exit zone marker in Overgrown Capital that transitions back to Verdant Forest. May already exist — verify first. If so, close as duplicate. 2+ tests.

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
- Notes: Verdant Forest should connect south to Prismfall Approach (Crystalline Steppes). Add zone marker on south edge of Verdant Forest. Add corresponding north entry zone in Prismfall Approach. Add transition type to GameManager. 3+ tests.

### Story Events — Upgrade Scaffolds to Full Implementation

### T-0283
- Title: Complete Chapter 6 "Born from Nothing" event — full Nyx origin dialogue
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: story, event
- Depends: —
- Blocked-by: —
- Refs: docs/story/act1/06-born-from-nothing.md, game/events/nyx_introduction.gd
- Notes: Current nyx_introduction.gd (190 lines) covers Nyx's initial appearance. Chapter 6 is about Nyx's mysterious origin from The Hollows — they're an Echo who became self-aware with no human memories. Expand into full event with: Nyx appearing at camp, party debate about whether to trust them, Nyx demonstrating terrifying power, emotional moment where Nyx asks "What am I?" Reference docs/story/act1/06-born-from-nothing.md for full scene script. 6+ tests.

### T-0284
- Title: Complete Chapter 7 "A Village Burns" event — full dialogue and branching
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: story, event
- Depends: —
- Blocked-by: —
- Refs: docs/story/act1/07-a-village-burns.md, game/events/village_burns.gd
- Notes: Current village_burns.gd (161 lines) is a scaffold with basic structure. Full chapter: Shepherds of Silence attack a village (possibly Roothollow), party must respond. Involves moral choice about how to handle the Shepherds. Expand with full dialogue from story script, add branching based on player choices, set reputation flags (Shepherds faction). 6+ tests.

### T-0285
- Title: Complete Chapter 8 "The Crystal City" event — Prismfall arrival
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: story, event
- Depends: T-0278
- Blocked-by: —
- Refs: docs/story/act1/08-the-crystal-city.md, game/events/crystal_city_arrival.gd
- Notes: Current crystal_city_arrival.gd (157 lines) is a scaffold. Full chapter: party arrives at Prismfall, discovers it's a trading hub with information about The Convergence. Meet NPCs with crucial lore. Access The Archives to learn about Lyra's fragments. Set up the descent into Beneath Prismfall. Reference story script for full dialogue. 6+ tests.

### T-0286
- Title: Complete Chapter 9 "Beneath Prismfall" event — Lyra's truth and Convergence reveal
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: story, event, climax
- Depends: T-0279
- Blocked-by: —
- Refs: docs/story/act1/09-beneath-prismfall.md, game/events/lyras_truth.gd
- Notes: Current lyras_truth.gd (153 lines) is a scaffold. This is the Act I climax — Lyra reveals The Severance was intentional, The Convergence was a sentient network, and 800 million people died. Major narrative beat. Expand with full dialogue, party reaction scenes, dramatic music cues. This event triggers after dungeon completion. 8+ tests.

### T-0287
- Title: Complete Chapter 10 "Captured" event — Act I ending
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: story, event, climax
- Depends: T-0286
- Blocked-by: —
- Refs: docs/story/act1/10-captured.md, game/events/captured.gd
- Notes: Current captured.gd (171 lines) is a scaffold. Act I ending: party is captured by the Reclamation Initiative. Director Vex reveals Kael is a Resonance Anchor. The Initiative offers Kael a choice. Party escapes. Sets up Act II. Full dialogue with Vex, party reactions, escape sequence. Set flags for Act II progression. 8+ tests.

### Enemy Content

### T-0288
- Title: Create Thornback Bear enemy — Verdant Tangle heavy hitter
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Tags: battle, data, enemy
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/02-enemy-design.md (Thornback Bear), game/data/enemies/
- Notes: Corrupted bear with crystal thorns. AGGRESSIVE AI, ~120 HP, attacks: Maul (heavy physical), Thorn Volley (ranged physical — needs AoE T-0273), Roar (attack buff). Weak to Fire and Sound. Drops: Beast Hide, Crystal Thorn, Feral Essence. Find sprite in Time Fantasy monster packs. Add to Verdant Forest and Overgrown Ruins encounter pools. 3+ tests.

### T-0289
- Title: Create Shard Serpent enemy — Crystalline Steppes construct
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: battle, data, enemy
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/02-enemy-design.md (Shard Serpent), game/data/enemies/
- Notes: Crystal snake construct. BASIC AI, ~80 HP. Attacks: Crystal Strike (physical + chance petrify via stun status), Burrow (skip turn, gain defense buff), Shatter (self-destruct AoE). Weak to impact/blunt. Drops: Pure Crystal, Serpent Core, Prism Scale. Add to Prismfall Approach encounter pool. 3+ tests.

### T-0290
- Title: Create crystal dungeon enemy set for Beneath Prismfall
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: battle, data, enemy
- Depends: T-0279
- Blocked-by: —
- Refs: docs/game-design/02-enemy-design.md, docs/game-design/05-dungeon-designs.md
- Notes: Beneath Prismfall needs unique enemies. Create 2-3: Crystal Sentinel (DEFENSIVE AI, high DEF, crystal slam + shield), Resonance Wisp (SUPPORT AI, heals other enemies, weak to Dark), and Prism Guardian (BOSS AI, for mini-boss encounter, reflects magic). Add to Beneath Prismfall encounter pool. 4+ tests.

### Scene Flow & Integration

### T-0291
- Title: Act I critical path flow test — verify title screen to Act I ending
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: integration, test, flow
- Depends: T-0287
- Blocked-by: —
- Refs: game/tools/, agents/
- Notes: Full integration test of Act I game flow: Title → New Game → Opening Sequence → Roothollow (tutorial quests, shop) → Verdant Forest (Iris recruitment, encounters) → Overgrown Ruins → Overgrown Capital (Lyra fragment, echoes, puzzles, Last Gardener) → Verdant Forest return → Prismfall Approach → Prismfall town → Beneath Prismfall → Lyra's Truth → Captured. Verify all scene transitions work, all events trigger correctly, save/load preserves state, no crashes. Create playtest preset JSONs for each chapter checkpoint.

### Quest & Content Expansion

### T-0292
- Title: Create Prismfall town shop — mid-tier equipment and items
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: data, shop
- Depends: T-0278
- Blocked-by: —
- Refs: game/data/shops/, game/data/equipment/, game/data/items/
- Notes: Prismfall is the major trading hub. Create prismfall_shop.tres with: upgraded weapons (steel-tier for each weapon type), mid-tier armor, consumables (hi-potion, ether, antidote, resonance_tonic), and echo-related items. Create any missing equipment .tres files. May need 4-6 new equipment pieces. 3+ tests.

### T-0293
- Title: Create Roothollow tutorial quests — help villagers
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: quest, data, story
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/04-side-quests.md, game/data/quests/, game/scenes/roothollow/
- Notes: Roothollow is the tutorial area. Add 2-3 simple side quests: herb_gathering.tres already exists but may need wiring. Add "Lost Cat" (explore to find NPC's pet — fetch quest), "Elder's Request" (deliver item to nearby area). Wire quest givers as Roothollow NPCs with dialogue. Complete/turn-in triggers via EventBus. 4+ tests.

### T-0294
- Title: Add party management UI — swap active and reserve members
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: ui
- Depends: —
- Blocked-by: —
- Refs: game/ui/party_ui/, game/autoloads/party_manager.gd, docs/best-practices/08-ui-patterns.md
- Notes: PartyManager supports 4 active + 4 reserve, but there's no UI to swap members. Add a party management screen accessible from pause menu. Show all recruited characters with stats. Drag/tap to swap between active and reserve slots. Cannot remove below 1 active member. Should integrate with existing party_ui. 5+ tests.

### Existing Low-Priority M1 Tickets (carried forward)

### T-0207
- Title: Add Government Center sub-area to Overgrown Capital — political debate echoes and hidden bunker
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md (Government Center), docs/lore/04-echo-catalog.md
- Notes: Capitol building area. Create 1-2 Story Echo .tres about political dissent re: Resonance regulation. Hidden bunker secret area with rare echo. 3+ tests.

### T-0213
- Title: Add Merchant's Regret optional mini-boss to Overgrown Capital Market District
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md, game/data/enemies/
- Notes: Create game/data/enemies/merchants_regret.tres (EnemyData: BOSS AI, ~200 HP, coin_shower AoE + desperate_bargain debuff). Trigger zone in Market stall cluster. Pre-battle 2-line dialogue. Flag: merchants_regret_encountered. compute_merchants_regret_can_trigger(flags) static helper. 3+ tests.

### T-0215
- Title: Add hidden VIP lounge in Entertainment District — legendary echo collectible
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/04-echo-catalog.md
- Notes: Secret area accessible via hidden stage entrance in theater area. Create game/data/echoes/final_performance.tres (EchoData: LEGENDARY rarity, STORY echo_type, 3-line lore about a performer's last show before The Severance). MemorialEchoStrategy. Flag: vip_lounge_found. compute_vip_lounge_eligible(flags) helper. 3+ tests.

### T-0216
- Title: Add rooftop garden secret area to Residential Quarter — rare echo collectible
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/04-echo-catalog.md
- Notes: Secret rooftop area accessible via collapsed building rubble path. Create game/data/echoes/rooftop_garden.tres (EchoData: RARE rarity, STORY echo_type, family tending a garden above the city). MemorialEchoStrategy with 2-3 line vision. Flag: rooftop_garden_found. 3+ tests.

### T-0217
- Title: Add hidden archives secret room in Government Center — Historical Records lore
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md, game/entities/interactable/
- Notes: Secret room in Government Center accessible via collapsed wall. Plain dialogue Interactable (one_time=true) with 3-line lore dump about pre-Severance political history. Flag: hidden_archives_found. compute_archives_lore_text() static helper. 2+ tests.

### T-0109
- Title: Add weather and time-of-day visual system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/06-audio-design.md
- Notes: Day/night cycle, weather effects. CanvasModulate for lighting, GPUParticles2D for weather.

### T-0110
- Title: Implement crafting system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/01-core-mechanics.md
- Notes: Combine materials into items. Recipe system, crafting UI, material gathering.

---

## M2 — Act II: The Weight of Echoes

### New Scenes — Cindral Wastes

### T-0300
- Title: Build Emberhearth city scene — Cindral Wastes major hub
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: scene, tilemap
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/03-world-map-and-locations.md (Emberhearth)
- Notes: City inside dormant volcanic caldera. Districts: The Rim (refugees, markets), Forge Quarter (blacksmiths), The Deep (old city), Ash Walker Territory (nomads). Services: inn "The Cooling Stone", weapons/armor/general shops, Echo trader, master blacksmith, Resonance Beacon. Use volcanic/desert tileset assets. Multiple NPCs, shop, inn rest. Add to ScenePaths. 8+ tests.

### T-0301
- Title: Build The Scorched Road route scene — Cindral Wastes overworld
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: scene, tilemap
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/03-world-map-and-locations.md (The Scorched Road)
- Notes: Ancient highway between Emberhearth and southern steppes. Heat shimmer, abandoned rest stops, caravan encounters. Environmental hazard: heat exhaustion (optional HP drain). Secrets: hidden oasis, crashed airship wreckage. Use desert/ash tileset. Encounter pool with Cindral Wastes enemies. 5+ tests.

### New Scenes — Ironcoast Federation

### T-0302
- Title: Build Gearhaven city scene — Ironcoast major hub (largest city)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: scene, tilemap
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/03-world-map-and-locations.md (Gearhaven)
- Notes: Sprawling coastal metropolis. Districts: The Spire (Initiative HQ), Factory District, Harbor, High Rise, The Undercity. Multiple inns, largest shop selection, black market dealer, Underground Echo Arena. Multiple Resonance Beacons. Use steampunk/industrial tileset. Most side content in the game lives here. 10+ tests.

### T-0303
- Title: Build Initiative Headquarters dungeon scene
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: scene, tilemap, dungeon
- Depends: T-0302
- Blocked-by: —
- Refs: docs/game-design/05-dungeon-designs.md (Initiative HQ), docs/game-design/03-world-map-and-locations.md
- Notes: High-tech fortress: public ground floor, stealth-section mid floors, executive offices, secret basement labs. Stealth sections (T-0321), hacking puzzles (T-0322). Moral choice: save test subjects or pursue main objective. Boss: Director Vex Thornwright (conditional). Use steampunk/tech tileset. 8+ tests.

### T-0304
- Title: Build Shipbreaker's Coast route scene — Ironcoast coastal area
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: scene, tilemap
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/03-world-map-and-locations.md (Shipbreaker's Coast)
- Notes: Rocky coastline with shipwrecks. Salvager and pirate encounters. Coastal caves with secrets. Legendary ship with pre-Severance cargo. Hidden pirate town (neutral trading post). Use coastal/ship tileset. 5+ tests.

### New Scenes — The Hollows

### T-0305
- Title: Build The Hollows entrance scene — reality-break zone
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: scene, tilemap
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/03-world-map-and-locations.md (The Hollows), docs/lore/02-main-story.md
- Notes: Central zone where reality breaks down. Past and present overlap, time flows strangely, reality responds to emotion. Visual effects: distortion, color shifts, impossible geometry. Use unique abstract tileset. This is where the truth about Kael and The Convergence is revealed. 6+ tests.

### T-0306
- Title: Build Deep Hollows dungeon scene — Act II climax location
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: scene, tilemap, dungeon
- Depends: T-0305
- Blocked-by: —
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/02-main-story.md
- Notes: Nightmare realm dungeon. Party members appear as child/elderly selves simultaneously. Echoes of possible futures manifest. Deepest area where Kael discovers their origin. Contains final Anchor (Lyra). Reality-bending puzzles (T-0323). Aberration enemies. 8+ tests.

### Story Events — Act II (Chapters 11-20)

### T-0307
- Title: Implement Chapter 11 "Rogue" event — party goes rogue after escape
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event
- Depends: T-0287
- Blocked-by: —
- Refs: docs/story/act2/11-rogue.md
- Notes: After escaping the Initiative (Ch10), party decides to go rogue. Seek other two Resonance Anchors before either faction claims them. New direction for the story. Full dialogue from story script. Set Act II progression flags.

### T-0308
- Title: Implement Chapter 12 "The Iron Coast" event — arrival at Gearhaven
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event
- Depends: T-0302
- Blocked-by: —
- Refs: docs/story/act2/12-the-iron-coast.md
- Notes: Party arrives at Gearhaven — major culture shock after rural/natural areas. Introduction to the Ironcoast Federation's industrial society. Meet key NPCs, learn about Initiative headquarters. Full dialogue from story script.

### T-0309
- Title: Implement Chapter 13 "Sister's Shadow" event — Sienna's defection
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event, recruitment
- Depends: T-0308
- Blocked-by: —
- Refs: docs/story/act2/13-sisters-shadow.md, docs/lore/03-characters.md (Sienna)
- Notes: Dr. Sienna Vex defects from the Initiative after witnessing her brother's willingness to sacrifice settlements. She provides insight into Convergence technology. Sienna recruitment event + sienna.tres CharacterData already exists. Wire recruitment to PartyManager.add_character(). Full dialogue from story script.

### T-0310
- Title: Implement Chapter 14 "Fire and Ash" event — finding Ash in Emberhearth
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event, recruitment
- Depends: T-0300
- Blocked-by: —
- Refs: docs/story/act2/14-fire-and-ash.md, docs/lore/03-characters.md (Ash)
- Notes: Party finds Ash in Emberhearth — a child who communicates through shared emotional resonance. Protected by Ash Walker nomads. Party initially believes Ash is the third Anchor (later revealed as amplifier, not Anchor). ash.tres CharacterData already exists. Wire recruitment.

### T-0311
- Title: Implement Chapter 15 "Siege of Emberhearth" event — major battle sequence
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event, battle
- Depends: T-0310
- Blocked-by: —
- Refs: docs/story/act2/15-siege-of-emberhearth.md
- Notes: Shepherds of Silence attack Emberhearth to kill Ash. Major battle sequence — party must defend the city. Moral complexity: Shepherds aren't entirely wrong about the Convergence dissolving individuality. Multiple battle encounters, dialogue between fights, reputation consequences.

### T-0312
- Title: Implement Chapter 16 "The Weight of Choice" event
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event
- Depends: T-0311
- Blocked-by: —
- Refs: docs/story/act2/16-the-weight-of-choice.md
- Notes: Aftermath of Emberhearth siege. Party must decide next steps. Moral choices with consequences for later endings.

### T-0313
- Title: Implement Chapter 17 "Into the Hollows" event — entering reality break zone
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event
- Depends: T-0305
- Blocked-by: —
- Refs: docs/story/act2/17-into-the-hollows.md
- Notes: Party ventures into The Hollows to find the final Anchor and discover truth about the Convergence. Surreal environment, party members affected by reality distortion. Full dialogue and atmospheric event scripting.

### T-0314
- Title: Implement Chapter 18 "What Kael Is" event — Kael's true origin
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event, climax
- Depends: T-0313
- Blocked-by: —
- Refs: docs/story/act2/18-what-kael-is.md
- Notes: Deep in The Hollows, Kael discovers they're a fragment of the Convergence that took human form. Not human — a bridge between connection and individuality. Party crisis: can they trust Kael? Major character development. Full dramatic dialogue.

### T-0315
- Title: Implement Chapter 19 "The Third Anchor" event — Lyra revealed as Anchor
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event
- Depends: T-0314
- Blocked-by: —
- Refs: docs/story/act2/19-the-third-anchor.md
- Notes: The final Anchor is Lyra — she was an Anchor all along and deliberately fragmented herself. Now reassembled, she reveals the complete picture about the Convergence.

### T-0316
- Title: Implement Chapter 20 "Endgame Revealed" event — Act II climax
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, event, climax
- Depends: T-0315
- Blocked-by: —
- Refs: docs/story/act2/20-endgame-revealed.md
- Notes: Director Vex reveals Resonance Cage plan. Prophet Null reveals Resonance Void plan. Both plans devastate Aethermoor. Party must find a third option: enter the Resonance Nexus. Sets up Act III. Full dialogue with both antagonists.

### Character Recruitments

### T-0317
- Title: Implement Cipher recruitment — hacker Resonance Anchor
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M2
- Tags: story, recruitment
- Depends: T-0308
- Blocked-by: —
- Refs: docs/lore/03-characters.md (Cipher), game/data/characters/cipher.tres
- Notes: cipher.tres CharacterData already exists. Cipher is a non-binary hacker from Gearhaven, one of the three Resonance Anchors. Has been evading Initiative for years. Write recruitment event with full dialogue. Wire to PartyManager.add_character(). Cipher uses Resonance to interface with technology. 6+ tests.

### New Battle Systems for M2

### T-0318
- Title: Implement Resonance Tuning — equipment customization with Echo Fragments
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: battle, equipment, echo
- Depends: T-0274
- Blocked-by: —
- Refs: docs/game-design/01-core-mechanics.md (Resonance Tuning)
- Notes: Equipment can be Resonance Tuned at crafters. Tuning adds properties using Echo Fragments. Items have 1-3 slots based on rarity. Replacing an Echo destroys the previous one + costs gold. Create TuningUI, add tuning_slots to EquipmentData, tuned_echoes tracking in EquipmentManager. 6+ tests.

### T-0319
- Title: Implement Limit Break abilities — Overload-state ultimate attacks
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: battle, resonance
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/01-core-mechanics.md (Overload state), docs/mechanics/character-abilities.md
- Notes: When in Overload (100%+ Resonance), characters can use Limit Break style ultimate abilities. Each character has a unique Limit Break. Consumes all Resonance gauge. Powerful but risky since Overload doubles incoming damage. Add limit_break ability field to CharacterData, special UI indicator, dramatic animation. 6+ tests.

### New Enemy Sets

### T-0320
- Title: Create Cindral Wastes enemy set — volcanic/desert creatures
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: battle, data, enemy
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/02-enemy-design.md (Cindral Wastes section)
- Notes: Magma Crawler (slow tank, crush + harden + heat wave), additional Ash Stalkers (pack tactics), volcanic constructs. Create 3-4 enemy .tres files. Wire to Emberhearth and Scorched Road encounter pools. 4+ tests.

### T-0321
- Title: Create Ironcoast/Initiative enemy set — soldiers and tech enemies
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: battle, data, enemy
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/02-enemy-design.md (Ironcoast section)
- Notes: Initiative Soldier (BASIC AI, balanced), Initiative Agent (AGGRESSIVE, stealth attacks), Security Drone (DEFENSIVE, high DEF), Initiative Scientist (SUPPORT, buffs allies). Create 3-4 enemy .tres. Wire to Gearhaven/Initiative HQ encounter pools. 4+ tests.

### T-0322
- Title: Create The Hollows enemy set — aberrations and reality-breaks
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: battle, data, enemy
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/02-enemy-design.md (Hollows section)
- Notes: Reality aberrations unique to The Hollows. Distorted echoes, temporal anomalies, shadow creatures. Create 3-4 enemy .tres. These should be the most unsettling and mechanically unusual enemies — status effects, turn manipulation, mirror attacks. 4+ tests.

### New Gameplay Systems for M2

### T-0321b
- Title: Implement stealth mechanics for Initiative HQ infiltration
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: system, gameplay
- Depends: T-0303
- Blocked-by: —
- Refs: docs/game-design/05-dungeon-designs.md (Initiative HQ)
- Notes: Initiative HQ has stealth sections. Guard patrol patterns, line-of-sight detection, hiding spots. Can fight through (harder) or sneak (Cipher shines). Basic stealth: guards with Area2D detection zones, patrol paths via Path2D, alert state triggers forced battle. 6+ tests.

### T-0322b
- Title: Implement hacking puzzle mechanics — Cipher's special ability
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: system, gameplay, puzzle
- Depends: T-0317
- Blocked-by: —
- Refs: docs/game-design/05-dungeon-designs.md, docs/game-design/01-core-mechanics.md
- Notes: Cipher can hack technology using Resonance. Create a simple puzzle mechanic for locked doors and security systems in Initiative HQ. Could be pattern-matching, sequence-solving, or a custom mini-game. Reusable for other tech-gated areas. 5+ tests.

### Character Quests

### T-0323
- Title: Implement Kael's "Fragments of Self" character quest chain
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: quest, story, character
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/04-side-quests.md (Kael: Fragments of Self), docs/story/character-quests/kael-fragments-of-self.md
- Notes: 5-stage quest spanning Acts I-III. Stage 1: Find Echo of "Kael's childhood" in Roothollow. Stage 2: Find contradicting Echo in Overgrown Capital. Stage 3: Find impossible Echo in The Hollows. Stage 4: Experience actual "birth" from Convergence. Stage 5: Resolution choice (accept/reject/embrace). Quest .tres + 5 event scripts + 3-4 echo .tres. 8+ tests.

### T-0324
- Title: Implement Iris's "Chains of Chrome" character quest chain
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: quest, story, character
- Depends: T-0302
- Blocked-by: —
- Refs: docs/game-design/04-side-quests.md (Iris: Chains of Chrome), docs/story/character-quests/iris-engineers-oath.md
- Notes: Iris's younger brother Dane is in Initiative military. 5-stage quest: receive letter, infiltrate outpost, find Dane (willingly there), ideological confrontation, resolution (multiple outcomes). Quest .tres + event scripts. 6+ tests.

### T-0325
- Title: Implement Garrick's "Three Burns" character quest chain
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: quest, story, character
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/04-side-quests.md, docs/story/character-quests/garrick-three-burns.md, game/data/quests/garrick_three_burns.tres
- Notes: garrick_three_burns.tres already exists as a quest definition. Implement the full quest chain: three moments that defined Garrick's life. Camp scenes, flashback events, moral reflections. Expand existing quest data with objective wiring and event triggers. 6+ tests.

### T-0326
- Title: Implement Nyx's "What Am I?" character quest chain
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M2
- Tags: quest, story, character
- Depends: T-0305
- Blocked-by: —
- Refs: docs/game-design/04-side-quests.md, docs/story/character-quests/nyx-what-am-i.md
- Notes: Nyx's existential quest — an Echo born from The Hollows with no human memories. Exploring what identity means when you have none. Requires The Hollows access. Quest .tres + event scripts. 6+ tests.

---

## M3 — Act III: Convergence

### Scenes

### T-0330
- Title: Build Resonance Nexus dungeon — final dungeon at heart of The Hollows
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: scene, tilemap, dungeon
- Depends: T-0306
- Blocked-by: —
- Refs: docs/lore/02-main-story.md (Act III), docs/game-design/05-dungeon-designs.md
- Notes: The Resonance Nexus at the heart of The Hollows. Surreal journey through humanity's collective unconscious — living memories, abstract emotions, conceptual landscapes. Party witnesses: first conscious thought, last memory before Severance, every version of themselves. Final dungeon before the ending choice. 10+ tests.

### T-0331
- Title: Build Inside the Convergence scene — surreal final zone
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: scene, tilemap
- Depends: T-0330
- Blocked-by: —
- Refs: docs/lore/02-main-story.md (Inside the Convergence)
- Notes: Abstract landscape inside the Convergence consciousness. Not a traditional dungeon — more of a narrative/visual experience. Party confronts crystallization fears. Player makes choices about how deeply each character crystallizes (affects abilities and story outcomes).

### Story Events — Act III (Chapters 21-28)

### T-0332
- Title: Implement Chapter 21 "Into the Nexus" event
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: story, event
- Depends: T-0316
- Blocked-by: —
- Refs: docs/story/act3/21-into-the-nexus.md

### T-0333
- Title: Implement Chapter 22 "The Prophet's Fall" event
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: story, event
- Depends: T-0332
- Blocked-by: —
- Refs: docs/story/act3/22-the-prophets-fall.md

### T-0334
- Title: Implement Chapter 23 "Iron and Blood" event
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: story, event
- Depends: T-0333
- Blocked-by: —
- Refs: docs/story/act3/23-iron-and-blood.md

### T-0335
- Title: Implement Chapter 24 "My Sister's Work" event
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: story, event
- Depends: T-0334
- Blocked-by: —
- Refs: docs/story/act3/24-my-sisters-work.md

### T-0336
- Title: Implement Chapter 25 "The Bridge" event
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: story, event
- Depends: T-0335
- Blocked-by: —
- Refs: docs/story/act3/25-the-bridge.md

### T-0337
- Title: Implement Chapter 26 "The Choice" event — four-ending branch point
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: story, event, climax
- Depends: T-0336
- Blocked-by: —
- Refs: docs/story/act3/26-the-choice.md, docs/lore/02-main-story.md (The Choice)
- Notes: The player chooses how to shape the future: Ending A (Silence — Convergence dies), Ending B (Subjugation — Convergence imprisoned), Ending C (Unity — forced integration), Ending D (Harmony — Kael becomes bridge, true ending requires specific prior choices). This is the most critical story event in the game.

### T-0338
- Title: Implement Chapter 27 "What Remains" event — aftermath
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: story, event
- Depends: T-0337
- Blocked-by: —
- Refs: docs/story/act3/27-what-remains.md

### T-0339
- Title: Implement Chapter 28 "Echoes of Tomorrow" event — epilogue
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: story, event
- Depends: T-0338
- Blocked-by: —
- Refs: docs/story/act3/28-echoes-of-tomorrow.md
- Notes: Epilogue showing each party member's fate based on player choices. Post-credits scene with young Echo Hunter finding Kael's crystal.

### Ending & Epilogue Systems

### T-0340
- Title: Implement four-ending system with choice tracking
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: system, story
- Depends: T-0337
- Blocked-by: —
- Refs: docs/lore/02-main-story.md (The Choice, Epilogue)
- Notes: Track player choices throughout Acts I-III that influence ending availability. Ending D (Harmony/True Ending) requires specific choices. Create ending_flags tracking in EventFlags. Ending-specific scenes/dialogue. Save which ending was achieved for New Game+ or gallery.

### T-0341
- Title: Implement epilogue sequences — per-character fates based on choices
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M3
- Tags: story, event
- Depends: T-0340
- Blocked-by: —
- Refs: docs/lore/02-main-story.md (Epilogue)
- Notes: Each party member has 2-3 possible fates. Iris: rebuild Initiative / destroy it / wander. Garrick: new spiritual movement / retire / keep fighting. Nyx: discover true nature / fade / become unprecedented. Etc. Show consequences of player choices — settlements saved/abandoned, characters helped/betrayed.

### T-0342
- Title: Implement post-credits scene — Kael's crystal and "What will you create?"
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M3
- Tags: story, event
- Depends: T-0341
- Blocked-by: —
- Refs: docs/lore/02-main-story.md (Post-Credits)
- Notes: Young Echo Hunter finds crystal fragment in ruins. It speaks with Kael's voice: "Every ending is a memory waiting to begin again. What will you create?" The cycle continues with hope.

### Remaining Character Quests

### T-0343
- Title: Implement Sienna's "Book of Names" character quest
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M3
- Tags: quest, story, character
- Depends: T-0309
- Blocked-by: —
- Refs: docs/story/character-quests/sienna-book-of-names.md

### T-0344
- Title: Implement Cipher's "Ghost in the Machine" character quest
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M3
- Tags: quest, story, character
- Depends: T-0317
- Blocked-by: —
- Refs: docs/story/character-quests/cipher-ghost-in-machine.md

### T-0345
- Title: Implement Lyra's "Before the Breaking" character quest
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M3
- Tags: quest, story, character
- Depends: T-0315
- Blocked-by: —
- Refs: docs/story/character-quests/lyra-before-the-breaking.md

### T-0346
- Title: Implement Ash's "The Drawing" character quest
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M3
- Tags: quest, story, character
- Depends: T-0310
- Blocked-by: —
- Refs: docs/story/character-quests/ash-the-drawing.md

---

## M4 — Optional Content & Polish

### Optional Dungeons

### T-0350
- Title: Build The First Reactor optional dungeon — Cindral Wastes (Level 25+)
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M4
- Tags: scene, dungeon
- Depends: T-0300
- Blocked-by: —
- Refs: docs/game-design/05-dungeon-designs.md (The First Reactor)
- Notes: First Resonance reactor that melted down during The Severance. 5 floors descending, lava hazards, unstable platforms, combat + environmental puzzles. Boss: Reactor Heart (crystalline aberration). Rewards: legendary fire weapons, unique Echoes, Severance lore. 8+ tests.

### T-0351
- Title: Build The Tangle Depths optional dungeon — Verdant Tangle (Level 35+)
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M4
- Tags: scene, dungeon
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/05-dungeon-designs.md (The Tangle Depths)
- Notes: Deepest forest where reality blurs with The Hollows. Trees in impossible geometries, time flows strangely. Reality-bending puzzles, time loop mechanics, highest rare Echo concentration. Boss: Temporal Bloom (exists across all times). Rewards: time-manipulation equipment, Paradox Echoes, Hollows shortcut. 8+ tests.

### Side Quest Sets

### T-0352
- Title: Implement Roothollow side quest set — tutorial and village quests
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M4
- Tags: quest, story
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/04-side-quests.md, docs/game-design/03-world-map-and-locations.md (Roothollow side quests)
- Notes: Help villagers, investigate Kael's past, protect village from Echo manifestations. 4-6 quests with NPC dialogue and completion triggers.

### T-0353
- Title: Implement Emberhearth side quest set — refugee and forge quests
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M4
- Tags: quest, story
- Depends: T-0300
- Blocked-by: —
- Refs: docs/game-design/04-side-quests.md, docs/game-design/03-world-map-and-locations.md (Emberhearth side quests)
- Notes: Help refugees find housing, excavate The Deep for artifacts, Ash Walker trials, investigate Initiative spies. 4-6 quests.

### T-0354
- Title: Implement Gearhaven side quest set — city intrigue and underground
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M4
- Tags: quest, story
- Depends: T-0302
- Blocked-by: —
- Refs: docs/game-design/04-side-quests.md, docs/game-design/03-world-map-and-locations.md (Gearhaven side quests)
- Notes: Corporate intrigue, underground fighting tournaments, helping undercity residents, Cipher's personal questline branches. Most side content in the game. 6-10 quests.

### T-0355
- Title: Implement Prismfall side quest set — trading hub and faction quests
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M4
- Tags: quest, story
- Depends: T-0278
- Blocked-by: —
- Refs: docs/game-design/04-side-quests.md, docs/game-design/03-world-map-and-locations.md (Prismfall)
- Notes: Refugee crisis mediation, faction questlines, archive research quests. 4-6 quests.

### Camp & Bonding Scenes

### T-0356
- Title: Implement camp bonding conversations — full character interaction system
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M4
- Tags: story, camp, bond
- Depends: —
- Blocked-by: —
- Refs: docs/story/camp-scenes/bonding-conversations.md, game/autoloads/bond_manager.gd
- Notes: BondManager tracks bond levels (D-C-B-A-S) but there's no content for bond-level conversations. Design doc calls for conversations at each bond tier between character pairs. Create dialogue scripts for key pairs (Kael-Iris, Kael-Garrick, Iris-Cipher, Garrick-Nyx, etc.). Trigger at camp when bond level increases. 6+ tests.

### T-0357
- Title: Implement party banter system — in-field dialogue triggers
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M4
- Tags: story, dialogue
- Depends: —
- Blocked-by: —
- Refs: docs/story/camp-scenes/party-banter.md, game/systems/banter_manager.gd
- Notes: BanterManager exists but needs content. Short character dialogue that triggers while exploring — comments on the area, reactions to recent events, character-specific observations. Create banter dialogue sets for each area. 4+ tests.

### T-0358
- Title: Implement NPC dialogue system — area-specific townspeople conversations
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M4
- Tags: story, dialogue
- Depends: —
- Blocked-by: —
- Refs: docs/story/camp-scenes/npc-dialogue.md
- Notes: Generic NPCs in towns should have contextual dialogue that changes based on story progression. Create dialogue sets per area per story chapter. Roothollow villagers, Prismfall traders, Emberhearth refugees, Gearhaven citizens. 3+ tests.

### UI Polish

### T-0360
- Title: Implement bestiary / monster log UI
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M4
- Tags: ui
- Depends: —
- Blocked-by: —
- Refs: game/ui/
- Notes: Track defeated enemy types, show stats/weaknesses/lore. Accessible from pause menu. Auto-populate when enemies are defeated (EventBus.enemy_defeated signal). Show sprite, stats, drops, lore text from EnemyData.

### T-0361
- Title: Implement world map UI — region overview and fast travel integration
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M4
- Tags: ui
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/03-world-map-and-locations.md
- Notes: Visual world map showing the 5 regions and their connections. Shows current location, discovered areas, available fast travel beacons. Accessible from pause menu. Could be a hand-drawn style map that fills in as areas are discovered.

### T-0362
- Title: Implement Echo equip UI — pre-battle echo slot management
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M4
- Tags: ui, echo
- Depends: T-0274
- Blocked-by: —
- Refs: game/ui/echo_journal/, game/autoloads/echo_manager.gd
- Notes: Echo journal exists for viewing collected echoes. Add an equip mode: 6 echo slots, drag/select echoes from collection into slots. Show echo stats and uses_per_battle. Accessible from pause menu or pre-battle screen. Integrate with EchoManager.equipped_echoes.

### Systems

### T-0363
- Title: Implement vehicle system — Aetherium Skiff for mid-game travel
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M4
- Tags: system, gameplay
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/01-core-mechanics.md (Vehicles)
- Notes: Hover vehicle for crossing water and rough terrain. Faster movement, can flee random encounters more easily. Needed to access certain islands and areas. Unlocked mid-game (Act II). Player entity variant with different movement speed and animations.

### T-0364
- Title: Implement Resonance Tuning equipment customization with Echo Fragments
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M4
- Tags: system, equipment, echo
- Depends: T-0274
- Blocked-by: —
- Refs: docs/game-design/01-core-mechanics.md (Resonance Tuning)
- Notes: Equipment can be customized at crafters by inserting Echo Fragments into tuning slots. Items have 1-3 slots based on rarity. Semi-permanent — replacing costs gold. Creates deep customization. Requires TuningUI, EquipmentData tuning slots, EchoData tuning properties.

---

## M5 — Release Readiness

### T-0370
- Title: Game balance pass — enemy stats, ability costs, XP curves, economy
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M5
- Tags: balance
- Depends: —
- Blocked-by: —
- Refs: game/systems/game_balance.gd, game/data/
- Notes: Comprehensive balance review of all enemy HP/damage, ability EE costs and damage values, XP curve (LevelManager), gold economy (shop prices vs drops), equipment stat progression. Playtest each chapter at expected level range. Adjust game_balance.gd constants. Document balance rationale.

### T-0371
- Title: Accessibility options — battle speed, puzzle hints, font size, input remapping
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M5
- Tags: ui, accessibility
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/01-core-mechanics.md (Accessibility)
- Notes: Battle speed toggle (normal/fast/instant). Puzzle hint system (optional hints in options). Font size scaling. Input remapping for keyboard/controller. Colorblind-friendly UI. Screen reader support for dialogue. Pause during ATB selection (already mentioned in design doc).

### T-0372
- Title: Tutorial system — progressive hints for new players
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M5
- Tags: ui, tutorial
- Depends: —
- Blocked-by: —
- Refs: game/ui/hud/ (tutorial_hints exists)
- Notes: Tutorial hints UI exists but needs content and trigger system. Contextual tutorials: first battle (explain commands), first resonance state change, first echo collection, first skill tree, first shop visit. Track which tutorials have been shown. Can be disabled in settings.

### T-0373
- Title: Performance optimization pass — scene loading, particles, memory
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M5
- Tags: performance
- Depends: —
- Blocked-by: —
- Refs: docs/best-practices/06-performance.md
- Notes: Profile scene loading times, particle systems, memory usage. Optimize heavy scenes. Implement lazy loading for distant regions. Pool VFX objects. Check for resource leaks. Target stable 60fps on mobile renderer.

### T-0374
- Title: Full game playtest — title screen to credits, all four endings
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M5
- Tags: test, integration
- Depends: T-0339
- Blocked-by: —
- Refs: game/tools/
- Notes: Complete playthrough of all main story content. Test all four endings. Verify save/load at every chapter. Check for softlocks, missing transitions, broken flags. Document and file bugs. Create comprehensive playtest report.

### T-0375
- Title: Audio integration pass — BGM for all scenes, SFX for all interactions
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M5
- Tags: audio
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/06-audio-design.md, game/autoloads/audio_manager.gd
- Notes: 49 music tracks exist but many scenes may not have BGM wired. Verify every scene has appropriate BGM. Wire character themes to character-specific events. Add SFX for all interactions (door open, chest open, item pickup, etc.). Verify AudioManager crossfade works across all transitions.

### T-0376
- Title: Visual polish pass — consistent art style, animation, and UI across all scenes
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M5
- Tags: visual, polish
- Depends: —
- Blocked-by: —
- Refs: game/assets/CLAUDE.md
- Notes: Verify all scenes use consistent Time Fantasy art style. Check for placeholder assets that need replacement. Verify all character portraits exist and are consistent. Check UI alignment and theming across all screens. Battle animations for all abilities.

### T-0377
- Title: Implement New Game+ system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M5
- Tags: system
- Depends: T-0340
- Blocked-by: —
- Refs: docs/game-design/01-core-mechanics.md
- Notes: After completing the game, allow restart with carried-over levels/equipment/echoes. Track which endings have been achieved. Unlock additional content or difficulty in NG+.

---

## Unscheduled

*(Tickets with no milestone assigned yet. Move to a milestone section when scheduled.)*
