extends Node2D

@export var warning_time: float = 1.2
@export var laser_time: float = 0.6

@onready var beam = $Beam
@onready var warning = $Warning

func _ready():
	beam.monitoring = false
	beam.visible = false
	fire_sequence()

func fire_sequence():
	# Show warning
	warning.visible = true
	
	await get_tree().create_timer(warning_time).timeout
	
	# Fire laser
	warning.visible = false
	beam.visible = true
	beam.monitoring = true
	
	await get_tree().create_timer(laser_time).timeout
	
	queue_free()


func _on_beam_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.die()
