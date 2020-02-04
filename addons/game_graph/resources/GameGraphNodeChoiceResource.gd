tool
class_name GameGraphNodeChoiceResource
extends GameGraphNodeResource

export(Resource) var question
export(Array, Resource) var choices

func get_type() -> String:
	return "choice"
