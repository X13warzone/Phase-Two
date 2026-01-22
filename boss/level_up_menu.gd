extends Control


@onready var button: Button = $CenterContainer/HBoxContainer/Button
@onready var button_2: Button = $CenterContainer/HBoxContainer/Button2
@onready var button_3: Button = $CenterContainer/HBoxContainer/Button3


"""
Upgrade types:
Max HP
HP regen (heal at end of each wave)
Physical defense
Magical defense
Physical damage
Magical damage
Unlock skill

Unlockable skills:
Ranged magic pool
Summon skeletons

"""


func set_options(string1: String, string2: String, string3: String) -> void:
	button.text = string1
	button_2.text = string2
	button_3.text = string3


func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	pass # Replace with function body.
