tool
extends "GameGraphNode.gd"

class_name GameGraphStartNode

var NodeResource = preload("res://addons/game_graph/resources/GameGraphNodeStartResource.gd")

func _ready() -> void:
	._ready()
	set_slot(0, false, 1, Color(1, 1, 0), true, 0, Color(0, 0, 1))

func save() -> Resource:
	var resource = NodeResource.new()
	resource.offset = offset
	resource.rect_size = rect_size
	resource.node_id = 0
	return resource

func from_resource(resource: Resource) -> void:
	.from_resource(resource)
