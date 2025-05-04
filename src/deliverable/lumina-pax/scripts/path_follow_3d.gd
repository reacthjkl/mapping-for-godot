# Attach this to your PathFollow3D
extends PathFollow3D

@export var speed: float = 0.1  # “paths per second”

func _ready():
	$AnimationPlayer.play("fly_circle")

func _process(delta):
	progress_ratio += speed * delta
	if progress_ratio >= 1.0:
		progress_ratio -= 1.0
