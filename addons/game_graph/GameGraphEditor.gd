tool
extends Control

class_name GameGraphEditor

onready var graph := $HSplitContainer/Container2/GraphEdit as GameGraphGraphEdit
onready var popup_menu := $PopupMenu as PopupMenu
onready var event_menu := $HSplitContainer/Container2/Menu/HBoxContainer/HBoxContainer/Event as MenuButton
onready var start := $HSplitContainer/Container2/GraphEdit/Start as GraphNode

var game_graph_resource = preload("GameGraphResource.gd")
var last_slot = null
var dialog_data : Resource
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

func console(text) -> void:
	var c = $HSplitContainer/Container2/Console

func make_resource() -> GameGraphResource:
	var resource : GameGraphResource = game_graph_resource.new()
	var dialog : GameGraphDialogResource = preload("resources/GameGraphDialogResource.gd").new()
	dialog.graph = graph.save()
	resource.dialogs = [dialog]
	resource.characters = []
	return resource

func reload_interface(resource: GameGraphResource) -> void:
	var dialog = resource.dialogs[0]
	if dialog is GameGraphDialogResource:
		graph.from_resource(dialog.graph)
	console("resource loaded")

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
		dialog_data = data
		reload_interface(data)

func _on_SaveDialog_file_selected(file: String) -> void:
	var data = make_resource()
	data.plugin_version = "0.0.1"
	var error = ResourceSaver.save(file, data)
	if error:
		console("error while saving")
	else:
		console("save at %s v=%s" % [file, data.plugin_version])