extends Node3D

signal lights_completed

@onready var lights_node = $"../Lights" # Zugang zum Environment-Node (oder direkt von einem anderen Platz)
const FADE_DURATION = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Ersetze dies mit dem Funktionskörper

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_fade_out():
	music_fade_out()
	lights_fade_out()
	
func music_fade_out():
	pass
	
func lights_fade_out():
	var target_lights = 0.2  # Ziel-Helligkeit auf 30% setzen
	var time = 0.0
	for light in lights_node.get_children():
		if (light is SpotLight3D or light is OmniLight3D) and light != $"../Lights/RedSpot" and light != $"./Lights/BlueSpot":
			var start_lights = float(light.light_energy)  # Sicherstellen, dass der Wert als float behandelt wird
			while time < FADE_DURATION:
				var t = time / FADE_DURATION  # t geht von 0 bis 1
				light.light_energy = lerp(start_lights, target_lights, t)  # Verwende lerp mit float
				await get_tree().process_frame
				time += get_process_delta_time()
			time = 0.0
	emit_signal("lights_out_completed")
	

	
