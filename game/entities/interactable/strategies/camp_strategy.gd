class_name CampStrategy
extends InteractionStrategy

## Opens the camp menu when a campfire interactable is activated.
## Instantiates CampMenu script-only Control, adds it to UILayer,
## and cleans it up when the player leaves camp.

const CampMenuScript := preload("res://ui/camp_menu/camp_menu.gd")


func execute(owner: Node) -> void:
	var ui_layer := owner.get_node_or_null("/root/UILayer")
	if not ui_layer:
		push_warning("CampStrategy: UILayer autoload not found")
		return

	var camp_menu: Control = CampMenuScript.new()
	ui_layer.add_child(camp_menu)
	camp_menu.camp_menu_closed.connect(camp_menu.queue_free, CONNECT_ONE_SHOT)
	camp_menu.open()
