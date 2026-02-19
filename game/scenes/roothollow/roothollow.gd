extends Node2D

## Roothollow — safe town hub with mushroom village buildings.
## No random encounters. Features NPCs (innkeeper, shopkeeper,
## townfolk), Garrick recruitment, save point, exit to Verdant Forest.
## Tilemap data is in roothollow_maps.gd (Maps).

const Maps = preload("roothollow_maps.gd")

const VERDANT_FOREST_PATH: String = (
	"res://scenes/verdant_forest/verdant_forest.tscn"
)
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

# Quest dialogue text keyed by quest id and phase
const _QUEST_TEXT: Dictionary = {
	&"herb_gathering": {
		"offer": "One more thing — I need medicinal herbs"
			+ " from the Verdant Forest. The village supply"
			+ " is running dangerously low."
			+ " Would you gather some for me?",
		"accept": "Thank you, dear! Look for forest herbs"
			+ " growing near the clearings. I'll need three.",
		"reminder": "Any luck finding those herbs"
			+ " in the Verdant Forest?",
		"turnin": "You found them! These will keep the"
			+ " village healthy for weeks."
			+ " Take this as thanks.",
	},
	&"scouts_report": {
		"offer": "Actually — I have a job for you. Strange"
			+ " creatures keep emerging near the ruins."
			+ " I need someone to investigate and clear"
			+ " the area. Interested?",
		"accept": "Good. Head to the Overgrown Ruins, see"
			+ " what's stirring, and deal with any threats."
			+ " Report back when it's done.",
		"reminder": "How's the scouting mission going?"
			+ " Clear those creatures near the ruins"
			+ " and report back.",
		"turnin": "Solid work. The intelligence will help"
			+ " us keep Roothollow safe."
			+ " Here's your payment.",
	},
	&"elder_wisdom": {
		"offer": "Before you go — there is something I"
			+ " need. An Echo Fragment at the old village"
			+ " memorial in the Verdant Forest. It holds"
			+ " memories of Roothollow's founding."
			+ " Would you retrieve it for me?",
		"accept": "The memorial is south of the main path"
			+ " in the forest, near a cluster of stones."
			+ " Be careful — echoes there may be restless.",
		"reminder": "Have you found the memorial Echo in"
			+ " the Verdant Forest? It's near a cluster"
			+ " of stones south of the main path.",
		"turnin": "You brought it... The memories within"
			+ " are extraordinary. These are the voices"
			+ " of Roothollow's founders."
			+ " Here — you've earned this.",
	},
}

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
		VERDANT_FOREST_PATH,
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
			var reminder := _get_quest_reminder(qid)
			if not reminder.is_empty():
				var lines: Array[DialogueLine] = [
					DialogueLine.create(speaker, reminder),
				]
				DialogueManager.start_dialogue(lines)
		return

	if not _can_offer_quest(qid, quest_data):
		return

	# Show quest offer with Accept/Decline choice
	var offer_text := _get_quest_offer(qid)
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
		var accept_text := _get_quest_accept(qid)
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
	var turnin_text := _get_quest_turnin(qid)
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


static func _get_quest_offer(qid: StringName) -> String:
	return _QUEST_TEXT.get(qid, {}).get("offer", "")


static func _get_quest_accept(qid: StringName) -> String:
	return _QUEST_TEXT.get(qid, {}).get("accept", "")


static func _get_quest_reminder(qid: StringName) -> String:
	return _QUEST_TEXT.get(qid, {}).get("reminder", "")


static func _get_quest_turnin(qid: StringName) -> String:
	return _QUEST_TEXT.get(qid, {}).get("turnin", "")


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
		innkeeper.dialogue_lines = get_maren_dialogue(flags)
		innkeeper.indicator_type = NPC.IndicatorType.CHAT

	var shopkeeper: StaticBody2D = $Entities/ShopkeeperNPC
	if shopkeeper:
		shopkeeper.npc_name = "Bram"
		shopkeeper.dialogue_lines = get_bram_dialogue(flags)
		shopkeeper.indicator_type = NPC.IndicatorType.SHOP

	var elder: StaticBody2D = $Entities/TownfolkNPC1
	if elder:
		elder.npc_name = "Elder Thessa"
		elder.dialogue_lines = get_thessa_dialogue(flags)
		elder.indicator_type = _compute_quest_indicator(
			&"elder_wisdom",
		)

	var scout: StaticBody2D = $Entities/TownfolkNPC2
	if scout:
		scout.npc_name = "Wren"
		scout.dialogue_lines = get_wren_dialogue(flags)
		scout.indicator_type = _compute_quest_indicator(
			&"scouts_report",
		)

	if _garrick_npc and _garrick_npc.visible:
		_garrick_npc.dialogue_lines = (
			get_garrick_casual_dialogue(flags)
		)
		_garrick_npc.indicator_type = NPC.IndicatorType.CHAT

	var lina: StaticBody2D = $Entities/LinaNPC
	if lina:
		lina.npc_name = "Lina"
		lina.dialogue_lines = get_lina_dialogue(flags)
		lina.indicator_type = NPC.IndicatorType.CHAT


# -- Flag-reactive dialogue helpers (static for testability) --


static func get_maren_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"Old Iron himself, traveling with my favorite Echo"
			+ " hunter. Now that's a sight.",
			"Garrick used to pass through years ago. Always"
			+ " ordered the same thing \u2014 black tea, no sugar."
			+ " Sat in the corner and watched the door.",
			"He's a good man, Kael. Whatever he's running from,"
			+ " he's running toward something better now.",
			"You take care of each other out there."
			+ " And come back for stew when you can.",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"So you've brought company! A soldier, by the look"
			+ " of her. Or... former soldier?",
			"Don't worry, I don't pry. Anyone who fights"
			+ " alongside Kael is welcome at my table.",
			"That arm of hers... Resonance-powered, isn't it?"
			+ " Haven't seen Initiative tech this far east"
			+ " in years.",
			"I'll set out extra bowls."
			+ " You all look like you could use a real meal.",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"There you are! Half the village was worried sick."
			+ " You were gone longer than usual.",
			"You found something in the ruins?"
			+ " Something... alive?",
			"I won't pretend to understand echoes the way you"
			+ " do. But if this one can speak,"
			+ " that changes things.",
			"The world's been holding its breath for three"
			+ " hundred years, Kael."
			+ " Maybe it's finally ready to exhale.",
			"Rest here tonight. Whatever comes next,"
			+ " you'll face it better on a full stomach.",
		])
	return PackedStringArray([
		"Kael! Come in, come in. You look like you haven't"
		+ " eaten since yesterday. ...You haven't, have you?",
		"The stew's still warm."
		+ " Sit down before you fall down.",
		"I heard you're heading out to the old ruins again."
		+ " Please be careful."
		+ " The echoes have been stranger lately.",
		"A trader from Prismfall passed through last week."
		+ " Said the roads south are crawling with corrupted"
		+ " creatures. Stay close to the forest paths,"
		+ " will you?",
	])


static func get_bram_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"Garrick Thorne is with you?"
			+ " THE Garrick Thorne?"
			+ " The man's a legend around here.",
			"He saved a caravan from crystal-corrupted wolves"
			+ " ten years back. Single-handedly held the pass"
			+ " while they escaped.",
			"If he's decided to travel with you, then whatever"
			+ " you're doing must be important."
			+ " Or incredibly dangerous. ...Or both.",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"Your new friend... she's from the Ironcoast,"
			+ " isn't she? I can tell by the armor.",
			"N-not that there's anything wrong with that!"
			+ " The Federation makes good gear."
			+ " Very reliable. Very... heavily armed.",
			"Actually, if she has any contacts in the supply"
			+ " chain, I'd love an introduction."
			+ " Strictly business!",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"Everyone's talking about what you found in the"
			+ " ruins. A conscious echo?"
			+ " That's... that's not supposed to happen,"
			+ " is it?",
			"I don't like it, Kael. Change is coming, and"
			+ " change is bad for business."
			+ " Change is bad for everything.",
			"The caravan still hasn't arrived."
			+ " I'm starting to think something happened"
			+ " on the road.",
			"If you run into any traders out there, tell them"
			+ " Roothollow is paying double for medical"
			+ " supplies. Triple, even. I don't care.",
		])
	return PackedStringArray([
		"Oh, Kael. Good timing. Well... actually,"
		+ " terrible timing.",
		"The supply caravan from Prismfall is three days"
		+ " late. Three days!"
		+ " That's never happened before.",
		"I've got some basic provisions left, but the good"
		+ " equipment? Gone. Bought up by a group of"
		+ " hunters heading south.",
		"If you're heading to the ruins, I can spare a"
		+ " couple of salves."
		+ " It's not much, but it's what I've got.",
	])


static func get_thessa_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"A conscious Echo, and now Garrick Thorne at your"
			+ " side. The winds of change blow faster than"
			+ " I expected.",
			"The Council at Prismfall must hear about this."
			+ " A conscious Echo changes everything we"
			+ " thought we knew about the Severance.",
			"The road south is dangerous \u2014 corrupted beasts,"
			+ " Shepherd patrols, and worse."
			+ " But you have allies now.",
			"An Echo hunter, an engineer, and a penitent"
			+ " knight. The echoes brought you together for a"
			+ " reason. Trust that.",
			"Go, Kael. Prismfall awaits. And when the path"
			+ " divides, trust each other more than you trust"
			+ " the world. This is only the beginning.",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"An Initiative deserter."
			+ " Interesting company you're keeping.",
			"Don't look surprised \u2014 I recognize the armor"
			+ " modifications. She's stripped the insignias,"
			+ " but the alloy is unmistakable."
			+ " Gearhaven titanium-crystal composite.",
			"The fact that she left the Initiative tells me"
			+ " more about her character than anything she"
			+ " could say. It takes courage to walk away"
			+ " from power.",
			"But be careful. The Initiative doesn't let its"
			+ " assets go quietly. If they're looking for"
			+ " her, they may eventually look here.",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"A conscious echo. I've read theories... fragments"
			+ " of old research papers recovered from the"
			+ " capital. But I never believed it possible.",
			"Do you know what this means, Kael? Echoes are"
			+ " crystallized memory \u2014 fragments of lives"
			+ " lived and lost. If one has achieved"
			+ " consciousness...",
			"...then the boundary between what was and what"
			+ " is may be thinner than we thought.",
			"The Shepherds of Silence would destroy her on"
			+ " sight. The Reclamation Initiative would cage"
			+ " her and study her."
			+ " Neither can learn of this.",
			"Protect her, Kael. And listen to what she has to"
			+ " say. The dead don't speak without reason.",
		])
	return PackedStringArray([
		"Ah, Kael. I was wondering when you'd visit."
		+ " The crystals in my study have been humming"
		+ " all morning.",
		"You're heading to the ruins again. I can see it"
		+ " in your eyes \u2014 that restless look you get"
		+ " when the echoes call.",
		"Before you go, a word of caution. The echoes in"
		+ " the old capital have been... different lately."
		+ " More coherent. Almost purposeful.",
		"In all my years studying Resonance, I've never"
		+ " felt anything like it. It's as if something"
		+ " buried is trying to wake up.",
		"Trust your instincts out there. You've always had"
		+ " an unusual connection to the echoes."
		+ " That's a gift, not a curse.",
	])


static func get_wren_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"I know Garrick by reputation. Twenty years of"
			+ " guarding trade routes, purifying corrupted"
			+ " zones, the whole legend.",
			"With him, Iris, and you? You might actually"
			+ " survive what's out there."
			+ " High praise from me.",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"Your new companion handles herself well."
			+ " I watched her take down a crystal-shard"
			+ " serpent near the forest edge without"
			+ " breaking stride.",
			"That arm of hers packs a punch. Literally."
			+ " The serpent didn't know what hit it.",
			"Good. You're going to need someone who can"
			+ " fight. The creatures between here and the"
			+ " ruins aren't getting any friendlier.",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"You came back from the ruins looking like you'd"
			+ " seen a ghost."
			+ " Or... whatever's worse than a ghost.",
			"Look, I don't need details. But if something's"
			+ " changing in there, I need to know."
			+ " My job is keeping this village safe.",
			"The Verdant Forest has been restless since you"
			+ " got back. More echo activity, more corrupted"
			+ " beasts. Like something stirred them up.",
			"If you're going out again, stick to the main"
			+ " paths. And maybe bring a friend or two.",
		])
	return PackedStringArray([
		"Heading out? The western trail's clear, but I"
		+ " wouldn't stray too far south. Saw tracks.",
		"Big ones. Not wolves. Something... wrong."
		+ " Crystal growths where the paw prints"
		+ " should be.",
		"The forest is getting worse. Used to be you'd"
		+ " see a corrupted creature once a month."
		+ " Now it's every other day.",
	])


static func get_garrick_casual_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"Word travels fast in a small village."
			+ " You found something unusual in the ruins.",
			"A conscious echo... I once served people who"
			+ " would have called that an abomination."
			+ " I've since learned not to trust their"
			+ " definitions.",
			"You're in over your head, kid. No offense."
			+ " What you've found \u2014 it'll attract attention."
			+ " The kind that arrives with swords drawn.",
			"If I were you, I'd find allies. Real ones."
			+ " Not the kind who smile when they want"
			+ " something.",
		])
	return PackedStringArray([
		"Hmm. You're young for an Echo hunter. Then again,"
		+ " the young ones are usually the bravest."
		+ " Or the most foolish.",
		"Don't take that the wrong way."
		+ " I've been both in my time.",
		"This village... it's peaceful. Reminds me of"
		+ " places that don't exist anymore."
		+ " Enjoy it while it lasts.",
	])


static func get_lina_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"The big man with the shield told me a story"
			+ " about a knight who fought a dragon made"
			+ " of memories!",
			"He's kinda scary but also kinda nice."
			+ " Like a grumpy grandpa.",
			"Are you going on an adventure? A REAL adventure?"
			+ " Bring me back something cool!",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"Your friend has a SHINY ARM!"
			+ " Is it made of crystal? Can I touch it?",
			"She said maybe later."
			+ " That's grown-up talk for no, isn't it?",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"Everyone's acting all serious today."
			+ " Did something happen?",
			"My pretty rock started glowing last night!"
			+ " Just for a second. Then it stopped.",
			"Mama told me to throw it away, but I hid it"
			+ " under my pillow instead."
			+ " Don't tell, okay?",
		])
	return PackedStringArray([
		"Kael! Kael! Look what I found by the river!",
		"It's a pretty rock. See how it shines? Mama says"
		+ " it's just quartz, but I think it's an echo."
		+ " A tiny one.",
		"When I hold it up to my ear, I can almost hear"
		+ " someone singing. Is that weird?",
		"When I grow up, I want to be an Echo hunter like"
		+ " you! I'll have a big journal and everything!",
	])


# -- Quest logic helpers (static / pure for testability) --


static func should_offer_quest(
	quest_id: StringName,
	active_ids: Array,
	completed_ids: Array,
) -> bool:
	if quest_id in active_ids:
		return false
	if quest_id in completed_ids:
		return false
	return true


static func can_complete_herb_quest(herb_count: int) -> bool:
	return herb_count >= 3


static func can_complete_elder_quest(
	obj_status: Array,
) -> bool:
	return (
		obj_status.size() >= 2
		and obj_status[0]
		and not obj_status[1]
	)


static func can_complete_scouts_quest(
	ruins_visited: bool,
) -> bool:
	return ruins_visited


static func get_quest_offer_lines(
	qid: StringName,
) -> PackedStringArray:
	return PackedStringArray([_get_quest_offer(qid)])


static func get_quest_complete_lines(
	qid: StringName,
) -> PackedStringArray:
	return PackedStringArray([_get_quest_turnin(qid)])
