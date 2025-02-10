extends Camera3D

const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@export_range(0.0, 1.0) var sensitivity: float = 0.25
@export var keyboard_look_speed: float = 1.0  # Geschwindigkeit für Blickbewegung mit Pfeiltasten

var _mouse_position = Vector2(0.0, 0.0)
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

func _ready():
	# Speichert die ursprüngliche Position und Rotation der Kamera
	_original_position = global_position
	_original_rotation = rotation_degrees

func _input(event):
	if event is InputEventMouseMotion:
		_mouse_position = event.relative

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_UP:
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			MOUSE_BUTTON_WHEEL_DOWN:
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)

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
			# Tasten zum Speichern von Positionen und Rotationen
			KEY_1: _save_position(1) if _shift else _load_position(1)
			KEY_2: _save_position(2) if _shift else _load_position(2)
			KEY_3: _save_position(3) if _shift else _load_position(3)
			KEY_4: _save_position(4) if _shift else _load_position(4)
			KEY_5: _save_position(5) if _shift else _load_position(5)

func _process(delta):
	_update_mouselook(delta)
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

func _update_mouselook(delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = -_mouse_position.x
		var pitch = -_mouse_position.y
		_mouse_position = Vector2.ZERO

		_apply_rotation(yaw, pitch)

	# Pfeiltastensteuerung für Blickrichtung
	var key_yaw = 0.0
	var key_pitch = 0.0

	if _left: key_yaw += keyboard_look_speed
	if _right: key_yaw -= keyboard_look_speed
	if _up: key_pitch += keyboard_look_speed
	if _down: key_pitch -= keyboard_look_speed

	_apply_rotation(key_yaw * delta * 50, key_pitch * delta * 50)  # Skalieren für smoothes Movement

func _apply_rotation(yaw: float, pitch: float):
	# Begrenzung des Pitch (Neigung nach oben/unten)
	pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
	_total_pitch += pitch

	rotate_y(deg_to_rad(yaw))
	rotate_object_local(Vector3(1, 0, 0), deg_to_rad(pitch))

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
