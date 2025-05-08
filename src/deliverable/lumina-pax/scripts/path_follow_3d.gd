# Attach this to your PathFollow3D
extends PathFollow3D

@export var speed: float = 0.03  # “paths per second”

var flying = false
var stop_requested = false

signal flying_stoped
	
func _process(delta):
	if flying: 
		var current_state = progress_ratio + 0.03 * delta
		progress_ratio = current_state
		
		if current_state >= 1.0:
			if not stop_requested:
				progress_ratio -= 1.0
			else:
				flying = false
				stop_requested = false
				emit_signal("flying_stoped")
				
			
func start_flying():
	flying = true
	
func request_stop_flying():
	stop_requested = true
