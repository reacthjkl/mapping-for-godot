extends Node3D

@export var wave_controller_path: NodePath    # Path to WaveController node
@export var opening_controller_path: NodePath    # Path to OpeningController node

var wc                                        # WaveController reference
var oc                                        # OpeningController reference

func _ready() -> void:
	if wave_controller_path != NodePath() and has_node(wave_controller_path):
		wc = get_node(wave_controller_path)
		
	if opening_controller_path != NodePath() and has_node(opening_controller_path):
		oc = get_node(opening_controller_path)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			match event.keycode:
				KEY_SPACE:
					wc.play()         
				KEY_SHIFT:             
					wc.stop()
