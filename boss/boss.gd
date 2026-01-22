extends Entity


enum ACTION {WALK, MELEE, MAGIC, SUMMON, STUNNED}
var action: ACTION = ACTION.WALK


@onready var melee_combo_timer: Timer = $MeleeComboTimer
@onready var hp_bar: TextureProgressBar = $CanvasLayer/HPBar
@onready var attack_player: AnimationPlayer = $AttackHitbox/AttackPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var level_up_menu: Control = $CanvasLayer/LevelUpMenu
@onready var stat_label: Label = $CanvasLayer/StatDisplay/Label


var SPEED = 150.0

var HP_REGEN: int = 0

var melee_damage: int = 1
var magic_damage: int = 1

var melee_combo_step: int = 0
var do_melee_next: bool = false


var level: int = 1
var xp: int = 0:
	set(new_xp):
		xp = new_xp
		if xp >= (level - 1) * 2 + 1:
			level += 1
			xp -= (level - 2) * 2 + 1
			level_up()

var upgrade_options = []


var unlock_magic_pool: bool = false
var unlock_summon_skeleton: bool = false


func _process(delta: float) -> void:
	GlobalScript.set_boss_position(position)
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false

	$AttackHitbox.rotation = (position.angle_to_point(get_viewport().get_mouse_position()))

	do_melee_next = false
	if Input.is_action_pressed("skill_1"):
		pass
	elif Input.is_action_pressed("attack"):
		if melee_combo_timer.is_stopped():
			attack_melee_sweep(1)
			melee_combo_step = 0
			melee_combo_timer.start(2.0)
		elif melee_combo_timer.time_left <= 1.6 and Input.is_action_just_pressed("attack"):
			do_melee_next = true
		elif melee_combo_timer.time_left <= 1.2:
			do_melee_next = true
	if do_melee_next:
		do_melee_attack()


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction.normalized() * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()


func do_melee_attack() -> void:
	if melee_combo_step == 0:
		attack_melee_sweep(1)
		melee_combo_step = 1
	elif melee_combo_step == 1:
		attack_melee_sweep(2)
		melee_combo_step = 2
	elif melee_combo_step == 2:
		attack_melee_stab()
		melee_combo_step = 0
	melee_combo_timer.start(2)


func attack_melee_stab() -> void:
	attack_player.play("melee_stab")
	for b in $AttackHitbox/MeleeStab.get_overlapping_bodies():
		if b.alive:
			b.take_hit(melee_damage * 2)


func attack_melee_sweep(frameset: int = 1) -> void:
	attack_player.play("melee_sweep%d" % frameset)
	for b in $AttackHitbox/MeleeSweep.get_overlapping_bodies():
		if b.alive:
			b.take_knockback(b.position - position, 70)
			b.take_hit(melee_damage)


func ranged_grasp_pool() -> void:
	pass


func summon_skeletons() -> void:
	pass


func take_hit(dmg: float, dmg_type: DMG_TYPE) -> void:
	super.take_hit(dmg, dmg_type)
	hp_bar.value = curr_hp * 100.0 / MAX_HP


func die() -> void:
	print("I died!")

"""
MAXHP - Max HP
REGEN - HP regen
PYDEF - Physical defense
MGDEF - Magical defense
PYDMG - Physical damage
MGDMG - Magical damage
Unlock skill

Unlockable skills:
RMGP - Ranged magic pool
SMNS - Summon skeletons"""
func level_up() -> void:
	"""
	Select a random option from 1-6
	Select a different option
	Select a different option from both prior options
	"""
	var all_options
	var temp_options
	var selected_option
	var selected_index
	upgrade_options.clear()
	if level < 4:
		all_options = [
			["MAXHP", [5, 10]],
			["REGEN", [1, 2]],
			["PYDEF", [1, 2]],
			["PYDMG", [1, 2]]
		]
	elif level == 4:
		all_options = [
			["RMGP", [0,0]],
			["RMGP", [0,0]],
			["RMGP", [0,0]]
		]
	elif level == 6:
		all_options = [
			["SMNS", [0, 0]],
			["SMNS", [0, 0]],
			["SMNS", [0, 0]]
		]
	else:
		all_options = [
			["MAXHP", [5, 10]],
			["REGEN", [1, 2]],
			["PYDEF", [1, 2]],
			["MGDEF", [1, 2]],
			["PYDMG", [1, 2]],
			["MGDMG", [1, 2]]
		]

	temp_options = all_options
	for i in range(3):
		selected_index =  randi_range(0, temp_options.size() - 1)
		selected_option = temp_options[selected_index]
		upgrade_options.append([selected_option[0], randi_range(selected_option[1][0], selected_option[1][1])])
		temp_options.remove_at(selected_index)
		level_up_menu.set_option(get_upgrade_text(upgrade_options[i][0], upgrade_options[i][1]))

	level_up_menu.show()
	get_tree().paused = true


func get_upgrade_text(upgrade_code: String, upgrade_value: int) -> String:
	var res = ""
	match upgrade_code:
		"MAXHP":
			res = "(BULK UP)\n\nINCREASE YOUR MAX HP"
		"REGEN":
			res = "(EAT A SNACK)\n\nINCREASE HP REGEN AT END OF EACH WAVE"
		"PYDEF":
			res = "(GO SHOPPING)\n\nINCREASE PHYSICAL DEFENSE"
		"MGDEF":
			res = "(TRAIN WITH MONKS)\n\nINCREASE MAGICAL DEFENSE"
		"PYDMG":
			res = "(SHARPEN MACE)\n\nINCREASE PHYSICAL DAMAGE"
		"MGDMG":
			res = "(READ A BOOK)\n\nINCREASE MAGICAL DAMAGE"
		"RMGP":
			res = "(REMEMBER SOME MAGIC)\n\nUNLOCK RANGED MAGIC ATTACK (Q)"
		"SMNS":
			res = "(GET YOUR FRIENDS)\n\nUNLOCK SUMMONING SKELETONS (E)"
	return res


func _on_level_up_menu_level_up_option_selected(option_num: int) -> void:
	level_up_menu.hide()
	var upgrade_code = upgrade_options[option_num][0]
	var upgrade_value = upgrade_options[option_num][1]
	
	match upgrade_code:
		"MAXHP":
			MAX_HP += upgrade_value
		"REGEN":
			HP_REGEN += upgrade_value
		"PYDEF":
			phys_def += upgrade_value
		"MGDEF":
			mag_def += upgrade_value
		"PYDMG":
			melee_damage += upgrade_value
		"MGDMG":
			magic_damage += upgrade_value
		"RMGP":
			unlock_magic_pool = true
		"SMNS":
			unlock_summon_skeleton = true
	stat_label.text = "
LVL: %d
XP: %d
MAX HP: %f
REGEN: %f
PHYS DEF: %d
MAG DEF: %d
PHYS DMG: %d
MAG DMG: %d
SKILL 1: %s
SKILL 2: %s" % [level, xp, MAX_HP, HP_REGEN, phys_def, mag_def, melee_damage, magic_damage, unlock_magic_pool, unlock_summon_skeleton]


func get_xp(xp_gain: int) -> void:
	xp += xp_gain
