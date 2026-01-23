extends Node2D


@onready var timer: Timer = $Timer


const LIFE_TIME = 3
var curr_life_time: float = 0.0


var bodies_in_range: Array = []
var damage: float = 1


func _process(delta: float) -> void:
	curr_life_time += delta
	if curr_life_time >= LIFE_TIME:
		queue_free()
	elif timer.is_stopped():
		timer.start(0.25)
		for b in bodies_in_range:
			b.take_hit(damage, Entity.DMG_TYPE.MAG)


func _on_area_2d_body_entered(body: Node2D) -> void:
	bodies_in_range.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	bodies_in_range.erase(body)
