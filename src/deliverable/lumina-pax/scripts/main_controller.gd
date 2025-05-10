extends Node3D

var isPlayingSequence = false


func _ready() -> void:
	$"../Wall__IdleWaveController".play()
	
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				if not isPlayingSequence:
					_run_sequence()
				
func _run_sequence():
	isPlayingSequence = true
	
	#stop idle animation
	$"../Wall__IdleWaveController".stop()
	await $"../Wall__IdleWaveController".stoped
	
	# wait for 10 sec, music fade out, lights down
	#await get_tree().create_timer(10.0).timeout
	$"../Fade_Controller".start_fade_out()
	await $"../Fade_Controller".lights_out_completed
	
	# TODO: turn on lights, start music
	await get_tree().create_timer(10.0).timeout
	$"../Fade_Controller".start_fade_in()
	await $"../Fade_Controller".lights_in_completed
	
	# open wall
	await get_tree().create_timer(3.0).timeout
	$"../Wall__OpeningController".open()
	await $"../Wall__OpeningController".pinboard_signal
	
	 #bring the empty pinboard
	$"../pinboard3_with_notes".showUp()
	await $"../pinboard3_with_notes".transition_completed
	
	# draw images, play drawing sounds
	# await 
	$"../pinboard3_with_notes/Plane_002".start_drawing()
	await $"../pinboard3_with_notes/Plane_002".start_next_picture
	$"../pinboard3_with_notes/Plane_001".start_drawing()
	await $"../pinboard3_with_notes/Plane_001".start_next_picture
	$"../pinboard3_with_notes/Plane".start_drawing()
	await $"../pinboard3_with_notes/Plane".pictures_done
	
	# origami Faltungen, zeitversetzt
	# await
	
	# replace tauben (transiotion not prio nr. 1)
	
	# start path following für 4 tauben: die 3 tauben setzten sich auf die steine, 1 taube fliegt
	
	# 8 tauben fliegen aus dem portal rein und bewegen sich im kreis await
	
	$"../SimplePigeons".start_flying()
	
	# tauben turteln, spot light auf dieses paar, particles anmachen
	
	# branch fällt
	
	# branch fällt
	$"../branch_falling".start_falling()  # Hier starten wir den Fall
	await $"../branch_falling".fall_completed
		
	# eine taube, die fliegt, fängt ein branch, setzt sich und pickt
	
	# x3 await
	
	# rausfliegen
	$"../SimplePigeons".stop_flying()
	await $"../SimplePigeons".stopped
	
	# close wall
	$"../Wall__OpeningController".close()
	await $"../Wall__OpeningController".finished
	
	# start idle animation
	$"../Wall__IdleWaveController".play()
	
	
	# end, reset values
	$"../pinboard3_with_notes".reset_position()
	$"../pinboard3_with_notes/Plane".reset_drawing()
	$"../pinboard3_with_notes/Plane_002".reset_drawing()
	$"../pinboard3_with_notes/Plane_001".reset_drawing()
	$"../branch_falling".reset_position()
	
	isPlayingSequence = false
	

	
