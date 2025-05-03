extends CanvasLayer

@onready var distortion_grid = $"DistortionControl"

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			match event.keycode:
				KEY_TAB:
					distortion_grid.visible = not distortion_grid.visible
					if(distortion_grid.visible):
						Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					else:
						Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				KEY_ESCAPE:
					distortion_grid._init_points()
					distortion_grid._apply_offsets_to_shader()
