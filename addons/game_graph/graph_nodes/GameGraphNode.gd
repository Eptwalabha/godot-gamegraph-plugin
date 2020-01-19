tool
extends GraphNode

class_name GameGraphNode

signal slot_removed(slot_port)
signal slot_inserted(slot_port)

func _ready() -> void:
	connect("resize_request", self, "_on_GameGraphNode_resize_request")

func _on_GameGraphNode_resize_request(new_minsize: Vector2) -> void:
	rect_size = new_minsize
