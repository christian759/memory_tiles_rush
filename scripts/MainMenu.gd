extends Control

var _color_cycle := [
    Color(0.05, 0.1, 0.2),
    Color(0.07, 0.15, 0.25),
    Color(0.04, 0.08, 0.18)
]
var _cycle_index := 0

@onready var background := $AnimatedBackground
@onready var tween := $BackgroundPulse

func _ready():
    theme = Global.get_ui_theme()
    _cycle_index = randi() % _color_cycle.size()
    background.color = Global.background_color
    _start_pulse()

func _start_pulse():
    var from = _color_cycle[_cycle_index]
    var to = _color_cycle[(_cycle_index + 1) % _color_cycle.size()]
    tween.tween_property(background, "color", to, 3.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_callback(self, 3.2, "_on_pulse_complete")

func _on_pulse_complete():
    _cycle_index = (_cycle_index + 1) % _color_cycle.size()
    background.color = _color_cycle[_cycle_index]
    tween.remove_all()
    _start_pulse()

func _on_StartGame_pressed():
    Global.play_sfx("flip", 1.1)
    get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func _on_Modes_pressed():
    get_tree().change_scene_to_file("res://scenes/ModesScreen.tscn")

func _on_Settings_pressed():
    get_tree().change_scene_to_file("res://scenes/SettingsScreen.tscn")
