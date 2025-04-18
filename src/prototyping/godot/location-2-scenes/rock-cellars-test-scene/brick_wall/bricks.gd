extends Node3D

# --- Wave & Visual Settings ---
@export var amplitude:         float         = 0.1    # max forward distance along Z
@export var wave_duration:     float         = 1.6    # seconds for one brick to go forward→back
@export var delay_per_unit:    float         = 1.0    # seconds delay per unit distance
@export var delay_per_wave:    float         = 4.0    # seconds pause between waves
@export var brightness_max:    float         = 1.2    # max brightness multiplier when fully forward
@export var noise_strength:    float         = 0.05   # amplitude of procedural noise on wave
@export var noise_scale:       float         = 2.0    # scaling for noise frequency

# --- Appearance Settings ---
@export var brick_texture:     Texture2D      # assign your brick texture here

# --- Audio Settings ---
@export var bricks_audio_player_path: NodePath       # path to the AudioStreamPlayer3D for wave sounds
@export var bg_track_audio_player_path: NodePath    

# --- Internal State ---
var _bricks = []                
var _orig_positions = []        
var _offsets = []                
var _materials = []            
var _spawned = []                
var _time = 0.0                 
var _max_wave_time = 0.0        
var _noise: FastNoiseLite       

# --- Node References ---
var bricks_player: AudioStreamPlayer3D
var bg_player: AudioStreamPlayer3D

func _ready() -> void:
	randomize()
	# initialize noise
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = noise_scale
	_noise.seed = randi()

	# cache bricsks audio player
	if bricks_audio_player_path != NodePath():
		bricks_player = get_node_or_null(bricks_audio_player_path) as AudioStreamPlayer3D
	if not bricks_player and has_node("AudioStreamPlayer3D"):
		bricks_player = get_node("AudioStreamPlayer3D") as AudioStreamPlayer3D

	# cache background music player and play looped
	if bg_track_audio_player_path != NodePath():
		bg_player = get_node_or_null(bg_track_audio_player_path) as AudioStreamPlayer3D
	if not bg_player and has_node("BG_MusicPlayer"):  
		bg_player = get_node("BG_MusicPlayer") as AudioStreamPlayer3D
	if bg_player:
		bg_player.play() 

	# cache bricks, positions, duplicate materials, apply texture, init dust flags
	for child in get_children():
		if child is MeshInstance3D:
			var brick = child as MeshInstance3D
			_bricks.append(brick)
			_orig_positions.append(brick.position)
			_spawned.append(false)
			var base_mat = brick.get_active_material(0)
			if base_mat and base_mat is StandardMaterial3D:
				var mat = (base_mat as StandardMaterial3D).duplicate() as StandardMaterial3D
				if brick_texture:
					mat.albedo_texture = brick_texture
				brick.set_surface_override_material(0, mat)
				_materials.append(mat)
			else:
				_materials.append(null)
	_start_wave()

func _process(delta: float) -> void:
	_time += delta

	# animate each brick with noise & brightness
	for i in range(_bricks.size()):
		var brick = _bricks[i]
		var t_local = _time - _offsets[i]
		var mat = _materials[i]
		if t_local >= 0.0 and t_local < wave_duration:
			var angle = PI * (t_local / wave_duration)
			var z_off = amplitude * sin(angle) + noise_strength * _noise.get_noise_3d(_orig_positions[i].x, _orig_positions[i].y, _time)
			brick.position = _orig_positions[i] + Vector3(0, 0, z_off)
			if mat:
				var factor = lerp(1.0, brightness_max, clamp(z_off / amplitude, 0.0, 1.0))
				var c = mat.albedo_color; c.r = factor; c.g = factor; c.b = factor
				mat.albedo_color = c
		else:
			brick.position = _orig_positions[i]
			if mat:
				mat.albedo_color = Color(1,1,1)
			if t_local < 0.0:
				_spawned[i] = false

	if _time >= _max_wave_time:
		_start_wave()

func _start_wave() -> void:
	# play wave sound
	if bricks_player:
		bricks_player.play()
	else:
		printerr("Wave AudioStreamPlayer3D not found at path: %s" % bricks_audio_player_path)

	# compute delays
	_offsets.clear()
	var max_off = 0.0
	var center_idx = randi() % _bricks.size()
	var center_pos = _orig_positions[center_idx]
	for pos in _orig_positions:
		var off = pos.distance_to(center_pos) * delay_per_unit + randf_range(-0.2, 0.2)
		_offsets.append(off)
		max_off = max(max_off, off)
	_max_wave_time = max_off + wave_duration + delay_per_wave
	_time = 0.0
