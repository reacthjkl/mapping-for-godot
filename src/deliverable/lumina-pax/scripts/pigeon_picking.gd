extends Node3D

# ——— Scene References ———
@onready var taube            = $"."                          
@onready var zweig            = $"../branch_falling"
@onready var schnabel         = $Marker3D
@onready var marker_zweig     = $"../branch_falling/Marker3D"
@onready var animation_player = $"AnimationPlayer"

# ——— Audio ———
@export var _picking_player       : AudioStreamPlayer3D
@export var _picken_gurren_player : AudioStreamPlayer3D
@export var _flying_player        : AudioStreamPlayer3D

# ——— Flug-Parameter zum Tuning im Inspector ———
@export_range(0.0, 10.0, 0.1) var flight_height         : float = 0.005   # Maximale Bogenhöhe
@export_range(0.1, 10.0, 0.1) var flight_duration       : float = 5.0   # Dauer des Rückflugs
@export_range(0.0, 1.0, 0.05) var flight_distance_factor: float = 0.6   # Faktor der Rückflug-Distanz (0.5 = Hälfte)

# ——— Interne Zustände ———
var taube_start_position   : Vector3
var zweig_original_parent  : Node
var zweig_start_position   : Vector3
var zweig_start_rotation   : Vector3

signal _taube_hat_zweig_erreicht_signal
signal flying_stopped

# ——— Für die Parabel-Bewegung ———
var flight_start : Vector3
var flight_end   : Vector3
var flight_t     : float = 0.0
var flying_off   : bool  = false

func _ready() -> void:
	taube_start_position   = taube.position
	zweig_start_position   = zweig.global_position
	zweig_start_rotation   = zweig.rotation
	zweig_original_parent  = zweig.get_parent()

func start_fliegen() -> void:
	animation_player.play("ArmatureAction")
	_flying_player.play()

	var schnabel_offset = schnabel.global_transform.origin - taube.global_transform.origin
	var ziel_position   = marker_zweig.global_transform.origin - schnabel_offset

	var tween = create_tween()
	tween.tween_property(taube, "position", ziel_position, 5.0)
	tween.connect("finished", Callable(self, "_taube_hat_zweig_erreicht"))

func _process(delta: float) -> void:
	if flying_off:
		flight_t = clamp(flight_t + delta/flight_duration, 0.0, 1.0)
		var base_pos = flight_start.lerp(flight_end, flight_t)
		var arc = Vector3.UP * (flight_height * 4.0 * flight_t * (1.0 - flight_t))
		taube.position = base_pos + arc

		if not animation_player.is_playing():
			animation_player.play("Flying")

		if flight_t >= 1.0:
			flying_off = false
			emit_signal("flying_stopped")

func _taube_hat_zweig_erreicht() -> void:
	emit_signal("_taube_hat_zweig_erreicht_signal")

	# Zweig einsammeln
	var marker_global     = marker_zweig.global_transform
	var schnabel_global   = schnabel.global_transform
	var offset_to_schnabel = schnabel_global.origin - marker_global.origin

	zweig.global_position = zweig.global_position + offset_to_schnabel
	zweig.reparent(schnabel)
	zweig.rotation = Vector3.ZERO

	_picking_player.play()
	_picken_gurren_player.play()

	# Parabel-Rückflug starten, jetzt mit gekürzter Distanz
	flight_start = taube.position
	var full_vector = Vector3(6, 1, 5)
	flight_end   = flight_start + full_vector * flight_distance_factor
	flight_t     = 0.0
	flying_off   = true

	_flying_player.stop()

func reset_position() -> void:
	# Taube zurücksetzen
	taube.position           = taube_start_position
	flying_off               = false
	flight_t                 = 0.0

	# Zweig zurück an Original-Parent
	if zweig.get_parent() != zweig_original_parent:
		zweig.reparent(zweig_original_parent)
	zweig.global_position    = zweig_start_position
	zweig.rotation           = zweig_start_rotation

	# Animation & Audio zurücksetzen
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("sitting2")

	_flying_player.stop()
	_picking_player.stop()
	_picken_gurren_player.stop()
