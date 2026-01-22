extends CharacterBody2D


enum ACTION {WALK, MELEE, MAGIC, SUMMON, STUNNED}
var action: ACTION = ACTION.WALK


@onready var melee_combo_timer: Timer = $MeleeComboTimer
@onready var hp_bar: TextureProgressBar = $CanvasLayer/HPBar
@onready var attack_player: AnimationPlayer = $AttackHitbox/AttackPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var SPEED = 150.0

var MAX_HP: int = 100
var curr_hp: int = MAX_HP:
	set(new_hp):
		curr_hp = new_hp
		if curr_hp < 0:
			die()
		hp_bar.value = curr_hp * 100.0 / MAX_HP

var melee_combo_step: int = 0
var do_melee_next: bool = false

var melee_damage: int = 1
var magic_damage: int = 1


var level: int = 1
var xp: int = 0:
	set(new_xp):
		xp = new_xp
		if xp > (level - 1) * 2 + 1:
			level += 1
			xp -= (level - 2) * 2 + 1


func _process(delta: float) -> void:
	GlobalScript.set_boss_position(position)
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false

	$AttackHitbox.rotation = (position.angle_to_point(get_viewport().get_mouse_position()))

	do_melee_next = false
	if Input.is_action_pressed("attack"):
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


func take_hit(dmg: int) -> void:
	curr_hp -= dmg


func die() -> void:
	print("I died!")
