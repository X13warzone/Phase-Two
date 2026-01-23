extends Projectile


func _on_attack_range_body_entered(body: Node2D) -> void:
	# Using 0.9999 for now just to account for possible floating point errors.
	# Realistically, actual floating point errors will be much more minor, but
	# this is sufficient and shouldn't negaitvel affect gameplay at all.
	if body.get_hp_percent() < 0.9999:
		body.heal(damage)
		alive = false
		queue_free()
