extends Node2D

## Roothollow — safe town hub with mushroom village buildings.
## No random encounters. Features NPCs (innkeeper, shopkeeper,
## townfolk), Garrick recruitment, save point, exit to Verdant Forest.
##
## Modules:
##   roothollow_maps.gd     — tilemap data constants
##   roothollow_dialogue.gd — flag-reactive NPC dialogue
##   roothollow_quests.gd   — quest text data and condition checks

const Maps = preload("roothollow_maps.gd")
const Dialogue = preload("roothollow_dialogue.gd")
const Quests = preload("roothollow_quests.gd")
const SP = preload("res://systems/scene_paths.gd")
const SHOP_DATA_PATH: String = (
	"res://data/shops/roothollow_general.tres"
)
const HERB_QUEST_PATH: String = (
	"res://data/quests/herb_gathering.tres"
)
const SCOUTS_QUEST_PATH: String = (
	"res://data/quests/scouts_report.tres"
)
const ELDER_QUEST_PATH: String = (
	"res://data/quests/elder_wisdom.tres"
)
const SCENE_BGM_PATH: String = "res://assets/music/Town Theme Day.ogg"

var _shop_data: Resource = null
var _herb_quest: Resource = null
var _scouts_quest: Resource = null
var _elder_quest: Resource = null

@onready var _ground: TileMapLayer = $Ground
@onready var _paths: TileMapLayer = $Paths
@onready var _ground_detail: TileMapLayer = $GroundDetail
@onready var _trees_border: TileMapLayer = $TreesBorder
@onready var _decorations: TileMapLayer = $Decorations
@onready var _objects: TileMapLayer = $Objects
@onready var _above_player: TileMapLayer = $AbovePlayer
@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_from_forest: Marker2D = $Entities/SpawnFromForest
@onready var _exit_to_forest: Area2D = $Triggers/ExitToForest
@onready var _garrick_zone: Area2D = $Triggers/GarrickRecruitZone
@onready var _garrick_event: GarrickRecruitment = $GarrickRecruitment
@onready var _garrick_npc: StaticBody2D = $Entities/GarrickNPC


func _ready() -> void:
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 448)
	_start_scene_music()
	UILayer.hud.location_name = "Roothollow"

	# Add spawn point to group for GameManager lookup
	_spawn_from_forest.add_to_group("spawn_from_forest")

	# Connect triggers
	_exit_to_forest.body_entered.connect(_on_exit_to_forest_entered)
	_garrick_zone.body_entered.connect(_on_garrick_zone_entered)

	# Zone transition marker
	_spawn_zone_marker()

	# Load shop and quest data
	_shop_data = load(SHOP_DATA_PATH)
	_herb_quest = load(HERB_QUEST_PATH)
	_scouts_quest = load(SCOUTS_QUEST_PATH)
	_elder_quest = load(ELDER_QUEST_PATH)

	# Connect innkeeper special interaction
	var innkeeper: StaticBody2D = $Entities/InnkeeperNPC
	if innkeeper:
		innkeeper.interaction_ended.connect(_on_innkeeper_finished)

	# Connect shopkeeper to open shop after dialogue
	var shopkeeper: StaticBody2D = $Entities/ShopkeeperNPC
	if shopkeeper:
		shopkeeper.interaction_ended.connect(
			_on_shopkeeper_finished,
		)

	# Connect NPC interaction_ended for quest offering
	var wren_npc: StaticBody2D = $Entities/TownfolkNPC2
	if wren_npc:
		wren_npc.interaction_ended.connect(_on_wren_finished)
	var thessa_npc: StaticBody2D = $Entities/TownfolkNPC1
	if thessa_npc:
		thessa_npc.interaction_ended.connect(_on_thessa_finished)

	# Hide Garrick recruitment zone if already recruited
	if EventFlags.has_flag(GarrickRecruitment.FLAG_NAME):
		_garrick_zone.monitoring = false
		_garrick_npc.visible = false
		_garrick_npc.process_mode = Node.PROCESS_MODE_DISABLED

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
	var m := Maps
	var atlas_paths: Array[String] = [
		MapBuilder.FAIRY_FOREST_A5_A,
		MapBuilder.MUSHROOM_VILLAGE,
		MapBuilder.FOREST_OBJECTS,
		MapBuilder.STONE_OBJECTS,
		MapBuilder.TREE_OBJECTS,
	]
	MapBuilder.apply_tileset(
		[
			_ground, _paths, _ground_detail, _decorations,
			_objects, _trees_border, _above_player,
		] as Array[TileMapLayer],
		atlas_paths,
		m.SOLID_TILES,
	)
	# Ground: organic terrain patches (grass, dirt, dark earth)
	MapBuilder.build_layer(_ground, m.GROUND_MAP, m.GROUND_LEGEND)
	# Paths (source 0)
	MapBuilder.build_layer(_paths, m.PATH_MAP, m.PATH_LEGEND)
	# Ground detail flower accents (source 0)
	MapBuilder.build_layer(
		_ground_detail, m.DECOR_MAP, m.DETAIL_LEGEND,
	)
	# Forest border canopy (source 2)
	MapBuilder.build_layer(
		_trees_border, m.BORDER_MAP, m.BORDER_LEGEND, 2,
	)
	# Mushroom building walls (source 1, Objects layer)
	MapBuilder.build_layer(
		_objects, m.BUILDING_MAP, m.BUILDING_LEGEND, 1,
	)
	# Mushroom caps / rooftops (source 1, AbovePlayer)
	MapBuilder.build_layer(
		_above_player, m.ROOF_MAP, m.ROOF_LEGEND, 1,
	)
	# Forest canopy overlay (source 2, AbovePlayer)
	MapBuilder.build_layer(
		_above_player, m.CANOPY_MAP, m.CANOPY_LEGEND, 2,
	)
	# Mushroom ground decorations (source 1)
	MapBuilder.build_layer(
		_decorations, m.DECOR_MAP,
		m.MUSHROOM_DECOR_LEGEND, 1,
	)
	# Stone ground decorations (source 3)
	MapBuilder.build_layer(
		_decorations, m.DECOR_MAP,
		m.STONE_DECOR_LEGEND, 3,
	)


func _on_exit_to_forest_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	GameManager.change_scene(
		SP.VERDANT_FOREST,
		GameManager.FADE_DURATION,
		"spawn_from_town",
	)


func _on_garrick_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if EventFlags.has_flag(GarrickRecruitment.FLAG_NAME):
		return
	# Require Lyra discovery and Iris recruitment first
	if not EventFlags.has_flag("opening_lyra_discovered"):
		return
	if not EventFlags.has_flag("iris_recruited"):
		return
	_garrick_zone.monitoring = false
	_garrick_event.trigger()
	await _garrick_event.sequence_completed
	# Hide Garrick NPC after he joins party
	_garrick_npc.visible = false
	_garrick_npc.process_mode = Node.PROCESS_MODE_DISABLED


func _on_innkeeper_finished() -> void:
	PartyManager.heal_all()
	var heal_lines: Array[DialogueLine] = [
		DialogueLine.create(
			"Maren",
			"Rest well. Your party has been fully restored.",
		),
	]
	DialogueManager.start_dialogue(heal_lines)
	await DialogueManager.dialogue_ended
	_check_quest_chain(_herb_quest, "Maren")


func _on_shopkeeper_finished() -> void:
	if _shop_data == null:
		return
	var shop_mgr := get_node_or_null("/root/ShopManager")
	if shop_mgr:
		shop_mgr.open_shop(_shop_data)


func _on_wren_finished() -> void:
	_check_quest_chain(_scouts_quest, "Wren")


func _on_thessa_finished() -> void:
	_check_quest_chain(_elder_quest, "Elder Thessa")


func _check_quest_chain(
	quest_data: Resource,
	speaker: String,
) -> void:
	if quest_data == null:
		return
	var qid: StringName = quest_data.id

	if QuestManager.is_quest_completed(qid):
		return

	if QuestManager.is_quest_active(qid):
		if _is_turnin_ready(qid):
			_do_quest_turnin(qid, quest_data, speaker)
		else:
			var reminder := Quests.get_quest_reminder(qid)
			if not reminder.is_empty():
				var lines: Array[DialogueLine] = [
					DialogueLine.create(speaker, reminder),
				]
				DialogueManager.start_dialogue(lines)
		return

	if not _can_offer_quest(qid, quest_data):
		return

	# Show quest offer with Accept/Decline choice
	var offer_text := Quests.get_quest_offer(qid)
	if offer_text.is_empty():
		return
	var offer_line := DialogueLine.create(
		speaker, offer_text, null,
		["Accept", "Decline"] as Array[String],
	)

	var accepted := false
	DialogueManager.choice_selected.connect(
		func(index: int) -> void: accepted = (index == 0),
		CONNECT_ONE_SHOT,
	)
	DialogueManager.start_dialogue([offer_line])
	await DialogueManager.dialogue_ended

	if accepted:
		QuestManager.accept_quest(quest_data)
		var accept_text := Quests.get_quest_accept(qid)
		if not accept_text.is_empty():
			var lines: Array[DialogueLine] = [
				DialogueLine.create(speaker, accept_text),
			]
			DialogueManager.start_dialogue(lines)


func _do_quest_turnin(
	qid: StringName,
	quest_data: Resource,
	speaker: String,
) -> void:
	var turnin_text := Quests.get_quest_turnin(qid)
	if turnin_text.is_empty():
		return
	var lines: Array[DialogueLine] = [
		DialogueLine.create(speaker, turnin_text),
	]
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	# Complete the final objective (turn-in) — auto-completes quest
	var objectives := QuestManager.get_objective_status(qid)
	if not objectives.is_empty():
		QuestManager.complete_objective(qid, objectives.size() - 1)

	# Grant gold reward
	if quest_data.reward_gold > 0:
		InventoryManager.add_gold(quest_data.reward_gold)


static func _is_turnin_ready(qid: StringName) -> bool:
	var objectives := QuestManager.get_objective_status(qid)
	if objectives.is_empty():
		return false
	if objectives.back():
		return false
	for i in objectives.size() - 1:
		if not objectives[i]:
			return false
	return true


static func _can_offer_quest(
	qid: StringName,
	quest_data: Resource,
) -> bool:
	if not QuestManager.can_accept_quest(quest_data):
		return false
	match qid:
		&"herb_gathering", &"elder_wisdom":
			return EventFlags.has_flag("opening_lyra_discovered")
	return true


func _spawn_zone_marker() -> void:
	var marker := ZoneMarker.new()
	marker.direction = ZoneMarker.Direction.LEFT
	marker.marker_color = ZoneMarker.DEFAULT_COLOR
	marker.destination_name = "Verdant Forest"
	marker.position = _exit_to_forest.position + Vector2(12, 0)
	add_child(marker)


static func _compute_quest_indicator(
	quest_id: StringName,
) -> NPC.IndicatorType:
	if QuestManager.is_quest_completed(quest_id):
		return NPC.IndicatorType.CHAT
	if QuestManager.is_quest_active(quest_id):
		return NPC.IndicatorType.QUEST_ACTIVE
	return NPC.IndicatorType.QUEST


func _setup_npc_dialogue() -> void:
	var flags := EventFlags.get_all_flags()

	var innkeeper: StaticBody2D = $Entities/InnkeeperNPC
	if innkeeper:
		innkeeper.npc_name = "Maren"
		innkeeper.dialogue_lines = Dialogue.get_maren_dialogue(
			flags,
		)
		innkeeper.indicator_type = NPC.IndicatorType.CHAT

	var shopkeeper: StaticBody2D = $Entities/ShopkeeperNPC
	if shopkeeper:
		shopkeeper.npc_name = "Bram"
		shopkeeper.dialogue_lines = Dialogue.get_bram_dialogue(
			flags,
		)
		shopkeeper.indicator_type = NPC.IndicatorType.SHOP

	var elder: StaticBody2D = $Entities/TownfolkNPC1
	if elder:
		elder.npc_name = "Elder Thessa"
		elder.dialogue_lines = Dialogue.get_thessa_dialogue(
			flags,
		)
		elder.indicator_type = _compute_quest_indicator(
			&"elder_wisdom",
		)

	var scout: StaticBody2D = $Entities/TownfolkNPC2
	if scout:
		scout.npc_name = "Wren"
		scout.dialogue_lines = Dialogue.get_wren_dialogue(flags)
		scout.indicator_type = _compute_quest_indicator(
			&"scouts_report",
		)

	if _garrick_npc and _garrick_npc.visible:
		_garrick_npc.dialogue_lines = (
			Dialogue.get_garrick_casual_dialogue(flags)
		)
		_garrick_npc.indicator_type = NPC.IndicatorType.CHAT

	var lina: StaticBody2D = $Entities/LinaNPC
	if lina:
		lina.npc_name = "Lina"
		lina.dialogue_lines = Dialogue.get_lina_dialogue(flags)
		lina.indicator_type = NPC.IndicatorType.CHAT
