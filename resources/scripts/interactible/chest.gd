@icon("res://addons/at-icons/node2d/chest.svg")
class_name Chest
extends Interactible

@export var amount:int = 3
@export var weapon_collection:WeaponSet
@export var spawn_range:float = 35.0

func trigger_on():
	sprite.frame += 1
	
	var dir:Vector2 = (global_position - GeneralManager.player.global_position).normalized()
	for i in amount:
		var p: WeaponPickUp = preload("res://scenes/pickables/pickable_weapon.tscn").instantiate() as WeaponPickUp
		p.weapon_scene = load(weapon_collection.collection.pick_random())
		p.position = Vector2.ZERO + (dir * spawn_range).rotated((-PI * 0.5) + ((PI / amount) * i))
		call_deferred("add_child", p)
		p.call_deferred("setup_pickable")
	
	super.trigger_on()
