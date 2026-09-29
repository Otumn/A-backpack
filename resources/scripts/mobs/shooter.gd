class_name Shooter
extends Mob

@export var projectile_key:String = "base"
@export var shoot_delay:float = 1.0
@export var target_player:bool = true

@onready var shoot_timer:Timer = $ShootTimer

func _ready() -> void:
	super._ready()
	shoot_timer.wait_time = shoot_delay
	shoot_timer.start()

func shoot():
	var r = get_angle_to(GeneralManager.player.global_position) + (PI * 0.5) if target_player else rotation 
	ProjectilePools.fire_projectile(self, projectile_key, Projectile.ProjectileFaction.MOBS, global_position, r)
	shoot_timer.start()

func push(_dir: Vector2, _force:float = 150.0, _time: float = 0.1):
	return #CAN'T BE PUSHED

func can_move() -> bool:
	return false #CAN'T MOVE

func _on_shoot_timer_timeout() -> void:
	shoot()
