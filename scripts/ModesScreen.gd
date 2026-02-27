extends Control

var _mode_buttons := {}

func _ready():
    theme = Global.get_ui_theme()
    _mode_buttons = {
        Global.GameMode.CLASSIC: $Content/ModeList/ClassicButton,
        Global.GameMode.TIMED: $Content/ModeList/TimedButton,
        Global.GameMode.MOVES: $Content/ModeList/MovesButton,
        Global.GameMode.CHALLENGE: $Content/ModeList/ChallengeButton
    }
    for mode in _mode_buttons.keys():
        var button = _mode_buttons[mode]
        button.text = Global.get_mode_meta(mode).name
        button.connect("pressed", callable(self, "_on_mode_selected"), [mode])
    $Content/BackButton.connect("pressed", callable(self, "_on_back"))
    _update_description(Global.selected_mode)

func _on_mode_selected(mode: int):
    Global.select_mode(mode)
    Global.play_sfx("match", 1.0)
    _update_description(mode)
    get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func _update_description(mode: int):
    var meta = Global.get_mode_meta(mode)
    $Content/Description.text = meta.description
    var detail = "Mode: %s" % meta.name
    $Content/Status.text = detail

func _on_back():
    get_tree().change_scene_to_file("res://home.tscn")
