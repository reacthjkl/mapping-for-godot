extends OmniLight3D

@export var fired = false

#----Audio-------------
@export var _wall_flash_player: AudioStreamPlayer3D


func request_flash():
	if not fired:
		_wall_flash_player.play()
		fired = true
		var tween = create_tween()
		tween.tween_property(self, "light_energy", 16.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		
		tween = create_tween()
		tween.tween_property(self, "light_energy", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
	
