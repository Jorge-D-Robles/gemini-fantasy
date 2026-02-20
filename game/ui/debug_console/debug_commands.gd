class_name DebugCommands
extends RefCounted

## Pure command parser for the debug console.
## compute_debug_command_result() is testable without live autoloads.
## execute_command() calls into autoloads and must not be called in tests.

## Scene name aliases for the teleport command.
const TELEPORT_TARGETS: Dictionary = {
	"roothollow": "res://scenes/roothollow/roothollow.tscn",
	"verdant_forest": "res://scenes/verdant_forest/verdant_forest.tscn",
	"overgrown_ruins": "res://scenes/overgrown_ruins/overgrown_ruins.tscn",
	"ruins": "res://scenes/overgrown_ruins/overgrown_ruins.tscn",
	"forest": "res://scenes/verdant_forest/verdant_forest.tscn",
	"town": "res://scenes/roothollow/roothollow.tscn",
}


## Parses command_text and returns a result Dictionary:
##   {ok: bool, message: String, command: String, args: Array[String]}
## Pure function — no autoload calls. Use for TDD.
static func compute_debug_command_result(
	command_text: String,
) -> Dictionary:
	var trimmed := command_text.strip_edges()
	if trimmed.is_empty():
		return {
			"ok": false,
			"message": "Enter a command.",
			"command": "",
			"args": [],
		}

	var parts: Array[String] = []
	for part: String in trimmed.split(" ", false):
		parts.append(part)

	var cmd: String = parts[0].to_lower()
	var args: Array[String] = []
	for i: int in range(1, parts.size()):
		args.append(parts[i])

	match cmd:
		"heal_all":
			return {
				"ok": true,
				"message": "Party fully healed.",
				"command": cmd,
				"args": args,
			}

		"set_level":
			if args.is_empty() or not args[0].is_valid_int():
				return {
					"ok": false,
					"message": "Usage: set_level <n>",
					"command": cmd,
					"args": args,
				}
			return {
				"ok": true,
				"message": "Level set to %s." % args[0],
				"command": cmd,
				"args": args,
			}

		"add_item":
			if args.is_empty():
				return {
					"ok": false,
					"message": "Usage: add_item <id> [qty]",
					"command": cmd,
					"args": args,
				}
			var qty_str: String = args[1] if args.size() > 1 else "1"
			return {
				"ok": true,
				"message": "Added %s x%s." % [args[0], qty_str],
				"command": cmd,
				"args": args,
			}

		"teleport":
			if args.is_empty():
				return {
					"ok": false,
					"message": "Usage: teleport <scene>  (scenes: %s)" % (
						", ".join(TELEPORT_TARGETS.keys())
					),
					"command": cmd,
					"args": args,
				}
			var target: String = args[0].to_lower()
			if not TELEPORT_TARGETS.has(target):
				return {
					"ok": false,
					"message": "Unknown scene '%s'. Try: %s" % [
						args[0],
						", ".join(TELEPORT_TARGETS.keys()),
					],
					"command": cmd,
					"args": args,
				}
			return {
				"ok": true,
				"message": "Teleporting to %s." % args[0],
				"command": cmd,
				"args": args,
			}

		"set_flag":
			if args.is_empty():
				return {
					"ok": false,
					"message": "Usage: set_flag <name>",
					"command": cmd,
					"args": args,
				}
			return {
				"ok": true,
				"message": "Flag '%s' set." % args[0],
				"command": cmd,
				"args": args,
			}

		_:
			return {
				"ok": false,
				"message": (
					"Unknown: '%s'. Commands: heal_all, set_level, add_item, "
					+ "teleport, set_flag"
				) % cmd,
				"command": cmd,
				"args": args,
			}


## Executes a parsed command result by calling into autoloads.
## Only call at runtime — not safe for unit tests.
static func execute_command(result: Dictionary, owner: Node) -> void:
	if not result.get("ok", false):
		return

	var cmd: String = result.get("command", "")
	var args: Array = result.get("args", [])

	match cmd:
		"heal_all":
			var party_mgr := owner.get_node_or_null("/root/PartyManager")
			if party_mgr:
				party_mgr.heal_all()

		"set_level":
			var party_mgr := owner.get_node_or_null("/root/PartyManager")
			if not party_mgr:
				return
			var level := int(args[0])
			var party: Array = party_mgr.get_active_party()
			for member: Resource in party:
				if member and "level" in member:
					member.level = maxi(1, level)

		"add_item":
			var inv_mgr := owner.get_node_or_null("/root/InventoryManager")
			if not inv_mgr:
				return
			var item_id := StringName(args[0])
			var qty := int(args[1]) if args.size() > 1 else 1
			inv_mgr.add_item(item_id, maxi(1, qty))

		"teleport":
			var scene_path: String = TELEPORT_TARGETS.get(
				args[0].to_lower(), ""
			)
			if scene_path.is_empty():
				return
			var gm := owner.get_node_or_null("/root/GameManager")
			if gm:
				gm.change_scene(scene_path)

		"set_flag":
			var flags := owner.get_node_or_null("/root/EventFlags")
			if flags:
				flags.set_flag(args[0])
