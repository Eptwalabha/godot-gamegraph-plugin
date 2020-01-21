tool
extends "res://addons/game_graph/graph_nodes/GameGraphNode.gd"

class_name GameGraphDialogNode

var line = preload("res://addons/game_graph/graph_nodes/GameGraphDialogLine.tscn")

func _ready() -> void:
	._ready()
	set_slot(0, true, 0, Color(0, 0, 1), true, 0, Color(0, 1, 0))

func save() -> Resource:
	var resource = preload("../resources/GameGraphNodeDialogResource.gd").new()
	resource.name = name
	resource.offset = offset
	resource.rect_size = rect_size
	resource.dialog_lines = []
	for node in get_children():
		if not node is GameGraphDialogLine:
			continue
		resource.dialog_lines.push_back(node.save())
	return resource

func from_resource(resource: Resource) -> void:
	.from_resource(resource)
	if resource is GameGraphNodeDialogResource:
		for dialog_line_resource in resource.dialog_lines:
			var dialog_line = _new_dialog_line()
			dialog_line.set_dialog_key(dialog_line_resource.dialog_key)

func delete_dialog_line(dialog_line: GameGraphDialogLine) -> void:
	var slot_port = dialog_line.get_index()
	emit_signal("slot_removed", slot_port)
	dialog_line.disconnect("delete_pressed", self, "_on_DialogLine_deleted")
	dialog_line.queue_free()

func insert_new_dialog_line() -> void:
	var dialog_line = _new_dialog_line()
	var slot_port = dialog_line.get_index()
	emit_signal("slot_inserted", slot_port)

func _new_dialog_line() -> GameGraphDialogLine:
	var dialog_line = line.instance()
	add_child(dialog_line)
	var slot_port = dialog_line.get_index()
	set_slot(slot_port, false, 0, Color(), true, 1, Color(1, 1, 0))
	dialog_line.connect("delete_pressed", self, "_on_DialogLine_deleted", [dialog_line])
	return dialog_line

func _on_Button_pressed() -> void:
	insert_new_dialog_line()

func _on_DialogLine_deleted(dialog_line: GameGraphDialogLine) -> void:
	delete_dialog_line(dialog_line)