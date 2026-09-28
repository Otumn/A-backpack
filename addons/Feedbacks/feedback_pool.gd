class_name FeedbackPool
extends Node2D

@export var target_feedback: PackedScene;
@export var pool_size: int = 10;
var pool: Array[Feedback];

func _ready() -> void:
	for i in range(pool_size):
		var fb = target_feedback.instantiate() as Feedback
		pool.append(fb)
		fb.setup_feedback()
		fb.stop_feedback()
		add_child(fb)

func get_available_feedback() -> Feedback:
	for i in pool:
		if i.available:
			return i
	return null
