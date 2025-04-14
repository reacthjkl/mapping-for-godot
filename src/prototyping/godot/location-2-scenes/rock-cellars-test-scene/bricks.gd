extends Node3D

@export var move_distance: float = 0.01
@export var move_speed: float = 1.0

func _ready():
	for cube in get_children():
		if cube is MeshInstance3D:  # Make sure it's a mesh
			move_cube_forward(cube)

func move_cube_forward(cube):
	await get_tree().create_timer(randf_range(0, 1)).timeout  # Random delay
	
	var tween = get_tree().create_tween().set_loops()
	var start_pos = cube.position
	var target_pos = start_pos + Vector3(0, 0, move_distance)  # Always forward
	var duration = move_speed + randf_range(-0.5, 0.5)

	tween.tween_property(cube, "position", target_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cube, "position", start_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
