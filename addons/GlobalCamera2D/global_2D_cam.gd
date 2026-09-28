class_name Global2DCamera
extends Camera2D

@export_group("Cam shake")
@export var shake_decay: float = 0.8
@export var shake_max_offset: Vector2 = Vector2(100, 75)
@export var shake_max_roll: float = 0.1

@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

var main_target: Global2DCameraTarget
var current_target: Global2DCameraTarget
var t: Tween
var tracked_pos: Vector2

var is_tweening_trans: bool = false
var is_setup: bool = false
var position_alpha: float = 0.0
var position_alpha_target: float = 0.0
var start_pos: Vector2

var shake_offset: Vector2 = Vector2.ZERO
var shake_trauma: float = 0.0
var shake_trauma_power: int = 2

var fade_color: Color

#region BUILT-IN CALLS
func _ready() -> void:
	randomize()

func _process(_delta: float) -> void:
	#position management
	if is_setup :
		if is_tweening_trans:
			tracked_pos = lerp(start_pos, current_target.global_position, position_alpha)
			position_alpha = clampf(inverse_lerp(0.0, position_alpha_target, t.get_total_elapsed_time() * 2), 0.0, 1.0)
		else: 
			tracked_pos = current_target.global_position
		
		if shake_trauma > 0:
			shake_trauma = max(shake_trauma - shake_decay * _delta, 0.0)
			screen_shake_manager()
			
		position = tracked_pos + shake_offset
#endregion

#region CAMERA TRANSITIONS
func cut_to_target(target: Global2DCameraTarget, set_main: bool = false):
	if target == current_target: return
	
	if t != null && t.is_running() : t.kill()
	
	if set_main : main_target = target
	current_target = target
	#base
	zoom = target.zoom
	offset = target.offset
	#limits
	limit_left = target.limits_left
	limit_top = target.limits_top
	limit_right = target.limits_right
	limit_bottom = target.limits_bottom
	limit_smoothed = target.smoothed_limits
	#smoothing
	position_smoothing_enabled = target.position_smoothing
	position_smoothing_speed = target.position_smoothing_speed
	rotation_smoothing_enabled = target.rotation_smoothing
	rotation_smoothing_speed = target.rotation_smoothing_speed
	#drag
	drag_horizontal_enabled = target.h_drag_enabled
	drag_vertical_enabled = target.v_drag_enabled
	drag_horizontal_offset = target.drag_h_offset
	drag_vertical_offset = target.drag_v_offset
	drag_left_margin = target.drag_left_margin
	drag_top_margin = target.drag_top_margin
	drag_right_margin = target.drag_right_margin
	drag_bottom_margin = target.drag_bottom_margin
	#reparent
	global_position = current_target.global_position
	reset_smoothing()

func tween_to_target(target: Global2DCameraTarget, type: Tween.TransitionType, time: float, set_main: bool = false):
	if target == current_target: return
	
	if set_main : main_target = target
	
	if is_tweening_trans:
		t.kill()
	position_alpha = 0.0
	position_alpha_target = time
	start_pos = global_position
	is_tweening_trans = true
	current_target = target
	
	position_smoothing_enabled = target.position_smoothing
	rotation_smoothing_enabled = target.rotation_smoothing
	limit_smoothed = target.smoothed_limits
	drag_horizontal_enabled = target.h_drag_enabled
	drag_vertical_enabled = target.v_drag_enabled
	
	t = create_tween().set_trans(type)
	t.set_parallel(true)
	#base
	t.tween_property(self, "zoom", target.zoom, time)
	t.tween_property(self, "offset", target.offset, time)
	#limits
	t.tween_property(self, "limit_left", target.limits_left, time)
	t.tween_property(self, "limit_right", target.limits_right, time)
	t.tween_property(self, "limit_top", target.limits_top, time)
	t.tween_property(self, "limit_bottom", target.limits_bottom, time)
	#smoothing
	t.tween_property(self, "position_smoothing_speed", target.position_smoothing_speed, time)
	t.tween_property(self, "rotation_smoothing_speed", target.rotation_smoothing_speed, time)
	#drag
	t.tween_property(self, "drag_horizontal_offset", target.drag_h_offset, time)
	t.tween_property(self, "drag_vertical_offset", target.drag_v_offset, time)
	t.tween_property(self, "drag_left_margin", target.drag_left_margin, time)
	t.tween_property(self, "drag_right_margin", target.drag_right_margin, time)
	t.tween_property(self, "drag_top_margin", target.drag_top_margin, time)
	t.tween_property(self, "drag_bottom_margin", target.drag_bottom_margin, time)
	await t.finished
	is_tweening_trans = false

func fade_to_target(target: Global2DCameraTarget, in_type: Tween.TransitionType, out_type: Tween.TransitionType, in_time: float, out_time: float, color: Color, set_main: bool = false):
	if target == current_target: return
	
	if t != null && t.is_running() : t.kill()
	
	if set_main : main_target = target
	
	if t != null:
		if t.is_running(): t.kill()
	
	t = create_tween().set_trans(in_type)
	fade_color = color
	t.tween_method(set_fade_alpha, 0.0, 1.0, in_time)
	await t.finished
	t.kill()
	cut_to_target(target, set_main)
	t = create_tween().set_trans(out_type)
	t.tween_method(set_fade_alpha, 1.0, 0.0, out_time)

func set_fade_alpha(alpha: float):
	fade_rect.color = Color(fade_color.r, fade_color.g, fade_color.b, alpha)
#endregion

#region CAMERA SHAKE
func screen_shake_manager():
	var amount = pow(shake_trauma, shake_trauma_power)
	rotation = shake_max_roll * amount * randf_range(-1, 1)
	shake_offset.x = shake_max_offset.x * amount * randf_range(-1, 1)
	shake_offset.y = shake_max_offset.y * amount * randf_range(-1, 1)

func add_screen_shake(trauma: float):
	shake_trauma = min(shake_trauma + trauma, 1.0)
#endregion
