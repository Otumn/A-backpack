@icon("res://addons/at-icons/node2d/coin.svg")
class_name Pickable
extends Area2D

signal setup
signal picked_up

func setup_pickable():
	setup.emit()

func pick_up(_player: PlayerBackpack):
	picked_up.emit()
