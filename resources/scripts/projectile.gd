@icon("res://addons/at-icons/node2d/bullet.svg")
class_name Projectile
extends Area2D

##Goes to its up!

@export_group("Base")
@export var speed:float = 75.0
##WILL AFFECT TRAJECTORY
@export var rotation_speed:float = 0.0
@export var sprite_rotation_speed:float = 0.25
@export var faction:ProjectileFaction = ProjectileFaction.MOBS
enum ProjectileFaction {MOBS, PLAYER, NEUTRAL}
@export var attack_profile:AttackProfile

@export_group("Behaviour")
@export var hit_opposing_projectiles:bool = false

@export_group("Feedbacks")
@export var spawn_feedback_key:String = ""
@export var constant_feedback_key:String = ""
@export var hit_feedback_key:String = ""

@onready var sprite:Sprite2D = $Sprite2D
@onready var coll:CollisionShape2D = $CollisionShape2D

var available:bool = false
#who fired this projectile?
var launcher:Node2D

func _physics_process(delta: float) -> void:
	manage_movement(delta)

func manage_movement(delta:float):
	if !available:
		global_position += transform.basis_xform(Vector2(0, -1)) * speed * delta
		rotation += rotation_speed * delta
		sprite.rotation += sprite_rotation_speed * delta

func setup_projectile():
	sprite.visible = true
	coll.disabled = false
	
	set_process(false)
	set_physics_process(false)
	
	available = true

##Set the projectile visible and starts movement
func start_projectile(lau:Node2D, fac:ProjectileFaction, pos:Vector2, rot:float) -> void:
	launcher = lau
	sprite.visible = true
	coll.disabled = false
	
	set_process(true)
	set_physics_process(true)
	
	global_position = pos
	rotation = rot
	
	update_faction(fac)
	set_hit_opposing_projectiles(hit_opposing_projectiles)
	
	if spawn_feedback_key != "":
		pass #TODO : spawn start feedback
	
	if constant_feedback_key != "":
		pass #TODO : spawn looping constant feedback
	
	available = false

##Disable the projectile
func end_projectile():
	sprite.visible = false
	coll.disabled = true
	
	set_process(false)
	set_physics_process(false)
	
	if hit_feedback_key != "":
		pass #TODO : spawn hit feedback
	
	available = true

func update_faction(new:ProjectileFaction):
	match new:
		ProjectileFaction.MOBS:
			set_collision_mask_value(2, true) #player
			set_collision_mask_value(3, false) #mobs
		ProjectileFaction.PLAYER:
			set_collision_mask_value(2, false) #player
			set_collision_mask_value(3, true) #mobs
		ProjectileFaction.NEUTRAL:
			set_collision_mask_value(2, true) #player
			set_collision_mask_value(3, true) #mobs
	faction = new

func set_hit_opposing_projectiles(toggle:bool):
	hit_opposing_projectiles = toggle
	set_collision_mask_value(6, toggle) #mobs

#TODO : collision detection (divided into player, mobs, projectile and maybe weapons)
func treat_collision(target:Node2D):
	#did a whole function for maybe one single thing but it might be useful later we don't know
	if target.has_method("on_attacked"):
		target.on_attacked(launcher, attack_profile)
	call_deferred("end_projectile")

func _on_body_entered(body: Node2D) -> void:
	treat_collision(body)

func _on_area_entered(area: Area2D) -> void:
	treat_collision(area)

func on_attacked(_source:Node2D, _attack:AttackProfile):
	end_projectile()
