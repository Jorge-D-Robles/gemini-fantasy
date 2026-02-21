extends Node2D

## Overgrown Ruins — the game's starting area.
## Kael explores ancient ruins and discovers Lyra (opening cutscene).
## Contains random encounters (Memory Blooms, Creeping Vines) and
## an exit to the Verdant Forest.

const SP = preload("res://systems/scene_paths.gd")
const EntryDialogue = preload(
	"res://scenes/overgrown_ruins/overgrown_ruins_entry_dialogue.gd"
)
const MEMORY_BLOOM_PATH: String = "res://data/enemies/memory_bloom.tres"
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const LAST_GARDENER_PATH: String = "res://data/enemies/last_gardener.tres"
const KAEL_DATA_PATH: String = "res://data/characters/kael.tres"
const SCENE_BGM_PATH: String = "res://assets/music/Echoes of the Capital.ogg"

# Tilemap data (legends + maps) lives in OvergrownRuinsMap.
# Encounter pool builder lives in OvergrownRuinsEncounters.

var _ground_debris_layer: TileMapLayer = null

@onready var _ground_layer: TileMapLayer = $Ground
@onready var _ground_detail_layer: TileMapLayer = $GroundDetail
@onready var _walls_layer: TileMapLayer = $Walls
@onready var _objects_layer: TileMapLayer = $Objects
@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_point: Marker2D = $Entities/SpawnPoint
@onready var _encounter_system: EncounterSystem = $EncounterSystem
@onready var _opening_sequence: OpeningSequence = $OpeningSequence
@onready var _exit_to_forest: Area2D = $Triggers/ExitToForest
@onready var _lyra_zone: Area2D = $Triggers/LyraDiscoveryZone
@onready var _spawn_from_forest: Marker2D = $Entities/SpawnFromForest
@onready var _boss_zone: Area2D = $Triggers/BossZone
@onready var _boss_encounter: BossEncounter = $BossEncounter
@onready var _garrick_meets_lyra: GarrickMeetsLyra = (
	$GarrickMeetsLyra
)
@onready var _demo_ending: DemoEnding = $DemoEnding


func _ready() -> void:
	# Dedicated debris layer — separates ground debris from ornate floor detail
	# so tiles on each layer can coexist at overlapping cell positions.
	_ground_debris_layer = TileMapLayer.new()
	_ground_debris_layer.name = "GroundDebris"
	_ground_debris_layer.z_index = -1
	add_child(_ground_debris_layer)
	move_child(_ground_debris_layer, $GroundDetail.get_index() + 1)

	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 384)
	_start_scene_music()
	_setup_camera_limits()

	# Initialize Kael in party if not already there
	if PartyManager.get_roster().is_empty():
		var kael_data := load(KAEL_DATA_PATH) as Resource
		if kael_data:
			PartyManager.add_character(kael_data)

	# Set default spawn position — GameManager.change_scene() with
	# spawn_point and SaveManager.set_pending_position() will override
	# after _ready() if a specific position was requested.
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.global_position = _spawn_point.global_position

	# HUD setup
	UILayer.hud.location_name = "Overgrown Ruins"

	# Add spawn points to groups
	_spawn_from_forest.add_to_group("spawn_from_forest")

	# Connect triggers
	_exit_to_forest.body_entered.connect(_on_exit_to_forest_entered)
	_lyra_zone.body_entered.connect(_on_lyra_zone_entered)
	_boss_zone.body_entered.connect(_on_boss_zone_entered)

	# Zone transition marker
	_spawn_zone_marker()

	# Lyra zone logic:
	# 1. Opening not done → zone fires OpeningSequence
	# 2. Opening done + Garrick recruited + not met Lyra → zone fires
	#    GarrickMeetsLyra (chains into DemoEnding)
	# 3. All done (or Garrick not recruited) → zone disabled
	# 4. Save-reload edge case: garrick_met_lyra set but demo_complete
	#    not set → keep zone enabled so demo ending re-triggers
	if EventFlags.has_flag(OpeningSequence.FLAG_NAME):
		var garrick_available := EventFlags.has_flag(
			"garrick_recruited",
		)
		var garrick_done := EventFlags.has_flag(
			GarrickMeetsLyra.FLAG_NAME,
		)
		var demo_done := EventFlags.has_flag(
			DemoEnding.FLAG_NAME,
		)
		if demo_done:
			_lyra_zone.monitoring = false
		elif garrick_done or not garrick_available:
			_lyra_zone.monitoring = false

	# Hide boss zone if already defeated
	if EventFlags.has_flag(BossEncounter.FLAG_NAME):
		_boss_zone.monitoring = false

	# Setup encounter system with ruins enemy pool
	var pool := OvergrownRuinsEncounters.build_pool(
		load(MEMORY_BLOOM_PATH) as Resource,
		load(CREEPING_VINE_PATH) as Resource,
	)
	_encounter_system.setup(pool)
	_encounter_system.encounter_triggered.connect(_on_encounter_triggered)
	_encounter_system.encounter_warning.connect(_on_encounter_warning)

	# Companion followers
	if player_node:
		var companion_ctrl := CompanionController.new()
		companion_ctrl.setup(player_node)
		$Entities.add_child(companion_ctrl)

	# Tutorial: menu hint after 4s on first visit
	_schedule_menu_hint()

	# Entry dialogue fires once when Garrick is in the party
	_maybe_trigger_entry_dialogue.call_deferred()


func _spawn_zone_marker() -> void:
	var marker := ZoneMarker.new()
	marker.direction = ZoneMarker.Direction.RIGHT
	marker.destination_name = "Verdant Forest"
	marker.position = (
		_exit_to_forest.position + Vector2(-12, 0)
	)
	add_child(marker)


func _start_scene_music() -> void:
	var bgm := load(SCENE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 1.5)
	else:
		push_warning("Scene BGM not found: " + SCENE_BGM_PATH)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.TF_DUNGEON,
		MapBuilder.RUINS_OBJECTS,
		MapBuilder.OVERGROWN_RUINS_OBJECTS,
	]
	var solid: Dictionary = {
		0: [
			Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1),
		],
		2: [
			Vector2i(0, 0), Vector2i(2, 0), Vector2i(4, 0),
			Vector2i(0, 4), Vector2i(1, 4),
			Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2),
			Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3),
			Vector2i(8, 2), Vector2i(9, 2),
			Vector2i(8, 3), Vector2i(9, 3),
		],
	}
	MapBuilder.apply_tileset(
		[_ground_layer, _ground_detail_layer, _ground_debris_layer,
		_walls_layer, _objects_layer] as Array[TileMapLayer],
		atlas_paths,
		solid,
	)

	# Ground — position-hashed brown earth floor (no noise needed)
	_fill_ground_with_variants(_ground_layer)
	MapBuilder.disable_collision(_ground_layer)

	# Procedural floor detail — scattered transparent debris
	var detail_noise := FastNoiseLite.new()
	detail_noise.seed = OvergrownRuinsMap.GROUND_NOISE_SEED + 1
	detail_noise.frequency = 0.15
	MapBuilder.scatter_decorations(
		_ground_detail_layer,
		OvergrownRuinsMap.COLS, OvergrownRuinsMap.ROWS,
		detail_noise, OvergrownRuinsMap.DETAIL_ENTRIES,
	)
	MapBuilder.disable_collision(_ground_detail_layer)

	# Procedural debris — scattered rubble, vines, moss
	var debris_noise := FastNoiseLite.new()
	debris_noise.seed = OvergrownRuinsMap.GROUND_NOISE_SEED + 2
	debris_noise.frequency = 0.2
	MapBuilder.scatter_decorations(
		_ground_debris_layer,
		OvergrownRuinsMap.COLS, OvergrownRuinsMap.ROWS,
		debris_noise, OvergrownRuinsMap.DEBRIS_ENTRIES,
	)
	MapBuilder.disable_collision(_ground_debris_layer)

	# Structural layers — authored, gameplay-critical placement
	_fill_walls_with_variants(_walls_layer)
	MapBuilder.build_layer(
		_objects_layer, OvergrownRuinsMap.OBJECTS_MAP, OvergrownRuinsMap.OBJECTS_LEGEND, 2
	)


func _fill_ground_with_variants(layer: TileMapLayer) -> void:
	for y: int in range(OvergrownRuinsMap.ROWS):
		for x: int in range(OvergrownRuinsMap.COLS):
			var atlas: Vector2i = OvergrownRuinsMap.pick_floor_tile(x, y)
			layer.set_cell(Vector2i(x, y), 0, atlas)
	layer.update_internals()


func _fill_walls_with_variants(layer: TileMapLayer) -> void:
	for y: int in range(OvergrownRuinsMap.WALL_MAP.size()):
		var row: String = OvergrownRuinsMap.WALL_MAP[y]
		for x: int in range(row.length()):
			var ch: String = row[x]
			if ch == "W":
				var atlas: Vector2i = OvergrownRuinsMap.pick_wall_tile(x, y)
				layer.set_cell(Vector2i(x, y), 0, atlas)
			elif ch == "G":
				layer.set_cell(
					Vector2i(x, y), 0, OvergrownRuinsMap.WALL_BORDER_TILE,
				)
	layer.update_internals()


func _setup_camera_limits() -> void:
	var cam: Camera2D = _player.get_node("Camera2D") as Camera2D
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 640
		cam.limit_bottom = 384


func _on_exit_to_forest_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	GameManager.change_scene(
		SP.VERDANT_FOREST,
		GameManager.FADE_DURATION,
		"spawn_from_forest",
	)


func _on_lyra_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if BattleManager.is_in_battle():
		return
	if DialogueManager.is_active():
		return
	if GameManager.is_transitioning():
		return

	if not EventFlags.has_flag(OpeningSequence.FLAG_NAME):
		# Opening sequence — Kael discovers Lyra
		_encounter_system.enabled = false
		_lyra_zone.monitoring = false
		_opening_sequence.trigger()
		await _opening_sequence.sequence_completed
		_encounter_system.enabled = true
		# Tutorial: zone travel hint after first major story event
		UILayer.hud.show_tutorial_hint("zone_travel")
	elif EventFlags.has_flag(EventFlagRegistry.GARRICK_RECRUITED) \
			and not EventFlags.has_flag(
				GarrickMeetsLyra.FLAG_NAME,
			):
		# Garrick meets Lyra — Chapter 4 Scene 5
		_encounter_system.enabled = false
		_lyra_zone.monitoring = false
		_garrick_meets_lyra.trigger()
		await _garrick_meets_lyra.sequence_completed
		# Chain demo ending (encounters stay disabled — scene changes)
		_demo_ending.trigger()
	elif EventFlags.has_flag(GarrickMeetsLyra.FLAG_NAME) \
			and not EventFlags.has_flag(
				DemoEnding.FLAG_NAME,
			):
		# Save-reload edge case: garrick_met_lyra set but
		# demo_complete not set — re-trigger demo ending
		_encounter_system.enabled = false
		_lyra_zone.monitoring = false
		_demo_ending.trigger()


func _on_boss_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if EventFlags.has_flag(BossEncounter.FLAG_NAME):
		return
	if not EventFlags.has_flag(OpeningSequence.FLAG_NAME):
		return
	if BattleManager.is_in_battle():
		return
	if DialogueManager.is_active():
		return
	if GameManager.is_transitioning():
		return
	_encounter_system.enabled = false
	_boss_zone.monitoring = false
	_boss_encounter.trigger()


func _maybe_trigger_entry_dialogue() -> void:
	if not EventFlags.has_flag(EntryDialogue.get_entry_gate_flag()):
		return
	if EventFlags.has_flag(EntryDialogue.get_entry_flag()):
		return
	EventFlags.set_flag(EntryDialogue.get_entry_flag())
	var raw: Array = EntryDialogue.get_entry_lines()
	var lines: Array[DialogueLine] = []
	for entry: Dictionary in raw:
		lines.append(DialogueLine.create(entry["speaker"], entry["text"]))
	DialogueManager.start_dialogue(lines)


func _schedule_menu_hint() -> void:
	await get_tree().create_timer(4.0).timeout
	UILayer.hud.show_tutorial_hint("menu")


func _on_encounter_warning() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.3, 1.3, 0.9), 0.15)
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func _on_encounter_triggered(enemy_group: Array[Resource]) -> void:
	if GameManager.current_state != GameManager.GameState.OVERWORLD:
		return
	if DialogueManager.is_active():
		return
	BattleManager.start_battle(enemy_group)
