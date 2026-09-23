class_name HomeUnlockBurst
extends Control

## Prsten trenutka otkljucavanja (HomeScreen.dc.html · UnlockBurst, 760 px, rub 16).
## Crta se jednom; animira se samo scale + modulate:a, bez redrawa po frejmu.

var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	resized.connect(_on_resized)
	_on_resized()


func play() -> void:
	if _tween:
		_tween.kill()
	visible = true
	scale = Vector2.ONE * 0.2
	modulate.a = 1.0
	if not is_inside_tree():
		return
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2.ONE, UiHome.T_UNLOCK)
	_tween.tween_callback(func() -> void: visible = false)


func is_playing() -> bool:
	return visible and _tween != null and _tween.is_valid() and _tween.is_running()


func _on_resized() -> void:
	pivot_offset = size * 0.5


func _draw() -> void:
	var r := UiHome.BURST_DIAMETER * 0.5 - UiHome.BURST_BORDER * 0.5
	draw_arc(size * 0.5, r, 0.0, TAU, 96, UiHome.BURST, UiHome.BURST_BORDER, true)
