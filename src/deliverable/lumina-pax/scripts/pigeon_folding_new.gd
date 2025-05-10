extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var plane = $Plane
@onready var plane_board = $"../pinboard3_with_notes/Plane_001"

signal animation_finished

func _ready() -> void:
	plane.visible = false  # Plane unsichtbar machen
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	

func start_folding() -> void:
	plane_board.visible = false
	if animation_player.has_animation("KeyAction"):
		animation_player.play("KeyAction")
	else:
		push_warning("Animation 'KeyAction' nicht gefunden!")

func _on_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished")
