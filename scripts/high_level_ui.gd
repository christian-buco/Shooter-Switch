extends Control
@onready var menu = $VBoxContainer
@onready var label = $Label
func _on_server_pressed() -> void:
	NetworkHandler.start_server()
	menu.visible = false
	label.visible = true

func _on_client_pressed() -> void:
	NetworkHandler.start_client()
	menu.visible = false
