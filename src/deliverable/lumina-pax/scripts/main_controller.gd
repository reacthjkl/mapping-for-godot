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
				
func _run_sequence():
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
	
	# origami Faltungen, zeitversetzt TODO: BELEUCHTUNG ORIGAMI FUNKT. NICHT RICHTIG. SHADER?

	#Faltung des Zweigs
	$"../action_pigeons/pigeon_folding_branch/Plane".visible = true	
	$"../action_pigeons/pigeon_folding_branch".start_folding()
	await $"../action_pigeons/pigeon_folding_branch".animation_finished
	# Gefaltete Origami-Taube ausblenden
	$"../action_pigeons/pigeon_folding_branch/Plane".visible = false
	# Animierte Taube anzeigen und abfliegen lassen
	$"../Pigeons/pigeon-pink/Armature/Skeleton3D/Plane".visible = true
	$"../Pigeons/pigeon-pink".fly_away()


	#Faltung des Herzen
	$"../action_pigeons/pigeon_folding_heart/Plane".visible = true	
	$"../action_pigeons/pigeon_folding_heart".start_folding()
	await $"../action_pigeons/pigeon_folding_heart".animation_finished
	# Gefaltete Origami-Taube ausblenden
	$"../action_pigeons/pigeon_folding_heart/Plane".visible = false
	# Animierte Taube anzeigen und abfliegen lassen
	$"../Pigeons/pigeon-black/Armature/Skeleton3D/Plane".visible = true
	$"../Pigeons/pigeon-black".fly_away()

	#Faltung der Taube
	$"../action_pigeons/pigeon_folding_pidgeon/Plane".visible = true	
	$"../action_pigeons/pigeon_folding_pidgeon".start_folding()
	await $"../action_pigeons/pigeon_folding_pidgeon".animation_finished
	# Gefaltete Origami-Taube ausblenden
	$"../action_pigeons/pigeon_folding_pidgeon/Plane".visible = false
	# Animierte Taube anzeigen und abfliegen lassen
	$"../Pigeons/pigeon-red/Armature/Skeleton3D/Plane".visible = true
	$"../Pigeons/pigeon-red".fly_away()
	
	# pinboard diappears
	$"../pinboard3_with_notes".disappear()
	await $"../pinboard3_with_notes".transition_completed
	
	#TODO: control flying volume 
	# 8 tauben fliegen aus dem portal rein und bewegen sich im kreis await
	$"../SimplePigeons".start_flying()
	
	await get_tree().create_timer(8.0).timeout
	
	
	# tauben turteln, spot light auf dieses paar, particles anmachen
	$"../TurtelPigeons/TurtrelPigeonPath/TurtrelPigeonPathFollow3D".start_flying()
	$"../TurtelPigeons/TurtrelPigeonPath2/TurtrelPigeonPathFollow3D".start_flying()
	
	#second pigeon started sitting, emmiting hearts
	await $"../TurtelPigeons/TurtrelPigeonPath2/TurtrelPigeonPathFollow3D".started_sitting
	$"../ParticleController".emitParticles(10.0)
	await $"../ParticleController".stopped
	
	$"../TurtelPigeons/TurtrelPigeonPath/TurtrelPigeonPathFollow3D".fly_away()
	$"../TurtelPigeons/TurtrelPigeonPath2/TurtrelPigeonPathFollow3D".fly_away()

	# rausfliegen
	$"../SimplePigeons".request_stop_flying()
	await $"../SimplePigeons".flying_stoped
	
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
	
	#pinboard
	$"../pinboard3_with_notes".reset_position()
	$"../pinboard3_with_notes/Plane".reset_drawing()
	$"../pinboard3_with_notes/Plane_002".reset_drawing()
	$"../pinboard3_with_notes/Plane_001".reset_drawing()
	
	#loving pigeons
	$"../TurtelPigeons/TurtrelPigeonPath/TurtrelPigeonPathFollow3D".reset()
	$"../TurtelPigeons/TurtrelPigeonPath2/TurtrelPigeonPathFollow3D".reset()

	#picking pigeon and branch
	$"../action_pigeons/pigeon_picking".reset_position()
	$"../action_pigeons/branch_falling".reset_position()

	#folding drawings
	$"../action_pigeons/pigeon_folding_heart".reset_position()
	$"../action_pigeons/pigeon_folding_pidgeon".reset_position()
	$"../action_pigeons/pigeon_folding_branch".reset_position()

	#reset volume
	#TODO: reset flying volume @lena
	
	# start idle animation
	$"../Wall__IdleWaveController".play()
	
	#TODO: fix light playing here @marina, @illia
	$"../Light_Controller".play()
	$"../Fade_Controller".waiting_music_start(waiting_music_default_vol)
	
	isPlayingSequence = false
