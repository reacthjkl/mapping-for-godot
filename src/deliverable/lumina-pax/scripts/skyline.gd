extends Node3D

func _ready():
	# Hide both the mesh and the light at start
	$MeshInstance3D.visible = false
	$SpotLight3D.visible = false
	$SpotLight3D.light_energy = 0.0

func appear_smoothly():
	# Show mesh and light nodes
	var mesh = $MeshInstance3D
	var light = $SpotLight3D
	mesh.visible = true
	light.visible = true

	# Duplicate and configure transparent material
	var material: StandardMaterial3D = mesh.get_active_material(0).duplicate()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true
	material.albedo_color.a = 0.0
	mesh.set_surface_override_material(0, material)

	# Create tween for fade-in effect
	var tween := create_tween()

	# Fade mesh alpha from 0.0 to 1.0
	tween.tween_property(material, "albedo_color:a", 1.0, 2.0)

	# Fade light energy from 0.0 to full brightness
	tween.tween_property(light, "light_energy", 1.0, 2.0)
