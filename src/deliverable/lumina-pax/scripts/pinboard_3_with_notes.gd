extends Node3D

@export var positionWhenUp = Vector3(1.3, 1.2, -0.4)

#state
var isUp = false
var inTransition = false
var moveSpeed = 0.75
var starting_position
var targetPosition
var transition_elapsed := 0.0
var transition_time := 6.0  # duration in seconds
var transition_start := Vector3.ZERO

signal transition_completed


func _ready() -> void:
	starting_position = position
	
func _process(delta: float) -> void:
	if inTransition:
		_updatePosition(delta)
	
func showUp():
	if not isUp and not inTransition:
		inTransition = true
		transition_elapsed = 0.0
		transition_start = global_position
		targetPosition = positionWhenUp
	
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
	position = starting_position
	isUp = false
	

func disappear():
	if isUp and not inTransition:
		inTransition = true
		transition_elapsed = 0.0
		transition_start = global_position
		targetPosition = starting_position
