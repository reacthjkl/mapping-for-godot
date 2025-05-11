extends Node3D

@export var positionWhenUp = Vector3(1.3, 1.2, -0.14)

#state
var isUp = false
var inTransition = false
var moveSpeed = 0.75
var starting_position
var targetPosition

signal transition_completed


func _ready() -> void:
	starting_position = position
	
func _process(delta: float) -> void:
	if inTransition:
		_updatePosition(delta)
	
func showUp():
	if not isUp and not inTransition:
		inTransition = true
		targetPosition = positionWhenUp
		
func disappear():
	if isUp and not inTransition:
		inTransition = true
		targetPosition = starting_position
	
func _updatePosition(delta: float) -> void:
	var direction = (targetPosition - position).normalized()
	var distance = position.distance_to(targetPosition)
	var step = moveSpeed * delta

	if step >= distance:
		position = targetPosition
		isUp = true
		inTransition = false
		emit_signal("transition_completed")
	else:
		position += direction * step
			
func reset_position():
	position = starting_position
	isUp = false
	
