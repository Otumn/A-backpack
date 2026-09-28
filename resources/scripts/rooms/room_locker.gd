@icon("res://addons/at-icons/node2d/lock.svg")
class_name RoomLocker
extends Node2D

signal enabled
signal disabled

@onready var left_sprite:Sprite2D = $Sprite_left
@onready var right_sprite:Sprite2D = $Sprite_right
@onready var coll:CollisionShape2D = $StaticBody2D/CollisionShape2D

func enable_lock():
	left_sprite.visible = true
	right_sprite.visible = true
	coll.disabled = false
	enabled.emit()

func disable_lock():
	left_sprite.visible = false
	right_sprite.visible = false
	coll.disabled = true
	disabled.emit()
