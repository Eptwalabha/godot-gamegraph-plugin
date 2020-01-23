tool
extends Control

class_name GameGraphEditor

onready var graph := $TabContainer/Dialogs/MainContainer/GraphEdit as GameGraphGraphEdit
onready var no_dialog_container := $TabContainer/Dialogs/MainContainer/NoDialog as CenterContainer
onready var popup_menu := $PopupMenu as PopupMenu
onready var start := $TabContainer/Dialogs/MainContainer/GraphEdit/Start as GraphNode
onready var dialog_list := $TabContainer/Dialogs/DialogList as GameGraphEditorDialogList

var GameGraphResource = preload("GameGraphResource.gd")
var GameGraphGraphResource = preload("resources/GameGraphGraphResource.gd")
var last_slot = null
var current_dialog_key : String = ''
var dialogs : Dictionary = {}
var resource_path := ''

enum POPUPMENU {
	DIALOG = 1,
	CHOICE = 2,
	EVENT = 3
	}

func _ready() -> void:
	popup_menu.clear()
	popup_menu.add_item("dialog", POPUPMENU.DIALOG)
	popup_menu.add_item("choice", POPUPMENU.CHOICE)
	popup_menu.add_item("event", POPUPMENU.EVENT)
	graph.add_valid_connection_type(0, 1)
	graph.add_valid_connection_type(1, 0)
	set_graph_visibility(false)

func console(text) -> void:
	var c = $TabContainer/Console
	c.text = "%s%s\n" % [c.text, text]

func commit_current() -> void:
	if current_dialog_key != '':
		dialogs[current_dialog_key].graph = graph.save()

func save_resource() -> GameGraphResource:
	var resource : GameGraphResource = GameGraphResource.new()
	resource.dialogs = []
	for dialog_key in dialogs:
		var dialog = dialogs[dialog_key]
		resource.dialogs.push_back(dialog)
	resource.characters = []
	return resource

func reload_interface(resource: GameGraphResource) -> void:
	current_dialog_key = ''
	dialog_list.clear_items()
	dialogs = {}
	for i in range(len(resource.dialogs)):
		var dialog = resource.dialogs[i]
		if dialog is GameGraphDialogResource:
			dialogs[dialog.dialog_key] = dialog
			dialog_list.add_item(dialog.dialog_key, dialog.label)
	var has_at_least_one_dialog = len(dialogs.keys()) > 1
	set_graph_visibility(has_at_least_one_dialog)
	if has_at_least_one_dialog:
		current_dialog_key = dialogs.keys()[0]
		graph.from_resource(dialogs[current_dialog_key].graph)
		console("resource loaded")

func load_current_dialog(dialog_key: String) -> void:
	if dialog_key == current_dialog_key:
		return
	commit_current()
	current_dialog_key = dialog_key
	graph.clear_graph()
	graph.from_resource(dialogs[current_dialog_key].graph)

func set_graph_visibility(visible: bool) -> void:
	graph.visible = visible
	no_dialog_container.visible = not visible

func _on_GraphEdit_connection_to_empty(from: String, from_slot: int, release_position: Vector2) -> void:
	popup_menu.rect_position = release_position + graph.rect_global_position
	last_slot = {
		"from": from,
		"from_slot": from_slot,
		"position": release_position
	}
	match graph.get_output_slot_type(from, from_slot):
		0:
			popup_menu.show()
			popup_menu.grab_focus()
		1:
			graph.add_event_emitter_node(last_slot)

func _on_Dialog_pressed() -> void:
	graph.add_dialog_node()

func _on_Choice_pressed() -> void:
	graph.add_choice_node()

func _on_Event_pressed() -> void:
	graph.add_event_emitter_node()

func _on_PopupMenu_id_pressed(ID: int) -> void:
	match ID:
		POPUPMENU.DIALOG:
			graph.add_dialog_node(last_slot)
		POPUPMENU.EVENT:
			graph.add_event_emitter_node(last_slot)
		POPUPMENU.CHOICE:
			graph.add_choice_node(last_slot)
		_:
			pass
	last_slot = null

func _on_PopupMenu_focus_exited() -> void:
	popup_menu.hide()
	last_slot = null

func _on_EventMenu_pressed() -> void:
	graph.add_event_emitter_node()

func _on_GraphEdit_popup_request(position: Vector2) -> void:
	popup_menu.rect_position = position
	last_slot = {
		"position": position - graph.rect_global_position
	}
	popup_menu.show()
	popup_menu.grab_focus()

func _on_Save_resource_pressed() -> void:
	$SaveDialog.popup_centered()
	
func _on_Load_resource_pressed() -> void:
	$LoadDialog.popup_centered()

func _on_LoadDialog_file_selected(file: String) -> void:
	var data = ResourceLoader.load(file)
	if data is GameGraphResource:
		resource_path = file
		reload_interface(data)

func _on_SaveDialog_file_selected(file: String) -> void:
	var data = save_resource()
	data.plugin_version = "0.0.1"
	var error = ResourceSaver.save(file, data)
	if error:
		console("error while saving")
	else:
		console("save at %s v=%s" % [file, data.plugin_version])

func _on_DialogList_dialog_selected(dialog_key) -> void:
	console("dialog selected '%s'" % dialog_key)
	load_current_dialog(dialog_key)

func _on_DialogList_new_dialog_requested() -> void:
	$WindowDialog.popup()

func _on_DialogList_dialog_deleted(dialog_key) -> void:
	console("dialog to delete %s" % dialog_key)

func _on_WindowDialog_new_dialog_submitted(key, label) -> void:
	graph.clear_graph()
	dialog_list.add_item(key, label)
	dialogs[key] = GameGraphDialogResource.new()
	dialogs[key].dialog_key = key
	dialogs[key].label = label
	dialogs[key].graph = GameGraphGraphResource.new()
	set_graph_visibility(true)
	load_current_dialog(key)
	$WindowDialog.hide()

func _on_WindowDialog_key_requested(key) -> void:
	var already_used = dialogs.has(key)
	$WindowDialog.show_key_unicity_warning(already_used)