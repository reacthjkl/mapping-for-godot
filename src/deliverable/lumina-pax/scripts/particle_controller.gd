extends Node3D

signal stopped

#-----Audio-----------
@export var _bubbles_player: AudioStreamPlayer3D
	
func emitParticles(duration: float) -> void:
	var time_elapsed := 0.0
	$red_hearts.emitting = true
	_bubbles_player.play()
	
	while time_elapsed < duration:
		await get_tree().process_frame
		time_elapsed += get_process_delta_time()
	
	$red_hearts.emitting = false
	emit_signal("stopped")
	_bubbles_player.stop()
