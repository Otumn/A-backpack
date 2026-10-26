@icon("res://addons/at-icons/node2d/chest.svg")
class_name Chest
extends Interactible

@export var amount:int = 3
@export var object_collection:ObjectSet

const spawn_range:float = 25.0

func trigger_on():
	sprite.frame += 1
	
	var dir:Vector2 = (global_position - GblMainLogic.player.global_position).normalized()
	for i in amount:
		var p: WeaponPickUp = preload("res://scenes/pickables/pickup_weapon.tscn").instantiate() as WeaponPickUp
		p.weapon_scene = object_collection.collection.pick_random()
		p.position = Vector2.ZERO + (dir * spawn_range).rotated((-PI * 0.5) + ((PI / amount) * i))
		call_deferred("add_child", p)
		p.call_deferred("setup_pickable")
	
	super.trigger_on()
