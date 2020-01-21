tool
extends Control

class_name GameGraphEditor

onready var graph := $HSplitContainer/Container2/GraphEdit as GraphEdit
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
	c.set_text(c.text + text + "\n")

func connect_node(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_type = get_output_slot_type(from, from_slot)
	var to_type = get_input_slot_type(to, to_slot)
	if from_type == to_type and to_type == 0:
		for connection in graph.get_connection_list():
			if connection.from == from and connection.from_port == from_slot:
				if get_input_slot_type(connection.to, connection.to_port) == 0:
					graph.disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
	graph.connect_node(from, from_slot, to, to_slot)

func get_input_slot_type(from, from_slot) -> int:
	return graph.get_node(from).get_connection_input_type(from_slot)
	
func get_output_slot_type(from, from_slot) -> int:
	return graph.get_node(from).get_connection_output_type(from_slot)

func add_event_emitter_node() -> GameGraphEventNode:
	var event_emitter = preload("graph_nodes/GameGraphEventNode.tscn").instance()
	add_node_to_graph(event_emitter)
	return event_emitter

func add_dialog_node() -> GameGraphDialogNode:
	var dialog = preload("graph_nodes/GameGraphDialogNode.tscn").instance()
	dialog.connect("slot_inserted", self, "_on_slot_inserted", [dialog])
	dialog.connect("slot_removed", self, "_on_slot_removed", [dialog])
	add_node_to_graph(dialog)
	return dialog

func add_choice_node() -> GameGraphChoiceNode:
	var choice = preload("graph_nodes/GameGraphChoiceNode.tscn").instance()
	choice.connect("slot_inserted", self, "_on_slot_inserted", [choice])
	choice.connect("slot_removed", self, "_on_slot_removed", [choice])
	add_node_to_graph(choice)
	return choice

func add_node_to_graph(node: GameGraphNode) -> void:
	graph.add_child(node)
	node.connect("close_request", self, "_on_GameGraphNode_close_request", [node])
	if last_slot:
		node.offset = last_slot["position"] + graph.scroll_offset
		if last_slot.has("from") and last_slot.has("from_slot"):
			connect_node(last_slot["from"], last_slot["from_slot"], node.name, 0)
		last_slot = null

func shift_connection_up(from, slot_port) -> void:
	var connections = []
	for c in graph.get_connection_list():
		if c.from == from and c.from_port + 1 >= slot_port:
			if c.from_port + 1 != slot_port:
				connections.push_back(c)
			graph.disconnect_node(c.from, c.from_port, c.to, c.to_port)
	for c in connections:
		graph.connect_node(c.from, c.from_port - 1, c.to, c.to_port)

func shift_connection_down(from, slot_port) -> void:
	var connections = []
	for c in graph.get_connection_list():
		if c.from == from and c.from_port >= slot_port:
			connections.push_back(c)
			graph.disconnect_node(c.from, c.from_port, c.to, c.to_port)
	for c in connections:
		graph.connect_node(c.from, c.from_port + 1, c.to, c.to_port)

func make_resource() -> GameGraphResource:
	var resource : GameGraphResource = game_graph_resource.new()
	var dialogs = []
	var all_nodes = []
	for node in graph.get_children():
		if not node is GameGraphNode:
			continue
		var n = node.save()
		if n is GameGraphNodeResource:
			all_nodes.push_front(n)
	var dialog = {
		'name': "super dialog",
		'graph': {
			'connections': graph.get_connection_list(),
			'nodes': all_nodes
		}
	}
	dialogs.push_front(dialog)
	resource.data = {
		'dialogs': dialogs
	}
	return resource

func reload_interface(resource: GameGraphResource) -> void:
	clear_graph()
	var data = resource.data
	var dialog = data.dialogs[0]
	var g = dialog.graph
	for node in g.nodes:
		var n = null
		match node.type:
			"dialog":
				n = add_dialog_node()
			"choice":
				n = add_choice_node()
			"event_emitter":
				n = add_event_emitter_node()
		n.name = node.name
		n.offset = node.offset
		n.rect_size = node.rect_size
	for c in g.connections:
		graph.connect_node(c.from, c.from_port, c.to, c.to_port)
	console("ok")

func clear_graph() -> void:
	for c in graph.get_connection_list():
		graph.disconnect_node(c.from, c.from_port, c.to, c.to_port)
	for n in graph.get_children():
		if n is GameGraphNode:
			n.queue_free()

func _on_GraphEdit_connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	connect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	graph.disconnect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_connection_to_empty(from: String, from_slot: int, release_position: Vector2) -> void:
	popup_menu.rect_position = release_position + graph.rect_global_position
	last_slot = {
		"from": from,
		"from_slot": from_slot,
		"position": release_position
	}
	match get_output_slot_type(from, from_slot):
		0:
			popup_menu.show()
			popup_menu.grab_focus()
		1:
			add_event_emitter_node()

func _on_Dialog_pressed() -> void:
	add_dialog_node()

func _on_Choice_pressed() -> void:
	add_choice_node()

func _on_Event_pressed() -> void:
	add_event_emitter_node()

func _on_PopupMenu_id_pressed(ID: int) -> void:
	match ID:
		POPUPMENU.DIALOG:
			add_dialog_node()
		POPUPMENU.EVENT:
			add_event_emitter_node()
		POPUPMENU.CHOICE:
			add_choice_node()
		_:
			pass

func _on_PopupMenu_focus_exited() -> void:
	popup_menu.hide()
	last_slot = null

func _on_EventMenu_pressed() -> void:
	add_event_emitter_node()

func _on_slot_inserted(slot_port: int, dialog: GameGraphNode) -> void:
	shift_connection_down(dialog.name, slot_port)
	
func _on_slot_removed(slot_port: int, dialog: GameGraphNode) -> void:
	shift_connection_up(dialog.name, slot_port)

func _on_GraphEdit_popup_request(position: Vector2) -> void:
	popup_menu.rect_position = position
	last_slot = {
		"position": position - graph.rect_global_position
	}
	popup_menu.show()
	popup_menu.grab_focus()

func _on_GameGraphNode_close_request(node: GameGraphNode) -> void:
	for c in graph.get_connection_list():
		if c.from == node.name or c.to == node.name:
			graph.disconnect_node(c.from, c.from_port, c.to, c.to_port)
	node.queue_free()

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