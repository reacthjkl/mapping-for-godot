extends Node3D

signal stopped

@onready var red_follow = $Path3D_Red_Light/PathFollow3D_Red
@onready var blue_follow = $Path3D_Blue_Light/PathFollow3D_Blue
@onready var red_light = $"../Lights/RedSpot"
@onready var blue_light = $"../Lights/BlueSpot"

var speed = 1.0
var max_progress_red = 0.0
var max_progress_blue = 0.0

var is_playing = false
var should_stop = false
var red_done = false
var blue_done = false

func _ready():
	red_follow.loop = true
	blue_follow.loop = true
	
func play():
	is_playing = true
	should_stop = false
	
	red_done = false
	blue_done = false
	
func stop():
	should_stop = true
	
func _process(delta):
	if red_done and blue_done:
		is_playing = false
		emit_signal("stopped")
		reset()
		
	if not is_playing:
		return
	
	if not red_done:
		red_follow.progress += speed * delta
		red_light.global_position = red_follow.global_position
	
	if not blue_done:
		blue_follow.progress += speed * delta
		blue_light.global_position = blue_follow.global_position
		
	# Länge vom Pfad
	var max_progress_red = red_follow.get_parent().curve.get_baked_length()
	var max_progress_blue = blue_follow.get_parent().curve.get_baked_length()
	

	if should_stop:
		red_follow.loop = false
		blue_follow.loop = false
		if red_follow.progress >= max_progress_red:
			red_done = true
		if blue_follow.progress >= max_progress_blue:
			blue_done = true

func reset():
	# Reset progre
	# Reset position and progress
	red_follow.progress = 0.0
	blue_follow.progress = 0.0

	red_light.global_position = red_follow.global_position
	blue_light.global_position = blue_follow.global_position

	# Reset other states
	red_done = false
	blue_done = false
	is_playing = false
	should_stop = false

	red_follow.loop = true
	blue_follow.loop = true
	
	
