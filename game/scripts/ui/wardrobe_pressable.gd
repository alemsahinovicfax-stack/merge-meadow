class_name WardrobePressable
extends Control

## Ormar — dodirljiva kontrola unutar skrola (kartica, tab, ShopLink, Close).
## Tap = pritisak + otpuštanje bez pomaka > TAP_SLOP; povlačenje skrola roditeljski
## ScrollContainer (vodoravno ili uspravno — kako je skrol podešen). Samo mouse
## eventi: na telefonu dolaze emulirani iz dodira (emulate_mouse_from_touch).

signal tapped

const TAP_SLOP := 12.0

var enabled: bool = true
## Kartica: scale(.97) dok je pritisnuta (80 ms); 1.0 = bez skaliranja.
var press_scale: float = 1.0

var _down: bool = false
var _dist: float = 0.0
var _pressed: bool = false
var _press_tween: Tween


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func is_pressed() -> bool:
	return _pressed


## Za smoke testove: isti put kao pravi tap.
func simulate_tap() -> void:
	if enabled:
		tapped.emit()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			_down = true
			_dist = 0.0
			_set_pressed(enabled)
			accept_event()
		elif _down:
			_down = false
			var was := _pressed
			_set_pressed(false)
			accept_event()
			if was and enabled and _dist < TAP_SLOP:
				tapped.emit()
	elif event is InputEventMouseMotion and _down:
		var mm := event as InputEventMouseMotion
		if not (mm.button_mask & MOUSE_BUTTON_MASK_LEFT):
			return
		_dist += mm.relative.length()
		if _dist >= TAP_SLOP and _pressed:
			_set_pressed(false)
		_scroll_parent(mm.relative)
		accept_event()


func _scroll_parent(rel: Vector2) -> void:
	var n := get_parent()
	while n != null and not n is ScrollContainer:
		n = n.get_parent()
	var sc := n as ScrollContainer
	if sc == null:
		return
	if sc.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED \
			and sc.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
		sc.scroll_horizontal -= int(rel.x)
	else:
		sc.scroll_vertical -= int(rel.y)


func _set_pressed(on: bool) -> void:
	if _pressed == on:
		return
	_pressed = on
	if press_scale < 0.999:
		pivot_offset = size * 0.5
		if _press_tween != null and _press_tween.is_valid():
			_press_tween.kill()
		_press_tween = create_tween()
		_press_tween.tween_property(self, "scale", Vector2.ONE * (press_scale if on else 1.0), UiWardrobe.T_PRESS)
	queue_redraw()
