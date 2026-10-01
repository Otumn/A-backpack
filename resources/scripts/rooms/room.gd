@icon("res://addons/at-icons/node2d/tablet.svg")
class_name Room
extends Node2D

signal room_entered(room:Room, x:int, y:int)
signal room_started(room:Room, x:int, y:int)
signal room_cleared(room:Room, x:int, y:int)

@export var coins_on_cleared:int = 2
@export var activity_type:RoomActivityType = RoomActivityType.FREE
enum RoomActivityType {FREE,
FIGHT, BOSSFIGHT,
PUZZLE, STORE,
START_END}
@export var start_room_on_playable_bounds = false

@onready var cam_target:Global2DCameraTarget = $Global2DCameraTarget
@onready var entities_parent:Node2D = $Entities

@onready var lock_left:RoomLocker = $Tiles/RoomLock_left
@onready var lock_right:RoomLocker = $Tiles/RoomLock_right
@onready var lock_top:RoomLocker = $Tiles/RoomLock_top
@onready var lock_bot:RoomLocker = $Tiles/RoomLock_bot

@onready var blck_right: RoomBlocker = $Tiles/blocker_right
@onready var blck_bot: RoomBlocker = $Tiles/blocker_bot
@onready var blck_left: RoomBlocker = $Tiles/blocker_left
@onready var blck_top: RoomBlocker = $Tiles/blocker_top


var geometry_type:RoomGeometryType = RoomGeometryType.MIDDLE
enum RoomGeometryType {MIDDLE, 
RIGHT_SEGMENT, BOT_SEGMENT, LEFT_SEGMENT, TOP_SEGMENT, 
RIGHT_TOP_CORNER, RIGHT_BOT_CORNER, LEFT_BOT_CORNER, LEFT_TOP_CORNER}

var clearance_state:RoomClearanceState = RoomClearanceState.TODO
enum RoomClearanceState{TODO, DOING, CLEARED}

var x_coord:int = 0
var y_coord:int = 0

func _ready() -> void:
	unlock_room()

#region ROOM GEOMETRY
func setup_room_geometry_as(type:RoomGeometryType):
	match type:
		RoomGeometryType.MIDDLE:
			toggle_segments(false, false, false, false)
		RoomGeometryType.RIGHT_SEGMENT:
			toggle_segments(true, false, false, false)
		RoomGeometryType.BOT_SEGMENT:
			toggle_segments(false, true, false, false)
		RoomGeometryType.LEFT_SEGMENT:
			toggle_segments(false, false, true, false)
		RoomGeometryType.TOP_SEGMENT:
			toggle_segments(false, false, false, true)
		RoomGeometryType.RIGHT_TOP_CORNER:
			toggle_segments(true, false, false, true)
		RoomGeometryType.RIGHT_BOT_CORNER:
			toggle_segments(true, true, false, false)
		RoomGeometryType.LEFT_BOT_CORNER:
			toggle_segments(false, true, true, false)
		RoomGeometryType.LEFT_TOP_CORNER:
			toggle_segments(false, false, true, true)
	geometry_type = type

func toggle_segments(right:bool, bot:bool, left:bool, top:bool):
	blck_right.visible = right
	blck_right.coll.disabled = !right
	blck_bot.visible = bot
	blck_bot.coll.disabled = !bot
	blck_left.visible = left
	blck_left.coll.disabled = !left
	blck_top.visible = top
	blck_top.coll.disabled = !top
#endregion

#region ROOM STATE
func enter_room():
	
	Global2dCamera.tween_to_target(cam_target, Tween.TRANS_CUBIC, 1.5)
	room_entered.emit(self, x_coord, y_coord)

func start_room():
	enable_room()
	lock_room()
	clearance_state = RoomClearanceState.DOING
	room_started.emit(self, x_coord, y_coord)

func clear_room():
	disable_room()
	unlock_room()
	clearance_state = RoomClearanceState.CLEARED
	GeneralManager.add_coins(coins_on_cleared)
	room_cleared.emit(self, x_coord, y_coord)
#endregion

#region ROOM CONTROL
func lock_room():
	lock_left.call_deferred("enable_lock")
	lock_right.call_deferred("enable_lock")
	lock_top.call_deferred("enable_lock")
	lock_bot.call_deferred("enable_lock")

func unlock_room():
	lock_left.call_deferred("disable_lock")
	lock_right.call_deferred("disable_lock")
	lock_top.call_deferred("disable_lock")
	lock_bot.call_deferred("disable_lock")

func enable_room():
	pass

func disable_room():
	pass
#endregion

#region EVENTS
func _on_room_bounds_body_entered(_body: Node2D) -> void:
	enter_room()

func _on_playable_bounds_body_entered(_body: Node2D) -> void:
	if start_room_on_playable_bounds && clearance_state == RoomClearanceState.TODO: start_room()
#endregion
