extends Node2D

## Overgrown Capital — Chapter 5 dungeon.
## The party explores the crystal-vine-overgrown ruins of the pre-Severance
## capital city. Three districts: Market, Entertainment, Research/Residential.
## Story events (Lyra Fragment 2, Last Gardener, camp scenes) live in T-0191–T-0195.

const SP = preload("res://systems/scene_paths.gd")
const INTERACTABLE_SCENE := preload("res://entities/interactable/interactable.tscn")
const PURIFICATION_NODE_STRATEGY_SCRIPT := preload(
	"res://entities/interactable/strategies/purification_node_strategy.gd"
)
const MEMORIAL_ECHO_STRATEGY_SCRIPT := preload(
	"res://entities/interactable/strategies/memorial_echo_strategy.gd"
)
const MEMORY_BLOOM_PATH: String = "res://data/enemies/memory_bloom.tres"
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const ECHO_NOMAD_PATH: String = "res://data/enemies/echo_nomad.tres"
const SCENE_BGM_PATH: String = "res://assets/music/Echoes of the Capital.ogg"
const LYRA_FRAGMENT_2_ECHO_ID: StringName = &"lyra_fragment_2"
const LYRA_FRAGMENT_2_FLAG: String = "lyra_fragment_2_collected"

# Tilemap data (legends + maps) lives in OvergrownCapitalMap.
# Encounter pool builder lives in OvergrownCapitalEncounters.

var _ground_debris_layer: TileMapLayer = null
var _crystal_walls: Dictionary = {}

@onready var _ground_layer: TileMapLayer = $Ground
@onready var _ground_detail_layer: TileMapLayer = $GroundDetail
@onready var _walls_layer: TileMapLayer = $Walls
@onready var _objects_layer: TileMapLayer = $Objects
@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_from_ruins: Marker2D = $Entities/SpawnFromRuins
@onready var _encounter_system: EncounterSystem = $EncounterSystem
@onready var _exit_to_ruins: Area2D = $Triggers/ExitToRuins


static func compute_spawn_from_ruins_position() -> Vector2:
	## Entry spawn point at col 20, row 25 — bottom-center Market District.
	## Matches SpawnFromRuins Marker2D position in the scene tree.
	return Vector2(320.0, 400.0)


static func compute_market_save_point_position() -> Vector2:
	## Save point in the Market District entry area — col 10, row 23.
	return Vector2(160.0, 368.0)


static func compute_purification_node_market_position() -> Vector2:
	## Purification Node blocking Market → Entertainment path.
	## Positioned at col 18, row 13 — center-west, just north of Market District.
	return Vector2(288.0, 208.0)


static func compute_crystal_wall_market_position() -> Vector2:
	## Crystal wall blocking Market → Entertainment path.
	## One tile north of the market Purification Node (col 18, row 12).
	return Vector2(288.0, 192.0)


static func compute_purification_node_entertainment_position() -> Vector2:
	## Purification Node blocking Entertainment → Research Quarter path.
	## Positioned at col 30, row 10 — northeast area.
	return Vector2(480.0, 160.0)


static func compute_crystal_wall_entertainment_position() -> Vector2:
	## Crystal wall blocking Entertainment → Research path.
	## One tile north of the entertainment Purification Node (col 30, row 9).
	return Vector2(480.0, 144.0)


static func compute_research_quarter_echo_position() -> Vector2:
	## Lyra Fragment 2 echo in the Research Quarter lab — col 28, row 6.
	return Vector2(448.0, 96.0)


static func compute_research_quarter_lines() -> Array[String]:
	## Returns vision_lines for Lyra Fragment 2: approach dialogue (Iris reads
	## nameplate) followed by the memory sequence (Marcus Cole, 140-day countdown,
	## Lyra's apology) and the party's reaction after the vision.
	return [
		"Iris",
		"Dr. L. Reyes. Resonance Dynamics. Department of Theoretical Consciousness.",
		"Kael",
		"This is her lab.",
		"Kael",
		'"World\'s Okayest Physicist."',
		"Iris",
		"I like her.",
		"Kael",
		"This is a big one. I can feel it from here.",
		"Lyra",
		("The connection density index has been climbing exponentially."
			+ " At this rate we hit the singularity threshold in..."
			+ " one hundred and forty days."),
		"Lyra",
		"I'm sorry. All of you. I'm sorry.",
		"Kael",
		("She knew it was coming. She warned people and they didn't listen."
			+ " One hundred and forty days."),
		"Iris",
		("We should get out of here."
			+ " The Initiative may have sensors that detect a fragment integration."),
		"Garrick",
		"Agreed.",
	]


func _ready() -> void:
	# Explicit z-index hierarchy matching existing scene pattern.
	$Ground.z_index = 0
	$GroundDetail.z_index = 0
	$Walls.z_index = 0
	$Objects.z_index = 0
	$Entities.z_index = 1

	# Dedicated debris layer — separates ground debris from ornate floor detail.
	# Inserted between GroundDetail and Walls, matching Overgrown Ruins pattern.
	_ground_debris_layer = TileMapLayer.new()
	_ground_debris_layer.name = "GroundDebris"
	_ground_debris_layer.z_index = 0
	add_child(_ground_debris_layer)
	move_child(_ground_debris_layer, $GroundDetail.get_index() + 1)

	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 448)
	_start_scene_music()
	_setup_camera_limits()
	_setup_encounters()
	_setup_purification_nodes()
	_setup_lyra_fragment_echo()

	UILayer.hud.location_name = "Overgrown Capital"

	# Register spawn groups — GameManager.change_scene() looks for these groups
	# when transitioning from Overgrown Ruins or Verdant Forest.
	_spawn_from_ruins.add_to_group("spawn_from_ruins")
	_spawn_from_ruins.add_to_group("spawn_from_forest")

	# Set default spawn position — overridden by GameManager after _ready()
	# if a specific spawn group was requested.
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.global_position = _spawn_from_ruins.global_position

	_exit_to_ruins.body_entered.connect(_on_exit_to_ruins_entered)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.FAIRY_FOREST_A5_A,
		MapBuilder.RUINS_A5,
		MapBuilder.OVERGROWN_RUINS_OBJECTS,
	]
	var solid: Dictionary = {
		1: [
			Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4),
			Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4),
			Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5),
			Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5), Vector2i(7, 5),
			Vector2i(0, 8), Vector2i(1, 8), Vector2i(2, 8), Vector2i(3, 8),
			Vector2i(4, 8), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8),
			Vector2i(0, 9), Vector2i(1, 9), Vector2i(2, 9), Vector2i(3, 9),
			Vector2i(4, 9), Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9),
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
	MapBuilder.build_layer(
		_ground_layer, OvergrownCapitalMap.GROUND_MAP, OvergrownCapitalMap.GROUND_LEGEND, 0
	)
	MapBuilder.build_layer(
		_ground_detail_layer, OvergrownCapitalMap.DETAIL_MAP, OvergrownCapitalMap.DETAIL_LEGEND, 1
	)
	MapBuilder.build_layer(
		_ground_debris_layer, OvergrownCapitalMap.DEBRIS_MAP, OvergrownCapitalMap.DEBRIS_LEGEND, 2
	)
	MapBuilder.build_layer(
		_walls_layer, OvergrownCapitalMap.WALL_MAP, OvergrownCapitalMap.WALL_LEGEND, 1
	)
	MapBuilder.build_layer(
		_objects_layer, OvergrownCapitalMap.OBJECTS_MAP, OvergrownCapitalMap.OBJECTS_LEGEND, 2
	)


func _start_scene_music() -> void:
	var bgm := load(SCENE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 1.5)
	else:
		push_warning("Scene BGM not found: " + SCENE_BGM_PATH)


func _setup_camera_limits() -> void:
	var cam: Camera2D = _player.get_node("Camera2D") as Camera2D
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 640
		cam.limit_bottom = 448


func _setup_encounters() -> void:
	var memory_bloom := load(MEMORY_BLOOM_PATH) as Resource
	var creeping_vine := load(CREEPING_VINE_PATH) as Resource
	var echo_nomad := load(ECHO_NOMAD_PATH) as Resource
	var pool := OvergrownCapitalEncounters.build_pool(memory_bloom, creeping_vine, echo_nomad)
	_encounter_system.setup(pool)


func _setup_purification_nodes() -> void:
	# Market District → Entertainment District (node_id = "market_north").
	var market_wall := _create_crystal_wall(compute_crystal_wall_market_position())
	market_wall.name = "CrystalWallMarket"
	_crystal_walls["market_north"] = market_wall
	$Entities.add_child(market_wall)

	var market_strat := PURIFICATION_NODE_STRATEGY_SCRIPT.new() as PurificationNodeStrategy
	market_strat.node_id = "market_north"
	market_strat.activation_lines = [
		"Kael",
		"The crystal vines are retreating… The path north is open.",
	]
	market_strat.node_cleared.connect(_on_node_cleared)
	var market_node := INTERACTABLE_SCENE.instantiate() as Interactable
	market_node.name = "PurificationNodeMarket"
	market_node.strategy = market_strat
	market_node.one_time = true
	market_node.indicator_type = Interactable.IndicatorType.INTERACT
	market_node.position = compute_purification_node_market_position()
	$Entities.add_child(market_node)

	# Entertainment District → Research Quarter (node_id = "entertainment_research").
	var ent_wall := _create_crystal_wall(compute_crystal_wall_entertainment_position())
	ent_wall.name = "CrystalWallEntertainment"
	_crystal_walls["entertainment_research"] = ent_wall
	$Entities.add_child(ent_wall)

	var ent_strat := PURIFICATION_NODE_STRATEGY_SCRIPT.new() as PurificationNodeStrategy
	ent_strat.node_id = "entertainment_research"
	ent_strat.activation_lines = [
		"Lyra",
		"I can feel the Resonance shifting — the crystal lattice is dissolving.",
		"Kael",
		"The Research Quarter… we can reach it now.",
	]
	ent_strat.node_cleared.connect(_on_node_cleared)
	var ent_node := INTERACTABLE_SCENE.instantiate() as Interactable
	ent_node.name = "PurificationNodeEntertainment"
	ent_node.strategy = ent_strat
	ent_node.one_time = true
	ent_node.indicator_type = Interactable.IndicatorType.INTERACT
	ent_node.position = compute_purification_node_entertainment_position()
	$Entities.add_child(ent_node)

	# Apply persistent cleared state from previous sessions.
	var all_flags := EventFlags.get_all_flags()
	for nid: String in _crystal_walls.keys():
		if not PurificationNodeStrategy.compute_node_active_state(all_flags, nid):
			var wall: Node = _crystal_walls.get(nid)
			if wall and is_instance_valid(wall):
				wall.queue_free()
			_crystal_walls.erase(nid)


func _create_crystal_wall(at_position: Vector2) -> StaticBody2D:
	## Creates a solid crystal wall that blocks the player (collision_layer = 2).
	var wall := StaticBody2D.new()
	wall.position = at_position
	wall.collision_layer = 2
	wall.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32.0, 16.0)
	shape.shape = rect
	wall.add_child(shape)
	return wall


func _on_node_cleared(node_id: String) -> void:
	var wall: Node = _crystal_walls.get(node_id)
	if wall and is_instance_valid(wall):
		wall.queue_free()
	_crystal_walls.erase(node_id)


func _setup_lyra_fragment_echo() -> void:
	# Bridge persisted collection state — echo_collected signal fires in current
	# session only, so ensure the EventFlag is set if already collected.
	if EchoManager.has_echo(LYRA_FRAGMENT_2_ECHO_ID) and not EventFlags.has_flag(
		LYRA_FRAGMENT_2_FLAG
	):
		EventFlags.set_flag(LYRA_FRAGMENT_2_FLAG)

	EchoManager.echo_collected.connect(_on_echo_collected)

	var echo_strat := MEMORIAL_ECHO_STRATEGY_SCRIPT.new() as MemorialEchoStrategy
	echo_strat.echo_id = LYRA_FRAGMENT_2_ECHO_ID
	echo_strat.require_quest_id = &""
	echo_strat.vision_lines = compute_research_quarter_lines()

	var echo_interactable := INTERACTABLE_SCENE.instantiate() as Interactable
	echo_interactable.name = "LyraFragment2Echo"
	echo_interactable.strategy = echo_strat
	echo_interactable.one_time = true
	echo_interactable.indicator_type = Interactable.IndicatorType.INTERACT
	echo_interactable.position = compute_research_quarter_echo_position()
	$Entities.add_child(echo_interactable)


func _on_echo_collected(echo_id: StringName) -> void:
	if echo_id == LYRA_FRAGMENT_2_ECHO_ID:
		EventFlags.set_flag(LYRA_FRAGMENT_2_FLAG)


func _on_exit_to_ruins_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	GameManager.change_scene(SP.VERDANT_FOREST, GameManager.FADE_DURATION, "spawn_from_capital")
