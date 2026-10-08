class_name ArenaSeedBag
extends Control

## Korpa sjemena (Arena v2, design_handoff_arena_v2 § Korpa): pletena korpa za piknik,
## dodir 300 x 280. Kolicina se vidi bez brojaca — do 12 cvjetova u gomili
## (UiArenaV2.basket_visible); brojac ostaje kao tacan broj. Prazna = tamni otvor i prazna
## rucka; ima sjemena (>= 2) = klacenje; sipa = nagib -12° oko dna i 2-3 cvijeta u letu.
## Performanse: tijelo korpe je zaseban cvor (Body) koji se klati rotacijom — crtez se ne
## obnavlja svaki frejm, samo kad se promijeni stanje. Sjena ide ispod, brojac i cvjetovi u
## letu iznad (Front).

signal bag_clicked

const OPEN_TILT := 0.035  # ~2°
const WIGGLE_AMP := 0.05
const WIGGLE_SPEED := 5.5
const POUR_TILT_IN_SEC := 0.1
const POUR_TILT_OUT_SEC := 0.25
const POUR_FLY_SEC := 0.35
const POUR_FLY_RISE := 40.0
const HANDLE_P := [Vector2(44, 156), Vector2(44, -2), Vector2(256, -2), Vector2(256, 156)]
const HANDLE_INK_W := 24.0
const HANDLE_W := 14.0
const OPENING_C := Vector2(150, 154)
const OPENING_R := Vector2(114, 20)
const RIM_RECT := Rect2(22, 146, 256, 30)
const CLOTH_DOTS := [Vector2(122, 164), Vector2(150, 168), Vector2(178, 164)]
## Redoslijed crtanja gomile (gornji red prvi, pa prednji preko njega).
const PILE_DRAW_ORDER := [9, 10, 11, 5, 6, 7, 8, 0, 1, 2, 3, 4]
## Cvjetovi u letu pri sipanju: [x, y, velicina, rotacija] u koordinatama hit-zone.
const POUR_FLYERS := [[36, 44, 56, -30], [-6, -4, 52, 20], [64, -44, 50, -10]]
const SHADOW_RECT := Rect2(30, 261, 240, 24)

var _open: bool = false
var _seed_count: int = 0
var _preview_types: Array[String] = []
var _wiggle_t: float = 0.0
var _can_pour: bool = false
var _show_counter: bool = true
var _base_position: Vector2 = Vector2.ZERO
var _pour_tilt: float = 0.0
var _pour_fly: float = 0.0
var _tilt_tween: Tween = null
var _fly_tween: Tween = null
var _colors: Dictionary = {}
var _body: Control = null
var _front: Control = null
var _rim_box: StyleBoxFlat = null


func _ready() -> void:
	custom_minimum_size = UiArenaV2.BASKET_HIT
	size = UiArenaV2.BASKET_HIT
	pivot_offset = size * 0.5
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 50
	for key in UiArenaV2.BASKET_COLORS:
		_colors[key] = UiArenaV2.col(str(UiArenaV2.BASKET_COLORS[key]))
	_body = _make_layer("Body", _draw_body)
	_body.pivot_offset = UiArenaV2.BASKET_PIVOT
	_front = _make_layer("Front", _draw_front)
	gui_input.connect(_on_gui_input)


func _make_layer(layer_name: String, painter: Callable) -> Control:
	var layer := Control.new()
	layer.name = layer_name
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.size = UiArenaV2.BASKET_HIT
	layer.draw.connect(painter)
	add_child(layer)
	return layer


func _process(delta: float) -> void:
	var angle := _pour_tilt
	if _open:
		_wiggle_t += delta * WIGGLE_SPEED
		position = _base_position + Vector2(0.0, sin(_wiggle_t * 1.7) * 4.0)
		angle += OPEN_TILT + sin(_wiggle_t) * WIGGLE_AMP
	else:
		position = _base_position
	if _body != null:
		_body.rotation = angle
	if _pour_fly > 0.0 and _front != null:
		_front.queue_redraw()


func set_layout_position(base: Vector2) -> void:
	_base_position = base
	position = _base_position


## Pozicija bez klacenja — za keepout i usta korpe.
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
	mouse_filter = Control.MOUSE_FILTER_STOP
	_redraw_all()


func _redraw_all() -> void:
	queue_redraw()
	if _body != null:
		_body.queue_redraw()
		_front.queue_redraw()


func get_seed_count() -> int:
	return _seed_count


## Koliko cvjetova se vidi u gomili (0 prazna, 12 puna).
func get_visible_pile() -> int:
	var vis := UiArenaV2.basket_visible(_seed_count)
	return maxi(0, vis - 2) if _pour_fly > 0.0 else vis


## Nagib pri sipanju: -12° (0,1 s) pa nazad (0,25 s back) oko dna korpe.
func play_pour() -> void:
	if not is_inside_tree():
		return
	if _tilt_tween != null and _tilt_tween.is_valid():
		_tilt_tween.kill()
	var tilt := deg_to_rad(UiArenaV2.BASKET_TILT_POUR_DEG)
	_tilt_tween = create_tween()
	_tilt_tween.tween_method(_set_pour_tilt, _pour_tilt, tilt, POUR_TILT_IN_SEC).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_OUT)
	_tilt_tween.tween_method(_set_pour_tilt, tilt, 0.0, POUR_TILT_OUT_SEC).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	if _fly_tween != null and _fly_tween.is_valid():
		_fly_tween.kill()
	_pour_fly = 1.0
	_redraw_all()
	_fly_tween = create_tween()
	_fly_tween.tween_property(self, "_pour_fly", 0.0, POUR_FLY_SEC).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_IN
	)
	_fly_tween.tween_callback(_redraw_all)


## Usta korpe (centar otvora) u koordinatama roditelja.
func get_mouth_position() -> Vector2:
	return _base_position + UiArenaV2.BASKET_MOUTH


func set_counter_visible(on: bool) -> void:
	_show_counter = on
	_redraw_all()


func _on_gui_input(event: InputEvent) -> void:
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
	draw_colored_polygon(_ellipse(SHADOW_RECT.get_center(), SHADOW_RECT.size * 0.5), _colors["shadow"])


## Tijelo korpe (crta se u Body, koji se rotira oko dna): rucka, otvor, gomila, pleter, rub, krpa.
func _draw_body() -> void:
	var c := _body
	_draw_handle(c)
	var opening := _ellipse(OPENING_C, OPENING_R)
	c.draw_colored_polygon(opening, _colors["opening"])
	_draw_closed(c, opening, _colors["edge"], 4.0)
	_draw_pile(c)
	_draw_wicker(c)
	_draw_rim(c)
	_draw_cloth(c)


## Iznad tijela, bez rotacije: cvjetovi u letu pri sipanju i brojac.
func _draw_front() -> void:
	if _pour_fly > 0.0 and _seed_count > 0:
		_draw_flyers(_front)
	if _seed_count > 0:
		_draw_counter(_front)


func _draw_handle(c: CanvasItem) -> void:
	var pts := PackedVector2Array()
	for i in 25:
		var t := float(i) / 24.0
		var u := 1.0 - t
		pts.append(
			HANDLE_P[0] * u * u * u + HANDLE_P[1] * 3.0 * u * u * t
			+ HANDLE_P[2] * 3.0 * u * t * t + HANDLE_P[3] * t * t * t
		)
	for pass_i in 2:
		var w := HANDLE_INK_W if pass_i == 0 else HANDLE_W
		var col: Color = _colors["edge"] if pass_i == 0 else _colors["handle"]
		c.draw_polyline(pts, col, w, true)
		c.draw_circle(pts[0], w * 0.5, col)
		c.draw_circle(pts[pts.size() - 1], w * 0.5, col)


func _draw_pile(c: CanvasItem) -> void:
	var shown := get_visible_pile()
	if shown <= 0 or _preview_types.is_empty():
		return
	for i in PILE_DRAW_ORDER:
		if i >= shown:
			continue
		var q: Array = UiArenaV2.BASKET_PILE[i]
		var type_id := _preview_types[i % _preview_types.size()]
		c.draw_set_transform(Vector2(q[0], q[1]), deg_to_rad(float(q[3])), Vector2.ONE)
		ArenaChipDraw.draw_flower(c, Vector2.ZERO, type_id, 1, float(q[2]))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_wicker(c: CanvasItem) -> void:
	var pts := PackedVector2Array([Vector2(30, 166), Vector2(270, 166), Vector2(249, 256)])
	_append_quad(pts, Vector2(249, 256), Vector2(246, 270), Vector2(232, 270))
	pts.append(Vector2(68, 270))
	_append_quad(pts, Vector2(68, 270), Vector2(54, 270), Vector2(51, 256))
	c.draw_colored_polygon(pts, _colors["wicker"])
	var weave: Color = _colors["weave"]
	c.draw_line(Vector2(40, 202), Vector2(260, 202), weave, 6.0, true)
	c.draw_line(Vector2(47, 236), Vector2(253, 236), weave, 6.0, true)
	for seg in [[84, 88], [117, 119], [150, 150], [183, 181], [216, 212]]:
		c.draw_line(Vector2(seg[0], 172), Vector2(seg[1], 264), weave, 4.0, true)
	_draw_closed(c, pts, _colors["edge"], 5.0)


func _draw_rim(c: CanvasItem) -> void:
	if _rim_box == null:
		_rim_box = StyleBoxFlat.new()
		_rim_box.bg_color = _colors["rim"]
		_rim_box.border_color = _colors["edge"]
		_rim_box.set_border_width_all(4)
		_rim_box.set_corner_radius_all(17)
		_rim_box.corner_detail = 12
		_rim_box.anti_aliasing = true
	c.draw_style_box(_rim_box, RIM_RECT.grow(2.0))
	var weave: Color = _colors["rim_weave"]
	for x in [40, 62, 84, 206, 228]:
		c.draw_line(Vector2(x, 152), Vector2(x + 10, 170), weave, 3.0, true)
	c.draw_line(Vector2(250, 152), Vector2(258, 166), weave, 3.0, true)


func _draw_cloth(c: CanvasItem) -> void:
	var pts := PackedVector2Array([Vector2(98, 150), Vector2(202, 150), Vector2(202, 178)])
	var scallops := [
		[Vector2(196, 192), Vector2(186, 180)], [Vector2(177, 194), Vector2(168, 180)],
		[Vector2(159, 194), Vector2(150, 180)], [Vector2(141, 194), Vector2(132, 180)],
		[Vector2(123, 194), Vector2(114, 180)], [Vector2(104, 192), Vector2(98, 178)],
	]
	for sc in scallops:
		_append_quad(pts, pts[pts.size() - 1], sc[0], sc[1])
	c.draw_colored_polygon(pts, _colors["cloth"])
	_draw_closed(c, pts, _colors["cloth_edge"], 3.0)
	for d in CLOTH_DOTS:
		c.draw_circle(d, 4.0, _colors["cloth_dot"])


func _draw_flyers(c: CanvasItem) -> void:
	var rise := (1.0 - _pour_fly) * POUR_FLY_RISE
	for i in POUR_FLYERS.size():
		var q: Array = POUR_FLYERS[i]
		var type_id := _preview_types[(i + 1) % _preview_types.size()] if not _preview_types.is_empty() else ""
		if type_id.is_empty():
			continue
		var tex := FlowerAssets.get_texture(type_id, 1)
		c.draw_set_transform(Vector2(q[0], float(q[1]) - rise), deg_to_rad(float(q[3])), Vector2.ONE)
		if tex != null:
			CampPlantDraw.draw_cropped_texture(c, Vector2.ZERO, tex, float(q[2]), Color(1, 1, 1, _pour_fly))
		else:
			ArenaChipDraw.draw_flower(c, Vector2.ZERO, type_id, 1, float(q[2]) * _pour_fly)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_counter(c: CanvasItem) -> void:
	if not _show_counter:
		return
	var cfg := UiArenaV2.BASKET_COUNTER
	var center := Vector2(cfg["c"][0], cfg["c"][1])
	var r := float(cfg["r"])
	c.draw_circle(center, r + 3.0, _colors["edge"])
	c.draw_circle(center, r, _colors["counter_edge"])
	c.draw_circle(center, r - 4.0, _colors["counter"])
	var size_px := int(cfg["font"])
	var font := UiChrome.heavy_font(UiChrome.EMBOLDEN_800)
	var baseline := center.y + (font.get_ascent(size_px) - font.get_descent(size_px)) * 0.5
	c.draw_string(
		font, Vector2(center.x - r, baseline), str(_seed_count), HORIZONTAL_ALIGNMENT_CENTER, r * 2.0,
		size_px, _colors["counter_ink"]
	)


func _draw_closed(canvas: CanvasItem, pts: PackedVector2Array, col: Color, w: float) -> void:
	var outline := pts.duplicate()
	outline.append(pts[0])
	canvas.draw_polyline(outline, col, w, true)


static func _append_quad(pts: PackedVector2Array, p0: Vector2, p1: Vector2, p2: Vector2, steps: int = 6) -> void:
	for i in range(1, steps + 1):
		var t := float(i) / steps
		pts.append(p0.lerp(p1, t).lerp(p1.lerp(p2, t), t))


static func _ellipse(c: Vector2, r: Vector2, steps: int = 40) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in steps:
		var a := TAU * float(i) / steps
		pts.append(c + Vector2(cos(a) * r.x, sin(a) * r.y))
	return pts


func _set_pour_tilt(value: float) -> void:
	_pour_tilt = value
