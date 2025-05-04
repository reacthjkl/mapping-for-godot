extends Node3D

var isPlayingSequence = false


func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:#
				if not isPlayingSequence:
					_run_sequence()
					isPlayingSequence = true
					
				
func _run_sequence():
	# stop idle animation
	$"../Wall__IdleWaveController".stop()
	await $"../Wall__IdleWaveController".stoped
	
	# open wall
	$"../Wall__OpeningController".open()
	await $"../Wall__OpeningController".pinboard_signal
	
	# bring the pinboard
	$"../Pinboard".showUp()
	await $"../Pinboard".transition_completed
	
	
