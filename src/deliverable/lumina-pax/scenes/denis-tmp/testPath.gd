extends Node3D

@onready var animationPlayer = $AnimationPlayer

@export var rotation_for_turteln: float
@export var offset_for_turteln: float
@export var stop_turteln_requested: bool

@export var initial_plane_rotation: Vector3

signal canStopTurtreln
var has_flight_happened = false
func _ready():
	animationPlayer.animation_finished.connect(_on_animation_finished)
	initial_plane_rotation = $Armature/Skeleton3D/Plane.rotation
	
func reset():
	$Armature/Skeleton3D/Plane.rotation = initial_plane_rotation
	
# Function to play animations in sequence with loops
func turteln() -> void:
	var current_position = $Armature/Skeleton3D/Plane.global_position
	$Armature/Skeleton3D/Plane.global_position = Vector3(current_position.x + offset_for_turteln, current_position.y, current_position.z)
	$Armature/Skeleton3D/Plane.rotation = Vector3(0.0, rotation_for_turteln, 0.0)
	
	while true:
		if stop_turteln_requested:
			stop_turteln_requested = false
			break
		
		# head-left‐right 3×
		for i in range(3):
			animationPlayer.play("HeadLeftRight")
			
			if stop_turteln_requested:
				stop_turteln_requested = false
				return
			await get_tree().create_timer(1.0).timeout
		if stop_turteln_requested:
			stop_turteln_requested = false
			break
		await get_tree().create_timer(1.0).timeout
		
		# head-up‐down 3×
		for i in range(3):
			animationPlayer.play("HeadUpDown")
			
			if stop_turteln_requested:
				stop_turteln_requested = false
				return
			await get_tree().create_timer(1.0).timeout
		if stop_turteln_requested:
			stop_turteln_requested = false
			break
		await get_tree().create_timer(1.0).timeout

		# moving wings once
		animationPlayer.play("MovingWings")
		if stop_turteln_requested:
			stop_turteln_requested = false
			break
		await get_tree().create_timer(2.0).timeout

		# head-left‐right 3× again
		for i in range(3):
			animationPlayer.play("HeadLeftRight")
			if stop_turteln_requested:
				stop_turteln_requested = false
				return
		await get_tree().create_timer(1.0).timeout
		# loop back to top automatically
	print("raus aus der Schleife")
		
		
func _on_animation_finished(anim_name: String):
	print("Animation finished:", anim_name)

	# Example: Stop flying after "Flying" animation ends
	if anim_name == "HeadUpDown" or anim_name == "MovingWings" or anim_name == "HeadLeftRight":
		emit_signal("canStopTurtreln")
	
func stopTurteln():
	stop_turteln_requested = true
	await canStopTurtreln
	reset()                                  
	
	
	
func fliegenUndPicken():
	animationPlayer.play("FliegenUndPicken")
	
func picken():
	animationPlayer.play("Picken")

func sittingTakingOff():
	animationPlayer.play("SittingTakingOff")

func takingOff1():
	animationPlayer.play("TakingOff1")

func takingOff2():
	animationPlayer.play("TakingOff2")
	
func sitting1():
	animationPlayer.play("sitting1")
	
func sitting2():
	animationPlayer.get_animation("sitting2").loop = false
