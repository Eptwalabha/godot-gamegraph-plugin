tool
extends "res://addons/game_graph/graph_nodes/GameGraphNode.gd"

class_name GameGraphEventNode

func _ready() -> void:
	._ready()
	set_slot(0, true, 1, Color(1, 1, 0), false, 0, Color(0, 0, 1))

func save() -> Resource:
	var resource = preload("../resources/GameGraphNodeEventResource.gd").new()
	resource.offset = offset
	resource.rect_size = rect_size
	resource.node_id = node_id
	resource.event_name = $EventName.text
	return resource

func from_resource(resource: Resource) -> void:
	.from_resource(resource)
	if resource is GameGraphNodeEventResource:
		$EventName.text = resource.event_name