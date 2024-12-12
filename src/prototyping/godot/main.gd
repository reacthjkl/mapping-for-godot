extends Node3D


func _ready() -> void:
	$pillars_scene/AnimationPlayer.play("left animation")
	$pillars_scene/AnimationPlayer.play("right-animation")
	


func _process(delta: float) -> void:
	pass
