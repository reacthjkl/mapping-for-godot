extends PathFollow3D

@onready var animationPlayer = $"pigeon-lightRose/AnimationPlayer"
@onready var pigeon = $"pigeon-lightRose"  # Adjust the path according to your scene
@export var speed: float = 2  # Adjust flight speed
var flying = false
var sitting = true
var stop_requested = false
var started_sitting_emitted = false

signal flying_stopped
signal started_sitting

func _process(delta):
	if flying: 
		# Move along the path
		progress += speed * delta
		
		if not animationPlayer.is_playing():
			animationPlayer.play("Flying")

	var path_length = get_parent().get_curve().get_baked_length()
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
		# Check if pigeon is valid and has the function
			if pigeon and pigeon.has_method("turteln"):                                         
				print("executed turteln")
				pigeon.turteln()
			else:
				print("Error: Pigeon node or turte_ratio ln function not found!")
			
			
func start_flying():
	visible = true
	flying = true
	started_sitting_emitted = false 
	animationPlayer.play("Flying")
	
func fly_away():
	visible = false

func request_stop_flying():
	stop_requested = true
	
func reset():
	progress = 0
	pigeon.stopTurteln()
