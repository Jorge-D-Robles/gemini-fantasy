class_name BattleVFX
extends Node2D

## Per-element visual effect that plays on a battle target.
## Follows the DamagePopup pattern: instantiate, add_child, setup().
## Self-destructs via queue_free() after animation completes.

const FRAME_SIZE := Vector2i(64, 64)
const COLS: int = 5
const DEFAULT_FPS: float = 20.0
const VFX_PATH_PREFIX: String = "res://assets/sprites/vfx/"

const VFX_CONFIG: Dictionary = {
	AbilityData.Element.NONE: {"file": "impact1.png", "frames": 30},
	AbilityData.Element.FIRE: {"file": "fire.png", "frames": 30},
	AbilityData.Element.ICE: {"file": "ice.png", "frames": 40},
	AbilityData.Element.WATER: {"file": "water.png", "frames": 50},
	AbilityData.Element.WIND: {"file": "wind.png", "frames": 25},
	AbilityData.Element.EARTH: {"file": "earth1.png", "frames": 30},
	AbilityData.Element.LIGHT: {"file": "holy.png", "frames": 25},
	AbilityData.Element.DARK: {"file": "darkness.png", "frames": 25},
}

const HEAL_CONFIG: Dictionary = {"file": "heal.png", "frames": 50}

var _sprite: AnimatedSprite2D


func _ready() -> void:
	_sprite = AnimatedSprite2D.new()
	_sprite.centered = true
	add_child(_sprite)


static func get_vfx_config(element: AbilityData.Element) -> Dictionary:
	if VFX_CONFIG.has(element):
		return VFX_CONFIG[element]
	return VFX_CONFIG[AbilityData.Element.NONE]


static func get_heal_config() -> Dictionary:
	return HEAL_CONFIG


static func build_sprite_frames(
	texture: Texture2D,
	total_frames: int,
	fps: float,
) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("default")
	frames.set_animation_speed("default", fps)
	frames.set_animation_loop("default", false)

	for i in range(total_frames):
		var col: int = i % COLS
		var row: int = i / COLS
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(
			col * FRAME_SIZE.x,
			row * FRAME_SIZE.y,
			FRAME_SIZE.x,
			FRAME_SIZE.y,
		)
		frames.add_frame("default", atlas)

	return frames


func setup(element: AbilityData.Element) -> void:
	var config: Dictionary = get_vfx_config(element)
	_play_config(config)


func setup_heal() -> void:
	_play_config(HEAL_CONFIG)


func _play_config(config: Dictionary) -> void:
	var path: String = VFX_PATH_PREFIX + config["file"]
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		push_warning("BattleVFX: failed to load '%s'" % path)
		queue_free()
		return

	var total_frames: int = config["frames"]
	var sprite_frames := build_sprite_frames(
		texture, total_frames, DEFAULT_FPS,
	)
	_sprite.sprite_frames = sprite_frames
	_sprite.play("default")
	_sprite.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	queue_free()
