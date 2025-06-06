extends OmniLight3D


#----Audio-------------
@export var _wall_flash_player: AudioStreamPlayer3D


func request_flash():
	_wall_flash_player.play()
	var tween = create_tween()
	tween.tween_property(self, "light_energy", 16.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	tween = create_tween()
	tween.tween_property(self, "light_energy", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	

	
