tool
extends VBoxContainer

class_name DialogList

signal dialog_selected(dialog_name)

onready var list_container := $Scroll/Margin/DialogsList as VBoxContainer
onready var filter := $Filter/Container/Filter as LineEdit
onready var search_icon := $Filter/Container/Filter/Magnifier as TextureRect

func _ready() -> void:
	pass

func add_item(dialog_key: String, dialog_name: String) -> void:
	var dialog_button = Button.new()
	dialog_button.text = dialog_name
	dialog_button.align = Button.ALIGN_LEFT
	dialog_button.clip_text = true
	dialog_button.connect("pressed", self, "_on_DialogButton_pressed", [dialog_key])
	list_container.add_child(dialog_button)

func remove_item(dialog_name: String) -> void:
	for dialog_button in list_container.get_children():
		if dialog_button.text == dialog_name:
			dialog_button.queue_free()

func clear_items() -> void:
	for dialog_button in list_container.get_children():
		dialog_button.queue_free()

func _filter_items(request) -> void:
	var request_lower = request.to_lower()
	for dialog in list_container.get_children():
		if request_lower == "":
			dialog.show()
		else:
			var n = dialog.text
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

func _on_DialogButton_pressed(dialog_key: String) -> void:
	emit_signal("dialog_selected", dialog_key)
