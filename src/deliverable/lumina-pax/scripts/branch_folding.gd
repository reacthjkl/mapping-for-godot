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

var targetPosition = Vector3(0.91, 0.62, 0.18)

signal fall_completed

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	starting_position = position
	animation_player.play("ArmatureAction")

func _process(delta: float) -> void:
	_update_fall(delta)

func start_falling() -> void:
	if not isFalling and not inTransition:
		isFalling = true
		inTransition = true
		velocity = Vector3.ZERO
		time_in_air = 0.0
		position = starting_position

func _update_fall(delta: float) -> void:
	if inTransition:
		time_in_air += delta

		var wind_offset = Vector3(
			sin(time_in_air * oscillation_frequency) * wind_strength,
			0,
			sin(time_in_air * oscillation_frequency) * wind_strength
		)

		var direction = (targetPosition - position).normalized()
		var distance = position.distance_to(targetPosition)
		var step = move_speed * delta

		if step >= distance:
			position = targetPosition + wind_offset
			inTransition = false
			emit_signal("fall_completed")
		else:
			position += direction * step + wind_offset


func reset_position() -> void:
	isFalling = false
	inTransition = false
	time_in_air = 0.0
	velocity = Vector3.ZERO
	position = starting_position
