extends Node3D

@onready var animationPlayer = $AnimationPlayer

# Function to play animations in sequence with loops
func turteln() -> void:
	while true:
		# head-left‐right 3×
		for i in range(3):
			animationPlayer.play("HeadLeftRight")
			await get_tree().create_timer(1.0).timeout
		await get_tree().create_timer(1.0).timeout

		# head-up‐down 3×
		for i in range(3):
			animationPlayer.play("HeadUpDown")
			await get_tree().create_timer(1.0).timeout
		await get_tree().create_timer(1.0).timeout

		# moving wings once
		animationPlayer.play("MovingWings")
		await get_tree().create_timer(2.0).timeout

		# head-left‐right 3× again
		for i in range(3):
			animationPlayer.play("HeadLeftRight")
		await get_tree().create_timer(1.0).timeout
		# loop back to top automatically

	
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
	animationPlayer.play("sitting2")
	
