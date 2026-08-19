extends Control
class_name SwipePager

## Horizontal swipe pager — Clash Royale style snap between full-width pages.

signal page_changed(index: int)
signal swipe_enabled_changed(enabled: bool)

const SWIPE_THRESHOLD_RATIO := 0.18
const SWIPE_VELOCITY_THRESHOLD := 320.0
const SNAP_DURATION := 0.28
const DEFAULT_PAGE_COUNT := 5
const DEFAULT_START_PAGE := 1
const SWIPE_AXIS_LOCK_PX := 20.0
const SWIPE_AXIS_DOMINANCE := 1.15
const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"

@export var page_count: int = DEFAULT_PAGE_COUNT
@export var start_page: int = DEFAULT_START_PAGE

var current_page: int = DEFAULT_START_PAGE

var _page_width: float = 0.0
var _drag_offset: float = 0.0
var _dragging: bool = false
var _drag_start_x: float = 0.0
var _drag_start_offset: float = 0.0
var _last_drag_x: float = 0.0
var _last_drag_time: float = 0.0
var _prev_drag_x: float = 0.0
var _prev_drag_time: float = 0.0
var _swipe_enabled: bool = true
var _snap_tween: Tween = null
var _touch_active: bool = false
var _swipe_gesture: bool = false
var _gesture_start: Vector2 = Vector2.ZERO

@onready var _pages_host: Control = $PagesHost


func _ready() -> void:
	current_page = clampi(start_page, 0, page_count - 1)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_on_resized)
	if _pages_host:
		_pages_host.resized.connect(_on_resized)
	call_deferred("_on_resized")


func set_swipe_enabled(enabled: bool) -> void:
	if _swipe_enabled == enabled:
		return
	_swipe_enabled = enabled
	if not enabled:
		_reset_gesture()
		_dragging = false
		_drag_offset = 0.0
		_apply_offset()
	swipe_enabled_changed.emit(enabled)


func is_swipe_enabled() -> bool:
	return _swipe_enabled


func get_pages_host() -> Control:
	return _pages_host


## Public align helper (smoke + callers) — never leave host between pages.
func ensure_aligned(animated: bool = false) -> void:
	_ensure_page_aligned(animated)


func go_to_page(index: int, animated: bool = true) -> void:
	index = clampi(index, 0, page_count - 1)
	if index == current_page and _drag_offset == 0.0 and not _dragging:
		# Mid-tween kill can leave host.x off base while drag_offset is 0.
		if _pages_host != null and _page_width >= 1.0:
			if absf(_pages_host.position.x - _get_base_offset()) > 0.5:
				_ensure_page_aligned(animated)
		return
	current_page = index
	_snap_to_page(animated)
	page_changed.emit(current_page)


func notify_pages_changed() -> void:
	_on_resized()


func _on_resized() -> void:
	_page_width = size.x
	if _page_width < 1.0:
		return
	if _pages_host:
		_pages_host.custom_minimum_size = Vector2(_page_width * page_count, size.y)
		_layout_page_slots()
	_apply_offset()


func _layout_page_slots() -> void:
	if _pages_host == null or _page_width < 1.0:
		return
	for i in _pages_host.get_child_count():
		var child := _pages_host.get_child(i) as Control
		if child == null:
			continue
		child.custom_minimum_size = Vector2(_page_width, size.y)
		child.size = Vector2(_page_width, size.y)
		child.position = Vector2(_page_width * i, 0.0)


func _get_base_offset() -> float:
	return -float(current_page) * _page_width


func _apply_offset() -> void:
	if _pages_host == null or _page_width < 1.0:
		return
	_pages_host.position.x = _get_base_offset() + _drag_offset


func _capture_host_offset() -> void:
	if _pages_host == null or _page_width < 1.0:
		_drag_offset = 0.0
		return
	_drag_offset = _pages_host.position.x - _get_base_offset()


func _ensure_page_aligned(animated: bool = true) -> void:
	_drag_offset = 0.0
	_snap_to_page(animated)


func _snap_to_page(animated: bool) -> void:
	_kill_snap_tween()
	_drag_offset = 0.0
	if not animated or _page_width < 1.0:
		_apply_offset()
		return
	var target_x := _get_base_offset()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	_snap_tween = tween
	tween.tween_property(_pages_host, "position:x", target_x, SNAP_DURATION)


func _kill_snap_tween() -> void:
	if _snap_tween != null and _snap_tween.is_valid():
		_snap_tween.kill()
	_snap_tween = null


func _cancel_active_pointer() -> void:
	if not _touch_active:
		_reset_gesture()
		return
	_ensure_page_aligned(true)
	_reset_gesture()


func _is_pointer_inside(pos: Vector2) -> bool:
	return get_global_rect().has_point(pos)


func should_block_hub_swipe_at(pos: Vector2) -> bool:
	var tree := get_tree()
	if tree == null:
		return false
	for node in tree.get_nodes_in_group(BLOCK_HUB_SWIPE_GROUP):
		var ctrl := node as Control
		if ctrl == null or not ctrl.is_visible_in_tree():
			continue
		if ctrl.get_global_rect().has_point(pos):
			return true
	return false


func _input(event: InputEvent) -> void:
	if not _swipe_enabled or _page_width < 1.0:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_drag(event as InputEventScreenDrag)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event as InputEventMouseMotion)


func _handle_touch(touch: InputEventScreenTouch) -> void:
	if not _is_pointer_inside(touch.position):
		if not touch.pressed:
			_cancel_active_pointer()
		return
	if touch.pressed:
		if should_block_hub_swipe_at(touch.position):
			return
		_start_pointer(touch.position.x, touch.position)
	else:
		_finish_pointer(touch.position.x)


func _handle_drag(drag: InputEventScreenDrag) -> void:
	if not _touch_active:
		return
	_update_pointer(drag.position.x, drag.position)


func _handle_mouse_button(mouse: InputEventMouseButton) -> void:
	if mouse.button_index != MOUSE_BUTTON_LEFT:
		return
	if not _is_pointer_inside(mouse.position):
		if not mouse.pressed:
			_cancel_active_pointer()
		return
	if mouse.pressed:
		if should_block_hub_swipe_at(mouse.position):
			return
		_start_pointer(mouse.position.x, mouse.position)
	else:
		_finish_pointer(mouse.position.x)


func _handle_mouse_motion(motion: InputEventMouseMotion) -> void:
	if not _touch_active or (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
		return
	_update_pointer(motion.position.x, motion.position)


func _start_pointer(x: float, pos: Vector2) -> void:
	_kill_snap_tween()
	_capture_host_offset()
	_touch_active = true
	_swipe_gesture = false
	_gesture_start = pos
	_dragging = false
	_drag_start_x = x
	_drag_start_offset = _drag_offset
	_last_drag_x = x
	_prev_drag_x = x
	var now := Time.get_ticks_msec() / 1000.0
	_last_drag_time = now
	_prev_drag_time = now


func _update_pointer(x: float, pos: Vector2) -> void:
	if not _touch_active:
		return
	if not _swipe_gesture:
		var delta := pos - _gesture_start
		if absf(delta.x) < SWIPE_AXIS_LOCK_PX and absf(delta.y) < SWIPE_AXIS_LOCK_PX:
			return
		if absf(delta.x) >= absf(delta.y) * SWIPE_AXIS_DOMINANCE:
			_swipe_gesture = true
			_dragging = true
			_drag_start_x = _gesture_start.x
			_drag_start_offset = _drag_offset
		else:
			_ensure_page_aligned(true)
			_reset_gesture()
			return
	var now := Time.get_ticks_msec() / 1000.0
	_prev_drag_x = _last_drag_x
	_prev_drag_time = _last_drag_time
	_last_drag_x = x
	_last_drag_time = now
	var move_delta := x - _drag_start_x
	_drag_offset = _drag_start_offset + move_delta
	if current_page <= 0 and _drag_offset > 0.0:
		_drag_offset *= 0.35
	elif current_page >= page_count - 1 and _drag_offset < 0.0:
		_drag_offset *= 0.35
	_apply_offset()
	get_viewport().set_input_as_handled()


func _finish_pointer(_x: float) -> void:
	if _swipe_gesture and _dragging:
		_end_drag()
		get_viewport().set_input_as_handled()
	else:
		_ensure_page_aligned(true)
	_reset_gesture()


func _reset_gesture() -> void:
	_touch_active = false
	_swipe_gesture = false
	_dragging = false


func _end_drag() -> void:
	if not _dragging:
		return
	_dragging = false
	var velocity := 0.0
	var dt := _last_drag_time - _prev_drag_time
	if dt > 0.0 and dt < 0.25:
		velocity = (_last_drag_x - _prev_drag_x) / dt
	var threshold := _page_width * SWIPE_THRESHOLD_RATIO
	var next_page := current_page
	if absf(_drag_offset) > threshold or absf(velocity) > SWIPE_VELOCITY_THRESHOLD:
		if _drag_offset < 0.0 or velocity < -SWIPE_VELOCITY_THRESHOLD:
			next_page = mini(current_page + 1, page_count - 1)
		elif _drag_offset > 0.0 or velocity > SWIPE_VELOCITY_THRESHOLD:
			next_page = maxi(current_page - 1, 0)
	current_page = next_page
	_drag_offset = 0.0
	_snap_to_page(true)
	page_changed.emit(current_page)
