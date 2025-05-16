extends Node3D

@onready var taube = $"."  # Das Skript ist direkt an der Taube
@onready var zweig = $"../branch_falling"  # Der Zweig
@onready var schnabel = $Marker3D  # Marker an der Taube (z. B. Schnabel)
@onready var marker_zweig = $"../branch_falling/Marker3D"  # Marker am Zweig
@onready var animation_player = $"AnimationPlayer"

#-----Audio-----------
@export var _picking_player: AudioStreamPlayer3D
@export var _picken_gurren_player: AudioStreamPlayer3D
@export var _flying_player: AudioStreamPlayer3D

var taube_start_position: Vector3
var zweig_original_parent: Node
var zweig_start_position: Vector3
var zweig_start_rotation: Vector3

signal _taube_hat_zweig_erreicht_signal

func _ready() -> void:
	taube_start_position = taube.position
	zweig_start_position = zweig.global_position
	zweig_start_rotation = zweig.rotation
	zweig_original_parent = zweig.get_parent()

func start_fliegen():
	animation_player.play("ArmatureAction")
	_flying_player.play()

	var schnabel_offset = schnabel.global_transform.origin - taube.global_transform.origin
	var ziel_position = marker_zweig.global_transform.origin - schnabel_offset

	var tween = create_tween()
	tween.tween_property(taube, "position", ziel_position, 5.0)
	tween.connect("finished", Callable(self, "_taube_hat_zweig_erreicht"))

func _taube_hat_zweig_erreicht():
	emit_signal("_taube_hat_zweig_erreicht_signal")
	var marker_global = marker_zweig.global_transform
	var schnabel_global = schnabel.global_transform

	var offset_to_schnabel = schnabel_global.origin - marker_global.origin
	var neue_position = zweig.global_position + offset_to_schnabel

	zweig.global_position = neue_position
	zweig.reparent(schnabel)
	zweig.rotation = Vector3.ZERO
	_picking_player.play()
	_picken_gurren_player.play()

	var weiter_position = taube.position + Vector3(5, 2, 5)
	var tween = create_tween()
	tween.tween_property(taube, "position", weiter_position, 5.0)
	_flying_player.stop()

# 
func reset_position() -> void:
	# Taube zurücksetzen
	taube.position = taube_start_position

	# Zweig wieder an seinen Ursprungs-Parent anhängen
	if zweig.get_parent() != zweig_original_parent:
		zweig.reparent(zweig_original_parent)

	# Zweig zurücksetzen
	zweig.global_position = zweig_start_position
	zweig.rotation = zweig_start_rotation

	# Animation stoppen
	if animation_player.is_playing():
		animation_player.stop()
