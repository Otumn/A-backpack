@icon("res://addons/at-icons/node2d/crash_test_dummy.svg")
class_name CombatBody2D
extends CharacterBody2D

signal landed_wall(only_wall: bool)
signal started_walk(new_direction: Vector2)
signal changed_walk_direction(new_direction: Vector2)
signal pushed(force: float, direction: Vector2)
signal hurt(old_health: int, new_health: int)
@warning_ignore("unused_signal")
signal healed(old_health: int, new_health: int)
signal died

@export_group("Combat")
@export var health: int = 5
##The higher the value, the more the character will get back controls of its body after being hit
@export var stun_resistance: float = 1.0

@export_group("Velocity")
@export var max_input_velocity: float = 300.0
##Length below which the body will be considered "at rest", used to detect when the body starts walking for example
@export var walk_start_threshold: float = 15.0
##Dot value to which the walking direction will be compared to know if the body has changed its input direction
@export_range(-1.0, 1.0, 0.01) var walk_change_threshold: float = 0.0
@export var max_forced_velocity: float = 5000.0
@export var min_forced_velocity: float = 15.0
@export var pushed_min_threshold: float = 20.0
@export var forced_velocity_decay = 100.0
@export var forced_velocity_decay_delay = 0.15
@onready var current_health: int = health


#velocities

## Actual input velocity used to calculate the final velocity. Is not meant to be modified directly
var applied_input_velocity: Vector2 = Vector2.ZERO
## Input velocity meant to be used as a constant force throughout frames, is not reset automaticaly
var input_lagging_velocity: Vector2 = Vector2.ZERO
## Input velocity meant to be used as a single value frame per frame, is reset automaticaly
var input_frame_velocity: Vector2 = Vector2.ZERO
## Velocity modified by the pushed event and equivalent
var forced_velocity: Vector2 = Vector2.ZERO
## Actual forced velocity used to calculate the final velocity. Is not meant to be modified directly
var applied_forced_velocity: Vector2 = Vector2.ZERO

#buffers

var input_velocity_y_buffer: Array[float] = [0.0, 0.0]
var input_velocity_x_buffer: Array[float] = [0.0, 0.0]
var on_wall_buffer: bool


#general variables

##if true, character is looking to the left
var is_flipped: bool = false
var is_counting_decay_time: bool = false
var forced_vel_decay_time: float = 0.0
var is_stunned: bool = false
var stunned_time: float = 0.0

#region BUILT-IN CALLS
func _process(delta: float) -> void:
	if is_counting_decay_time : 
		forced_vel_decay_time += delta
		if forced_vel_decay_time >= forced_velocity_decay_delay: 
			forced_vel_decay_time = 0
			is_counting_decay_time = false
	if is_stunned:
		stunned_time -= delta
		if stunned_time <= 0.0:
			is_stunned = false

func _physics_process(delta: float) -> void:
	manage_input_velocity(delta)
	manage_forced_velocity(delta)
	
	manage_buffers()
	sum_up_velocities()
	move_and_slide()
#endregion

#region MANAGERS
func manage_forced_velocity(delta: float):
	if forced_velocity.length() != 0:
		if !is_counting_decay_time: forced_velocity += -(forced_velocity.normalized()) * forced_velocity_decay
		
		if forced_velocity.length() > max_forced_velocity : forced_velocity = forced_velocity.normalized() * max_forced_velocity
		if forced_velocity.length() < min_forced_velocity : forced_velocity = Vector2.ZERO
		applied_forced_velocity = forced_velocity * delta

func manage_input_velocity(delta:float):
	applied_input_velocity = input_frame_velocity + input_lagging_velocity * delta
	
	if applied_input_velocity.length() > max_input_velocity: applied_input_velocity = applied_input_velocity.normalized() * max_input_velocity

func manage_buffers():
	#need to be the last manager called in physics process, right before move_and_slide()
	if is_on_wall() && not on_wall_buffer:
		landed_wall.emit(is_on_wall_only())
	on_wall_buffer = is_on_wall()
	
	input_velocity_x_buffer.push_front(applied_input_velocity.x)
	input_velocity_x_buffer.resize(2)
	input_velocity_y_buffer.push_front(applied_input_velocity.y)
	input_velocity_y_buffer.resize(2)
	
	var prev_vel = Vector2(input_velocity_x_buffer[1], input_velocity_y_buffer[1])
	if prev_vel.length() < walk_start_threshold &&  applied_input_velocity.length() != 0:
		started_walk.emit(applied_input_velocity)
	elif applied_input_velocity.normalized().dot(prev_vel.normalized()) < walk_change_threshold && applied_input_velocity.length() != 0:
		changed_walk_direction.emit(applied_forced_velocity)

func sum_up_velocities():
	velocity = applied_input_velocity + applied_forced_velocity
	input_frame_velocity = Vector2.ZERO
#endregion

func on_attacked(source:Node2D , attack:AttackProfile):
	var h = current_health
	current_health = maxi(current_health - (attack.damage), 0)
	hurt.emit(h, current_health)
	
	if current_health == 0 : 
		on_death()
		return
	
	is_stunned = true
	stunned_time = attack.stun_time * stun_resistance
	push_combat_body_2D(attack.force, global_position - source.global_position)

func on_death():
	died.emit()

func on_healed():
	#don't know about the architecture
	pass

func push_combat_body_2D(force: float, direction: Vector2):
	forced_velocity += direction.normalized() * force
	is_counting_decay_time = true
	forced_vel_decay_time = 0.0
	
	pushed.emit(force, direction)

func is_pushed() -> bool:
	return applied_forced_velocity.length() > applied_input_velocity.length() && applied_forced_velocity.length() > pushed_min_threshold

func get_next_frame_raw_velocity() -> Vector2:
	return input_frame_velocity + input_lagging_velocity + forced_velocity
