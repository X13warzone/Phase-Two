extends Node


@onready var fps_label: Label = $CanvasLayer/FPSLabel
@onready var score_1_label: Label = $CanvasLayer/Score1Label
@onready var hero_party: Node2D = $HeroParty
@onready var boss: CharacterBody2D = $Boss


const HERO_MAGE = preload("res://hero/hero_mage.tscn")
const HERO_KNIGHT = preload("res://hero/hero_knight.tscn")
""" FORMAT
wave_num: [num_knights, num_archers, num_mages, num_clerics]
"""
const WAVES = {
	1: [1, 0, 0, 0],
	2: [2, 0, 1, 0],
	3: [2, 0, 4, 0],
	4: [4, 0, 3, 0],
	5: [10, 0, 4, 0]
}
var wave: int = 0


var heroes_alive: int = -1:
	set(new_ha):
		heroes_alive = new_ha
		if new_ha <= 0:
			wave += 1
			spawn_wave()


func _ready() -> void:
	GlobalScript.heroes_slain_updated.connect(_update_score)
	heroes_alive = 0


func _process(delta: float) -> void:
	fps_label.text = "FPS: %f" % Engine.get_frames_per_second()


func _update_score(heroes_slain) -> void:
	score_1_label.text = "FOOLISH HEROES VANQUISHED: %d" % heroes_slain

	heroes_alive -= 1


func spawn_unit(unit_name: String, location: Vector2) -> void:
	match unit_name:
		"Knight":
			var c = HERO_KNIGHT.instantiate()
			c.position = location
			hero_party.add_child(c)
		"Mage":
			var c = HERO_MAGE.instantiate()
			c.position = location
			hero_party.add_child(c)


func get_random_loc() -> Vector2:
	var loc = Vector2.ZERO
	if randf() <= 0.5:
		loc.y = randi_range(230, 310)
		if randf() <= 0.5:
			loc.x = -40
		else:
			loc.x = 1192
	else:
		loc.x = randi_range(530, 622)
		if randf() <= 0.5:
			loc.y = -40
		else:
			loc.y = 680
	return loc


func spawn_wave() -> void:
	boss.curr_hp += boss.HP_REGEN
	if WAVES.get(wave, 0):
		heroes_alive = WAVES[wave][0] + WAVES[wave][1] + WAVES[wave][2] + WAVES[wave][3]
		for hero in WAVES[wave][0]:
			spawn_unit("Knight", get_random_loc())
		for hero in WAVES[wave][2]:
			spawn_unit("Mage", get_random_loc())
	else:
		var knights = randi_range(wave, wave * 2)
		var mages = randi_range(wave, ceili(wave * 1.5))
		heroes_alive = knights + mages
		
		for hero in knights:
			spawn_unit("Knight", get_random_loc())
