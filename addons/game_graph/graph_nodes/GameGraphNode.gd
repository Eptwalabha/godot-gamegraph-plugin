tool
extends GraphNode

class_name GameGraphNode

signal slot_removed(slot_port)
signal slot_inserted(slot_port)

var node_id = 0
var removed = false

func _ready() -> void:
	pass

func save() -> Resource:
	return null

func get_slot_offset() -> int:
	return 0

func from_resource(resource: Resource) -> void:
	if resource is GameGraphNodeResource:
		offset = resource.offset
		rect_size = resource.rect_size
		node_id = resource.node_id

func _on_GameGraphNode_resize_request(new_minsize: Vector2) -> void:
	rect_size = new_minsize
