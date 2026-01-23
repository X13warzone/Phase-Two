extends CharacterBody2D
class_name Projectile

## How fast the projectile travels
@export var speed: float
## How long the projectile lasts, in seconds
@export var life_time: float = 10.0
@export var damage: int = 1


var current_life: float = 0
var alive: bool = false


func _ready() -> void:
	velocity = Vector2(speed, 0).rotated(rotation)


func _process(delta: float) -> void:
	current_life += delta
	if current_life >= life_time:
		alive = false
		queue_free()


func _physics_process(delta: float) -> void:
	move_and_slide()


func _on_attack_range_body_entered(body: Node2D) -> void:
	pass


func _on_hitbox_check_body_entered(body: Node2D) -> void:
	alive = false
	queue_free()
