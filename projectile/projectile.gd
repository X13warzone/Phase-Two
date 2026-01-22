extends CharacterBody2D


## How fast the projectile travels
@export var speed: float
## How long the projectile lasts, in seconds
@export var life_time: float = 10.0
@export var damage: int = 1


var current_life: float = 0
var alive: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2(speed, 0).rotated(rotation)
	print(rotation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_life += delta
	if current_life >= life_time:
		alive = false
		queue_free()


func _physics_process(delta: float) -> void:
	move_and_slide()


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.has_method("take_hit"):
		alive = false
		body.take_hit(damage, Entity.DMG_TYPE.MAG)
		queue_free()


func _on_hitbox_check_body_entered(body: Node2D) -> void:
	print_debug("Fireball wall")
	alive = false
	queue_free()
