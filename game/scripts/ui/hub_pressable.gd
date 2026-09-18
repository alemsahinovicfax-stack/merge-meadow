class_name HubPressable
extends Control

## Klik-zona hub chromea (tab, Settings) — isti input obrazac kao UiClickButton
## (BaseButton lomi klik na desktopu, greske-katalog #5): touch klikne na pritisak, miš na otpuštanje.
## Podklasa crta stanje u _apply_state().

signal clicked

var disabled: bool = false:
	set(value):
		disabled = value
		if disabled:
			_pressing = false
		mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
		_apply_state()

var _pressing: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_NONE
	gui_input.connect(_on_gui_input)
	mouse_exited.connect(_on_mouse_exited)


func is_pressing() -> bool:
	return _pressing


func _apply_state() -> void:
	pass


func _set_pressing(on: bool) -> void:
	if _pressing == on:
		return
	_pressing = on
	_apply_state()


func _on_gui_input(event: InputEvent) -> void:
	if disabled or SceneRouter.is_input_blocked():
		if event is InputEventMouseButton or event is InputEventScreenTouch:
			accept_event()
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_set_pressing(true)
		else:
			var was_pressing := _pressing
			_set_pressing(false)
			if was_pressing:
				clicked.emit()
		accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_set_pressing(true)
			clicked.emit()
		else:
			_set_pressing(false)
		accept_event()


func _on_mouse_exited() -> void:
	_set_pressing(false)
