extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var plane = $Plane
@onready var plane_board = $"../pinboard3_with_notes/Plane_001"
var starting_position: Vector3  # Anfangsposition der Plane
signal animation_finished

func _ready() -> void:
	#plane.visible = false
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func start_folding() -> void:
	plane_board.visible = false
	plane.visible = true
	
	var start_pos = plane.position
	var pos_right_up = start_pos + Vector3(0.9, 0.9, 0)  # nach rechts und oben
	var pos_forward = pos_right_up + Vector3(0, 0, 2)  # danach nach vorne

	var tween = get_tree().create_tween()
	tween.tween_property(plane, "position", pos_right_up, 2)  # Schritt 1
	#tween.tween_interval(2.0)  # Schritt 2: Wartezeit
	tween.tween_property(plane, "position", pos_forward, 2)  # Schritt 3
	tween.tween_interval(2.0)  # Schritt 4: Wartezeit
	tween.connect("finished", Callable(self, "_start_animation"))  # Schritt 5: Start Animation

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
