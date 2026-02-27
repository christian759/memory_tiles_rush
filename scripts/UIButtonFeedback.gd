extends Button

@export var hover_scale: Vector2 = Vector2.ONE * 1.03
@export var hover_duration: float = 0.14
@export var press_scale: Vector2 = Vector2.ONE * 0.96

var _base_scale: Vector2
var _tween: Tween

func _ready():
    _base_scale = scale
    _tween = Tween.new()
    add_child(_tween)
    connect("mouse_entered", callable(self, "_on_mouse_entered"))
    connect("mouse_exited", callable(self, "_on_mouse_exited"))
    connect("pressed", callable(self, "_on_pressed"))
    connect("focus_exited", callable(self, "_on_mouse_exited"))

func _on_mouse_entered():
    _tween.kill()
    _tween.tween_property(self, "scale", hover_scale, hover_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_mouse_exited():
    _tween.kill()
    _tween.tween_property(self, "scale", _base_scale, hover_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _on_pressed():
    _tween.kill()
    _tween.tween_property(self, "scale", press_scale, hover_duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    _tween.tween_property(self, "scale", hover_scale, hover_duration / 2).set_delay(hover_duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
