extends Node2D

## Overgrown Capital — Chapter 5 dungeon.
## The party explores the crystal-vine-overgrown ruins of the pre-Severance
## capital city. Three districts: Market, Entertainment, Research/Residential.
## Story events (Lyra Fragment 2, Last Gardener, camp scenes) live in T-0191–T-0195.

const SP = preload("res://systems/scene_paths.gd")
const INTERACTABLE_SCENE := preload("res://entities/interactable/interactable.tscn")
const LAST_GARDENER_ENCOUNTER_SCRIPT := preload("res://events/last_gardener_encounter.gd")
const LEAVING_CAPITAL_SCRIPT := preload("res://events/leaving_capital.gd")
const PURIFICATION_NODE_STRATEGY_SCRIPT := preload(
	"res://entities/interactable/strategies/purification_node_strategy.gd"
)
const MEMORIAL_ECHO_STRATEGY_SCRIPT := preload(
	"res://entities/interactable/strategies/memorial_echo_strategy.gd"
)
const SAVE_POINT_STRATEGY_SCRIPT := preload(
	"res://entities/interactable/strategies/save_point_strategy.gd"
)
const MEMORY_BLOOM_PATH: String = "res://data/enemies/memory_bloom.tres"
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const ECHO_NOMAD_PATH: String = "res://data/enemies/echo_nomad.tres"
const SCENE_BGM_PATH: String = "res://assets/music/Echoes of the Capital.ogg"
const LYRA_FRAGMENT_2_ECHO_ID: StringName = &"lyra_fragment_2"
const LYRA_FRAGMENT_2_FLAG: String = "lyra_fragment_2_collected"
const MORNING_COMMUTE_ECHO_ID: StringName = &"morning_commute"
const FAMILY_DINNER_ECHO_ID: StringName = &"family_dinner"
const MOTHERS_COMFORT_ECHO_ID: StringName = &"mothers_comfort"
const FIRST_DAY_OF_SCHOOL_ECHO_ID: StringName = &"first_day_of_school"

# Tilemap data (legends + maps) lives in OvergrownCapitalMap.
# Encounter pool builder lives in OvergrownCapitalEncounters.

var _ground_debris_layer: TileMapLayer = null
var _crystal_walls: Dictionary = {}
var _gardener_zone: Area2D = null

@onready var _ground_layer: TileMapLayer = $Ground
@onready var _ground_detail_layer: TileMapLayer = $GroundDetail
@onready var _walls_layer: TileMapLayer = $Walls
@onready var _objects_layer: TileMapLayer = $Objects
@onready var _above_player_layer: TileMapLayer = $AbovePlayer
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


static func compute_research_save_point_position() -> Vector2:
	## Save point in the Research Quarter — col 28, row 7.
	## One tile below Lyra Fragment 2 echo (row 6); gives players a chance
	## to save before the Research Quarter vision and Last Gardener encounter.
	return Vector2(448.0, 112.0)


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


static func compute_gardener_zone_position() -> Vector2:
	## Trigger zone for The Last Gardener encounter.
	## Positioned at col 20, row 3 — the Palace District approach,
	## blocking the path north out of the Research Quarter.
	return Vector2(320.0, 48.0)


static func compute_research_quarter_echo_position() -> Vector2:
	## Lyra Fragment 2 echo in the Research Quarter lab — col 28, row 6.
	return Vector2(448.0, 96.0)


static func compute_residential_echo_positions() -> Array:
	## Two echo positions in the Residential Quarter.
	## [0] Mother's Comfort — apartment room, col 5, row 15.
	## [1] First Day of School — school building, col 9, row 12.
	return [Vector2(80.0, 240.0), Vector2(144.0, 192.0)]


static func compute_mothers_comfort_vision_lines() -> Array[String]:
	## Vision for Mother's Comfort echo — warmth in a residential apartment.
	return [
		"Kael",
		("An apartment. Small, clean. Children's drawings taped to the walls."
			+ " Something is baking."),
		"Lyra",
		("She's humming. The baby's finally asleep."
			+ " She keeps humming even when she doesn't need to."),
		"Kael",
		"She was happy. Just this moment — she was happy.",
	]


static func compute_first_day_of_school_vision_lines() -> Array[String]:
	## Vision for First Day of School echo — Network-mediated education.
	return [
		"Kael",
		"A classroom. The children aren't looking at the teacher — their eyes are somewhere else.",
		"Iris",
		("Direct neural injection. They're not learning; they're being loaded."
			+ " In forty minutes they'll 'know' a year's mathematics."),
		"Garrick",
		"They look like they're sleeping. They look like they've always looked like that.",
	]


static func compute_market_echo_positions() -> Array:
	## Two echo positions in the Market District.
	## [0] Morning Commute — transit bench area, col 6, row 20.
	## [1] Family Dinner — residential quarter, col 34, row 20.
	return [Vector2(96.0, 320.0), Vector2(544.0, 320.0)]


static func compute_morning_commute_vision_lines() -> Array[String]:
	## Vision for Morning Commute echo — the empty commuter in the Memory Network.
	return [
		"Kael",
		("A man on a bench. Eyes closed. Peaceful expression."
			+ " The market moves around him — vendors, crowds, noise —"
			+ " and he isn't here at all."),
		"Iris",
		("Memory Network. He's reliving something better."
			+ " A beach, a summer, something that ended before the Severance."),
		"Kael",
		("They were everywhere. Thousands of them, walking and eating and riding"
			+ " while their minds were somewhere else entirely."),
	]


static func compute_family_dinner_vision_lines() -> Array[String]:
	## Vision for Family Dinner echo — the family seated apart in the Network.
	return [
		"Kael",
		("A kitchen. Table set for four. Food going cold."
			+ " Three of them are far away — I can feel it,"
			+ " the kind of absence that isn't absence."),
		"Garrick",
		("The youngest is awake. Watching. Waiting for someone to come back."),
		"Kael",
		"No one does.",
	]


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
	# Dedicated debris layer — separates ground debris from ornate floor detail.
	# Inserted between GroundDetail and Walls, matching Overgrown Ruins pattern.
	_ground_debris_layer = TileMapLayer.new()
	_ground_debris_layer.name = "GroundDebris"
	_ground_debris_layer.z_index = -1
	add_child(_ground_debris_layer)
	move_child(_ground_debris_layer, $GroundDetail.get_index() + 1)

	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 448)
	_start_scene_music()
	_setup_camera_limits()
	_setup_encounters()
	_setup_purification_nodes()
	_setup_save_points()
	_setup_lyra_fragment_echo()
	_setup_market_echoes()
	_setup_residential_echoes()

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
	_setup_gardener_zone()


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
		_walls_layer, _objects_layer, _above_player_layer] as Array[TileMapLayer],
		atlas_paths,
		solid,
	)

	# Ground — position-hashed brown earth floor (no noise needed)
	_fill_ground_with_variants(_ground_layer)
	MapBuilder.disable_collision(_ground_layer)

	# Procedural floor detail — scattered transparent debris
	var detail_noise := FastNoiseLite.new()
	detail_noise.seed = OvergrownCapitalMap.GROUND_NOISE_SEED + 1
	detail_noise.frequency = 0.15
	MapBuilder.scatter_decorations(
		_ground_detail_layer,
		OvergrownCapitalMap.COLS, OvergrownCapitalMap.ROWS,
		detail_noise, OvergrownCapitalMap.DETAIL_ENTRIES,
	)
	MapBuilder.disable_collision(_ground_detail_layer)

	# Procedural debris — scattered rubble, vines, moss
	var debris_noise := FastNoiseLite.new()
	debris_noise.seed = OvergrownCapitalMap.GROUND_NOISE_SEED + 2
	debris_noise.frequency = 0.2
	MapBuilder.scatter_decorations(
		_ground_debris_layer,
		OvergrownCapitalMap.COLS, OvergrownCapitalMap.ROWS,
		debris_noise, OvergrownCapitalMap.DEBRIS_ENTRIES,
	)
	MapBuilder.disable_collision(_ground_debris_layer)

	# Structural layers — authored, gameplay-critical placement
	_fill_walls_with_variants(_walls_layer)
	MapBuilder.build_layer(
		_objects_layer, OvergrownCapitalMap.OBJECTS_MAP, OvergrownCapitalMap.OBJECTS_LEGEND, 2
	)
	MapBuilder.build_layer(
		_above_player_layer, OvergrownCapitalMap.ABOVE_PLAYER_MAP,
		OvergrownCapitalMap.ABOVE_LEGEND, 2,
	)


func _fill_ground_with_variants(layer: TileMapLayer) -> void:
	for y: int in range(OvergrownCapitalMap.ROWS):
		for x: int in range(OvergrownCapitalMap.COLS):
			var atlas: Vector2i = OvergrownCapitalMap.pick_floor_tile(x, y)
			layer.set_cell(Vector2i(x, y), 0, atlas)
	layer.update_internals()


func _fill_walls_with_variants(layer: TileMapLayer) -> void:
	for y: int in range(OvergrownCapitalMap.WALL_MAP.size()):
		var row: String = OvergrownCapitalMap.WALL_MAP[y]
		for x: int in range(row.length()):
			var ch: String = row[x]
			if ch == "W":
				var atlas: Vector2i = OvergrownCapitalMap.pick_wall_tile(x, y)
				layer.set_cell(Vector2i(x, y), 0, atlas)
			elif ch == "G":
				layer.set_cell(
					Vector2i(x, y), 0, OvergrownCapitalMap.WALL_BORDER_TILE,
				)
	layer.update_internals()


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


func _setup_gardener_zone() -> void:
	if not LastGardenerEncounter.compute_can_trigger(EventFlags.get_all_flags()):
		return
	_gardener_zone = Area2D.new()
	_gardener_zone.name = "GardenerZone"
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(96.0, 32.0)
	shape.shape = rect
	_gardener_zone.add_child(shape)
	_gardener_zone.position = compute_gardener_zone_position()
	_gardener_zone.body_entered.connect(_on_gardener_zone_entered)
	$Triggers.add_child(_gardener_zone)


func _on_gardener_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	if _gardener_zone:
		_gardener_zone.monitoring = false
	_trigger_gardener_encounter.call_deferred()


func _trigger_gardener_encounter() -> void:
	if not LastGardenerEncounter.compute_can_trigger(EventFlags.get_all_flags()):
		return
	var encounter: Node = LAST_GARDENER_ENCOUNTER_SCRIPT.new()
	add_child(encounter)
	encounter.trigger()
	await encounter.sequence_completed
	encounter.queue_free()


func _on_exit_to_ruins_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	if LeavingCapital.compute_can_trigger(EventFlags.get_all_flags()):
		_exit_to_ruins.monitoring = false
		_trigger_leaving_capital_and_exit.call_deferred()
		return
	GameManager.change_scene(SP.VERDANT_FOREST, GameManager.FADE_DURATION, "spawn_from_capital")


func _trigger_leaving_capital_and_exit() -> void:
	var event: Node = LEAVING_CAPITAL_SCRIPT.new()
	add_child(event)
	event.trigger()
	await event.sequence_completed
	event.queue_free()
	GameManager.change_scene(SP.VERDANT_FOREST, GameManager.FADE_DURATION, "spawn_from_capital")


func _setup_market_echoes() -> void:
	var positions := compute_market_echo_positions()

	# Morning Commute — transit bench area, western Market District.
	var morning_strat := MEMORIAL_ECHO_STRATEGY_SCRIPT.new() as MemorialEchoStrategy
	morning_strat.echo_id = MORNING_COMMUTE_ECHO_ID
	morning_strat.require_quest_id = &""
	morning_strat.vision_lines = compute_morning_commute_vision_lines()
	var morning_interactable := INTERACTABLE_SCENE.instantiate() as Interactable
	morning_interactable.name = "MorningCommuteEcho"
	morning_interactable.strategy = morning_strat
	morning_interactable.one_time = true
	morning_interactable.indicator_type = Interactable.IndicatorType.INTERACT
	morning_interactable.position = positions[0]
	$Entities.add_child(morning_interactable)

	# Family Dinner — residential quarter, eastern Market District.
	var dinner_strat := MEMORIAL_ECHO_STRATEGY_SCRIPT.new() as MemorialEchoStrategy
	dinner_strat.echo_id = FAMILY_DINNER_ECHO_ID
	dinner_strat.require_quest_id = &""
	dinner_strat.vision_lines = compute_family_dinner_vision_lines()
	var dinner_interactable := INTERACTABLE_SCENE.instantiate() as Interactable
	dinner_interactable.name = "FamilyDinnerEcho"
	dinner_interactable.strategy = dinner_strat
	dinner_interactable.one_time = true
	dinner_interactable.indicator_type = Interactable.IndicatorType.INTERACT
	dinner_interactable.position = positions[1]
	$Entities.add_child(dinner_interactable)


func _setup_residential_echoes() -> void:
	var positions := compute_residential_echo_positions()

	# Mother's Comfort — apartment room, western Residential Quarter.
	var comfort_strat := MEMORIAL_ECHO_STRATEGY_SCRIPT.new() as MemorialEchoStrategy
	comfort_strat.echo_id = MOTHERS_COMFORT_ECHO_ID
	comfort_strat.require_quest_id = &""
	comfort_strat.vision_lines = compute_mothers_comfort_vision_lines()
	var comfort_interactable := INTERACTABLE_SCENE.instantiate() as Interactable
	comfort_interactable.name = "MothersComfortEcho"
	comfort_interactable.strategy = comfort_strat
	comfort_interactable.one_time = true
	comfort_interactable.indicator_type = Interactable.IndicatorType.INTERACT
	comfort_interactable.position = positions[0]
	$Entities.add_child(comfort_interactable)

	# First Day of School — school building, central Residential Quarter.
	var school_strat := MEMORIAL_ECHO_STRATEGY_SCRIPT.new() as MemorialEchoStrategy
	school_strat.echo_id = FIRST_DAY_OF_SCHOOL_ECHO_ID
	school_strat.require_quest_id = &""
	school_strat.vision_lines = compute_first_day_of_school_vision_lines()
	var school_interactable := INTERACTABLE_SCENE.instantiate() as Interactable
	school_interactable.name = "FirstDayOfSchoolEcho"
	school_interactable.strategy = school_strat
	school_interactable.one_time = true
	school_interactable.indicator_type = Interactable.IndicatorType.INTERACT
	school_interactable.position = positions[1]
	$Entities.add_child(school_interactable)


func _setup_save_points() -> void:
	# Market District save point — col 10, row 23.
	var market_strat := SAVE_POINT_STRATEGY_SCRIPT.new() as SavePointStrategy
	var market_save := INTERACTABLE_SCENE.instantiate() as Interactable
	market_save.name = "SavePointMarket"
	market_save.strategy = market_strat
	market_save.one_time = false
	market_save.indicator_type = Interactable.IndicatorType.SAVE
	market_save.position = compute_market_save_point_position()
	$Entities.add_child(market_save)

	# Research Quarter save point — col 28, row 5.
	var research_strat := SAVE_POINT_STRATEGY_SCRIPT.new() as SavePointStrategy
	var research_save := INTERACTABLE_SCENE.instantiate() as Interactable
	research_save.name = "SavePointResearch"
	research_save.strategy = research_strat
	research_save.one_time = false
	research_save.indicator_type = Interactable.IndicatorType.SAVE
	research_save.position = compute_research_save_point_position()
	$Entities.add_child(research_save)
