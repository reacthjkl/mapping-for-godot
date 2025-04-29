extends CanvasLayer

@onready var distortion_grid = $"Distortion Control"

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			match event.keycode:
				KEY_TAB:
					distortion_grid.visible = not distortion_grid.visible
