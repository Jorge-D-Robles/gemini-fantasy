class_name CompanionFollower
extends Node2D

## A single companion that follows the player in the overworld.
## Uses a 3x4 sprite sheet (same format as player.gd).
## Position and facing are set externally by CompanionController.

enum Facing {
	DOWN,
	UP,
	LEFT,
	RIGHT,
}

const ANIM_FPS: float = 8.0
const SPRITE_SCALE := Vector2(0.55, 0.75)
const DIRECTION_NAMES: Dictionary = {
	Facing.DOWN: "down",
	Facing.UP: "up",
	Facing.LEFT: "left",
	Facing.RIGHT: "right",
}

var character_id: StringName = &""
var facing: Facing = Facing.DOWN
var _sprite: AnimatedSprite2D = null
var _animations_ready: bool = false
var _is_moving: bool = false


func setup(sprite_path: String, char_id: StringName) -> void:
	character_id = char_id
	if sprite_path.is_empty():
		push_warning(
			"CompanionFollower: empty sprite_path for '%s'" % char_id
		)
		return
	var texture: Texture2D = load(sprite_path) as Texture2D
	if texture == null:
		push_warning(
			"CompanionFollower: failed to load '%s'" % sprite_path
		)
		return
	var frames: SpriteFrames = build_sprite_frames(texture)
	if frames == null:
		return
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = frames
	_sprite.scale = SPRITE_SCALE
	_sprite.play("idle_down")
	add_child(_sprite)
	_animations_ready = true


func set_facing(new_facing: Facing) -> void:
	if facing == new_facing:
		return
	facing = new_facing
	_update_animation()


func set_moving(moving: bool) -> void:
	if _is_moving == moving:
		return
	_is_moving = moving
	_update_animation()


func _update_animation() -> void:
	if not _animations_ready:
		return
	var dir_name: String = DIRECTION_NAMES[facing]
	var anim_name: String
	if _is_moving:
		anim_name = "walk_%s" % dir_name
	else:
		anim_name = "idle_%s" % dir_name
	if _sprite.animation != anim_name:
		_sprite.play(anim_name)


static func build_sprite_frames(texture: Texture2D) -> SpriteFrames:
	if texture == null:
		return null
	# Sprite sheets are RPG Maker MV/MZ format: 144x192 px containing 4
	# characters (2 wide x 2 tall). Each character occupies 72x96 px with
	# 3 walk columns x 4 direction rows. Frame size = 24x24 px.
	# Always extract the top-left character (char_col=0, char_row=0).
	var frame_w: int = texture.get_width() / (2 * 3)
	var frame_h: int = texture.get_height() / (2 * 4)
	var char_origin_x: int = 0
	var char_origin_y: int = 0

	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	var row_map: Dictionary = {
		"down": 0,
		"left": 1,
		"right": 2,
		"up": 3,
	}
	var walk_cycle: Array[int] = [0, 1, 2, 1]

	for dir_name: String in row_map:
		var row: int = row_map[dir_name]

		var walk_name := "walk_%s" % dir_name
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, ANIM_FPS)
		frames.set_animation_loop(walk_name, true)
		for col: int in walk_cycle:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(
				char_origin_x + col * frame_w,
				char_origin_y + row * frame_h,
				frame_w,
				frame_h,
			)
			frames.add_frame(walk_name, atlas)

		var idle_name := "idle_%s" % dir_name
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 1.0)
		frames.set_animation_loop(idle_name, false)
		var idle_atlas := AtlasTexture.new()
		idle_atlas.atlas = texture
		idle_atlas.region = Rect2(
			char_origin_x + frame_w,
			char_origin_y + row * frame_h,
			frame_w,
			frame_h,
		)
		frames.add_frame(idle_name, idle_atlas)

	return frames


static func compute_facing_from_direction(
	direction: Vector2,
) -> Facing:
	if direction == Vector2.ZERO:
		return Facing.DOWN
	if absf(direction.x) > absf(direction.y):
		if direction.x > 0.0:
			return Facing.RIGHT
		return Facing.LEFT
	if direction.y > 0.0:
		return Facing.DOWN
	return Facing.UP
