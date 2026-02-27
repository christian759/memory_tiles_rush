extends Node

# Game Modes
enum GameMode { CLASSIC, TIMED, MOVES, CHALLENGE }
var current_mode = GameMode.CLASSIC

# Settings
var master_volume: float = 0.5
var sounds_enabled: bool = true
var music_enabled: bool = true
var grid_size: int = 4 # 4 for 4x4, 6 for 6x6
var current_theme: int = 0

# Game State
var score: int = 0
var moves: int = 0
var time_elapsed: float = 0
var hints_used: int = 0

# Mode specific stats
var mode_highscores = {
	GameMode.CLASSIC: 0,
	GameMode.TIMED: 0,
	GameMode.MOVES: 0,
	GameMode.CHALLENGE: 0
}

func reset_run_stats():
	score = 0
	moves = 0
	time_elapsed = 0
	hints_used = 0

func get_mode_name(mode: GameMode) -> String:
	match mode:
		GameMode.CLASSIC: return "Classic Mode"
		GameMode.TIMED: return "Timed Mode"
		GameMode.MOVES: return "Moves Mode"
		GameMode.CHALLENGE: return "Challenge Mode"
	return "Unknown"

func get_mode_description(mode: GameMode) -> String:
	match mode:
		GameMode.CLASSIC: return "Match all pairs to win.\nTake your time!"
		GameMode.TIMED: return "Match all pairs before\ntime runs out."
		GameMode.MOVES: return "Match all pairs within\na limited number of moves."
		GameMode.CHALLENGE: return "Watch out for special tiles\nwith bonuses and penalties!"
	return ""

func save_highscore(mode: GameMode, value: int):
	if mode_highscores[mode] < value:
		mode_highscores[mode] = value
