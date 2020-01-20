tool
extends "res://addons/game_graph/graph_nodes/GameGraphNode.gd"

class_name GameGraphEventNode

func _ready() -> void:
	._ready()
	set_slot(0, true, 1, Color(1, 1, 0), false, 0, Color(0, 0, 1))

func get_type() -> String:
	return "event_emiter"