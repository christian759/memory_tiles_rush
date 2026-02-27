extends Button
class_name MemoryTile

signal tile_requested(tile)
signal reveal_complete(tile)

var pair_id: int
var symbol: String = ""
var is_matched: bool = false
var is_face_up: bool = false
var special_data: Dictionary = {}
var flip_duration: float = 0.32
var _tween: Tween
var _highlight: ColorRect

@onready var particle = $MatchParticles
@onready var indicator = $SpecialIndicator

func _ready():
    _tween = Tween.new()
    add_child(_tween)
    _highlight = $Highlight
    connect("pressed", callable(self, "_on_pressed"))
    indicator.modulate = Color(1, 1, 1, 0)

func setup(id: int, display: String, special: Dictionary, speed_multiplier: float) -> void:
    pair_id = id
    symbol = display
    special_data = special
    flip_duration = 0.42 / max(0.5, speed_multiplier)
    text = ""
    is_face_up = false
    is_matched = false
    modulate = Color(1, 1, 1, 1)
    indicator.text = special_data.get("label", "")
    indicator.visible = not special_data.empty()
    indicator.modulate = special_data.empty() ? Color(1, 1, 1, 0) : Color(1, 1, 1, 0.9)

func _on_pressed() -> void:
    emit_signal("tile_requested", self)

func reveal_face(instant: bool = false) -> void:
    if is_face_up or is_matched:
        return
    _animate_flip(true, instant)

func hide_face(instant: bool = false) -> void:
    if not is_face_up or is_matched:
        return
    _animate_flip(false, instant)

func lock_in_match() -> void:
    is_matched = true
    _highlight.color = Color(0.81, 0.98, 0.64, 0.65)
    particle.emitting = true
    text = symbol

func play_hint() -> void:
    _highlight.color = Color(1, 1, 1, 0.5)
    _tween.kill()
    _tween.tween_property(_highlight, "color:a", 0.0, 0.4).set_delay(0.3)

func _animate_flip(show: bool, instant: bool) -> void:
    is_face_up = show
    if instant:
        text = show ? symbol : ""
        return
    _tween.stop_all()
    _tween.tween_property(self, "scale:x", 0.03, flip_duration * 0.5).set_trans(Tween.TRANS_SINE)
    _tween.tween_callback(self, flip_duration * 0.5, funcref(self, "_on_half_flip"), show)
    _tween.tween_property(self, "scale:x", 1.0, flip_duration * 0.5).set_delay(flip_duration * 0.5).set_trans(Tween.TRANS_SINE)

func _on_half_flip(show: bool) -> void:
    text = show ? symbol : ""
    if show:
        _highlight.color = Color(1, 1, 1, 0.2)
    else:
        _highlight.color = Color(1, 1, 1, 0)
    emit_signal("reveal_complete", self)
