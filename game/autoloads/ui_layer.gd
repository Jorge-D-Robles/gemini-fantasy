extends Node

## Global UI autoload. Holds HUD, DialogueBox, PauseMenu, ShopUI,
## and (in debug builds) the DebugConsole as persistent children.

const SHOP_UI_SCENE := preload("res://ui/shop_ui/shop_ui.tscn")
const DEBUG_CONSOLE_SCRIPT := preload(
	"res://ui/debug_console/debug_console.gd"
)

var _shop_ui: Node = null

@onready var hud := $HUD
@onready var dialogue_box := $DialogueBox
@onready var pause_menu := $PauseMenu


func _ready() -> void:
	if OS.is_debug_build():
		var console := DEBUG_CONSOLE_SCRIPT.new()
		add_child(console)

	var shop_mgr: Node = get_node_or_null("/root/ShopManager")
	if shop_mgr:
		shop_mgr.shop_opened.connect(_on_shop_opened)
		shop_mgr.shop_closed.connect(_on_shop_closed)


func _on_shop_opened(shop_data: Resource) -> void:
	if _shop_ui != null:
		_shop_ui.close()
		_shop_ui.queue_free()
	_shop_ui = SHOP_UI_SCENE.instantiate()
	add_child(_shop_ui)
	_shop_ui.shop_ui_closed.connect(_on_shop_ui_closed)
	_shop_ui.open(shop_data)


func _on_shop_closed() -> void:
	if _shop_ui != null:
		_shop_ui.close()


func _on_shop_ui_closed() -> void:
	if _shop_ui != null:
		_shop_ui.queue_free()
		_shop_ui = null
	var shop_mgr: Node = get_node_or_null("/root/ShopManager")
	if shop_mgr and shop_mgr.is_open:
		shop_mgr.close_shop()
