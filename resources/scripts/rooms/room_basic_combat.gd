class_name RoomBasicCombat
extends Room

var spawners:Array[MobSpawner]
var spawners_cleared:int = 0

func _ready() -> void:
	setup_room_encounter()
	
	super._ready()

func setup_room_encounter():
	for c in entities_parent.get_children():
		if (c as MobSpawner):
			spawners.append(c)
	
	for s in spawners:
		s.connect("all_mobs_died", on_spawner_cleared)

func start_room():
	for s in spawners:
		s.spawn_mob()
	
	super.start_room()

func on_spawner_cleared():
	spawners_cleared += 1
	if spawners_cleared == spawners.size():
		clear_room()
