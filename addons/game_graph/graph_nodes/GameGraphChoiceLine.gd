tool
extends MarginContainer

class_name GameGraphChoiceLine

signal edit_pressed
signal delete_pressed

func _ready() -> void:
	$Line/Delete.connect("pressed", self, "_on_Delete_pressed")

func _on_Delete_pressed() -> void:
	emit_signal("delete_pressed")

func set_choice_key(choice_key: String) -> void:
	$Line/Choice.text = choice_key

func save() -> Resource:
	var resource = preload("../resources/GameGraphNodeChoiceLineResource.gd").new()
	resource.choice_key = $Line/Choice.text
	return resource
