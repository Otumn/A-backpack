@icon("res://addons/at-icons/node/reticle.svg")
class_name AttackProfile
extends Resource

@export var damage:int = 1
@export var force: float = 3000.0
@export var stun_time: float = 0.1
##Direction of the hit, given that the hitbox is at neutral scale (1.0;1.0)
@export var type: DamageType = DamageType.NEUTRAL
enum DamageType {NEUTRAL, FIRE, ICE, ELECTRIC}
