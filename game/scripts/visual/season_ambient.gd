class_name SeasonAmbient
extends Control

## Ambijent polja sezone (design_handoff_seasons § Kitovi, ambientParticles u seasons_kit.js):
## deterministički R2 niz (bez RNG-a), ≤ 24 čestice, JEDNA petlja. Po frejmu samo pomak
## i alpha; crta se u rectu ovog čvora (polje = stranica). Ne radi dok je skriven.
## Sve čestice idu u JEDNU mrežu trokuta po frejmu (jedan draw poziv).
##   petals  — latica (elipsa 1 : 0,55) klizi (drift) i rotira 220°, alpha 0 → ,9 → 0
##   stars_motes — zvjezdice trepere (,2 ↔ 1) + mrvice mjesečine se dižu (−24, −170)

const PETAL_FADE := 0.12
const MOTE_FADE := 0.2
const PETAL_ALPHA := 0.9
const MOTE_ALPHA := 0.85
const MOTE_RISE := Vector2(-24.0, -170.0)
## Zvjezdica iz clip-patha (% kutije): 8 tačaka.
const STAR := [
	Vector2(0.5, 0.0), Vector2(0.6, 0.4), Vector2(1.0, 0.5), Vector2(0.6, 0.6),
	Vector2(0.5, 1.0), Vector2(0.4, 0.6), Vector2(0.0, 0.5), Vector2(0.4, 0.4),
]

var _parts: Array = []
var _def: Dictionary = {}
var _time: float = 0.0
var _fade: float = 1.0
var _fade_tween: Tween = null
var _petal: PackedVector2Array
var _dot: PackedVector2Array
var _star: PackedVector2Array
var _fan_idx: PackedInt32Array
var _star_idx: PackedInt32Array


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_petal = SeasonBackdrop._ellipse(Vector2.ZERO, 0.5, 0.275)
	_dot = SeasonBackdrop._ellipse(Vector2.ZERO, 0.5, 0.5)
	for p in STAR:
		_star.append((p as Vector2) - Vector2(0.5, 0.5))
	for v in range(1, _dot.size() - 1):
		_fan_idx.append_array([0, v, v + 1])
	_star_idx = Geometry2D.triangulate_polygon(_star)
	visibility_changed.connect(_sync_process)
	_sync_process()


## Sezona bez kita → prazno (ništa se ne crta ni ne vrti).
func set_season(season_id: String) -> void:
	_def = UiSeasons.ambient(season_id)
	_parts = particles(_def)
	_sync_process()
	queue_redraw()


func particle_count() -> int:
	return _parts.size()


func is_looping() -> bool:
	return is_processing()


## Ulaz poslije prelaza: alpha 0 → 1 za 0,3 s (Home v3 · ambijent tek na u = 1).
func fade_in() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade = 0.0
	if not is_inside_tree():
		_fade = 1.0
		return
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "_fade", 1.0, UiSeasons.AMBIENT_FADE_IN)


## Čestice u % recta: {kind, pos, size, col, delay}. Isto kao ambientParticles u JS.
static func particles(a: Dictionary) -> Array:
	var out: Array = []
	if a.is_empty():
		return out
	var q := UiSeasons.r2()
	var a1 := float(q["a1"])
	var a2 := float(q["a2"])
	var qs := float(q["size"])
	var qr := float(q["rot"])
	var pal: Array = a.get("pal", ["#FFFFFF"])
	var sec := float(a.get("sec", 6.0))
	if str(a.get("id", "")) == "petals":
		var z: Array = a["zone"]
		var sz: Array = a["size"]
		for i in int(a["n"]):
			out.append({
				"kind": "petal",
				"pos": Vector2(float(z[0]) + fposmod(0.21 + a1 * (i + 1), 1.0) * float(z[2]), float(z[1]) + fposmod(0.63 + a2 * (i + 1), 1.0) * float(z[3])),
				"size": lerpf(float(sz[0]), float(sz[1]), fposmod(qs * (i + 1), 1.0)),
				"col": UiSeasons.col(str(pal[i % pal.size()])),
				"delay": -fposmod(qr * (i + 1), 1.0) * sec, "sec": sec,
			})
	else:
		var z: Array = a.get("zone", [0, 0, 100, 30])
		var mz: Array = a.get("moteZone", z)
		for i in int(a.get("twinkle", 0)):
			out.append({
				"kind": "twinkle",
				"pos": Vector2(float(z[0]) + fposmod(0.4 + a1 * (i + 1), 1.0) * float(z[2]), float(z[1]) + fposmod(0.1 + a2 * (i + 1), 1.0) * float(z[3])),
				"size": 7.0 + 5.0 * fposmod(qs * (i + 1), 1.0),
				"col": UiSeasons.col(str(pal[0])),
				"delay": -fposmod(qr * (i + 1), 1.0) * sec, "sec": sec,
			})
		for i in int(a.get("motes", 0)):
			out.append({
				"kind": "mote",
				"pos": Vector2(float(mz[0]) + fposmod(0.7 + a1 * (i + 1), 1.0) * float(mz[2]), float(mz[1]) + fposmod(0.3 + a2 * (i + 1), 1.0) * float(mz[3])),
				"size": 6.0 + 4.0 * fposmod(qs * (i + 2), 1.0),
				"col": UiSeasons.col(str(pal[mini(1, pal.size() - 1)])),
				"delay": -fposmod(qr * (i + 3), 1.0) * sec * 2.0, "sec": sec * 2.0,
			})
	return out.slice(0, UiSeasons.AMBIENT_MAX)


func _sync_process() -> void:
	set_process(is_visible_in_tree() and not _parts.is_empty())


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if _parts.is_empty() or size.x < 2.0:
		return
	var drift := Vector2.ZERO
	if _def.has("drift"):
		var d: Array = _def["drift"]
		drift = Vector2(float(d[0]), float(d[1]))
	var pct := size / 100.0
	var pts := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	for p in _parts:
		var sec := float(p["sec"])
		var t := fposmod((_time - float(p["delay"])) / sec, 1.0)
		var at: Vector2 = (p["pos"] as Vector2) * pct
		var s := float(p["size"])
		var c: Color = p["col"]
		match str(p["kind"]):
			"petal":
				c.a = PETAL_ALPHA * _edge_fade(t, PETAL_FADE) * _fade
				var xf := Transform2D(deg_to_rad(220.0 * t), Vector2(s, s), 0.0, at + drift * t)
				_push(pts, cols, idx, xf * _petal, _fan_idx, c)
			"twinkle":
				c.a = lerpf(0.2, 1.0, 0.5 - 0.5 * cos(TAU * t)) * _fade
				_push(pts, cols, idx, Transform2D(0.0, Vector2(s, s), 0.0, at + Vector2(s, s) * 0.5) * _star, _star_idx, c)
			"mote":
				var am := t / MOTE_FADE if t < MOTE_FADE else (1.0 - t) / (1.0 - MOTE_FADE)
				c.a = MOTE_ALPHA * am * _fade
				_push(pts, cols, idx, Transform2D(0.0, Vector2(s, s), 0.0, at + MOTE_RISE * t) * _dot, _fan_idx, c)
	if not pts.is_empty():
		RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), idx, pts, cols)


static func _push(pts: PackedVector2Array, cols: PackedColorArray, idx: PackedInt32Array, shape: PackedVector2Array, shape_idx: PackedInt32Array, c: Color) -> void:
	var base := pts.size()
	pts.append_array(shape)
	for v in shape_idx:
		idx.append(base + v)
	var n := cols.size()
	cols.resize(n + shape.size())
	for i in shape.size():
		cols[n + i] = c


static func _edge_fade(t: float, edge: float) -> float:
	if t < edge:
		return t / edge
	if t > 1.0 - edge:
		return (1.0 - t) / edge
	return 1.0
