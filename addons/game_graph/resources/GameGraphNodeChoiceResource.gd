tool
extends "res://addons/game_graph/resources/GameGraphNodeResource.gd"

class_name GameGraphNodeChoiceResource

export(String) var question
export(Array, Resource) var choices

func get_type() -> String:
	return "choice"