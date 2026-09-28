@icon("res://addons/at-icons/node2d/checkerboard.svg")
class_name PlayedFloor
extends Node2D

@export var p:FloorParams

@onready var room_parent:Node2D = $RoomParent
@onready var player_parent:Node2D = $PlayerParent

const room_size:Vector2 = Vector2(1216.0, 704.0)
const combat_room_dir:String = "res://scenes/rooms/combat/"

func _ready() -> void:
	load_floor(p)

func load_floor(params:FloorParams):
	for x in params.size_x:
		for y in params.size_y:
			var u = x + 1
			var v = y + 1
			var room:Room
			
			#Room spawn
			@warning_ignore("integer_division")
			if u == (params.size_x + 1) / 2 && v == (params.size_y + 1) / 2:
				room = preload("res://scenes/rooms/room_start.tscn").instantiate() # load the starting room
				GeneralManager.spawn_player_bakcpack(room_parent, Vector2(x * room_size.x, y * room_size.y))
			else:
				var a = DirAccess.get_files_at(combat_room_dir)
				room = load(combat_room_dir+a[randi()%a.size()]).instantiate() # load a normal room
			
			room.global_position = Vector2(x * room_size.x, y * room_size.y)
			room_parent.add_child(room)
			room.x_coord = u
			room.y_coord = v
			
			if v == 1: #top
				if u == 1: #left top corner
					room.setup_room_geometry_as(Room.RoomGeometryType.LEFT_TOP_CORNER)
				elif u == params.size_x: #right top corner
					room.setup_room_geometry_as(Room.RoomGeometryType.RIGHT_TOP_CORNER)
				else: #top segment
					room.setup_room_geometry_as(Room.RoomGeometryType.TOP_SEGMENT)
			elif v == params.size_y: #bot
				if u == 1: #left bot corner
					room.setup_room_geometry_as(Room.RoomGeometryType.LEFT_BOT_CORNER)
				elif u == params.size_x: #right bot corner
					room.setup_room_geometry_as(Room.RoomGeometryType.RIGHT_BOT_CORNER)
				else: #bot segment
					room.setup_room_geometry_as(Room.RoomGeometryType.BOT_SEGMENT)
			else:
				if u == 1: #left segment
					room.setup_room_geometry_as(Room.RoomGeometryType.LEFT_SEGMENT)
				elif u == params.size_x: #right segment
					room.setup_room_geometry_as(Room.RoomGeometryType.RIGHT_SEGMENT)
				else: #middle part
					room.setup_room_geometry_as(Room.RoomGeometryType.MIDDLE)
			
	#horizontal door spawn
	for x in params.size_x: #row
		for y in params.size_y - 1: #column
			var door:RoomDoor = params.room_doors.instantiate()
			door.global_position = Vector2((room_size.x * 0.5) + y * room_size.x, x * room_size.y)
			room_parent.add_child(door)
			door.rotation = PI * 0.5
			
	#vertital door spawn
	for x in params.size_x - 1: #row
		for y in params.size_y: #column
			var door:RoomDoor = params.room_doors.instantiate()
			room_parent.add_child(door)
			door.global_position = Vector2(y * room_size.x,(room_size.y * 0.5) + x * room_size.y)
