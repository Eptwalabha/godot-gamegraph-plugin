tool
extends "GameGraphNode.gd"

class_name GameGraphChoiceNode

var ChoiceLine = preload("GameGraphChoiceLine.tscn")
var ChoiceResource = preload("res://addons/game_graph/resources/GameGraphNodeChoiceResource.gd")

func _ready() -> void:
	._ready()
	set_slot(0, true, 0, Color(0, 0, 1), false, 0, Color(0, 0, 1))

func save() -> Resource:
	var resource = ChoiceResource.new()
	resource.offset = offset
	resource.rect_size = rect_size
	resource.node_id = node_id
	resource.question = $HBoxContainer/Question.text
	resource.choices = []
	for node in get_children():
		if not node is GameGraphChoiceLine:
			continue
		resource.choices.push_back(node.save())
	return resource

func from_resource(resource: Resource) -> void:
	.from_resource(resource)
	if resource is GameGraphNodeChoiceResource:
		$HBoxContainer/Question.text = resource.question
		for choice_line_resource in resource.choices:
			var choice_line = _new_choice_line()
			choice_line.set_choice_key(choice_line_resource.choice_key)

func delete_choice_line(choice_line: GameGraphChoiceLine) -> void:
	var slot_port = _get_slot_index(choice_line)
	emit_signal("slot_removed", slot_port)
	choice_line.disconnect("delete_pressed", self, "_on_ChoiceLine_deleted")
	choice_line.queue_free()
	
func insert_new_choice_line() -> void:
	var choice_line = _new_choice_line()
	var slot_port = choice_line.get_index()
	emit_signal("slot_inserted", slot_port)

func _get_slot_index(choice_line: GameGraphChoiceLine) -> int:
	var index = get_slot_offset()
	for node in get_children():
		if not node is GameGraphChoiceLine:
			continue
		if node == choice_line:
			return index
		index += 1
	return -1

func _new_choice_line() -> GameGraphChoiceLine:
	var choice_line = ChoiceLine.instance()
	add_child(choice_line)
	var slot_port = choice_line.get_index()
	set_slot(slot_port, false, 0, Color(), true, 0, Color(0, 1, 0))
	choice_line.connect("delete_pressed", self, "_on_ChoiceLine_deleted", [choice_line])
	return choice_line

func _on_Button_pressed() -> void:
	insert_new_choice_line()

func _on_ChoiceLine_deleted(choice_line: GameGraphChoiceLine) -> void:
	delete_choice_line(choice_line)

func _on_GameGraphChoiceNode_resize_request(new_minsize: Vector2) -> void:
	rect_size = new_minsize
