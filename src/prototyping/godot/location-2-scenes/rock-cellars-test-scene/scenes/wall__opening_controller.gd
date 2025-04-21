extends Node3D
class_name WallOpeningController

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
var _time: float                              = 0.0
