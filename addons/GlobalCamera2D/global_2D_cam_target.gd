class_name Global2DCameraTarget
extends Node2D

@export_group("Base")
## Can only have ONE starter_target! Can't guarantee anything if multiple are there! The target will also be considered the base one
@export var starter_target: bool = false
@export var offset: Vector2 = Vector2(0.0, 0.0)
@export var zoom: Vector2 = Vector2(1.0, 1.0)
@export_group("Limits")
@export var limits_left: int = -10000000
@export var limits_top: int = -10000000
@export var limits_right: int = 10000000
@export var limits_bottom: int = 10000000
@export var smoothed_limits: bool = false
@export_group("Smoothing")
@export var position_smoothing: bool = false
@export var position_smoothing_speed: float = 5.0
@export var rotation_smoothing: bool = false
@export var rotation_smoothing_speed: float = 5.0
@export_group("Drag")
@export var h_drag_enabled: bool = false
@export var v_drag_enabled: bool = false
@export_range(-1, 1, 0.001) var drag_h_offset: float = 0.0
@export_range(-1, 1, 0.001) var drag_v_offset: float = 0.0
@export_range(0, 1, 0.01) var drag_left_margin: float = 0.2
@export_range(0, 1, 0.01) var drag_top_margin: float = 0.2
@export_range(0, 1, 0.01) var drag_right_margin: float = 0.2
@export_range(0, 1, 0.01) var drag_bottom_margin: float = 0.2

func _ready() -> void:
	if starter_target :
		Global2dCamera.global_position = global_position
		await get_tree().create_timer(0.1).timeout
		Global2dCamera.cut_to_target(self, true)
		var t = create_tween().set_trans(Tween.TRANS_SINE)
		t.tween_method(Global2dCamera.set_fade_alpha, 1.0, 0.0, 0.35)
		Global2dCamera.is_setup = true
