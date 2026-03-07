extends Node2D

## Gearhaven — sprawling steampunk coastal metropolis, Ironcoast major hub.
## Safe town hub with inn, tech shop, armor shop, NPCs. No random encounters.
## Largest city in the game — districts: Spire, Factory, Harbor, High Rise,
## Undercity.
##
## Modules:
##   gearhaven_map.gd      — tilemap data constants
##   gearhaven_dialogue.gd — flag-reactive NPC dialogue

const Maps = preload("gearhaven_map.gd")
const Dialogue = preload("gearhaven_dialogue.gd")
const SHOP_DATA_PATH: String = (
	"res://data/shops/gearhaven_tech.tres"
)
const SCENE_BGM_PATH: String = (
	"res://assets/music/Gilded World, Empty Throne.ogg"
)

var _shop_data: Resource = null

@onready var _ground: TileMapLayer = $Ground
@onready var _ground_detail: TileMapLayer = $GroundDetail
@onready var _paths: TileMapLayer = $Paths
@onready var _objects: TileMapLayer = $Objects
@onready var _above_player: TileMapLayer = $AbovePlayer
@onready var _exit_to_coast: Area2D = (
	$Triggers/ExitToShipbreakersCoast
)
@onready var _exit_to_hq: Area2D = (
	$Triggers/ExitToInitiativeHQ
)


func _ready() -> void:
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 480)
	_start_scene_music()
	UILayer.hud.location_name = "Gearhaven"

	# Spawn points
	$Entities/SpawnFromShipbreakersCoast.add_to_group(
		"spawn_from_shipbreakers_coast",
	)
	$Entities/SpawnFromInitiativeHQ.add_to_group(
		"spawn_from_initiative_hq",
	)

	# Connect exit triggers
	_exit_to_coast.body_entered.connect(
		_on_exit_to_coast_entered,
	)
	_exit_to_hq.body_entered.connect(
		_on_exit_to_hq_entered,
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

	var tech_shop: StaticBody2D = $Entities/TechShopNPC
	if tech_shop:
		tech_shop.interaction_ended.connect(
			_on_tech_shop_finished,
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


func _start_scene_music() -> void:
	var bgm := load(SCENE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 1.0)
	else:
		push_warning("Scene BGM not found: " + SCENE_BGM_PATH)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.TF_TERRAIN,       # source 0 — ground, path
		MapBuilder.STEAMPUNK_CITY1,  # source 1 — industrial objects
		MapBuilder.STEAMPUNK_CITY2,  # source 2 — gray brick facades
		MapBuilder.STEAMPUNK_CITY2C, # source 3 — red brick facades
	]
	MapBuilder.apply_tileset(
		[
			_ground, _ground_detail, _paths,
			_objects, _above_player,
		] as Array[TileMapLayer],
		atlas_paths,
		Maps.SOLID_TILES,
	)

	# Procedural ground — city stone biome noise + position hash
	var ground_noise := FastNoiseLite.new()
	ground_noise.seed = Maps.GROUND_NOISE_SEED
	ground_noise.frequency = Maps.GROUND_NOISE_FREQ
	ground_noise.fractal_octaves = Maps.GROUND_NOISE_OCTAVES
	_fill_ground_with_variants(_ground, ground_noise)
	MapBuilder.disable_collision(_ground)

	# Ground detail — sparse rubble (source 1)
	MapBuilder.build_layer(
		_ground_detail, Maps.DECOR_MAP,
		Maps.DETAIL_LEGEND, 1,
	)
	MapBuilder.disable_collision(_ground_detail)

	# Paths (source 0) — sandy/tan with position hash variety
	_fill_paths_with_variants(_paths)
	MapBuilder.disable_collision(_paths)

	# Industrial objects (source 1)
	MapBuilder.build_layer(
		_objects, Maps.BUILDING_MAP,
		Maps.BUILDING_LEGEND, 1,
	)

	# Gray building facades (source 2)
	MapBuilder.build_layer(
		_objects, Maps.BUILDING2_MAP,
		Maps.BUILDING2_LEGEND, 2,
	)

	# Red brick facades (source 3)
	MapBuilder.build_layer(
		_objects, Maps.BUILDING3_MAP,
		Maps.BUILDING3_LEGEND, 3,
	)

	# Gray rooftops (source 2, AbovePlayer)
	MapBuilder.build_layer(
		_above_player, Maps.ROOF_MAP,
		Maps.ROOF_LEGEND, 2,
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


func _on_exit_to_coast_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return


func _on_exit_to_hq_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return


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


func _on_tech_shop_finished() -> void:
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
		innkeeper.dialogue_lines = (
			Dialogue.get_innkeeper_dialogue(flags)
		)
		innkeeper.indicator_type = NPC.IndicatorType.CHAT

	var tech_shop: StaticBody2D = $Entities/TechShopNPC
	if tech_shop:
		tech_shop.npc_name = "Tech Merchant"
		tech_shop.dialogue_lines = (
			Dialogue.get_tech_shop_dialogue(flags)
		)
		tech_shop.indicator_type = NPC.IndicatorType.SHOP

	var armor_shop: StaticBody2D = $Entities/ArmorShopNPC
	if armor_shop:
		armor_shop.npc_name = "Armor Smith"
		armor_shop.dialogue_lines = (
			Dialogue.get_armor_shop_dialogue(flags)
		)
		armor_shop.indicator_type = NPC.IndicatorType.SHOP

	var harbor_master: StaticBody2D = $Entities/HarborMasterNPC
	if harbor_master:
		harbor_master.npc_name = "Harbor Master"
		harbor_master.dialogue_lines = (
			Dialogue.get_harbor_master_dialogue(flags)
		)
		harbor_master.indicator_type = NPC.IndicatorType.CHAT

	var officer: StaticBody2D = $Entities/InitiativeOfficerNPC
	if officer:
		officer.npc_name = "Initiative Officer"
		officer.dialogue_lines = (
			Dialogue.get_initiative_officer_dialogue(flags)
		)
		officer.indicator_type = NPC.IndicatorType.CHAT

	var contact: StaticBody2D = $Entities/UndergroundContactNPC
	if contact:
		contact.npc_name = "Shady Contact"
		contact.dialogue_lines = (
			Dialogue.get_underground_contact_dialogue(flags)
		)
		contact.indicator_type = NPC.IndicatorType.CHAT


func _spawn_zone_markers() -> void:
	var west_marker := ZoneMarker.new()
	west_marker.direction = ZoneMarker.Direction.LEFT
	west_marker.destination_name = "Shipbreaker's Coast"
	west_marker.position = (
		_exit_to_coast.position + Vector2(12, 0)
	)
	add_child(west_marker)

	var east_marker := ZoneMarker.new()
	east_marker.direction = ZoneMarker.Direction.RIGHT
	east_marker.destination_name = "Initiative HQ"
	east_marker.position = (
		_exit_to_hq.position + Vector2(-12, 0)
	)
	add_child(east_marker)


func _spawn_save_point_marker() -> void:
	var save_point: Node = $Entities/SavePoint
	if not save_point:
		return
	save_point.indicator_type = Interactable.IndicatorType.SAVE
	var marker := SavePointMarker.new()
	save_point.add_child(marker)
