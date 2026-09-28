@icon("res://addons/at-icons/node2d/vortex.svg")
class_name MobSpawner
extends Node2D

signal spawned_mob(mob:Mob, nb:int)
signal all_mobs_spawned
signal mob_died
signal all_mobs_died

@export var mob:PackedScene
@export var spawn_amount:int = 2
@export var spawn_interval:float = 0.25
@export var spawn_delay:float = 0.1
@export var take_rotation:bool = false
@export var label:Label

@onready var sprite:Sprite2D = $Sprite2D
@onready var spawn_timer:Timer = $SpawnTimer
@onready var delay_timer:Timer = $DelayTimer

var first_spawn:bool = true
var mob_spawned:int = 0
var mob_dead:int = 0

func _ready() -> void:
	delay_timer.wait_time = spawn_delay
	spawn_timer.wait_time = spawn_interval
	sprite.visible = false
	label.visible = false

func spawn_mob():
	if first_spawn:
		delay_timer.start()
		first_spawn = false
		return
	
	var m = mob.instantiate() as Mob
	#m.global_position = global_position
	if take_rotation: m.rotation = rotation
	call_deferred("add_child", m)
	m.connect("death", _on_mob_death)
	mob_spawned += 1
	spawned_mob.emit(m, mob_spawned)
	if mob_spawned < spawn_amount:
		spawn_timer.start()
	else:
		all_mobs_spawned.emit()

func _on_mob_death():
	mob_died.emit()
	mob_dead += 1
	if mob_dead == spawn_amount:
		all_mobs_died.emit()

func _on_spawn_timer_timeout() -> void:
	if mob_spawned < spawn_amount:
		spawn_mob()

func _on_delay_timer_timeout() -> void:
	spawn_mob()
