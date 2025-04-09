extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		$pillars_scene/AnimationPlayer.play("Cube-animAction")
	elif Input.is_action_just_pressed("ui_cancel"):  # "ui_cancel" is mapped to R below
		$pillars_scene/AnimationPlayer.play_backwards("Cube-animAction")
	
