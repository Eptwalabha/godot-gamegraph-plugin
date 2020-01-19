tool
extends MarginContainer

class_name GameGraphChoiceLine

signal edit_pressed
signal delete_pressed

func _ready() -> void:
	$Line/Delete.connect("pressed", self, "_on_Delete_pressed")

func _on_Delete_pressed() -> void:
	emit_signal("delete_pressed")
