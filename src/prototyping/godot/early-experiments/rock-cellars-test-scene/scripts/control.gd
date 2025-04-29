extends Control

const COLS := 16
const ROWS := 8
const POINT_RADIUS := 6.0
const GRAB_RADIUS := POINT_RADIUS * 1.5
const POINT_COLOR := Color(0.0, 1.0, 0.0, 1.0)

# State:
var points := []                # Vector2 positions in pixels
var dragging_index := -1        # which point we’re dragging, or -1

@export var distortion_mesh_path: NodePath
var distortion_material: ShaderMaterial

func _ready() -> void:
	set_process(true)
	_init_points()
	queue_redraw()
	
	# find the MeshInstance3D that uses your distortion shader
	var mesh = get_node(distortion_mesh_path) as MeshInstance3D
	distortion_material = mesh.get_active_material(0) as ShaderMaterial
	
	# initialize shader with the zero‐offset grid
	_apply_offsets_to_shader()

# Build the initial grid of evenly-spaced points
func _init_points() -> void:
	points.clear()
	for y in range(ROWS + 1):
		for x in range(COLS + 1):
			var u := x / float(COLS)
			var v := y / float(ROWS)
			points.append(Vector2(u * size.x, v * size.y))

func _process(delta: float) -> void:
	# always redraw so _draw() uses the up-to-date `points`[]
	queue_redraw()

func _draw() -> void:
	for p in points:
		draw_circle(p, POINT_RADIUS, POINT_COLOR)

# Capture mouse down/up and motion:
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			dragging_index = _find_point_at(event.position)
		else:
			dragging_index = -1
			
	elif event is InputEventMouseMotion and dragging_index >= 0:
		# pick 25% speed when Alt/Option is held, else normal speed
		var sens := 0.25 if event.alt_pressed else 1.0

		# move the selected point by the scaled mouse delta
		var new_pos: Vector2 = points[dragging_index] + event.relative * sens

		# clamp it inside the Control’s rectangle
		new_pos.x = clamp(new_pos.x, 0.0, size.x)
		new_pos.y = clamp(new_pos.y, 0.0, size.y)

		# write it back and redraw
		points[dragging_index] = new_pos
		queue_redraw()
		_apply_offsets_to_shader()


# Helper: returns the index of the first point under `pos`, or -1 if none
func _find_point_at(pos: Vector2) -> int:
	for i in points.size() - 1:  # you can also iterate forwards
		if points[i].distance_to(pos) <= GRAB_RADIUS:
			return i
	return -1

func _compute_offsets() -> Array:
	var arr := []
	for i in range(points.size()):
		var col := i % (COLS + 1)
		var row := i / (COLS + 1)
		var grid_u := float(col) / float(COLS)
		var grid_v := float(row) / float(ROWS)
		var orig_px := Vector2(grid_u * size.x, grid_v * size.y)
		# delta in UV‐space:
		arr.append((points[i] - orig_px) / size)
	return arr

# step 2: push them into the shader
func _apply_offsets_to_shader() -> void:
	# Godot will accept a plain Array of Vector2 for a vec2[] uniform
	distortion_material.set_shader_parameter("offsets", _compute_offsets())
