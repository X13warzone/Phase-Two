extends Node2D


func _ready() -> void:
	$DeathSound.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.get_xp(1)
	queue_free()
