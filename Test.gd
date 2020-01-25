extends Node

onready var dialog := $GameGraph as GameGraph

func _ready() -> void:
	print(dialog.dialogs.dialogs)
