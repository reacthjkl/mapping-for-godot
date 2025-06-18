extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var plane: Node3D = $Plane
@onready var plane_board: Node3D = $"../../pinboard3_with_notes/Heart_Drawing"

#------Audio--------
@export var _folding_player: AudioStreamPlayer3D

signal animation_finished

var starting_position: Vector3
var starting_rotation: Vector3

func _ready() -> void:
	
	# Startwerte sichern
	starting_position = plane.global_transform.origin
	starting_rotation = plane.rotation

	plane.visible = false
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func start_folding() -> void:
	plane_board.visible = false
	plane.visible = true

	var start_pos = plane.global_transform.origin
	var dir_right_up = Vector3(0.3, 0.4, 0)
	var dir_forward = Vector3(0, 0, 1)

	var pos_right_up = start_pos + dir_right_up
	var pos_forward = pos_right_up + dir_forward

	var tween = get_tree().create_tween()
	tween.tween_property(plane, "global_transform:origin", pos_right_up, 2.0)
	tween.tween_property(plane, "global_transform:origin", pos_forward,  2.0)
	tween.tween_interval(2.0)
	tween.connect("finished", Callable(self, "_start_animation"))

func _start_animation() -> void:
	if not animation_player.has_animation("KeyAction"):
		push_warning("Animation 'KeyAction' nicht gefunden!")
		return

	# Animationslänge ermitteln
	var anim_length = animation_player.get_animation("KeyAction").length

	# Spin um die lokale X-Achse über die Animationsdauer
	var spin_tween = get_tree().create_tween()
	var action = spin_tween.tween_property(
		plane,
		"rotation:x",
		plane.rotation.x + TAU,   # 360° in Radiant
		anim_length
	)
	action.set_trans(Tween.TRANS_LINEAR)
	action.set_ease(Tween.EASE_IN_OUT)

	# Animation & Audio
	animation_player.play("KeyAction")
	_folding_player.play()

func _on_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished")
	_folding_player.stop()

func reset_position() -> void:
	plane.global_transform.origin = starting_position
	plane.rotation = starting_rotation
	plane.visible = false
	plane_board.visible = true
	if animation_player.is_playing():
		animation_player.stop()
