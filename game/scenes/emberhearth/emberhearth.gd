extends Node2D

## Emberhearth — volcanic caldera city, Cindral Wastes major hub.
## Safe town hub with inn, blacksmith, shop, NPCs. No random encounters.
## Story event: FireAndAsh triggers on first entry when sienna_defected.
##
## Modules:
##   emberhearth_map.gd      — tilemap data constants
##   emberhearth_dialogue.gd — flag-reactive NPC dialogue

const Maps = preload("emberhearth_map.gd")
const Dialogue = preload("emberhearth_dialogue.gd")
const SP = preload("res://systems/scene_paths.gd")
const SHOP_DATA_PATH: String = (
	"res://data/shops/emberhearth_forge.tres"
)
const SCENE_BGM_PATH: String = (
	"res://assets/music/Embers of Today.ogg"
)

var _shop_data: Resource = null

@onready var _ground: TileMapLayer = $Ground
@onready var _ground_detail: TileMapLayer = $GroundDetail
@onready var _paths: TileMapLayer = $Paths
@onready var _caldera_border: TileMapLayer = $CalderaBorder
@onready var _objects: TileMapLayer = $Objects
@onready var _above_player: TileMapLayer = $AbovePlayer
@onready var _exit_to_scorched_road: Area2D = (
	$Triggers/ExitToScorchedRoad
)


func _ready() -> void:
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 448)
	_start_scene_music()
	UILayer.hud.location_name = "Emberhearth"

	# Spawn point
	$Entities/SpawnFromScorchedRoad.add_to_group(
		"spawn_from_scorched_road",
	)

	# Connect exit trigger
	_exit_to_scorched_road.body_entered.connect(
		_on_exit_to_scorched_road_entered,
	)

	# Zone markers
	_spawn_zone_markers()

	# Save point
	_spawn_save_point_marker()

	# Load shop data
	_shop_data = load(SHOP_DATA_PATH)

	# Connect NPC interactions
	var innkeeper: StaticBody2D = $Entities/InnkeeperNPC
	if innkeeper:
		innkeeper.interaction_ended.connect(
			_on_innkeeper_finished,
		)

	var shopkeeper: StaticBody2D = $Entities/ShopkeeperNPC
	if shopkeeper:
		shopkeeper.interaction_ended.connect(
			_on_shopkeeper_finished,
		)

	var blacksmith: StaticBody2D = $Entities/BlacksmithNPC
	if blacksmith:
		blacksmith.interaction_ended.connect(
			_on_blacksmith_finished,
		)

	# Set flag-reactive NPC dialogue
	_setup_npc_dialogue()

	# Companion followers
	var player_node := get_tree().get_first_node_in_group(
		"player",
	) as Node2D
	if player_node:
		var companion_ctrl := CompanionController.new()
		companion_ctrl.setup(player_node)
		$Entities.add_child(companion_ctrl)

	# Story event: FireAndAsh on first entry with sienna_defected
	_maybe_trigger_ash_event.call_deferred()


func _maybe_trigger_ash_event() -> void:
	var flags := EventFlags.get_all_flags()
	if not FireAndAsh.compute_can_trigger(flags):
		return
	var event := FireAndAsh.new()
	add_child(event)
	event.trigger()
	await event.sequence_completed
	event.queue_free()
	# Refresh NPC dialogue after story event sets flags
	_setup_npc_dialogue()


func _start_scene_music() -> void:
	var bgm := load(SCENE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 1.0)
	else:
		push_warning("Scene BGM not found: " + SCENE_BGM_PATH)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.TF_TERRAIN,       # source 0 — ground, path
		MapBuilder.ASHLANDS_OBJECTS,  # source 1 — caldera border
		MapBuilder.STEAMPUNK_CITY1,   # source 2 — forge objects
		MapBuilder.STEAMPUNK_CITY2,   # source 3 — building walls
	]
	MapBuilder.apply_tileset(
		[
			_ground, _ground_detail, _paths,
			_caldera_border, _objects, _above_player,
		] as Array[TileMapLayer],
		atlas_paths,
		Maps.SOLID_TILES,
	)

	# Procedural ground — volcanic biome noise + position hash
	var ground_noise := FastNoiseLite.new()
	ground_noise.seed = Maps.GROUND_NOISE_SEED
	ground_noise.frequency = Maps.GROUND_NOISE_FREQ
	ground_noise.fractal_octaves = Maps.GROUND_NOISE_OCTAVES
	_fill_ground_with_variants(_ground, ground_noise)
	MapBuilder.disable_collision(_ground)

	# Ground detail — sparse rubble (source 2)
	MapBuilder.build_layer(
		_ground_detail, Maps.DECOR_MAP,
		Maps.DETAIL_LEGEND, 2,
	)
	MapBuilder.disable_collision(_ground_detail)

	# Paths (source 0) — sandy/tan with position hash variety
	_fill_paths_with_variants(_paths)
	MapBuilder.disable_collision(_paths)

	# Caldera border — ashlands rocks (source 1) with variants
	MapBuilder.fill_layer_with_variants(
		_caldera_border, Maps.BORDER_MAP,
		Maps.BORDER_VARIANT_LEGEND, 1,
		Maps.BORDER_HASH_SEED,
	)

	# Building objects (source 2) — forge equipment, fences, barrels
	MapBuilder.build_layer(
		_objects, Maps.BUILDING_MAP,
		Maps.BUILDING_LEGEND, 2,
	)

	# Building facades (source 3) — steampunk city walls
	MapBuilder.build_layer(
		_objects, Maps.BUILDING2_MAP,
		Maps.BUILDING2_LEGEND, 3,
	)

	# Rooftops (source 3, AbovePlayer)
	MapBuilder.build_layer(
		_above_player, Maps.ROOF_MAP,
		Maps.ROOF_LEGEND, 3,
	)
	MapBuilder.disable_collision(_above_player)


func _fill_ground_with_variants(
	layer: TileMapLayer,
	noise: FastNoiseLite,
) -> void:
	for y: int in range(Maps.ROWS):
		for x: int in range(Maps.COLS):
			var noise_val: float = noise.get_noise_2d(
				float(x), float(y),
			)
			var atlas: Vector2i = Maps.pick_tile(noise_val, x, y)
			layer.set_cell(Vector2i(x, y), 0, atlas)
	layer.update_internals()


func _fill_paths_with_variants(layer: TileMapLayer) -> void:
	for y: int in range(Maps.PATH_MAP.size()):
		var row: String = Maps.PATH_MAP[y]
		for x: int in range(row.length()):
			if row[x] == "P":
				var atlas: Vector2i = Maps.pick_path_tile(x, y)
				layer.set_cell(Vector2i(x, y), 0, atlas)
	layer.update_internals()


func _on_exit_to_scorched_road_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if not ResourceLoader.exists(SP.SCORCHED_ROAD):
		return
	GameManager.change_scene(
		SP.SCORCHED_ROAD,
		GameManager.FADE_DURATION,
		"spawn_from_emberhearth",
	)


func _on_innkeeper_finished() -> void:
	PartyManager.heal_all()
	var heal_lines: Array[DialogueLine] = [
		DialogueLine.create(
			"Innkeeper",
			"Rest well. Your party has been fully restored.",
		),
	]
	if not DialogueManager.start_dialogue(heal_lines):
		return
	await DialogueManager.dialogue_ended


func _on_shopkeeper_finished() -> void:
	if _shop_data == null:
		return
	var shop_mgr := get_node_or_null("/root/ShopManager")
	if shop_mgr == null:
		return
	shop_mgr.open_shop(_shop_data)


func _on_blacksmith_finished() -> void:
	# Crafting system deferred — blacksmith is dialogue-only for now
	pass


func _setup_npc_dialogue() -> void:
	var flags := EventFlags.get_all_flags()

	var innkeeper: StaticBody2D = $Entities/InnkeeperNPC
	if innkeeper:
		innkeeper.npc_name = "Innkeeper"
		innkeeper.dialogue_lines = (
			Dialogue.get_innkeeper_dialogue(flags)
		)
		innkeeper.indicator_type = NPC.IndicatorType.CHAT

	var shopkeeper: StaticBody2D = $Entities/ShopkeeperNPC
	if shopkeeper:
		shopkeeper.npc_name = "Shopkeeper"
		shopkeeper.dialogue_lines = (
			Dialogue.get_shopkeeper_dialogue(flags)
		)
		shopkeeper.indicator_type = NPC.IndicatorType.SHOP

	var blacksmith: StaticBody2D = $Entities/BlacksmithNPC
	if blacksmith:
		blacksmith.npc_name = "Blacksmith"
		blacksmith.dialogue_lines = (
			Dialogue.get_blacksmith_dialogue(flags)
		)
		blacksmith.indicator_type = NPC.IndicatorType.CHAT

	var kamara: StaticBody2D = $Entities/KamaraNPC
	if kamara:
		kamara.npc_name = "Elder Kamara"
		kamara.dialogue_lines = (
			Dialogue.get_kamara_dialogue(flags)
		)
		kamara.indicator_type = NPC.IndicatorType.CHAT

	var refugee: StaticBody2D = $Entities/RefugeeNPC
	if refugee:
		refugee.npc_name = "Refugee"
		refugee.dialogue_lines = (
			Dialogue.get_refugee_dialogue(flags)
		)
		refugee.indicator_type = NPC.IndicatorType.CHAT


func _spawn_zone_markers() -> void:
	var south_marker := ZoneMarker.new()
	south_marker.direction = ZoneMarker.Direction.DOWN
	south_marker.destination_name = "Scorched Road"
	south_marker.position = (
		_exit_to_scorched_road.position + Vector2(0, -12)
	)
	add_child(south_marker)


func _spawn_save_point_marker() -> void:
	var save_point: Node = $Entities/SavePoint
	if not save_point:
		return
	save_point.indicator_type = Interactable.IndicatorType.SAVE
	var marker := SavePointMarker.new()
	save_point.add_child(marker)
