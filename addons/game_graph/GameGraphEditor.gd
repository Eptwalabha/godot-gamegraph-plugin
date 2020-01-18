tool
extends Control

class_name GameGraphEditor

onready var graph := $HSplitContainer/Container2/GraphEdit as GraphEdit
onready var popup_menu := $PopupMenu as PopupMenu
onready var event_menu := $HSplitContainer/Container2/Menu/HBoxContainer/HBoxContainer/Event as MenuButton
onready var start := $HSplitContainer/Container2/GraphEdit/Start as GraphNode

var last_slot = null

enum POPUPMENU {
	DIALOG = 1,
	CHOICE = 2,
	EVENT = 3
	}
enum EVENTTYPE {
	EMITER = 1,
	RECEIVER = 2
	}

func _ready() -> void:
	popup_menu.clear()
	popup_menu.add_item("dialog", POPUPMENU.DIALOG)
	popup_menu.add_item("choice", POPUPMENU.CHOICE)
	popup_menu.add_item("event", POPUPMENU.EVENT)
	event_menu.get_popup().clear()
	event_menu.get_popup().add_item("emiter", EVENTTYPE.EMITER)
	event_menu.get_popup().add_item("receiver", EVENTTYPE.RECEIVER)
	event_menu.get_popup().connect("id_pressed", self, "_on_EventMenu_pressed")

func _on_GraphEdit_connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	connect_node(from, from_slot, to, to_slot)

func connect_node(from: String, from_slot: int, to: String, to_slot: int) -> void:
	if from == start.name:
		for connection in graph.get_connection_list():
			if connection.from == start.name:
				graph.disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
	graph.connect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	graph.disconnect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_connection_to_empty(from: String, from_slot: int, release_position: Vector2) -> void:
	popup_menu.rect_position = release_position + graph.rect_global_position
	last_slot = {
		"from": from,
		"from_slot": from_slot,
		"position": release_position
	}
	var a = graph.get_node(from).get_connection_output_type(from_slot)
	print("super %s, %s" % [from_slot, a])
	match a:
		0:
			popup_menu.show()
			popup_menu.grab_focus()
		1:
			add_event_emiter_node()

func _on_Dialog_pressed() -> void:
	add_dialog_node()

func add_event_emiter_node() -> void:
	var event_emiter = preload("graph_nodes/GameGraphEventNode.tscn").instance()
	graph.add_child(event_emiter)
	if last_slot:
		event_emiter.offset = last_slot["position"] + graph.scroll_offset
		if last_slot.has("from") and last_slot.has("from_slot"):
			connect_node(last_slot.from, last_slot.from_slot, event_emiter.name, 0)
		last_slot = null


func add_dialog_node() -> void:
	var dialog = preload("graph_nodes/GameGraphDialogNode.tscn").instance()
	dialog.connect("slot_inserted", self, "_on_slot_inserted", [dialog])
	dialog.connect("slot_removed", self, "_on_slot_removed", [dialog])
	graph.add_child(dialog)
	if last_slot:
		dialog.offset = last_slot["position"] + graph.scroll_offset
		if last_slot.has("from") and last_slot.has("from_slot"):
			connect_node(last_slot["from"], last_slot["from_slot"], dialog.name, 0)
		last_slot = null

func _on_PopupMenu_id_pressed(ID: int) -> void:
	match ID:
		POPUPMENU.DIALOG:
			add_dialog_node()
		POPUPMENU.EVENT:
			add_event_emiter_node()
		_:
			pass

func _on_PopupMenu_focus_exited() -> void:
	popup_menu.hide()
	last_slot = null

func _on_EventMenu_pressed(ID: int) -> void:
	match ID:
		EVENTTYPE.EMITER:
			add_event_emiter_node()
		EVENTTYPE.RECEIVER:
			print("receiver")

func _on_slot_inserted(slot_port: int, dialog: GameGraphNode) -> void:
	shift_connection_down(dialog.name, slot_port)
	
func _on_slot_removed(slot_port: int, dialog: GameGraphNode) -> void:
	shift_connection_up(dialog.name, slot_port)
	
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

func _on_GraphEdit_popup_request(position: Vector2) -> void:
	popup_menu.rect_position = position
	last_slot = {
		"position": position - graph.rect_global_position
	}
	popup_menu.show()
	popup_menu.grab_focus()
