extends CharacterBody2D
class_name Hero


enum JOB {
	CLERIC ## Supports allies.
	, MAGE ## Ranged magical attacks.
	, KNIGHT ## Melee tank.
	, ARCHER ## Ranged physical attacks.
}
enum ACTION {RETREAT, ATTACK, FORWARD, HEAL, REGROUP, STUNNED, CHANNEL}


@export var SPEED: float = 100.0
@export var job: JOB
@export var MAX_HP: int = 10


@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var kb_timer: Timer = $KBTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var hp_bar: TextureProgressBar = $HPBar
@onready var channel_bar: TextureProgressBar = $ChannelBar
@onready var projectiles: Node2D = $Projectiles
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D


var action: ACTION = ACTION.FORWARD


var curr_hp: int = MAX_HP:
	set(new_hp):
		curr_hp = new_hp
		if curr_hp <= 0:
			GlobalScript.heroes_slain += 1
			alive = false
			queue_free()
		hp_bar.value = curr_hp * 100.0 / MAX_HP
		
var alive: bool = true


var move_target: Vector2

var boss_in_range: Node


func _ready() -> void:
	curr_hp = MAX_HP


func _process(delta: float) -> void:
	move_to_boss()
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false


func _physics_process(delta: float) -> void:
	match action:
		ACTION.FORWARD:
			move_target = navigation_agent_2d.get_next_path_position()
			velocity = (move_target - position).normalized() * SPEED
	
	move_and_slide()


func move_to_boss() -> void:
	navigation_agent_2d.target_position = GlobalScript.get_boss_position()


func take_knockback(dir: Vector2, strength: float) -> void:
	action = ACTION.STUNNED
	velocity = dir.normalized() * strength
	kb_timer.start(0.1)


func take_hit(dmg: int) -> void:
	curr_hp -= dmg


func raycast_to_boss() -> bool:
	ray_cast_2d.target_position = GlobalScript.get_boss_position() - position
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		return true
	return false


func attack() -> void:
	if boss_in_range:
		pass


func _on_attack_range_body_entered(body: Node2D) -> void:
	boss_in_range = body


func _on_attack_range_body_exited(body: Node2D) -> void:
	boss_in_range = null


func _on_kb_timer_timeout() -> void:
	action = ACTION.FORWARD
