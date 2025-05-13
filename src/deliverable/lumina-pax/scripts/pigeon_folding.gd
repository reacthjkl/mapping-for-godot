extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal animation_finished

func _ready() -> void:
	$Plane.set("blend_shapes/Key 1", 0.0)
	animation_player.connect("animation_finished", _on_animation_finished)

func start_folding() -> void:
	if animation_player.has_animation("KeyAction"):
		animation_player.play("KeyAction")
	else:
		push_warning("Animation 'KeyAction' nicht gefunden!")

func _on_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished")
