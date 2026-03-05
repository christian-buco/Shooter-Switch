extends Node

@onready var players = get_parent().get_node("Players").get_children()
@onready var crosshair = get_parent().get_node("Crosshair")

# Timer
@onready var countdown_label: Label = get_parent().get_node("UI/CountdownLabel")
@onready var timer_label: Label = get_parent().get_node("UI/TimerLabel")

var countdown_time: int = 3
var round_time: float = 15.0

var countdown_active: bool = false
var round_active: bool = false

var current_shooter_index: int = 1

@export var laser_scene: PackedScene
@export var projectile_scene: PackedScene
@onready var projectile_container = get_parent().get_node("Projectiles")

func get_screen_rect() -> Rect2:
	var size = get_viewport().get_visible_rect().size
	return Rect2(Vector2.ZERO, size)

func get_random_outside_position() -> Vector2:
	var screen = get_screen_rect()
	var margin = 50.0

	var side = randi() % 4

	match side:
		0: # Top
			return Vector2(randf_range(0, screen.size.x), -margin)
		1: # Bottom
			return Vector2(randf_range(0, screen.size.x), screen.size.y + margin)
		2: # Left
			return Vector2(-margin, randf_range(0, screen.size.y))
		3: # Right
			return Vector2(screen.size.x + margin, randf_range(0, screen.size.y))

	return Vector2.ZERO

func _ready():
	start_round()

func _process(delta):
	if round_active:
		if players[current_shooter_index].role == players[current_shooter_index].Role.SHOOTER:
			if Input.is_action_just_pressed("shoot_ability_1"):
				print("Spawn projectile")
				spawn_projectile()
			if Input.is_action_just_pressed("shoot_ability_2"):
				print("Spawn laser")
				spawn_laser()

func spawn_projectile():
	var spawn_pos = get_random_outside_position()
	var target_pos = crosshair.global_position
	
	var p = projectile_scene.instantiate()
	p.global_position = spawn_pos
	
	var dir = (target_pos - spawn_pos).normalized()
	p.direction = dir
	
	projectile_container.add_child(p)

func spawn_laser():
	var laser = laser_scene.instantiate()
	
	laser.global_position = crosshair.global_position
	
	# Random horizontal or vertical
	if randi() % 2 == 0:
		laser.rotation_degrees = 0
	else:
		laser.rotation_degrees = 90
	
	add_child(laser)

func start_round():
	assign_shooter(current_shooter_index)
	start_countdown()

func start_countdown():
	countdown_active = true
	round_active = false
	
	crosshair.active = false
	countdown_label.visible = true
	
	run_countdown()

func run_countdown() -> void:
	var time_left = countdown_time
	
	while time_left > 0:
		countdown_label.text = str(time_left)
		await get_tree().create_timer(1.0).timeout
		time_left -= 1
		
	countdown_label.text = "GO!"
	await get_tree().create_timer(0.5).timeout
	
	countdown_label.visible = false
	
	start_action_phase()
	
func start_action_phase():
	countdown_active = false
	round_active = true
	
	crosshair.active = true
	start_round_timer()
	
func start_round_timer():
	var time_left = round_time

	while time_left > 0 and round_active:
		timer_label.text = str(int(time_left))
		await get_tree().create_timer(1.0).timeout
		time_left -= 1

	if round_active:
		pass
		#end_round()

func assign_shooter(index: int):
	for i in players.size():
		if i == index:
			players[i].set_role(players[i].Role.SHOOTER)
			crosshair.active = true
		else:
			players[i].set_role(players[i].Role.DODGER)
