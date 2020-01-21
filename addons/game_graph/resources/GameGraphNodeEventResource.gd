tool
extends "res://addons/game_graph/resources/GameGraphNodeResource.gd"

class_name GameGraphNodeEventResource

export(String) var event_name

func get_type() -> String:
	return "event_emitter"