extends Node3D

@export var gravity: float = 9.8
@export var max_distance: float = 3.0
@export var lower_limit: float = -10.0
@export var fall_curve_amplitude: float = 1.5
@export var move_speed: float = 0.3  # Geschwindigkeit der Bewegung zur Zielposition
@export var wind_strength: float = 0.003  # Viel geringere Stärke der Windbewegung
@export var oscillation_frequency: float = 7  # Frequenz der Schwingung des Zweigs im Wind

var isFalling = false
var inTransition = false
var velocity: Vector3 = Vector3.ZERO
var time_in_air: float = 0.0
var starting_position: Vector3

# Zielposition, an die der Zweig fallen soll
var targetPosition = Vector3(0.831, 0.7, 0.215)

signal fall_completed

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	starting_position = position
	animation_player.play("ArmatureAction")  # Animation starten

func _process(delta: float) -> void:
	_update_fall(delta)

# Fall starten
func start_falling() -> void:
	if not isFalling and not inTransition:
		isFalling = true
		inTransition = true
		velocity = Vector3.ZERO
		time_in_air = 0.0
		position = starting_position

# Update für den Fall
func _update_fall(delta: float) -> void:
	if inTransition:
		# Zeitbasis für die Schwingung (um eine natürliche Bewegung zu erzeugen)
		time_in_air += delta

		# Berechne den Schwingungseffekt für die X- und Z-Achse (jetzt viel schwächer)
		var wind_offset = Vector3(
			sin(time_in_air * oscillation_frequency) * wind_strength,
			0,  # Keine Schwingung in Y
			sin(time_in_air * oscillation_frequency) * wind_strength
		)

		# Bewegungsrichtung berechnen
		var direction = (targetPosition - position).normalized()
		var distance = position.distance_to(targetPosition)
		var step = move_speed * delta

		# Wenn der Zweig nahe genug am Ziel ist, stoppe die Bewegung
		if step >= distance:
			position = targetPosition + wind_offset  # Ziel + Windoffset
			inTransition = false
			emit_signal("fall_completed")  # Signal senden, wenn die Bewegung abgeschlossen ist
		else:
			# Der Zweig bewegt sich in Richtung Ziel unter Berücksichtigung der Schwingung
			position += direction * step + wind_offset
			
func reset_position():
	position = starting_position
	isFalling = false
	inTransition = false
