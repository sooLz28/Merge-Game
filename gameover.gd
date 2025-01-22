extends CanvasLayer


func _on_retry_button_up() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()



func _on_quit_button_up() -> void:
	get_tree().quit(0)
