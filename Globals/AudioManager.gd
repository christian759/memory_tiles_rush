extends Node

@onready var bgm: AudioStreamPlayer = $BGM
@onready var sfx_flip: AudioStreamPlayer = $SFX/Flip
@onready var sfx_match: AudioStreamPlayer = $SFX/Match
@onready var sfx_error: AudioStreamPlayer = $SFX/Error
@onready var sfx_win: AudioStreamPlayer = $SFX/Win
@onready var sfx_hover: AudioStreamPlayer = $SFX/Hover
@onready var sfx_click: AudioStreamPlayer = $SFX/Click

func play_bgm():
	if Global.music_enabled and bgm.stream != null and not bgm.playing:
		bgm.play()

func stop_bgm():
	bgm.stop()

func play_flip():
	_play_sfx(sfx_flip)

func play_match():
	_play_sfx(sfx_match)

func play_error():
	_play_sfx(sfx_error)

func play_win():
	_play_sfx(sfx_win)

func play_hover():
	_play_sfx(sfx_hover)

func play_click():
	_play_sfx(sfx_click)

func _play_sfx(player: AudioStreamPlayer):
	if Global.sounds_enabled and player.stream != null:
		player.pitch_scale = randf_range(0.9, 1.1)
		player.play()
