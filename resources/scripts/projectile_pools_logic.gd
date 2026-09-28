@icon("res://addons/at-icons/node2d/ammunition.svg")
class_name ProjectilePoolsLogic
extends Node2D

@export var pools_parameters:Dictionary[String, ProjectilePool]

var pools_refs:Dictionary[String, Node2D]

func _ready() -> void:
	setup_all_pools()

func setup_all_pools():
	#var index:int = 0
	for pp in pools_parameters:
		var pool:Node2D = Node2D.new()
		add_child(pool)
		for a in pools_parameters[pp].amount:
			var pro:Projectile = pools_parameters[pp].projectile.instantiate() as Projectile
			pool.add_child(pro)
			pro.setup_projectile()
		pools_refs[pp] = pool
		#index += 1

func fire_projectile(key:String, faction:Projectile.ProjectileFaction, pos:Vector2, rot:float) -> Projectile:
	if pools_refs.has(key) == false: return
	
	for p in pools_refs[key].get_children():
		p = (p as Projectile)
		if p.available:
			p.start_projectile(faction, pos, rot)
			return p
	return null
