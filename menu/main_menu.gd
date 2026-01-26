extends Node


@onready var menu_buttons: CenterContainer = $MenuButtons
@onready var credits_menu: Control = $CreditsMenu
@onready var options_menu: CenterContainer = $OptionsMenu
@onready var leaderboard_menu: Control = $LeaderboardMenu


func _ready() -> void:
	menu_buttons.show()
	options_menu.hide()
	credits_menu.hide()


func _on_start_button_pressed() -> void:
	SceneTransition.change_scene("res://level.tscn")


func _on_options_button_pressed() -> void:
	menu_buttons.hide()
	options_menu.show()


func _on_credits_button_pressed() -> void:
	credits_menu.show()
	menu_buttons.hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_options_back_button_pressed() -> void:
	options_menu.hide()
	menu_buttons.show()


func _on_bg_music_finished() -> void:
	$BGMusic.play()


func _on_credits_back_button_pressed() -> void:
	credits_menu.hide()
	menu_buttons.show()


func _on_leaderboard_button_pressed() -> void:
	leaderboard_menu.show()
	menu_buttons.hide()


func _on_leaderboard_back_button_pressed() -> void:
	leaderboard_menu.hide()
	menu_buttons.show()
