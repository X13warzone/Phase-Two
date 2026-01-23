extends Entity


enum ACTION {RETREAT, ATTACK, FORWARD, HEAL, REGROUP, STUNNED, CHANNEL}

@export var SPEED: float = 100.0


@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var attack_timer: Timer = $AttackTimer
@onready var hp_bar: TextureProgressBar = $HPBar
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var check_timer: Timer = $CheckTimer


var action: ACTION = ACTION.FORWARD

var alive: bool = true

var bodies_in_range = []
var move_target: Vector2

func _process(delta: float) -> void:
	curr_hp -= delta
	hp_bar.value = curr_hp * 100.0 / MAX_HP

	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false

	if check_timer.is_stopped():
		check_timer.start()
		var min_dist = -1
		var min_hero
		for h in get_tree().get_nodes_in_group("Hero"):
			if min_dist == -1 or position.distance_squared_to(h.position) < min_dist:
				min_dist = position.distance_squared_to(h.position)
				min_hero = h
		if min_dist != -1:
			navigation_agent_2d.target_position = min_hero.position

	if alive and attack_timer.is_stopped():
		if bodies_in_range.size() > 0:
			attack_timer.start(0.6)
			attack()


func _physics_process(delta: float) -> void:
	move_target = navigation_agent_2d.get_next_path_position()
	velocity = (move_target - position).normalized() * SPEED
	move_and_slide()


func take_hit(dmg: float, dmg_type: DMG_TYPE) -> void:
	super.take_hit(dmg, dmg_type)
	hp_bar.value = curr_hp * 100.0 / MAX_HP


func attack() -> void:
	bodies_in_range[0].take_hit(1.0, Entity.DMG_TYPE.PHYS)


func die() -> void:
	alive = false
	queue_free()


func _on_attack_range_body_entered(body: Node2D) -> void:
	bodies_in_range.append(body)


func _on_attack_range_body_exited(body: Node2D) -> void:
	bodies_in_range.erase(body)


func _on_kb_timer_timeout() -> void:
	action = ACTION.FORWARD
