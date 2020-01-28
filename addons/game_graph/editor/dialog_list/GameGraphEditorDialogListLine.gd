tool
extends PanelContainer

class_name GameGraphEditorDialogListLine

signal dialog_selected
signal dialog_deleted

var id = 0
var label : String = "" setget _set_label
var label_lower := ""
var key := ""
var selected : bool = false setget _set_selected

func _match_query(query: String) -> bool:
	return label_lower.find(query) != -1

func _set_label(new_label: String) -> void:
	label = new_label
	label_lower = new_label.to_lower()
	$Line/Label.text = new_label
	set("hint_tooltip", key)

func _set_selected(is_selected: bool) -> void:
	selected = is_selected
	var hex = "#31999999" if is_selected else "#00999999"
	get("custom_styles/panel").set_bg_color(Color(hex))

func _on_DialogListLine_pressed() -> void:
	emit_signal("dialog_selected")

func _on_Button_pressed() -> void:
	emit_signal("dialog_deleted")

func _on_DialogListLine_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			emit_signal("dialog_selected")
