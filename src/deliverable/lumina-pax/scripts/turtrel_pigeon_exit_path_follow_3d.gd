extends PathFollow3D

@export var speed: float = 2.0
var flying: bool = false

func start_exit():
	flying = true
	progress = 0  # Reset progress along the new path

func _process(delta):
	if flying:

		progress += speed * delta
		if progress >= get_parent().curve.get_baked_length():
			flying = false
			print("Pigeon has reached the end of the exit path!")
			# Optionally, you can hide or remove the pigeon here (e.g., queue_free()).
