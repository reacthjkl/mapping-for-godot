extends Node3D

@export var fall_duration: float = 10.0           # gewünschte Fallzeit in Sekunden
@export var wind_min_strength: float = 0.008      # anfängliche Windstärke
@export var wind_max_strength: float = 0.05       # maximale Windstärke
@export var wind_increase_rate: float = 0.005     # Zunahme der Windstärke pro Sekunde
@export var oscillation_frequency: float = 3.0    # Wind-Oszillationsfrequenz
@export var fade_duration: float = 0.5            # Zeit für das sanfte „Faden“ am Ende

# Faktor für die Z-Amplitude (kleiner als 1 → weniger Auslenkung in Z)
@export var wind_z_factor: float = 0.5            

signal fall_completed

var starting_position: Vector3
var starting_rotation: Vector3
var target_position: Vector3 = Vector3(0.91, 0.66, 0.18)

var time_in_air: float = 0.0
var in_fall: bool = false

var velocity: Vector3 = Vector3.ZERO
var gravity: float = 0.0
var wind_strength: float = 0.0

func _ready() -> void:
	starting_position = global_transform.origin
	starting_rotation = rotation

func start_falling() -> void:
	# Reset
	global_transform.origin = starting_position
	rotation = starting_rotation
	time_in_air = 0.0
	in_fall = true
	wind_strength = wind_min_strength

	# Gravitation so berechnen, dass Höhe in fall_duration zurückgelegt wird
	var drop = starting_position.y - target_position.y
	gravity = 2.0 * drop / pow(fall_duration, 2)

	# Horizontale Geschwindigkeit so setzen, dass x & z in derselben Zeit ankommen
	velocity.x = (target_position.x - starting_position.x) / fall_duration
	velocity.z = (target_position.z - starting_position.z) / fall_duration
	velocity.y = 0.0

func _process(delta: float) -> void:
	if not in_fall:
		return

	time_in_air += delta

	# Windstärke langsam erhöhen (bis max)
	wind_strength = clamp(wind_strength + wind_increase_rate * delta,
						  wind_min_strength,
						  wind_max_strength)

	# Elliptischer Wind-Offset mit reduzierter Z-Amplitude
	var phase = time_in_air * oscillation_frequency
	var wind_offset = Vector3(
		sin(phase) * wind_strength,                          # X-Amplitude voll
		0.0,
		sin(phase + PI / 2) * wind_strength * wind_z_factor   # Z-Amplitude reduziert
	)

	# Gravitation auf Y
	velocity.y -= gravity * delta

	# Bewegung plus Wind
	global_transform.origin += velocity * delta + wind_offset

	# Ende-Bedingung
	if time_in_air >= fall_duration or global_transform.origin.y <= target_position.y:
		in_fall = false
		# sanftes Faden zur exakten Endposition
		var tween = get_tree().create_tween()
		var action = tween.tween_property(self, "global_transform:origin",
										  target_position, fade_duration)
		action.set_trans(Tween.TRANS_SINE)
		action.set_ease(Tween.EASE_IN_OUT)
		tween.connect("finished", Callable(self, "_on_fade_complete"))

func _on_fade_complete() -> void:
	global_transform.origin = target_position
	emit_signal("fall_completed")

func reset_position() -> void:
	in_fall = false
	global_transform.origin = starting_position
	rotation = starting_rotation
