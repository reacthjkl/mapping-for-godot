extends Node3D

@export var inOutPath: Path3D
@export var circlePath: Path3D
@export var follower: PathFollow3D
@export var unsingInOutPath = true

signal flyingStopped

func _ready() -> void:
	setPath()
	
	
func setPath() -> void:
	# Remember its world‐transform (so it doesn't jump unexpectedly)
	var world_t = follower.global_transform
	
	# Remove from current parent and add under the other
	follower.get_parent().remove_child(follower)
	
	var new_parent
	if unsingInOutPath:
		new_parent = inOutPath
	else:
		new_parent = circlePath
		
	new_parent.add_child(follower)
	
	# Restore its world‐transform so it stays put
	follower.global_transform = world_t
	
func switchPath() -> void:
	unsingInOutPath = not unsingInOutPath
	setPath()
	
func start_flying():
	follower.start_flying()
	
func request_stop_flying():
	follower.request_stop_flying()
	await follower.flyingStopped
	emit_signal("flyingStopped")
