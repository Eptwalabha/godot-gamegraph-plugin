tool
class_name GameGraph
extends Node

signal event_triggered(dialog_name, event_name)

export(Resource) var story

var dialogs = {}
var current_dialog = ''
var current_node_id = 0
var current_line_id = 0

func _ready() -> void:
	_build_automaton()

func _get_configuration_warning() -> String:
	if story is GameGraphResource:
		return ""
	else:
		return "In order to work, this custom Node requires a GameGraphResource"

func get_dialog_list() -> Dictionary:
	var d = {}
	for dialog in story.dialogs:
		var key = dialog.dialog_key
		d[key] = {
			'key': key,
			'label': dialog.label
		}
	return d

func start_dialog(dialog_name) -> bool:
	if dialogs.has(dialog_name):
		current_node_id = 0
		current_dialog = dialog_name
		return true
	return false

func next(choice_id = null) -> Dictionary:
	var current_node = get_current_node()
	match current_node.type:
		'start':
			jump_to_next_node()
			for event in current_node.events:
				emit_signal("event_triggered", current_dialog, event)
			return get_next_item()
		'dialog':
			return get_next_item()
		'choice':
			if choice_id != null and choice_id < len(current_node.choices):
				var choice = current_node.choices[choice_id]
				for event in choice.events:
					emit_signal("event_triggered", current_dialog, event)
				if choice.output == null:
					return get_ending()
				current_node_id = choice.output
				current_line_id = 0
				return get_next_item()
	return get_ending()

func is_end_node() -> bool:
	return get_current_node().output == null

func jump_to_next_node() -> void:
	current_node_id = get_current_node().output
	current_line_id = 0

func get_current_node() -> Dictionary:
	return dialogs[current_dialog].nodes[current_node_id]

func get_next_item() -> Dictionary:
	var current_node = get_current_node()
	if current_node.type == 'dialog':
		if current_line_id >= len(current_node.lines):
			for event in current_node.events:
				emit_signal("event_triggered", current_dialog, event)
			if is_end_node():
				return get_ending()
			jump_to_next_node()
			return get_next_item()
		else:
			var line = current_node.lines[current_line_id]
			for event in line.events:
				emit_signal("event_triggered", current_dialog, event)
			current_line_id += 1
			return {
				'type': 'dialog',
				'text': line.text
			}
	elif current_node.type == 'choice':
		var choices = []
		for i in range(len(current_node.choices)):
			var choice = current_node.choices[i]
			choices.push_back({
				'text': choice.text,
				'id': i
			})
		return {
			'type': 'choice',
			'text': current_node.question,
			'choices': choices
		}
	else:
		return get_ending()

func get_ending() -> Dictionary:
	return { 'type': "end" }

func _build_automaton() -> void:
	dialogs = {}
	for dialog in story.dialogs:
		var dialog_key = dialog.dialog_key
		var events = _build_events(dialog.graph.nodes)
		var nodes = _build_nodes(dialog.graph.nodes)
		var connections = dialog.graph.connections
		var connected_nodes = _build_connected_nodes(nodes, events, connections)
		dialogs[dialog_key] = {
			'key': dialog_key,
			'label': dialog.label,
			'nodes': connected_nodes
		}

func _build_nodes(node_resources: Array) -> Dictionary:
	var nodes = {}
	for node in node_resources:
		if not node is GameGraphNodeEventResource:
			nodes[node.node_id] = _to_dictionary(node)
	return nodes

func _build_events(node_resources: Array) -> Dictionary:
	var events = {}
	for node in node_resources:
		if node is GameGraphNodeEventResource:
			events[node.node_id] = node.event_name
	return events

func _build_connected_nodes(
		nodes: Dictionary,
		events: Dictionary,
		connections: Array) -> Dictionary:
	var final_nodes = {}
	for c in connections:
		var from_index = c[0]
		var from = nodes.get(from_index)
		var out_port = c[1]
		var to_index = c[2]
		var is_output_event = events.has(to_index)
		var is_output_node = nodes.has(to_index)
		if not nodes.has(from_index) or not (is_output_event or is_output_node):
			continue

		if not final_nodes.has(from_index):
			final_nodes[from_index] = from

		var from_node = final_nodes[from_index]
		if is_output_node:
			var to = nodes.get(to_index)
			if not final_nodes.has(to_index):
				final_nodes[to_index] = to
			if from.type == 'choice':
				from_node.choices[out_port].output = to_index
			else :
				from_node.output = to_index
		elif is_output_event:
			var event_name : String = events.get(to_index)
			if from.type == 'dialog':
				if out_port == 0:
					from_node.events.push_back(event_name)
				else:
					from_node.lines[out_port - 1].events.push_back(event_name)
			elif from.type == 'start':
				from_node.events.push_back(event_name)
			elif from.type == 'choice':
				from_node.choices[out_port].events.push_back(event_name)
		final_nodes[from_index] = from_node
	return final_nodes

func _to_dictionary(node) -> Dictionary:
	if node is GameGraphNodeDialogResource:
		var dict = {
			'type': "dialog",
			'lines': [],
			'output': null,
			'events': []
		}
		for line in node.dialog_lines:
			dict.lines.push_back({
				'text': line.dialog_key,
				'who': line.who,
				'how': line.how,
				'events': []
			})
		return dict
	elif node is GameGraphNodeChoiceResource:
		var dict = {
			'type': "choice",
			'question': node.question,
			'choices': [],
			'output': null,
			'events': []
		}
		for choice in node.choices:
			dict.choices.push_back({
				'text': choice.choice_key,
				'output': null,
				'events': []
			})
		return dict
	return {
		'type': "start",
		'output': null,
		'events': []
	}
