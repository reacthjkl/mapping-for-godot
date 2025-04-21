extends Node3D
class_name WallIdleWaveController

@export var bricks_root_path: NodePath                     # Node containing MeshInstance3D bricks
@export var bricks_audio_player_path: NodePath             # AudioStreamPlayer3D for wave sounds
@export var bg_track_audio_player_path: NodePath           # AudioStreamPlayer3D for background music
@export var auto_start: bool = true                        # Start waves automatically
@export var bg_fade_duration: float = 2.0                  # seconds for fade in/out of background music

# ----- Wave & Visual Settings -----
@export var amplitude: float = 0.2                         # forward distance
@export var wave_duration: float = 1.6                     # seconds forward → back
@export var delay_per_unit: float = 1.65                    # delay per unit distance
@export var delay_per_wave: float = 4.0                    # pause between waves
@export var brightness_max: float = 1.2                    # max brightness multiplier
@export var noise_strength: float = 0.05                   # noise amplitude
@export var noise_scale: float = 2.0                       # noise frequency scale
@export var brick_texture: Texture2D                       # texture applied to every brick

# ----- Internal State -----
var _bricks: Array[MeshInstance3D]            = []
var _orig_positions: Array[Vector3]           = []
var _offsets: Array[float]                    = []
var _materials: Array[StandardMaterial3D]     = []
var _noise: FastNoiseLite
var _time: float                              = 0.0
var _max_wave_time: float                     = 0.0

# ----- Audio & Fade State -----
var _bricks_player: AudioStreamPlayer3D
var _bg_player: AudioStreamPlayer3D
var _initial_bg_volume_db: float              = 0.0
var _is_playing: bool                         = false
var _stop_requested: bool                     = false
var _fading_in: bool                          = false
var _fading_out: bool                         = false
var _fade_elapsed: float                      = 0.0

# =============================================================
#                       LIFECYCLE
# =============================================================
func _ready() -> void:
	randomize()
	_setup_noise()
	_cache_audio_players()
	_initialize_bricks()
	set_process(false)              # start disabled; play() enables
	if auto_start:
		play()

func _setup_noise() -> void:
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = noise_scale
	_noise.seed = randi()

func _cache_audio_players() -> void:
	if bricks_audio_player_path != NodePath():
		_bricks_player = get_node_or_null(bricks_audio_player_path)
	if not _bricks_player and has_node("AudioStreamPlayer3D"):
		_bricks_player = get_node("AudioStreamPlayer3D")

	if bg_track_audio_player_path != NodePath():
		_bg_player = get_node_or_null(bg_track_audio_player_path)
	if not _bg_player and has_node("BG_MusicPlayer"):
		_bg_player = get_node("BG_MusicPlayer")

	if _bg_player:
		_initial_bg_volume_db = _bg_player.volume_db

func _initialize_bricks() -> void:
	var root: Node3D = self
	if bricks_root_path != NodePath():
		var maybe_root = get_node_or_null(bricks_root_path)
		if maybe_root and maybe_root is Node3D:
			root = maybe_root

	for child in root.get_children():
		if child is MeshInstance3D:
			var brick := child as MeshInstance3D
			_bricks.append(brick)
			_orig_positions.append(brick.position)

			# Ensure every brick has its own material with the texture assigned
			var mat: StandardMaterial3D
			if brick.material_override and brick.material_override is StandardMaterial3D:
				mat = brick.material_override as StandardMaterial3D
			else:
				var surf_mat = brick.get_active_material(0)
				if surf_mat and surf_mat is StandardMaterial3D:
					mat = (surf_mat as StandardMaterial3D).duplicate()
				else:
					mat = StandardMaterial3D.new()

			if brick_texture:
				mat.albedo_texture = brick_texture
			mat.albedo_color = Color(1,1,1)
			brick.material_override = mat
			_materials.append(mat)

# =============================================================
#                        PUBLIC API
# =============================================================
func play() -> void:
	# Fade‑in background music
	if _bg_player:
		_bg_player.volume_db = -80.0
		_bg_player.play()
		_fading_in = true
		_fading_out = false
		_fade_elapsed = 0.0

	# Start wave system
	_time = 0.0
	_offsets.clear()
	_start_wave()
	_is_playing = true
	_stop_requested = false
	set_process(true)

func stop() -> void:
	if _is_playing:
		_stop_requested = true

# =============================================================
#                        MAIN LOOP
# =============================================================
func _process(delta: float) -> void:
	_handle_fades(delta)

	if not _is_playing:
		return

	_update_waves(delta)

	if _time >= _max_wave_time:
		if _stop_requested:
			_is_playing = false
			_stop_requested = false
			if _bg_player:
				_fading_out = true
				_fading_in = false
				_fade_elapsed = 0.0
		else:
			_start_wave()

func _handle_fades(delta: float) -> void:
	if _fading_in and _bg_player:
		_fade_elapsed += delta
		var t = clamp(_fade_elapsed / bg_fade_duration, 0.0, 1.0)
		_bg_player.volume_db = lerp(-80.0, _initial_bg_volume_db, t)
		if t >= 1.0:
			_fading_in = false

	if _fading_out and _bg_player:
		_fade_elapsed += delta
		var t2 = clamp(_fade_elapsed / bg_fade_duration, 0.0, 1.0)
		_bg_player.volume_db = lerp(_initial_bg_volume_db, -80.0, t2)
		if t2 >= 1.0:
			_bg_player.stop()
			_fading_out = false
			set_process(false)   # disable processing once everything is done

func _update_waves(delta: float) -> void:
	# 1) Advance the master timer that drives the whole wave.
	_time += delta
	
	# 2) Move every brick.
	for i in range(_bricks.size()):
		var brick = _bricks[i]
		var mat = _materials[i]
		
		# Each brick starts later depending on its delay offset.
		var t_local = _time - _offsets[i]
		if t_local >= 0.0 and t_local < wave_duration:
			
			# Inside the wave window → push brick forward.
			var off = amplitude * sin(PI * t_local / wave_duration)
			off += noise_strength * _noise.get_noise_3d(_orig_positions[i].x, _orig_positions[i].y, _time)
			
			# Add some subtle noise so the motion isn’t perfectly uniform.
			brick.position = _orig_positions[i] + Vector3(0, 0, off)
			
			# Brighten the brick the further it moves.
			if mat:
				var factor = lerp(1.0, brightness_max, clamp(off / amplitude, 0.0, 1.0))
				mat.albedo_color = Color(factor, factor, factor)
		else:
			# Outside the window → snap back to start position & colour.
			brick.position = _orig_positions[i]
			if mat:
				mat.albedo_color = Color(1,1,1)

func _start_wave() -> void:
	if _bricks_player:
		_bricks_player.play()

	_offsets.clear()
	var max_off := 0.0
	var center_idx := randi() % _bricks.size()
	var center_pos := _orig_positions[center_idx]
	for pos in _orig_positions:
		var off := pos.distance_to(center_pos) * delay_per_unit + randf_range(-0.2, 0.2)
		_offsets.append(off)
		max_off = max(max_off, off)
	_max_wave_time = max_off + wave_duration + delay_per_wave
	_time = 0.0
