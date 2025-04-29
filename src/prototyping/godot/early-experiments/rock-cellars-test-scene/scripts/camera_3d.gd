extends Camera3D

const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 0.01

@export_range(0.0, 1.0) var sensitivity: float = 0.0025
@export var keyboard_look_speed: float = 1  # Geschwindigkeit für Blickbewegung mit Pfeiltasten

var _total_pitch = 0.0

var _direction = Vector3.ZERO
var _velocity = Vector3.ZERO
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false
var _up = false
var _down = false
var _left = false
var _right = false
var _reset = false  # Flag zum Zurücksetzen der Kamera

# Dictionary zum Speichern der Positionen und Rotationen
var saved_positions = {}

# Ursprüngliche Position und Rotation der Kamera
var _original_position: Vector3
var _original_rotation: Vector3

# Config
const CONFIG_PATH := "user://camera_config.json"

func _ready():
	# Speichert die ursprüngliche Position und Rotation der Kamera
	_original_position = global_position
	_original_rotation = rotation_degrees
	
	_load_camera_config()

func _input(event):
	
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_J:  
				_save_camera_config()
			KEY_K: 
				_load_camera_config()
			KEY_ENTER:
				$distortion_lens.visible = not $distortion_lens.visible
		
	if event is InputEventKey:
		match event.keycode:
			KEY_W: _w = event.pressed
			KEY_S: _s = event.pressed
			KEY_A: _a = event.pressed
			KEY_D: _d = event.pressed
			KEY_Q: _q = event.pressed
			KEY_E: _e = event.pressed
			KEY_SHIFT: _shift = event.pressed
			KEY_ALT: _alt = event.pressed
			KEY_UP: _up = event.pressed
			KEY_DOWN: _down = event.pressed
			KEY_LEFT: _left = event.pressed
			KEY_RIGHT: _right = event.pressed
			KEY_R: 
				if event.pressed:
					_reset = true  # Wenn R gedrückt wird, setze zurück
			KEY_L:
				if event.pressed:
					log_camera_transform()
			KEY_9:
				if event.pressed:
					fov += 1;
			KEY_0:
				if event.pressed:
					fov -= 1;
			# Tasten zum Speichern von Positionen und Rotationen
			KEY_1: _save_position(1) if _shift else _load_position(1)
			KEY_2: _save_position(2) if _shift else _load_position(2)
			KEY_3: _save_position(3) if _shift else _load_position(3)
			KEY_4: _save_position(4) if _shift else _load_position(4)
			KEY_5: _save_position(5) if _shift else _load_position(5)

func _process(delta):
	_update_look(delta)
	_update_movement(delta)

	# Wenn Reset aktiv ist, Position und Rotation zurücksetzen
	if _reset:
		reset_camera()
		_reset = false  # Setze den Reset-Flag zurück

func _update_movement(delta):
	_direction = Vector3(
		(_d as float) - (_a as float), 
		(_e as float) - (_q as float),
		(_s as float) - (_w as float)
	)

	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta

	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER

	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		_velocity = Vector3.ZERO
	else:
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)

		translate(_velocity * delta * speed_multi)

func _update_look(delta):
	var key_yaw = 0.0
	var key_pitch = 0.0
	
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER

	if _left: key_yaw += keyboard_look_speed * speed_multi
	if _right: key_yaw -= keyboard_look_speed * speed_multi
	if _up: key_pitch += keyboard_look_speed * speed_multi
	if _down: key_pitch -= keyboard_look_speed * speed_multi

	_apply_rotation(key_yaw * delta * 50, key_pitch * delta * 50)  # Skalieren für smoothes Movement

func _apply_rotation(yaw: float, pitch: float):
	# Begrenzung des Pitch (Neigung nach oben/unten)
	pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
	_total_pitch += pitch

	rotate_y(deg_to_rad(yaw))
	rotate_object_local(Vector3(1, 0, 0), deg_to_rad(pitch))

func _exit_tree():
	_save_camera_config()

# Funktion zum Zurücksetzen der Kamera
func reset_camera():
	global_position = _original_position
	rotation_degrees = _original_rotation
	
	# Speichert die aktuelle Position und Rotation
func _save_position(index: int):
	saved_positions[index] = {
		"position": global_position,
		"rotation": rotation_degrees
	}

# Lädt eine gespeicherte Position und Rotation
func _load_position(index: int):
	if saved_positions.has(index):
		global_position = saved_positions[index]["position"]
		rotation_degrees = saved_positions[index]["rotation"]

func log_camera_transform():
	var pos = global_position
	var rot = rotation_degrees
	print("📷 Kamera Position: x=%.2f, y=%.2f, z=%.2f" % [pos.x, pos.y, pos.z])
	print("🌀 Kamera Rotation: x=%.2f°, y=%.2f°, z=%.2f°" % [rot.x, rot.y, rot.z])
	print("🌀 FOV: %.2f°" % [fov])
	
	
func _save_camera_config():
	var config = {
		"position": global_position,
		"rotation": rotation_degrees,
		"fov": fov
	}

	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(config, "\t"))  # Pretty print
		file.close()
		print("💾 Camera config saved to:", CONFIG_PATH)

func _string_to_vector3(value: String) -> Vector3:
	var cleaned = value.replace("(", "").replace(")", "")  # Remove parentheses
	var parts = cleaned.split(",")
	if parts.size() == 3:
		return Vector3(parts[0].to_float(), parts[1].to_float(), parts[2].to_float())
	return Vector3.ZERO  # Fallback

func _load_camera_config():
	if not FileAccess.file_exists(CONFIG_PATH):
		print("⚠️ Config file not found at:", CONFIG_PATH)
		return

	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		var config = JSON.parse_string(content)
		if config is Dictionary:
			if config.has("position") and config.position is String:
				global_position = _string_to_vector3(config.position)
			if config.has("rotation") and config.rotation is String:
				rotation_degrees = _string_to_vector3(config.rotation)
			if config.has("fov"):
				fov = config.fov

			print("✅ Camera config loaded from:", CONFIG_PATH)
		else:
			print("❌ Failed to parse config file.")
