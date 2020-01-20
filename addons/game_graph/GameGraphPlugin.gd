tool
extends EditorPlugin

class_name GameGraphPlugin

var editor

func _enter_tree() -> void:
	editor = preload("GameGraphEditor.tscn").instance()
	add_control_to_bottom_panel(editor, "Game graph")
	add_custom_type("GameGraph", "Node", preload("GameGraph.gd"), preload("game_graph.png"))

func _exit_tree() -> void:
	remove_control_from_bottom_panel(editor)
	remove_custom_type("GameGraph")
	editor.free()

func get_plugin_name() -> String:
	return "GameGraph"