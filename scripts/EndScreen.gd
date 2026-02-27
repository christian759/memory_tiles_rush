extends Control

signal replay()
signal main_menu()

@onready var status_label := $Content/StatusLabel
@onready var detail_label := $Content/DetailLabel
@onready var stats_label := $Content/StatsLabel
@onready var primary_button := $Content/Buttons/PlayAgain
@onready var secondary_button := $Content/Buttons/Menu

func _ready():
    theme = Global.get_ui_theme()
    primary_button.connect("pressed", callable(self, "_on_replay"))
    secondary_button.connect("pressed", callable(self, "_on_menu"))
    hide()

func show_result(victory: bool, score: int, moves: int, seconds: int, mode: int, message: String = "") -> void:
    status_label.text = victory ? "Victory!" : "Game Over"
    detail_label.text = victory ? "You mastered %s." % Global.get_mode_meta(mode).name : message
    stats_label.text = "Score: %d\nMoves: %d\nTime: %ds" % [score, moves, seconds]
    queue_signal_details(victory)
    show()

func queue_signal_details(victory: bool) -> void:
    primary_button.text = victory ? "Play Again" : "Retry"

func _on_replay():
    hide()
    emit_signal("replay")

func _on_menu():
    emit_signal("main_menu")
