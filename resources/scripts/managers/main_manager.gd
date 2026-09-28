class_name GameManager
extends Node

signal coins_set(old_amount:int, new_amount:int)
signal coins_added(old_amount:int, new_amount:int)
signal value_set(old_amount:int, new_amount:int)
signal value_added(old_amount:int, new_amount:int)

var player:PlayerBackpack
var current_floor_depth:int = 1
##used to open doors and interact with enviro. TBD name
var current_coins:int = 0
##used to scale character. TBD name
var current_value:int = 0


func spawn_player_bakcpack(parent:Node2D, position:Vector2):
	var b:PlayerBackpack = preload("res://scenes/player_backpack.tscn").instantiate()
	b.global_position = position
	parent.add_child(b)

func set_coins(amount:int):
	var old = current_coins
	current_coins = amount
	coins_set.emit(old, current_coins)


func add_coins(amount:int):
	var old = current_coins
	current_coins += amount
	coins_added.emit(old, current_coins)

func set_value(amount:int):
	var old = current_value
	current_value = amount
	value_set.emit(old, current_value)

func add_value(amount:int):
	var old = current_value
	current_value += amount
	value_added.emit(old, current_value)
