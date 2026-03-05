extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("players"):
		body.die()
		queue_free()
