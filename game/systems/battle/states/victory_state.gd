extends State

## Handles battle victory: calculates rewards, shows victory screen.

const UITheme = preload("res://ui/ui_theme.gd")
const FANFARE_PATH: String = "res://assets/music/Success!.ogg"

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	# Play victory fanfare
	var fanfare := load(FANFARE_PATH) as AudioStream
	if fanfare:
		AudioManager.play_bgm(fanfare, 0.0)
	else:
		push_warning("Victory fanfare not found: " + FANFARE_PATH)

	var total_exp: int = 0
	var total_gold: int = 0
	var items: Array[String] = []

	var bus: Node = get_node_or_null("/root/EventBus")
	for b in battle_scene.enemy_battlers:
		if b is EnemyBattler:
			total_exp += b.exp_reward
			total_gold += b.gold_reward
			if bus and b.data:
				bus.emit_enemy_defeated(b.data.id)
			for loot_entry in b.loot_table:
				var chance: float = loot_entry.get("drop_chance", 0.0)
				if randf() < chance:
					items.append(loot_entry.get("item_id", "unknown"))

	# Apply gold rewards
	var inv: Node = get_node_or_null("/root/InventoryManager")
	if inv:
		inv.add_gold(total_gold)
		for item_id in items:
			inv.add_item(StringName(item_id), 1)

	# Apply XP to all party members
	var pm: Node = get_node_or_null("/root/PartyManager")
	var level_ups: Array[Dictionary] = []
	if pm:
		level_ups = apply_xp_rewards(pm.get_active_party(), total_exp)

	var party_data: Array[Resource] = []
	if pm:
		party_data = pm.get_active_party()

	var battle_ui: Node = battle_scene.get_node_or_null("BattleUI")
	if battle_ui:
		battle_ui.show_victory(
			total_exp, total_gold, items, party_data, level_ups,
		)
		battle_ui.add_battle_log(
			"Victory! Gained %d EXP and %d Gold." % [total_exp, total_gold],
			UITheme.LogType.VICTORY,
		)
		for lu: Dictionary in level_ups:
			battle_ui.add_battle_log(
				"%s reached Level %d!" % [lu["character"], lu["level"]],
				UITheme.LogType.VICTORY,
			)

	# Wait for player to dismiss victory screen
	await get_tree().create_timer(2.0).timeout
	battle_scene.end_battle(true)


## Applies XP to each CharacterData in the party. Returns an array of
## level-up info dicts with "character", "level", and "changes" keys.
static func apply_xp_rewards(
	party: Array[Resource], total_exp: int,
) -> Array[Dictionary]:
	var level_ups: Array[Dictionary] = []
	for member: Resource in party:
		if member is CharacterData:
			var results := LevelManager.add_xp(member, total_exp)
			for changes: Dictionary in results:
				level_ups.append({
					"character": member.display_name,
					"level": member.level,
					"changes": changes,
				})
	return level_ups
