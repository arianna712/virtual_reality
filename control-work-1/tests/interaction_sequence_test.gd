extends SceneTree

class GuidedRay:
	extends "res://scenes/ray_cast_3d.gd"
	var selected: Node
	func _interaction_target() -> Node:
		return selected

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	var original = scene.get_node("PlayerCharacter/CameraHolder/Camera/RayCast3D")
	original.free()
	root.add_child(scene)
	current_scene = scene
	var ray = GuidedRay.new()
	scene.add_child(ray)
	var press = InputEventAction.new()
	press.action = "use"
	press.pressed = true
	assert(ray.steps.size() == 19)
	ray.selected = scene.get_node("apple")
	ray._input(press)
	assert(ray.current_step == 0 and ray.inventory.is_empty(), "Wrong order must not collect")
	ray.selected = scene.get_node("lamp2")
	ray._input(press)
	assert(ray.current_step == 0, "Wrong lamp must not advance")
	ray.selected = scene.get_node("lamp")
	ray._input(press)
	assert(ray.current_step == 1)
	assert(scene.get_node("lamp/SpotLight3D").visible)
	var table = scene.get_node("gothicTable/DropZone_table")
	ray.selected = table
	ray._input(press)
	assert(ray.current_step == 1, "Empty inventory must not advance")
	for item in ray.ITEM_ORDER:
		var before: int = ray.current_step
		ray.selected = scene.get_node(item)
		ray._input(press)
		assert(ray.inventory == [item])
		assert(ray.current_step == before + 1)
		ray._input(press)
		assert(ray.current_step == before + 1, "Repeated pickup must not advance")
		ray.selected = table
		ray._input(press)
		assert(ray.inventory.is_empty())
		assert(ray.current_step == before + 2)
		assert(table.get_node(item + "_after").visible)
		assert(table.get_node(item + "_after").get_child(0).freeze)
	ray._input(press)
	assert(ray.current_step == 19, "Completion must stay final")
	assert(ray._step_text().contains("Task completed"))
	await process_frame
	var panel = ray.guide.get_node("Screen/Panel")
	assert(panel.size.y > 150 and panel.size.x >= 380, "Guide must have a readable layout")
	print("PASS: 19 steps, wrong order, wrong lamp, empty inventory, repeated actions, frozen placements, completion and HUD layout")
	quit(0)
