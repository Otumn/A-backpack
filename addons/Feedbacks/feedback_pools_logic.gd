class_name FeedbackLogic
extends Node2D

@export var pools: Dictionary[String, FeedbackPool]

func trigger_feedback(type: String, pos: Vector2, rot: float) -> Feedback:
	var f = pools[type].get_available_feedback()
	if f != null:
		f.trigger_feedback(pos, rot)
	else:
		print("f was null")
	return f
