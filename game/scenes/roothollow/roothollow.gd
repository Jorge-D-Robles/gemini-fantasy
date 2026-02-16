extends Node2D

## Roothollow — safe town hub. No random encounters.
## Features NPCs (innkeeper, shopkeeper, townfolk), Garrick recruitment,
## a save point, and an exit to the Verdant Forest.

const VERDANT_FOREST_PATH: String = (
	"res://scenes/verdant_forest/verdant_forest.tscn"
)

# -- Ground: 8 clean grass variants from A5_A row 0 --
const GROUND_LEGEND: Dictionary = {
	"G": Vector2i(0, 0), "g": Vector2i(1, 0),
	"H": Vector2i(2, 0), "h": Vector2i(3, 0),
	"I": Vector2i(4, 0), "i": Vector2i(5, 0),
	"J": Vector2i(6, 0), "j": Vector2i(7, 0),
}

# -- Paths: 6 stone walkway variants from A5_A rows 10-11 --
const PATH_LEGEND: Dictionary = {
	"S": Vector2i(0, 10), "s": Vector2i(1, 10),
	"P": Vector2i(2, 10), "p": Vector2i(3, 10),
	"Q": Vector2i(4, 10), "q": Vector2i(5, 10),
}

# -- Detail: 4 flower/foliage accents from A5_A row 14 --
const DETAIL_LEGEND: Dictionary = {
	"f": Vector2i(0, 14), "F": Vector2i(1, 14),
	"b": Vector2i(2, 14), "B": Vector2i(3, 14),
}

# Block-rotation constants: 6 blocks of 8 chars = 48 cols per row
const _B0: String = "GhIgjHiG"
const _B1: String = "jIHgGhiJ"
const _B2: String = "hGjIiHgJ"
const _B3: String = "IgHjGiJh"
const _B4: String = "gJhIjGHi"
const _B5: String = "HiGjhJgI"

# 48 cols x 38 rows — all grass, block-rotated for variety
const GROUND_MAP: Array[String] = [
	_B0 + _B1 + _B2 + _B3 + _B4 + _B5,
	_B3 + _B5 + _B0 + _B4 + _B1 + _B2,
	_B1 + _B2 + _B4 + _B5 + _B3 + _B0,
	_B5 + _B0 + _B3 + _B1 + _B2 + _B4,
	_B2 + _B4 + _B1 + _B0 + _B5 + _B3,
	_B4 + _B3 + _B5 + _B2 + _B0 + _B1,
	_B0 + _B5 + _B2 + _B3 + _B4 + _B1,
	_B3 + _B1 + _B4 + _B5 + _B0 + _B2,
	_B2 + _B0 + _B3 + _B4 + _B1 + _B5,
	_B5 + _B4 + _B0 + _B1 + _B2 + _B3,
	_B1 + _B3 + _B5 + _B2 + _B4 + _B0,
	_B4 + _B2 + _B1 + _B0 + _B3 + _B5,
	_B0 + _B4 + _B3 + _B5 + _B1 + _B2,
	_B3 + _B0 + _B2 + _B4 + _B5 + _B1,
	_B5 + _B1 + _B4 + _B3 + _B0 + _B2,
	_B2 + _B5 + _B0 + _B1 + _B3 + _B4,
	_B4 + _B3 + _B1 + _B2 + _B5 + _B0,
	_B1 + _B2 + _B5 + _B0 + _B4 + _B3,
	_B0 + _B3 + _B4 + _B2 + _B1 + _B5,
	_B3 + _B5 + _B1 + _B4 + _B2 + _B0,
	_B5 + _B0 + _B2 + _B1 + _B3 + _B4,
	_B2 + _B4 + _B3 + _B5 + _B0 + _B1,
	_B4 + _B1 + _B0 + _B3 + _B5 + _B2,
	_B1 + _B2 + _B5 + _B4 + _B0 + _B3,
	_B0 + _B5 + _B3 + _B2 + _B4 + _B1,
	_B3 + _B0 + _B4 + _B1 + _B2 + _B5,
	_B5 + _B4 + _B1 + _B0 + _B3 + _B2,
	_B2 + _B1 + _B0 + _B3 + _B5 + _B4,
	_B4 + _B3 + _B2 + _B5 + _B1 + _B0,
	_B1 + _B5 + _B4 + _B0 + _B2 + _B3,
	_B0 + _B2 + _B3 + _B4 + _B5 + _B1,
	_B3 + _B4 + _B5 + _B2 + _B0 + _B1,
	_B5 + _B1 + _B0 + _B3 + _B4 + _B2,
	_B2 + _B3 + _B1 + _B5 + _B0 + _B4,
	_B4 + _B0 + _B2 + _B1 + _B3 + _B5,
	_B1 + _B5 + _B4 + _B0 + _B2 + _B3,
	_B0 + _B2 + _B5 + _B4 + _B1 + _B3,
	_B3 + _B4 + _B0 + _B1 + _B5 + _B2,
]

# Stone walkways: main E-W road, N-S road, plaza, building approaches
# Rows 11-12 (y=176-192): main east-west road
# Cols 19-21 (x=304-336): north-south road
# Cols 17-23, rows 14-17: central plaza around save point
# Inn approach: cols 7-10, rows 5-7
# Shop approach: cols 25-28, rows 5-7
const PATH_MAP: Array[String] = [
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"       SsPp                   QqSs              ",
	"       pQqS                   sPpQ              ",
	"       SspP                   QsPq              ",
	"                   SsP                          ",
	"                   pQq                          ",
	"                   SsP                          ",
	" SsPpQqSsPpQqSsPpQqSsPpQqSsPpQqSsPpQqSs        ",
	" pQqSsPpQqSsPpQqSsPpQqSsPpQqSsPpQqSsPp        ",
	"                   SsP                          ",
	"                 QqSsPpQq                       ",
	"                 SsPpQqSs                       ",
	"                 pQqSsPpQ                       ",
	"                 QqSsPpQq                       ",
	"                   SsP                          ",
	"                   pQq                          ",
	"                   SsP                          ",
	"                   pQq                          ",
	"                   SsP                          ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
]

# Sparse flowers on open grass, avoiding roads/buildings/NPCs
const DETAIL_MAP: Array[String] = [
	"                                                ",
	"   f                  B              b          ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"  B                                     f       ",
	"                                                ",
	"                                                ",
	"      f                          b              ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"                                                ",
	"  f                                       B     ",
	"                                                ",
	"                                                ",
	"        B                                       ",
	"                                 f              ",
	"                                                ",
	"                                                ",
	"   b                      f                     ",
	"                                                ",
	"                                                ",
	"                                          b     ",
	"                                                ",
	"          F                    B                ",
	"                                                ",
	"                                                ",
	"    b                                           ",
	"                                                ",
	"                                                ",
]

@onready var _ground: TileMapLayer = $Ground
@onready var _paths: TileMapLayer = $Paths
@onready var _ground_detail: TileMapLayer = $GroundDetail
@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_from_forest: Marker2D = $Entities/SpawnFromForest
@onready var _exit_to_forest: Area2D = $Triggers/ExitToForest
@onready var _garrick_zone: Area2D = $Triggers/GarrickRecruitZone
@onready var _garrick_event: GarrickRecruitment = $GarrickRecruitment
@onready var _garrick_npc: StaticBody2D = $Entities/GarrickNPC


func _ready() -> void:
	_setup_tilemap()
	UILayer.hud.location_name = "Roothollow"

	# Add spawn point to group for GameManager lookup
	_spawn_from_forest.add_to_group("spawn_from_forest")

	# Connect triggers
	_exit_to_forest.body_entered.connect(_on_exit_to_forest_entered)
	_garrick_zone.body_entered.connect(_on_garrick_zone_entered)

	# Connect innkeeper special interaction
	var innkeeper: StaticBody2D = $Entities/InnkeeperNPC
	if innkeeper:
		innkeeper.interaction_ended.connect(_on_innkeeper_finished)

	# Hide Garrick recruitment zone if already recruited
	if EventFlags.has_flag(GarrickRecruitment.FLAG_NAME):
		_garrick_zone.monitoring = false
		_garrick_npc.visible = false
		_garrick_npc.process_mode = Node.PROCESS_MODE_DISABLED

	# Set flag-reactive NPC dialogue
	_setup_npc_dialogue()


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [MapBuilder.FAIRY_FOREST_A5_A]
	MapBuilder.apply_tileset(
		[_ground, _paths, _ground_detail] as Array[TileMapLayer],
		atlas_paths,
	)
	MapBuilder.build_layer(_ground, GROUND_MAP, GROUND_LEGEND)
	MapBuilder.build_layer(_paths, PATH_MAP, PATH_LEGEND)
	MapBuilder.build_layer(
		_ground_detail, DETAIL_MAP, DETAIL_LEGEND,
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
			"Innkeeper",
			"Rest well. Your party has been fully restored.",
		),
	]
	DialogueManager.start_dialogue(heal_lines)


func _setup_npc_dialogue() -> void:
	var flags := EventFlags.get_all_flags()

	var innkeeper: StaticBody2D = $Entities/InnkeeperNPC
	if innkeeper:
		innkeeper.npc_name = "Maren"
		innkeeper.dialogue_lines = get_maren_dialogue(flags)

	var shopkeeper: StaticBody2D = $Entities/ShopkeeperNPC
	if shopkeeper:
		shopkeeper.npc_name = "Bram"
		shopkeeper.dialogue_lines = get_bram_dialogue(flags)

	var elder: StaticBody2D = $Entities/TownfolkNPC1
	if elder:
		elder.npc_name = "Elder Thessa"
		elder.dialogue_lines = get_thessa_dialogue(flags)

	var scout: StaticBody2D = $Entities/TownfolkNPC2
	if scout:
		scout.npc_name = "Wren"
		scout.dialogue_lines = get_wren_dialogue(flags)

	if _garrick_npc and _garrick_npc.visible:
		_garrick_npc.dialogue_lines = (
			get_garrick_casual_dialogue(flags)
		)

	var lina: StaticBody2D = $Entities/LinaNPC
	if lina:
		lina.npc_name = "Lina"
		lina.dialogue_lines = get_lina_dialogue(flags)


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
