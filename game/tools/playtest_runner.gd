extends Node2D

## Automated playtest runner for full-state integration testing.
##
## Boots the game with all autoloads initialized, injects configurable game
## state (party, flags, inventory, gold), loads a target scene alongside the
## runner (without replacing it), then executes a scripted action sequence,
## capturing screenshots and collecting errors throughout.
##
## IMPORTANT: The runner persists alongside the loaded scene. It is never freed
## by scene changes because it directly adds the target scene to root via
## root.add_child() rather than using get_tree().change_scene_to_file().
##
## Invocation:
##   godot --path game/ res://tools/playtest_runner.tscn \
##          -- --config=/tmp/playtest_config.json

const PlaytestConfig := preload("res://tools/playtest_config.gd")
const PlaytestCapture := preload("res://tools/playtest_capture.gd")
const PlaytestActions := preload("res://tools/playtest_actions.gd")

var _config: Dictionary = {}
var _options: Dictionary = {}
var _screenshots: Array = []
var _errors: Array = []
var _warnings: Array = []
var _log_lines: Array = []
var _capture_index: int = 1
var _actions_done: int = 0
var _start_time: float = 0.0
var _timeout_timer: float = 0.0
var _capture_interval_elapsed: float = 0.0
var _scene_loaded: bool = false
var _finishing: bool = false


func _ready() -> void:
	_start_time = Time.get_unix_time_from_system()
	var cli_args := OS.get_cmdline_user_args()
	var partial := PlaytestConfig.parse_cli_args(cli_args)

	# If --config= was provided, load and merge the JSON config.
	if partial.has("config_path"):
		var json_config := _load_config_file(partial["config_path"])
		# CLI args take precedence over file config.
		_config = PlaytestConfig.merge_defaults(
			_merge_partial_over(json_config, partial)
		)
	else:
		_config = PlaytestConfig.merge_defaults(partial)

	var errors := PlaytestConfig.validate(_config)
	if errors.size() > 0:
		push_error("PlaytestRunner: invalid config — " + ", ".join(errors))
		_finish(false)
		return

	_options = _config.get("options", {})
	var output_dir: String = _options.get("output_dir", "/tmp/playtest/")
	if not PlaytestCapture.ensure_output_dir(output_dir):
		push_error("PlaytestRunner: cannot create output dir '%s'" % output_dir)
		_finish(false)
		return

	if _options.get("disable_bgm", true):
		AudioManager.stop_bgm()

	# Inject state BEFORE scene loads so scene's _ready() sees it.
	_inject_state(_config.get("state", {}))

	# Load target scene by adding it to root alongside the runner.
	# We MUST NOT use change_scene_to_file() because that would free
	# the runner (it's the current_scene). Instead, we directly add
	# the target scene as a sibling child of root.
	var scene_path: String = _config.get("scene", "")
	var spawn_point: String = _config.get("spawn_point", "")
	var scene_ok := await _load_scene_direct(scene_path, spawn_point)
	if not scene_ok:
		_finish(false)
		return

	# Wait several frames for all deferred setup to complete.
	for _i in range(8):
		await get_tree().process_frame

	_scene_loaded = true
	_log("Scene loaded: %s" % scene_path)

	await _execute_actions(_config.get("actions", []))

	if not _finishing:
		_finish(true)


func _process(delta: float) -> void:
	if not _scene_loaded or _finishing:
		return

	# Timeout safety exit.
	_timeout_timer += delta
	var timeout: float = _options.get("timeout_seconds", 60.0)
	if _timeout_timer >= timeout:
		push_error("PlaytestRunner: timeout after %.1f seconds" % timeout)
		_errors.append("Timeout after %.1f seconds" % timeout)
		_finish(false)
		return

	# Periodic screenshot capture.
	var interval: float = _options.get("capture_interval_seconds", 0.0)
	if interval > 0.0:
		_capture_interval_elapsed += delta
		if _capture_interval_elapsed >= interval:
			_capture_interval_elapsed = 0.0


# --- Scene Loading ---

func _load_scene_direct(scene_path: String, spawn_point: String) -> bool:
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("PlaytestRunner: failed to load scene '%s'" % scene_path)
		_errors.append("Failed to load scene: %s" % scene_path)
		return false

	# Instantiate and add the scene to root without replacing the runner.
	# Use call_deferred so add_child runs after _ready() finishes (avoids
	# "parent node busy setting up children" error).
	var scene_instance: Node = packed.instantiate()
	get_tree().root.add_child.call_deferred(scene_instance)

	# Wait for the deferred add_child to execute.
	await get_tree().process_frame
	await get_tree().process_frame

	# Register as current_scene only if successfully parented to root.
	if scene_instance.get_parent() == get_tree().root:
		get_tree().current_scene = scene_instance

	# Notify autoloads that the scene changed.
	GameManager.scene_changed.emit(scene_path)

	# Apply spawn point if specified.
	if not spawn_point.is_empty():
		var player := get_tree().get_first_node_in_group("player")
		var marker := get_tree().get_first_node_in_group(spawn_point)
		if player and marker:
			player.global_position = marker.global_position

	return true


# --- State Injection ---

func _inject_state(state: Dictionary) -> void:
	_inject_party(state.get("party", []), state.get("party_levels", {}))
	_inject_inventory(state.get("inventory", {}))
	_inject_gold(state.get("gold", 0))
	_inject_flags(state.get("flags", []))
	_inject_equipment(state.get("equipment", {}))
	_inject_quests(state.get("quests", []))


func _inject_party(ids: Array, levels: Dictionary) -> void:
	for id: String in ids:
		var path := "res://data/characters/%s.tres" % id
		var data: Resource = load(path)
		if data == null:
			var msg := "character not found — %s" % path
			_warnings.append(msg)
			push_warning("PlaytestRunner: " + msg)
			continue
		PartyManager.add_character(data)

		if levels.has(id) and data is CharacterData:
			var char_data := data as CharacterData
			var target_level: int = levels[id]
			while char_data.level < target_level:
				var needed := LevelManager.xp_for_level(char_data.level + 1) \
						- char_data.current_xp + 1
				LevelManager.add_xp(char_data, needed)


func _inject_inventory(items: Dictionary) -> void:
	for item_id: String in items:
		InventoryManager.add_item(StringName(item_id), int(items[item_id]))


func _inject_gold(amount: int) -> void:
	if amount > 0:
		InventoryManager.add_gold(amount)


func _inject_flags(flags: Array) -> void:
	for flag: String in flags:
		EventFlags.set_flag(flag)


func _inject_equipment(equipment: Dictionary) -> void:
	for char_id: String in equipment:
		var slots: Dictionary = equipment[char_id]
		for slot_name: String in slots:
			var eq_id: String = slots[slot_name]
			var path := "res://data/equipment/%s.tres" % eq_id
			var eq_data: Resource = load(path)
			if eq_data == null:
				var msg := "equipment not found — %s" % path
				_warnings.append(msg)
				push_warning("PlaytestRunner: " + msg)
				continue
			EquipmentManager.equip(StringName(char_id), eq_data)


func _inject_quests(quest_ids: Array) -> void:
	for quest_id: String in quest_ids:
		var path := "res://data/quests/%s.tres" % quest_id
		var quest: Resource = load(path)
		if quest == null:
			var msg := "quest not found — %s" % path
			_warnings.append(msg)
			push_warning("PlaytestRunner: " + msg)
			continue
		QuestManager.accept_quest(quest)


# --- Action Execution ---

func _execute_actions(actions: Array) -> void:
	var total := actions.size()
	for i: int in range(total):
		if _finishing:
			break
		if _timeout_timer >= _options.get("timeout_seconds", 60.0):
			break
		var action: Dictionary = actions[i]
		await _execute_action(action)
		_actions_done += 1
		_log(
			"action %d/%d done — %s"
			% [i + 1, total, action.get("type", "?")]
		)


func _execute_action(action: Dictionary) -> void:
	var action_type: String = action.get("type", "")
	match action_type:
		"wait":
			await _wait_seconds(action.get("seconds", 1.0))
		"screenshot":
			await _do_screenshot(action.get("label", "capture"))
		"move":
			await _simulate_move(
				action.get("direction", "right"),
				action.get("seconds", 1.0)
			)
		"interact":
			await _simulate_input_press("interact")
		"cancel":
			await _simulate_input_press("cancel")
		"menu":
			await _simulate_input_press("menu")
		"advance_dialogue":
			await _advance_dialogue()
		"wait_dialogue":
			await _wait_dialogue(action.get("timeout", 10.0))
		"select_choice":
			_select_dialogue_choice(action.get("index", 0))
			await get_tree().process_frame
		"trigger_battle":
			await _trigger_battle(
				action.get("enemies", []),
				action.get("can_escape", true)
			)
		"wait_battle":
			await _wait_battle(action.get("timeout", 30.0))
		"auto_play_battle":
			await _execute_auto_play_battle(action)
		"wait_state":
			await _wait_state(
				action.get("state", "OVERWORLD"),
				action.get("timeout", 10.0)
			)
		"set_flag":
			EventFlags.set_flag(action.get("flag", ""))
		"log":
			_log(action.get("message", ""))
		_:
			var msg := "unknown action type '%s'" % action_type
			_warnings.append(msg)
			push_warning("PlaytestRunner: " + msg)


# --- Input Simulation ---

func _simulate_input_press(action_name: String) -> void:
	var press := InputEventAction.new()
	press.action = action_name
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := InputEventAction.new()
	release.action = action_name
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame


func _simulate_move(direction: String, duration: float) -> void:
	var action_name := "move_%s" % direction
	var press := InputEventAction.new()
	press.action = action_name
	press.pressed = true
	Input.parse_input_event(press)
	await _wait_seconds(duration)
	var release := InputEventAction.new()
	release.action = action_name
	release.pressed = false
	Input.parse_input_event(release)


# --- Dialogue Actions ---

func _advance_dialogue() -> void:
	DialogueManager.advance()
	await get_tree().process_frame


func _wait_dialogue(timeout: float) -> void:
	var elapsed := 0.0
	while DialogueManager.is_active() and elapsed < timeout:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	if elapsed >= timeout:
		var msg := "wait_dialogue timed out after %.1f seconds" % timeout
		_warnings.append(msg)
		push_warning("PlaytestRunner: " + msg)


func _select_dialogue_choice(index: int) -> void:
	DialogueManager.select_choice(index)


# --- Battle Actions ---

func _trigger_battle(enemy_ids: Array, can_escape: bool) -> void:
	var enemy_group: Array[Resource] = []
	for id: String in enemy_ids:
		var path := "res://data/enemies/%s.tres" % id
		var data: Resource = load(path)
		if data == null:
			var msg := "enemy not found for battle — %s" % path
			_warnings.append(msg)
			push_warning("PlaytestRunner: " + msg)
		else:
			enemy_group.append(data)

	if enemy_group.is_empty():
		var msg := "trigger_battle: no valid enemies loaded"
		_errors.append(msg)
		push_error("PlaytestRunner: " + msg)
		return

	BattleManager.start_battle(enemy_group, can_escape)
	await get_tree().process_frame


func _wait_battle(timeout: float) -> void:
	var elapsed := 0.0
	while BattleManager.is_in_battle() and elapsed < timeout:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	if elapsed >= timeout:
		var msg := "wait_battle timed out after %.1f seconds" % timeout
		_warnings.append(msg)
		push_warning("PlaytestRunner: " + msg)


## Auto-play a battle by issuing attack commands each player turn.
## Optionally triggers the battle if "enemies" field is provided.
## Logs the outcome (victory/defeat, player actions, final party HP).
func _execute_auto_play_battle(action: Dictionary) -> void:
	var timeout: float = action.get("timeout", 60.0)
	var enemy_ids: Array = action.get("enemies", [])
	var can_escape: bool = action.get("can_escape", false)

	# Optionally trigger a battle if enemies are specified.
	if not enemy_ids.is_empty():
		await _trigger_battle(enemy_ids, can_escape)
		await get_tree().process_frame

	# Wait for BattleManager to report an active battle.
	var wait := 0.0
	while not BattleManager.is_in_battle() and wait < 5.0:
		await get_tree().process_frame
		wait += get_process_delta_time()
	if not BattleManager.is_in_battle():
		_warnings.append("auto_play_battle: battle never started")
		return

	# Wait for the battle scene to become current_scene.
	var battle_scene: Node = null
	wait = 0.0
	while battle_scene == null and wait < 10.0:
		await get_tree().process_frame
		wait += get_process_delta_time()
		var candidate: Node = get_tree().current_scene
		if is_instance_valid(candidate) and \
				candidate.has_method("get_living_enemies"):
			battle_scene = candidate
	if battle_scene == null:
		var msg := "auto_play_battle: timed out waiting for battle scene"
		_errors.append(msg)
		push_error("PlaytestRunner: " + msg)
		return

	var battle_ui: Node = battle_scene.get_node_or_null("BattleUI")
	var state_machine: Node = battle_scene.get_node_or_null("BattleStateMachine")
	if battle_ui == null or state_machine == null:
		var msg := "auto_play_battle: BattleUI or BattleStateMachine missing"
		_errors.append(msg)
		push_error("PlaytestRunner: " + msg)
		return

	_log("auto_play_battle: connected to battle scene, auto-playing")

	# Capture outcome via one-shot lambda on BattleManager.battle_ended.
	var result := {"done": false, "victory": false}
	var on_ended := func(v: bool) -> void:
		result["done"] = true
		result["victory"] = v
	BattleManager.battle_ended.connect(on_ended, CONNECT_ONE_SHOT)

	var player_actions := 0
	var elapsed := 0.0
	var last_state_name := StringName("")

	while not result["done"] and elapsed < timeout:
		await get_tree().process_frame
		elapsed += get_process_delta_time()

		if not BattleManager.is_in_battle():
			break
		if not is_instance_valid(battle_scene):
			break

		var cur: Variant = state_machine.get("current_state")
		if not cur is Node:
			continue
		var cur_name: StringName = (cur as Node).name
		if cur_name == last_state_name:
			continue
		last_state_name = cur_name

		if cur_name == &"PlayerTurn":
			# Wait one frame so PlayerTurnState.enter() wires up command_selected.
			await get_tree().process_frame
			if not BattleManager.is_in_battle():
				break
			battle_ui.command_selected.emit("attack")
			player_actions += 1
			_log("auto_play_battle: action %d — attack" % player_actions)
		elif cur_name == &"TargetSelect":
			# Wait one frame so TargetSelectState.enter() wires up target_selected.
			await get_tree().process_frame
			if not BattleManager.is_in_battle():
				break
			if is_instance_valid(battle_scene):
				var living: Array = battle_scene.call("get_living_enemies")
				if living.size() > 0:
					battle_ui.target_selected.emit(living[0])

	if elapsed >= timeout and not result["done"]:
		var msg := "auto_play_battle: timed out after %.1f seconds" % timeout
		_warnings.append(msg)
		push_warning("PlaytestRunner: " + msg)
		if BattleManager.battle_ended.is_connected(on_ended):
			BattleManager.battle_ended.disconnect(on_ended)

	var outcome := "victory" if result.get("victory", false) else "defeat"
	_log("auto_play_battle: result=%s player_actions=%d" % [outcome, player_actions])

	# Log final party HP for balance analysis.
	var active_party: Array[Resource] = PartyManager.get_active_party()
	for char_res: Resource in active_party:
		if "id" in char_res:
			var char_id: StringName = char_res.get("id")
			var hp: int = PartyManager.get_hp(char_id)
			_log("auto_play_battle: HP %s=%d" % [str(char_id), hp])


# --- State Actions ---

func _wait_state(state_name: String, timeout: float) -> void:
	var target_state := _parse_game_state(state_name)
	var elapsed := 0.0
	while GameManager.current_state != target_state and elapsed < timeout:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	if elapsed >= timeout:
		var msg := "wait_state '%s' timed out after %.1f seconds" % [
			state_name, timeout
		]
		_warnings.append(msg)
		push_warning("PlaytestRunner: " + msg)


func _parse_game_state(state_name: String) -> GameManager.GameState:
	match state_name:
		"OVERWORLD":
			return GameManager.GameState.OVERWORLD
		"BATTLE":
			return GameManager.GameState.BATTLE
		"DIALOGUE":
			return GameManager.GameState.DIALOGUE
		"MENU":
			return GameManager.GameState.MENU
		"CUTSCENE":
			return GameManager.GameState.CUTSCENE
	return GameManager.GameState.OVERWORLD


# --- Screenshot Capture ---

func _do_screenshot(label: String) -> void:
	await RenderingServer.frame_post_draw
	var filename := PlaytestCapture.format_screenshot_filename(_capture_index, label)
	var output_dir: String = _options.get("output_dir", "/tmp/playtest/")
	var ok := PlaytestCapture.capture(get_viewport(), output_dir, filename)
	if ok:
		_screenshots.append({
			"index": _capture_index,
			"label": label,
			"file": filename,
		})
		_log("screenshot — %s" % filename)
	else:
		var msg := "screenshot failed for label '%s'" % label
		_warnings.append(msg)
		push_warning("PlaytestRunner: " + msg)
	_capture_index += 1


# --- Finish ---

func _finish(success: bool) -> void:
	if _finishing:
		return
	_finishing = true

	var duration := Time.get_unix_time_from_system() - _start_time
	var final_state := PlaytestCapture.collect_final_state(GameManager, PartyManager)
	var report := PlaytestCapture.build_report(
		success and _errors.is_empty(),
		duration,
		_config.get("scene", ""),
		_screenshots,
		_errors,
		_actions_done,
		_config.get("actions", []).size(),
		final_state,
	)
	report["warnings"] = _warnings
	report["log"] = _log_lines

	var output_dir: String = _options.get("output_dir", "/tmp/playtest/")
	var report_path := output_dir.path_join("report.json")
	PlaytestCapture.write_json_report(report_path, report)

	_write_log_file(output_dir.path_join("playtest.log"))

	print(
		"PlaytestRunner: report → %s" % report_path
	)
	print(
		"PlaytestRunner: done — success=%s duration=%.1fs"
		% [report.get("success"), duration]
	)

	get_tree().quit(0 if report.get("success", false) else 1)


# --- Helpers ---

func _log(message: String) -> void:
	var line := "[%.2f] %s" % [
		Time.get_unix_time_from_system() - _start_time,
		message,
	]
	_log_lines.append(line)
	print("PlaytestRunner: " + line)


func _write_log_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	for line: String in _log_lines:
		file.store_line(line)
	file.close()


func _wait_seconds(seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds:
		elapsed += get_process_delta_time()
		await get_tree().process_frame


func _load_config_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("PlaytestRunner: cannot open config file '%s'" % path)
		return {}
	var content := file.get_as_text()
	file.close()
	return PlaytestConfig.parse_json(content)


func _merge_partial_over(base: Dictionary, partial: Dictionary) -> Dictionary:
	var merged := base.duplicate(true)
	for key: String in partial:
		if key == "state" and merged.has("state") and \
				partial["state"] is Dictionary:
			var merged_state: Dictionary = merged["state"]
			merged_state.merge(partial["state"], true)
		elif key == "options" and merged.has("options") and \
				partial["options"] is Dictionary:
			var merged_opts: Dictionary = merged["options"]
			merged_opts.merge(partial["options"], true)
		else:
			merged[key] = partial[key]
	return merged
