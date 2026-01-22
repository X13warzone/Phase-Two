extends CharacterBody2D
class_name Entity


enum DMG_TYPE {PHYS, MAG}


@export var MAX_HP: float = 10.0
var curr_hp: float = MAX_HP:
	set(new_hp):
		curr_hp = new_hp
		if curr_hp <= 0:
			die()
		if curr_hp > MAX_HP:
			curr_hp = MAX_HP


var phys_def: int
var mag_def: int

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


func die() -> void:
	pass
