extends Node2D


var xp_gain: int = 1


func _ready() -> void:
	if GlobalScript.play_death_sound:
		GlobalScript.play_death_sound = false
		$DeathSound.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.get_xp(xp_gain)
	queue_free()
