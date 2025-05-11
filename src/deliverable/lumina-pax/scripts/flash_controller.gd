extends Node3D

@onready var main_light: Light3D = $"../Lights/MainLight"
var original_light_energy: float

# Timer we’ll use for the 1 s cooldown
@onready var cooldown_timer: Timer = Timer.new()

const FLASH_COOLDOWN := 1.0  # seconds

func _ready() -> void:
	# Cache the starting energy
	original_light_energy = main_light.light_energy

	# Configure and add our cooldown timer
	cooldown_timer.wait_time = FLASH_COOLDOWN
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)

func request_flash(intensity_multiplier: float = 10.0, flash_duration: float = 0.2) -> void:
	# If the timer is running, we’re still in cooldown—ignore the request
	if not cooldown_timer.is_stopped():
		return

	# Start the cooldown
	cooldown_timer.start()

	# 1) boost
	main_light.light_energy = original_light_energy * intensity_multiplier

	# 2) wait & restore
	await get_tree().create_timer(flash_duration).timeout
	main_light.light_energy = original_light_energy
