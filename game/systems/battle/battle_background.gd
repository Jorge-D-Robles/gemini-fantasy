extends Sprite2D

## Draws a gradient battle background based on the area type.
## Replaces the empty BattleBackground Sprite2D in battle_scene.tscn.

enum AreaType {
	FOREST,
	RUINS,
	TOWN,
	CAVE,
}

const VIEWPORT_WIDTH: int = 640
const VIEWPORT_HEIGHT: int = 360

## Sky (top) and ground (bottom) gradient colors per area type.
## Each entry: [sky_top, sky_bottom, ground_top, ground_bottom]
const AREA_PALETTES: Dictionary = {
	AreaType.FOREST: {
		"sky_top": Color(0.05, 0.12, 0.08),
		"sky_bottom": Color(0.08, 0.22, 0.12),
		"ground_top": Color(0.12, 0.18, 0.08),
		"ground_bottom": Color(0.06, 0.1, 0.05),
	},
	AreaType.RUINS: {
		"sky_top": Color(0.06, 0.06, 0.12),
		"sky_bottom": Color(0.12, 0.1, 0.18),
		"ground_top": Color(0.18, 0.15, 0.1),
		"ground_bottom": Color(0.1, 0.08, 0.06),
	},
	AreaType.TOWN: {
		"sky_top": Color(0.12, 0.06, 0.15),
		"sky_bottom": Color(0.18, 0.1, 0.12),
		"ground_top": Color(0.14, 0.1, 0.08),
		"ground_bottom": Color(0.08, 0.06, 0.05),
	},
	AreaType.CAVE: {
		"sky_top": Color(0.03, 0.03, 0.05),
		"sky_bottom": Color(0.06, 0.06, 0.08),
		"ground_top": Color(0.08, 0.07, 0.06),
		"ground_bottom": Color(0.04, 0.04, 0.03),
	},
}

## Maps scene filename keywords to area types.
const SCENE_AREA_MAP: Dictionary = {
	"verdant_forest": AreaType.FOREST,
	"forest": AreaType.FOREST,
	"roothollow": AreaType.TOWN,
	"town": AreaType.TOWN,
	"overgrown_ruins": AreaType.RUINS,
	"ruins": AreaType.RUINS,
	"cave": AreaType.CAVE,
	"dungeon": AreaType.CAVE,
}


## Creates and applies the gradient texture for the given area type.
func setup(area: AreaType) -> void:
	var palette: Dictionary = AREA_PALETTES.get(area, AREA_PALETTES[AreaType.FOREST])

	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.45, 0.5, 1.0])
	gradient.colors = PackedColorArray([
		palette["sky_top"],
		palette["sky_bottom"],
		palette["ground_top"],
		palette["ground_bottom"],
	])

	var grad_tex := GradientTexture2D.new()
	grad_tex.gradient = gradient
	grad_tex.width = VIEWPORT_WIDTH
	grad_tex.height = VIEWPORT_HEIGHT
	grad_tex.fill_from = Vector2(0.5, 0.0)
	grad_tex.fill_to = Vector2(0.5, 1.0)

	texture = grad_tex
	centered = false
	z_index = -10


## Resolves an area type from a scene file path.
static func area_from_scene_path(scene_path: String) -> AreaType:
	var lower := scene_path.to_lower()
	for keyword: String in SCENE_AREA_MAP:
		if lower.contains(keyword):
			return SCENE_AREA_MAP[keyword] as AreaType
	return AreaType.FOREST
