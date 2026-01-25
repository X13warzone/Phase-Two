extends Projectile


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.has_method("take_hit"):
		alive = false
		body.take_hit(damage, Entity.DMG_TYPE.PHYS)
		queue_free()


func _on_hitbox_check_area_entered(area: Area2D) -> void:
	print("swat")
	alive = false
	queue_free()
