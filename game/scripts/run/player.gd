extends Area2D

signal lane_changed(new_lane: int)
signal hit_obstacle

const SWIPE_THRESHOLD := 50.0
const LANE_TWEEN_DURATION := 0.12

var lane_index: int = 1
var lane_x_positions: Array[float] = []
var _touch_start: Vector2 = Vector2.ZERO
var _touching: bool = false
var _input_enabled: bool = true
var _lane_tween: Tween
var _magnet_radius: float = 0.0

@onready var _magnet_field: Area2D = get_node_or_null("MagnetField")


func setup_lanes(positions: Array[float]) -> void:
	lane_x_positions = positions
	reset_lane()


func reset_lane() -> void:
	lane_index = 1
	_apply_lane(false)


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled


func set_magnet_radius(radius: float) -> void:
	_magnet_radius = radius
	if _magnet_field:
		var shape := _magnet_field.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape and shape.shape is CircleShape2D:
			(shape.shape as CircleShape2D).radius = radius
	queue_redraw()


func _ready() -> void:
	add_to_group("player")
	area_entered.connect(_on_area_entered)
	if _magnet_field:
		_magnet_field.area_entered.connect(_on_magnet_area_entered)


func _apply_lane(animate: bool) -> void:
	if lane_x_positions.size() < 3:
		return

	var target_x := lane_x_positions[lane_index]
	if _lane_tween and _lane_tween.is_valid():
		_lane_tween.kill()

	if not animate:
		position.x = target_x
		return

	_lane_tween = create_tween()
	_lane_tween.tween_property(self, "position:x", target_x, LANE_TWEEN_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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
		_apply_lane(true)
		lane_changed.emit(lane_index)
	elif delta.x < 0.0 and lane_index > 0:
		lane_index -= 1
		_apply_lane(true)
		lane_changed.emit(lane_index)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("orb"):
		if area.has_method("collect"):
			area.collect()
	elif area.is_in_group("obstacle"):
		hit_obstacle.emit()


func _on_magnet_area_entered(area: Area2D) -> void:
	# Magnet skuplja orbove u dometu, ali NE reagira na prepreke.
	if area.is_in_group("orb") and area.has_method("collect"):
		area.collect()


func _draw() -> void:
	if _magnet_radius > SWIPE_THRESHOLD:
		draw_arc(Vector2.ZERO, _magnet_radius, 0.0, TAU, 48, Color(0.5, 0.8, 1.0, 0.25), 3.0)
