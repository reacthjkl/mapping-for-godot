extends Node3D

# The object whose cast_shadow property you want to toggle
@export var object_to_toggle: Node3D # Reference to the object, set this in the editor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("ArmatureAction_001")
	
	if not object_to_toggle:
		object_to_toggle = $Armature/Skeleton3D/Object_4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Check for the 'V' key press
	if Input.is_action_just_pressed("toggle_cast_shadow"):
		_toggle_cast_shadow()
		
# Toggle the cast_shadow property between SHADOWS_ON and SHADOWS_ONLY
func _toggle_cast_shadow():
	if object_to_toggle:
		if object_to_toggle.cast_shadow == 1:  # SHADOWS_ON
			object_to_toggle.cast_shadow = 3  # SHADOWS_ONLY
		else:
			object_to_toggle.cast_shadow = 1  # SHADOWS_ON
