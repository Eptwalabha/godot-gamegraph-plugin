tool
class_name GameGraphEditor
extends Control

const GameGraphResource = preload("res://addons/game_graph/resources/GameGraphResource.gd")
const GameGraphGraphResource = preload("res://addons/game_graph/resources/GameGraphGraphResource.gd")
var last_slot = null
var current_dialog_key : String = ''
var dialogs : Dictionary = {}
var resource_path := ''
var current_selected_node = null

onready var graph := $TabContainer/Dialog/Main/MainContainer/GraphEdit as GameGraphGraphEdit
onready var no_dialog_container := $TabContainer/Dialog/Main/MainContainer/NoDialog as CenterContainer
onready var popup_menu := $PopupMenu as PopupMenu
onready var dialog_list := $TabContainer/Dialog/Main/DialogList as GameGraphEditorDialogList
onready var dialog_line_editor := $WindowDialogLineEditor as WindowDialogLineEditor

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
	update_graph_visibility()

func console(text) -> void:
	var c = $TabContainer/Console
	if c is TextEdit:
		c.text = "%s%s\n" % [c.text, text]

func commit_current() -> void:
	if current_dialog_key != '' and dialogs.has(current_dialog_key):
		dialogs[current_dialog_key].graph = graph.save()

func save_resource() -> GameGraphResource:
	commit_current()
	var resource : GameGraphResource = GameGraphResource.new()
	resource.dialogs = []
	for dialog_key in dialogs:
		var dialog = dialogs[dialog_key]
		resource.dialogs.push_back(dialog)
	resource.characters = []
	return resource

func change_selection(nodes: Array) -> void:
	if len(nodes) != 1:
		return
	if nodes[0] is GameGraph:
		current_selected_node = nodes[0]

func reload_interface(resource: GameGraphResource) -> void:
	dialog_list.show()
	current_dialog_key = ''
	dialog_list.clear_items()
	dialogs = {}
	for i in range(len(resource.dialogs)):
		var dialog = resource.dialogs[i]
		if dialog is GameGraphDialogResource:
			dialogs[dialog.dialog_key] = dialog
			dialog_list.add_item(dialog.dialog_key, dialog.label)
	if len(dialogs.keys()) > 0:
		current_dialog_key = dialogs.keys()[0]
		dialog_list.set_selected_item(current_dialog_key)
		graph.from_resource(dialogs[current_dialog_key].graph)
		console("resource loaded")
	update_graph_visibility()

func load_current_dialog(dialog_key: String) -> void:
	if dialog_key == current_dialog_key or not dialogs.keys().has(dialog_key):
		return
	commit_current()
	current_dialog_key = dialog_key
	dialog_list.set_selected_item(current_dialog_key)
	graph.clear_graph()
	graph.from_resource(dialogs[current_dialog_key].graph)

func load_new_dialog(dialog_key: String) -> void:
	commit_current()
	current_dialog_key = dialog_key
	graph.new_graph()

func update_graph_visibility() -> void:
	var visible = len(dialogs.keys()) > 0
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

func _on_GraphEdit_popup_request(position: Vector2) -> void:
	popup_menu.rect_position = position
	last_slot = {
		"position": position - graph.rect_global_position
	}
	popup_menu.show()
	popup_menu.grab_focus()

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

func _on_Toolbar_New_resource_pressed() -> void:
	pass

func _on_Toolbar_Load_resource_pressed() -> void:
	$LoadDialog.popup_centered()

func _on_Toolbar_Save_resource_pressed() -> void:
	$SaveDialog.popup_centered()

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

func _on_DialogList_dialog_deleted(dialog_key) -> void:
	console("dialog to delete %s" % dialog_key)
	dialogs.erase(dialog_key)
	dialog_list.remove_item(dialog_key)
	if len(dialogs.keys()) > 0:
		load_current_dialog(dialogs.keys()[0])
	else:
		update_graph_visibility()

func _on_WindowDialog_new_dialog_submitted(key, label) -> void:
	dialog_list.add_item(key, label)
	dialogs[key] = GameGraphDialogResource.new()
	dialogs[key].dialog_key = key
	dialogs[key].label = label
	update_graph_visibility()
	load_new_dialog(key)
	$WindowDialog.hide()

func _on_WindowDialog_key_requested(key) -> void:
	var already_used = dialogs.has(key)
	$WindowDialog.show_key_unicity_warning(already_used)


func _on_GraphEdit_dialog_line_edited(dialog_node, dialog_line) -> void:
	dialog_line_editor.open(dialog_line)

func _on_DialogList_dialog_created() -> void:
	$WindowDialog.popup()
