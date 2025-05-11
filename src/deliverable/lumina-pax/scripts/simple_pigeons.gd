extends Node3D

signal stopped

func start_flying():
	var path_follows = get_pigeons_path_follows()
	
	for path_follow in path_follows:
		path_follow.start_flying()
		
func stop_flying():
	var path_follows = get_pigeons_path_follows()
	
	for path_follow in path_follows:
		path_follow.request_stop_flying()
		
	# wait for the last pigeon
	await path_follows[path_follows.size() - 1].flying_stoped
	emit_signal("stopped")
		
func get_pigeons_path_follows():
	var paths = get_children()
	var path_follows = []
	
	for path in paths:
		if path is Path3D:
			var path_follow = path.get_children()[0]
			path_follows.append(path_follow)
			
	return path_follows
