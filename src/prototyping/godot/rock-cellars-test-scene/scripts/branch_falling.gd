# Branch.gd
extends Node3D

# Im Editor anpassbar:
@export var start_position: Vector3 = Vector3(0, 5, 0)
@export var end_position:   Vector3 = Vector3(0, 0, 0)
@export var move_duration:  float    = 2.0

# Name der in Blender/Import vorhandenen Animation:
@export var anim_name: String = "ArmatureAction"

var tween: Tween
var anim_player: AnimationPlayer

func _ready() -> void:
	# 0) Sicherstellen, dass dieser Node und alle Visual-Kinder sichtbar sind
	show()
	for child in get_children():
		if child is VisualInstance3D:
			child.show()

	# 1) Starte an der definierten Position
	global_transform.origin = start_position

	# 2) Referenzen holen
	tween = create_tween()
	anim_player = $AnimationPlayer

func play() -> void:
	# 1) Spiel die importierte Animation ab
	if anim_player.has_animation(anim_name):
		anim_player.play(anim_name)
	else:
		push_warning("Animation '%s' nicht gefunden!" % anim_name)

	# 2) Bewege den Branch von oben nach unten
	tween.kill()               # Alte Tweens entfernen
	tween = create_tween()     # Neuen Tween anlegen
	tween.tween_property(
		self, "global_transform:origin",
		end_position, move_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
