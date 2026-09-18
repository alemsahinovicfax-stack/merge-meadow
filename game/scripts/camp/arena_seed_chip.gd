class_name ArenaSeedChip
extends Control

## Sjeme u merge areni — T1/T2, drag + magnet snap merge. Crtez: ArenaChipDraw (smjer B).

signal drag_started(chip: ArenaSeedChip)
signal drag_released(chip: ArenaSeedChip)

## Chip je nastao kao 48 px radius x 1.4 — razmaci u controlleru i GameState.ARENA_*
## (snap, magnet, max 30) vezani su za ovu velicinu.
const DISPLAY_SCALE := 1.4
const CHIP_RADIUS := 48.0 * DISPLAY_SCALE

# Stanja i tajming — "Tabela animacija" u design_handoff_merge_arena.
const DRAG_SCALE := 1.12
const DRAG_ROT := -0.0524  # -3°
const DRAG_LIFT_SEC := 0.12
const PARTNER_SCALE := 1.04
const PULSE_PERIOD := 0.7
const MERGE_POP_SCALE := 1.3
const MERGE_POP_SEC := 0.26
const WOBBLE_STEPS: Array[Vector2] = [
	Vector2(6.0, 0.06), Vector2(-6.0, 0.08), Vector2(3.0, 0.07), Vector2(0.0, 0.09)
]
const EATEN_SCALE := 0.62
const EATEN_ALPHA := 0.4
const POUR_SEC := 0.42
const POUR_START_SCALE := 0.6

var chip_id: int = -1
var type_id: String = ""
var tier: int = 1

var _pulse_highlight: bool = false
var pulse_highlight: bool:
	set(value):
		if _pulse_highlight == value:
			return
		_pulse_highlight = value
		set_process(value)
		queue_redraw()
	get:
		return _pulse_highlight

var magnet_partner: bool = false:
	set(value):
		if magnet_partner == value:
			return
		magnet_partner = value
		if not _dragging and not _being_eaten:
			_tween_pose(_rest_scale(), 0.0)
		queue_redraw()

var _mythic: bool = false
var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _being_eaten: bool = false
var _merge_ring: float = 0.0
var _fly_offset: Vector2 = Vector2.ZERO
var _pose_tween: Tween = null
var _fx_tween: Tween = null


func setup(id: int, seed_type: String, at: Vector2, seed_tier: int = 1) -> void:
	chip_id = id
	type_id = seed_type
	tier = seed_tier
	_mythic = GameState.is_mythic_seed(seed_type)
	custom_minimum_size = Vector2(CHIP_RADIUS * 2.0, CHIP_RADIUS * 2.0)
	size = custom_minimum_size
	pivot_offset = size * 0.5
	position = at - Vector2(CHIP_RADIUS, CHIP_RADIUS)
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(false)
	queue_redraw()


func set_tier(new_tier: int) -> void:
	tier = new_tier
	queue_redraw()


func get_center() -> Vector2:
	return position + size * 0.5


func set_center(center: Vector2) -> void:
	position = center - size * 0.5


func is_dragging() -> bool:
	return _dragging


func is_being_eaten() -> bool:
	return _being_eaten


## Pour: sjemenka izlijece iz vrece (`from_center`, koordinate roditelja) na svoje mjesto.
## Pozicija je odmah konacna — leti samo crtez, pa magnet/Muncher/testovi vide pravo stanje.
func play_pour_in(from_center: Vector2, delay: float) -> void:
	if not is_inside_tree():
		return
	_fly_offset = from_center - get_center()
	modulate.a = 0.0
	scale = Vector2.ONE * POUR_START_SCALE
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_callback(func() -> void: modulate.a = 1.0)
	tw.tween_method(_set_fly_offset, _fly_offset, Vector2.ZERO, POUR_SEC).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2.ONE, POUR_SEC).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)


func play_merge_pop() -> void:
	if not is_inside_tree():
		return
	_kill_tweens()
	rotation = 0.0
	scale = Vector2.ONE
	_fx_tween = create_tween()
	_fx_tween.tween_property(self, "scale", Vector2.ONE * MERGE_POP_SCALE, MERGE_POP_SEC * 0.4).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_OUT)
	_fx_tween.tween_property(self, "scale", Vector2.ONE * _rest_scale(), MERGE_POP_SEC * 0.6).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	create_tween().tween_method(_set_merge_ring, 1.0, 0.0, MERGE_POP_SEC)


## Promasaj — pusten pored sjemenke s kojom ne moze.
func play_wobble() -> void:
	if not is_inside_tree():
		return
	_kill_tweens()
	scale = Vector2.ONE * _rest_scale()
	_fx_tween = create_tween()
	for step in WOBBLE_STEPS:
		_fx_tween.tween_property(self, "rotation", deg_to_rad(step.x), step.y).set_trans(Tween.TRANS_SINE)


func set_being_eaten(on: bool) -> void:
	if _being_eaten == on:
		return
	_being_eaten = on
	queue_redraw()
	if not is_inside_tree():
		return
	_kill_tweens()
	_fx_tween = create_tween().set_parallel(true)
	var sec := GameState.ARENA_PEST_EAT_DURATION if on else 0.15
	_fx_tween.tween_property(self, "scale", Vector2.ONE * (EATEN_SCALE if on else _rest_scale()), sec)
	_fx_tween.tween_property(self, "modulate:a", EATEN_ALPHA if on else 1.0, sec)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_begin_drag(touch.position)
		else:
			_end_drag()
		accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _dragging:
			global_position = drag.position - _drag_offset
		accept_event()
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_begin_drag(mouse.position)
		else:
			_end_drag()
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset


func _process(_delta: float) -> void:
	if pulse_highlight:
		queue_redraw()


func _draw() -> void:
	var ring := ArenaChipDraw.Ring.NONE
	var ring_alpha := 1.0
	if _merge_ring > 0.0:
		ring = ArenaChipDraw.Ring.MERGE
		ring_alpha = _merge_ring
	elif magnet_partner:
		ring = ArenaChipDraw.Ring.PARTNER
	elif pulse_highlight:
		ring = ArenaChipDraw.Ring.PULSE
		var phase := Time.get_ticks_msec() / 1000.0 * TAU / PULSE_PERIOD
		ring_alpha = 0.55 + 0.45 * (0.5 + 0.5 * sin(phase))
	# Crtez je u lokalnom (skaliranom) prostoru — pomak leta skaliraj natrag.
	var offset := _fly_offset / maxf(scale.x, 0.01)
	ArenaChipDraw.draw_chip(
		self, size * 0.5 + offset, type_id, tier, _mythic, ring, ring_alpha, _dragging, _being_eaten
	)


func _begin_drag(local_pos: Vector2) -> void:
	_dragging = true
	_drag_offset = local_pos
	z_index = 10
	_tween_pose(DRAG_SCALE, DRAG_ROT)
	queue_redraw()
	drag_started.emit(self)


func _end_drag() -> void:
	if not _dragging:
		return
	_dragging = false
	z_index = 0
	_tween_pose(_rest_scale(), 0.0)
	queue_redraw()
	drag_released.emit(self)


func _rest_scale() -> float:
	return PARTNER_SCALE if magnet_partner else 1.0


func _tween_pose(target_scale: float, target_rot: float) -> void:
	if not is_inside_tree():
		scale = Vector2.ONE * target_scale
		rotation = target_rot
		return
	if _pose_tween != null and _pose_tween.is_valid():
		_pose_tween.kill()
	_pose_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_pose_tween.tween_property(self, "scale", Vector2.ONE * target_scale, DRAG_LIFT_SEC)
	_pose_tween.tween_property(self, "rotation", target_rot, DRAG_LIFT_SEC)


func _kill_tweens() -> void:
	if _pose_tween != null and _pose_tween.is_valid():
		_pose_tween.kill()
	if _fx_tween != null and _fx_tween.is_valid():
		_fx_tween.kill()


func _set_fly_offset(value: Vector2) -> void:
	_fly_offset = value
	queue_redraw()


func _set_merge_ring(value: float) -> void:
	_merge_ring = value
	queue_redraw()
