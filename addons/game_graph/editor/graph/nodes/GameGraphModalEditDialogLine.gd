tool
class_name WindowDialogLineEditor
extends WindowDialog

var current_line = null

onready var text := $Params/Text/Text as TextEdit
onready var who := $Params/Who/Text as LineEdit
onready var how := $Params/How/Text as LineEdit

func open(line_to_edit = null) -> void:
	_clear_form()
	if line_to_edit is GameGraphDialogLine:
		text.text = line_to_edit.key
		who.text = line_to_edit.who
		how.text = line_to_edit.how
		current_line = line_to_edit
	popup()

func _clear_form() -> void:
	text.text = ""
	who.text = ""
	how.text = ""

func _on_Cancel_pressed() -> void:
	hide()

func _on_Save_pressed() -> void:
	if current_line is GameGraphDialogLine:
		current_line.key = text.text
		current_line.who = who.text
		current_line.how = how.text
	hide()
