class_name ArenaMeadowBg
extends Control

## Livada iza Arene (Arena v2, design_handoff_arena_v2 § Livade): svaka sezona je drugo mjesto,
## crtano iz recepta UiArenaV2.FIELDS — slojevi (poligoni u %) + rasuti elementi (R2 niz, bez RNG-a).
## 0 PNG. Bujnost 0 → 4 (T3 u rundi, crossfade 0,6 s) mijenja oblike; combo mijenja samo
## svjetlo (ComboLight) i kratki naklon elemenata u krugu talasa.

const MAX_LEVEL := 4.0
const CROSSFADE_SEC := 0.6
const ELLIPSE_STEPS := 20
const ARC_STEPS := 8
const RECT_CORNER_STEPS := 4

## Ciljna boja tla (bez animacije) — ranije ColorRect.color.
var color: Color:
	get:
		var base: Array = _field["base"]
		return UiArenaV2.layer_color(base, _target_level)

var _season_id: String = ""
var _field: Dictionary = {}
var _level: float = 0.0
var _target_level: float = 0.0
var _tween: Tween = null
## Triangulacija po sloju/poligonu (u %, ne ovisi o velicini) — racuna se jednom po sezoni.
var _layer_tris: Array = []
var _combo_light: ColorRect = null
var _light_tween: Tween = null
var _bow_center: Vector2 = Vector2.ZERO
var _bow_radius: float = 0.0
var _bow_t: float = -1.0
var _colors: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_combo_light = ColorRect.new()
	_combo_light.name = "ComboLight"
	_combo_light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_combo_light.set_anchors_preset(Control.PRESET_FULL_RECT)
	_combo_light.modulate.a = 0.0
	add_child(_combo_light)
	set_season(GameState.active_season_id if GameState != null else "")
	resized.connect(queue_redraw)
	set_process(false)


func set_season(season_id: String) -> void:
	var id := season_id if UiArenaV2.FIELDS.has(season_id) else "country_bloom"
	if id == _season_id:
		return
	_season_id = id
	_field = UiArenaV2.field(id)
	_layer_tris.clear()
	for layer in _field["layers"]:
		var tris: Array = []
		if str(layer["kind"]) == "poly":
			for poly in layer["polys"]:
				tris.append(Geometry2D.triangulate_polygon(_pct_points(poly, Vector2(100.0, 100.0))))
		_layer_tris.append(tris)
	if _combo_light != null:
		_combo_light.color = UiArenaV2.col(str(_field["combo"]["light"]))
	queue_redraw()


func get_season_id() -> String:
	return _season_id


## Svi poligoni sezone su triangulisani (headless provjera recepta).
func all_layers_triangulated() -> bool:
	for i in _layer_tris.size():
		for tri in _layer_tris[i]:
			if (tri as PackedInt32Array).is_empty():
				return false
	return true


func set_t3_level(level: float, animated: bool) -> void:
	_target_level = clampf(level, 0.0, MAX_LEVEL)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not animated or not is_inside_tree():
		_set_level(_target_level)
		return
	_tween = create_tween()
	_tween.tween_method(_set_level, _level, _target_level, CROSSFADE_SEC)


func get_level() -> float:
	return _level


## Combo svjetlo: ravan preklop boje sezone, ulaz 0,2 s (cubic out) na svaki merge.
func set_combo_light(alpha: float) -> void:
	_tween_light(alpha, UiArenaV2.COMBO_LIGHT["in_sec"], Tween.TRANS_CUBIC, Tween.EASE_OUT)


## Povratak na 0 za 0,35 s (cubic in-out) kad combo prozor istekne.
func clear_combo_light() -> void:
	_tween_light(0.0, UiArenaV2.COMBO_LIGHT["out_sec"], Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)


func get_combo_light_alpha() -> float:
	return _combo_light.modulate.a if _combo_light != null else 0.0


## Od combo 4: elementi u krugu talasa se kratko naklone (1 → 1,18 → 1), kasne po udaljenosti.
func play_bow(center: Vector2, radius: float) -> void:
	_bow_center = center
	_bow_radius = maxf(radius, 1.0)
	_bow_t = 0.0
	set_process(true)


func _process(delta: float) -> void:
	if _bow_t < 0.0:
		set_process(false)
		return
	_bow_t += delta
	if _bow_t > float(UiArenaV2.COMBO_BOW["sec"]) + float(UiArenaV2.COMBO_BOW["delay_per_ring"]):
		_bow_t = -1.0
		set_process(false)
	queue_redraw()


func _draw() -> void:
	if _field.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, size), UiArenaV2.layer_color(_field["base"], _level))
	var layers: Array = _field["layers"]
	for i in layers.size():
		_draw_layer(layers[i], _layer_tris[i] if i < _layer_tris.size() else [])
	for s in _field["scatter"]:
		_draw_scatter(s)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_layer(layer: Dictionary, tris: Array) -> void:
	var kind := str(layer["kind"])
	if kind == "shape":
		var at: Array = layer["at"]
		var pos := Vector2(float(at[0]) * size.x / 100.0, float(at[1]) * size.y / 100.0)
		_draw_shape(str(layer["shape"]), layer["palette"], pos, 0.0, float(layer["size"]), 1.0)
		return
	var col := UiArenaV2.layer_color(layer["fill"], _level)
	var polys: Array = layer["polys"]
	for k in polys.size():
		var pts := _pct_points(polys[k], size)
		if kind == "line":
			draw_polyline(pts, col, float(layer.get("w", 4.0)), true)
			continue
		var idx: PackedInt32Array = tris[k] if k < tris.size() else PackedInt32Array()
		if idx.is_empty():
			draw_colored_polygon(pts, col)
		else:
			var colors := PackedColorArray()
			colors.resize(pts.size())
			colors.fill(col)
			RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), idx, pts, colors)


func _draw_scatter(s: Dictionary) -> void:
	var grow := UiArenaV2.scatter_grow(s, _level)
	var n: Array = s["n"]
	for i in int(n[1]):
		var alpha := UiArenaV2.scatter_alpha(s, i, _level)
		if alpha <= 0.0:
			continue
		var it := UiArenaV2.scatter_instance(s, i)
		if bool(it["avoided"]):
			continue
		var p: Vector2 = it["pos"]
		var pos := Vector2(p.x * size.x / 100.0, p.y * size.y / 100.0)
		var sc := float(it["size"]) * grow * _bow_scale(pos)
		_draw_shape(str(s["shape"]), it["palette"], pos, float(it["rot"]), sc, alpha)


func _bow_scale(pos: Vector2) -> float:
	if _bow_t < 0.0:
		return 1.0
	var d := pos.distance_to(_bow_center)
	if d > _bow_radius:
		return 1.0
	var delay := d / _bow_radius * float(UiArenaV2.COMBO_BOW["delay_per_ring"])
	var t := clampf((_bow_t - delay) / float(UiArenaV2.COMBO_BOW["sec"]), 0.0, 1.0)
	return 1.0 + (float(UiArenaV2.COMBO_BOW["scale"]) - 1.0) * sin(PI * t)


## Oblik iz UiArenaV2.SHAPES (jedinica = velicina elementa, y nadole). Primitivi:
## c krug · e elipsa · p poligon · l linija · a luk · r pravougaonik (zaobljen).
func _draw_shape(shape_id: String, palette: Array, pos: Vector2, rot_deg: float, sc: float, alpha: float) -> void:
	var prims: Array = UiArenaV2.SHAPES.get(shape_id, [])
	if prims.is_empty() or sc <= 0.0:
		return
	draw_set_transform(pos, deg_to_rad(rot_deg), Vector2(sc, sc))
	for p in prims:
		var ci := int(p[p.size() - 1])
		var c := _color(str(palette[mini(ci, palette.size() - 1)]))
		c.a *= alpha
		match str(p[0]):
			"c":
				draw_colored_polygon(_ellipse(Vector2(p[1], p[2]), float(p[3]), float(p[3])), c)
			"e":
				draw_colored_polygon(_ellipse(Vector2(p[1], p[2]), float(p[3]), float(p[4])), c)
			"p":
				var pts := PackedVector2Array()
				for q in p[1]:
					pts.append(Vector2(q[0], q[1]))
				draw_colored_polygon(pts, c)
			"r":
				draw_colored_polygon(_rect_points(float(p[1]), float(p[2]), float(p[3]), float(p[4]), float(p[5])), c)
			"l":
				draw_line(Vector2(p[1], p[2]), Vector2(p[3], p[4]), c, float(p[5]))
			"a":
				var arc := PackedVector2Array()
				for k in ARC_STEPS + 1:
					var a := deg_to_rad(lerpf(float(p[4]), float(p[5]), float(k) / ARC_STEPS))
					arc.append(Vector2(p[1], p[2]) + Vector2(cos(a), sin(a)) * float(p[3]))
				draw_polyline(arc, c, float(p[6]))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _color(value: String) -> Color:
	if not _colors.has(value):
		_colors[value] = UiArenaV2.col(value)
	return _colors[value]


static func _pct_points(poly: Array, box: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for q in poly:
		pts.append(Vector2(float(q[0]) * box.x / 100.0, float(q[1]) * box.y / 100.0))
	return pts


static func _ellipse(c: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in ELLIPSE_STEPS:
		var a := TAU * float(k) / ELLIPSE_STEPS
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


static func _rect_points(x: float, y: float, w: float, h: float, rad: float) -> PackedVector2Array:
	var r := minf(rad, minf(w, h) * 0.5)
	if r <= 0.0:
		return PackedVector2Array([Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)])
	var pts := PackedVector2Array()
	var corners := [
		[Vector2(x + w - r, y + r), -90.0], [Vector2(x + w - r, y + h - r), 0.0],
		[Vector2(x + r, y + h - r), 90.0], [Vector2(x + r, y + r), 180.0],
	]
	for cn in corners:
		for k in RECT_CORNER_STEPS + 1:
			var a := deg_to_rad(float(cn[1]) + k * 90.0 / RECT_CORNER_STEPS)
			pts.append((cn[0] as Vector2) + Vector2(cos(a), sin(a)) * r)
	return pts


func _tween_light(target: float, sec: float, trans: Tween.TransitionType, ease_type: Tween.EaseType) -> void:
	if _combo_light == null:
		return
	if _light_tween != null and _light_tween.is_valid():
		_light_tween.kill()
	if not is_inside_tree():
		_combo_light.modulate.a = target
		return
	_light_tween = create_tween()
	_light_tween.tween_property(_combo_light, "modulate:a", target, sec).set_trans(trans).set_ease(ease_type)


func _set_level(value: float) -> void:
	_level = value
	queue_redraw()
