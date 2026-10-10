class_name ArenaMeadowBg
extends Control

## Livada iza Arene (Arena v2, design_handoff_arena_v2 § Livade): svaka sezona je drugo mjesto,
## crtano iz recepta UiArenaV2.FIELDS — slojevi (poligoni u %) + rasuti elementi (R2 niz, bez RNG-a).
## 0 PNG. Bujnost 0 → 4 (T3 u rundi, crossfade 0,6 s) mijenja oblike; combo mijenja samo
## svjetlo (ComboLight) i kratki naklon elemenata u krugu talasa.
## Performanse: geometrija sezone (oblici, indeksi, polozaji) racuna se jednom (_build_cache);
## po frejmu se samo skaliraju tacke i boje. Crtanje ide najvise jednom po frejmu, iz _process.

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
## Keš geometrije za trenutnu sezonu i velicinu: [{line: bool, ...}] u redoslijedu crtanja.
var _chunks: Array = []
var _cache_size: Vector2 = Vector2.ZERO
var _dirty: bool = false
## Rasuti elementi (cvjetići, kamenčići…) crtaju se u svom sloju: naklon pri combou mijenja samo
## njih, pa brda i slojevi ostaju kao keširan crtež (perf 2026-10-09: naklon je svaki frejm
## iznova slao cijelu livadu, 1,2–2,6 ms).
var _scatter_layer: Control = null
var _scatter_dirty: bool = false
static var _shape_cache: Dictionary = {}


class _ScatterLayer:
	extends Control

	var bg: ArenaMeadowBg

	func _draw() -> void:
		bg._draw_chunks(self, true)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scatter_layer = _ScatterLayer.new()
	_scatter_layer.name = "ScatterLayer"
	_scatter_layer.bg = self
	_scatter_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scatter_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_scatter_layer)
	_combo_light = ColorRect.new()
	_combo_light.name = "ComboLight"
	_combo_light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_combo_light.set_anchors_preset(Control.PRESET_FULL_RECT)
	_combo_light.modulate.a = 0.0
	add_child(_combo_light)
	set_season(GameState.active_season_id if GameState != null else "")
	resized.connect(_request_redraw)
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
	_cache_size = Vector2.ZERO
	_request_redraw()


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
	_scatter_dirty = true
	if is_inside_tree():
		set_process(true)


## Crtez se trazi ovdje, a obnavlja iz _process — tako tween (koji se vrti poslije _process)
## ne izazove drugo crtanje u istom frejmu. Nivo / velicina / sezona = oba sloja.
func _request_redraw() -> void:
	_dirty = true
	_scatter_dirty = true
	if is_inside_tree():
		set_process(true)
	else:
		queue_redraw()
		if _scatter_layer != null:
			_scatter_layer.queue_redraw()


func _process(delta: float) -> void:
	if _bow_t >= 0.0:
		_bow_t += delta
		_scatter_dirty = true
		if _bow_t > float(UiArenaV2.COMBO_BOW["sec"]) + float(UiArenaV2.COMBO_BOW["delay_per_ring"]):
			_bow_t = -1.0
	var drew := false
	if _dirty:
		_dirty = false
		queue_redraw()
		drew = true
	if _scatter_dirty:
		_scatter_dirty = false
		if _scatter_layer != null:
			_scatter_layer.queue_redraw()
		drew = true
	if not drew and _bow_t < 0.0 and (_tween == null or not _tween.is_valid() or not _tween.is_running()):
		set_process(false)


## Cijela livada ide u jedan mesh po dijelu (jedan draw poziv; girlanda je zaseban AA poziv).
## Ovdje se crta sve osim rasutih elemenata (njih crta _ScatterLayer).
func _draw() -> void:
	_draw_chunks(self, false)


func _draw_chunks(canvas: CanvasItem, scatter: bool) -> void:
	if _field.is_empty():
		return
	if _cache_size != size:
		_build_cache()
	for chunk in _chunks:
		if bool(chunk.get("scatter", false)) != scatter:
			continue
		if chunk["line"]:
			canvas.draw_polyline(chunk["pts"], UiArenaV2.layer_color(chunk["fill"], _level), chunk["w"], true)
			continue
		if (chunk["entries"] as Array).is_empty():
			continue
		# Boje ovise samo o nivou bujnosti — za naklon (combo) se ne racunaju ponovo.
		if chunk["cols_level"] != _level:
			var cols := PackedColorArray()
			for e in chunk["entries"]:
				_emit_colors(e, cols)
			chunk["cols"] = cols
			chunk["cols_level"] = _level
		var pts := PackedVector2Array()
		for e in chunk["entries"]:
			pts.append_array(_entry_points(e))
		RenderingServer.canvas_item_add_triangle_array(canvas.get_canvas_item(), chunk["idx"], pts, chunk["cols"])


## Tacke unosa za trenutni nivo i naklon; rasuti element se preracuna samo kad mu se
## promijeni velicina (tokom naklona to su samo elementi u krugu talasa).
func _entry_points(e: Dictionary) -> PackedVector2Array:
	if int(e["k"]) != 2:
		return e["pts"]
	var pos: Vector2 = e["pos"]
	var sc := float(e["size"]) * UiArenaV2.scatter_grow(e["s"], _level) * _bow_scale(pos)
	if e.get("sc", -1.0) == sc:
		return e["pts_now"]
	var xf := Transform2D(0.0, Vector2(sc, sc), 0.0, pos)
	var out := PackedVector2Array()
	for part in e["parts"]:
		out.append_array(xf * (part["pts"] as PackedVector2Array))
	e["sc"] = sc
	e["pts_now"] = out
	return out


func _emit_colors(e: Dictionary, cols: PackedColorArray) -> void:
	match int(e["k"]):
		0:  # sloj ili pozadina: boja po nivou
			cols.append_array(_filled(e["n"], UiArenaV2.layer_color(e["fill"], _level)))
		1:  # oblik fiksne boje (mjesec)
			cols.append_array(e["cols"])
		2:  # rasuti element: alpha po nivou
			var alpha := UiArenaV2.scatter_alpha(e["s"], int(e["i"]), _level)
			for part in e["parts"]:
				var c: Color = part["color"]
				c.a *= alpha
				cols.append_array(_filled(part["n"], c))


func _build_cache() -> void:
	_cache_size = size
	_chunks.clear()
	var chunk := _new_chunk()
	var base_pts := PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0.0), size, Vector2(0.0, size.y)])
	_add_entry(chunk, {"k": 0, "pts": base_pts, "n": 4, "fill": _field["base"]}, PackedInt32Array([0, 1, 2, 0, 2, 3]))
	var layers: Array = _field["layers"]
	for li in layers.size():
		var layer: Dictionary = layers[li]
		var kind := str(layer["kind"])
		if kind == "shape":
			var at: Array = layer["at"]
			var pos := Vector2(float(at[0]) * size.x / 100.0, float(at[1]) * size.y / 100.0)
			var xf := Transform2D(0.0, Vector2.ONE * float(layer["size"]), 0.0, pos)
			for part in _shape_mesh(str(layer["shape"])):
				var pal: Array = layer["palette"]
				var c := _color(str(pal[mini(int(part["ci"]), pal.size() - 1)]))
				var pts: PackedVector2Array = xf * (part["pts"] as PackedVector2Array)
				_add_entry(chunk, {"k": 1, "pts": pts, "cols": _filled(pts.size(), c)}, part["idx"])
			continue
		var polys: Array = layer["polys"]
		for k in polys.size():
			var pts := _pct_points(polys[k], size)
			if kind == "line":
				_chunks.append(chunk)
				_chunks.append({"line": true, "pts": pts, "fill": layer["fill"], "w": float(layer.get("w", 4.0))})
				chunk = _new_chunk()
				continue
			var tris: Array = _layer_tris[li] if li < _layer_tris.size() else []
			var idx: PackedInt32Array = tris[k] if k < tris.size() else PackedInt32Array()
			if idx.is_empty():
				for v in range(1, pts.size() - 1):
					idx.append_array([0, v, v + 1])
			_add_entry(chunk, {"k": 0, "pts": pts, "n": pts.size(), "fill": layer["fill"]}, idx)
	# Rasuti elementi su uvijek zadnji — idu u svoj dio, koji crta _ScatterLayer.
	_chunks.append(chunk)
	chunk = _new_chunk()
	chunk["scatter"] = true
	for s in _field["scatter"]:
		var parts := _shape_mesh(str(s["shape"]))
		var n: Array = s["n"]
		for i in int(n[1]):
			var it := UiArenaV2.scatter_instance(s, i)
			if bool(it["avoided"]):
				continue
			var p: Vector2 = it["pos"]
			var rot := Transform2D(deg_to_rad(float(it["rot"])), Vector2.ZERO)
			var pal: Array = it["palette"]
			var inst_parts: Array = []
			var idx := PackedInt32Array()
			var offset := 0
			for part in parts:
				var pts: PackedVector2Array = rot * (part["pts"] as PackedVector2Array)
				inst_parts.append({
					"pts": pts, "n": pts.size(),
					"color": _color(str(pal[mini(int(part["ci"]), pal.size() - 1)])),
				})
				for v in part["idx"]:
					idx.append(offset + v)
				offset += pts.size()
			var entry := {
				"k": 2, "s": s, "i": i, "size": float(it["size"]),
				"pos": Vector2(p.x * size.x / 100.0, p.y * size.y / 100.0), "parts": inst_parts,
			}
			_add_entry(chunk, entry, idx, offset)
	_chunks.append(chunk)


func _new_chunk() -> Dictionary:
	return {"line": false, "entries": [], "idx": PackedInt32Array(), "verts": 0, "cols_level": -1.0}


func _add_entry(chunk: Dictionary, entry: Dictionary, idx: PackedInt32Array, verts: int = -1) -> void:
	var base: int = chunk["verts"]
	var all_idx: PackedInt32Array = chunk["idx"]
	for v in idx:
		all_idx.append(base + v)
	chunk["idx"] = all_idx
	chunk["verts"] = base + (verts if verts >= 0 else (entry["pts"] as PackedVector2Array).size())
	(chunk["entries"] as Array).append(entry)


static func _filled(n: int, c: Color) -> PackedColorArray:
	var out := PackedColorArray()
	out.resize(n)
	out.fill(c)
	return out


func _bow_scale(pos: Vector2) -> float:
	if _bow_t < 0.0:
		return 1.0
	var d := pos.distance_to(_bow_center)
	if d > _bow_radius:
		return 1.0
	var delay := d / _bow_radius * float(UiArenaV2.COMBO_BOW["delay_per_ring"])
	var t := clampf((_bow_t - delay) / float(UiArenaV2.COMBO_BOW["sec"]), 0.0, 1.0)
	return 1.0 + (float(UiArenaV2.COMBO_BOW["scale"]) - 1.0) * sin(PI * t)


## Oblik triangulisan jednom (jedinicni prostor): [{ci, pts, idx}]. Primitivi:
## c krug · e elipsa · p poligon · l linija · a luk · r pravougaonik (zaobljen).
static func _shape_mesh(shape_id: String) -> Array:
	if _shape_cache.has(shape_id):
		return _shape_cache[shape_id]
	var out: Array = []
	# Season Kit: oblici kojih nema u Areni v2 (bala sijena) dolaze iz kita.
	for p in UiArenaV2.SHAPES.get(shape_id, UiSeasons.shapes().get(shape_id, [])):
		var ci := int(p[p.size() - 1])
		var pts := PackedVector2Array()
		var idx := PackedInt32Array()
		match str(p[0]):
			"c":
				pts = _ellipse(Vector2(p[1], p[2]), float(p[3]), float(p[3]))
			"e":
				pts = _ellipse(Vector2(p[1], p[2]), float(p[3]), float(p[4]))
			"p":
				for q in p[1]:
					pts.append(Vector2(q[0], q[1]))
			"r":
				pts = _rect_points(float(p[1]), float(p[2]), float(p[3]), float(p[4]), float(p[5]))
			"l":
				_append_stroke(pts, idx, [Vector2(p[1], p[2]), Vector2(p[3], p[4])], float(p[5]))
			"a":
				var arc: Array = []
				for k in ARC_STEPS + 1:
					var a := deg_to_rad(lerpf(float(p[4]), float(p[5]), float(k) / ARC_STEPS))
					arc.append(Vector2(p[1], p[2]) + Vector2(cos(a), sin(a)) * float(p[3]))
				_append_stroke(pts, idx, arc, float(p[6]))
		if idx.is_empty() and pts.size() >= 3:
			idx = Geometry2D.triangulate_polygon(pts)
			if idx.is_empty():
				for k in range(1, pts.size() - 1):
					idx.append_array([0, k, k + 1])
		if not idx.is_empty():
			out.append({"ci": ci, "pts": pts, "idx": idx})
	_shape_cache[shape_id] = out
	return out


## Linija sirine w kao niz cetvorouglova (isto kao draw_line / draw_polyline bez AA).
static func _append_stroke(pts: PackedVector2Array, idx: PackedInt32Array, line: Array, w: float) -> void:
	for k in line.size() - 1:
		var a: Vector2 = line[k]
		var b: Vector2 = line[k + 1]
		var d := b - a
		if d.length_squared() < 1e-8:
			continue
		var n := Vector2(-d.y, d.x).normalized() * w * 0.5
		var base := pts.size()
		pts.append_array([a + n, b + n, b - n, a - n])
		idx.append_array([base, base + 1, base + 2, base, base + 2, base + 3])


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
	_request_redraw()
