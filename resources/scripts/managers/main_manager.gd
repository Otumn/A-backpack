class_name GameManager
extends Node

signal coins_set(old_amount:int, new_amount:int)
signal coins_added(old_amount:int, new_amount:int)
signal value_set(old_amount:int, new_amount:int)
signal value_added(old_amount:int, new_amount:int)

var player:PlayerBackpack
var run_data:DataRun

func load_run_data(data:DataRun = null):
	if data == null:
		data = DataRun.new()
	run_data = data

func spawn_player_bakcpack(parent:Node2D, position:Vector2):
	var b:PlayerBackpack = preload("res://scenes/player_backpack.tscn").instantiate()
	b.global_position = position
	player = b
	parent.add_child(b)

func set_coins(amount:int):
	var old = run_data.current_coins
	run_data.current_coins = amount
	coins_set.emit(old, run_data.current_coins)

func add_coins(amount:int):
	var old = run_data.current_coins
	run_data.current_coins += amount
	coins_added.emit(old, run_data.current_coins)

func set_value(amount:int):
	var old = run_data.current_value
	run_data.current_value = amount
	value_set.emit(old, run_data.current_value)

func add_value(amount:int):
	var old = run_data.current_value
	run_data.current_value += amount
	value_added.emit(old, run_data.current_value)
