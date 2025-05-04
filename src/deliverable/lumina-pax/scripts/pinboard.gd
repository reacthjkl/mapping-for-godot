extends Node3D

var isUp = false
var inTransition = false
var targetPosition = Vector3(1.5, 1.2, -0.14)
var moveSpeed = 0.75

signal transition_completed


func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	_updatePosition(delta)
	
func showUp():
	if not isUp and not inTransition:
		inTransition = true
	
func _updatePosition(delta: float) -> void:
	if inTransition:
		var direction = (targetPosition - global_position).normalized()
		var distance = global_position.distance_to(targetPosition)
		var step = moveSpeed * delta

		if step >= distance:
			global_position = targetPosition
			isUp = true
			inTransition = false
			emit_signal("transition_completed")
		else:
			global_position += direction * step
	
