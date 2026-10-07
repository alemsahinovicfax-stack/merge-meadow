extends Control
class_name ArenaPest

## MA-01b — Muncher pest: spava, jede T1/T2, freeze na T3.
## Vizual (Arena v2, design_handoff_arena_v2 § Muncher): ljubicasta gusjenica sa zutim pjegama —
## glava r 50 (centar = centar jedenja) + 3 segmenta koji prate put glave. Stanja se citaju
## pozom: sklupcana + zzz · rep gore + „!" · ispruzena + obrve V · usta sirom + mrvice · kocka leda.

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
const EDGE_W := UiArenaV2.MUNCHER_EDGE_W
const HEAD_R := UiArenaV2.MUNCHER_HEAD_R
const BOB_PERIOD := 0.6
const BOB_AMP := 5.0
const CHOMP_PERIOD := 0.25  # 2 x u 0,5 s
const FREEZE_IN_SEC := 0.18
const FREEZE_OUT_SEC := 0.25
const SHADOW_DROP := 6.0
## Spava U gnijezdu: segmenti sklupčani unutar vanjskog ruba gnijezda (250 x 112), pa prednji
## rub pokrije donji dio tijela. Poza „sleep" iz paketa (y +56 / +64) bi virila ispod gnijezda
## (playtest 2026-10-06); van gnijezda (SLEEPING_SPOT) ostaje poza iz paketa.
const NEST_SLEEP_SEGS: Array[Vector2] = [Vector2(-62, 6), Vector2(-44, 16), Vector2(4, 26)]
## Segmenti prate glavu (lanac); ovoliko brzo sustizu cilj poze.
const SEG_FOLLOW := 14.0
const WAVE_WEIGHTS: Array[float] = [0.5, -0.8, 1.0]
const ANTENNA_BASE_X := 16.0
const ANTENNA_BASE_Y := -40.0
const ANTENNA_W := 7.0
const BULB_R := 9.0
const EYE_CX := 19.0
const EYE_CY := -13.0
const LOOK_PX := 4.0
const ASLEEP_SPOT := Color("#EADB9E")
const ALARM_OFFSET := Vector2(-70.0, -46.0)
const ALARM_SIZE := 64.0
const ALARM_STAR := [
	[50, 0], [62, 30], [96, 22], [72, 50], [96, 78], [62, 70],
	[50, 100], [38, 70], [4, 78], [28, 50], [4, 22], [38, 30],
]
const CRUMBS := [[-56, 40, "#FFCCD5", 30], [46, 48, "#FFEAA7", -20], [-8, 70, "#B8E0F5", 60]]
const ICE_SIZE := Vector2(200, 170)

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
var _segs: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var _dir: Vector2 = Vector2(cos(deg_to_rad(200.0)), sin(deg_to_rad(200.0)))
var _colors: Dictionary = {}
var _drawn_pose: String = ""
var _boxes: Dictionary = {}
var _ice_box: StyleBoxFlat = null
var _ice_rim: StyleBoxFlat = null

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
	_snap_segments()
	queue_redraw()


func set_nest_position(center: Vector2) -> void:
	_nest_center = center
	if _state == State.SLEEPING_NEST:
		_pest_center = center
		_snap_segments()
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
	var moved := _update_segments(delta)
	# Crtez se obnavlja samo kad se nesto vidljivo mijenja: kretanje/jedenje, segmenti koji se
	# jos namjestaju ili nova poza. Usnuli ili zaleđeni muncher ne trosi frejm.
	var key := get_pose_key()
	if moved or key != _drawn_pose or _state == State.HUNTING or _state == State.EATING:
		_drawn_pose = key
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
	if next.distance_squared_to(_pest_center) > 0.0001:
		_dir = (next - _pest_center).normalized()
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


## Kljuc poze u UiArenaV2.MUNCHER_POSES.
func get_pose_key() -> String:
	match _state:
		State.SLEEPING_NEST, State.SLEEPING_SPOT:
			return "sleep"
		State.WAKE_DELAY:
			return "wake"
		State.EATING:
			return "eat"
		State.FROZEN:
			return "frozen"
	return "hunt"


func get_segment_positions() -> Array[Vector2]:
	return _segs.duplicate()


func _snap_segments() -> void:
	for k in 3:
		_segs[k] = _pest_center + _sleep_seg(k)


## U gnijezdu (spava ili se tek budi na njemu) — tijelo je „u rupi".
func _in_nest() -> bool:
	var at_nest := _pest_center.distance_to(_nest_center) < 1.0
	return _state == State.SLEEPING_NEST or (_state == State.WAKE_DELAY and at_nest)


func _sleep_seg(k: int) -> Vector2:
	if _state == State.SLEEPING_NEST:
		return NEST_SLEEP_SEGS[k]
	return _v(UiArenaV2.MUNCHER_POSES["sleep"]["segs"][k])


## Sleep/wake: fiksni pomaci poze. Hunt/eat: lanac — svaki segment na razmaku od prethodnog,
## pa tijelo prati put glave. Frozen: tijelo stoji.
## Vraca true ako se neki segment pomjerio vise od 0,05 px (treba novi crtez).
func _update_segments(delta: float) -> bool:
	var key := get_pose_key()
	if key == "frozen":
		return false
	var before := _segs.duplicate()
	var pose: Dictionary = UiArenaV2.MUNCHER_POSES[key]
	var follow := 1.0 - exp(-SEG_FOLLOW * delta)
	if pose.has("segs"):
		for k in 3:
			var target := _pest_center + (_sleep_seg(k) if key == "sleep" else _v(pose["segs"][k]))
			_segs[k] = target if _segs[k].distance_squared_to(target) < 0.0025 else _segs[k].lerp(target, follow)
		return _segs_moved(before)
	var spacing: Array = pose["spacing"]
	var prev := _pest_center
	var prev_d := 0.0
	for k in 3:
		var gap := float(spacing[k]) - prev_d
		var v := _segs[k] - prev
		if v.length_squared() < 0.01:
			v = -_dir
		var target := prev + v.normalized() * gap
		_segs[k] = _segs[k].lerp(target, follow) if key == "eat" else target
		prev = _segs[k]
		prev_d = float(spacing[k])
	return _segs_moved(before)


func _segs_moved(before: Array[Vector2]) -> bool:
	for k in 3:
		if _segs[k].distance_squared_to(before[k]) > 0.0025:
			return true
	return false


func _draw() -> void:
	if _colors.is_empty():
		for k in UiArenaV2.MUNCHER_COLORS:
			_colors[k] = UiArenaV2.col(str(UiArenaV2.MUNCHER_COLORS[k]))
	var key := get_pose_key()
	var pose: Dictionary = UiArenaV2.MUNCHER_POSES[key]
	var in_nest := _in_nest()
	var bob := sin(_bob_t * TAU / BOB_PERIOD) * BOB_AMP if key == "hunt" else 0.0
	var off := Vector2(0.0, bob)
	var head := _pest_center + off
	var body: Color = _colors["body"]
	var deep: Color = _colors["body_deep"]
	var edge: Color = _colors["edge"]
	var spot: Color = _colors["spot"]
	if key == "frozen":
		body = _colors["frozen_body"]
		deep = _colors["frozen_deep"]
		edge = _colors["frozen_edge"]
		spot = _colors["frozen_spot"]
	elif key == "sleep":
		body = _colors["asleep_body"]
		deep = _colors["asleep_deep"]
		edge = _colors["asleep_edge"]
		spot = ASLEEP_SPOT
	if in_nest:
		_draw_nest_back(_nest_center)
	var segs: Array[Vector2] = []
	var perp := Vector2(-_dir.y, _dir.x)
	var wave := float(pose.get("wave", 0.0)) * cos(_bob_t * TAU / BOB_PERIOD)
	for k in 3:
		segs.append(_segs[k] + off + perp * wave * WAVE_WEIGHTS[k])
	var sc := float(pose.get("head_scale", 1.0))
	# U gnijezdu nema sjene na tlu — tijelo je u rupi (sjena bi virila ispod ruba).
	if not in_nest:
		var shadow: Color = _colors["shadow"]
		for k in range(2, -1, -1):
			draw_circle(segs[k] + Vector2(0.0, SHADOW_DROP), UiArenaV2.MUNCHER_SEG_R[k], shadow)
		draw_circle(head + Vector2(0.0, SHADOW_DROP), HEAD_R * sc, shadow)
	for k in range(2, -1, -1):
		var r: float = UiArenaV2.MUNCHER_SEG_R[k]
		draw_circle(segs[k], r, edge)
		draw_circle(segs[k], r - EDGE_W, body if k == 0 else deep)
		draw_circle(segs[k] + Vector2(4.0 - 0.36 * r, 4.0 - 0.44 * r), r * 0.28, spot)
	draw_set_transform(head, deg_to_rad(float(pose.get("head_rot", 0.0))), Vector2(sc, sc))
	for tip in pose["antenna"]:
		var t := _v(tip)
		var base := Vector2(ANTENNA_BASE_X * signf(t.x), ANTENNA_BASE_Y)
		draw_line(base, t, edge, ANTENNA_W, true)
		draw_circle(base, ANTENNA_W * 0.5, edge)
		draw_circle(t, BULB_R, edge)
		draw_circle(t, BULB_R - EDGE_W, spot)
	draw_circle(Vector2.ZERO, HEAD_R, edge)
	draw_circle(Vector2.ZERO, HEAD_R - EDGE_W, body)
	draw_circle(Vector2(-28.5, -18.5), 5.5, spot)
	draw_circle(Vector2(36.0, -16.0), 4.0, spot)
	_draw_face(key)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if in_nest:
		_draw_nest_front(_nest_center)
	if _shell > 0.001:
		_draw_ice(head + (segs[0] - head) * 0.35)
	if key == "sleep":
		_draw_zzz(head)
	elif key == "wake":
		_draw_alarm(head + ALARM_OFFSET)
	elif key == "eat":
		for c in CRUMBS:
			draw_set_transform(head + Vector2(c[0], c[1]), deg_to_rad(float(c[3])), Vector2.ONE)
			draw_colored_polygon(_ellipse_pts(Vector2.ZERO, Vector2(7.5, 5.0), 16), Color(str(c[2])))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_face(key: String) -> void:
	var ink: Color = _colors["ink"]
	var mouth: Color = _colors["mouth"]
	var tooth: Color = _colors["tooth"]
	var look := _dir * LOOK_PX if key == "hunt" or key == "eat" else Vector2.ZERO
	if key == "hunt" or key == "wake" or key == "frozen":
		var eye := Vector3(26, 30, 14)
		if key == "wake":
			eye = Vector3(32, 34, 10)
		elif key == "frozen":
			eye = Vector3(28, 30, 8)
		for side in [-1.0, 1.0]:
			var c := Vector2(EYE_CX * side, EYE_CY)
			draw_colored_polygon(_ellipse_pts(c, Vector2(eye.x, eye.y) * 0.5, 24), ink)
			draw_colored_polygon(_ellipse_pts(c, Vector2(eye.x, eye.y) * 0.5 - Vector2(3, 3), 24), _colors["eye"])
			draw_circle(c + look, eye.z * 0.5, ink)
	elif key == "sleep":
		for side in [-1.0, 1.0]:
			draw_arc(Vector2(EYE_CX * side, -20.0), 9.5, 0.0, PI, 12, ink, 5.0, true)
	elif key == "eat":
		for side in [-1.0, 1.0]:
			draw_arc(Vector2(EYE_CX * side, -8.0), 9.5, PI, TAU, 12, ink, 5.0, true)
	if key == "hunt" or key == "eat" or key == "frozen":
		var brow_y := -36.0 if key == "frozen" else -32.0
		var tilt := -14.0 if key == "frozen" else 20.0
		for side in [-1.0, 1.0]:
			var c := Vector2(EYE_CX * side, brow_y)
			var d := Vector2.from_angle(deg_to_rad(tilt * -side)) * 14.0
			draw_line(c - d, c + d, ink, 8.0, true)
			draw_circle(c - d, 4.0, ink)
			draw_circle(c + d, 4.0, ink)
	match key:
		"sleep":
			_rounded(Rect2(-12, 14, 24, 6), mouth, 3)
			_rounded(Rect2(3, 18, 8, 8), tooth, 0, 3, mouth, 2)
		"hunt":
			_rounded(Rect2(-26, 4, 52, 24), mouth, 6, 12)
			draw_colored_polygon(_ellipse_pts(Vector2(0, 22), Vector2(11, 4.5), 16), _colors["tongue"])
			_rounded(Rect2(-16, 4, 10, 9), tooth, 0, 3)
			_rounded(Rect2(6, 4, 10, 9), tooth, 0, 3)
		"eat":
			var chomp := absf(sin(_chomp_t * PI / CHOMP_PERIOD))
			var mouth_h := 12.0 + 36.0 * chomp
			draw_colored_polygon(_ellipse_pts(Vector2(0, 20), Vector2(32, mouth_h * 0.5), 28), _colors["edge"])
			draw_colored_polygon(_ellipse_pts(Vector2(0, 20), Vector2(29, mouth_h * 0.5 - 3.0), 28), mouth)
			if mouth_h > 22.0:
				var ty := 20.0 + mouth_h * 0.5 - 9.0
				draw_colored_polygon(_ellipse_pts(Vector2(0, ty), Vector2(14, 5), 16), _colors["tongue"])
				var top := 20.0 - mouth_h * 0.5 + 2.0
				_rounded(Rect2(-17, top, 11, 10), tooth, 0, 3)
				_rounded(Rect2(6, top, 11, 10), tooth, 0, 3)
		"wake":
			draw_colored_polygon(_ellipse_pts(Vector2(0, 20), Vector2(9, 10), 20), mouth)
		"frozen":
			_rounded(Rect2(-13, 14, 26, 8), mouth, 4)


## Gnijezdo 250 x 112: prsten od grancica s ukradenim laticama (straznji dio, ispod tijela).
func _draw_nest_back(c: Vector2) -> void:
	var nest := UiArenaV2.MUNCHER_NEST
	var outer := Vector2(float(nest["w"]), float(nest["h"])) * 0.5
	draw_colored_polygon(_ellipse_pts(c, outer + Vector2(2.5, 2.5), 48), Color(str(nest["edge"])))
	draw_colored_polygon(_ellipse_pts(c, outer - Vector2(2.5, 2.5), 48), Color(str(nest["fill"])))
	var bed_c := c + Vector2(0.0, 3.0)
	var bed := Vector2(float(nest["bed_w"]), float(nest["bed_h"])) * 0.5
	draw_colored_polygon(_ellipse_pts(bed_c, bed, 40), Color(str(nest["bed_edge"])))
	draw_colored_polygon(_ellipse_pts(bed_c, bed - Vector2(4, 4), 40), Color(str(nest["bed"])))
	var petals: Array = nest["petals"]
	var spots := [[-61, 3.5, 11, 6.5, -20], [-25, 17.5, 11, 6.5, 15], [41, 15.5, 11, 6.5, -10], [70, -1, 10, 6, 25]]
	for i in spots.size():
		var p: Array = spots[i]
		draw_set_transform(c + Vector2(p[0], p[1]), deg_to_rad(float(p[4])), Vector2.ONE)
		draw_colored_polygon(_ellipse_pts(Vector2.ZERO, Vector2(p[2], p[3]), 16), Color(str(petals[i])))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Prednji rub gnijezda preko tijela — muncher „lezi u" gnijezdu.
func _draw_nest_front(c: Vector2) -> void:
	var nest := UiArenaV2.MUNCHER_NEST
	var outer := Vector2(float(nest["w"]), float(nest["h"])) * 0.5
	var inner := outer - Vector2(22.0, 17.0)
	var cut := 4.0
	var a0 := asin(cut / outer.y)
	var b0 := asin(cut / inner.y)
	var outer_arc := PackedVector2Array()
	var inner_arc := PackedVector2Array()
	for i in 25:
		var t := float(i) / 24.0
		var a := lerpf(a0, PI - a0, t)
		outer_arc.append(c + Vector2(cos(a) * outer.x, sin(a) * outer.y))
		var b := lerpf(b0, PI - b0, t)
		inner_arc.append(c + Vector2(cos(b) * inner.x, sin(b) * inner.y))
	var band := outer_arc.duplicate()
	for i in range(inner_arc.size() - 1, -1, -1):
		band.append(inner_arc[i])
	draw_colored_polygon(band, Color(str(nest["fill"])))
	draw_polyline(_offset_arc(c, outer + Vector2(2.5, 2.5), a0), Color(str(nest["edge"])), 5.0, true)
	draw_polyline(inner_arc, Color(str(nest["bed_edge"])), 4.0, true)
	var twig := Color(str(nest["edge"]))
	for tw in [[-68, 37, 34, 12], [50, 39, 30, -10]]:
		var d := Vector2.from_angle(deg_to_rad(float(tw[3]))) * float(tw[2]) * 0.5
		var m := c + Vector2(tw[0], tw[1])
		draw_line(m - d, m + d, twig, 5.0, true)


func _draw_ice(center: Vector2) -> void:
	var a := _shell
	var s := 0.8 + 0.2 * _shell
	draw_set_transform(center, 0.0, Vector2(s, s))
	var box := Rect2(-ICE_SIZE * 0.5, ICE_SIZE)
	if _ice_box == null:
		_ice_box = StyleBoxFlat.new()
		_ice_box.set_border_width_all(4)
		_ice_box.set_corner_radius_all(28)
		_ice_box.corner_detail = 10
		_ice_box.anti_aliasing = true
		_ice_rim = StyleBoxFlat.new()
		_ice_rim.draw_center = false
		_ice_rim.set_border_width_all(2)
		_ice_rim.set_corner_radius_all(30)
		_ice_rim.corner_detail = 10
	var sb := _ice_box
	sb.bg_color = Color(_colors["ice"], _colors["ice"].a * a)
	sb.border_color = Color(_colors["ice_edge"], a)
	var rim := _ice_rim
	rim.border_color = Color(_colors["frozen_edge"], a)
	draw_style_box(rim, box.grow(2.0))
	draw_style_box(sb, box)
	var tl := box.position
	var white := Color(_colors["ice_hi"], a)
	var shine := Vector2.from_angle(deg_to_rad(-35.0))
	draw_line(tl + Vector2(57, 34.5) - shine * 30.5, tl + Vector2(57, 34.5) + shine * 30.5, white, 9.0, true)
	draw_line(tl + Vector2(57, 58.5) - shine * 12.5, tl + Vector2(57, 58.5) + shine * 12.5, white, 9.0, true)
	var icicle := Color(_colors["ice_edge"], a)
	for ic in [[34, 18, 24], [86, 16, 18], [134, 18, 28]]:
		var x := float(ic[0])
		draw_colored_polygon(PackedVector2Array([
			tl + Vector2(x, 168), tl + Vector2(x + float(ic[1]), 168), tl + Vector2(x + float(ic[1]) * 0.5, 168 + float(ic[2]))
		]), icicle)
	for cap in [[36, 2, 16], [64, 0, 20], [91, 3, 13]]:
		draw_circle(tl + Vector2(cap[0], cap[1]), float(cap[2]), white)
	for sp in [[213, 23, 7], [-16.5, 109.5, 5.5]]:
		var p := tl + Vector2(sp[0], sp[1])
		var r := float(sp[2]) * 1.414
		draw_colored_polygon(PackedVector2Array([
			p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r), p + Vector2(-r, 0)
		]), white)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Zzz desno i nisko — vrh ~16 px od polja kad je gnijezdo na y 108.
func _draw_zzz(head: Vector2) -> void:
	var z := UiArenaV2.MUNCHER_ZZZ
	var font := UiChrome.heavy_font(UiChrome.EMBOLDEN_800)
	var fill := Color(str(z["fill"]))
	var ink: Color = _colors["ink"]
	for i in 3:
		var size_px := int(z["sizes"][i])
		var o := _v(z["offsets"][i])
		var top := head.y + o.y - size_px * 0.8
		var pos := Vector2(head.x + o.x, top + font.get_ascent(size_px))
		draw_string_outline(font, pos, "z", HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, int(z["outline"]), ink)
		draw_string(font, pos, "z", HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, fill)


func _draw_alarm(center: Vector2) -> void:
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for q in ALARM_STAR:
		var p := Vector2(float(q[0]) / 100.0 - 0.5, float(q[1]) / 100.0 - 0.5)
		outer.append(center + p * ALARM_SIZE)
		inner.append(center + p * (ALARM_SIZE - 10.0))
	draw_colored_polygon(outer, _colors["ink"])
	draw_colored_polygon(inner, _colors["alarm"])
	var font := UiChrome.heavy_font(UiChrome.EMBOLDEN_800)
	var baseline := center.y + (font.get_ascent(36) - font.get_descent(36)) * 0.5
	draw_string(font, Vector2(center.x - 20.0, baseline), "!", HORIZONTAL_ALIGNMENT_CENTER, 40.0, 36, _colors["ink"])


func _rounded(
	rect: Rect2, fill: Color, top_r: int, bottom_r: int = -1, border: Color = Color.TRANSPARENT, border_w: int = 0
) -> void:
	var cache_key := "%s|%s|%d|%d|%s|%d" % [rect.size, fill.to_html(), top_r, bottom_r, border.to_html(), border_w]
	if _boxes.has(cache_key):
		draw_style_box(_boxes[cache_key], rect)
		return
	var s := StyleBoxFlat.new()
	_boxes[cache_key] = s
	s.bg_color = fill
	s.corner_radius_top_left = top_r
	s.corner_radius_top_right = top_r
	var b := top_r if bottom_r < 0 else bottom_r
	s.corner_radius_bottom_left = b
	s.corner_radius_bottom_right = b
	s.corner_detail = 8
	s.anti_aliasing = true
	if border_w > 0:
		s.border_color = border
		s.set_border_width_all(border_w)
	draw_style_box(s, rect)


static func _offset_arc(c: Vector2, r: Vector2, a0: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 25:
		var a := lerpf(a0, PI - a0, float(i) / 24.0)
		pts.append(c + Vector2(cos(a) * r.x, sin(a) * r.y))
	return pts


static func _ellipse_pts(c: Vector2, r: Vector2, steps: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in steps:
		var a := TAU * float(i) / steps
		pts.append(c + Vector2(cos(a) * r.x, sin(a) * r.y))
	return pts


static func _v(a: Array) -> Vector2:
	return Vector2(float(a[0]), float(a[1]))


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
