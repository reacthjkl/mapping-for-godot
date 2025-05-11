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
	#
	# lights down
	$"../Fade_Controller".lights_fade_out(2)
	$"../Fade_Controller".music_fade_out(2)
	await $"../Fade_Controller".lights_out_completed
	
	# waiting music fade out
	
	await get_tree().create_timer(5.0).timeout
	
	# turn on lights, TODO: start music + wait 2 sec
	$"../Fade_Controller".lights_fade_in(5)
	$"../Fade_Controller".music_start()
	await $"../Fade_Controller".lights_in_completed
	await get_tree().create_timer(2.0).timeout
	
	# open wall
	$"../Wall__OpeningController".open()
	await $"../Wall__OpeningController".pinboard_signal
	
	 #bring the empty pinboard + wait 2 sec
	$"../pinboard3_with_notes".showUp()
	await $"../pinboard3_with_notes".transition_completed
	await get_tree().create_timer(2.0).timeout
	
	# draw images, play drawing sounds + wait 2 sec
	$"../pinboard3_with_notes/Plane_002".start_drawing($"../Audio/Soundeffects/Draw Branch")
	await $"../pinboard3_with_notes/Plane_002".start_next_picture
	$"../pinboard3_with_notes/Plane_001".start_drawing($"../Audio/Soundeffects/Draw Heart")
	await $"../pinboard3_with_notes/Plane_001".start_next_picture
	$"../pinboard3_with_notes/Plane".start_drawing($"../Audio/Soundeffects/Draw Pigeon")
	await $"../pinboard3_with_notes/Plane".pictures_done
	await get_tree().create_timer(2.0).timeout
	
	# origami Faltungen, zeitversetzt
	
	# pinboard diappears
	$"../pinboard3_with_notes".disappear()
	await $"../pinboard3_with_notes".transition_completed
	
	# replace tauben (transiotion not prio nr. 1)
	
	# start path following für 4 tauben: die 3 tauben setzten sich auf die steine, 1 taube fliegt
	
	# 8 tauben fliegen aus dem portal rein und bewegen sich im kreis await
	
	$"../SimplePigeons".start_flying()
	
	# tauben turteln, spot light auf dieses paar, particles anmachen
	
	# branch fällt
	$"../branch_falling".start_falling()  # Hier starten wir den Fall
	await $"../branch_falling".fall_completed
		
	# eine taube, die fliegt, fängt ein branch, setzt sich und pickt
	
	# x3 await
	
	# rausfliegen
	await get_tree().create_timer(15.0).timeout
	$"../SimplePigeons".request_stop_flying()
	await $"../SimplePigeons".flying_stoped
	
	# close wall, lights down + wait 5 sec
	$"../Wall__OpeningController".close()
	await $"../Wall__OpeningController".finished
	$"../Fade_Controller".lights_fade_out(1.0)
	await $"../Fade_Controller".lights_out_completed
	$"../Fade_Controller".music_fade_out(3.0)
	await get_tree().create_timer(5.0).timeout
	
	# turn on lights
	$"../Fade_Controller".lights_fade_in(1.0)
	await $"../Fade_Controller".lights_in_completed
	
	# end, reset values
	$"../pinboard3_with_notes".reset_position()
	$"../pinboard3_with_notes/Plane".reset_drawing()
	$"../pinboard3_with_notes/Plane_002".reset_drawing()
	$"../pinboard3_with_notes/Plane_001".reset_drawing()
	$"../branch_falling".reset_position()
	
	# start idle animation
	$"../Wall__IdleWaveController".play()
	
	isPlayingSequence = false
	

	
