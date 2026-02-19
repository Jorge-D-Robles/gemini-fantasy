extends GutTest

## Tests for CompanionFollower static logic.

const CF = preload("res://entities/companion/companion_follower.gd")


func test_build_sprite_frames_creates_eight_animations() -> void:
	var img := Image.create(144, 192, false, Image.FORMAT_RGBA8)
	var tex := ImageTexture.create_from_image(img)
	var frames: SpriteFrames = CF.build_sprite_frames(tex)
	assert_not_null(frames, "Should return SpriteFrames")
	assert_true(frames.has_animation("walk_down"))
	assert_true(frames.has_animation("walk_up"))
	assert_true(frames.has_animation("walk_left"))
	assert_true(frames.has_animation("walk_right"))
	assert_true(frames.has_animation("idle_down"))
	assert_true(frames.has_animation("idle_up"))
	assert_true(frames.has_animation("idle_left"))
	assert_true(frames.has_animation("idle_right"))
	assert_eq(frames.get_frame_count("walk_down"), 4, "Walk has 4 frames [0,1,2,1]")
	assert_eq(frames.get_frame_count("idle_down"), 1, "Idle has 1 frame")


func test_build_sprite_frames_null_returns_null() -> void:
	var frames: SpriteFrames = CF.build_sprite_frames(null)
	assert_null(frames, "Null texture should return null")


func test_compute_facing_cardinal_down() -> void:
	var facing: int = CF.compute_facing_from_direction(Vector2.DOWN)
	assert_eq(facing, CF.Facing.DOWN)


func test_compute_facing_cardinal_up() -> void:
	var facing: int = CF.compute_facing_from_direction(Vector2.UP)
	assert_eq(facing, CF.Facing.UP)


func test_compute_facing_cardinal_left() -> void:
	var facing: int = CF.compute_facing_from_direction(Vector2.LEFT)
	assert_eq(facing, CF.Facing.LEFT)


func test_compute_facing_cardinal_right() -> void:
	var facing: int = CF.compute_facing_from_direction(Vector2.RIGHT)
	assert_eq(facing, CF.Facing.RIGHT)


func test_compute_facing_diagonal_resolves_dominant_y() -> void:
	# (1, 2) -> Y dominant -> DOWN
	var facing: int = CF.compute_facing_from_direction(Vector2(1.0, 2.0))
	assert_eq(facing, CF.Facing.DOWN)


func test_compute_facing_diagonal_resolves_dominant_x() -> void:
	# (-3, 1) -> X dominant -> LEFT
	var facing: int = CF.compute_facing_from_direction(Vector2(-3.0, 1.0))
	assert_eq(facing, CF.Facing.LEFT)


func test_compute_facing_zero_vector_returns_down() -> void:
	var facing: int = CF.compute_facing_from_direction(Vector2.ZERO)
	assert_eq(facing, CF.Facing.DOWN)
