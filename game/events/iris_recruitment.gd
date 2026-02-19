class_name IrisRecruitment
extends Node

## Iris recruitment event in the Verdant Forest.
## Triggers a cutscene, a forced battle, then Iris joins the party.
## Dialogue matches Chapter 3 ("The Deserter") of the story script
## (docs/story/act1/03-the-deserter.md), adapting Option B (Kael
## intervenes directly). After the battle, Iris joins the party.

signal sequence_completed

const FLAG_NAME: String = "iris_recruited"
const IRIS_DATA_PATH: String = "res://data/characters/iris.tres"
const ASH_STALKER_PATH: String = "res://data/enemies/ash_stalker.tres"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var pre_battle_lines: Array[DialogueLine] = _build_pre_battle_dialogue()

	DialogueManager.start_dialogue(pre_battle_lines)
	await DialogueManager.dialogue_ended

	# Add Iris to party before battle so she participates
	var iris_data := load(IRIS_DATA_PATH) as Resource
	if iris_data:
		PartyManager.add_character(iris_data)

	GameManager.pop_state()

	# Start forced battle with 2 Ash Stalkers.
	# Register a ONE_SHOT callback on BattleManager.battle_ended so that
	# post-battle dialogue runs even though this node is freed during the
	# scene change. The callback is a static-like lambda that only
	# references autoloads (which survive scene changes).
	var ash_stalker := load(ASH_STALKER_PATH) as Resource
	if ash_stalker:
		var enemy_group: Array[Resource] = [ash_stalker, ash_stalker]
		BattleManager.battle_ended.connect(
			_on_iris_battle_ended, CONNECT_ONE_SHOT,
		)
		BattleManager.start_battle(enemy_group, false)
	else:
		# If enemy data failed to load, skip battle and finish
		_play_post_battle_dialogue()


func _build_pre_battle_dialogue() -> Array[DialogueLine]:
	return [
		# Iris mid-fight, talking to herself
		DialogueLine.create(
			"Iris",
			"Hah! These things just keep coming!",
		),
		DialogueLine.create(
			"Iris",
			"Two ranged, one melee, one tech. Three exits."
			+ " Come on, Iris, worse odds than this.",
		),

		# Kael intervenes — sees a flanking swordsman
		DialogueLine.create(
			"Kael",
			"Behind you!",
		),
		DialogueLine.create(
			"Iris",
			"Who the hell--? ...Never mind. Left flank,"
			+ " take the rifle!",
		),
		DialogueLine.create(
			"Kael",
			"I-- okay!",
		),

		# Iris takes command
		DialogueLine.create(
			"Iris",
			"Move when I move. And keep your guard up"
			+ " -- you left your whole left side open.",
		),
		DialogueLine.create(
			"Iris",
			"On three. One-- forget it, just go!",
		),
	]


static func _on_iris_battle_ended(victory: bool) -> void:
	if not victory:
		# On defeat, clear the flag so the event can re-trigger
		EventFlags.clear_flag(FLAG_NAME)
		return
	_play_post_battle_dialogue()


static func _play_post_battle_dialogue() -> void:
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var post_battle_lines: Array[DialogueLine] = _build_post_battle_lines()

	DialogueManager.start_dialogue(post_battle_lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()


static func _build_post_battle_lines() -> Array[DialogueLine]:
	return [
		# Aftermath urgency — Iris counts exits, needs to move
		DialogueLine.create(
			"Iris",
			"Three exits. We came from the south. They"
			+ " came from the north -- that's where their"
			+ " camp is. We're going east. Now.",
		),
		DialogueLine.create(
			"Kael",
			"I-- hi. I'm Kael.",
		),
		DialogueLine.create(
			"Iris",
			"Great. Can you run? Their reinforcements"
			+ " don't bluff. Ten minutes, maybe less.",
		),

		# Identity reveal — rapid-fire, military cadence
		DialogueLine.create(
			"Iris",
			"Iris Mantle. Former Lieutenant, Reclamation"
			+ " Initiative Engineering Corps. 'Former' being"
			+ " the word that matters.",
		),
		DialogueLine.create(
			"Iris",
			"They're in the Tangle hunting Resonance"
			+ " anomalies. Consciousness indicators. I know"
			+ " what they do with the ones they find, and"
			+ " they'd prefer I stopped breathing.",
		),

		# Resonance Cage reveal
		DialogueLine.create(
			"Kael",
			"What do they do with them?",
		),
		DialogueLine.create(
			"Iris",
			"Feed them into something called the Resonance"
			+ " Cage. Director Vex's project. Every conscious"
			+ " fragment they've found in five years -- gone."
			+ " Consumed like fuel.",
		),
		DialogueLine.create(
			"Iris",
			"I built the extraction tools. Helped them find"
			+ " those fragments. Then I walked into the wrong"
			+ " lab and saw what happened next.",
		),
		# Dane foreshadowing
		DialogueLine.create(
			"Iris",
			"Took what data I could and ran. Left my brother"
			+ " Dane behind with those people.",
		),

		# Kael reveals Lyra — direct, no setup
		DialogueLine.create(
			"Kael",
			"Iris. I found a conscious Echo. In the south"
			+ " ruins. Her name is Lyra. She's alive.",
		),
		DialogueLine.create(
			"Iris",
			"...You found one. A real-- the Initiative's"
			+ " sensors will pick her up. They're surveying"
			+ " this sector. We need to get to her first.",
		),

		# Iris joins — pragmatic, not sentimental
		DialogueLine.create(
			"Iris",
			"Also -- no offense, but you fight like someone"
			+ " who learned from a book. You need someone"
			+ " watching your back who knows which end of a"
			+ " rifle goes forward.",
		),
	]
