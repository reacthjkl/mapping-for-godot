extends Node3D

@export var plane: MeshInstance3D
@export var origami_plane: MeshInstance3D

@onready var anim = $AnimationPlayer


func fly_away():
	# Hole die Origami-Taube
	#var origami_plane = get_node_or_null("../../../../pigeon_folding_branch")

	if origami_plane:
		# Übernehme Position und Ausrichtung der Origami-Taube
		global_position = origami_plane.global_position
	else:
		push_warning("Origami-Taube nicht gefunden! Prüfe den Pfad.")
		
	global_position += Vector3(-0.46, -0.02, 0.0)  # Position korrigieren	

	
	# Diese Taube sichtbar machen
	visible = true

	# Verstecke Origami-Mesh innerhalb dieses Objekts (falls vorhanden)
	#if plane:
	#	plane.visible = false
	#else:
	#	push_warning("Mesh 'Plane' im animierten Objekt nicht gefunden!")

	# Animation abspielen
	if anim.has_animation("ArmatureAction"):
		anim.play("ArmatureAction")
	else:
		push_warning("Animation 'ArmatureAction' nicht gefunden!")
		
	# Kurze Wartezeit vor dem Abflug
	await get_tree().create_timer(0.3).timeout

	# Gleichzeitig: Flugbewegung per Tween starten
	var tween = get_tree().create_tween()
	var start_pos = global_transform.origin
	var end_pos = start_pos + Vector3(6, 1, 1)  
	tween.tween_property(self, "global_transform:origin", end_pos, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
