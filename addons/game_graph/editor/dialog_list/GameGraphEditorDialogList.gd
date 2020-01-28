tool
extends MarginContainer

class_name GameGraphEditorDialogList

signal dialog_selected(dialog_key)
signal dialog_deleted(dialog_key)

onready var list_container := $Container/Scroll/Margin/DialogsList as VBoxContainer
onready var filter := $Container/Filter as LineEdit
onready var search_icon := $Container/Filter/Magnifier as TextureRect

var DialogListLine = preload("GameGraphEditorDialogListLine.tscn")

func add_item(dialog_key: String, dialog_name: String) -> void:
	var dialog_line : GameGraphEditorDialogListLine = DialogListLine.instance()
	list_container.add_child(dialog_line)
	dialog_line.key = dialog_key
	dialog_line.label = dialog_name
	dialog_line.connect("dialog_selected", self, "_on_dialog_selected", [dialog_key])
	dialog_line.connect("dialog_deleted", self, "_on_dialog_deleted", [dialog_key])

func clear_items() -> void:
	for dialog_button in list_container.get_children():
		dialog_button.queue_free()

func _filter_items(request) -> void:
	var request_lower = request.to_lower()
	for dialog in list_container.get_children():
		if request_lower == "":
			dialog.show()
		else:
			var n = dialog.label
			if n.to_lower().find(request_lower) != -1:
				dialog.show()
			else:
				dialog.hide()

func _on_Filter_text_changed(new_text: String) -> void:
	if len(new_text) > 0:
		search_icon.hide()
	else:
		search_icon.show()
	_filter_items(new_text)

func _on_dialog_deleted(dialog_key: String) -> void:
	emit_signal("dialog_deleted", dialog_key)

func _on_dialog_selected(dialog_key: String) -> void:
	emit_signal("dialog_selected", dialog_key)
