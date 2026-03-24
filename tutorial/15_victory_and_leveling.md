# Module 15: Victory, Rewards, and Leveling

## What We Have So Far

Interactive combat with enemies, AI, random encounters, and a boss fight. But winning a battle does nothing — no rewards, no progression.

## What We're Building This Module

Post-battle rewards (XP, gold, item drops), a leveling system with stat growth curves, the victory fanfare screen, and the game-over/defeat flow.

## Experience and Level-Up

### The XP Curve

We need a formula for "how much XP to reach the next level." A simple quadratic curve works well:

```gdscript
static func xp_for_level(level: int) -> int:
    return level * level * 10
```

| Level | XP Required | Total XP |
|-------|------------|----------|
| 1 → 2 | 40 | 40 |
| 2 → 3 | 90 | 130 |
| 3 → 4 | 160 | 290 |
| 5 → 6 | 360 | 1,050 |
| 10 → 11 | 1,100 | 5,500 |

This curve starts gentle and ramps up — early levels come fast (motivating), later levels take more effort (extending gameplay).

### Stat Growth

When a character levels up, their stats increase based on **growth rates** defined in CharacterData:

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

Update the Victory battle state to show rewards:

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
        # Access the EnemyData to get rewards
        var enemy_data: EnemyData = enemy.get_meta("enemy_data") if enemy.has_meta("enemy_data") else null
        if enemy_data:
            total_xp += enemy_data.xp_reward
            total_gold += enemy_data.gold_reward
            if enemy_data.drop_item and randf() < enemy_data.drop_chance:
                dropped_items.append(enemy_data.drop_item)

    # Distribute XP to party members
    var xp_per_member: int = total_xp / max(1, battle_manager.get_alive_party().size())
    for battler in battle_manager.get_alive_party():
        _apply_xp(battler, xp_per_member)

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
    # We need to track current XP — add it to CharacterData
    char_data.current_xp = char_data.get("current_xp") if char_data.get("current_xp") else 0
    char_data.current_xp += xp
    print(char_data.display_name + " gained " + str(xp) + " XP!")

    # Check for level up
    var required: int = char_data.level * char_data.level * 10
    while char_data.current_xp >= required:
        char_data.current_xp -= required
        var gains: Dictionary = char_data.level_up()
        print(char_data.display_name + " reached level " + str(char_data.level) + "!")
        print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
              ", DEF +" + str(gains.defense))
        required = char_data.level * char_data.level * 10
```

Add `current_xp` to the CharacterData resource:

```gdscript
# Add to character_data.gd
var current_xp: int = 0  # Runtime state, not @export
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
    SceneManager.change_scene("res://scenes/willowbrook/willowbrook.tscn")
```

In Module 20, we'll replace this with a proper Game Over screen with options (retry, load save, return to title).

## Post-Battle State Restoration

After a victorious battle, the party needs to return to the overworld with their current HP/MP intact. The SceneManager's `return_from_battle()` handles the scene change, but we need to persist the party's battle state.

For now, since we don't have a formal PartyManager yet (Module 17), the CharacterData resources retain their modified stats because Resources are shared by reference. When the battle modifies `character_data.max_hp` via `level_up()`, that change persists across scenes.

> **JRPG Pattern:** After normal battles, HP/MP carry over (no free heals). Save points and inns restore them. This creates a resource management game — do you use that Potion now or save it for the boss?

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
- "VICTORY" message appears
- XP, gold, and item drops are shown
- Characters may level up with stat increase notifications
- The game returns to the overworld at the player's previous position

After losing a battle:
- "DEFEAT" message appears
- The game reloads (placeholder for proper Game Over screen)

## Next Module

We have combat with rewards. In **Module 16: The Quest System and Game Flags**, we'll add a game-wide flag system for tracking world state, quest data with objectives, a quest log UI, and make NPCs react differently based on what the player has accomplished.
