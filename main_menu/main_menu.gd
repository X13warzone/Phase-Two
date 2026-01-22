extends Node


@onready var menu_buttons: CenterContainer = $MenuButtons
@onready var options_menu: Control = $OptionsMenu
@onready var credits_menu: Control = $CreditsMenu


func _ready() -> void:
	menu_buttons.show()
	options_menu.hide()
	credits_menu.hide()


func _on_start_button_pressed() -> void:
	SceneTransition.change_scene("res://level.tscn")


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_credits_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_options_back_button_pressed() -> void:
	pass # Replace with function body.
