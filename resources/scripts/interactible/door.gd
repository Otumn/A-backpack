@icon("res://addons/at-icons/node2d/doors.svg")
class_name Door
extends Interactible

@export var coll:CollisionShape2D

func trigger_on():
	sprite.frame += 1
	coll.disabled = true
	super.trigger_on()

func trigger_off():
	sprite.frame -= 1
	coll.disabled = false
	super.trigger_off()
