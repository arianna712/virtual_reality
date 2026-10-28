extends RayCast3D

const ITEM_NAMES = {
	"tray": "tray", "plate": "plate", "teacup": "teacup",
	"spoon": "teaspoon", "milk_pitcher": "milk pitcher",
	"milk": "milk", "teapot": "teapot", "croissant": "croissant", "apple": "apple"
}
const ITEM_ORDER = ["tray", "plate", "teacup", "spoon", "milk_pitcher", "milk", "teapot", "croissant", "apple"]
const GUIDE_SCENE = preload("res://scenes/interaction_guide.tscn")

var inventory: Array[String] = []
var steps: Array[Dictionary] = [{"action": "lamp", "item": "lamp"}]
var current_step := 0
var feedback_time := 0.0
var guide: CanvasLayer

func _ready() -> void:
	for item in ITEM_ORDER:
		steps.append({"action": "pick", "item": item})
		steps.append({"action": "place", "item": item})
	guide = GUIDE_SCENE.instantiate()
	add_child(guide)
	_update_guide()

func _process(delta: float) -> void:
	feedback_time = maxf(0.0, feedback_time - delta)
	if feedback_time == 0.0:
		guide.get_node("Screen/Panel/Margin/Rows/Feedback").text = ""
	var target := _interaction_target()
	var prompt := "Move closer and aim at the indicated object."
	if current_step >= steps.size():
		prompt = "Task completed!"
	elif target != null:
		if target.name == "DropZone_table":
			prompt = "Pick up the indicated object first."
			if not inventory.is_empty():
				prompt = "E - Place: " + str(ITEM_NAMES[inventory[0]])
		elif target.name == "lamp":
			prompt = "E - Turn on the lamp"
		elif target.name == "lamp2":
			prompt = "This lamp is already on. Find the unlit lamp."
		else:
			prompt = "E - Pick up: " + str(ITEM_NAMES[str(target.name)])
	guide.get_node("Screen/Prompt").text = prompt

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("use") or event.is_echo():
		return
	if current_step >= steps.size():
		return
	force_raycast_update()
	var target := _interaction_target()
	if target == null:
		_feedback("Move closer and aim at the indicated object.")
		return
	var step: Dictionary = steps[current_step]
	var target_name := str(target.name)
	if target_name in ["lamp", "lamp2"]:
		if step["action"] != "lamp" or target_name != step["item"]:
			_feedback("First: " + _step_text())
			return
		var light := target.get_node_or_null("SpotLight3D") as Light3D
		if light == null:
			_feedback("This lamp cannot be turned on.")
			return
		light.visible = true
		_advance("Lamp turned on!")
	elif target_name == "DropZone_table":
		if step["action"] != "place" or not inventory.has(str(step["item"])):
			_feedback("First: " + _step_text())
			return
		var placed_item := target.get_node_or_null(str(step["item"]) + "_after") as Node3D
		if placed_item == null:
			_feedback("No placement spot is available for this item.")
			return
		placed_item.show()
		inventory.erase(str(step["item"]))
		_advance("Item placed on the table!")
	else:
		if step["action"] != "pick" or target_name != step["item"]:
			_feedback("First: " + _step_text())
			return
		inventory.append(target_name)
		target.queue_free()
		_advance("Picked up: " + str(ITEM_NAMES[target_name]))

# Walks up from the physics body to the interactive object node.
func _interaction_target() -> Node:
	if not is_colliding():
		return null
	var node := get_collider() as Node
	while node != null and node != get_tree().current_scene:
		var node_name := str(node.name)
		if node_name == "DropZone_table" or node_name in ["lamp", "lamp2"] or ITEM_NAMES.has(node_name):
			return node
		node = node.get_parent()
	return null

func _step_text() -> String:
	if current_step >= steps.size():
		return "The table is ready! Task completed."
	var step: Dictionary = steps[current_step]
	if step["action"] == "lamp":
		return "Turn on the unlit lamp on the left wall."
	var item_name: String = ITEM_NAMES[str(step["item"])]
	if step["action"] == "pick":
		return "Pick up: " + item_name
	return "Place on the table: " + item_name

func _advance(message: String) -> void:
	current_step += 1
	_update_guide()
	_feedback(message)

func _update_guide() -> void:
	var rows := guide.get_node("Screen/Panel/Margin/Rows")
	rows.get_node("Progress").text = "Completed: %d/%d" % [current_step, steps.size()]
	rows.get_node("Objective").text = _step_text()
	rows.get_node("Inventory").text = "Inventory: " + ("empty" if inventory.is_empty() else str(ITEM_NAMES[inventory[0]]))

func _feedback(message: String) -> void:
	guide.get_node("Screen/Panel/Margin/Rows/Feedback").text = message
	feedback_time = 4.0
