extends Node3D

@export var move_distance: float = 5.0
@export var move_speed: float = 1.0

func _ready():
	for cube in get_children():
		if cube is MeshInstance3D:  # Stelle sicher, dass es ein Mesh ist
			apply_random_color(cube)
			move_cube_randomly(cube)

func move_cube_randomly(cube):
	await get_tree().create_timer(randf_range(0, 1)).timeout  # Zufällige Verzögerung
	
	var tween = get_tree().create_tween().set_loops()
	var start_pos = cube.position
	var target_pos = start_pos + Vector3(move_distance if randf() > 0.5 else -move_distance, 0, 0)
	var duration = move_speed + randf_range(-0.5, 0.5)

	tween.tween_property(cube, "position", target_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cube, "position", start_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func apply_random_color(cube):
	var random_color = Color.from_hsv(randf(), 1.0, 1.0)  # Maximale Sättigung und Helligkeit
	var material = StandardMaterial3D.new()
	material.albedo_color = random_color
	cube.set_surface_override_material(0, material)  # Material auf den Würfel anwenden
