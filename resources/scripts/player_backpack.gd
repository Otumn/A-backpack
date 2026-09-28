@icon("res://addons/at-icons/node2d/backpack.svg")
class_name PlayerBackpack
extends CombatBody2D

@export var max_weapons: int = 6
@export var weapons_distance: float = 50.0
@export var walk_speed: float = 50.0

@onready var weapon_center:Marker2D = $WeaponCenter

var x_input:float = 0.0
var y_input:float = 0.0
var current_nb_weapons: int = 0
var weapon_rotation_index: int = 0
var weapons_positions: Array[Vector2]
var weapons: Array[Weapon]
var registered_interactible: Array[Interactible]

#region 
func _ready() -> void:
	GeneralManager.player = self
	HUD.set_hp(current_health)
	HUD.set_weapon_frames(max_weapons)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"): ProjectilePools.fire_projectile("explosion", Projectile.ProjectileFaction.PLAYER, global_position, 0)
	
	manage_inputs()
	manage_weapons_position()
	
	super._process(delta)
#endregion

#region INPUTS
func manage_inputs():
	if is_stunned:
		x_input = 0.0
		y_input = 0.0
	else:
		x_input = Input.get_axis("move_left", "move_right")
		y_input = Input.get_axis("move_up", "move_down")
	input_frame_velocity = Vector2(x_input, y_input).normalized() * walk_speed
	
	if Input.is_action_just_pressed("rotate_weapons_right"): rotate_weapon_right()
	if Input.is_action_just_pressed("rotate_weapons_left"): rotate_weapon_left()
	
	if Input.is_action_just_pressed("interact"): interact()
#endregion

#region WEAPON MANAGEMENT
func manage_weapons_position():
	weapons_positions.resize(current_nb_weapons)
	weapon_center.look_at(get_global_mouse_position())
	weapon_center.rotation += PI * 0.5
	
	if current_nb_weapons == 0: return
	
	var space_state = get_world_2d().direct_space_state
	for i in current_nb_weapons:
		var tested_pos = weapon_center.transform.basis_xform(Vector2(0, -1)).rotated((TAU/float(current_nb_weapons)) * (i + weapon_rotation_index))
		weapons[i].attack_offset = tested_pos
		tested_pos *= weapons_distance
		
		var query = PhysicsRayQueryParameters2D.create(weapon_center.global_position, weapon_center.global_position + tested_pos, 1, [self])
		var result = space_state.intersect_ray(query)
		
		if result:
			weapons_positions[i] = weapon_center.global_position + result.position - position
		else:
			weapons_positions[i] = weapon_center.global_position + tested_pos
		weapons[i].idle_position = weapons_positions[i]

func add_weapon(new_weapon:Weapon) -> bool:
	#add weapon at the last position, no choice in the order here (will be done through UI later)
	if current_nb_weapons == max_weapons: return false
	
	current_nb_weapons += 1
	
	#set holder parameter via weapon resource
	weapons.append(new_weapon)
	new_weapon.weapon_center = weapon_center
	
	#Apparently I need to "call_deferred" I don't get why but whatever
	new_weapon.call_deferred("reparent", get_parent())
	new_weapon.call_deferred("enable_weapon")
	new_weapon.name = "wp"+str(current_nb_weapons)
	
	HUD.add_weapon(new_weapon.sprite)
	
	return true

func remove_weapon(index: int = 0) -> bool:
	if current_nb_weapons == 0: return false
	
	index = current_nb_weapons - 1
	
	weapons[index].queue_free()
	weapons.remove_at(index)
	current_nb_weapons -= 1
	
	weapon_rotation_index = mini(weapon_rotation_index, current_nb_weapons)
	
	return true

func rotate_weapon_right():
	if current_nb_weapons == 0: return
	weapon_rotation_index += 1
	if weapon_rotation_index > current_nb_weapons: weapon_rotation_index = 1

func rotate_weapon_left():
	if current_nb_weapons == 0: return
	weapon_rotation_index -= 1
	if weapon_rotation_index < 0: weapon_rotation_index = current_nb_weapons - 1
#endregion

#region INTERACTION MANAGEMENT
func add_interactible(interactible:Interactible):
	if not interactible in registered_interactible:
		if not registered_interactible.is_empty():
			registered_interactible[0].disable_interaction()
		registered_interactible.push_front(interactible)
		registered_interactible[0].enable_interaction()

func remove_interactible(interactible:Interactible):
	if interactible in registered_interactible:
		interactible.disable_interaction()
		if registered_interactible.find(interactible) == 0 && len(registered_interactible) > 1:
			registered_interactible.erase(interactible)
			registered_interactible[0].enable_interaction()
		else:
			registered_interactible.erase(interactible)

func interact():
	if not registered_interactible.is_empty():
		registered_interactible[0].interact()

func _on_interactible_area_area_entered(area: Area2D) -> void:
	add_interactible(area as Interactible)

func _on_interactible_area_area_exited(area: Area2D) -> void:
	remove_interactible(area as Interactible)
#endregion

func on_attacked(source:Node2D , attack:AttackProfile):
	super.on_attacked(source, attack)
	HUD.set_hp(current_health)

func on_death():
	HUD.display_game_over()
	super.on_death()

func _on_damages_area_body_entered(body: Node2D) -> void: #can't remember why exactly that detection is done here, but I'm pretty sure I had a good reason
	if body.is_in_group("Mobs"):
		var mob = body as Mob
		on_attacked(mob, mob.attack_profile)
		mob.push((mob.global_position - global_position))
