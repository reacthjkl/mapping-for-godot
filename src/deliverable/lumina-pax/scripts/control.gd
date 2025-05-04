extends Control

class_name DistortionControl

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
		# find the ColorRect that uses the distortion shader
	var rect = get_node(distortion_mesh_path) as ColorRect
	distortion_material = rect.material as ShaderMaterial
	
	set_process(true)
	_init_points()
	load_grid()
	queue_redraw()
	
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
	
func save_grid(path: String = "user://distortion_grid.json") -> void:
	# 1) Build a plain Array of Dictionaries {x:…, y:…}
	var data: Array = []
	for p in points:
		data.append({"x": p.x, "y": p.y})
	# 2) Encode to JSON
	var json_text: String = JSON.stringify(data)
	# 3) Open the file for writing and store the string
	var f = FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(json_text)
		f.close()
		print("Distortion grid saved to ", path)
	else:
		push_error("Failed to open " + path + " for writing.")
		
func load_grid(path: String = "user://distortion_grid.json") -> void:
	# 1) If no file exists yet, just bail
	if not FileAccess.file_exists(path):
		print("No grid config found at ", path)
		return
	# 2) Open and read the entire JSON string
	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		push_error("Failed to open " + path + " for reading.")
		return
	var json_text: String = f.get_as_text()
	f.close()
	# 3) Parse it
	var arr = JSON.parse_string(json_text)
	if typeof(arr) != TYPE_ARRAY:
		push_error("Grid JSON was not an Array!")
		return
	
	points.clear()
	for item in arr:
		# assume each item is a Dictionary with x and y keys
		var x = item.get("x", 0.0)
		var y = item.get("y", 0.0)
		points.append(Vector2(x, y))
	# 5) Redraw and reapply to shader
	queue_redraw()
	_apply_offsets_to_shader()
	print("Loaded distortion grid from ", path)
	
func _exit_tree():
	save_grid()
