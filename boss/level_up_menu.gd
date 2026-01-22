extends Control

signal level_up_option_selected(option_num: int)


@onready var button_1: Button = $CenterContainer/HBoxContainer/Button
@onready var button_2: Button = $CenterContainer/HBoxContainer/Button2
@onready var button_3: Button = $CenterContainer/HBoxContainer/Button3


var options_set: int = 0
"""
Upgrade types:
MAXHP - Max HP
REGEN - HP regen (heal at end of each wave)
PYDEF - Physical defense
MGDEF - Magical defense
PYDMG - Physical damage
MGDMG - Magical damage
Unlock skill

Unlockable skills:
RMGP - Ranged magic pool (lvl 4)
SMNS - Summon skeletons (lvl 7)

"""


func set_option(string: String) -> void:
	match options_set:
		0:
			button_1.text = string
		1:
			button_2.text = string
		2:
			button_3.text = string
	options_set += 1


func _on_button_pressed() -> void:
	options_set = 0
	get_tree().paused = false
	emit_signal("level_up_option_selected", 0)


func _on_button_2_pressed() -> void:
	options_set = 0
	get_tree().paused = false
	emit_signal("level_up_option_selected", 1)


func _on_button_3_pressed() -> void:
	options_set = 0
	get_tree().paused = false
	emit_signal("level_up_option_selected", 2)
