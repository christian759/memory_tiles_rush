extends Control

const TileScene = preload("res://Scenes/Tile.tscn")

@onready var mode_label = $UI/TopBar/HBox/ModeLabel
@onready var stats_label = $UI/TopBar/HBox/StatsLabel
@onready var grid = $UI/CenterContainer/GridContainer
@onready var game_timer = $GameTimer
@onready var wait_timer = $WaitTimer
@onready var hint_button = $UI/TopBar/HBox/Controls/HintButton

var flipped_tiles: Array = []
var matches_found: int = 0
var total_pairs: int = 0
var is_processing: bool = false
var time_left: int = 0
var moves_left: int = 0

# Emoji icons for tiles
var icons = ["💎", "🍎", "🚀", "🌟", "🍔", "🎮", "🎵", "🎈", "🍉", "🍓", "🍌", "🥑", "🍩", "🍕", "🛸", "🎲", "💡", "🌈"]

func _ready():
	ThemeManager.apply_background($Background)
	ThemeManager.apply_title_style($UI/TopBar/HBox/ModeLabel)
	ThemeManager.apply_title_style($UI/TopBar/HBox/StatsLabel)
	ThemeManager.apply_button_style($UI/TopBar/HBox/Controls/HintButton)
	ThemeManager.apply_button_style($UI/TopBar/HBox/Controls/PauseButton)
	
	AudioManager.play_bgm()
	Global.reset_run_stats()
	_setup_game()

func _setup_game():
	mode_label.text = Global.get_mode_name(Global.current_mode)
	
	var grid_size = Global.grid_size
	grid.columns = grid_size
	total_pairs = (grid_size * grid_size) / 2
	
	if Global.current_mode == Global.GameMode.TIMED:
		time_left = total_pairs * 5 # 5 seconds per pair
		game_timer.start()
	elif Global.current_mode == Global.GameMode.MOVES:
		moves_left = int(total_pairs * 2.5) # generous moves
		game_timer.start() # To track time_elapsed anyway
	else:
		game_timer.start()
	
	_update_stats_ui()
	_spawn_tiles()

func _spawn_tiles():
	# Clean existing
	for child in grid.get_children():
		child.queue_free()
	
	var values = []
	for i in range(total_pairs):
		values.append(i)
		values.append(i)
	
	values.shuffle()
	
	for val in values:
		var tile = TileScene.instantiate()
		grid.add_child(tile)
		tile.set_value(val, icons[val % icons.size()])
		
		# Challenge mode - 10% chance of bonus, 5% time penalty
		if Global.current_mode == Global.GameMode.CHALLENGE:
			var roll = randf()
			if roll < 0.10:
				tile.bonus_type = 1 # extra score
			elif roll < 0.15:
				tile.bonus_type = 3 # penalty
		
		tile.connect("flipped", Callable(self, "_on_tile_flipped"))

func _on_tile_flipped(tile):
	if is_processing or flipped_tiles.size() >= 2:
		return
	
	tile.flip_up()
	flipped_tiles.append(tile)
	
	if flipped_tiles.size() == 2:
		is_processing = true
		Global.moves += 1
		
		if Global.current_mode == Global.GameMode.MOVES:
			moves_left -= 1
			
		_update_stats_ui()
		wait_timer.start(0.8)

func _on_wait_timer_timeout():
	if flipped_tiles[0].value == flipped_tiles[1].value:
		# Match
		AudioManager.play_match()
		for t in flipped_tiles:
			t.set_matched()
			_apply_bonus(t)
			
		matches_found += 1
		Global.score += 100
		
		if matches_found >= total_pairs:
			_win_game()
	else:
		# No match
		AudioManager.play_error()
		for t in flipped_tiles:
			t.flip_down()
			
	flipped_tiles.clear()
	is_processing = false
	
	if Global.current_mode == Global.GameMode.MOVES and moves_left <= 0 and matches_found < total_pairs:
		_lose_game()
	
	_update_stats_ui()

func _apply_bonus(tile):
	if Global.current_mode == Global.GameMode.CHALLENGE:
		if tile.bonus_type == 1:
			Global.score += 50
		elif tile.bonus_type == 3:
			Global.score -= 20

func _on_game_timer_timeout():
	Global.time_elapsed += 1
	if Global.current_mode == Global.GameMode.TIMED:
		time_left -= 1
		_update_stats_ui()
		if time_left <= 0:
			game_timer.stop()
			_lose_game()
	else:
		_update_stats_ui()

func _update_stats_ui():
	var txt = ""
	if Global.current_mode == Global.GameMode.TIMED:
		txt = "Time: %ds | Score: %d" % [time_left, Global.score]
	elif Global.current_mode == Global.GameMode.MOVES:
		txt = "Moves: %d | Score: %d" % [moves_left, Global.score]
	else:
		txt = "Time: %ds | Moves: %d | Score: %d" % [int(Global.time_elapsed), Global.moves, Global.score]
		
	stats_label.text = txt

func _on_hint_pressed():
	if is_processing or Global.hints_used >= 3:
		return
	Global.hints_used += 1
	Global.score -= 50
	
	var unmatched = {}
	for child in grid.get_children():
		if not child.is_matched and not child.is_flipped:
			if not unmatched.has(child.value):
				unmatched[child.value] = []
			unmatched[child.value].append(child)
			
	for val in unmatched:
		if unmatched[val].size() >= 2:
			var t1 = unmatched[val][0]
			var t2 = unmatched[val][1]
			t1.modulate = Color(1.5, 1.5, 0.5)
			t2.modulate = Color(1.5, 1.5, 0.5)
			var tw = create_tween()
			tw.tween_property(t1, "modulate", Color(1,1,1), 1.0)
			var tw2 = create_tween()
			tw2.tween_property(t2, "modulate", Color(1,1,1), 1.0)
			break
			
	_update_stats_ui()

func _on_pause_pressed():
	AudioManager.play_click()
	var pause_scene = load("res://Scenes/PauseMenu.tscn").instantiate()
	get_tree().root.add_child(pause_scene)
	get_tree().paused = true

func _win_game():
	AudioManager.play_win()
	game_timer.stop()
	Global.save_highscore(Global.current_mode, Global.score)
	_show_game_over(true)

func _lose_game():
	AudioManager.play_error()
	game_timer.stop()
	_show_game_over(false)

func _show_game_over(win: bool):
	var over_scene = load("res://Scenes/GameOver.tscn").instantiate()
	over_scene.is_win = win
	get_tree().root.add_child(over_scene)
