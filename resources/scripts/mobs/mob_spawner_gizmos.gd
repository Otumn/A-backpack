@icon("res://addons/at-icons/node2d/swatches.svg")
@tool
class_name MobSpawnerGizmos
extends Node2D

@export var target:MobSpawner

func _draw() -> void:
	if Engine.is_editor_hint():
		if target.mob != null:
			target.label.text = str(target.spawn_delay)+"s;"+"*"+str(target.spawn_amount)+";"+str(target.spawn_interval)+"s"
