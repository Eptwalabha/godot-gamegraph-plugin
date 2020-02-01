tool
class_name GameGraphWindowDialogNewDialog
extends WindowDialog

signal new_dialog_submitted(label, key)
signal key_requested(key)

onready var label := $Margin/Container/Dialog/Input as LineEdit
onready var key := $Margin/Container/Key/Input as LineEdit
var initial_key := ""

func reset_inputs():
	key.text = ""
	label.text = ""
	initial_key = ""
	show_key_unicity_warning(false)

func show_key_unicity_warning(show_warning: bool):
	$Margin/Container/Warning.visible = show_warning

func is_inputs_valid() -> bool:
	return len(key.text) > 3 and len(label.text) > 3

func update_button_state() -> void:
	var valid = is_inputs_valid()
	var warning_visible = $Margin/Container/Warning.visible
	$Margin/Container/Buttons/Confirm.disabled = not valid or warning_visible

func _on_Confirm_pressed() -> void:
	emit_signal("new_dialog_submitted", key.text, label.text)

func _on_DialogInput_text_changed(new_text: String) -> void:
	update_button_state()

func _on_KeyInput_text_changed(new_text: String) -> void:
	if len(new_text) > 3:
		emit_signal("key_requested", new_text)
	update_button_state()

func _on_Cancel_pressed() -> void:
	reset_inputs()
	hide()

func _on_WindowDialog_popup_hide() -> void:
	reset_inputs()
