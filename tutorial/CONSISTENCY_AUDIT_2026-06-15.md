# Crystal Saga Tutorial — Accuracy & Consistency Audit (2026-06-15)

> Not published by the website (`build.js` only picks up `^\d{2}_*.md`). Maintainer-facing.

## Method

Every one of the 27 modules was audited by a dedicated reviewer that grounded each
Godot 4 API / GDScript / editor-workflow claim against the **official Godot docs via the
Godot RAG MCP** (standard mode, docs-first), then a second adversarial reviewer per module
confirmed/refuted each finding (also RAG-grounded). Eight cross-module sweeps then checked
the series-level contracts (autoload order, canonical IDs, data-model fields, public API
signatures, forward/back references, input/project setup, the end-to-end build path, and the
`REGRESSION.md` checklist) over an aggregated symbol ledger. A synthesis pass deduplicated and
prioritized. Target engine: **Godot 4.6** (per Module 01).

The single blocker and the most semantically subtle majors were then independently
re-verified by hand against the source and the docs:

- **Blocker (M12)** — confirmed. `Array.filter()` is documented as `Array filter(method: Callable) const`
  (returns a *new untyped* Array), and the typed-array rules state you "cannot assign an array with a
  different element type" without `Array.assign()` (the docs' own example marks `b = a` as an Error).
  So `return _items.filter(...).duplicate(true)` from a `-> Array[Dictionary]` function does not coerce —
  it fails. `get_all_items()` is safe only because `duplicate(true)` preserves the *source's* typing.
- **M21 DialogueBox cast** — confirmed. `DialogueBox extends CanvasLayer` (11:185), which `Inherits: Node`,
  so the `: Control` annotation at 21:156 is an invalid downcast.
- **M21 Lira / handler fragments / M17 boss trigger / pendant scene_key** — confirmed by source + grep.
- Core load-bearing APIs spot-checked clean: `change_scene_to_file` + `await get_tree().scene_changed`,
  `AudioServer.set_bus_volume_db`/`get_bus_index`, `ResourceLoader.CACHE_MODE_IGNORE`, `move_and_slide()`.

Result: **48 findings — 1 blocker, 9 major, 32 minor, 6 nit.** `tutorial/tools/check_tutorial.py` passes.

---

# Crystal Saga Tutorial — Consolidated Accuracy & Consistency Audit

## Executive Summary

Crystal Saga is a high-quality 27-module Godot 4 JRPG tutorial. Across all per-module and cross-module audits, the Godot API usage is overwhelmingly accurate against the official docs, the cross-module data contracts hold, the review modules mirror current code, and the writing discipline (no banned AI words, no `--` punctuation) is clean. The lint checker passes.

A diligent reader **can** follow Modules 01→27 and reach a complete, runnable JRPG demo — but only after fixing **one true code blocker** and a small set of follow-along-breaking gaps.

## End-to-End Verdict

**Can a diligent reader reach a complete, runnable demo? YES — once the blocker is fixed.**

The gameplay loop is fully closed (title → New Game → explore → encounter → battle → victory/defeat → Game Over choice screen / ending → credits), every required artifact referenced as existing is created earlier, all 8 autoloads have registration steps, and the scene-reconstruction battle pattern matches the docs-sanctioned approach.

**Completion blocker (must fix first):**
- **`M12-get-consumables-typed-return`** — `get_consumables()` returns an untyped `filter().duplicate()` Array from a function annotated `-> Array[Dictionary]`. GDScript's typed-return check throws a runtime error the first time the battle item menu opens (Module 15, `consumables[0].item`). This is on the normal build path and halts progress.

Four MAJOR follow-along breakers do not strictly stop a determined reader but prevent headline features from working as written: missing Lira NPCData, the un-reconciled `_on_npc_interacted()` fragments, the missing boss-trigger setup, and the `scene_key` forward dependency.

---

## Findings by Severity

### Blocker

| id | Modules | Issue | Fix |
|----|---------|-------|-----|
| `M12-get-consumables-typed-return` | 12, 15 | `get_consumables()` returns untyped Array from `Array[Dictionary]` function → runtime crash on opening the battle item menu | Build a typed result array (loop + `result: Array[Dictionary]`), or use `out.assign(_items.filter(...))` |

### Major

| id | Modules | Issue | Fix |
|----|---------|-------|-----|
| `M21-lira-npcdata-missing` | 21, 23 | Recruitment gates on `npc_data.id == "lira"` but only the CharacterData `lira.tres` is created; no NPCData or instanced NPC | Add steps to create `data/npcs/lira.tres`, instance the NPC, assign data, connect signal |
| `M21-npc-handler-fragments` | 21 | Three disjoint `_on_npc_interacted()` fragments never reconcile; inn never dispatched; Lira dialogue case unregistered | Show one consolidated handler routing shopkeeper/innkeeper/lira/else; add `"lira"` to the M20 dispatcher |
| `M17-boss-trigger-setup` | 17, 16 | Boss-trigger Area2D / CollisionShape2D / placement / `boss_data` assignment never created; `from_enemy(null)` crashes | Add explicit BossTrigger Area2D step + assign `crystal_guardian.tres`; null-guard `_start_boss_battle()` |
| `X-pendant-scene-key-forward-dep` | 20, 16, 22 | M20 sets `PendantChest.scene_key` before the export exists (M22); default mis-keys the pendant save flag | Drop the M20 clause; re-instruct setting `scene_key="whisperwood"` in M22 |
| `M21-dialoguebox-control-type` | 21, 11 | `DialogueBox` (a CanvasLayer) typed as `Control` → invalid-cast error | Change M21:156 to `: CanvasLayer` (or untyped) |
| `M11-choice-guard-incremental` | 11 | Choice-bypass guard missing from incremental `_unhandled_input`; a custom `interact` press skips past choices | State the complete listing replaces `_unhandled_input`; show the guarded version |
| `M01-advanced-settings-toggle` | 01 | Window Width/Height Override are hidden until Advanced Settings is enabled; reader can't reproduce 1280×720 | Add a step to enable the Advanced Settings toggle |
| `M19-doc-links-globalscope` | 19 | `max()`/`clampf()` linked to `@GDScript` page with nonexistent anchors | Point to `class_@globalscope.html` anchors; fix link text |
| `M04-broken-doc-links` | 04, 01 | Two Getting Started doc links return 404 (one also in M01) | Use `first_look_at_the_editor.html` and `tutorials/editor/project_manager.html` |

### Minor

| id | Modules | Issue | Fix |
|----|---------|-------|-----|
| `M24-25-missing-music-tracks` | 24, 25, 27 | `title_theme.ogg` / `ending_theme.ogg` played but never created | Add to M24 asset list (graceful but silent today) |
| `X-review-skipping-teasers` | 03, 07, 12, 22 | "Next Module" teasers skip the part-review module | Name the review first (mirror M18) |
| `M16-26-whisperwood-encounters` | 16, 26 | M16 table promises forest encounters never wired; M26 contradicts it | Change cell to "None in this slice (exploration)" |
| `M26-pendant-playtest-framing` | 20, 26 | M26 checklist frames the already-built pendant pickup as a TODO | Reword to assume it exists |
| `M26-economy-balance-numbers` | 26, 21 | Worked example uses 50/40 gold vs canonical 100/80; runs math wrong | Use 100/80, total ~180, 180/64 ≈ 2.8 runs |
| `X-player-group-premature-contract` | 03, 06, 07 | M03/M06 contracts claim player "joins the player group" before M07 adds it | Qualify as "registered in Module 7" |
| `M14-unreachable-damage-number` | 14 | "Slime attacks Aiden for 5 damage!" — formula can only ever yield 1 | Change to 1, or raise the test Slime's attack |
| `M17-encounterdata-weight-range` | 17 | `@export_range(0.0,1.0)` on weight contradicts the "any magnitude" lesson | Add `or_greater` (or a plain `@export`) |
| `M24-autoload-card-final-label` | 24, 25 | Two consecutive cards both titled "(Final)"; M24 omits PauseMenu | Rename M24 card to "(Updated)" |
| `X-inventory-use-item-on-member-unwired` | 12, 21 | `use_item_on_member()` defined but never wired into `_use_consumable()` | Show the concrete edit in M21 |
| `M01-texture-filter-path` | 01, 05 | Texture-filter path omits the "Canvas Textures" subsection | Use the full canonical path; drop unverified "advanced-only" |
| `X-pendant-item-id` | 20, 09 | `pendant.tres` has no `id`; missing from the canonical-ID registry | Set `id="pendant"`; add registry row |
| `M20-autoload-order-note` | 20 | No warning that GameManager must register above QuestManager | Add an order-matters sentence |
| `M02-scene-unique-nodes-scope` | 02 | `%UniqueName` "regardless of where in the tree" overstates scope | Scope it to "within the same scene" |
| `M01-mobile-renderer-web` | 01 | Mobile renderer forecloses web export; rationale partly invented | Pick Compatibility or add the web caveat |
| `M01-first-run-state-mismatch` | 01 | First F5 run promises 1280×720/crisp before the Pixel Art section applies it | Reorder, or note the first run uses defaults |
| `M10-unsafe-property-access` | 10, 11, 13, 20, 21, 23 | NPC handlers access `.npc_data` through a `CharacterBody2D` type → UNSAFE_PROPERTY_ACCESS | Series-wide `class_name NPC`, or leave intentionally dynamic |
| `M15-item-consume-on-full-hp` | 15 | "Using an Item consumes it" but full-HP target doesn't consume | Reword bullet or move `remove_item` out of the guard |
| `M07-spawn-fallback-log` | 07, 08 | Contract promises a spawn error log that's never emitted; M8 review drops the "default" loop | Add `push_warning`; restore the review loop |
| `M12-attach-script-steps` | 12, 15 | UI scripts never get explicit "attach to root" steps; `@onready` paths break | Add attach steps (mirror M10/M14) |
| `M12-process-mode-retroactive` | 12 | M12 retroactively sets SceneManager `process_mode=Always` (already done in M07) | Replace with a reminder (REGRESSION.md:50) |
| `M18-partymanager-forward-ref` | 18 | Contract says victory writes to PartyManager (not until M21) | Reword to grant_xp()/InventoryManager |
| `M18-defeat-file-path` | 18 | Defeat code block never names its target file | Name `defeat_state.gd` before the block |
| `M09-forward-ref-modules` | 09 | Cache-bypass mis-pointed to M25 (M22); current_hp to M18 (M14) | Fix both forward references |
| `M16-prose-code-string-drift` | 16 | Save-crystal prose/code string mismatch; dead group tags; unwired Crystal Key | Align strings; drop dead tags; mark key optional |
| `M23-custom-type-doc-links` | 23 | Custom types linked to generic engine class pages | Link only the base class; keep custom names plain |
| `M22-chest-group-drop` | 22 | M22 chest drops `add_to_group("interactables")` while claiming parity | Restore or note the intentional removal |
| `M24-bus-ordering` | 24 | MusicManager assigns "Music" bus before buses are created | Move bus creation earlier or add a forward note |
| `M24-sfx-preload-missing-files` | 24 | SFX `const preload()` references `.wav` files never created | Add a WAV-creation step or use `load()` |
| `M25-settings-panel-center-focus` | 25 | Settings panel not actually centered; no focused control (both flows) | Use CenterContainer + grab_focus on a child |
| `M05-camera-limits-per-map` | 05, 07 | Hardcoded camera limits on the shared player can't fit both maps | Note limits are per-map |
| `M03-testzone-delete-checkpoint` | 03 | Checkpoint promises a TestZone print after telling the reader to delete it | Reorder or rephrase |

### Nit

`M11-typewriter-duration-floor` (no min duration on empty lines), `M20-quest-log-bbcode-brackets` (literal `[x]` in BBCode label), `M03-floating-motion-mode` (Floating "disables collision logic" wording), `M20-makeworldflag-unexplained` (helper added but unexplained until M22), `M02-print-color-theme` (print color is theme-dependent), `M01-play-button-labels` (Play vs Run Project/Scene + missing macOS shortcuts).

---

## Strengths

- **Doc-grounded Godot 4 accuracy**: TileMapLayer, `move_and_slide()` no-arg + velocity, `get_axis`, `scene_changed` await-in-autoload, `CACHE_MODE_IGNORE`, AudioServer buses, typed arrays, lifecycle ordering — all verified correct.
- **Solid cross-module data contracts**: HP/MP carry-over, `from_enemy()` carrying max_mp + sprite→portrait, current_hp/mp/xp introduced where promised, save round-trip preserves leveled stats.
- **Clean autoload discipline**: all 8 introduced in the contracted order with matching reference cards; no use-before-introduction; no `Engine.has_singleton` misuse.
- **Stable canonical IDs**: fynn / elder_maren / crystal_guardian / aiden consistent everywhere; zero stale `traveler` IDs.
- **Faithful review modules** (04/08/13/19/23/27) mirror current code, and the full gameplay loop is closed with a proper Game Over choice screen.
- **Strong writing discipline**: no banned AI words, no `--` punctuation, motivate-before-code, lint checker passes.

---

## Prioritized Fix List

1. `M12-get-consumables-typed-return` (blocker — unblocks the battle item menu)
2. `M21-lira-npcdata-missing`
3. `M21-npc-handler-fragments`
4. `M17-boss-trigger-setup`
5. `X-pendant-scene-key-forward-dep`
6. `M21-dialoguebox-control-type`
7. `M11-choice-guard-incremental`
8. `M24-25-missing-music-tracks`
9. `X-review-skipping-teasers`
10. `M16-26-whisperwood-encounters`
11. `M26-pendant-playtest-framing`
12. `M26-economy-balance-numbers`
13. `X-player-group-premature-contract`
14. `M14-unreachable-damage-number`
15. `M17-encounterdata-weight-range`
16. `M01-advanced-settings-toggle`
17. `M19-doc-links-globalscope`
18. `M04-broken-doc-links`
19. `M24-autoload-card-final-label`
20. `X-inventory-use-item-on-member-unwired`

Remaining minor/nit items follow as a cleanup pass; none block completion.
