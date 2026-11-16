extends Node3D

# The breakfast scene starts at 08:10.
var seconds := 8 * 3600 + 10 * 60

func _ready() -> void:
	update_hands()

func _on_tick() -> void:
	seconds = (seconds + 1) % 43200
	update_hands()
	$Tick.pitch_scale = 1.0 if seconds % 2 == 0 else 0.9
	$Tick.play()

func update_hands() -> void:
	$Second.rotation.z = -TAU * (seconds % 60) / 60.0
	$Minute.rotation.z = -TAU * (seconds % 3600) / 3600.0
	$Hour.rotation.z = -TAU * seconds / 43200.0
