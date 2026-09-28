class_name HomeV3Arrow
extends Control

## PrevSeason / NextSeason: krug 120 (krem, rub 4 ink, sjenka 0 6 0 .24) s
## chevronom 26 + rub 9, pomaknutim 6 px ka svojoj strani (margin 12).

signal pressed

@export var left: bool = true
var _down: bool = false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = Vector2(UiHomeV3.ARROW_SIZE, UiHomeV3.ARROW_SIZE)
	custom_minimum_size = size


func _gui_input(event: InputEvent) -> void:
	var pos := Vector2.ZERO
	var is_down := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		pos = mb.position
		is_down = mb.pressed
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		pos = st.position
		is_down = st.pressed
	else:
		return
	accept_event()
	var inside := Rect2(Vector2.ZERO, size).has_point(pos)
	if is_down:
		_set_down(inside)
		return
	var fire := _down and inside
	_set_down(false)
	if fire:
		pressed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED or what == NOTIFICATION_MOUSE_EXIT:
		_set_down(false)


func _set_down(v: bool) -> void:
	if _down == v:
		return
	_down = v
	queue_redraw()


func _draw() -> void:
	var lift := 4.0 if _down else 0.0
	var r := Rect2(Vector2(0.0, lift), size)
	UiHomeV3.draw_panel(self, r, UiHomeV3.CREAM, size.x * 0.5, 4.0, UiHomeV3.INK, 6.0 - lift, UiHomeV3.ARROW_SHADOW)
	var shift := 6.0 if left else -6.0
	UiHomeV3.draw_chevron(self, r.get_center() + Vector2(shift, 0.0), 26.0, 9.0, left, UiHomeV3.INK)
