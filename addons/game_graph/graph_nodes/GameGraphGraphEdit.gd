tool
extends GraphEdit

class_name GameGraphGraphEdit

func save() -> Resource:
	var resource = preload("../resources/GameGraphGraphResource.gd").new()
	resource.nodes = _get_node_resources()
	resource.connections = _get_connections()
	return resource

func clear_graph() -> void:
	for c in get_connection_list():
		disconnect_node(c.from, c.from_port, c.to, c.to_port)
	for n in get_children():
		if n is GameGraphNode:
			n.queue_free()

func add_event_emitter_node(slot_data = null) -> GameGraphEventNode:
	var event_emitter = preload("GameGraphEventNode.tscn").instance()
	add_node_to_graph(event_emitter, slot_data)
	return event_emitter

func add_dialog_node(slot_data = null) -> GameGraphDialogNode:
	var dialog = preload("GameGraphDialogNode.tscn").instance()
	dialog.connect("slot_inserted", self, "_on_slot_inserted", [dialog])
	dialog.connect("slot_removed", self, "_on_slot_removed", [dialog])
	add_node_to_graph(dialog, slot_data)
	return dialog

func add_choice_node(slot_data = null) -> GameGraphChoiceNode:
	var choice = preload("GameGraphChoiceNode.tscn").instance()
	choice.connect("slot_inserted", self, "_on_slot_inserted", [choice])
	choice.connect("slot_removed", self, "_on_slot_removed", [choice])
	add_node_to_graph(choice, slot_data)
	return choice

func add_node_to_graph(node: GameGraphNode, slot_data = null) -> void:
	add_child(node)
	node.connect("close_request", self, "_on_GameGraphNode_close_request", [node])
	if slot_data:
		node.offset = slot_data["position"] + scroll_offset
		if slot_data.has("from") and slot_data.has("from_slot"):
			do_connect_node(slot_data["from"], slot_data["from_slot"], node.name, 0)

func do_connect_node(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_type = get_output_slot_type(from, from_slot)
	var to_type = get_input_slot_type(to, to_slot)
	if from_type == to_type and to_type == 0:
		for connection in get_connection_list():
			if connection.from == from and connection.from_port == from_slot:
				if get_input_slot_type(connection.to, connection.to_port) == 0:
					disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
	connect_node(from, from_slot, to, to_slot)

func shift_connection_up(from, slot_port) -> void:
	var connections = []
	for c in get_connection_list():
		if c.from == from and c.from_port + 1 >= slot_port:
			if c.from_port + 1 != slot_port:
				connections.push_back(c)
			disconnect_node(c.from, c.from_port, c.to, c.to_port)
	for c in connections:
		connect_node(c.from, c.from_port - 1, c.to, c.to_port)

func shift_connection_down(from, slot_port) -> void:
	var connections = []
	for c in get_connection_list():
		if c.from == from and c.from_port >= slot_port:
			connections.push_back(c)
			disconnect_node(c.from, c.from_port, c.to, c.to_port)
	for c in connections:
		connect_node(c.from, c.from_port + 1, c.to, c.to_port)

func get_input_slot_type(from, from_slot) -> int:
	return get_node(from).get_connection_input_type(from_slot)
	
func get_output_slot_type(from, from_slot) -> int:
	return get_node(from).get_connection_output_type(from_slot)

func _get_node_resources() -> Array:
	var node_resources = []
	for node in get_children():
		if not node is GameGraphNode:
			continue
		var n = node.save()
		if n is GameGraphNodeResource:
			node_resources.push_front(n)
	return node_resources

func _get_connections() -> Array:
	return get_connection_list()

func _on_slot_inserted(slot_port: int, dialog: GameGraphNode) -> void:
	shift_connection_down(dialog.name, slot_port)
	
func _on_slot_removed(slot_port: int, dialog: GameGraphNode) -> void:
	shift_connection_up(dialog.name, slot_port)

func _on_GameGraphNode_close_request(node: GameGraphNode) -> void:
	for c in get_connection_list():
		if c.from == node.name or c.to == node.name:
			disconnect_node(c.from, c.from_port, c.to, c.to_port)
	node.queue_free()

func _on_GraphEdit_connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	do_connect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	disconnect_node(from, from_slot, to, to_slot)