@tool
class_name Global2DCamTargetGizmos
extends Node2D

@export var target: Global2DCameraTarget

func _draw() -> void:
	if Engine.is_editor_hint():
		if target != null:
			global_position = target.global_position
			position = target.offset
			
			#screen sizing
			var scr  = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
			scr.x *= (1/target.zoom.x)
			scr.y *= (1/target.zoom.y)
			var t_r_point = Vector2(scr.x * 0.5, -scr.y * 0.5)
			var t_l_point = Vector2(-scr.x * 0.5, -scr.y * 0.5)
			var b_r_point = Vector2(scr.x * 0.5, scr.y * 0.5)
			var b_l_point = Vector2(-scr.x * 0.5, scr.y * 0.5)
			draw_line(t_r_point, b_r_point, Color.NAVY_BLUE)
			draw_line(b_r_point, b_l_point, Color.NAVY_BLUE)
			draw_line(b_l_point, t_l_point, Color.NAVY_BLUE)
			draw_line(t_l_point, t_r_point, Color.NAVY_BLUE)
			
			
			#drag display
			
			var d_t_r_point = Vector2(t_r_point.x * target.drag_right_margin, t_r_point.y * target.drag_top_margin)
			var d_b_r_point = Vector2(b_r_point.x * target.drag_right_margin, b_r_point.y * target.drag_bottom_margin)
			var d_t_l_point = Vector2(t_l_point.x * target.drag_left_margin, t_l_point.y * target.drag_top_margin)
			var d_b_l_point = Vector2(b_l_point.x * target.drag_left_margin, b_l_point.y * target.drag_bottom_margin)
			
			if target.h_drag_enabled:
				draw_line(d_t_r_point, d_b_r_point, Color.DARK_SALMON)
				draw_line(d_b_l_point, d_t_l_point, Color.DARK_SALMON)
				
			if target.v_drag_enabled:
				draw_line(d_b_r_point, d_b_l_point, Color.DARK_SALMON)
				draw_line(d_t_l_point, d_t_r_point, Color.DARK_SALMON)
