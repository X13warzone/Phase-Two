extends Entity


enum ACTION {WALK, MELEE, MAGIC, SUMMON, STUNNED}
var action: ACTION = ACTION.WALK


@onready var summon_skeleton_timer: Timer = $SummonSkeletonTimer
@onready var melee_combo_timer: Timer = $MeleeComboTimer
@onready var magic_pool_timer: Timer = $MagicPoolTimer
@onready var attack_player: AnimationPlayer = $AttackHitbox/AttackPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var level_up_menu: Control = $CanvasLayer/LevelUpMenu
@onready var stat_label: Label = $CanvasLayer/StatDisplay/Label
@onready var mace_sweep_sfx: AudioStreamPlayer = $AttackHitbox/MaceSweepSFX
@onready var mace_hit_sfx: AudioStreamPlayer = $AttackHitbox/MaceHitSFX
@onready var death_menu: CenterContainer = $CanvasLayer/DeathMenu
@onready var wall_checker: RayCast2D = $WallChecker
@onready var hit_if_timer: Timer = $HitIFTimer
@onready var mace_stab_sfx: AudioStreamPlayer = $AttackHitbox/MaceStabSFX
@onready var hp_bar: TextureProgressBar = $CanvasLayer/HPBar
@onready var xp_bar: TextureProgressBar = $CanvasLayer/HPBar/XPBar
@onready var skill_cooldown_display: Control = $CanvasLayer/SkillCooldownDisplay
@onready var poison_prog: TextureProgressBar = $CanvasLayer/SkillCooldownDisplay/CenterContainer/HBoxContainer/MarginContainer2/PoisonProg
@onready var skeleton_prog: TextureProgressBar = $CanvasLayer/SkillCooldownDisplay/CenterContainer/HBoxContainer/MarginContainer3/SkeletonProg


const MAGIC_POOL = preload("res://projectile/magic_pool.tscn")
const SKELETON_MINION = preload("res://entity/skeleton_minion.tscn")


var alive: bool = true

var SPEED = 150.0

var HP_REGEN: int = 0

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
var summon_skeleton_count: int = 2  ## This will be upticked once everytime SMNS is called. Default is 3, so we start at 2 since it'll be upticked when unlocked
var skill_coolddown: int = 0:
	set(new_cd):
		skill_coolddown = new_cd
		poison_prog.max_value = 7.0 * (100.0 / (100.0 + skill_coolddown))
		skeleton_prog.max_value = 15.0 * (100.0 / (100.0 + skill_coolddown))


func _process(delta: float) -> void:
	GlobalScript.set_boss_position(position)
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false

	$AttackHitbox.rotation = (position.angle_to_point(get_viewport().get_mouse_position()))

	do_melee_next = false
	if Input.is_action_pressed("skill_2") and unlock_summon_skeleton:
		if summon_skeleton_timer.is_stopped():
			summon_skeleton_timer.start(15.0 * (100.0 / (100.0 + skill_coolddown)))
			summon_skeletons()
	elif Input.is_action_pressed("skill_1") and unlock_magic_pool:
		if magic_pool_timer.is_stopped():
			magic_pool_timer.start(7.0 * (100.0 / (100.0 + skill_coolddown)))
			attack_magic_pool()
	elif Input.is_action_pressed("attack"):
		if melee_combo_timer.is_stopped():
			melee_combo_step = 0
			do_melee_attack()
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
	var enemies_hit = 0
	attack_player.play("melee_stab")
	mace_stab_sfx.play()
	for b in $AttackHitbox/MeleeStab.get_overlapping_bodies():
		if b.alive:
			enemies_hit += 1
			b.take_knockback(b.position - position, 0)
			b.take_hit(melee_damage * 2, DMG_TYPE.PHYS)
	if enemies_hit:
		mace_hit_sfx.play()


func attack_melee_sweep(frameset: int = 1) -> void:
	var enemies_hit = 0
	match frameset:
		1:
			attack_player.play("melee_sweep1")
		2:
			attack_player.play_backwards("melee_sweep1")
	$AttackHitbox/MeleeSweep.monitorable = true
	mace_sweep_sfx.play()
	for b in $AttackHitbox/MeleeSweep.get_overlapping_bodies():
		if b.has_method("take_hit"):
			enemies_hit += 1
			b.take_knockback(b.position - position, 70)
			b.take_hit(melee_damage, DMG_TYPE.PHYS)
	for b in $AttackHitbox/MeleeSweep.get_overlapping_areas():
		if b.get_parent().is_in_group("ProjDestructible"):
			print("new swat")
			b.get_parent().queue_free()
	if enemies_hit:
		mace_hit_sfx.play()


func attack_magic_pool() -> void:
	var c = MAGIC_POOL.instantiate()
	add_child(c)
	c.damage *= magic_damage
	c.position = get_viewport().get_mouse_position()


func summon_skeletons() -> void:
	var summon_pos: Vector2
	var c
	for sp in range(summon_skeleton_count):
		summon_pos = Vector2(0, -50).rotated(deg_to_rad(sp * 360.0 / summon_skeleton_count))
		wall_checker.target_position = summon_pos
		wall_checker.force_raycast_update()
		if wall_checker.is_colliding():
			summon_pos = summon_pos.normalized() * (position.distance_to(wall_checker.get_collision_point()) - 20.0)
		c = SKELETON_MINION.instantiate()
		$Summons.add_child(c)
		c.position = summon_pos + position
		c.MAX_HP *= MAX_HP / 50.0  ## Scales 2x with our max hp
		c.melee_damage *= melee_damage * 0.5  ## Scales 0.5x with our phys dmg


func take_hit(dmg: float, dmg_type: DMG_TYPE) -> void:
	if hit_if_timer.is_stopped():
		hit_if_timer.start(0.2)
		super.take_hit(dmg, dmg_type)
		hp_bar.value = curr_hp * 100.0 / MAX_HP


func die() -> void:
	if alive:
		alive = false
		death_menu.show()
		get_tree().paused = true

"""
MAXHP - Max HP
REGEN - HP regen
PYDEF - Physical defense
MGDEF - Magical defense
PYDMG - Physical damage
MGDMG - Magical damage
SKLCD - Skill cooldowns
SMNS - Summon 1 additional skeleton
MSPED - Movement speed

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
			["MAXHP", [5, 5]],
			["REGEN", [1, 1]],
			["PYDEF", [1, 2]],
			["PYDMG", [1, 1]],
			["MSPED", [5, 10]]
		]
	elif level == 4:
		all_options = [
			["RMGP", [0,0]],
			["RMGP", [0,0]],
			["RMGP", [0,0]]
		]
	elif level < 7:
		all_options = [
			["MAXHP", [6, 8]],
			["REGEN", [1, 1]],
			["PYDEF", [1, 3]],
			["MGDEF", [1, 3]],
			["PYDMG", [1, 2]],
			["MGDMG", [1, 2]],
			["SKLCD", [1, 5]],
			["MSPED", [7, 12]]
		]
	elif level == 7:
		all_options = [
			["SMNS", [0, 0]],
			["SMNS", [0, 0]],
			["SMNS", [0, 0]]
		]
	else:
		all_options = [
			["MAXHP", [8, 12]],
			["REGEN", [2, 5]],
			["PYDEF", [2, 5]],
			["MGDEF", [2, 5]],
			["PYDMG", [1, 2]],
			["MGDMG", [1, 2]],
			["SKLCD", [3, 9]],
			["SMNS", [0, 0]],
			["MSPED", [10, 15]]
		]

	temp_options = all_options
	for i in range(3):
		selected_index =  randi_range(0, temp_options.size() - 1)
		selected_option = temp_options[selected_index]
		upgrade_options.append([selected_option[0], randi_range(selected_option[1][0], selected_option[1][1])])
		temp_options.remove_at(selected_index)
		level_up_menu.set_option(get_upgrade_text(upgrade_options[i][0], upgrade_options[i][1]))

	$CanvasLayer/LevelUpMenu/LevelUp.play()
	$LevelUpSprite.play("default")
	await $LevelUpSprite.animation_finished

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
			if unlock_summon_skeleton:
				res = "(THE MORE THE MERRIER)\n\nSUMMON AN ADDITIONAL SKELETON"
			else:
				res = "(CALL THE GANG)\n\nUNLOCK SUMMONING SKELETONS (E)"
		"SKLCD":
			res = "(CHUG ENERGY DRINK)\n\nREDUCE SKILL COOLDOWNS"
		"MSPED":
			res = "(WALK 500 MILES)\n\nINCREASE MOVEMENT SPEED"
	return res


func _on_level_up_menu_level_up_option_selected(option_num: int) -> void:
	level_up_menu.hide()
	var upgrade_code = upgrade_options[option_num][0]
	var upgrade_value = upgrade_options[option_num][1]
	
	match upgrade_code:
		"MAXHP":
			MAX_HP += upgrade_value
			curr_hp += upgrade_value
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
			skill_cooldown_display.magic_poison_unlocked = true
		"SMNS":
			unlock_summon_skeleton = true
			summon_skeleton_count += 1
			skill_cooldown_display.summon_skeleton_unlocked = true
		"SKCLD":
			skill_coolddown += upgrade_value
		"MSPED":
			SPEED += upgrade_value
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
	xp_bar.value = xp * 100.0 / ((level - 1) * 2 + 1)


func heal(life_gained: float) -> void:
	super.heal(life_gained)
	hp_bar.value = curr_hp * 100.0 / MAX_HP
