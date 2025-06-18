extends Node3D

var isPlayingSequence = false

var bg_music_default_volume: float
var waiting_music_default_vol: float

func _ready() -> void:
	
	#---------set default values-----------
	bg_music_default_volume = $"../Audio/Music/Origami Love 1".volume_db
	waiting_music_default_vol = $"../Audio/Music/WaitingMode".volume_db
	
	#--------------------------------------
	$"../Wall__IdleWaveController".play()
	$"../Light_Controller".play()
	$"../Fade_Controller".waiting_music_start(waiting_music_default_vol)
	#TODO: start idle music @lena
	
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				if not isPlayingSequence:
					_run_sequence()
	
	if event is InputEventKey and event.pressed:
		match  event.keycode:
			KEY_CTRL:
				Engine.time_scale = 10
		
	if event is InputEventKey and event.is_released():
		match  event.keycode:
			KEY_CTRL:
				Engine.time_scale = 1
				
func _run_sequence():
	Engine.time_scale = 100
	isPlayingSequence = true
	
	#stop idle animation
	$"../Wall__IdleWaveController".stop()
	$"../Light_Controller".stop()
	
	await $"../Wall__IdleWaveController".stoped
	
	#
	# lights down
	$"../Fade_Controller".lights_fade_out(2)
	$"../Fade_Controller".waiting_music_fade_out(4.0)
	#TODO: add fade out for idle music @lena
	await $"../Fade_Controller".lights_out_completed
	# waiting music fade out
	
	
	# turn on lights, TODO: start music + wait 2 sec
	$"../Fade_Controller".music_start(bg_music_default_volume)
	$"../Fade_Controller".lights_fade_in(2)
	await $"../Fade_Controller".lights_in_completed
	
	# open walls
	$"../Wall__OpeningController".open()
	await $"../Wall__OpeningController".finished
	
	#bring the empty pinboard + wait 2 sec
	await get_tree().create_timer(2.0).timeout
	$"../pinboard3_with_notes".showUp()
	await $"../pinboard3_with_notes".transition_completed
	await get_tree().create_timer(2.0).timeout
	
	# draw images, play drawing sounds + wait 2 sec
	$"../pinboard3_with_notes/Branch_Drawing".start_drawing($"../Audio/Soundeffects/Draw Branch")
	await $"../pinboard3_with_notes/Branch_Drawing".start_next_picture
	$"../pinboard3_with_notes/Heart_Drawing".start_drawing($"../Audio/Soundeffects/Draw Heart")
	await $"../pinboard3_with_notes/Heart_Drawing".start_next_picture
	$"../pinboard3_with_notes/Pigeon_Drawing".start_drawing($"../Audio/Soundeffects/Draw Pigeon")
	await $"../pinboard3_with_notes/Pigeon_Drawing".pictures_done
	await get_tree().create_timer(2.0).timeout
	
	Engine.time_scale = 1
	
	#Faltung des Zweigs
	$"../action_pigeons/pigeon_folding_branch/Plane".visible = true	
	$"../action_pigeons/pigeon_folding_branch".start_folding()
	await $"../action_pigeons/pigeon_folding_branch".animation_finished

	
	# Gefaltete Origami-Taube ausblenden, Animierte Taube anzeigen und abfliegen lassen
	var current_pigeon = $"../Pigeons/pigeon-pink"
	current_pigeon.request_transition()
	await current_pigeon.transition_finished
	current_pigeon.fly_away()


	#Faltung des Herzen
	$"../action_pigeons/pigeon_folding_heart/Plane".visible = true	
	$"../action_pigeons/pigeon_folding_heart".start_folding()
	await $"../action_pigeons/pigeon_folding_heart".animation_finished
	
	# Gefaltete Origami-Taube ausblenden, Animierte Taube anzeigen und abfliegen lassen
	current_pigeon = $"../Pigeons/pigeon-black"
	current_pigeon.request_transition()
	await current_pigeon.transition_finished
	current_pigeon.fly_away()

	#Faltung der Taube
	$"../action_pigeons/pigeon_folding_pidgeon/Plane".visible = true	
	$"../action_pigeons/pigeon_folding_pidgeon".start_folding()
	await $"../action_pigeons/pigeon_folding_pidgeon".animation_finished
	
	# Gefaltete Origami-Taube ausblenden, Animierte Taube anzeigen und abfliegen lassen
	current_pigeon = $"../Pigeons/pigeon-red"
	current_pigeon.request_transition()
	await current_pigeon.transition_finished
	current_pigeon.fly_away()
	
	# pinboard diappears
	$"../pinboard3_with_notes".disappear()
	await $"../pinboard3_with_notes".transition_completed
	
	#TODO: control flying volume @lena
	# 8 tauben fliegen aus dem portal rein und bewegen sich im kreis await
	$"../SimplePigeons".start_flying()
	
	await get_tree().create_timer(8.0).timeout
	
	
	# tauben turteln, spot light auf dieses paar, particles anmachen
	$"../TurtelPigeons/TurtrelPigeonPath/TurtrelPigeonPathFollow3D".start_flying()
	$"../TurtelPigeons/TurtrelPigeonPath2/TurtrelPigeonPathFollow3D".start_flying()
	
	#second pigeon started sitting, emmiting hearts
	await $"../TurtelPigeons/TurtrelPigeonPath2/TurtrelPigeonPathFollow3D".started_sitting
	$"../ParticleController".emitParticles(10.0)
	$"../Audio/Soundeffects/Gurren 1".play()
	$"../Audio/Soundeffects/Gurren 2".play()
	await $"../ParticleController".stopped
	
	$"../TurtelPigeons/TurtrelPigeonPath/TurtrelPigeonPathFollow3D".fly_away()
	$"../TurtelPigeons/TurtrelPigeonPath2/TurtrelPigeonPathFollow3D".fly_away()
	$"../Audio/Soundeffects/Gurren 1".stop()
	$"../Audio/Soundeffects/Gurren 2".stop()
	
	# rausfliegen
	$"../SimplePigeons".request_stop_flying()
	#await $"../SimplePigeons".flying_stoped

	# branch fällt
	$"../action_pigeons/branch_falling".start_falling()  # Hier starten wir den Fall
	await $"../action_pigeons/branch_falling".fall_completed
	
	#Taube kommt und holt den Branch 
	$"../action_pigeons/pigeon_picking".start_fliegen()
	await $"../action_pigeons/pigeon_picking"._taube_hat_zweig_erreicht_signal
	
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
	
	# -----------------end, reset values----------------------
	get_tree().reload_current_scene()
