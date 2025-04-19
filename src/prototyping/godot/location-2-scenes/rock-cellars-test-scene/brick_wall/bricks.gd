extends Node3D

@export var wave_controller_path: NodePath    # Path to your WaveController node
var wc                                        # WaveController reference

func _ready() -> void:
	if wave_controller_path != NodePath() and has_node(wave_controller_path):
		wc = get_node(wave_controller_path)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				if wc:
					wc.play()
			KEY_SHIFT:
				if wc:
					wc.stop()
