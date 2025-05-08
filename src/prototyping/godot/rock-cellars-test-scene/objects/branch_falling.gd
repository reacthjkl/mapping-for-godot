
extends Node3D

@export var fall_speed: float = 2.0
@export var reset_height: float = 5.0  # Höhe, zu der der Zweig zurückspringt
@export var lower_limit: float = -10.0  # Wenn der Zweig so tief fällt, wird er zurückgesetzt
@export var gravity: float = 9.8  # Schwerkraft (kann angepasst werden)
@export var max_distance: float = 3.0  # Maximale horizontale Distanz, die der Zweig zurücklegt

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Variablen für den Bogen
var velocity: Vector3 = Vector3.ZERO
var time_in_air: float = 0.0

func _ready():
	animation_player.play("ArmatureAction")  # spiele Animation ab

# Hier wird die Fallbewegung berechnet
func _process(delta):
	# Berechne die Schwerkraftbewegung (y-Richtung)
	velocity.y -= gravity * delta
	position.y += velocity.y * delta  # Bewegung in der y-Achse (nach unten)

	# Berechne die horizontale Bewegung (Bogen)
	time_in_air += delta  # Zähle die Zeit, wie lange der Zweig schon fällt
	position.x = sin(time_in_air) * max_distance  # Sinus-Funktion für den Bogen (x-Achse)
	position.z = cos(time_in_air) * max_distance  # Cosinus-Funktion für den Bogen (z-Achse)

	# Wenn der Zweig zu tief fällt, zurück nach oben setzen (Loop)
	if position.y < lower_limit:
		position.y = reset_height
		velocity = Vector3.ZERO  # Setze Geschwindigkeit zurück
		time_in_air = 0  # Zurücksetzen der Zeit
