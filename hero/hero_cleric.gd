extends Hero


const HEAL_ORB = preload("res://projectile/heal_orb.tscn")


var heroes_in_range = []


func _process(delta: float) -> void:
	super._process(delta)
	if attack_timer.is_stopped():
		if heroes_in_range.size() > 0 and action == ACTION.FORWARD and !raycast_to_boss():
			var h = get_close_lowest_hp_hero()
			if h:
				channel_bar.show()
				action = ACTION.CHANNEL
				attack_timer.start(0.2)
				velocity = Vector2.ZERO
		elif action == ACTION.CHANNEL:
			action = ACTION.FORWARD
			channel_bar.hide()
			attack()
			attack_timer.start(0.8) ## This sets a 0.8 delay between each heal, but I want each heal to come out quickly before the hero targeted dies (it's fine if that happens, but it just makes more sense this way
	elif action == ACTION.CHANNEL:
		channel_bar.value = (0.5 - attack_timer.time_left) * 100.0 / 0.5


func _physics_process(delta: float) -> void:
	if action == ACTION.FORWARD and position.distance_squared_to(GlobalScript.get_boss_position()) > 13500:
		move_target = navigation_agent_2d.get_next_path_position()
		velocity = (move_target - position).normalized() * SPEED
	
	move_and_slide()


func get_close_lowest_hp_hero() -> Node:
	var lowest_hp = 1
	var lowest_hero = null
	for b in heroes_in_range:
		if b.get_hp_percent() < lowest_hp:
			lowest_hp = b.get_hp_percent()
			lowest_hero = b
	return lowest_hero


func attack() -> void:
	var h = get_close_lowest_hp_hero()
	if h:
		var c = HEAL_ORB.instantiate()
		c.position = position
		c.rotation = position.angle_to_point(h.position)
		projectiles.add_child(c)
		c.true_parent = self


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body != self:
		heroes_in_range.append(body)


func _on_attack_range_body_exited(body: Node2D) -> void:
	heroes_in_range.erase(body)
