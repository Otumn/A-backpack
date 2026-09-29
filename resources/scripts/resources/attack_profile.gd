@icon("res://addons/at-icons/node/reticle.svg")
class_name AttackProfile
extends Resource

@export var damage:int = 1
@export var force: float = 1
@export var stun_time: float = 0.1
@export var type: DamageType = DamageType.NEUTRAL
enum DamageType {NEUTRAL, FIRE, ICE, ELECTRIC}

const base_force:float = 300.0

func get_force(adjusted:bool = false) -> float:
	return base_force * force * 10 if adjusted else base_force * force 
