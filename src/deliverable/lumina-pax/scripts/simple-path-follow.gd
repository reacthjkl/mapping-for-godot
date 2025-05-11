extends PathFollow3D

@export var speed = 0.08

#state
var flying
var stop_requested
var flyingIn

var pause_before_circle_fly = 0.0

signal flyingStopped

func _process(delta: float) -> void:
	if flying: 
		
		var increment = speed * delta
		
		# means pigeon is flying in and has to start to fly in the circle
		if $"../..".unsingInOutPath and (progress_ratio + increment) >= 0.5 and not stop_requested:
			$"../..".switchPath()
			progress_ratio = 0.0
		#means pigeon is flying in the circle and needs to stop, so switch the path 
		elif (not $"../..".unsingInOutPath) and ((progress_ratio + increment) >= 1.0) and stop_requested:
			$"../..".switchPath()
			progress_ratio = 0.5
		# means pegeon is flying out and needs to stop
		elif $"../..".unsingInOutPath and (progress_ratio + increment) >= 1.0 and stop_requested:
			#stop flying
			progress_ratio = 0.0
			flying = false
			stop_requested = false
			emit_signal("flyingStopped")
		else:
			progress_ratio += increment
		

	
func start_flying():
	flying = true
	flyingIn = true
	
func request_stop_flying():
	stop_requested = true
