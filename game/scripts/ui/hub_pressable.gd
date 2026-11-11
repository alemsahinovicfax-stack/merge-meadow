class_name HubPressable
extends Control

## Klik-zona hub chromea (tab, Settings) — isti input obrazac kao UiClickButton
## (BaseButton lomi klik na desktopu, greske-katalog #5): touch klikne na pritisak, miš na otpuštanje.
## Podklasa crta stanje u _apply_state().

signal clicked

## Zvuk tapa (AudioManager id); "" = bez — dugme čija radnja pušta svoj zvuk (kupovina, Play).
var tap_sfx: String = "ui_tap"

var disabled: bool = false:
	set(value):
		disabled = value
		if disabled:
			_pressing = false
		mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
		_apply_state()

const DRAG_SCROLL := preload("res://scripts/ui/drag_scroll.gd")

var _pressing: bool = false
## Dugme u ScrollContaineru: dodir prolazi do skrola, tap tek na puštanje (DragScroll.in_scroll).
var _in_scroll: bool = false
var _touch_travel: float = 0.0
## Prst je dolje na dugmetu u skrolu. Odvojeno od _pressing: mouse_exited (raspored se
## pomjeri, emulirani miš) gasi _pressing usred dodira, a tap se ne smije izgubiti.
var _touch_down: bool = false


func _ready() -> void:
	_in_scroll = DRAG_SCROLL.in_scroll(self)
	mouse_filter = Control.MOUSE_FILTER_PASS if _in_scroll else Control.MOUSE_FILTER_STOP
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
		if event is InputEventMouseButton or (event is InputEventScreenTouch and not _in_scroll):
			accept_event()
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		# Telefon (emulate_mouse_from_touch): emulirani miš stiže prije touch-a — klik ide samo kroz touch.
		if mouse.device == InputEvent.DEVICE_ID_EMULATION:
			accept_event()
			return
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_set_pressing(true)
		else:
			var was_pressing := _pressing
			_set_pressing(false)
			if was_pressing:
				_emit_clicked()
		accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if _in_scroll:
			# Bez accept_event: isti dodir mora stići do ScrollContainera.
			if touch.pressed:
				_touch_travel = 0.0
				_touch_down = true
				_set_pressing(true)
			else:
				var was_down := _touch_down
				_touch_down = false
				_set_pressing(false)
				if was_down:
					_emit_clicked()
			return
		if touch.pressed:
			_set_pressing(true)
			_emit_clicked()
		else:
			_set_pressing(false)
		accept_event()
	elif event is InputEventScreenDrag and _in_scroll and _touch_down:
		_touch_travel += (event as InputEventScreenDrag).relative.length()
		if _touch_travel > DRAG_SCROLL.TAP_SLOP:
			cancel_press()


func _on_mouse_exited() -> void:
	_set_pressing(false)


## TouchScroller: gesta je postala skrol — dugme pod prstom ne klikne.
func cancel_press() -> void:
	_touch_down = false
	_set_pressing(false)


## Podklasa može birati zvuk po stanju (ShopBuyButton).
func _tap_sound() -> String:
	return tap_sfx


func _emit_clicked() -> void:
	var s := _tap_sound()
	if not s.is_empty():
		Sfx.play(s)
	clicked.emit()
