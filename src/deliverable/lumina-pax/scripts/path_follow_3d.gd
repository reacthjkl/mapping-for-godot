# Attach this to your PathFollow3D
extends PathFollow3D

@export var speed: float = 0.03  # “paths per second”

var flying = false
var stop_requested = false

var pigeon

signal flying_stoped

func _ready():
	pigeon = get_children()[0]
	pigeon.visible = false
	

	
func _process(delta):
	if flying: 
		var current_state = progress_ratio + 0.03 * delta
		progress_ratio = current_state
		
		if current_state >= 1.0 and stop_requested:
			stop_flying()
			
			
func start_flying():
	flying = true
	pigeon.visible = true
	
func stop_flying():
	flying = false
	stop_requested = false
	pigeon.visible = false
	progress_ratio = 0.0
	emit_signal("flying_stoped")
	
func request_stop_flying():
	stop_requested = true
