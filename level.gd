extends Node


@onready var fps_label: Label = $CanvasLayer/FPSLabel
@onready var score_1_label: Label = $CanvasLayer/Score1Label
@onready var hero_party: Node2D = $HeroParty
@onready var boss: CharacterBody2D = $Boss
@onready var wave_label: Label = $CanvasLayer/WaveLabel
@onready var pause_menu: Control = $CanvasLayer/PauseMenu


const HERO_MAGE = preload("res://hero/hero_mage.tscn")
const HERO_KNIGHT = preload("res://hero/hero_knight.tscn")
const HERO_ARCHER = preload("res://hero/hero_archer.tscn")
const HERO_CLERIC = preload("res://hero/hero_cleric.tscn")
""" FORMAT
wave_num: [num_knights, num_archers, num_mages, num_clerics]
"""
const WAVES = {
	1: [1, 0, 0, 0],
	2: [2, 1, 0, 0],
	3: [2, 2, 1, 0],
	4: [3, 2, 2, 1],
	5: [6, 3, 4, 3]
}
var wave: int = 0


func _ready() -> void:
	GlobalScript.heroes_slain_updated.connect(_update_score)
	GlobalScript.heroes_slain = 0



func _process(delta: float) -> void:
	fps_label.text = "FPS: %f" % Engine.get_frames_per_second()
	
	if Input.is_action_just_pressed("cancel"):
		get_tree().paused = !get_tree().paused
		pause_menu.visible = get_tree().paused
	
	if get_tree().get_node_count_in_group("Hero") <= 0:
		wave += 1
		GlobalScript.wave = wave
		spawn_wave()
		_update_score()


func _update_score() -> void:
	score_1_label.text = "WAVE %d\nFOOLISH HEROES VANQUISHED: %d" % [wave, GlobalScript.heroes_slain]


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
		c.MAX_HP *= (floori(1 + (wave / 3.0)) / 5.0) + 0.8
		c.phys_def += floori(wave / 4.0)
		c.mag_def += floori((wave - 1.0) / 4.0)
		c.melee_damage += (floori((wave - 5.0) / 2.0) + 1.0) / 5.0
		c.magic_damage += (floori((wave - 5.0) / 2.0) + 1.0) / 5.0


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
	for xp_orb in get_tree().get_nodes_in_group("xp_orb"):
		boss.get_xp(xp_orb.xp_gain)
		xp_orb.queue_free()
	boss.heal(boss.HP_REGEN)
	if WAVES.get(wave, 0):
		for hero in WAVES[wave][0]:
			spawn_unit("Knight", get_random_loc())
		for hero in WAVES[wave][1]:
			spawn_unit("Archer", get_random_loc())
		for hero in WAVES[wave][2]:
			spawn_unit("Mage", get_random_loc())
		for hero in WAVES[wave][3]:
			spawn_unit("Cleric", get_random_loc())
	else:
		var knights = ceili(wave)
		var archers = ceili(wave * 0.6)
		var mages = floori(wave * 0.6)
		var clerics = ceili(wave * 0.5)
	
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


func _on_pause_back_button_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false


func _on_pause_main_button_pressed() -> void:
	get_tree().paused = false
	SceneTransition.change_scene("res://menu/main_menu.tscn")
