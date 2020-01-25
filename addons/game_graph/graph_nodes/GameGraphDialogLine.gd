tool
extends MarginContainer

class_name GameGraphDialogLine

signal edit_pressed
signal delete_pressed

func _ready() -> void:
	$Line/Edit.connect("pressed", self, "_on_Edit_pressed")
	$Line/Delete.connect("pressed", self, "_on_Delete_pressed")

func _on_Edit_pressed() -> void:
	emit_signal("edit_pressed")
	
func _on_Delete_pressed() -> void:
	emit_signal("delete_pressed")

func set_dialog_key(key: String) -> void:
	$Line/Dialog.text = key

func save() -> Resource:
	var resource = preload("../resources/GameGraphNodeDialogLineResource.gd").new()
	resource.dialog_key = $Line/Dialog.text
	resource.who = name
	resource.how = name
	return resource
