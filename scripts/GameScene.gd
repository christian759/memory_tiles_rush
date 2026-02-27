extends Control

const TILE_SCENE := preload("res://scenes/Tile.tscn")
const MODE_SETTINGS := {
    Global.GameMode.CLASSIC: {"timer": 0, "move_limit": 0},
    Global.GameMode.TIMED: {"timer": 90, "move_limit": 0},
    Global.GameMode.MOVES: {"timer": 0, "move_limit": 30},
    Global.GameMode.CHALLENGE: {"timer": 0, "move_limit": 0}
}

const SPECIAL_EFFECTS := [
    {"type": "bonus_time", "label": "+5s", "value": 5, "feedback": "Time Boost!"},
    {"type": "extra_score", "label": "+", "value": 80, "feedback": "Bonus Points!"},
    {"type": "move_penalty", "label": "-1", "value": -1, "feedback": "Move Penalty"}
]

@onready var grid := $GameArea/GridContainer
@onready var top_mode := $TopBar/ModeLabel
@onready var top_moves := $TopBar/MovesLabel
@onready var top_timer := $TopBar/TimerLabel
@onready var top_score := $TopBar/ScoreLabel
@onready var hint_button := $TopBar/HintButton
@onready var pause_button := $TopBar/PauseButton
@onready var countdown_timer := $Countdown
@onready var delay_timer := $FlipBackDelay
@onready var pause_overlay := $PauseOverlay
@onready var result_overlay := $ResultOverlay

var active_tiles := []
var total_pairs := 0
var matched_pairs := 0
var moves := 0
var elapsed := 0.0
var remaining_time := 0
var move_limit := 0
var score := 0
var hints_used := 0
var special_pairs := {}
var grid_size := Vector2i.ZERO

func _ready():
    theme = Global.get_ui_theme()
    Global.connect("settings_changed", callable(self, "_on_settings_changed"))
    countdown_timer.connect("timeout", callable(self, "_on_countdown"))
    delay_timer.connect("timeout", callable(self, "_on_flip_back"))
    pause_button.connect("pressed", callable(self, "_on_pause"))
    hint_button.connect("pressed", callable(self, "_on_hint"))
    _setup_pause()
    result_overlay.connect("replay", callable(self, "_on_replay"))
    result_overlay.connect("main_menu", callable(self, "_on_result_menu"))
    result_overlay.hide()
    start_game()

func start_game():
    score = 0
    moves = 0
    matched_pairs = 0
    elapsed = 0
    hints_used = 0
    active_tiles.clear()
    pause_overlay.hide()
    result_overlay.hide()
    _clear_grid()
    grid_size = Global.settings["grid_size"]
    grid.columns = grid_size.x
    total_pairs = int(grid_size.x * grid_size.y / 2)
    var pool := _build_symbol_pool(total_pairs)
    var assignments := []
    for i in range(total_pairs):
        assignments.append(i)
        assignments.append(i)
    assignments.shuffle()
    special_pairs = {}
    if Global.selected_mode == Global.GameMode.CHALLENGE:
        special_pairs = _assign_specials(total_pairs)
    for idx in range(assignments.size()):
        var pair_id = assignments[idx]
        var tile = TILE_SCENE.instantiate()
        tile.setup(pair_id, pool[pair_id], special_pairs.has(pair_id) ? special_pairs[pair_id] : {}, Global.settings["animation_speed"])
        tile.connect("tile_requested", callable(self, "_on_tile_requested"))
        grid.add_child(tile)
    _apply_mode_metadata()
    _update_ui()

func _clear_grid():
    for child in grid.get_children():
        child.queue_free()

func _build_symbol_pool(pairs: int) -> Array:
    var base_symbols = ["✶", "✦", "◆", "◈", "⬟", "⟁", "❖", "▣", "✪", "✺", "❂", "⌘", "★", "♢", "♧", "♤"]
    base_symbols.shuffle()
    var out := []
    for i in range(pairs):
        out.append(base_symbols[i % base_symbols.size()])
    return out

func _assign_specials(pairs: int) -> Dictionary:
    var map := {}
    var count := int(min(3, pairs / 2))
    var candidates := range(pairs)
    candidates.shuffle()
    for i in range(count):
        var type = SPECIAL_EFFECTS[randi() % SPECIAL_EFFECTS.size()]
        map[candidates[i]] = type
    return map

func _apply_mode_metadata():
    var mode_name = Global.get_mode_meta(Global.selected_mode).name
    top_mode.text = mode_name
    var mode_info = MODE_SETTINGS[Global.selected_mode]
    remaining_time = mode_info.timer
    move_limit = mode_info.move_limit
    top_timer.visible = remaining_time > 0
    if remaining_time > 0:
        countdown_timer.start()
    else:
        countdown_timer.stop()

func _on_tile_requested(tile):
    if active_tiles.has(tile) or tile.is_matched or result_overlay.visible:
        return
    if active_tiles.size() >= 2:
        return
    tile.reveal_face()
    active_tiles.append(tile)
    if active_tiles.size() == 2:
        moves += 1
        _update_ui()
        if _is_match(active_tiles[0], active_tiles[1]):
            _resolve_match(active_tiles[0], active_tiles[1])
        else:
            delay_timer.start()
            Global.play_sfx("error")
    _check_move_limit()

func _resolve_match(a, b):
    a.lock_in_match()
    b.lock_in_match()
    matched_pairs += 1
    var combo = 100 + int(Global.settings["animation_speed"] * 20)
    score += combo
    Global.play_sfx("match", 1.1)
    _apply_special(a)
    active_tiles.clear()
    _update_ui()
    _check_victory()

func _apply_special(tile):
    if Global.selected_mode != Global.GameMode.CHALLENGE:
        return
    var special = tile.special_data
    if special.empty():
        return
    match special.type:
        "bonus_time":
            remaining_time += special.value
            countdown_timer.start()
        "extra_score":
            score += special.value
        "move_penalty":
            move_limit = max(1, move_limit + special.value)
    Global.play_sfx("bonus", 1.0)

func _is_match(a, b) -> bool:
    return a.pair_id == b.pair_id

func _on_flip_back():
    for tile in active_tiles:
        tile.hide_face()
    active_tiles.clear()
    delay_timer.stop()

func _update_ui():
    top_moves.text = "Moves: %d" % moves
    top_score.text = "Score: %d" % score
    if remaining_time > 0:
        top_timer.text = "Time: %ds" % remaining_time
    top_timer.visible = remaining_time > 0
    hint_button.disabled = not Global.settings["hints"]

func _on_countdown():
    remaining_time = max(0, remaining_time - 1)
    _update_ui()
    if remaining_time <= 0:
        countdown_timer.stop()
        _on_game_over("Time's up")

func _check_move_limit():
    if move_limit > 0 and moves >= move_limit:
        _on_game_over("Out of moves")

func _check_victory():
    if matched_pairs >= total_pairs:
        _show_result(true)

func _show_result(victory: bool):
    countdown_timer.stop()
    delay_timer.stop()
    result_overlay.show_result(victory, score, moves, int(elapsed), Global.selected_mode)
    result_overlay.visible = true

func _on_game_over(message: String):
    Global.play_sfx("fail")
    result_overlay.show_result(false, score, moves, int(elapsed), Global.selected_mode, message)
    result_overlay.visible = true

func _process(delta):
    if result_overlay.visible:
        return
    elapsed += delta

func _on_pause():
    pause_overlay.show()
    get_tree().paused = true

func resume_game():
    pause_overlay.hide()
    get_tree().paused = false

func _setup_pause():
    pause_overlay.hide()
    pause_overlay.connect("resume_game", self, "resume_game")
    pause_overlay.connect("restart_game", self, "start_game")
    pause_overlay.connect("back_to_menu", self, "_back_to_menu")

func _back_to_menu():
    get_tree().paused = false
    get_tree().change_scene_to_file("res://home.tscn")

func _on_replay():
    result_overlay.hide()
    start_game()

func _on_result_menu():
    result_overlay.hide()
    get_tree().change_scene_to_file("res://home.tscn")

func _on_hint():
    if not Global.settings["hints"]:
        return
    hints_used += 1
    var unmatched := []
    for child in grid.get_children():
        if child is MemoryTile and not child.is_matched and not child.is_face_up:
            unmatched.append(child)
    if unmatched.size() > 0:
        var tile = unmatched[randi() % unmatched.size()]
        tile.play_hint()
    Global.play_sfx("hint", 1.2)

func _on_settings_changed():
    hint_button.disabled = not Global.settings["hints"]
    start_game()
