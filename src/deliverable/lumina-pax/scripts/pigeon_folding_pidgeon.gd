extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var plane = $Plane
@onready var plane_board = $"../pinboard3_with_notes/Plane"

signal animation_finished

var starting_position: Vector3  # Anfangsposition der Plane

func _ready() -> void:
	starting_position = plane.global_transform.origin  # Position merken
	plane.visible = false
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func start_folding() -> void:
	plane_board.visible = false
	plane.visible = true

	var start_pos = plane.global_transform.origin
	var dir_right_up = Vector3(0, -0.2 , 0)
	var dir_forward = Vector3(0, 0, 1)

	var pos_right_up = start_pos + dir_right_up
	var pos_forward = pos_right_up + dir_forward

	var tween = get_tree().create_tween()
	tween.tween_property(plane, "global_transform:origin", pos_right_up, 2)
	tween.tween_property(plane, "global_transform:origin", pos_forward, 2)
	tween.tween_interval(2.0)
	tween.connect("finished", Callable(self, "_start_animation"))

func _start_animation() -> void:
	if animation_player.has_animation("KeyAction"):
		animation_player.play("KeyAction")
	else:
		push_warning("Animation 'KeyAction' nicht gefunden!")

func _on_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished")

func reset_position() -> void:
	plane.global_transform.origin = starting_position
	plane.visible = false
	plane_board.visible = true
	if animation_player.is_playing():
		animation_player.stop()
