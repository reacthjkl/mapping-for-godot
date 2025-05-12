extends Node3D

var isPlayingSequence = false


func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				if not isPlayingSequence:
					_run_sequence()
					isPlayingSequence = true
					
			KEY_B: 
				$"../branch_falling".start_falling()
				
			KEY_F:
				$"../pigeon_folding_new".start_folding()
				
func _run_sequence():
	
 
	 #stop idle animation
	$"../Wall__IdleWaveController".stop()
	await $"../Wall__IdleWaveController".stoped
	
	# wait for 10 sec, music fade out, lights down
	
	# open wall, TODO: lights up, start music
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
	
	
	# origami Faltungen, zeitversetzt TODO: BELEUCHTUNG ORIGAMI FUNKT. NICHT RICHTIG. SHADER?

	

	#Faltung des Zweigs
	$"../pigeon_folding_branch/Plane".visible = true	
	$"../pigeon_folding_branch".start_folding()
	await $"../pigeon_folding_branch".animation_finished
	# Gefaltete Origami-Taube ausblenden
	$"../pigeon_folding_branch/Plane".visible = false
	# Animierte Taube anzeigen und abfliegen lassen
	$"../Pigeons/pigeon-pink/Armature/Skeleton3D/Plane".visible = true
	$"../Pigeons/pigeon-pink".fly_away()


	#Faltung des Herzen
	$"../pigeon_folding_heart/Plane".visible = true	
	$"../pigeon_folding_heart".start_folding()
	await $"../pigeon_folding_heart".animation_finished
	# Gefaltete Origami-Taube ausblenden
	$"../pigeon_folding_heart/Plane".visible = false
	# Animierte Taube anzeigen und abfliegen lassen
	$"../Pigeons/pigeon-black/Armature/Skeleton3D/Plane".visible = true
	$"../Pigeons/pigeon-black".fly_away()
	

	#Faltung der Taube
	$"../pigeon_folding_pidgeon/Plane".visible = true	
	$"../pigeon_folding_pidgeon".start_folding()
	await $"../pigeon_folding_pidgeon".animation_finished
	# Gefaltete Origami-Taube ausblenden
	$"../pigeon_folding_pidgeon/Plane".visible = false
	# Animierte Taube anzeigen und abfliegen lassen
	$"../Pigeons/pigeon-red/Armature/Skeleton3D/Plane".visible = true
	$"../Pigeons/pigeon-red".fly_away()
	

	
	
	# Abflug Taube (branch)

	
	
	
	# await
	
	# replace tauben (transiotion not prio nr. 1)
	
	# start path following für 4 tauben: die 3 tauben setzten sich auf die steine, 1 taube fliegt
	
	# 8 tauben fliegen aus dem portal rein und bewegen sich im kreis await
	$"../Pigeons/Path3D/PathFollow3D".start_flying()
	
	await get_tree().create_timer(2.0).timeout
	
	# tauben turteln, spot light auf dieses paar, particles anmachen

	# branch fällt
	
	# branch fällt
	print("Zweig fällt...")
	$"../branch_falling".start_falling()  # Hier starten wir den Fall
	await $"../branch_falling".fall_completed
	print("Zweig ist unten angekommen.")

	
	
	
	
	# eine taube, die fliegt, fängt ein branch, setzt sich und pickt
	
	# x3 await
	
	# rausfliegen
	$"../Pigeons/Path3D/PathFollow3D".request_stop_flying()
	await $"../Pigeons/Path3D/PathFollow3D".flying_stoped
	
	# close wall
	$"../Wall__OpeningController".close()
	await $"../Wall__OpeningController".finished
	
	# start idle animation
	$"../Wall__IdleWaveController".play()
	
	isPlayingSequence = false
	
	# end, reset values
	$"../pinboard3_with_notes".reset_position()
	$"../pinboard3_with_notes/Plane".reset_drawing()
	$"../pinboard3_with_notes/Plane_002".reset_drawing()
	$"../pinboard3_with_notes/Plane_001".reset_drawing()
	$"../branch_falling".reset_position()
