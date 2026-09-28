@icon("res://addons/at-icons/node2d/hand.svg")
class_name WeaponPickUp
extends Pickable

var weapon:Weapon
var weapon_scene:PackedScene

func setup_pickable():
	weapon = weapon_scene.instantiate() as Weapon
	add_child(weapon)
	weapon.disable_weapon()
	super.setup_pickable()

func pick_up(player: PlayerBackpack):
	if player.add_weapon(weapon): 
		queue_free()
	else:
		pass #TODO: feedback and shit
	
	super.pick_up(player)

#Collision only scans for the player
func _on_body_entered(body: Node2D) -> void:
	pick_up(body as PlayerBackpack)
