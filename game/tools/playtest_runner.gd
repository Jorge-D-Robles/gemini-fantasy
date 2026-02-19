extends Node2D

## Automated playtest runner for full-state integration testing.
##
## Boots the game with all autoloads initialized, injects configurable game
## state (party, flags, inventory, gold), loads a target scene via
## GameManager.change_scene(), then executes a scripted action sequence,
## capturing screenshots and collecting errors throughout.
##
## Invocation:
##   godot --path game/ res://tools/playtest_runner.tscn \
##          -- --config=/tmp/playtest_config.json
##
## Or inline args:
##   godot --path game/ res://tools/playtest_runner.tscn \
##          -- --scene=res://scenes/roothollow/roothollow.tscn \
##             --party=kael,lyra --gold=500 --output=/tmp/playtest/

const PlaytestConfig := preload("res://tools/playtest_config.gd")
const PlaytestCapture := preload("res://tools/playtest_capture.gd")

## Populated after state injection + scene load.
var _config: Dictionary = {}
var _options: Dictionary = {}
var _screenshots: Array = []
var _errors: Array = []
var _capture_index: int = 1
var _actions_done: int = 0
var _start_time: float = 0.0
var _timeout_timer: float = 0.0
var _capture_interval_elapsed: float = 0.0
var _scene_loaded: bool = false


func _ready() -> void:
	_start_time = Time.get_unix_time_from_system()
	var cli_args := OS.get_cmdline_user_args()
	var partial := PlaytestConfig.parse_cli_args(cli_args)

	# If --config= was provided, load and merge the JSON config.
	if partial.has("config_path"):
		var json_config := _load_config_file(partial["config_path"])
		# CLI args take precedence over file config.
		_config = PlaytestConfig.merge_defaults(_merge_partial_over(json_config, partial))
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

	_inject_state(_config.get("state", {}))

	var scene_path: String = _config.get("scene", "")
	var spawn_point: String = _config.get("spawn_point", "")
	GameManager.change_scene(scene_path, 0.0, spawn_point)
	await GameManager.transition_finished

	_scene_loaded = true
	print("PlaytestRunner: scene loaded — %s" % scene_path)

	await _execute_actions(_config.get("actions", []))
	_finish(true)


func _process(delta: float) -> void:
	if not _scene_loaded:
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
			await _do_screenshot("interval_%d" % _capture_index)


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
			push_warning("PlaytestRunner: character not found — %s" % path)
			continue
		PartyManager.add_character(data)

		# Level up to target level if specified.
		if levels.has(id) and data is CharacterData:
			var char_data := data as CharacterData
			var target_level: int = levels[id]
			while char_data.level < target_level:
				var needed := LevelManager.xp_for_level(char_data.level + 1) \
						- char_data.current_xp + 1
				LevelManager.add_xp(char_data, needed)


func _inject_inventory(items: Dictionary) -> void:
	for item_id: String in items:
		var count: int = items[item_id]
		InventoryManager.add_item(StringName(item_id), count)


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
				push_warning(
					"PlaytestRunner: equipment not found — %s" % path
				)
				continue
			EquipmentManager.equip(StringName(char_id), eq_data)


func _inject_quests(quest_ids: Array) -> void:
	for quest_id: String in quest_ids:
		var path := "res://data/quests/%s.tres" % quest_id
		var quest: Resource = load(path)
		if quest == null:
			push_warning("PlaytestRunner: quest not found — %s" % path)
			continue
		QuestManager.accept_quest(quest)


# --- Action Execution ---

func _execute_actions(actions: Array) -> void:
	var total := actions.size()
	for i: int in range(total):
		if _timeout_timer >= _options.get("timeout_seconds", 60.0):
			break
		var action: Dictionary = actions[i]
		await _execute_action(action)
		_actions_done += 1
		print("PlaytestRunner: action %d/%d done — %s" % [i + 1, total, action.get("type", "?")])


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
		_:
			push_warning("PlaytestRunner: unknown action type '%s'" % action_type)


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
		print("PlaytestRunner: screenshot — %s" % filename)
	else:
		push_warning("PlaytestRunner: screenshot failed for label '%s'" % label)
	_capture_index += 1


# --- Finish ---

func _finish(success: bool) -> void:
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

	var output_dir: String = _options.get("output_dir", "/tmp/playtest/")
	var report_path := output_dir.path_join("report.json")
	PlaytestCapture.write_json_report(report_path, report)
	print("PlaytestRunner: report written to %s" % report_path)
	print("PlaytestRunner: finished — success=%s duration=%.1fs" % [
		report.get("success"), duration
	])

	get_tree().quit(0 if report.get("success", false) else 1)


# --- Helpers ---

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
		if key == "state" and merged.has("state") and partial["state"] is Dictionary:
			var merged_state: Dictionary = merged["state"]
			merged_state.merge(partial["state"], true)
		elif key == "options" and merged.has("options") and \
				partial["options"] is Dictionary:
			var merged_opts: Dictionary = merged["options"]
			merged_opts.merge(partial["options"], true)
		else:
			merged[key] = partial[key]
	return merged
