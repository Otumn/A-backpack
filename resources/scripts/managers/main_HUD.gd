class_name MainHUD
extends CanvasLayer

signal hp_changed(old_hp:int, new_hp:int)
signal weapon_frame_changed(old_value:int, new_value:int)

@export_range(1, 100, 1) var hp_sprite_pool:int = 20
@export_range(1, 100, 1) var weapon_frame_sprite_pool:int = 8

@onready var in_game_cont:Control = $InGameContainer
@onready var hp:TextureRect = $InGameContainer/HealthContainer/HP
@onready var weapon_frame:WeaponFrame = $InGameContainer/WeaponsContainer/WeaponFrame
@onready var coins_label:Label = $InGameContainer/LabelContainer/CoinsLabel
@onready var value_label:Label = $InGameContainer/LabelContainer/ValueLabel

@onready var game_over_cont:Control = $GameOverContainer

@onready var pause_cont:Control = $PauseContainer

@onready var options_cont:Control = $OptionsContainer

var hps:Array[TextureRect] = []
var current_hp:int = 5
var wpfs:Array[WeaponFrame] = []
var current_weapon_amount = 6
var next_weapon_index = 0

func _ready() -> void:
	setup_pools()
	GeneralManager.connect("coins_set", _on_coins_set)
	GeneralManager.connect("coins_added", _on_coins_added)
	GeneralManager.connect("value_set", _on_value_set)
	GeneralManager.connect("value_added", _on_value_added)

#region IN GAME HUD
func display_in_game_HUD(toggle:bool):
	in_game_cont.visible = toggle

func setup_pools():
	var parent = hp.get_parent()
	for i in hp_sprite_pool - 1:
		var d
		if i == 0:
			d = hp
		else:
			d = hp.duplicate()
			parent.add_child(d)
		hps.append(d)
		d.visible = false
	
	parent = weapon_frame.get_parent()
	for i in weapon_frame_sprite_pool:
		var wp
		if i == 0:
			wp = weapon_frame
		else:
			wp = weapon_frame.duplicate()
			parent.add_child(wp)
		wpfs.append(wp)

func set_hp(value:int):
	var old_value = current_hp
	current_hp = value
	
	for i in len(hps):
		hps[i].visible = i < value
	
	hp_changed.emit(old_value, current_hp)

func set_weapon_frames(value:int):
	var old = current_weapon_amount
	current_weapon_amount = value
	
	for i in weapon_frame_sprite_pool:
		wpfs[weapon_frame_sprite_pool - 1 - i].visible = i < value
		#wpfs[i].visible = true
	
	next_weapon_index = len(wpfs) - 1
	weapon_frame_changed.emit(old, current_weapon_amount)

func add_weapon(sprite:Sprite2D):
	wpfs[next_weapon_index].set_icon_texture(sprite)
	next_weapon_index -= 1
#endregion

#region PAUSE MENU
func display_pause_menu(toggle:bool):
	pause_cont.visible = toggle
#endregion

#region OPTIONS MENU
func display_option_menu(toggle:bool):
	options_cont.visible = toggle
#endregion

#region GAME OVER
func display_game_over(toggle:bool):
	game_over_cont.visible = toggle

func _on_go_button_pressed() -> void:
	Global2dCamera.is_setup = false
	get_tree().reload_current_scene()
	display_game_over(false)
#endregion

#region INTERNAL EVENTS

#endregion

#region EXTERNAL EVENTS
func _on_coins_set(_old:int, new:int):
	coins_label.text = "Coins : " + str(new)

func _on_coins_added(_old:int, new:int):
	coins_label.text = "Coins : " + str(new)

func _on_value_set(_old:int, new:int):
	value_label.text = "Value : " + str(new)

func _on_value_added(_old:int, new:int):
	value_label.text = "Value : " + str(new)
#endregion
