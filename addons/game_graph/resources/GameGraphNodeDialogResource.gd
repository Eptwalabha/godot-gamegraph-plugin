tool
extends "res://addons/game_graph/resources/GameGraphNodeResource.gd"

class_name GameGraphNodeDialogResource

export(Array, Resource) var dialog_lines

func get_type() -> String:
	return "dialog"