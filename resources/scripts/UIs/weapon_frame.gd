@icon("res://addons/at-icons/control/sky.svg")
class_name WeaponFrame
extends TextureRect

@export var icon:Sprite2D

var x_coord:int = 0
var y_coord:int = 0
var region_size:float = 32.0

func set_icon_texture(sprite:Sprite2D):
	if icon == null:
		return
	icon.texture = sprite.texture
	icon.frame_coords = sprite.frame_coords
	icon.hframes = sprite.hframes
	icon.vframes = sprite.vframes
