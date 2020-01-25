tool
extends Node

class_name GameGraph

export(Resource) var dialogs

func _get_configuration_warning() -> String:
	if dialogs is GameGraphResource:
		return ""
	else:
		return "In order to work, this custom Node requires a GameGraphResource"
