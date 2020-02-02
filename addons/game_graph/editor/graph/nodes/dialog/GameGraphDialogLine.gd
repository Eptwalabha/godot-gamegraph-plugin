tool
class_name GameGraphDialogLine
extends MarginContainer

signal edit_pressed
signal delete_pressed

const DialogLineResource = preload("res://addons/game_graph/resources/GameGraphNodeDialogLineResource.gd")

var key : String = "" setget _set_dialog_key
var who : String = "" setget _set_dialog_who
var how : String = "" setget _set_dialog_how

func _ready() -> void:
	pass

func _on_Edit_pressed() -> void:
	emit_signal("edit_pressed")

func _on_Delete_pressed() -> void:
	emit_signal("delete_pressed")

func _set_dialog_key(new_key: String) -> void:
	key = new_key
	$Line/Dialog.text = key

func _set_dialog_who(new_who: String) -> void:
	who = new_who

func _set_dialog_how(new_how: String) -> void:
	how = new_how

func save() -> Resource:
	var resource = DialogLineResource.new()
	resource.dialog_key = key
	resource.who = who
	resource.how = how
	return resource

func _on_Dialog_text_changed(new_text: String) -> void:
	_set_dialog_key(new_text)
