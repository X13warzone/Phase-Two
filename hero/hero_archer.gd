extends Hero

const ARCHER_ARROW = preload("res://projectile/archer_arrow.tscn")


func _process(delta: float) -> void:
	super._process(delta)
	if attack_timer.is_stopped():
		if boss_in_range and action == ACTION.FORWARD and !raycast_to_boss():
			channel_bar.show()
			action = ACTION.CHANNEL
			attack_timer.start(1)
			velocity = Vector2.ZERO
		elif action == ACTION.CHANNEL:
			action = ACTION.FORWARD
			channel_bar.hide()
			attack()
	elif action == ACTION.CHANNEL:
		channel_bar.value = (0.5 - attack_timer.time_left) * 100.0 / 0.5


func attack() -> void:
	var c = ARCHER_ARROW.instantiate()
	c.position = position
	c.rotation = position.angle_to_point(GlobalScript.get_boss_position())
	projectiles.add_child(c)
	c.damage *= melee_damage


func take_knockback(dir: Vector2, strength: float) -> void:
	super.take_knockback(dir, strength)
	attack_timer.stop()
