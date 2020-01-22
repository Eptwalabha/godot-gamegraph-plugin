tool
extends Button

class_name GameGraphEditorDialogListLine

signal dialog_selected
signal dialog_deleted

var id = 0
var label : String = "" setget _set_label
var label_lower := ""
var key := ""

func _match_query(query: String) -> bool:
	return label_lower.find(query) != -1

func _set_label(new_label: String) -> void:
	label = new_label
	label_lower = new_label.to_lower()
	$Line/Label.text = new_label
	set("hint_tooltip", key)


func _on_DialogListLine_pressed() -> void:
	emit_signal("dialog_selected")

func _on_Button_pressed() -> void:
	emit_signal("dialog_deleted")
