@icon("res://addons/at-icons/node2d/gate.svg")
class_name RoomDoor
extends Interactible

signal unlocked
signal blocked
signal deblocked

@onready var blocker:CollisionShape2D = $Collider/CollisionShape2D
##Whether or not the door can be interacted with. Similar to can_interact but useful for room flow, custom funcs, signal
var is_blocked:bool = false
##Whether or not the price has been paid to open this door. If true, then the door will be interactible when its room is cleared, if not it will wait to be paid for
var is_unlocked:bool = false
##Whether or not the open is ACTUALLY opened. Lets the player pass and all
var is_open:bool = false

func open_door():
	sprite.frame = 1
	call_deferred("enable_blocker", false)
	is_open = true

func close_door():
	sprite.frame = 0
	call_deferred("enable_blocker", true)
	is_open = false

func enable_blocker(enabled:bool):
	blocker.disabled = !enabled

func unlock_door():
	is_unlocked = true
	unlocked.emit()

func block_door():
	is_blocked = true
	enable_blocker(true)
	sprite.frame = 2
	blocked.emit()

func deblock_door():
	is_blocked = false
	enable_blocker(false)
	sprite.frame = 0
	deblocked.emit()

#region INTERACTIBLE
func trigger_on():
	unlock_door()
	super.disable_interaction() #Needed to disable the interaction sprite
	super.trigger_on()
	open_door()

func enable_interaction():
	if is_blocked:return
	if is_unlocked:
		open_door()
	else:
		super.enable_interaction()

func disable_interaction():
	if is_blocked:return
	if is_unlocked:
		if is_open: close_door()
	else:
		super.disable_interaction()
#endregion
