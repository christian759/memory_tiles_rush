extends Button

signal flipped(tile)

var value: int = -1
var is_flipped: bool = false
var is_matched: bool = false

# For challenge mode
var bonus_type: int = 0 # 0=none, 1=extra_points, 2=extra_time, 3=penalty

@onready var symbol_label: Label = $Symbol

func _ready():
	_update_visuals()
	symbol_label.hide()
	pivot_offset = size / 2
	resized.connect(_on_resized)

func _on_resized():
	pivot_offset = size / 2

func set_value(val: int, icon_str: String):
	value = val
	symbol_label.text = icon_str

func flip_up():
	if is_flipped or is_matched: return
	is_flipped = true
	AudioManager.play_flip()
	_animate_flip(true)

func flip_down():
	if not is_flipped or is_matched: return
	is_flipped = false
	AudioManager.play_flip()
	_animate_flip(false)

func set_matched():
	is_matched = true
	disabled = true
	# Pop animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
	
	# Change color to matched state
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.2, 0.8, 0.2, 0.8)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	add_theme_stylebox_override("disabled", sb)

func _animate_flip(to_up: bool):
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0.0, 0.15).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		if to_up:
			symbol_label.show()
			_set_front_style()
		else:
			symbol_label.hide()
			_set_back_style()
	)
	tween.tween_property(self, "scale:x", 1.0, 0.15).set_trans(Tween.TRANS_QUAD)

func _on_pressed():
	if not is_flipped and not is_matched:
		emit_signal("flipped", self)

func _set_back_style():
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.2, 0.2, 0.4, 1.0)
	sb.border_width_bottom = 6
	sb.border_color = Color(0.1, 0.1, 0.25, 1.0)
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	add_theme_stylebox_override("normal", sb)
	
	var sb_hover = sb.duplicate()
	sb_hover.bg_color = Color(0.25, 0.25, 0.5, 1.0)
	sb_hover.border_width_bottom = 4
	sb_hover.expand_margin_top = 2
	add_theme_stylebox_override("hover", sb_hover)
	
	var sb_pressed = sb.duplicate()
	sb_pressed.border_width_bottom = 0
	sb_pressed.expand_margin_top = 6
	sb_pressed.bg_color = Color(0.15, 0.15, 0.3, 1.0)
	add_theme_stylebox_override("pressed", sb_pressed)
	
	# clear disabled overrrides just in case
	remove_theme_stylebox_override("disabled")

func _set_front_style():
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.95, 0.95, 0.95, 1.0)
	if bonus_type == 1 or bonus_type == 2:
		sb.border_color = Color(0.8, 0.8, 0.2, 1.0)
		sb.border_width_all = 4
	elif bonus_type == 3:
		sb.border_color = Color(0.8, 0.2, 0.2, 1.0)
		sb.border_width_all = 4
	else:
		sb.border_color = Color(0.8, 0.8, 0.8, 1.0)
		sb.border_width_bottom = 4

	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("hover", sb)
	add_theme_stylebox_override("pressed", sb)

func _update_visuals():
	if is_flipped or is_matched:
		_set_front_style()
	else:
		_set_back_style()
