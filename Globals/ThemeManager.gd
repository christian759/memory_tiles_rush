extends Node

# A set of beautiful dynamic styles.
const COLOR_BG_TOP = Color("#0f172a") # dark slate
const COLOR_BG_BOT = Color("#1e1b4b") # deep indigo

func apply_background(node: Node):
	# Replaces a raw ColorRect with a smooth gradient
	if node is ColorRect:
		var rect = TextureRect.new()
		var grad = Gradient.new()
		grad.colors = PackedColorArray([COLOR_BG_TOP, COLOR_BG_BOT])
		grad.offsets = PackedFloat32Array([0.0, 1.0])
		var tex = GradientTexture2D.new()
		tex.gradient = grad
		tex.fill_to = Vector2(0, 1)
		tex.fill_from = Vector2(0, 0)
		rect.texture = tex
		rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		node.get_parent().add_child(rect)
		node.get_parent().move_child(rect, node.get_index())
		node.queue_free()
		
		# Add a subtle floating particle effect on the background
		_add_floating_particles(rect)

func apply_button_style(btn: Button):
	# Glassmorphic button
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(1, 1, 1, 0.1)
	normal.border_width_all = 2
	normal.border_color = Color(1, 1, 1, 0.2)
	normal.corner_radius_top_left = 16
	normal.corner_radius_top_right = 16
	normal.corner_radius_bottom_left = 16
	normal.corner_radius_bottom_right = 16
	normal.shadow_color = Color(0, 0, 0, 0.2)
	normal.shadow_size = 4
	normal.shadow_offset = Vector2(0, 2)
	
	var hover = normal.duplicate()
	hover.bg_color = Color(1, 1, 1, 0.2)
	hover.border_color = Color(1, 1, 1, 0.4)
	hover.expand_margin_top = 2
	hover.expand_margin_bottom = 2
	hover.expand_margin_left = 4
	hover.expand_margin_right = 4
	hover.shadow_size = 8
	
	var pressed = normal.duplicate()
	pressed.bg_color = Color(1, 1, 1, 0.05)
	pressed.border_color = Color(1, 1, 1, 0.1)
	pressed.shadow_size = 0
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_color_override("font_color", Color(1,1,1,0.9))
	btn.add_theme_color_override("font_hover_color", Color(1,1,1,1))

func apply_title_style(label: Label):
	label.add_theme_color_override("font_color", Color("#f8fafc"))
	label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.5))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.add_theme_constant_override("shadow_outline_size", 4)

func apply_panel_style(panel: PanelContainer):
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.4)
	sb.border_width_all = 2
	sb.border_color = Color(1, 1, 1, 0.1)
	sb.corner_radius_top_left = 16
	sb.corner_radius_top_right = 16
	sb.corner_radius_bottom_left = 16
	sb.corner_radius_bottom_right = 16
	panel.add_theme_stylebox_override("panel", sb)

func _add_floating_particles(parent: Node):
	# Flowing ethereal dust
	var p = CPUParticles2D.new()
	p.position = Vector2(640, 720) # Bottom center
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(640, 0)
	p.direction = Vector2(0, -1)
	p.spread = 15.0
	p.gravity = Vector2(0, -5)
	p.initial_velocity_min = 10.0
	p.initial_velocity_max = 30.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 6.0
	p.color = Color(1, 1, 1, 0.1)
	p.amount = 40
	p.lifetime = 20.0
	p.preprocess = 20.0 # So it's already full on spawn
	parent.add_child(p)
	
	# Floating Glass Orbs
	for i in range(5):
		var orb = ColorRect.new()
		orb.color = Color(1, 1, 1, 0.03)
		var size_val = randf_range(50, 200)
		orb.custom_minimum_size = Vector2(size_val, size_val)
		orb.size = Vector2(size_val, size_val)
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = orb.color
		sb.corner_radius_top_left = 1000
		sb.corner_radius_top_right = 1000
		sb.corner_radius_bottom_left = 1000
		sb.corner_radius_bottom_right = 1000
		orb.add_theme_stylebox_override("panel", sb)
		
		# For flat ColorRects to have rounded corners, Godot 4 uses Panel instead.
		# Let's cleanly swap this to a Panel.
		var panel = Panel.new()
		panel.add_theme_stylebox_override("panel", sb)
		panel.custom_minimum_size = Vector2(size_val, size_val)
		panel.size = Vector2(size_val, size_val)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var start_x = randf_range(0, 1280)
		var start_y = randf_range(0, 720)
		panel.position = Vector2(start_x, start_y)
		parent.add_child(panel)
		
		_float_orb(panel)

func _float_orb(panel: Panel):
	var tw = create_tween().set_loops()
	var new_x = panel.position.x + randf_range(-100, 100)
	var new_y = panel.position.y + randf_range(-100, 100)
	var dur = randf_range(5.0, 10.0)
	tw.tween_property(panel, "position", Vector2(new_x, new_y), dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(panel, "position", panel.position, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
