extends Node3D

@export var pigeon: MeshInstance3D
@export var origami_plane: MeshInstance3D
@export var light: OmniLight3D

@onready var anim = $AnimationPlayer

#----Audio----------
@export var _blue_flash_player: AudioStreamPlayer3D
@export var _flying_player: AudioStreamPlayer3D

signal transition_finished

func request_transition():

	
	# fade out folded pigeon
	var tween = create_tween()
	tween.tween_property(origami_plane, "transparency", 1.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	pigeon.visible = true
	pigeon.transparency = 1.0
	pigeon.global_position = origami_plane.global_position
	pigeon.global_position += Vector3(-0.1, -0.1, 0.0)
	reset_origami()
	#start animation
	anim.get_animation("ArmatureAction").loop = true
	anim.play("ArmatureAction")
	

	_blue_flash_player.play()
	
	tween = create_tween()
	var tween2 = create_tween()
	tween.tween_property(pigeon, "transparency", 0.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(light, "light_energy", 3.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	origami_plane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var tween3 = create_tween()
	tween3.tween_property(light, "light_energy", 0.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	emit_signal("transition_finished")

func fly_away():

	
	# Kurze Wartezeit vor dem Abflug
	await get_tree().create_timer(0.3).timeout

	_flying_player.play()
	
	# Gleichzeitig: Flugbewegung per Tween starten
	var tween = get_tree().create_tween()
	var start_pos = global_transform.origin
	var end_pos = start_pos + Vector3(6, 1, 1)  
	tween.tween_property(self, "global_transform:origin", end_pos, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	_flying_player.stop()
	
func reset_origami():
	origami_plane.transparency = 0.0
	origami_plane.visible = true
	origami_plane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
