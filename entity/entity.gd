extends CharacterBody2D
class_name Entity


enum DMG_TYPE {PHYS, MAG}


@export var MAX_HP: float = 10.0:
	set(new_max_hp):
		if new_max_hp < MAX_HP:
			MAX_HP = new_max_hp
			if curr_hp > MAX_HP:
				curr_hp = MAX_HP
		else:
			var max_hp_change = new_max_hp - MAX_HP
			MAX_HP = new_max_hp
			curr_hp += max_hp_change
var curr_hp: float = MAX_HP:
	set(new_hp):
		curr_hp = new_hp
		if curr_hp <= 0:
			die()
		if curr_hp > MAX_HP:
			curr_hp = MAX_HP


var phys_def: int = 0
var mag_def: int = 0

var melee_damage: int = 1
var magic_damage: int = 1


func _ready() -> void:
	curr_hp = MAX_HP


func take_hit(dmg: float, dmg_type: DMG_TYPE) -> void:
	match dmg_type:
		DMG_TYPE.PHYS:
			curr_hp -= dmg * (1.0 / (1.0 + (phys_def / 10.0)))
		DMG_TYPE.MAG:
			curr_hp -= dmg * (1.0 / (1.0 + (mag_def / 10.0)))


func heal(life_gained: float) -> void:
	curr_hp += life_gained


func get_hp_percent() -> float:
	return curr_hp / MAX_HP


func die() -> void:
	pass
