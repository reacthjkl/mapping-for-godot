extends Node3D

signal lights_out_completed
signal lights_in_completed

@onready var lights_node = $"../Lights" # Zugang zum Environment-Node (oder direkt von einem anderen Platz)
@onready var blue_spot = $"../Lights/BlueSpot"
@onready var red_spot = $"../Lights/RedSpot"
@onready var main_light = $"../Lights/MainLight"
@onready var top_light = $"../Lights/TopLight"
var original_light_energies: Dictionary = {}
const FADE_DURATION = 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Ersetze dies mit dem Funktionskörper

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_fade_out():
	music_fade_out()
	lights_fade_out()
	
func start_fade_in():
	music_fade_in()
	lights_fade_in()
	
func music_fade_out():
	pass
	
func lights_fade_out():
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
			while time < FADE_DURATION:
				var t = time / FADE_DURATION  # t geht von 0 bis 1
				light.light_energy = lerp(start_lights, target_lights[light], t)  # Verwende lerp mit float
				await get_tree().process_frame
				time += get_process_delta_time()
			time = 0.0
	emit_signal("lights_out_completed")
	
func music_fade_in():
	pass
	
func lights_fade_in():
	var time = 0.0
	for light in lights_node.get_children():
		if light is SpotLight3D or light is OmniLight3D:
			var target_lights = original_light_energies.get(light, 1.0)
			var start_lights = float(light.light_energy)  # Sicherstellen, dass der Wert als float behandelt wird
			while time < FADE_DURATION:
				var t = time / FADE_DURATION  # t geht von 0 bis 1
				light.light_energy = lerp(start_lights, target_lights, t)  # Verwende lerp mit float
				await get_tree().process_frame
				time += get_process_delta_time()
			time = 0.0
	emit_signal("lights_in_completed")
