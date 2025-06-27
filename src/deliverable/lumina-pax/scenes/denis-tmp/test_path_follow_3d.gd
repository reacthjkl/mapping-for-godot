extends PathFollow3D

# This flag tells the script when the pigeon is on its exit (fly-out) path.
@export var is_exit_path: bool = false

@onready var exit_path = $"../TurtrelPigeonExitPath/TurtrelPigeonExitPathFollow3D"
@onready var animationPlayer = $"pigeon-lightRose/AnimationPlayer"
@onready var pigeon = $"pigeon-lightRose"  # Adjust this path as needed.
@export var speed: float = 2  # Adjust flight speed as desired.

var flying = false
var sitting = true
var stop_requested = false
var started_sitting_emitted = false

signal flying_stopped
signal started_sitting

func _process(delta):
	if flying:
		# Update progress along the path
		progress += speed * delta
		var path_length = get_parent().get_curve().get_baked_length()
		
		if is_exit_path:
			# For exit path: use TakingOff2 for the first 20% of the path,
			# then switch to Flying.
			if progress < 0.05 * path_length:
				if animationPlayer.current_animation != "TakingOff2":
					animationPlayer.play("TakingOff2")
			else:
				if animationPlayer.current_animation != "Flying":
					animationPlayer.play("Flying")
		else:
			# Retain original non-exit behavior.
			if not animationPlayer.is_playing():
				animationPlayer.play("Flying")
			
			if progress >= path_length - 0.7 and not started_sitting_emitted:
				animationPlayer.play("TakingOff1")  # Start landing earlier
			
			if progress >= path_length - 0.1:
				if not started_sitting_emitted:
					flying = false
					sitting = true
					animationPlayer.play("sitting2")
					print("is sitting")
					emit_signal("started_sitting")
					started_sitting_emitted = true 
					if pigeon and pigeon.has_method("turteln"):
						print("executed turteln")
						pigeon.turteln()
					else:
						print("Error: Pigeon node or turteln function not found!")
	
func start_flying():
	visible = true
	flying = true
	started_sitting_emitted = false
	progress = 0  # Reset progress at the start of flight
	# IMPORTANT: If on exit path, first ensure any turteln loop is stopped
	if is_exit_path:
		if pigeon and pigeon.has_method("stopTurteln"):
			pigeon.stopTurteln()
		animationPlayer.play("TakingOff2")
	else:
		animationPlayer.play("Flying")
	
func fly_away():
	visible = false

func request_stop_flying():
	stop_requested = true

func reset():
	progress = 0
