@icon("res://addons/at-icons/node2d/sword.svg")
class_name Weapon
extends Area2D

##Moving object taking a weapon resources as its parameters

signal hit_target(target:Node2D)
signal attack_triggered()
signal attack_ready()
signal fired_projectile(projecile:Projectile)
signal blocked_projectile()

@export_group("Behaviour")
@export var weapon_type:WeaponType = WeaponType.OFFENCE
enum WeaponType {OFFENCE, DEFENSE, SUPPORT}
@export var weapon_element:bool = false # TBD
@export var weapon_fuel:bool = false # TBD
@export var target_preference:bool = false # TBD
##Will enemy projectiles be blocked upon touching the weapon?
@export var is_projectile_blocker:bool = false
## If true the weapon will always try to stay within detection range distance of player
@export var stays_next_to_player:bool = false
## If left empty the weapon will behave like a melee weapon
@export var projectile_key:String = ""

@export_group("Stats")
@export var attack_profile:AttackProfile = preload("res://resources/attack_profiles/BaseProfile.tres")
@export var move_speed:float = 1.0
@export var attack_cooldown:float = 1.0
@export var attack_range:float = 1.0
@export var attack_radius:float = 1.0
@export var detection_range:float = 1.0

#Not 100% sure about this method of balancing. My thought process is to say "If I need to increase/decrease all values accross the board I have a quick way to do it"
const base_attack_cooldown: float = 2.0
const base_move_speed: float = 150.0
const base_attack_range: float = 40
const base_detection_range: float = 150.0
const base_attack_radius:float = 20.0
const idle_distance_threshold: float = 5.0

@onready var sprite:Sprite2D = $Sprite2D
@onready var hitbox:CollisionShape2D = $Hitbox
@onready var projectiles_coll = $ProjectileBlocker/ProjecilesColl
@onready var detector:CollisionShape2D = $TargetDetector/DetectorRange 
@onready var attack_CD_timer: Timer = $AttackCooldown

var weapon_center:Node2D
var enabled:bool = false
var is_fighting: bool = false
var is_attacking: bool = false
##global position the holder will try to reach when idling
var idle_position: Vector2 = Vector2.ZERO
var attack_position: Vector2 =  Vector2.ZERO
var attack_offset: Vector2 = Vector2.ZERO
var current_target: Mob
var buffered_targets: Array[Mob]

#region BUILT-IN CALLS
func _ready() -> void:
	attack_CD_timer.wait_time = get_attack_cooldown()
	detector.shape.radius = get_detection_range()
	hitbox.shape.radius = get_attack_radius()
	projectiles_coll.shape.radius = get_attack_radius()

func _physics_process(delta: float) -> void:
	manage_position(delta)
#endregion

#region GENERAL MANAGEMENT
func enable_weapon():
	set_process(true)
	set_physics_process(true)
	projectiles_coll.disabled = !is_projectile_blocker
	
	enabled = true

func disable_weapon():
	set_process(false)
	set_physics_process(false)
	enabled = false

func manage_position(delta:float):
	if is_fighting:
		attack_position = get_attack_position()
		if global_position.distance_to(attack_position) > idle_distance_threshold:
			global_position += (attack_position - global_position).normalized() * get_move_speed() * delta * (global_position.distance_to(attack_position) * 0.05)
			if ((global_position.distance_to(attack_position) <= idle_distance_threshold + 5.0) or projectile_key != "") && not is_attacking:
				attack()
		if !is_near_player():
			#reset_fight()
			pass
	else:
		if global_position.distance_to(idle_position) > idle_distance_threshold:
			global_position += (idle_position - global_position).normalized() * get_move_speed() * delta * (global_position.distance_to(idle_position) * 0.1)

##Gets the position to which the weapon will go when it has a target. Base behaviour is going next to the target
func get_attack_position() -> Vector2:
	if projectile_key == "":
		return current_target.global_position + attack_offset * get_attack_range()
	else:
		return idle_position

func is_near_player() -> bool:
	if stays_next_to_player:
		return get_distance_to_player() < get_detection_range()
	else:
		return true

func get_distance_to_player() -> float:
	return global_position.distance_to(weapon_center.global_position)
#endregion

#region FIGHT FUNCTIONS
##Defines one iteration of an attack. Base behaviour is melee attack
func attack():
	attack_triggered.emit()
	if projectile_key == "": 
		is_attacking = true
		hitbox.disabled = false
		var t = create_tween().set_trans(Tween.TRANS_SINE)
		t.tween_property(self, "global_position", current_target.global_position, 0.1)
		t.tween_property(self, "global_position", attack_position, 0.1)
		await t.finished
		hitbox.disabled = true
		attack_CD_timer.start()
	else:
		is_attacking = true
		
		var p = GblPoolsLogic.fire_projectile(self, projectile_key, Projectile.ProjectileFaction.PLAYER, global_position, self.get_angle_to(current_target.global_position) + PI*0.5)
		fired_projectile.emit(p)
		
		attack_CD_timer.start()

func target(mob:Mob):
	if mob.is_queued_for_deletion(): 
		reset_fight()
		return
	
	is_fighting = true
	current_target = mob
	current_target.connect("death", check_for_target)

func check_for_target():
	var index = -1
	var distance = 9999999
	for i in len(buffered_targets):
		if buffered_targets[i].is_queued_for_deletion():
			continue
		if global_position.distance_to(buffered_targets[i].global_position) < distance:
			distance = global_position.distance_to(buffered_targets[i].global_position)
			index = i
	if index == -1:
		reset_fight()
	else:
		call_deferred("target", buffered_targets[index])
		#target(buffered_targets[index])

func reset_fight():
	buffered_targets.clear()
	current_target = null
	is_fighting = false
#endregion

#region EXTERNAL CALLS
func _on_target_detector_body_entered(body: Node2D) -> void:
	if !enabled: return
	
	if current_target != null:
		buffered_targets.append(body as Mob)
	else:
		target(body as Mob)

func _on_target_detector_body_exited(body: Node2D) -> void:
	if !enabled: return
	
	if (body as Mob) in buffered_targets:
		buffered_targets.erase(body) 

#Hitbox call
func _on_body_entered(body: Node2D) -> void:
	if !enabled: return
	
	if (body as Mob):
		body.on_attacked(self, attack_profile)
		hit_target.emit(body)


#Projectile blocker call
func _on_projectile_blocker_area_entered(area: Area2D) -> void:
	if !enabled: return
	
	if (area as Projectile):
		area.end_projectile()
		blocked_projectile.emit()

func _on_attack_cooldown_timeout() -> void:
	is_attacking = false
	attack_ready.emit()
#endregion

#region STATS GETTERS

func get_attack_cooldown() -> float:
	return base_attack_cooldown * attack_cooldown

func get_move_speed() -> float:
	return base_move_speed * move_speed

func get_attack_range() -> float:
	return base_attack_range * attack_range

func get_detection_range() -> float:
	return base_detection_range * detection_range

func get_attack_radius() -> float:
	return base_attack_radius * attack_radius

#endregion
