extends Node

signal heroes_slain_updated

var boss_position: Vector2

var heroes_slain: int = 0:
	set(new_hs):
		heroes_slain = new_hs
		emit_signal("heroes_slain_updated")

var play_death_sound: bool = true:
	set(new_bool):
		play_death_sound = false
		await get_tree().create_timer(0.1).timeout
		play_death_sound = true

var wave: int = 0


func set_boss_position(new_position: Vector2) -> void:
	boss_position = new_position


func get_boss_position() -> Vector2:
	return boss_position
