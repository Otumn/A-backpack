@icon("res://addons/at-icons/node/list_unordered.svg")
class_name FloorParams
extends Resource

@export_group("Base")
@export var difficulty_mult:float = 1.0
@export var size_x:int = 5
@export var size_y:int = 5

@export_group("Rooms")
@export var starting_room:PackedScene = preload("res://scenes/rooms/start/room_start_00.tscn")
@export var room_doors:PackedScene
@export var possible_loot:bool = false # TBD
## Key = room scenes directory, value = directory selection probability. CANNOT BE EMPTY
@export var possible_rooms_collections:Dictionary[ObjectSet, float]

func get_total_probability() -> float:
	var t:float = 0.0
	for d in possible_rooms_collections:
		t += possible_rooms_collections[d]
	return t

func get_collection_from_proba(value:float) -> ObjectSet:
	var t:float = 0.0
	for d in possible_rooms_collections:
		t += possible_rooms_collections[d]
		if value <= t:
			return d
	return null

func get_random_room_collection() -> ObjectSet:
	var r: float = randf_range(0.0, get_total_probability())
	return get_collection_from_proba(r)
