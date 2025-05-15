extends ColorRect

@export var speed:   float = 0.5    # how fast the wave expands
@export var width:   float = 0.15    # thickness of the wave front (in UV space)
@export var amp:     float = 0.01   # maximum distortion offset
@export var center:  Vector2 = Vector2(0.4, 0.5)  # shock origin in UV space

var time_accum: float = 0.0

var shock_wave_requested = false

func _process(delta: float) -> void:
	if not shock_wave_requested:
		visible = false
		return 

	time_accum += delta

	# Grab and cast the material
	var mat := material as ShaderMaterial
	if not mat:
		return

	# Updated API calls:
	mat.set_shader_parameter("time",   time_accum)
	mat.set_shader_parameter("center", center)
	mat.set_shader_parameter("speed",  speed)
	mat.set_shader_parameter("width",  width)
	mat.set_shader_parameter("amp",    amp)
	
func request_shock_wave():
	shock_wave_requested = true
	visible = true
	
func reset():
	shock_wave_requested = false
	time_accum = 0.0
	
