extends Node3D

@export var gravity: float = 9.8
@export var max_distance: float = 3.0
@export var lower_limit: float = -10.0
@export var fall_curve_amplitude: float = 1.5
@export var move_speed: float = 1.5  # Geschwindigkeit der Bewegung zur Zielposition

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
		# Bewegungsrichtung berechnen
		var direction = (targetPosition - position).normalized()
		var distance = position.distance_to(targetPosition)
		var step = move_speed * delta

		# Wenn der Zweig nahe genug am Ziel ist, stoppe die Bewegung
		if step >= distance:
			position = targetPosition
			inTransition = false
			emit_signal("fall_completed")  # Signal senden, wenn die Bewegung abgeschlossen ist
		else:
			# Der Zweig bewegt sich in Richtung Ziel
			position += direction * step
