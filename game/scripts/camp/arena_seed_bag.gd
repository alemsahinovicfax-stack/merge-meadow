class_name ArenaSeedBag
extends Control

## Vreca sjemena (smjer B): hit-zona 280 x 250, tijelo 214 x 178 (prazna 214 x 126), vrat,
## brojac (krug r 42) i do 3 tipa koji vire iz vrata. Otvorena (>= 2 sjemena) se klati;
## tap izbacuje sjeme u arenu.

signal bag_clicked

const PEEK_SIZES: Array[float] = [64.0, 74.0, 64.0]
const PEEK_ROT_DEG: Array[float] = [-16.0, 0.0, 16.0]
const PEEK_OVERLAP := 10.0
const PEEK_SINK := 26.0  # koliko cvjetovi ulaze u tijelo ispod vrata
const OPEN_TILT := 0.035  # ~2°
const POUR_TILT := -0.209  # -12°
const POUR_TILT_IN_SEC := 0.1
const POUR_TILT_OUT_SEC := 0.25
const WIGGLE_SPEED := 5.5
const BODY_EDGE_W := 5.0
const NECK_EDGE_W := 4
const NECK_RISE := 16.0
const COUNTER_INSET := Vector2(6.0, 2.0)
const COUNTER_EDGE_W := 4.0
const COUNTER_FONT_SIZE := 44

var _open: bool = false
var _seed_count: int = 0
var _preview_types: Array[String] = []
var _wiggle_t: float = 0.0
var _can_pour: bool = false
var _base_position: Vector2 = Vector2.ZERO
var _pour_tilt: float = 0.0
var _tilt_tween: Tween = null


func _ready() -> void:
	custom_minimum_size = UiArena.BAG_HIT
	size = UiArena.BAG_HIT
	pivot_offset = size * 0.5
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 50
	gui_input.connect(_on_gui_input)


func _process(delta: float) -> void:
	if not _open:
		rotation = _pour_tilt
		position = _base_position
		return
	_wiggle_t += delta * WIGGLE_SPEED
	rotation = OPEN_TILT + sin(_wiggle_t) * 0.05 + _pour_tilt
	position = _base_position + Vector2(0.0, sin(_wiggle_t * 1.7) * 4.0)


func set_layout_position(base: Vector2) -> void:
	_base_position = base
	position = _base_position


## Pozicija bez klacenja — za keepout i usta vrece.
func get_base_position() -> Vector2:
	return _base_position


func set_state(seed_count: int, can_pour: bool, preview_types: Array) -> void:
	_seed_count = seed_count
	_can_pour = can_pour
	_open = seed_count >= 2
	_preview_types.clear()
	for t in preview_types:
		_preview_types.append(str(t))
	visible = true
	mouse_filter = (
		Control.MOUSE_FILTER_STOP if seed_count > 0
		else Control.MOUSE_FILTER_IGNORE
	)
	queue_redraw()


## Nagib pri izbacivanju: -12° pa nazad.
func play_pour() -> void:
	if not is_inside_tree():
		return
	if _tilt_tween != null and _tilt_tween.is_valid():
		_tilt_tween.kill()
	_tilt_tween = create_tween()
	_tilt_tween.tween_method(_set_pour_tilt, _pour_tilt, POUR_TILT, POUR_TILT_IN_SEC).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_OUT)
	_tilt_tween.tween_method(_set_pour_tilt, POUR_TILT, 0.0, POUR_TILT_OUT_SEC).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)


## Usta vrece (sredina vrata) u koordinatama roditelja.
func get_mouth_position() -> Vector2:
	var body := UiArena.BAG_SIZE
	return _base_position + Vector2(size.x * 0.5, size.y - body.y)


func _on_gui_input(event: InputEvent) -> void:
	if _seed_count <= 0:
		return
	if SceneRouter.is_input_blocked():
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and not mouse.pressed:
			bag_clicked.emit()
			accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if not touch.pressed:
			bag_clicked.emit()
			accept_event()


func _draw() -> void:
	var body_size := UiArena.BAG_SIZE_EMPTY if _seed_count <= 0 else UiArena.BAG_SIZE
	var body := Rect2(Vector2((size.x - body_size.x) * 0.5, size.y - body_size.y), body_size)
	if _seed_count > 0:
		_draw_peek(body)
	var pts := _sack_points(body)
	draw_colored_polygon(pts, UiArena.BAG_BODY)
	var outline := pts.duplicate()
	outline.append(pts[0])
	draw_polyline(outline, UiArena.BAG_BODY_EDGE, BODY_EDGE_W, true)
	_draw_neck(body)
	if _seed_count > 0:
		_draw_counter()


func _draw_peek(body: Rect2) -> void:
	var idx: Array[int] = [1]
	if _open:
		idx = [0, 1, 2]
	var cx := size.x * 0.5
	var bottom := body.position.y + PEEK_SINK
	var side_shift := (PEEK_SIZES[1] + PEEK_SIZES[0]) * 0.5 - PEEK_OVERLAP
	for i in idx:
		var s: float = PEEK_SIZES[i]
		var type_id := _preview_type(i)
		if type_id.is_empty():
			continue
		var center := Vector2(cx + (float(i) - 1.0) * side_shift, bottom - s * 0.5)
		var tex := FlowerAssets.get_texture(type_id, 1)
		if tex != null:
			draw_set_transform(center, deg_to_rad(PEEK_ROT_DEG[i]), Vector2.ONE)
			draw_texture_rect(tex, Rect2(-Vector2(s, s) * 0.5, Vector2(s, s)), false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			ArenaChipDraw.draw_flower(self, center, type_id, 1, s)


func _draw_neck(body: Rect2) -> void:
	var neck := UiArena.BAG_NECK_SIZE
	var rect := Rect2(Vector2((size.x - neck.x) * 0.5, body.position.y - NECK_RISE), neck)
	var s := StyleBoxFlat.new()
	s.bg_color = UiArena.BAG_NECK
	s.border_color = UiArena.BAG_NECK_EDGE
	s.set_border_width_all(NECK_EDGE_W)
	s.set_corner_radius_all(int(neck.y * 0.5))
	s.corner_detail = 12
	draw_style_box(s, rect)


func _draw_counter() -> void:
	var r := UiArena.BAG_COUNTER_R
	var c := size - COUNTER_INSET - Vector2(r, r)
	draw_circle(c, r, UiPalette.WARM_WHITE)
	draw_arc(c, r - COUNTER_EDGE_W * 0.5, 0.0, TAU, 48, UiArena.RIM_EDGE, COUNTER_EDGE_W, true)
	var font := UiChrome.heavy_font(UiChrome.EMBOLDEN_800)
	var text := str(_seed_count)
	var baseline := c.y + (font.get_ascent(COUNTER_FONT_SIZE) - font.get_descent(COUNTER_FONT_SIZE)) * 0.5
	draw_string(
		font, Vector2(c.x - r, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0,
		COUNTER_FONT_SIZE, UiPalette.OUTLINE
	)


func _preview_type(i: int) -> String:
	if _preview_types.is_empty():
		return ""
	if _open:
		return _preview_types[mini(i, _preview_types.size() - 1)]
	return _preview_types[0]


## Vreca: zaobljen pravougaonik s eliptickim uglovima (gore 44 % x 30 %, dolje 46 % x 56 %).
static func _sack_points(r: Rect2, steps: int = 10) -> PackedVector2Array:
	var w := r.size.x
	var h := r.size.y
	var tl := Vector2(w * 0.44, h * 0.30)
	var br := Vector2(w * 0.46, h * 0.56)
	var arcs: Array = [
		[r.position + tl, tl, PI],
		[r.position + Vector2(w - tl.x, tl.y), tl, PI * 1.5],
		[r.position + Vector2(w - br.x, h - br.y), br, 0.0],
		[r.position + Vector2(br.x, h - br.y), br, PI * 0.5],
	]
	var pts := PackedVector2Array()
	for arc in arcs:
		var c: Vector2 = arc[0]
		var rad: Vector2 = arc[1]
		var a0: float = arc[2]
		for i in steps + 1:
			var a := a0 + PI * 0.5 * float(i) / float(steps)
			pts.append(c + Vector2(cos(a) * rad.x, sin(a) * rad.y))
	return pts


func _set_pour_tilt(value: float) -> void:
	_pour_tilt = value
