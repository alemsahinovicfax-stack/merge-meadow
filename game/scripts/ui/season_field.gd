class_name SeasonField
extends Control

## HOME-14 LIFE-C/D — 12–14 flowers in meadow_safe_rect; MeadowPip Walk/Sniff/Sleep.

const FLOWER_SCRIPT := preload("res://scripts/ui/season_field_flower.gd")
const FLOWER_COUNT := 13
const CHROME_PAD := 12.0
const PIP_SIDE := 72.0
const PIP_MIN_MOVE := 80.0
const PIP_WALK_SPEED := 70.0
const PIP_WALK_MIN := 2.2
const PIP_WALK_MAX := 5.5
const PIP_SNIFF_NEAR := 72.0
const PIP_SNIFF_WALK_MAX := 2.5
const PIP_WEIGHT_WALK := 0.50
const PIP_WEIGHT_SNIFF := 0.25
const PIP_WEIGHT_SLEEP := 0.25

enum _PipState { NONE, WALK, SNIFF, SLEEP }
const FLOWER_SLOTS: Array[Vector2] = [
	Vector2(0.14, 0.12),
	Vector2(0.38, 0.12),
	Vector2(0.62, 0.12),
	Vector2(0.86, 0.12),
	Vector2(0.26, 0.36),
	Vector2(0.50, 0.36),
	Vector2(0.74, 0.36),
	Vector2(0.12, 0.58),
	Vector2(0.38, 0.58),
	Vector2(0.62, 0.58),
	Vector2(0.88, 0.58),
	Vector2(0.32, 0.80),
	Vector2(0.68, 0.80),
]

@onready var field_ground: ColorRect = $FieldGround
@onready var meadow_pip: Control = $MeadowPip
var _open_season_id: String = ""
var _wander_tween: Tween = null
var _pip_state: int = _PipState.NONE
var _last_sniff_id: int = 0


func _ready() -> void:
	_hide_pip_and_stop()


func apply_season(season_id: String) -> void:
	_open_season_id = season_id
	if field_ground:
		field_ground.color = SeasonTheme.home_field_tint(season_id)
	_rebuild_flowers(season_id)
	call_deferred("_rebuild_flowers_deferred", season_id)


func meadow_safe_rect() -> Rect2:
	var bounds := _field_bounds()
	if bounds.size.x < 8.0 or bounds.size.y < 8.0:
		return bounds
	var safe := bounds
	for chrome in _chrome_controls():
		var local := _global_rect_to_local(chrome.get_global_rect()).grow(CHROME_PAD)
		safe = _carve_aabb(safe, local)
	var half := SeasonFieldFlower.FLOWER_SIDE * 0.5
	safe = safe.grow(-half)
	if safe.size.x < 8.0 or safe.size.y < 8.0:
		var min_size := Vector2(8.0, 8.0)
		var center := bounds.get_center()
		return Rect2(center - min_size * 0.5, min_size)
	return safe


func clear_flowers() -> void:
	for child in get_children():
		if _is_shell_child(child):
			continue
		remove_child(child)
		child.queue_free()


func dismiss_flowers() -> void:
	_open_season_id = ""
	_hide_pip_and_stop()
	clear_flowers()


func is_pip_wandering() -> bool:
	return _wander_tween != null and _wander_tween.is_running()


func is_pip_alive() -> bool:
	return (
		not _open_season_id.is_empty()
		and meadow_pip != null
		and meadow_pip.visible
		and _pip_state != _PipState.NONE
	)


func _rebuild_flowers_deferred(season_id: String) -> void:
	if _open_season_id != season_id:
		return
	_rebuild_flowers(season_id)


func _is_shell_child(child: Node) -> bool:
	var n := str(child.name)
	return n == "FieldGround" or n == "SeasonsButton" or n == "MeadowPip"


func _rebuild_flowers(season_id: String) -> void:
	clear_flowers()
	if season_id.is_empty():
		_hide_pip_and_stop()
		return
	var bounds := _field_bounds()
	if bounds.size.x < 8.0 or bounds.size.y < 8.0:
		_hide_pip_and_stop()
		return
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null or def.seed_type_ids.is_empty():
		_restart_wander()
		return
	var pool: Array[String] = def.seed_type_ids
	var safe := meadow_safe_rect()
	var count := clampi(FLOWER_COUNT, 12, mini(14, FLOWER_SLOTS.size()))
	for i in count:
		var type_id := str(pool[i % pool.size()])
		var flower: SeasonFieldFlower = FLOWER_SCRIPT.new()
		add_child(flower)
		flower.setup(type_id, 3)
		flower.z_index = 0
		var slot: Vector2 = FLOWER_SLOTS[i]
		var pos := safe.position + slot * safe.size
		pos.x = clampf(pos.x, safe.position.x, maxf(safe.position.x, safe.end.x - flower.size.x))
		pos.y = clampf(pos.y, safe.position.y, maxf(safe.position.y, safe.end.y - flower.size.y))
		flower.position = pos
	_restart_wander()


func _field_bounds() -> Rect2:
	var bounds := size
	if bounds.x < 8.0 and field_ground:
		bounds = field_ground.size
	return Rect2(Vector2.ZERO, bounds)


func _chrome_root() -> Node:
	var n: Node = get_parent()
	while n:
		if (
			n.get_node_or_null("%DailyChestCard") != null
			and n.get_node_or_null("%SeasonNameChip") != null
			and n.get_node_or_null("%PlayRow") != null
		):
			return n
		n = n.get_parent()
	return null


func _chrome_controls() -> Array[Control]:
	var out: Array[Control] = []
	var root := _chrome_root()
	if root == null:
		return out
	var daily: Control = root.get_node_or_null("%DailyChestCard") as Control
	var basket: Control = root.get_node_or_null("%BasketCard") as Control
	var chip: Control = root.get_node_or_null("%SeasonNameChip") as Control
	var play_row: Control = root.get_node_or_null("%PlayRow") as Control
	var settings: Control = root.get_node_or_null("%SettingsButton") as Control
	if settings == null:
		settings = root.get_node_or_null("SettingsButton") as Control
	var upgrades: Control = root.get_node_or_null("%FieldUpgradeStack") as Control
	for node in [daily, basket, settings, chip, play_row, upgrades]:
		var chrome: Control = node as Control
		if chrome == null or not chrome.visible:
			continue
		out.append(chrome)
	return out


func _global_rect_to_local(global_rect: Rect2) -> Rect2:
	var inv := get_global_transform_with_canvas().affine_inverse()
	var corners: Array[Vector2] = [
		inv * global_rect.position,
		inv * (global_rect.position + Vector2(global_rect.size.x, 0.0)),
		inv * (global_rect.position + Vector2(0.0, global_rect.size.y)),
		inv * (global_rect.position + global_rect.size),
	]
	var min_x := corners[0].x
	var min_y := corners[0].y
	var max_x := corners[0].x
	var max_y := corners[0].y
	for i in range(1, corners.size()):
		min_x = minf(min_x, corners[i].x)
		min_y = minf(min_y, corners[i].y)
		max_x = maxf(max_x, corners[i].x)
		max_y = maxf(max_y, corners[i].y)
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)


func _carve_aabb(safe: Rect2, blocker: Rect2) -> Rect2:
	var hit := safe.intersection(blocker)
	if hit.size.x <= 0.0 or hit.size.y <= 0.0:
		return safe
	var next := safe
	if hit.size.y <= hit.size.x:
		var safe_mid := safe.position.y + safe.size.y * 0.5
		var hit_mid := hit.position.y + hit.size.y * 0.5
		if hit_mid >= safe_mid:
			next.size.y = maxf(0.0, blocker.position.y - safe.position.y)
		else:
			var new_top := blocker.position.y + blocker.size.y
			next.size.y = maxf(0.0, safe.end.y - new_top)
			next.position.y = new_top
	else:
		var safe_mid := safe.position.x + safe.size.x * 0.5
		var hit_mid := hit.position.x + hit.size.x * 0.5
		if hit_mid >= safe_mid:
			next.size.x = maxf(0.0, blocker.position.x - safe.position.x)
		else:
			var new_left := blocker.position.x + blocker.size.x
			next.size.x = maxf(0.0, safe.end.x - new_left)
			next.position.x = new_left
	return next


func _hide_pip_and_stop() -> void:
	_stop_wander()
	_pip_state = _PipState.NONE
	_last_sniff_id = 0
	if meadow_pip:
		meadow_pip.visible = false


func _stop_wander() -> void:
	if _wander_tween:
		_wander_tween.kill()
		_wander_tween = null


func _restart_wander() -> void:
	_stop_wander()
	_last_sniff_id = 0
	if meadow_pip == null:
		_pip_state = _PipState.NONE
		return
	meadow_pip.visible = true
	meadow_pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meadow_pip.position = _clamp_pip_pos(meadow_pip.position)
	_enter_pip_state(_PipState.WALK)


func _pip_size() -> Vector2:
	if meadow_pip and meadow_pip.size.x >= 8.0:
		return meadow_pip.size
	return Vector2(PIP_SIDE, PIP_SIDE)


func _clamp_pip_pos(pos: Vector2) -> Vector2:
	var safe := meadow_safe_rect()
	var sz := _pip_size()
	var max_x := maxf(safe.position.x, safe.end.x - sz.x)
	var max_y := maxf(safe.position.y, safe.end.y - sz.y)
	return Vector2(
		clampf(pos.x, safe.position.x, max_x),
		clampf(pos.y, safe.position.y, max_y)
	)


func _meadow_flowers() -> Array[Control]:
	var out: Array[Control] = []
	for child in get_children():
		if child.is_in_group("meadow_flower") and child is Control:
			out.append(child as Control)
	return out


func _random_safe_pip_pos() -> Vector2:
	var safe := meadow_safe_rect()
	var sz := _pip_size()
	var max_x := maxf(safe.position.x, safe.end.x - sz.x)
	var max_y := maxf(safe.position.y, safe.end.y - sz.y)
	return Vector2(randf_range(safe.position.x, max_x), randf_range(safe.position.y, max_y))


func _pip_pos_for_flower(flower: Control) -> Vector2:
	var dest := flower.position + (flower.size - _pip_size()) * 0.5
	return _clamp_pip_pos(dest)


func _enter_pip_state(state: int) -> void:
	_stop_wander()
	_pip_state = state
	match state:
		_PipState.WALK:
			_start_walk()
		_PipState.SNIFF:
			_start_sniff()
		_PipState.SLEEP:
			_start_sleep()
		_:
			_pip_state = _PipState.NONE


func _pick_next_pip_state() -> void:
	if _open_season_id.is_empty() or meadow_pip == null or not meadow_pip.visible:
		_hide_pip_and_stop()
		return
	_enter_pip_state(_weighted_next_state(_pip_state))


func _weighted_next_state(current: int) -> int:
	var options: Array[int] = []
	var weights: Array[float] = []
	if current != _PipState.WALK:
		options.append(_PipState.WALK)
		weights.append(PIP_WEIGHT_WALK)
	if current != _PipState.SNIFF:
		options.append(_PipState.SNIFF)
		weights.append(PIP_WEIGHT_SNIFF)
	if current != _PipState.SLEEP:
		options.append(_PipState.SLEEP)
		weights.append(PIP_WEIGHT_SLEEP)
	if options.is_empty():
		return _PipState.WALK
	var total := 0.0
	for w in weights:
		total += w
	var roll := randf() * total
	var acc := 0.0
	for i in options.size():
		acc += weights[i]
		if roll <= acc:
			return options[i]
	return options[options.size() - 1]


func _pick_walk_dest() -> Vector2:
	var current := meadow_pip.position
	var dest: Vector2
	if randf() < 0.5:
		dest = _random_safe_pip_pos()
	else:
		var flowers := _meadow_flowers()
		if flowers.is_empty():
			dest = _random_safe_pip_pos()
		else:
			var flower: Control = flowers[randi() % flowers.size()]
			dest = _pip_pos_for_flower(flower)
	if dest.distance_to(current) >= PIP_MIN_MOVE:
		return dest
	for _i in 6:
		var alt := _random_safe_pip_pos()
		if alt.distance_to(current) >= PIP_MIN_MOVE:
			return alt
	return dest


func _tween_pip_to(dest: Vector2, duration: float, on_done: Callable) -> void:
	if meadow_pip == null:
		_pip_state = _PipState.NONE
		return
	_stop_wander()
	meadow_pip.position = _clamp_pip_pos(meadow_pip.position)
	dest = _clamp_pip_pos(dest)
	_wander_tween = create_tween()
	_wander_tween.set_trans(Tween.TRANS_SINE)
	_wander_tween.set_ease(Tween.EASE_IN_OUT)
	_wander_tween.tween_property(meadow_pip, "position", dest, duration)
	_wander_tween.finished.connect(on_done, CONNECT_ONE_SHOT)


func _start_walk() -> void:
	if meadow_pip == null:
		_pip_state = _PipState.NONE
		return
	var dest := _pick_walk_dest()
	var duration := clampf(
		meadow_pip.position.distance_to(dest) / PIP_WALK_SPEED, PIP_WALK_MIN, PIP_WALK_MAX
	)
	_tween_pip_to(dest, duration, _on_pip_move_finished)


func _pick_sniff_flower() -> Control:
	var flowers := _meadow_flowers()
	if flowers.is_empty():
		return null
	var others: Array[Control] = []
	for flower in flowers:
		if flower.get_instance_id() != _last_sniff_id:
			others.append(flower)
	var pool: Array[Control] = others if not others.is_empty() else flowers
	return pool[randi() % pool.size()]


func _start_sniff() -> void:
	if meadow_pip == null:
		_pip_state = _PipState.NONE
		return
	var flower := _pick_sniff_flower()
	if flower == null:
		_start_sniff_idle()
		return
	_last_sniff_id = flower.get_instance_id()
	var dest := _pip_pos_for_flower(flower)
	if meadow_pip.position.distance_to(dest) <= PIP_SNIFF_NEAR:
		_start_sniff_idle()
		return
	var duration := clampf(
		meadow_pip.position.distance_to(dest) / PIP_WALK_SPEED, 0.8, PIP_SNIFF_WALK_MAX
	)
	_tween_pip_to(dest, duration, _on_pip_move_finished)


func _start_sniff_idle() -> void:
	_stop_wander()
	_pip_state = _PipState.SNIFF
	if meadow_pip:
		meadow_pip.position = _clamp_pip_pos(meadow_pip.position)
	_wander_tween = create_tween()
	_wander_tween.tween_interval(randf_range(0.7, 1.4))
	_wander_tween.finished.connect(_on_pip_idle_finished, CONNECT_ONE_SHOT)


func _start_sleep() -> void:
	_stop_wander()
	if meadow_pip:
		meadow_pip.position = _clamp_pip_pos(meadow_pip.position)
	_wander_tween = create_tween()
	_wander_tween.tween_interval(randf_range(2.0, 5.0))
	_wander_tween.finished.connect(_on_pip_idle_finished, CONNECT_ONE_SHOT)


func _on_pip_move_finished() -> void:
	_wander_tween = null
	if _open_season_id.is_empty() or meadow_pip == null or not meadow_pip.visible:
		_hide_pip_and_stop()
		return
	if _pip_state == _PipState.SNIFF:
		_start_sniff_idle()
		return
	_pick_next_pip_state()


func _on_pip_idle_finished() -> void:
	_wander_tween = null
	_pick_next_pip_state()
