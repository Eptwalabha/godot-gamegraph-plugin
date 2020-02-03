tool
class_name GameGraphPlugin
extends EditorPlugin

var editor
var eds

func _enter_tree() -> void:
	editor = preload("editor/GameGraphEditor.tscn").instance()
	add_control_to_bottom_panel(editor, "Game graph")
	add_custom_type("GameGraph", "Node", preload("GameGraph.gd"), preload("assets/game_graph.png"))
	eds = get_editor_interface().get_selection()
	eds.connect("selection_changed", self, "_node_selection_changed")

func _exit_tree() -> void:
	remove_control_from_bottom_panel(editor)
	remove_custom_type("GameGraph")
	editor.free()

func get_plugin_name() -> String:
	return "GameGraph"

func _node_selection_changed() -> void:
	editor.change_selection(eds.get_selected_nodes())
