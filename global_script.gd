extends Node

signal heroes_slain_updated(number)

var boss_position: Vector2
var heroes_slain: int = 0:
	set(new_hs):
		heroes_slain = new_hs
		emit_signal("heroes_slain_updated", heroes_slain)


func set_boss_position(new_position: Vector2) -> void:
	boss_position = new_position


func get_boss_position() -> Vector2:
	return boss_position


func _input(event: InputEvent) -> void:
	pass
