extends Node2D

## Prismfall — crystal trading town on the canyon edge.
## Safe town hub with inn, shop, archives. No random encounters.
## Story event: CrystalCityArrival triggers on first entry.
##
## Modules:
##   prismfall_map.gd      — tilemap data constants
##   prismfall_dialogue.gd — flag-reactive NPC dialogue

const Maps = preload("prismfall_map.gd")
const Dialogue = preload("prismfall_dialogue.gd")
const SP = preload("res://systems/scene_paths.gd")
const SHOP_DATA_PATH: String = "res://data/shops/prismfall_arms.tres"
const SCENE_BGM_PATH: String = (
	"res://assets/music/Kingdom of First Light.ogg"
)

var _shop_data: Resource = null

@onready var _ground: TileMapLayer = $Ground
@onready var _ground_detail: TileMapLayer = $GroundDetail
@onready var _paths: TileMapLayer = $Paths
@onready var _objects: TileMapLayer = $Objects
@onready var _above_player: TileMapLayer = $AbovePlayer
@onready var _exit_to_approach: Area2D = $Triggers/ExitToApproach
@onready var _exit_to_dungeon: Area2D = $Triggers/ExitToDungeon


func _ready() -> void:
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 448)
	_start_scene_music()
	UILayer.hud.location_name = "Prismfall"

	# Spawn points
	$Entities/SpawnFromApproach.add_to_group("spawn_from_approach")
	$Entities/SpawnFromDungeon.add_to_group("spawn_from_dungeon")

	# Triggers
	_exit_to_approach.body_entered.connect(
		_on_exit_to_approach_entered,
	)
	_exit_to_dungeon.body_entered.connect(
		_on_exit_to_dungeon_entered,
	)

	# Zone markers
	_spawn_zone_markers()

	# Save point
	_spawn_save_point_marker()

	# Load shop data
	_shop_data = load(SHOP_DATA_PATH)

	# NPC dialogue
	_setup_npc_dialogue()

	# Connect shop interaction
	var shopkeeper: StaticBody2D = $Entities/ShopkeeperNPC
	if shopkeeper:
		shopkeeper.interaction_ended.connect(
			_on_shopkeeper_finished,
		)

	# Connect innkeeper interaction
	var innkeeper: StaticBody2D = $Entities/InnkeeperNPC
	if innkeeper:
		innkeeper.interaction_ended.connect(
			_on_innkeeper_finished,
		)

	# Companion followers
	var player_node := get_tree().get_first_node_in_group(
		"player",
	) as Node2D
	if player_node:
		var companion_ctrl := CompanionController.new()
		companion_ctrl.setup(player_node)
		$Entities.add_child(companion_ctrl)

	# Story event: crystal_city_arrival on first visit
	_maybe_trigger_arrival.call_deferred()


func _maybe_trigger_arrival() -> void:
	var flags := EventFlags.get_all_flags()
	if not CrystalCityArrival.compute_can_trigger(flags):
		return
	var event := CrystalCityArrival.new()
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
		MapBuilder.TF_TERRAIN,      # source 0 — stone ground, path
		MapBuilder.RUINS1_OBJECTS,   # source 1 — crystal pillars, walls
		MapBuilder.STONE_OBJECTS,    # source 2 — rocks, flowers
	]
	MapBuilder.apply_tileset(
		[
			_ground, _ground_detail, _paths,
			_objects, _above_player,
		] as Array[TileMapLayer],
		atlas_paths,
		Maps.SOLID_TILES,
	)

	# Procedural ground — stone biome noise + position hash
	var ground_noise := FastNoiseLite.new()
	ground_noise.seed = Maps.GROUND_NOISE_SEED
	ground_noise.frequency = Maps.GROUND_NOISE_FREQ
	ground_noise.fractal_octaves = Maps.GROUND_NOISE_OCTAVES
	_fill_ground_with_variants(_ground, ground_noise)
	MapBuilder.disable_collision(_ground)

	# Paths (source 0) — sandy/tan with position hash variety
	_fill_paths_with_variants(_paths)
	MapBuilder.disable_collision(_paths)

	# Ground detail (source 2) — sparse rocks and flowers
	MapBuilder.build_layer(
		_ground_detail, Maps.DECOR_MAP, Maps.DETAIL_LEGEND, 2,
	)
	MapBuilder.disable_collision(_ground_detail)

	# Building walls (source 1) — crystal pillars, stone walls
	MapBuilder.build_layer(
		_objects, Maps.BUILDING_MAP, Maps.BUILDING_LEGEND, 1,
	)

	# Above-player (source 1) — pillar tops, arch tops
	MapBuilder.build_layer(
		_above_player, Maps.ROOF_MAP, Maps.ROOF_LEGEND, 1,
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


func _on_exit_to_approach_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	GameManager.change_scene(
		SP.PRISMFALL_APPROACH,
		GameManager.FADE_DURATION,
		"spawn_from_prismfall",
	)


func _on_exit_to_dungeon_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	GameManager.change_scene(
		SP.BENEATH_PRISMFALL,
		GameManager.FADE_DURATION,
		"spawn_from_dungeon",
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


func _setup_npc_dialogue() -> void:
	var flags := EventFlags.get_all_flags()

	var innkeeper: StaticBody2D = $Entities/InnkeeperNPC
	if innkeeper:
		innkeeper.npc_name = "Innkeeper"
		innkeeper.dialogue_lines = Dialogue.get_innkeeper_dialogue(
			flags,
		)
		innkeeper.indicator_type = NPC.IndicatorType.CHAT

	var shopkeeper: StaticBody2D = $Entities/ShopkeeperNPC
	if shopkeeper:
		shopkeeper.npc_name = "Shopkeeper"
		shopkeeper.dialogue_lines = (
			Dialogue.get_shopkeeper_dialogue(flags)
		)
		shopkeeper.indicator_type = NPC.IndicatorType.SHOP

	var archivist: StaticBody2D = $Entities/ArchivistNPC
	if archivist:
		archivist.npc_name = "Archivist"
		archivist.dialogue_lines = (
			Dialogue.get_archivist_dialogue(flags)
		)
		archivist.indicator_type = NPC.IndicatorType.CHAT

	var trader: StaticBody2D = $Entities/TraderNPC
	if trader:
		trader.npc_name = "Trader"
		trader.dialogue_lines = (
			Dialogue.get_trader_dialogue(flags)
		)
		trader.indicator_type = NPC.IndicatorType.CHAT

	var resident: StaticBody2D = $Entities/CanyonResidentNPC
	if resident:
		resident.npc_name = "Canyon Resident"
		resident.dialogue_lines = (
			Dialogue.get_canyon_resident_dialogue(flags)
		)
		resident.indicator_type = NPC.IndicatorType.CHAT


func _spawn_zone_markers() -> void:
	var north_marker := ZoneMarker.new()
	north_marker.direction = ZoneMarker.Direction.UP
	north_marker.destination_name = "Crystalline Steppes"
	north_marker.position = _exit_to_approach.position + Vector2(0, 12)
	add_child(north_marker)

	var south_marker := ZoneMarker.new()
	south_marker.direction = ZoneMarker.Direction.DOWN
	south_marker.destination_name = "Crystal Canyon"
	south_marker.position = _exit_to_dungeon.position + Vector2(0, -12)
	add_child(south_marker)


func _spawn_save_point_marker() -> void:
	var save_point: Node = $Entities/SavePoint
	if not save_point:
		return
	save_point.indicator_type = Interactable.IndicatorType.SAVE
	var marker := SavePointMarker.new()
	save_point.add_child(marker)
