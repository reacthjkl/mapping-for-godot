extends Node3D

@export var wave_controller_path: NodePath    # Path to WaveController node
@export var opening_controller_path: NodePath # Path to OpeningController node

var waveController                            # WaveController reference
var openingController                         # OpeningController reference

func _ready() -> void:
	# get controllers
	if wave_controller_path != NodePath() and has_node(wave_controller_path):
		waveController = get_node(wave_controller_path)
		
	if opening_controller_path != NodePath() and has_node(opening_controller_path):
		openingController = get_node(opening_controller_path)
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			match event.keycode:
				KEY_SPACE:
					waveController.play()         
				KEY_SHIFT:             
					waveController.stop()
				KEY_O:
					openingController.open()
				KEY_C:
					openingController.close()
