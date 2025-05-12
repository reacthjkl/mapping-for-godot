extends Node3D

signal lights_out_completed
signal lights_in_completed

@onready var lights_node = $"../Lights" # Zugang zum Environment-Node (oder direkt von einem anderen Platz)
@onready var blue_spot = $"../Lights/BlueSpot"
@onready var red_spot = $"../Lights/RedSpot"
@onready var main_light = $"../Lights/MainLight"
@onready var top_light = $"../Lights/TopLight"
var original_light_energies: Dictionary = {}

@export var _origami_love_player: AudioStreamPlayer3D
@export var _waiting_music_player: AudioStreamPlayer3D

func music_fade_out(duration):
	var target_volume = -80.0
	var time = 0.0
	var volume_now = _origami_love_player.volume_db
	while time < duration:
		var t = time / duration  # t geht von 0 bis 1
		_origami_love_player.volume_db = lerp(volume_now, target_volume, t)  # Verwende lerp mit float
		await get_tree().process_frame
		time += get_process_delta_time()
	time = 0.0
	_origami_love_player.stop() 
	
func waiting_music_fade_out(duration):
	var target_volume = -60.0
	var time = 0.0
	var volume_now = _waiting_music_player.volume_db
	while time < duration:
		var t = time / duration  # t geht von 0 bis 1
		_waiting_music_player.volume_db = lerp(volume_now, target_volume, t)  # Verwende lerp mit float
		await get_tree().process_frame
		time += get_process_delta_time()
	time = 0.0
	_waiting_music_player.stop() 
	
func lights_fade_out(duration):
	var target_lights = {
		blue_spot: 2.5,
		red_spot: 1.0,
		main_light: 0.3,
		top_light: 0.3
	}
	var time = 0.0
	original_light_energies.clear()
	for light in lights_node.get_children():
		if light is SpotLight3D or light is OmniLight3D:
			original_light_energies[light] = light.light_energy
			var start_lights = float(light.light_energy)  # Sicherstellen, dass der Wert als float behandelt wird
			while time < duration:
				var t = time / duration  # t geht von 0 bis 1
				light.light_energy = lerp(start_lights, target_lights[light], t)  # Verwende lerp mit float
				await get_tree().process_frame
				time += get_process_delta_time()
			time = 0.0
	emit_signal("lights_out_completed")
	
func music_start(value):
	_origami_love_player.volume_db = value
	_origami_love_player.play()
	
func waiting_music_start(value):
	_waiting_music_player.volume_db = value
	_waiting_music_player.play()
	
func lights_fade_in(duration):
	var time = 0.0
	for light in lights_node.get_children():
		if light is SpotLight3D or light is OmniLight3D:
			var target_lights = original_light_energies.get(light, 1.0)
			var start_lights = float(light.light_energy)  # Sicherstellen, dass der Wert als float behandelt wird
			while time < duration:
				var t = time / duration  # t geht von 0 bis 1
				light.light_energy = lerp(start_lights, target_lights, t)  # Verwende lerp mit float
				await get_tree().process_frame
				time += get_process_delta_time()
			time = 0.0
	emit_signal("lights_in_completed")
	
func reset_waiting_music(value):
	_waiting_music_player.volume_db = value
