extends MeshInstance3D

@export var frames : Array[Texture2D]
@export var frame_rate : float = 12.0
@export var drawing_offset : float = 0.3

signal pictures_done
signal start_next_picture

var frame_index := 0
var time_accum := 0.0
var drawing = false

func _ready():
	if not frames.is_empty():
		frame_index = 0
		var mat = mesh.surface_get_material(0)
		if mat: 
			mat.albedo_texture = frames[frame_index]
	
func _process(delta):
	if drawing:
		time_accum += delta
		if time_accum >= 1.0 / frame_rate:
			time_accum = 0
			frame_index += 1

			if frame_index < frames.size():
				$".".mesh.surface_get_material(0).albedo_texture = frames[frame_index]

				# Signal zum Start des nächsten Bildes
				if float(frame_index) / float(frames.size()) >= drawing_offset:
					emit_signal("start_next_picture")
			else:
				# Letzter Frame erreicht → Animation beenden
				drawing = false
				emit_signal("pictures_done")

			
func start_drawing(sound_player):
	drawing = true
	
	sound_player.play()

func reset_drawing():
	frame_index = 0
	var mat = mesh.surface_get_material(0)
	if mat: 
		mat.albedo_texture = frames[frame_index]
		
