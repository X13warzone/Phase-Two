extends CenterContainer


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	hide()
	SceneTransition.reload_scene()
