extends Control
class_name ArenaPest

## MA-01b — Muncher pest: spava, jede T1/T2, freeze na T3.

enum State {
	SLEEPING_NEST,
	WAKE_DELAY,
	HUNTING,
	EATING,
	SLEEPING_SPOT,
	FROZEN,
}

const PEST_RADIUS := 28.0

var _state: State = State.SLEEPING_NEST
var _pest_center: Vector2 = Vector2.ZERO
var _nest_center: Vector2 = Vector2.ZERO
var _target_chip: ArenaSeedChip = null
var _eat_timer: float = 0.0
var _freeze_timer: float = 0.0
var _wake_timer: float = 0.0
var _target_reeval: float = 0.0
var _eyes_open: bool = false
var _wiggle: float = 0.0

var _get_edible_chips: Callable
var _get_keepout_rect: Callable
var _get_playfield_bounds: Callable
var _on_eat_chip: Callable


func setup(
	get_edible_chips: Callable,
	get_keepout_rect: Callable,
	get_playfield_bounds: Callable,
	on_eat_chip: Callable
) -> void:
	_get_edible_chips = get_edible_chips
	_get_keepout_rect = get_keepout_rect
	_get_playfield_bounds = get_playfield_bounds
	_on_eat_chip = on_eat_chip
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 50
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = true


func reset_to_nest() -> void:
	_state = State.SLEEPING_NEST
	_target_chip = null
	_eat_timer = 0.0
	_freeze_timer = 0.0
	_wake_timer = 0.0
	_target_reeval = 0.0
	_eyes_open = false
	_pest_center = _nest_center
	queue_redraw()


func set_nest_position(center: Vector2) -> void:
	_nest_center = center
	if _state == State.SLEEPING_NEST:
		_pest_center = center
		queue_redraw()


func on_seeds_poured(has_chips_on_field: bool) -> void:
	if not has_chips_on_field:
		return
	if _state == State.SLEEPING_NEST or _state == State.SLEEPING_SPOT:
		_state = State.WAKE_DELAY
		_wake_timer = GameState.ARENA_PEST_WAKE_DELAY
		_eyes_open = true
		queue_redraw()


func on_field_chip_count_changed(count: int) -> void:
	if count <= 0 and _state in [State.HUNTING, State.EATING, State.WAKE_DELAY]:
		_go_sleep_at_current_spot()
	elif count > 0 and _state == State.SLEEPING_SPOT:
		pass


func on_t3_created() -> void:
	_state = State.FROZEN
	_freeze_timer = GameState.ARENA_PEST_T3_FREEZE
	_target_chip = null
	_eat_timer = 0.0
	queue_redraw()


func is_active() -> bool:
	return _state != State.SLEEPING_NEST and _state != State.SLEEPING_SPOT


func tick(delta: float) -> void:
	_wiggle += delta * 6.0
	match _state:
		State.SLEEPING_NEST, State.SLEEPING_SPOT:
			pass
		State.WAKE_DELAY:
			_wake_timer -= delta
			if _wake_timer <= 0.0:
				_state = State.HUNTING
				_pick_target(true)
		State.FROZEN:
			_freeze_timer -= delta
			if _freeze_timer <= 0.0:
				var chips: Array = _get_edible_chips.call() if _get_edible_chips.is_valid() else []
				if chips.is_empty():
					_go_sleep_at_current_spot()
				else:
					_state = State.HUNTING
					_pick_target(true)
		State.HUNTING:
			_tick_hunting(delta)
		State.EATING:
			_eat_timer -= delta
			if _eat_timer <= 0.0:
				_finish_eating()
	queue_redraw()


func _tick_hunting(delta: float) -> void:
	_target_reeval -= delta
	if _target_reeval <= 0.0:
		_target_reeval = GameState.ARENA_PEST_TARGET_REEVAL
		_pick_target(false)
	if _target_chip == null or not is_instance_valid(_target_chip):
		_pick_target(true)
		if _target_chip == null:
			_go_sleep_at_current_spot()
			return
	var chip_center := _target_chip.get_center()
	var dir := chip_center - _pest_center
	var dist := dir.length()
	if dist <= GameState.ARENA_PEST_EAT_RADIUS:
		_begin_eating()
		return
	if dist > 1.0:
		dir = dir / dist
	var speed := GameState.ARENA_PEST_SPEED * delta
	var next := _pest_center + dir * speed
	next = _clamp_to_bounds(next)
	next = _avoid_keepout(next)
	_pest_center = next


func _begin_eating() -> void:
	_state = State.EATING
	_eat_timer = GameState.ARENA_PEST_EAT_DURATION
	_eyes_open = true


func _finish_eating() -> void:
	if _target_chip != null and is_instance_valid(_target_chip):
		if _on_eat_chip.is_valid():
			_on_eat_chip.call(_target_chip)
	_target_chip = null
	var chips: Array = _get_edible_chips.call() if _get_edible_chips.is_valid() else []
	if chips.is_empty():
		_go_sleep_at_current_spot()
	else:
		_state = State.HUNTING
		_pick_target(true)


func _go_sleep_at_current_spot() -> void:
	_state = State.SLEEPING_SPOT
	_target_chip = null
	_eat_timer = 0.0
	_eyes_open = false


func _pick_target(force: bool) -> void:
	if not force and _target_chip != null and is_instance_valid(_target_chip):
		return
	var chips: Array = _get_edible_chips.call() if _get_edible_chips.is_valid() else []
	if chips.is_empty():
		_target_chip = null
		return
	var best: ArenaSeedChip = null
	var best_score := INF
	for raw in chips:
		var chip := raw as ArenaSeedChip
		if chip == null or not is_instance_valid(chip):
			continue
		var dist := _pest_center.distance_to(chip.get_center())
		var tier_bias := 0.0 if chip.tier >= 2 else 12.0
		var score := dist + tier_bias
		if score < best_score:
			best_score = score
			best = chip
	_target_chip = best


func _clamp_to_bounds(center: Vector2) -> Vector2:
	if not _get_playfield_bounds.is_valid():
		return center
	var bounds: Rect2 = _get_playfield_bounds.call()
	var r := PEST_RADIUS
	return Vector2(
		clampf(center.x, bounds.position.x + r, bounds.position.x + bounds.size.x - r),
		clampf(center.y, bounds.position.y + r, bounds.position.y + bounds.size.y - r)
	)


func _avoid_keepout(center: Vector2) -> Vector2:
	if not _get_keepout_rect.is_valid():
		return center
	var zone: Rect2 = _get_keepout_rect.call()
	if zone.size.x < 1.0 or not zone.has_point(center):
		return center
	var zone_center := zone.get_center()
	var dir := center - zone_center
	if dir.length_squared() < 1.0:
		dir = Vector2(0.0, -1.0)
	else:
		dir = dir.normalized()
	var push := maxf(zone.size.x, zone.size.y) * 0.45 + PEST_RADIUS
	return _clamp_to_bounds(zone_center + dir * push)


func _draw() -> void:
	var bob := sin(_wiggle) * 2.0 if _eyes_open else 0.0
	var center := _pest_center + Vector2(0.0, bob)
	var body_color := Color(0.55, 0.38, 0.72, 1.0)
	if _state == State.FROZEN:
		body_color = Color(0.65, 0.82, 0.98, 1.0)
	elif not _eyes_open:
		body_color = Color(0.48, 0.34, 0.62, 1.0)
	draw_circle(center, PEST_RADIUS, body_color)
	draw_arc(center, PEST_RADIUS, 0.0, TAU, 32, Color(0.28, 0.18, 0.38, 0.35), 2.0, true)
	if _eyes_open:
		draw_circle(center + Vector2(-9.0, -4.0), 5.0, Color(1.0, 1.0, 1.0, 0.95))
		draw_circle(center + Vector2(9.0, -4.0), 5.0, Color(1.0, 1.0, 1.0, 0.95))
		draw_circle(center + Vector2(-9.0, -4.0), 2.5, Color(0.12, 0.1, 0.18, 1.0))
		draw_circle(center + Vector2(9.0, -4.0), 2.5, Color(0.12, 0.1, 0.18, 1.0))
	else:
		draw_line(center + Vector2(-10.0, -2.0), center + Vector2(-4.0, -2.0), Color(0.2, 0.14, 0.28, 0.8), 2.0)
		draw_line(center + Vector2(4.0, -2.0), center + Vector2(10.0, -2.0), Color(0.2, 0.14, 0.28, 0.8), 2.0)
	if _state == State.EATING:
		draw_circle(center + Vector2(0.0, 8.0), 6.0, Color(0.95, 0.45, 0.55, 0.85))
