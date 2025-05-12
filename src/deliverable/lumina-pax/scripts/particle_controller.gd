extends Node3D

signal stopped
	
func emitParticles(duration: float) -> void:
	var time_elapsed := 0.0
	$red_hearts.emitting = true
	
	while time_elapsed < duration:
		await get_tree().process_frame
		time_elapsed += get_process_delta_time()
	
	$red_hearts.emitting = false
	emit_signal("stopped")
