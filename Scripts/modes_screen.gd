extends Control

@onready var desc_label = $VBoxContainer/DescriptionBox/DescLabel

func _ready():
	ThemeManager.apply_background($Background)
	ThemeManager.apply_title_style($VBoxContainer/Title)
	ThemeManager.apply_panel_style($VBoxContainer/DescriptionBox)
	
	_connect_sounds(self)
	
	var box = $VBoxContainer
	box.scale = Vector2(0.9, 0.9)
	box.modulate.a = 0
	var tw = create_tween().set_parallel(true)
	tw.tween_property(box, "scale", Vector2(1,1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(box, "modulate:a", 1.0, 0.3)

func _connect_sounds(node: Node):
	if node is Button:
		ThemeManager.apply_button_style(node)
		if not node.is_connected("mouse_entered", Callable(self, "_on_btn_hover_sound")):
			node.mouse_entered.connect(func(): AudioManager.play_hover())
		if not node.is_connected("pressed", Callable(self, "_on_btn_click_sound")):
			node.pressed.connect(func(): AudioManager.play_click())
	for child in node.get_children():
		_connect_sounds(child)

func _on_btn_classic_hover():
	desc_label.text = Global.get_mode_description(Global.GameMode.CLASSIC)

func _on_btn_timed_hover():
	desc_label.text = Global.get_mode_description(Global.GameMode.TIMED)

func _on_btn_moves_hover():
	desc_label.text = Global.get_mode_description(Global.GameMode.MOVES)

func _on_btn_challenge_hover():
	desc_label.text = Global.get_mode_description(Global.GameMode.CHALLENGE)

func _start_game(mode: Global.GameMode):
	Global.current_mode = mode
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_btn_classic_pressed():
	_start_game(Global.GameMode.CLASSIC)

func _on_btn_timed_pressed():
	_start_game(Global.GameMode.TIMED)

func _on_btn_moves_pressed():
	_start_game(Global.GameMode.MOVES)

func _on_btn_challenge_pressed():
	_start_game(Global.GameMode.CHALLENGE)

func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
