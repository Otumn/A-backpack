@icon("res://addons/at-icons/node/reticle.svg")
class_name AttackProfile
extends Resource

@export var damage:int = 1
@export var force: float = 1
@export var stun_time: float = 1
@export var type: DamageType = DamageType.NEUTRAL
enum DamageType {NEUTRAL, FIRE, ICE, ELECTRIC}

const base_force:float = 150.0
const base_stun_time = 0.2

func get_force(adjusted:bool = false) -> float:
	return base_force * force * 10 if adjusted else base_force * force 

func get_stun_time() -> float:
	return base_stun_time * stun_time
