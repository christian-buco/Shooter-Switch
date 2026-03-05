extends CharacterBody2D

# ENUMS
enum Role { DODGER, SHOOTER }

# EXPORTED
@export var speed: float = 300.0
@export var bounce_strength: float = 2.5

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 8.0

# STATE
@export var player_id: int = 1
var role: Role = Role.DODGER
var is_alive: bool = true

var input_vector: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("players")
	$BounceArea.body_entered.connect(_on_player_entered)
	global_position = Vector2(randf() * 500, randf() * 500)
	print("Player", name, 
		  "authority:", get_multiplayer_authority(),
		  "pos:", global_position)
	
func _on_player_entered(body):
	if body.is_in_group("players") and body != self:
		var direction = (global_position - body.global_position).normalized()
		knockback_velocity = direction * speed * bounce_strength

func _physics_process(delta: float) -> void:
	#if !is_multiplayer_authority(): return
	if not is_alive: return
	
	if role == Role.DODGER:
		handle_movement()
		velocity += knockback_velocity
		move_and_slide()
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * speed * delta)

func handle_movement():
	input_vector = Vector2.ZERO

	input_vector.x = Input.get_action_strength("move_right_%d" % player_id) - \
						Input.get_action_strength("move_left_%d" % player_id)
						
	input_vector.y = Input.get_action_strength("move_down_%d" % player_id) - \
						Input.get_action_strength("move_up_%d" % player_id)

	input_vector = input_vector.normalized()
	velocity = input_vector * speed

func set_role(new_role: Role):
	role = new_role
	
	if role == Role.SHOOTER:
		velocity = Vector2.ZERO
	else:
		is_alive = true
		visible = true

func die():
	is_alive = false
	velocity = Vector2.ZERO
	visible = false
	set_collision_layer_value(1, false)

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
