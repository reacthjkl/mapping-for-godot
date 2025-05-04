extends Node3D
class_name WallOpeningController

# ───────────────── CONFIG ─────────────────
@export var bricks_root_path              : NodePath                # Parent that contains all MeshInstance3D bricks
@export var center_brick                  : Node3D                  # Reference to the anchor brick
@export var radius                        : float          = 0.8
@export var rotate_time                   : float          = 4      # Seconds to reach 90° twist
@export var move_time                     : float          = 8      # Seconds to finish sliding
@export var bricks_audio_player_path      : NodePath                # AudioStreamPlayer3D for sounds
@export var easing_curve: Curve


# ───────────── INTERNAL STATE ─────────────
var _bricks                  : Array[MeshInstance3D] = []
var _orig_positions          : Array[Vector3]        = []
var _slide_targets           : Array[Vector3]        = []
var _state                   : float                 = 0.0    # Animation progress, 0‑1
var _dir                     : int                   = 0      # +1 opening, −1 closing, 0 idle
var _is_open                 : bool                  = false
var _total_time              : float                          # rotate_time + move_time (set in _ready)
var _rotate_portion          : float                          # rotate_time / total_time (set in _ready)
signal pinboard_signal

# ───────────── MUSIC & FX ─────────────
var _bricks_player           : AudioStreamPlayer3D

# ============================================================
#                           LIFECYCLE
# ============================================================
func _ready() -> void:
	_total_time    = rotate_time + move_time
	_rotate_portion = rotate_time / _total_time
	
	easing_curve.bake()

	_collect_bricks()
	_compute_slide_targets()
	_cache_audio_players()

# ------------------------------------------------------------
#   Gather bricks & remember their original transforms
# ------------------------------------------------------------
func _collect_bricks() -> void:
	var root := get_node_or_null(bricks_root_path) as Node3D
	assert(root, "bricks_root_path must point to a Node3D")

	for child in root.get_children():
		if child is MeshInstance3D:
			var brick := child as MeshInstance3D
			_bricks.append(brick)
			_orig_positions.append(brick.position)
			_slide_targets.append(Vector3.ZERO)
			
# ------------------------------------------------------------
#   Decide which bricks are affected & in which way
# ------------------------------------------------------------
func _compute_slide_targets() -> void:
	for i in _bricks.size():
		var off   := _orig_positions[i] - center_brick.position
		# build a Vector2 in “ellipse‑space”
		var norm := Vector2(off.x / radius, off.y / radius)
		
		if norm.length() <= 1.0:
			# distance factor: 1.0 at centre, 0.0 at boundary
			var factor := 1.0 - norm.length()
			# signed direction based on X offset
			var dir = sign(off.x)
			if dir == 0:
				dir = 1
			# final target distance
			var target = dir * factor * 0.7
			_slide_targets[i] = Vector3(target, 0, factor / 4)
		else:
			_slide_targets[i] = Vector3.ZERO

func _cache_audio_players() -> void:
	if bricks_audio_player_path != NodePath():
		_bricks_player = get_node_or_null(bricks_audio_player_path)
	if not _bricks_player and has_node("AudioStreamPlayer3D"):
		_bricks_player = get_node("AudioStreamPlayer3D")

# ============================================================
#                         PUBLIC API
# ============================================================
func open() -> void:
	if _is_open or _dir != 0:
		return
		
	if _bricks_player:
		_bricks_player.play()
		
	_dir   = +1
	_state = 0.0

func close() -> void:
	if not _is_open or _dir != 0:
		return
		
	if _bricks_player:
		_bricks_player.play()
	
	_dir   = -1
	_state = 1.0

# ============================================================
#                         MAIN LOOP
# ============================================================
func _process(delta: float) -> void:
	if _dir == 0:
		return

	_state = clamp(_state + (_dir * delta / _total_time), 0.0, 1.0)
	_update_bricks()

	if _state == 0.0 or _state == 1.0:
		_dir     = 0
		_is_open = _state > 0.5
		
	if(_state > 0.5):
		emit_signal("pinboard_signal")

# ------------------------------------------------------------
#           Apply rotation & translation this frame
# ------------------------------------------------------------
func _update_bricks() -> void:
	var rot_ratio   : float
	var slide_ratio : float
	
	if _state < _rotate_portion:
		rot_ratio   = _state / _rotate_portion
		slide_ratio = 0.0
	else:
		rot_ratio   = 1.0
		slide_ratio = (_state - _rotate_portion) / (1.0 - _rotate_portion)

	for i in _bricks.size():
		var brick := _bricks[i]
		
		var eased_rot   = easing_curve.sample(rot_ratio)
		var eased_slide = easing_curve.sample(slide_ratio)
		
		brick.rotation_degrees.y = 90.0 * eased_rot * sign(_slide_targets[i].x)
		brick.position          = _orig_positions[i] + _slide_targets[i] * eased_slide
