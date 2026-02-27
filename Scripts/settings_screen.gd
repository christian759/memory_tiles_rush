extends Control

@onready var btn_sound = $VBoxContainer/HBoxSound/BtnSound
@onready var btn_music = $VBoxContainer/HBoxMusic/BtnMusic
@onready var option_grid = $VBoxContainer/HBoxGrid/OptionGrid

func _ready():
	_connect_sounds(self)
	btn_sound.button_pressed = Global.sounds_enabled
	btn_music.button_pressed = Global.music_enabled
	if Global.grid_size == 4:
		option_grid.select(0)
	else:
		option_grid.select(1)
		
	var box = $VBoxContainer
	box.position.x += 100
	box.modulate.a = 0
	var tw = create_tween().set_parallel(true)
	tw.tween_property(box, "position:x", box.position.x - 100, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_property(box, "modulate:a", 1.0, 0.4)

func _connect_sounds(node: Node):
	if node is Button:
		if not node.is_connected("mouse_entered", Callable(self, "_on_btn_hover")):
			node.mouse_entered.connect(func(): AudioManager.play_hover())
		if not node.is_connected("pressed", Callable(self, "_on_btn_click")):
			node.pressed.connect(func(): AudioManager.play_click())
	for child in node.get_children():
		_connect_sounds(child)

func _on_btn_sound_toggled(button_pressed: bool):
	Global.sounds_enabled = button_pressed
	btn_sound.text = "On" if button_pressed else "Off"
	AudioManager.play_click()

func _on_btn_music_toggled(button_pressed: bool):
	Global.music_enabled = button_pressed
	btn_music.text = "On" if button_pressed else "Off"
	if button_pressed:
		AudioManager.play_bgm()
	else:
		AudioManager.stop_bgm()
	AudioManager.play_click()

func _on_option_grid_item_selected(index: int):
	if index == 0:
		Global.grid_size = 4
	else:
		Global.grid_size = 6
	AudioManager.play_click()

func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
