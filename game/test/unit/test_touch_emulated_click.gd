## Telefon (emulate_mouse_from_touch): Godot uz svaki dodir pošalje i emulirani miš
## (`device = DEVICE_ID_EMULATION`), i to PRIJE touch eventa — greske-katalog #60.
## Jedan tap smije kliknuti tačno jednom; pravi miš i čisti touch rade kao prije.
extends GutTest

const PHONE := "phone"
const MOUSE := "mouse"
const TOUCH := "touch"


func before_each() -> void:
	SceneRouter.set("_input_block_until_msec", 0)


func _mouse(pressed: bool, emulated: bool) -> InputEventMouseButton:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = pressed
	ev.position = Vector2(20, 20)
	ev.global_position = ev.position
	if emulated:
		ev.device = InputEvent.DEVICE_ID_EMULATION
	return ev


func _touch(pressed: bool) -> InputEventScreenTouch:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.pressed = pressed
	ev.position = Vector2(20, 20)
	return ev


## Redoslijed kao `Input::_parse_input_event_impl`: emulirani miš ide prije svog touch-a.
func _events(kind: String) -> Array[InputEvent]:
	match kind:
		PHONE:
			return [_mouse(true, true), _touch(true), _mouse(false, true), _touch(false)]
		MOUSE:
			return [_mouse(true, false), _mouse(false, false)]
	return [_touch(true), _touch(false)]


func _tap(ctrl: Control, kind: String) -> void:
	for ev in _events(kind):
		ctrl.gui_input.emit(ev)


func _assert_one_click(make: Callable, sig: String) -> void:
	for kind: String in [PHONE, MOUSE, TOUCH]:
		var ctrl: Control = make.call()
		add_child_autofree(ctrl)
		watch_signals(ctrl)
		_tap(ctrl, kind)
		assert_signal_emit_count(ctrl, sig, 1, "%s: %s tap" % [ctrl.get_class(), kind])


func test_hub_pressable_one_click_per_tap() -> void:
	_assert_one_click(func() -> Control: return HubPressable.new(), "clicked")


func test_ui_click_button_one_click_per_tap() -> void:
	_assert_one_click(func() -> Control: return UiClickButton.new(), "clicked")


func test_ui_click_button_hold_one_click_and_release() -> void:
	for kind: String in [PHONE, MOUSE, TOUCH]:
		var b := UiClickButton.new()
		b.auto_repeat = true
		add_child_autofree(b)
		watch_signals(b)
		_tap(b, kind)
		assert_signal_emit_count(b, "clicked", 1, "%s tap" % kind)
		assert_signal_emit_count(b, "press_ended", 1, "%s release ends hold" % kind)
		assert_false(b.is_holding(), "%s: no hold after release" % kind)


func test_field_tiles_one_click_per_tap() -> void:
	_assert_one_click(func() -> Control: return FieldBasketButton.new(), "clicked")
	_assert_one_click(func() -> Control: return FieldUpgradesButton.new(), "clicked")


func test_arena_seed_bag_one_click_per_tap() -> void:
	_assert_one_click(func() -> Control: return ArenaSeedBag.new(), "bag_clicked")
