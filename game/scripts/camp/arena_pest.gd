extends Control
class_name ArenaPest

## MA-01b — Muncher pest: spava, jede T1/T2, freeze na T3.
## Vizual (smjer B, design_handoff_merge_arena): 104 px, usi, oci/usta po stanju, ledena
## heksagonalna ljuska, zzz, gnijezdo 210 x 104 — svako stanje razlucivo i bez boje.

enum State {
	SLEEPING_NEST,
	WAKE_DELAY,
	HUNTING,
	EATING,
	SLEEPING_SPOT,
	FROZEN,
}

## Vizuelni radius (clamp u polje). Jedenje ide po GameState.ARENA_PEST_EAT_RADIUS od centra.
const PEST_RADIUS := UiArena.MUNCHER_VISUAL_R
const BODY_EDGE_W := 4.0
const EAR_R := 15.0
const EAR_OFFSET := Vector2(27.0, -51.0)
const EYE_Y := -7.0
const EYE_DX := 17.0
const EYE_OPEN_D := 14.0
const EYE_WAKE_D := 18.0
const EYE_SLEEP := Vector2(20.0, 5.0)
const EYE_SLEEP_DX := 20.0
const MOUTH_EAT := Rect2(-19.0, 8.0, 38.0, 28.0)
const MOUTH_IDLE := Rect2(-9.0, 14.0, 18.0, 9.0)
const BOB_PERIOD := 0.6
const BOB_AMP := 5.0
const HUNT_TILT := -0.105  # -6°
const CHOMP_PERIOD := 0.25  # 2 x u 0,5 s
const FREEZE_IN_SEC := 0.18
const FREEZE_OUT_SEC := 0.25
const ZZZ_OFFSET := Vector2(44.0, -60.0)
const ZZZ_FONT_SIZE := 32
const NEST_EDGE_W := 5.0
const NEST_INNER_EDGE_W := 4.0

var _state: State = State.SLEEPING_NEST
var _pest_center: Vector2 = Vector2.ZERO
var _nest_center: Vector2 = Vector2.ZERO
var _target_chip: ArenaSeedChip = null
var _eat_timer: float = 0.0
var _freeze_timer: float = 0.0
var _wake_timer: float = 0.0
var _target_reeval: float = 0.0
var _bob_t: float = 0.0
var _chomp_t: float = 0.0
var _shell: float = 0.0
var _shell_tween: Tween = null

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
	_release_target()
	_state = State.SLEEPING_NEST
	_eat_timer = 0.0
	_freeze_timer = 0.0
	_wake_timer = 0.0
	_target_reeval = 0.0
	_set_shell(0.0)
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
		queue_redraw()


func on_field_chip_count_changed(count: int) -> void:
	if count <= 0 and _state in [State.HUNTING, State.EATING, State.WAKE_DELAY]:
		_go_sleep_at_current_spot()


func on_t3_created() -> void:
	_release_target()
	_state = State.FROZEN
	_freeze_timer = GameState.ARENA_PEST_T3_FREEZE
	_eat_timer = 0.0
	_tween_shell(1.0, FREEZE_IN_SEC, Tween.TRANS_BACK, Tween.EASE_OUT)
	queue_redraw()


func is_active() -> bool:
	return _state != State.SLEEPING_NEST and _state != State.SLEEPING_SPOT


func tick(delta: float) -> void:
	_bob_t += delta
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
				_tween_shell(0.0, FREEZE_OUT_SEC, Tween.TRANS_CUBIC, Tween.EASE_IN)
				var chips: Array = _get_edible_chips.call() if _get_edible_chips.is_valid() else []
				if chips.is_empty():
					_go_sleep_at_current_spot()
				else:
					_state = State.HUNTING
					_pick_target(true)
		State.HUNTING:
			_tick_hunting(delta)
		State.EATING:
			_chomp_t += delta
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
	_chomp_t = 0.0
	if _target_chip != null and is_instance_valid(_target_chip):
		_target_chip.set_being_eaten(true)


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
	_release_target()
	_state = State.SLEEPING_SPOT
	_eat_timer = 0.0


## Plijen koji je prezivio (freeze, reset) vraca se u normalu.
func _release_target() -> void:
	if _target_chip != null and is_instance_valid(_target_chip) and _target_chip.is_being_eaten():
		_target_chip.set_being_eaten(false)
	_target_chip = null


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
	var asleep := _state == State.SLEEPING_NEST or _state == State.SLEEPING_SPOT
	var at_nest := _pest_center.distance_to(_nest_center) < 1.0
	if _state == State.SLEEPING_NEST or (_state == State.WAKE_DELAY and at_nest):
		_draw_nest()
	var hunting := _state == State.HUNTING
	var bob := sin(_bob_t * TAU / BOB_PERIOD) * BOB_AMP if hunting else 0.0
	var center := _pest_center + Vector2(0.0, bob)
	var body := UiArena.MUNCHER_AWAKE
	var edge := UiArena.MUNCHER_AWAKE_EDGE
	if _state == State.FROZEN:
		body = UiArena.MUNCHER_FROZEN
		edge = UiArena.MUNCHER_FROZEN_EDGE
	elif asleep:
		body = UiArena.MUNCHER_ASLEEP
		edge = UiArena.MUNCHER_ASLEEP_EDGE
	draw_set_transform(center, HUNT_TILT if hunting else 0.0, Vector2.ONE)
	draw_circle(Vector2.ZERO, PEST_RADIUS, body)
	draw_arc(Vector2.ZERO, PEST_RADIUS - BODY_EDGE_W * 0.5, 0.0, TAU, 48, edge, BODY_EDGE_W, true)
	for side in [-1.0, 1.0]:
		var ear := Vector2(EAR_OFFSET.x * side, EAR_OFFSET.y)
		draw_circle(ear, EAR_R, body)
		draw_arc(ear, EAR_R - BODY_EDGE_W * 0.5, 0.0, TAU, 24, edge, BODY_EDGE_W, true)
	_draw_face(asleep)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _shell > 0.001:
		_draw_frost_shell(center)
	if asleep:
		draw_string(
			UiChrome.heavy_font(UiChrome.EMBOLDEN_800), center + ZZZ_OFFSET, "z z z",
			HORIZONTAL_ALIGNMENT_LEFT, -1, ZZZ_FONT_SIZE, UiPalette.WARM_WHITE
		)


func _draw_face(asleep: bool) -> void:
	var ink := UiPalette.OUTLINE
	if asleep:
		for side in [-1.0, 1.0]:
			var c := Vector2(EYE_SLEEP_DX * side, EYE_Y)
			draw_rect(Rect2(c - EYE_SLEEP * 0.5, EYE_SLEEP), ink)
	else:
		var d := EYE_WAKE_D if _state == State.WAKE_DELAY else EYE_OPEN_D
		for side in [-1.0, 1.0]:
			draw_circle(Vector2(EYE_DX * side, EYE_Y), d * 0.5, ink)
	var mouth := StyleBoxFlat.new()
	mouth.corner_detail = 10
	if _state == State.EATING:
		var open := 0.45 + 0.55 * absf(sin(_chomp_t * PI / CHOMP_PERIOD))
		var rect := Rect2(MOUTH_EAT.position, Vector2(MOUTH_EAT.size.x, MOUTH_EAT.size.y * open))
		mouth.bg_color = UiArena.MOUTH
		mouth.border_color = UiArena.MOUTH_EDGE
		mouth.set_border_width_all(3)
		mouth.corner_radius_bottom_left = 17
		mouth.corner_radius_bottom_right = 17
		draw_style_box(mouth, rect)
	else:
		mouth.bg_color = UiArena.MUNCHER_MOUTH_IDLE
		mouth.corner_radius_bottom_left = 8
		mouth.corner_radius_bottom_right = 8
		draw_style_box(mouth, MOUTH_IDLE)


func _draw_frost_shell(center: Vector2) -> void:
	var r := UiArena.FROST_SHELL_R * (0.8 + 0.2 * _shell)
	var hex := PackedVector2Array()
	for p in [
		Vector2(0.0, -1.0), Vector2(0.86, -0.5), Vector2(0.86, 0.5),
		Vector2(0.0, 1.0), Vector2(-0.86, 0.5), Vector2(-0.86, -0.5),
	]:
		hex.append(center + p * r)
	draw_colored_polygon(hex, Color(UiArena.FROST_SHELL, UiArena.FROST_SHELL.a * _shell))
	var outline := hex.duplicate()
	outline.append(hex[0])
	draw_polyline(outline, Color(UiArena.FROST_SHELL_EDGE, _shell), 4.0, true)


func _draw_nest() -> void:
	var outer := UiArena.NEST_SIZE
	_draw_ellipse(_nest_center, outer * 0.5, UiArena.NEST, UiArena.NEST_EDGE, NEST_EDGE_W)
	# CSS inset 14 / 18 / 8 unutar 210 x 104.
	var inner := Vector2(outer.x - 36.0, outer.y - 22.0)
	var inner_c := _nest_center + Vector2(0.0, (14.0 - 8.0) * 0.5)
	_draw_ellipse(inner_c, inner * 0.5, UiArena.NEST_INNER, UiArena.NEST_INNER_EDGE, NEST_INNER_EDGE_W)


func _draw_ellipse(c: Vector2, radii: Vector2, fill: Color, edge: Color, edge_w: float) -> void:
	var pts := PackedVector2Array()
	for i in 40:
		var a := TAU * float(i) / 40.0
		pts.append(c + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, fill)
	var outline := pts.duplicate()
	outline.append(pts[0])
	draw_polyline(outline, edge, edge_w, true)


func _tween_shell(target: float, sec: float, trans: Tween.TransitionType, ease_type: Tween.EaseType) -> void:
	if not is_inside_tree():
		_set_shell(target)
		return
	if _shell_tween != null and _shell_tween.is_valid():
		_shell_tween.kill()
	_shell_tween = create_tween()
	_shell_tween.tween_method(_set_shell, _shell, target, sec).set_trans(trans).set_ease(ease_type)


func _set_shell(value: float) -> void:
	_shell = value
	queue_redraw()
