extends Control

signal resume_game
signal restart_game
signal back_to_menu

func _ready():
    theme = Global.get_ui_theme()
    $Resume.connect("pressed", callable(self, "_on_resume"))
    $Restart.connect("pressed", callable(self, "_on_restart"))
    $MainMenu.connect("pressed", callable(self, "_on_back"))

func _on_resume():
    emit_signal("resume_game")

func _on_restart():
    emit_signal("restart_game")

func _on_back():
    emit_signal("back_to_menu")
