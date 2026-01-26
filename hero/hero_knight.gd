extends Hero


func _process(delta: float) -> void:
	super._process(delta)
	
	if action == ACTION.FORWARD:
		if boss_in_range and attack_timer.is_stopped():
			action = ACTION.ATTACK
			attack_timer.start(1)
	elif action == ACTION.ATTACK:
		if attack_timer.is_stopped():
			attack()
			action = ACTION.FORWARD
		if !boss_in_range:
			action = ACTION.FORWARD


func attack() -> void:
	if boss_in_range and !raycast_to_boss():
		boss_in_range.take_hit(2.0, DMG_TYPE.PHYS)
