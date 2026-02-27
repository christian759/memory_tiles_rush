extends Node

const GameMode = {
    CLASSIC: 0,
    TIMED: 1,
    MOVES: 2,
    CHALLENGE: 3
}

const ModeMeta = {
    GameMode.CLASSIC: {
        name: "Classic",
        description: "Match every pair with unlimited moves and savor the rhythm."
    },
    GameMode.TIMED: {
        name: "Timed",
        description: "Beat the clock before time runs out."
    },
    GameMode.MOVES: {
        name: "Moves-Limited",
        description: "Every move counts—stay sharp and economical."
    },
    GameMode.CHALLENGE: {
        name: "Challenge",
        description: "Special tiles spice up the board with bonuses and penalties."
    }
}

signal music_toggled(enabled)
signal sound_toggled(enabled)
signal settings_changed()
signal mode_changed(mode)

var settings := {
    "grid_size": Vector2i(4, 4),
    "animation_speed": 1.0,
    "theme_index": 0,
    "sound": true,
    "music": true,
    "hints": true
}

var themes = [
    {"name": "Calm Ocean", "accent": Color(0.21, 0.58, 0.72), "background": Color(0.04, 0.05, 0.12)},
    {"name": "Warm Dawn", "accent": Color(0.94, 0.49, 0.32), "background": Color(0.13, 0.07, 0.04)},
    {"name": "Misty Forest", "accent": Color(0.18, 0.66, 0.47), "background": Color(0.05, 0.12, 0.09)}
]

var selected_mode: int = GameMode.CLASSIC
var score: int = 0
var ui_theme: Theme
var accent_color: Color = themes[0].accent
var background_color: Color = themes[0].background

var audio_players := {}

func _ready():
    load_settings()
    _instantiate_audio()
    _apply_theme(settings["theme_index"])

func _instantiate_audio():
    audio_players.music = AudioStreamPlayer.new()
    audio_players.sfx = AudioStreamPlayer.new()
    add_child(audio_players.music)
    add_child(audio_players.sfx)
    audio_players.music.bus = "Music"
    audio_players.sfx.bus = "SFX"
    if settings["music"]:
        _start_music()

func _start_music():
    if not audio_players.music.stream:
        var path = "res://assets/audio/ambient_loop.wav"
        if ResourceLoader.exists(path):
            audio_players.music.stream = ResourceLoader.load(path)
    if audio_players.music.stream:
        audio_players.music.playing = true
        audio_players.music.loop = true

func play_sfx(name: String, pitch_scale: float = 1.0):
    if not settings["sound"]:
        return
    var path = "res://assets/audio/%s.wav" % name
    if not ResourceLoader.exists(path):
        return
    audio_players.sfx.stream = ResourceLoader.load(path)
    audio_players.sfx.pitch_scale = pitch_scale
    audio_players.sfx.play()

func toggle_music(enabled: bool):
    settings["music"] = enabled
    if enabled:
        _start_music()
    else:
        audio_players.music.playing = false
    emit_signal("music_toggled", enabled)
    save_settings()

func toggle_sound(enabled: bool):
    settings["sound"] = enabled
    emit_signal("sound_toggled", enabled)
    save_settings()

func set_theme_index(index: int) -> void:
    settings["theme_index"] = clamp(index, 0, themes.size() - 1)
    _apply_theme(settings["theme_index"])
    emit_signal("settings_changed")
    save_settings()

func set_grid_size(size: Vector2i) -> void:
    settings["grid_size"] = size
    emit_signal("settings_changed")
    save_settings()

func set_animation_speed(speed: float) -> void:
    settings["animation_speed"] = clamp(speed, 0.5, 2.0)
    emit_signal("settings_changed")
    save_settings()

func set_hints_enabled(enabled: bool) -> void:
    settings["hints"] = enabled
    emit_signal("settings_changed")
    save_settings()

func select_mode(mode: int) -> void:
    selected_mode = mode
    emit_signal("mode_changed", mode)

func get_mode_meta(mode: int) -> Dictionary:
    return ModeMeta.get(mode, {})

func get_current_theme() -> Dictionary:
    return themes[settings["theme_index"]]

func _apply_theme(index: int) -> void:
    var theme_data = themes[index]
    accent_color = theme_data.accent
    background_color = theme_data.background

func load_settings():
    var cfg = ConfigFile.new()
    if cfg.load("user://settings.cfg") == OK:
        var grid_data = cfg.get_value("game", "grid_size", settings["grid_size"])
        if typeof(grid_data) == TYPE_VECTOR2:
            settings["grid_size"] = Vector2i(grid_data.x, grid_data.y)
        else:
            settings["grid_size"] = grid_data
        settings["animation_speed"] = cfg.get_value("game", "animation_speed", settings["animation_speed"])
        settings["theme_index"] = cfg.get_value("game", "theme_index", settings["theme_index"])
        settings["sound"] = cfg.get_value("audio", "sound", settings["sound"])
        settings["music"] = cfg.get_value("audio", "music", settings["music"])
        settings["hints"] = cfg.get_value("game", "hints", settings["hints"])

func save_settings():
    var cfg = ConfigFile.new()
    cfg.set_value("game", "grid_size", Vector2(settings["grid_size"]))
    cfg.set_value("game", "animation_speed", settings["animation_speed"])
    cfg.set_value("game", "theme_index", settings["theme_index"])
    cfg.set_value("game", "hints", settings["hints"])
    cfg.set_value("audio", "sound", settings["sound"])
    cfg.set_value("audio", "music", settings["music"])
    cfg.save("user://settings.cfg")

func get_ui_theme() -> Theme:
    if ui_theme:
        return ui_theme
    ui_theme = Theme.new()
    var base = StyleBoxFlat.new()
    base.bg_color = Color(1, 1, 1, 0)
    ui_theme.set_stylebox("panel", "Panel", base)
    ui_theme.set_stylebox("normal", "Button", _make_button_style(Color(0.25, 0.45, 0.7)))
    ui_theme.set_stylebox("hover", "Button", _make_button_style(Color(0.4, 0.65, 0.9)))
    ui_theme.set_stylebox("pressed", "Button", _make_button_style(Color(0.15, 0.35, 0.6)))
    ui_theme.set_color("font_color", "Button", Color(1, 1, 1))
    ui_theme.set_constant("separation", "Button", 12)
    return ui_theme

func _make_button_style(color: Color) -> StyleBoxFlat:
    var style = StyleBoxFlat.new()
    style.bg_color = color
    style.corner_radius_top_left = 12
    style.corner_radius_top_right = 12
    style.corner_radius_bottom_right = 12
    style.corner_radius_bottom_left = 12
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    style.border_width_bottom = 2
    style.border_width_top = 2
    style.border_width_left = 2
    style.border_width_right = 2
    style.border_color = Color(1, 1, 1, 0.2)
    return style
end
