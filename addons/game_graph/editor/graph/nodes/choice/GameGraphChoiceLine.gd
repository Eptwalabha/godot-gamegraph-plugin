tool
class_name GameGraphChoiceLine
extends MarginContainer

signal edit_pressed
signal delete_pressed

var ChoiceLineResource : Resource = preload("res://addons/game_graph/resources/GameGraphNodeChoiceLineResource.gd")

func _ready() -> void:
	$Line/Delete.connect("pressed", self, "_on_Delete_pressed")

func _on_Delete_pressed() -> void:
	emit_signal("delete_pressed")

func set_choice_key(choice_key: String) -> void:
	$Line/Choice.text = choice_key

func save() -> Resource:
	var resource = ChoiceLineResource.new()
	resource.choice_key = $Line/Choice.text
	return resource
