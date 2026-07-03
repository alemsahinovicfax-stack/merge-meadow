extends Area2D

signal lane_changed(new_lane: int)
signal hit_obstacle

const SWIPE_THRESHOLD := 50.0

var lane_index: int = 1
var lane_x_positions: Array[float] = []
var _touch_start: Vector2 = Vector2.ZERO
var _touching: bool = false
var _input_enabled: bool = true


func setup_lanes(positions: Array[float]) -> void:
	lane_x_positions = positions
	reset_lane()


func reset_lane() -> void:
	lane_index = 1
	_apply_lane()


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled


func _ready() -> void:
	add_to_group("player")
	area_entered.connect(_on_area_entered)


func _apply_lane() -> void:
	if lane_x_positions.size() >= 3:
		position.x = lane_x_positions[lane_index]


func _input(event: InputEvent) -> void:
	if not _input_enabled:
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_touch_start = touch.position
			_touching = true
		elif _touching:
			_handle_swipe(touch.position)
			_touching = false
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_touch_start = mouse.position
			_touching = true
		elif _touching:
			_handle_swipe(mouse.position)
			_touching = false


func _handle_swipe(end_pos: Vector2) -> void:
	var delta := end_pos - _touch_start
	if absf(delta.x) < SWIPE_THRESHOLD:
		return
	if absf(delta.x) < absf(delta.y):
		return
	if delta.x > 0.0 and lane_index < 2:
		lane_index += 1
		_apply_lane()
		lane_changed.emit(lane_index)
	elif delta.x < 0.0 and lane_index > 0:
		lane_index -= 1
		_apply_lane()
		lane_changed.emit(lane_index)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("orb"):
		if area.has_method("collect"):
			area.collect()
	elif area.is_in_group("obstacle"):
		hit_obstacle.emit()
