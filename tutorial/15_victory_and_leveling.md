# Module 15: Victory, Rewards, and Leveling

## What We Have So Far

Interactive combat with enemies, AI, random encounters, and a boss fight. But winning a battle does nothing: no rewards, no progression.

## What We're Building This Module

Post-battle rewards (XP, gold, item drops), a leveling system with stat growth curves, the victory fanfare screen, and the game-over/defeat flow.

## Preparing the Data Layer

Before building the victory and leveling flows, we need to add a few runtime properties to existing Resources. Make these changes first.

### CharacterData Additions

Open `res://resources/character_data.gd` and add these runtime properties (not `@export`, since these track state during play, not base data):

```gdscript
# Add to character_data.gd, runtime state (below the @export vars)
var current_xp: int = 0
var current_hp: int = 0  # Tracks HP between battles
var current_mp: int = 0  # Tracks MP between battles
```

> **Why both CharacterData and BattlerData have HP/MP:** BattlerData holds HP/MP *during* a battle (it's temporary, created fresh each fight). CharacterData holds HP/MP *between* battles (persistent across scenes). At battle start, `BattlerData.initialize_from_character()` copies from CharacterData. At battle end, we sync back.

### The XP Curve

We need a formula for "how much XP to reach the next level." A simple quadratic curve works well. Add this static function to `res://resources/character_data.gd`:

```gdscript
static func xp_for_level(level: int) -> int:
    return level * level * 10
```

| Level | XP to Next Level | Total XP |
|-------|-----------------|----------|
| 1 → 2 | 10 | 10 |
| 2 → 3 | 40 | 50 |
| 3 → 4 | 90 | 140 |
| 4 → 5 | 160 | 300 |
| 5 → 6 | 250 | 550 |
| 10 → 11 | 1,000 | 3,850 |

The formula `level * level * 10` means at level 1 you need 10 XP, at level 5 you need 250 XP, etc.

This curve starts gentle and ramps up. Early levels come fast (motivating), later levels take more effort (extending gameplay).

### Stat Growth

When a character levels up, their stats increase based on **growth rates** defined in CharacterData. Add this method to `res://resources/character_data.gd`:

> **Note:** `level_up()` modifies the Resource's properties at runtime. These changes persist in memory (because Resources are shared by reference) but do NOT modify the `.tres` file on disk. This is the correct behavior; runtime progression should not overwrite base data.

```gdscript
func level_up() -> Dictionary:
    level += 1
    var gains: Dictionary = {
        hp = hp_growth + randi_range(0, 2),
        mp = mp_growth + randi_range(0, 1),
        attack = attack_growth + randi_range(0, 1),
        defense = defense_growth + randi_range(0, 1),
        speed = speed_growth,
    }
    max_hp += gains.hp
    max_mp += gains.mp
    attack += gains.attack
    defense += gains.defense
    speed += gains.speed
    return gains
```

The small random variance (randi_range(0, 1) or (0, 2)) makes each level-up feel slightly different.

## The Victory Flow

Now that the data layer is ready, update the Victory battle state (`res://systems/battle/states/victory_state.gd`) to show rewards:

```gdscript
extends BattleState
## Battle won. Calculate and display rewards.


func enter(_context: Dictionary = {}) -> void:
    print("--- VICTORY ---")

    var total_xp: int = 0
    var total_gold: int = 0
    var dropped_items: Array[ItemData] = []

    # Calculate rewards from all enemies
    for enemy in battle_manager.enemies:
        if enemy.enemy_data:
            total_xp += enemy.enemy_data.xp_reward
            total_gold += enemy.enemy_data.gold_reward
            if enemy.enemy_data.drop_item and randf() < enemy.enemy_data.drop_chance:
                dropped_items.append(enemy.enemy_data.drop_item)

    # Distribute XP to party members
    var xp_per_member: int = total_xp / max(1, battle_manager.get_alive_party().size())
    for battler in battle_manager.get_alive_party():
        _apply_xp(battler, xp_per_member)

    # Sync battle HP/MP back to CharacterData for persistence
    for battler in battle_manager.party:
        if battler.character_data:
            battler.character_data.current_hp = battler.current_hp
            battler.character_data.current_mp = battler.current_mp

    # Grant gold
    InventoryManager.add_gold(total_gold)
    print("Gained " + str(total_gold) + " gold!")

    # Grant dropped items
    for item in dropped_items:
        InventoryManager.add_item(item)
        print("Found: " + item.display_name + "!")

    battle_manager.battle_won.emit()

    # Wait for player to acknowledge
    await get_tree().create_timer(2.0).timeout
    # Return to overworld
    SceneManager.return_from_battle()


func _apply_xp(battler: BattlerData, xp: int) -> void:
    if not battler.character_data:
        return

    var char_data: CharacterData = battler.character_data
    char_data.current_xp += xp
    print(char_data.display_name + " gained " + str(xp) + " XP!")

    # Check for level up (may level up multiple times)
    var required: int = CharacterData.xp_for_level(char_data.level)
    while char_data.current_xp >= required:
        char_data.current_xp -= required
        var gains: Dictionary = char_data.level_up()
        print(char_data.display_name + " reached level " + str(char_data.level) + "!")
        print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
              ", DEF +" + str(gains.defense))
        required = CharacterData.xp_for_level(char_data.level)
```

## The Defeat Flow

When the party is wiped:

```gdscript
extends BattleState
## Party wiped. Show game over screen.


func enter(_context: Dictionary = {}) -> void:
    print("--- DEFEAT ---")
    print("The party has fallen...")
    battle_manager.battle_lost.emit()

    await get_tree().create_timer(2.0).timeout

    # Return to title screen (or last save point)
    # For now, just reload the main scene
    SceneManager.change_scene("res://scenes/willowbrook/willowbrook.tscn", "default")
```

In Module 20, we'll replace this with a proper Game Over screen with options (retry, load save, return to title).

## Post-Battle State Restoration

After a victorious battle, the party returns to the overworld with their current HP/MP intact. Two things make this work:

1. **HP/MP sync**: the Victory state writes `battler.current_hp` and `battler.current_mp` back to `battler.character_data` (see the sync code above). Without this, the party would return to full HP after every fight.
2. **Resource sharing**: CharacterData resources are shared by reference. When the battle modifies stats via `level_up()`, that change persists across scenes automatically.

For now, since we don't have a formal PartyManager yet (Module 17), the CharacterData resource at `res://data/characters/aiden.tres` is loaded via `load()`, which caches it. All code that loads the same path gets the same object.

> **JRPG Pattern:** After normal battles, HP/MP carry over (no free heals). Save points and inns restore them. This creates a resource management game: do you use that Potion now or save it for the boss?

> **See:** [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html). Resources loaded with `load()` are cached and shared by reference. Runtime changes to exported properties persist in memory but don't write back to the `.tres` file.

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html). For future enhancements, Tweens can animate the victory screen (stat bars filling, XP counters incrementing).

## What We've Learned

- **XP distribution** divides total XP among alive party members.
- **Level-up curve** (`level * level * 10`) starts easy and scales up.
- **Stat growth** per level uses base growth rates plus small random variance.
- **Loot drops** use probability (`randf() < drop_chance`) on each defeated enemy.
- **Victory flow:** calculate rewards → distribute XP → check level ups → grant gold/items → return to overworld.
- **Defeat flow:** display game over → return to title or last save.
- Resources modified in battle persist because they're shared by reference.

## What You Should See

After winning a battle:
- "--- VICTORY ---" appears in the output panel
- XP, gold, and item drops are listed (e.g., "Aiden gained 12 XP!", "Gained 6 gold!")
- Characters may level up: "Aiden reached level 2!" with stat increases
- After 2 seconds, the game returns to the overworld at the player's previous position
- HP/MP carry over from the battle (if you took damage, your HP stays reduced)

After losing a battle:
- "--- DEFEAT ---" appears in the output panel
- The game reloads Willowbrook (placeholder for proper Game Over screen in Module 20)

**Concrete example:** If Aiden (level 1, 0 XP) defeats 2 Crystal Slimes (12 XP each), he gains 24 XP total. Since level 1→2 requires only 10 XP, he levels up to level 2 with 14 XP remaining.

## Next Module

We have combat with rewards. In **Module 16: The Quest System and Game Flags**, we'll add a game-wide flag system for tracking world state, quest data with objectives, a quest log UI, and make NPCs react differently based on what the player has accomplished.
