extends Control

var _grid_sizes = [Vector2i(4, 3), Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4)]

func _ready():
    theme = Global.get_ui_theme()
    _populate_grid_options()
    _populate_theme_options()
    $Content/SoundToggle.connect("toggled", callable(self, "_on_sound_toggled"))
    $Content/MusicToggle.connect("toggled", callable(self, "_on_music_toggled"))
    $Content/HintsToggle.connect("toggled", callable(self, "_on_hints_toggled"))
    $Content/SpeedSlider.connect("value_changed", callable(self, "_on_speed_changed"))
    $Content/BackButton.connect("pressed", callable(self, "_on_back"))
    _sync_ui()

func _populate_grid_options():
    var option = $Content/GridOptions/GridOption
    option.clear()
    for size in _grid_sizes:
        option.add_item("%dx%d" % [size.x, size.y])
        option.set_item_metadata(option.get_item_count() - 1, size)
    option.connect("item_selected", callable(self, "_on_grid_selected"))

func _populate_theme_options():
    var option = $Content/ThemeOptions/ThemeOption
    option.clear()
    for i in range(Global.themes.size()):
        option.add_item(Global.themes[i].name)
        option.set_item_metadata(i, i)
    option.connect("item_selected", callable(self, "_on_theme_selected"))

func _sync_ui():
    var option = $Content/GridOptions/GridOption
    for i in range(option.get_item_count()):
        if option.get_item_metadata(i) == Global.settings["grid_size"]:
            option.select(i)
            break
    $Content/SoundToggle.pressed = Global.settings["sound"]
    $Content/MusicToggle.pressed = Global.settings["music"]
    $Content/HintsToggle.pressed = Global.settings["hints"]
    $Content/SpeedSlider.value = Global.settings["animation_speed"]
    var theme_option = $Content/ThemeOptions/ThemeOption
    theme_option.select(Global.settings["theme_index"])

func _on_grid_selected(index: int):
    var size: Vector2i = $Content/GridOptions/GridOption.get_item_metadata(index)
    Global.set_grid_size(size)

func _on_theme_selected(index: int):
    Global.set_theme_index(index)

func _on_sound_toggled(button_pressed: bool):
    Global.toggle_sound(button_pressed)

func _on_music_toggled(button_pressed: bool):
    Global.toggle_music(button_pressed)

func _on_hints_toggled(button_pressed: bool):
    Global.set_hints_enabled(button_pressed)

func _on_speed_changed(value: float):
    Global.set_animation_speed(value)

func _on_back():
    get_tree().change_scene_to_file("res://home.tscn")
