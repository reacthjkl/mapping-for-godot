extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var plane: MeshInstance3D = $Plane
@onready var plane_board: Node3D = $"../../pinboard3_with_notes/Branch_Drawing"

#----Audio--------------
@export var _folding_player: AudioStreamPlayer3D

signal animation_finished

var starting_position: Vector3   # Anfangsposition der Plane
var starting_rotation: Vector3   # Anfangsrotation der Plane

func _ready() -> void:
	# PlaneMesh-Unterteilungen setzen (falls Plane ein PlaneMesh ist)
	if plane.mesh is PlaneMesh:
		var pm := plane.mesh.duplicate() as PlaneMesh
		pm.subdivide_width = 20
		pm.subdivide_depth = 20
		plane.mesh = pm

	# Start-Werte sichern
	starting_position = plane.global_transform.origin
	starting_rotation = plane.rotation

	plane.visible = false
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func start_folding() -> void:
	plane_board.visible = false
	plane.visible = true

	# Bewegung in zwei Schritten (langsamer)
	var start_pos = plane.global_transform.origin
	var pos_right_up = start_pos + Vector3(-0.3, 0, 0)
	var pos_forward = pos_right_up + Vector3(0, 0, 1)

	var move_tween = get_tree().create_tween()
	move_tween.tween_property(plane, "global_transform:origin", pos_right_up, 3.0)
	move_tween.tween_property(plane, "global_transform:origin", pos_forward, 3.0)
	move_tween.tween_interval(2.0)
	move_tween.connect("finished", Callable(self, "_start_animation"))

func _start_animation() -> void:
	if not animation_player.has_animation("KeyAction"):
		push_warning("Animation 'KeyAction' nicht gefunden!")
		return

	# Länge der KeyAction-Animation ermitteln
	var anim_length = animation_player.get_animation("KeyAction").length

	# Langsamer Spin um die eigene Y-Achse über die gesamte Animationsdauer
	var spin_tween = get_tree().create_tween()
	var action = spin_tween.tween_property(
		plane,
		"rotation:x",
		plane.rotation.x + TAU,  # TAU = 2π = 360°
		anim_length
	)
	action.set_trans(Tween.TRANS_LINEAR)
	action.set_ease(Tween.EASE_IN_OUT)

	# Animation und Audio starten
	animation_player.play("KeyAction")
	_folding_player.play()

func _on_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished")
	_folding_player.stop()
	# Rotation steht nach 360°-Drehung wieder im Startwert, daher kein Reset nötig

func reset_position() -> void:
	plane.global_transform.origin = starting_position
	plane.rotation = starting_rotation
	plane.visible = false
	plane_board.visible = true
	if animation_player.is_playing():
		animation_player.stop()
