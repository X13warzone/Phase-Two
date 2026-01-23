extends Node


@onready var fps_label: Label = $CanvasLayer/FPSLabel
@onready var score_1_label: Label = $CanvasLayer/Score1Label
@onready var hero_party: Node2D = $HeroParty
@onready var boss: CharacterBody2D = $Boss
@onready var wave_label: Label = $CanvasLayer/WaveLabel


const HERO_MAGE = preload("res://hero/hero_mage.tscn")
const HERO_KNIGHT = preload("res://hero/hero_knight.tscn")
const HERO_ARCHER = preload("res://hero/hero_archer.tscn")
const HERO_CLERIC = preload("res://hero/hero_cleric.tscn")
""" FORMAT
wave_num: [num_knights, num_archers, num_mages, num_clerics]
"""
const WAVES = {
	1: [1, 0, 0, 1],
	2: [2, 1, 0, 0],
	3: [2, 2, 1, 0],
	4: [3, 2, 2, 1],
	5: [6, 3, 4, 3]
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
	var c
	match unit_name:
		"Knight":
			c = HERO_KNIGHT.instantiate()
		"Mage":
			c = HERO_MAGE.instantiate()
		"Archer":
			c = HERO_ARCHER.instantiate()
		"Cleric":
			c = HERO_CLERIC.instantiate()
	if c:
		c.position = location
		hero_party.add_child(c)


func get_random_loc() -> Vector2:
	var loc = Vector2.ZERO
	if randf() <= 0.5:
		loc.y = randi_range(250, 370)
		if randf() <= 0.5:
			loc.x = randi_range(-100, -50)
		else:
			loc.x = randi_range(1170, 1220)
	else:
		loc.x = randi_range(500, 620)
		if randf() <= 0.5:
			loc.y = randi_range(-80, -30)
		else:
			loc.y = randi_range(670, 720)
	return loc


func spawn_wave() -> void:
	boss.curr_hp += boss.HP_REGEN
	if WAVES.get(wave, 0):
		heroes_alive = WAVES[wave][0] + WAVES[wave][1] + WAVES[wave][2] + WAVES[wave][3]
		for hero in WAVES[wave][0]:
			spawn_unit("Knight", get_random_loc())
		for hero in WAVES[wave][1]:
			spawn_unit("Archer", get_random_loc())
		for hero in WAVES[wave][2]:
			spawn_unit("Mage", get_random_loc())
		for hero in WAVES[wave][3]:
			spawn_unit("Cleric", get_random_loc())
	else:
		var knights = randi_range(wave, wave * 2)
		var archers = randi_range(wave, floori(wave * 1.5))
		var mages = randi_range(wave, ceili(wave * 1.5))
		var clerics = randi_range(floori(wave * 0.8), ceili(wave * 1.5))
		heroes_alive = knights + archers + mages + clerics
		
		for hero in knights:
			spawn_unit("Knight", get_random_loc())
		for hero in archers:
			spawn_unit("Archer", get_random_loc())
		for hero in mages:
			spawn_unit("Mage", get_random_loc())
		for hero in clerics:
			spawn_unit("Cleric", get_random_loc())


func _on_bg_music_finished() -> void:
	$BGMusic.play()
