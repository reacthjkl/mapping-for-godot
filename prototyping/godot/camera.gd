extends Camera3D

var move_speed = 5.0
var rotation_speed = 45.0 # Rotation speed in degrees per second

func _process(delta):
	# Movement with WASD keys
	var movement = Vector3.ZERO
	
	if Input.is_action_pressed("move_left"): # 'A' key
		movement.x += 1
	if Input.is_action_pressed("move_right"): # 'D' key
		movement.x -= 1
	if Input.is_action_pressed("move_forward"): # 'W' key
		movement.z -= 1
	if Input.is_action_pressed("move_backward"): # 'S' key
		movement.z += 1
	
	# Vertical movement with space (up) and shift (down)
	if Input.is_action_pressed("ui_accept"): # Space key (default is "ui_accept")
		movement.y += 1
	if Input.is_action_pressed("ui_cancel"): # Shift key (default is "ui_cancel")
		movement.y -= 1
	
	# Apply movement relative to the camera's orientation
	movement = movement.normalized() * move_speed * delta
	translate(transform.basis.x * movement.x + transform.basis.y * movement.y - transform.basis.z * movement.z)
	
	# Rotation with Up/Down arrow keys
	if Input.is_key_pressed(KEY_UP):
		rotate_x(deg_to_rad(-rotation_speed * delta))
	elif Input.is_key_pressed(KEY_DOWN):
		rotate_x(deg_to_rad(rotation_speed * delta))
