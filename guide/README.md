# Building a JRPG in Godot 4 — A Guide for Software Engineers

You are a professional software engineer. You know how to design systems, manage state, separate concerns, and write testable code. You have never built a game.

This guide bridges that gap. Over 21 chapters and 3 appendices, you will build a complete 2D turn-based JRPG in Godot 4.x — from an empty project to a shippable game with a battle system, dialogue, quests, equipment, save/load, and audio. Every concept is introduced through the lens of patterns you already know: component trees, event emitters, dependency injection, state machines, and data-driven architecture.

## What You Will Build

A classic JRPG in the tradition of Final Fantasy VI and Chrono Trigger:

- **Overworld exploration** with tile-based maps, NPCs, and random encounters
- **Turn-based battle system** with a speed-based turn queue, elemental damage, status effects, and a unique Resonance mechanic
- **Party management** with active/reserve members, equipment, and skill trees
- **Dialogue system** with portraits, branching choices, and cutscene integration
- **Quest tracking** with objectives, prerequisites, and rewards
- **Inventory and equipment** with stat bonuses and item effects
- **Save/load** to JSON with versioned file format
- **Audio** with BGM crossfading and pooled SFX
- **UI** with menus, HUD, battle interface, and gamepad/keyboard navigation

## Who This Is For

- You have professional experience writing software (any language, any framework)
- You are comfortable with typed languages, component architectures, and event-driven patterns
- You have zero game development experience (or want to start fresh with Godot)
- You have Godot 4.x installed and can create a new project

The guide uses Angular/TypeScript as its primary frame of reference for analogies, but the concepts transfer from any modern framework (React, Vue, SwiftUI, Jetpack Compose). If you know what a component tree is, you will be fine.

## Philosophy

Game development is software engineering with a render loop. The same principles apply:

- **Separation of concerns** — Data resources define *what* things are. Systems define *how* they behave. Scenes define *where* they appear.
- **Composition over inheritance** — Small, focused nodes composed into scenes, not deep class hierarchies.
- **Event-driven communication** — Signals decouple producers from consumers, just like event emitters and observables.
- **Testable architecture** — Pure static functions for game logic. Integration through dependency injection. State machines with explicit transitions.

The unfamiliar parts — frame-based updates, pixel coordinates, collision layers, sprite sheets — are mechanics, not paradigms. You already have the paradigms.

## How to Read This Guide

Chapters are sequential. Each one builds on the last. Do not skip ahead — later chapters reference systems built in earlier ones.

Each chapter follows this structure:

1. **Concept introduction** with a parallel to something you know
2. **What we are building** in this chapter
3. **Step-by-step implementation** with complete, copy-pasteable code
4. **How it connects** to previously built systems
5. **Common mistakes** and how to avoid them
6. **What is next** — preview of the next chapter

Code examples use GDScript with full static typing, tabs for indentation, and double quotes for strings. Every example is complete — no `...` ellipsis hiding critical details.

## Table of Contents

### Part I — Foundation

| # | Chapter | What You Build |
|---|---------|---------------|
| 1 | [Godot for Engineers](01-godot-for-engineers.md) | Mental model: scene tree, nodes, signals, GDScript, game loop |
| 2 | [Project Setup](02-project-setup.md) | Project structure, input actions, conventions, version control |

### Part II — The World

| # | Chapter | What You Build |
|---|---------|---------------|
| 3 | [Player and Movement](03-player-and-movement.md) | CharacterBody2D, 4-directional movement, sprite animation |
| 4 | [World Building](04-world-building.md) | TileMapLayers, multi-layer maps, collision, camera limits |
| 5 | [Scene Transitions](05-scene-transitions.md) | Fade/slide transitions, spawn points, scene management |

### Part III — Interaction

| # | Chapter | What You Build |
|---|---------|---------------|
| 6 | [Data-Driven Design](06-data-driven-design.md) | Custom Resource classes, .tres files, data-driven design |
| 7 | [NPCs and Dialogue](07-npcs-and-dialogue.md) | NPC entity, DialogueManager autoload, dialogue UI |
| 8 | [Interactables](08-interactables.md) | Strategy pattern, chests, signs, doors, save points |

### Part IV — Combat

| # | Chapter | What You Build |
|---|---------|---------------|
| 9 | [Party Management](09-party-management.md) | PartyManager, roster, active/reserve, runtime state |
| 10 | [Battle System Foundations](10-battle-system-foundations.md) | BattleScene, battlers, turn queue, state machine |
| 11 | [Battle Commands and Targeting](11-battle-commands-and-targeting.md) | Player/enemy turns, action system, AI patterns |
| 12 | [Battle Math and Resolution](12-battle-math-and-resolution.md) | Damage formulas, status effects, victory/defeat |

### Part V — Systems

| # | Chapter | What You Build |
|---|---------|---------------|
| 13 | [Random Encounters](13-random-encounters.md) | EncounterSystem, step counting, weighted pools |
| 14 | [Inventory and Equipment](14-inventory-and-equipment.md) | InventoryManager, EquipmentManager, stat bonuses |
| 15 | [Quests and Events](15-quests-and-events.md) | QuestManager, EventFlags, story progression |
| 16 | [Save and Load](16-save-and-load.md) | SaveManager, JSON serialization, save slots |

### Part VI — Polish

| # | Chapter | What You Build |
|---|---------|---------------|
| 17 | [Audio](17-audio.md) | AudioManager, BGM crossfade, SFX pool, audio buses |
| 18 | [UI and Menus](18-ui-and-menus.md) | HUD, pause menu, battle UI, menu navigation |
| 19 | [Polish and Juice](19-polish-and-juice.md) | Screen shake, damage popups, companions, tweens |
| 20 | [Testing](20-testing.md) | GUT framework, unit tests, test-driven workflow |
| 21 | [Integration and Shipping](21-integration-and-shipping.md) | System wiring, full game loop, export, what's next |

### Appendices

| # | Appendix | Contents |
|---|----------|----------|
| A | [Architecture Patterns](appendix-architecture-patterns.md) | Signal, autoload, state machine, strategy, factory, EventBus, serialize |
| B | [Editor vs Code Workflow](appendix-editor-workflow.md) | When to use the editor, when to write code, hybrid tasks |
| C | [Project Checklist](appendix-checklist.md) | Pre-release feature completeness verification |

## Prerequisites

- **Godot 4.x** (4.3 or later recommended) — download from [godotengine.org](https://godotengine.org)
- **A code editor** — Godot's built-in editor works, or use VS Code with the godot-tools extension
- **Programming experience** — you should be comfortable reading typed code with classes, interfaces, and generics
- **Git** — for version control (optional but strongly recommended)

## Conventions Used

- `MonospaceText` refers to code, file paths, class names, or terminal commands
- **Bold text** introduces new terms or emphasizes important points
- Code blocks include the file path as a comment on the first line when showing a complete file
- GDScript uses static typing everywhere: `var speed: float = 80.0`, not `var speed = 80.0`
- All string literals use double quotes: `"hello"`, not `'hello'`

Let's build a game.
