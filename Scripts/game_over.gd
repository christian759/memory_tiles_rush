extends CanvasLayer

var is_win: bool = true

@onready var title = $VBoxContainer/Title
@onready var stats = $VBoxContainer/Stats
@onready var box = $VBoxContainer

func _ready():
	_connect_sounds(self)
	
	if is_win:
		title.text = "Victory!"
		title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	else:
		title.text = "Game Over"
		title.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		
	var stats_text = "Mode: %s\nScore: %d\nMoves: %d\nTime: %ds" % [
		Global.get_mode_name(Global.current_mode),
		Global.score,
		Global.moves,
		int(Global.time_elapsed)
	]
	
	stats.text = stats_text
	
	# Entry animation
	box.scale = Vector2(0.5, 0.5)
	box.modulate.a = 0.0
	var tw = create_tween().set_parallel(true)
	tw.tween_property(box, "scale", Vector2(1,1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(box, "modulate:a", 1.0, 0.5)

func _connect_sounds(node: Node):
	if node is Button:
		ThemeManager.apply_button_style(node)
		if not node.is_connected("mouse_entered", Callable(self, "_on_btn_hover")):
			node.mouse_entered.connect(func(): AudioManager.play_hover())
		if not node.is_connected("pressed", Callable(self, "_on_btn_click")):
			node.pressed.connect(func(): AudioManager.play_click())
	for child in node.get_children():
		_connect_sounds(child)

func _on_btn_replay_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()

func _on_btn_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	queue_free()
