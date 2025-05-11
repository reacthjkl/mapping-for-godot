extends Node3D

signal flying_stoped

var controllers = []

#--Audio-------
@export var _flying_player: AudioStreamPlayer3D

func _ready():
	controllers = get_children()
	
func start_flying():
	for controller in controllers:
		controller.start_flying()
	_flying_player.play()
		
func request_stop_flying():
	for controller in controllers:
		controller.request_stop_flying()
		
	await controllers[controllers.size() - 1].flyingStopped
	emit_signal("flying_stoped")
	
	_flying_player.stop()
