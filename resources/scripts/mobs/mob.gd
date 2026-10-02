@icon("res://addons/at-icons/node2d/carnival_mask.svg")
class_name Mob
extends CharacterBody2D

##Moving object taking a mob resources as its parameters

signal hurt(old_health, new_health)
signal death

@export_group("Base")
@export var sprite:Sprite2D
@export var body_coll:CollisionShape2D
@export var health_bar:TextureProgressBar

@export_group("Stats")
@export var attack_profile:AttackProfile = preload("res://resources/attack_profiles/BaseProfile.tres")
@export var health:int = 1
# the lower the resistance, the more the mob will resist getting pushed
@export var stun_resistance:float = 1.0
@export var move_speed:float = 1

const base_health:float = 10.0
const base_stun_resistance:float = 1.0
const base_move_speed:float = 50.0

var current_health:int = 0
var move_dir:Vector2 = Vector2.ZERO
var pushed_time:float = 0.0
var is_pushed:bool = false


func _init() -> void:
	current_health = get_scaled_health()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_pushed:
		pushed_time -= delta
		if pushed_time < 0:
			is_pushed = false

func _physics_process(_delta: float) -> void:
	if can_move():  
		move_dir = (GeneralManager.player.global_position - global_position).normalized()
		velocity = move_dir * get_move_speed()
		
	move_and_slide()

func on_attacked(source:Node2D, attack:AttackProfile):
	hit(attack.damage)
	push((global_position - source.global_position), attack.get_force(), attack.get_stun_time() * get_stun_resistance())

func hit(damage:int):
	var old = current_health
	current_health = maxi(current_health - damage, 0)
	hurt.emit(old, current_health)
	health_bar.value = inverse_lerp(0, get_scaled_health(), current_health)
	#TODO : add feedback
	if current_health == 0:
		queue_free()
		death.emit()

func push(dir: Vector2, force:float = 150.0, time: float = 0.1):
	velocity = dir.normalized() * force
	pushed_time = time
	
	is_pushed = true

func can_move() -> bool:
	return not is_pushed

func get_scaled_health() -> int:
	return roundi(get_health() * GeneralManager.run_data.difficulty)

func get_health() -> int:
	return roundi(base_health*health)

func get_stun_resistance() -> float:
	return base_stun_resistance * stun_resistance

func get_move_speed() -> float:
	return base_move_speed * move_speed
