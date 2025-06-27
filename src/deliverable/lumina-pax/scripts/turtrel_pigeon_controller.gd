extends Node3D


@export var turtelPath: Path3D
@export var flyOutPath: Path3D
@export var follower: PathFollow3D
@export var usingTurtelPath = true

signal flyingStopped

func _ready() -> void:
	setPath()
	
func setPath() -> void:
	# Remember its world-transform to prevent sudden jumps.
	var world_t = follower.global_transform
	# Remove follower from its current parent.
	follower.get_parent().remove_child(follower)
	
	var new_parent
	if usingTurtelPath:
		new_parent = turtelPath
		follower.is_exit_path = false   # On turtel (regular) path.
	else:
		new_parent = flyOutPath
		follower.is_exit_path = true    # Set exit path flag when switching to flyOutPath.
		
	new_parent.add_child(follower)
	# Restore the follower's world transform.
	follower.global_transform = world_t

	
func switchPath() -> void:
	usingTurtelPath = not usingTurtelPath
	setPath()
	
func start_flying():
	follower.start_flying()
	
func request_stop_flying():       
	follower.request_stop_flying()
	await follower.flyingStopped
	emit_signal("flyingStopped")
