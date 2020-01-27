tool
extends Node

class_name GameGraph

signal event_triggered(dialog_name, event_name)

var dialogs = {}

var i = 0
var current_dialog = ''
var current_node_id = 0

export(Resource) var story

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

func next_dialog() -> Dictionary:
	i += 1
	if i == 1:
		return {
			'type': 'dialog',
			'text': 'super mon text'
		}
	else:
		return {
			'type': 'choice',
			'text': 'super first choice',
			'choices': [
				{
					'label': 'super',
					'id': 0
				}
			]
		}

func pick_choice(choice_id: int) -> Dictionary:
	if choice_id == 0:
		return {
			'type': 'choice',
			'text': 'again ?',
			'choices': [
				{
					'label': 'yes',
					'id': 0
				},
				{
					'label': 'nope!',
					'id': 1
				}
			]
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
	print(dialogs)

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

func _build_connected_nodes(nodes: Dictionary, events: Dictionary, connections: Array) -> Dictionary:
	var automata = {}
#	TODO cycle through all connections, complete all node an build the graph
	return automata

func _to_dictionary(node) -> Dictionary:
	if node is GameGraphNodeDialogResource:
		var dict = {
			'type': "dialog",
			'lines': []
		}
		for line in node.dialog_lines:
			dict.lines.push_back({
				'text': line.dialog_key,
				'who': line.who,
				'how': line.how
			})
		return dict
	elif node is GameGraphNodeChoiceResource:
		var dict = {
			'type': "choice",
			'question': node.question,
			'choices': []
		}
		for choice in node.choices:
			dict.choices.push_back({
				'text': choice.choice_key
			})
		return dict
	return {
		'type': "start"
	}
