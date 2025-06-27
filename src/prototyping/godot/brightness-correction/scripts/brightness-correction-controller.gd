extends CanvasLayer
@export var color_rect: ColorRect


func _input(event):
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_O:  
				var currect_val = color_rect.material.get_shader_parameter("correction_strength")
				color_rect.material.set_shader_parameter("correction_strength", currect_val - 0.01)
			KEY_P:
				var currect_val = color_rect.material.get_shader_parameter("correction_strength")
				color_rect.material.set_shader_parameter("correction_strength", currect_val + 0.01)
