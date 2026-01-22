extends Hero


const MAGE_FIREBALL = preload("res://projectile/mage_fireball.tscn")


func _process(delta: float) -> void:
	super._process(delta)
	if attack_timer.is_stopped():
		if boss_in_range and action == ACTION.FORWARD and !raycast_to_boss():
			channel_bar.show()
			action = ACTION.CHANNEL
			attack_timer.start(2)
			velocity = Vector2.ZERO
		elif action == ACTION.CHANNEL:
			action = ACTION.FORWARD
			channel_bar.hide()
			attack()
	elif action == ACTION.CHANNEL:
		channel_bar.value = 100.0 - attack_timer.time_left * 50.0


func attack() -> void:
	var c = MAGE_FIREBALL.instantiate()
	c.position = position
	c.rotation = position.angle_to_point(GlobalScript.get_boss_position())
	projectiles.add_child(c)
