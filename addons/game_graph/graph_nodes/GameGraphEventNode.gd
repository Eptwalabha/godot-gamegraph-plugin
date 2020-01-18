tool
extends "res://addons/game_graph/graph_nodes/GameGraphNode.gd"

func _ready() -> void:
	._ready()
	set_slot(0, true, 1, Color(1, 1, 0), false, 0, Color(0, 0, 1))