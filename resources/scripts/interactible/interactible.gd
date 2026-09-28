@icon("res://addons/at-icons/node2d/click.svg")
class_name Interactible
extends Area2D

signal interaction(on:bool)

@export_group("Base")
@export var sprite:Sprite2D

@export_group("Parameters")
@export var two_ways:bool = false
##If true, the interactible will automaticaly disable the interaction after the interaction triggered. Should be left true unless specific needs. If false, disabling the interaction should be called manually.
@export var auto_disable_on_interact:bool = true

var can_interact:bool = true
var interacted:bool = false

func interact():
	if not interacted:
		trigger_on()
		if not two_ways:
			can_interact = false
			if auto_disable_on_interact: disable_interaction()
	elif two_ways:
		trigger_off()

func trigger_on():
	interacted = true
	interaction.emit(true)

func trigger_off():
	interacted = false
	interaction.emit(false)

func enable_interaction():
	if can_interact:
		$Container/TextureRect.visible = true
	
func disable_interaction():
	$Container/TextureRect.visible = false
