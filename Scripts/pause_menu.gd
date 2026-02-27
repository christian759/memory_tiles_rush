extends CanvasLayer

func _ready():
	_connect_sounds(self)
	$VBoxContainer.modulate.a = 0
	var tw = create_tween()
	tw.tween_property($VBoxContainer, "modulate:a", 1.0, 0.2)

func _connect_sounds(node: Node):
	if node is Button:
		if not node.is_connected("mouse_entered", Callable(self, "_on_btn_hover")):
			node.mouse_entered.connect(func(): AudioManager.play_hover())
		if not node.is_connected("pressed", Callable(self, "_on_btn_click")):
			node.pressed.connect(func(): AudioManager.play_click())
	for child in node.get_children():
		_connect_sounds(child)

func _on_btn_resume_pressed():
	get_tree().paused = false
	queue_free()

func _on_btn_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()

func _on_btn_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	queue_free()
