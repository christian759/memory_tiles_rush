extends Control

func _ready():
	_connect_sounds(self)
	# Quick tween entry animation
	var box = $VBoxContainer
	box.position.y += 50
	box.modulate.a = 0
	var tw = create_tween().set_parallel(true)
	tw.tween_property(box, "position:y", box.position.y - 50, 0.5).set_trans(Tween.TRANS_OUT).set_ease(Tween.EASE_OUT)
	tw.tween_property(box, "modulate:a", 1.0, 0.5)
	
	AudioManager.play_bgm()

func _connect_sounds(node: Node):
	if node is Button:
		node.mouse_entered.connect(func(): AudioManager.play_hover())
		node.pressed.connect(func(): AudioManager.play_click())
	for child in node.get_children():
		_connect_sounds(child)

func _on_btn_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_btn_modes_pressed():
	get_tree().change_scene_to_file("res://Scenes/ModesScreen.tscn")

func _on_btn_settings_pressed():
	get_tree().change_scene_to_file("res://Scenes/SettingsScreen.tscn")

func _on_btn_quit_pressed():
	get_tree().quit()
