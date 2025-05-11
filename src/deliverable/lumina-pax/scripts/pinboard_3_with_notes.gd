extends Node3D

var isUp = false
var inTransition = false
var initial_target_position = Vector3(1.5, 1.2, -0.14)
var targetPosition = initial_target_position
var moveSpeed = 0.75
var starting_position

var transition_elapsed := 0.0
var transition_time := 4.0  # duration in seconds
var transition_start := Vector3.ZERO

signal transition_completed


func _ready() -> void:
	starting_position = global_position
	
func _process(delta: float) -> void:
	_updatePosition(delta)
	
func showUp():
	if not isUp and not inTransition:
		inTransition = true
		transition_elapsed = 0.0
		transition_start = global_position
		targetPosition = initial_target_position
	
	
func _updatePosition(delta: float) -> void:
	if inTransition:
		transition_elapsed += delta
		var t = transition_elapsed / transition_time
		if t >= 1.0:
			global_position = targetPosition
			isUp = (targetPosition != starting_position)
			inTransition = false
			emit_signal("transition_completed")
		else:
			var eased_t = 0.0
			if targetPosition == starting_position:
				# Ease-in (disappearing): t²
				eased_t = t * t
			else:
				eased_t = -t * (t - 2.0)  # Quadratic ease-out
			global_position = transition_start.lerp(targetPosition, eased_t)
			
func reset_position():
	global_position = starting_position
	isUp = false
	inTransition = false
	targetPosition = initial_target_position
	
func disappear():
	if isUp and not inTransition:
		inTransition = true
		transition_elapsed = 0.0
		transition_start = global_position
		targetPosition = starting_position
