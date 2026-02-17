extends Node2D

## Scene preview tool for agent visual verification.
##
## Loads a target scene, optionally positions a camera, waits for
## rendering to complete, captures a screenshot, and exits.
## Designed to be run from the command line with user args after --.

const TILE_SIZE: int = 16

var _output_path: String = "/tmp/scene_preview.png"
var _scene_path: String = ""
var _wait_frames: int = 5
var _camera_x: float = NAN
var _camera_y: float = NAN
var _zoom_level: float = 1.0
var _full_map: bool = false
var _show_ui: bool = false


func _ready() -> void:
	_parse_args()

	if _scene_path.is_empty():
		push_error("ScenePreview: --preview-scene is required")
		_fail_and_quit()
		return

	var packed: PackedScene = load(_scene_path) as PackedScene
	if packed == null:
		push_error(
			"ScenePreview: Failed to load scene '%s'" % _scene_path
		)
		_fail_and_quit()
		return

	var scene_instance: Node = packed.instantiate()
	add_child(scene_instance)

	if not _show_ui:
		_hide_ui_layer()

	if _full_map:
		_setup_full_map_camera(scene_instance)
	elif not is_nan(_camera_x) and not is_nan(_camera_y):
		_setup_positioned_camera()

	_capture_after_frames(_wait_frames)


func _parse_args() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for arg: String in args:
		if arg.begins_with("--preview-scene="):
			_scene_path = arg.trim_prefix("--preview-scene=")
		elif arg.begins_with("--output="):
			_output_path = arg.trim_prefix("--output=")
		elif arg.begins_with("--wait-frames="):
			_wait_frames = arg.trim_prefix(
				"--wait-frames="
			).to_int()
		elif arg.begins_with("--camera-x="):
			_camera_x = arg.trim_prefix("--camera-x=").to_float()
		elif arg.begins_with("--camera-y="):
			_camera_y = arg.trim_prefix("--camera-y=").to_float()
		elif arg.begins_with("--zoom="):
			_zoom_level = arg.trim_prefix("--zoom=").to_float()
		elif arg == "--full-map":
			_full_map = true
		elif arg == "--show-ui":
			_show_ui = true


func _hide_ui_layer() -> void:
	var ui_layer: Node = get_tree().root.get_node_or_null(
		"UILayer"
	)
	if ui_layer == null:
		return
	for child: Node in ui_layer.get_children():
		if child is CanvasItem:
			(child as CanvasItem).visible = false


func _setup_positioned_camera() -> void:
	var cam := Camera2D.new()
	cam.enabled = true
	cam.position = Vector2(_camera_x, _camera_y)
	cam.zoom = Vector2(_zoom_level, _zoom_level)
	add_child(cam)
	cam.make_current()


func _setup_full_map_camera(scene_root: Node) -> void:
	var bounds := _compute_tilemap_bounds(scene_root)
	if bounds.size == Vector2.ZERO:
		push_warning(
			"ScenePreview: No TileMapLayer cells found — "
			+ "using default camera"
		)
		return

	var viewport_size := Vector2(
		get_viewport().get_visible_rect().size
	)
	var zoom_x: float = viewport_size.x / bounds.size.x
	var zoom_y: float = viewport_size.y / bounds.size.y
	var zoom_fit: float = minf(zoom_x, zoom_y)
	if _zoom_level != 1.0:
		zoom_fit = _zoom_level

	var cam := Camera2D.new()
	cam.enabled = true
	cam.position = bounds.get_center()
	cam.zoom = Vector2(zoom_fit, zoom_fit)
	add_child(cam)
	cam.make_current()


func _compute_tilemap_bounds(root: Node) -> Rect2:
	var combined := Rect2()
	var found_any: bool = false

	var layers: Array[Node] = _find_all_tilemap_layers(root)
	for node: Node in layers:
		var layer: TileMapLayer = node as TileMapLayer
		var cells: Array[Vector2i] = layer.get_used_cells()
		for cell: Vector2i in cells:
			var local_pos: Vector2 = layer.map_to_local(cell)
			var global_pos: Vector2 = layer.to_global(local_pos)
			var tile_rect := Rect2(
				global_pos - Vector2(
					TILE_SIZE / 2.0, TILE_SIZE / 2.0
				),
				Vector2(TILE_SIZE, TILE_SIZE),
			)
			if not found_any:
				combined = tile_rect
				found_any = true
			else:
				combined = combined.merge(tile_rect)

	if found_any:
		combined = combined.grow(TILE_SIZE)

	return combined


func _find_all_tilemap_layers(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	if root is TileMapLayer:
		result.append(root)
	for child: Node in root.get_children():
		result.append_array(_find_all_tilemap_layers(child))
	return result


func _capture_after_frames(frames: int) -> void:
	for i: int in range(frames):
		await get_tree().process_frame

	await RenderingServer.frame_post_draw

	var image: Image = get_viewport().get_texture().get_image()
	if image == null:
		push_error("ScenePreview: Failed to get viewport image")
		_fail_and_quit()
		return

	var err: Error = image.save_png(_output_path)
	if err != OK:
		push_error(
			"ScenePreview: Failed to save PNG to '%s': %s"
			% [_output_path, error_string(err)]
		)
		_fail_and_quit()
		return

	print("ScenePreview: Saved to %s" % _output_path)
	get_tree().quit(0)


func _fail_and_quit() -> void:
	var fallback := Image.create_empty(
		1, 1, false, Image.FORMAT_RGBA8
	)
	fallback.set_pixel(0, 0, Color.RED)
	fallback.save_png(_output_path)
	get_tree().quit(1)
