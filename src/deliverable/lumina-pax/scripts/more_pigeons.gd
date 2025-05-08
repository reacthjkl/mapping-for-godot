extends Node3D

var animationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ready")
	animationPlayer = $AnimationPlayers
	turteln()

# Function to play animations in sequence with loops
func turteln() -> void:
	# Loop the "HeadLeftRight" animation 3 times
	for i in range(3):
		animationPlayer.play("HeadLeftRight")
		print("Looping HeadLeftRight: ", i + 1)
		await get_tree().create_timer(1.0).timeout

	print("Finished looping HeadLeftRight")

	# Wait for 1 second before starting the next animation loop
	await get_tree().create_timer(1.0).timeout

	# Loop the "HeadUpDown" animation 3 times
	for i in range(3):
		animationPlayer.play("HeadUpDown")
		print("Looping HeadUpDown: ", i + 1)
		await get_tree().create_timer(1.0).timeout

	print("Finished looping HeadUpDown")

	# Wait for 1 second before playing the final animation
	await get_tree().create_timer(1.0).timeout

	# Play the "MovingWings" animation
	animationPlayer.play("MovingWings")
	print("Playing MovingWings")
	await get_tree().create_timer(2.0).timeout
	
	for i in range(3):
		animationPlayer.play("HeadLeftRight")
		print("Looping HeadLeftRight: ", i + 1)
		await get_tree().create_timer(1.0).timeout

	print("Finished looping HeadLeftRight")
