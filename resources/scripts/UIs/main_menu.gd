class_name MainMenu
extends CanvasLayer


func _on_btn_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/played_floor.tscn")

func _on_btn_options_pressed() -> void:
	HUD.display_options_menu(true)
