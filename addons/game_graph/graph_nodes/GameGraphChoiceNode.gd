tool
extends "res://addons/game_graph/graph_nodes/GameGraphNode.gd"

class_name GameGraphChoiceNode

var line = preload("res://addons/game_graph/graph_nodes/GameGraphChoiceLine.tscn")

func _ready() -> void:
	._ready()
	set_slot(0, true, 0, Color(0, 0, 1), false, 0, Color(0, 0, 1))

func delete_choice_line(choice_line: GameGraphChoiceLine) -> void:
	var slot_port = choice_line.get_index()
	emit_signal("slot_removed", slot_port)
	choice_line.disconnect("delete_pressed", self, "_on_ChoiceLine_deleted")
	choice_line.queue_free()
	
func insert_new_choice_line() -> void:
	var choice_line = line.instance()
	add_child(choice_line)
	var slot_port = choice_line.get_index()
	set_slot(slot_port, false, 0, Color(), true, 0, Color(0, 0, 1))
	choice_line.connect("delete_pressed", self, "_on_ChoiceLine_deleted", [choice_line])
	emit_signal("slot_inserted", slot_port)

func _on_Button_pressed() -> void:
	insert_new_choice_line()

func _on_ChoiceLine_deleted(choice_line: GameGraphChoiceLine) -> void:
	delete_choice_line(choice_line)