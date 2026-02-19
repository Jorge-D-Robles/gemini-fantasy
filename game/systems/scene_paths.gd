class_name ScenePaths
extends RefCounted

## Centralized scene path constants. Import via:
##   const SP = preload("res://systems/scene_paths.gd")
## or reference directly: ScenePaths.ROOTHOLLOW

# -- Overworld scenes --
const ROOTHOLLOW: String = (
	"res://scenes/roothollow/roothollow.tscn"
)
const VERDANT_FOREST: String = (
	"res://scenes/verdant_forest/verdant_forest.tscn"
)
const OVERGROWN_RUINS: String = (
	"res://scenes/overgrown_ruins/overgrown_ruins.tscn"
)

# -- UI scenes --
const TITLE_SCREEN: String = (
	"res://ui/title_screen/title_screen.tscn"
)
const DEMO_END_SCREEN: String = (
	"res://ui/demo_end_screen/demo_end_screen.tscn"
)

# -- Battle --
const BATTLE_SCENE: String = (
	"res://systems/battle/battle_scene.tscn"
)
