tool
extends "res://addons/game_graph/graph_nodes/GameGraphNode.gd"

class_name GameGraphStartNode

func _ready() -> void:
	._ready()
	set_slot(0, false, 1, Color(1, 1, 0), true, 0, Color(0, 0, 1))

func save() -> Resource:
	var resource = preload("../resources/GameGraphNodeStartResource.gd").new()
	resource.name = name
	resource.offset = offset
	resource.rect_size = rect_size
	resource.node_id = 0
	return resource

func from_resource(resource: Resource) -> void:
	.from_resource(resource)