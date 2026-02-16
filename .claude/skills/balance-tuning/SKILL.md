---
name: balance-tuning
description: Analyze and adjust game balance for combat, progression, economy, or difficulty. Reads design docs and existing data to suggest or apply balance changes to .tres resource files.
argument-hint: <area> [details...]
disable-model-invocation: true
---

# Balance Tuning

Analyze and tune game balance for: **$ARGUMENTS**

ultrathink

## Step 1 — Identify Balance Area

| Area | Data Files | Design Reference |
|------|-----------|-----------------|
| `combat` | enemies, skills, status effects | `docs/game-design/01-core-mechanics.md`, `02-enemy-design.md` |
| `progression` | character stats, XP curves, AP costs | `docs/game-design/01-core-mechanics.md` |
| `economy` | item prices, loot tables, shop inventory | `docs/game-design/01-core-mechanics.md` |
| `difficulty` | encounter rates, enemy scaling, boss stats | `docs/game-design/02-enemy-design.md` |
| `resonance` | resonance gain rates, overload thresholds | `docs/game-design/01-core-mechanics.md` |
| `echoes` | echo power levels, rarity distribution | `docs/lore/04-echo-catalog.md` |
| `equipment` | weapon/armor stats, upgrade scaling | `docs/game-design/01-core-mechanics.md` |

## Step 2 — Read Current Data

1. Read the relevant design document for intended balance
2. Read all `.tres` files in the affected data directories
3. Read the Resource class definitions to understand valid ranges
4. Read existing formulas in system scripts (damage calc, XP calc, etc.)

## Step 3 — Analyze Balance

### Combat Balance Analysis

- **Damage formula**: Does damage scale appropriately with level?
- **TTK (Time to Kill)**: How many turns to defeat enemies at expected level?
- **Healing economy**: Can players sustain through a dungeon without excessive items?
- **Skill utility**: Are all skills viable? Any strictly dominant?
- **Element balance**: Are element weaknesses/resistances balanced?
- **Resonance risk/reward**: Is overload worth the risk?

### Progression Analysis

- **XP curve**: Does leveling feel rewarding without being grindy?
- **Stat growth**: Do stats scale meaningfully per level?
- **Skill unlock pacing**: Are new abilities spread throughout the game?
- **AP cost scaling**: Are later skills appropriately more expensive?

### Economy Analysis

- **Gold income vs costs**: Can players afford needed items?
- **Item pricing tiers**: Consumable < Equipment < Rare < Unique
- **Loot table fairness**: Are drop rates frustrating or too generous?
- **Shop progression**: Do shops offer upgrades at appropriate intervals?

## Step 4 — Propose Changes

Present balance changes to the user in this format:

```markdown
## Balance Changes for: <area>

### Current State
- <observation about current balance>

### Issues Identified
1. <problem>: <why it's a problem>
2. ...

### Proposed Changes

| File | Property | Current | Proposed | Rationale |
|------|----------|---------|----------|-----------|
| `potion.tres` | `value` | 30 | 50 | Too weak for mid-game |
| `goblin.tres` | `hp` | 100 | 80 | Too tanky for first area |

### Formulas Affected
- Damage: `base_atk * (1.0 - def / 200.0)` — no change needed
- XP: `base_xp * level_diff_modifier` — adjust modifier curve
```

## Step 5 — Apply Changes (after user approval)

1. Edit the affected `.tres` files with approved values
2. Update any formula scripts if approved
3. Document the changes in a balance log

## Step 6 — Report

1. Files modified with old → new values
2. Expected gameplay impact
3. Areas to monitor during playtesting
4. Suggested follow-up tuning areas

## Balance Design Principles (from design docs)

- **No grinding required** — strategy > levels
- **Every encounter designed with purpose**
- **Resonance is high-risk, high-reward**
- **Expected story completion level: 50-60** (cap 99)
- **40+ hour main story**
- **Multiple viable party compositions**
