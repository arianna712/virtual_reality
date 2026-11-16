extends Node3D

func _ready() -> void:
	$Wind.play()
	await get_tree().create_timer(6.0).timeout
	$Thunder.play()
	await get_tree().create_timer(4.0).timeout
	$Drops.emitting = true
	$Rain.play()
	create_tween().tween_property($Rain, "volume_db", -25.5, 3.0)
	$ThunderInterval.start()

func _on_thunder_interval_timeout() -> void:
	$Thunder.pitch_scale = randf_range(0.87, 1.03)
	$Thunder.play()
	$ThunderInterval.start(randf_range(24.0, 37.0))
