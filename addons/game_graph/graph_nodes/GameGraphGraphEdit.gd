tool
extends GraphEdit

class_name GameGraphGraphEdit

var NodeDialog = preload("GameGraphDialogNode.tscn")
var NodeEventEmitter = preload("GameGraphEventNode.tscn")
var NodeChoice = preload("GameGraphChoiceNode.tscn")
var NodeStart = preload("GameGraphStartNode.tscn")

var id_node = 0

func _ready() -> void:
	add_valid_connection_type(0, 1)
	add_valid_connection_type(1, 0)

func save() -> Resource:
	var resource : GameGraphGraphResource = preload("../resources/GameGraphGraphResource.gd").new()
	resource.nodes = _get_node_resources()
	resource.connections = _get_connections()
	return resource

func new_graph() -> void:
	clear_graph()
	var start = NodeStart.instance()
	start.offset = Vector2(100, 100)
	add_child(start)

func from_resource(resource: GameGraphGraphResource) -> void:
	clear_graph()
	for node_resource in resource.nodes:
		var node : GameGraphNode = _make_node_instance(node_resource.get_type())
		add_child(node)
		node.from_resource(node_resource)
	for connection in resource.connections:
		connect_node(connection.from, connection.from_port, connection.to, connection.to_port)

func clear_graph() -> void:
	clear_connections()
	for node in get_children():
		if node is GameGraphNode:
			node.queue_free()

func add_event_emitter_node(slot_data = null) -> GameGraphEventNode:
	var event = _make_node_instance("event_emitter") as GameGraphEventNode
	add_node_to_graph(event, slot_data)
	return event

func add_dialog_node(slot_data = null) -> GameGraphDialogNode:
	var dialog = _make_node_instance("dialog") as GameGraphDialogNode
	add_node_to_graph(dialog, slot_data)
	return dialog

func add_choice_node(slot_data = null) -> GameGraphChoiceNode:
	var choice = _make_node_instance("choice") as GameGraphChoiceNode
	add_node_to_graph(choice, slot_data)
	return choice

func _make_node_instance(type: String) -> GameGraphNode:
	var node = null
	match type:
		"choice":
			node = NodeChoice.instance()
		"dialog":
			node = NodeDialog.instance()
		"event_emitter":
			node = NodeEventEmitter.instance()
		"start":
			node = NodeStart.instance()
	if node is GameGraphNode:
		node.connect("slot_inserted", self, "_on_slot_inserted", [node])
		node.connect("slot_removed", self, "_on_slot_removed", [node])
	node.connect("close_request", self, "_on_GameGraphNode_close_request", [node])
	return node

func add_node_to_graph(node: GameGraphNode, slot_data = null) -> void:
	add_child(node)
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