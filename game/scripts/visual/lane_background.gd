extends Sprite2D

## Smjer A — košene staze na tamnoj livadi. PNG cover je zamijenjen crtanjem.
## `apply_theme()` i dalje postavlja `modulate` (cosmetic × season) — season_run_smoke.
## Season Kit (design_handoff_seasons § Kitovi · Run): sezona s kitom crta svoje tlo,
## materijal staze (pokošene pruge | kamenčići), daljinu (0,35×), blizinu (1,0×) i
## ambijent iz UiSeasons.run_def; tint sezone se ne primjenjuje (modulate = kozmetika).
## Daljina, blizina i kamenčići su STATIČNE mreže (računaju se jednom po sezoni) —
## po frejmu se samo pomaknu (draw_set_transform), pa crtanje ne raste s frejmovima.

const SeasonThemeScript := preload("res://scripts/seasons/season_theme.gd")

const _MOW_PERIOD := 124.0
const _MOW_STRIPE := 40.0
const _FAR_PERIOD := 720.0
const _NEAR_PERIOD := 480.0
## Visina koju statične mreže pokrivaju (px baze) — i najduži telefon u 1080 širini.
const _COVER_H := 2600.0
const _LANE_EDGE := 4.0
const _SEAM_W := 6.0
const _SEAM_ON := 46.0
const _SEAM_OFF := 62.0
## Kamenčići staze po pločici 200 x period: (x, y, r).
const _PEBBLES := [[30.0, 30.0, 7.0], [130.0, 78.0, 6.0], [84.0, 54.0, 5.0]]
const _AMB_FADE := 0.1
const _AMB_ALPHA := 0.85

var _scroll_px: float = 0.0
var _run: Dictionary = {}
var _far: Dictionary = {}
var _near: Dictionary = {}
var _pebbles: Dictionary = {}
var _amb: Array = []
var _amb_fan: PackedInt32Array
var _time: float = 0.0


func _ready() -> void:
	z_index = -10
	centered = false
	texture = null
	apply_theme()
	if not get_viewport().size_changed.is_connected(_on_resized):
		get_viewport().size_changed.connect(_on_resized)


func apply_theme() -> void:
	texture = null
	centered = false
	position = Vector2.ZERO
	scale = Vector2.ONE
	_build_kit(GameState.active_season_id)
	_apply_meadow_cosmetic()
	queue_redraw()


func add_scroll(distance: float) -> void:
	_scroll_px += distance
	queue_redraw()


func has_kit() -> bool:
	return not _run.is_empty()


func ambient_count() -> int:
	return _amb.size()


func _apply_meadow_cosmetic() -> void:
	var bg_id := GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_MEADOW_BG)
	var cosmetic := CosmeticCatalog.get_meadow_modulate(bg_id)
	if has_kit():
		modulate = cosmetic
		return
	var season: Color = SeasonThemeScript.bg_modulate(GameState.active_season_id)
	modulate = cosmetic * season


func _on_resized() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta


func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x < 2.0 or vp.y < 2.0:
		return
	var sx := vp.x / 1080.0
	if has_kit():
		_draw_kit(vp, sx)
		return
	draw_rect(Rect2(Vector2.ZERO, vp), UiRun.GROUND, true)
	_draw_far(vp, sx, _scroll_px * 0.35)
	for i in 3:
		_draw_lane(i, vp, sx, _scroll_px)
	_draw_seam(405.0 * sx, vp.y)
	_draw_seam(675.0 * sx, vp.y)
	_draw_near(vp, sx, _scroll_px)


# --- Season Kit ---

func _build_kit(season_id: String) -> void:
	_run = UiSeasons.run_def(season_id)
	_far = {}
	_near = {}
	_pebbles = {}
	_amb = []
	set_process(not _run.is_empty())
	if _run.is_empty():
		return
	var far: Dictionary = _run["far"]
	var far_items: Array = []
	for a in far["at"]:
		far_items.append([str(far["shape"]), far["pal"], float(a[0]) * 10.8, float(a[1]) * 7.2, float(a[2])])
	_far = _tile_mesh(far_items, float(far.get("period", _FAR_PERIOD)))
	var near: Dictionary = _run["near"]
	var near_items: Array = []
	if near.has("posts"):
		var posts: Dictionary = near["posts"]
		var y := 0.0
		while y < _NEAR_PERIOD:
			for x in posts["x"]:
				near_items.append(["post", posts["pal"], float(x), y + 150.0, float(posts["size"])])
			y += float(posts["every"])
	for key in ["tufts", "moss", "flowers", "glints"]:
		if near.has(key):
			var g: Dictionary = near[key]
			for a in g["at"]:
				near_items.append([str(g["shape"]), g["pal"], float(a[0]), float(a[1]), float(a[2])])
	_near = _tile_mesh(near_items, float(near.get("period", _NEAR_PERIOD)))
	var mat: Dictionary = _run["material"]
	if mat.has("pebble"):
		var period := float(mat["period"])
		var meshes: Array = []
		var y := -period
		while y < _COVER_H + period:
			for p in _PEBBLES:
				meshes.append(SeasonBackdrop.shape_at("dot", [str(mat["pebble"])], Vector2(p[0], y + float(p[1])), float(p[2]) * 2.0))
			y += period
		_pebbles = SeasonBackdrop.merge_meshes(meshes)
	_amb = _ambient(_run.get("ambient", {}))


## Mreža pločica (period) od −1 do pokrivene visine: [shape, pal, x, y, size].
func _tile_mesh(items: Array, period: float) -> Dictionary:
	var meshes: Array = []
	var t := -1
	while float(t) * period < _COVER_H + period:
		for it in items:
			meshes.append(SeasonBackdrop.shape_at(str(it[0]), it[1], Vector2(float(it[2]), float(it[3]) + float(t) * period), float(it[4])))
		t += 1
	var m := SeasonBackdrop.merge_meshes(meshes)
	m["period"] = period
	return m


## Ambijent runa (≤ 24, jedna petlja): R2 niz, let drift za sec, alpha 0 → ,85 → 0.
static func _ambient(a: Dictionary) -> Array:
	var out: Array = []
	if a.is_empty():
		return out
	var q := UiSeasons.r2()
	var sz: Array = a["size"]
	var pal: Array = a["pal"]
	var sec := float(a["sec"])
	for i in mini(int(a["n"]), UiSeasons.AMBIENT_MAX):
		out.append({
			"pos": Vector2(40.0 + fposmod(0.21 + float(q["a1"]) * (i + 1), 1.0) * 1000.0, fposmod(0.63 + float(q["a2"]) * (i + 1), 1.0) * 1700.0),
			"size": lerpf(float(sz[0]), float(sz[1]), fposmod(float(q["size"]) * (i + 1), 1.0)),
			"col": UiSeasons.col(str(pal[i % pal.size()])),
			"delay": -fposmod(float(q["rot"]) * (i + 1), 1.0) * sec,
			"petal": str(a.get("shape", "")) == "petal",
		})
	return out


func _draw_kit(vp: Vector2, sx: float) -> void:
	var ci := get_canvas_item()
	draw_rect(Rect2(Vector2.ZERO, vp), UiSeasons.col(str(_run["ground"])), true)
	var far: Dictionary = _run["far"]
	_draw_tiles(ci, _far, _scroll_px * float(far.get("speed", 0.35)), sx)
	var lane := UiSeasons.col(str(_run["lane"]))
	var edge := UiSeasons.col(str(_run["laneEdge"]))
	var mat: Dictionary = _run["material"]
	for i in 3:
		var cx := UiRun.lane_x(i, vp.x)
		var w := float(UiRun.LANE_WIDTH) * sx
		var left := cx - w * 0.5
		draw_rect(Rect2(left, 0.0, w, vp.y), lane, true)
		if mat.has("stripe"):
			var period := float(mat.get("period", _MOW_PERIOD))
			var on := float(mat.get("on", _MOW_STRIPE))
			var stripe := UiSeasons.col(str(mat["stripe"]))
			var y := fposmod(_scroll_px, period) - period
			while y < vp.y:
				draw_rect(Rect2(left + _LANE_EDGE * sx, y, w - _LANE_EDGE * 2.0 * sx, on), stripe, true)
				y += period
		elif not _pebbles.is_empty():
			var period := float(mat["period"])
			draw_set_transform(Vector2(left, fposmod(_scroll_px, period) * sx), 0.0, Vector2(sx, sx))
			RenderingServer.canvas_item_add_triangle_array(ci, _pebbles["idx"], _pebbles["pts"], _pebbles["cols"])
			draw_set_transform_matrix(Transform2D.IDENTITY)
		draw_rect(Rect2(left, 0.0, _LANE_EDGE * sx, vp.y), edge, true)
		draw_rect(Rect2(left + w - _LANE_EDGE * sx, 0.0, _LANE_EDGE * sx, vp.y), edge, true)
	var seam := UiSeasons.col(str(_run["seam"]))
	for x in [405.0, 675.0]:
		var y := 0.0
		while y < vp.y:
			draw_rect(Rect2(x * sx - _SEAM_W * 0.5 * sx, y, _SEAM_W * sx, minf(_SEAM_ON, vp.y - y)), seam, true)
			y += _SEAM_ON + _SEAM_OFF
	var near: Dictionary = _run["near"]
	_draw_tiles(ci, _near, _scroll_px * float(near.get("speed", 1.0)), sx)
	_draw_ambient(sx)


func _draw_tiles(ci: RID, mesh: Dictionary, scroll: float, sx: float) -> void:
	if mesh.is_empty() or (mesh["pts"] as PackedVector2Array).is_empty():
		return
	draw_set_transform(Vector2(0.0, fposmod(scroll, float(mesh["period"])) * sx), 0.0, Vector2(sx, sx))
	RenderingServer.canvas_item_add_triangle_array(ci, mesh["idx"], mesh["pts"], mesh["cols"])
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_ambient(sx: float) -> void:
	if _amb.is_empty():
		return
	var a: Dictionary = _run["ambient"]
	var sec := float(a["sec"])
	var d: Array = a["drift"]
	var drift := Vector2(float(d[0]), float(d[1]))
	if _amb_fan.is_empty():
		for v in range(1, SeasonBackdrop.ELLIPSE_STEPS - 1):
			_amb_fan.append_array([0, v, v + 1])
	# Jedna mreža za sve čestice (jedan draw poziv).
	var pts := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	for p in _amb:
		var t := fposmod((_time - float(p["delay"])) / sec, 1.0)
		var fade := t / _AMB_FADE if t < _AMB_FADE else ((1.0 - t) / _AMB_FADE if t > 1.0 - _AMB_FADE else 1.0)
		var c: Color = p["col"]
		c.a = _AMB_ALPHA * fade
		var s := float(p["size"]) * sx
		var at := ((p["pos"] as Vector2) + drift * t) * sx
		var ry := s * (0.275 if bool(p["petal"]) else 0.5)
		SeasonAmbient._push(pts, cols, idx, SeasonBackdrop._ellipse(at, s * 0.5, ry), _amb_fan, c)
	RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), idx, pts, cols)


# --- Smjer A (sezone bez kita) ---

func _draw_lane(index: int, vp: Vector2, sx: float, scroll: float) -> void:
	var cx := UiRun.lane_x(index, vp.x)
	var width := float(UiRun.LANE_WIDTH) * sx
	var left := cx - width * 0.5
	var edge := 4.0 * sx
	draw_rect(Rect2(left, 0.0, width, vp.y), UiRun.LANE, true)
	draw_rect(Rect2(left, 0.0, edge, vp.y), UiRun.LANE_EDGE, true)
	draw_rect(Rect2(left + width - edge, 0.0, edge, vp.y), UiRun.LANE_EDGE, true)
	var shift := fposmod(scroll, _MOW_PERIOD)
	var y := shift - _MOW_PERIOD
	while y < vp.y:
		draw_rect(
			Rect2(left + edge, y, width - edge * 2.0, _MOW_STRIPE),
			UiRun.LANE_MOW,
			true
		)
		y += _MOW_PERIOD


func _draw_seam(x: float, height: float) -> void:
	var y := 0.0
	var dash := 18.0
	var gap := 14.0
	while y < height:
		var end_y := minf(y + dash, height)
		draw_line(Vector2(x, y), Vector2(x, end_y), UiRun.LANE_SEAM, 3.0, true)
		y += dash + gap


func _draw_far(vp: Vector2, sx: float, scroll: float) -> void:
	var spots := [
		Vector2(180, 90), Vector2(620, 240), Vector2(880, 120),
		Vector2(260, 480), Vector2(740, 560), Vector2(140, 640),
	]
	var shift := fposmod(scroll, _FAR_PERIOD)
	var tiles := int(ceil(vp.y / _FAR_PERIOD)) + 2
	for tile in tiles:
		var base_y := float(tile - 1) * _FAR_PERIOD + shift
		for spot in spots:
			var at := Vector2(spot.x * sx, base_y + spot.y)
			if at.y < -180.0 or at.y > vp.y + 180.0:
				continue
			draw_circle(at, 96.0 * sx, UiRun.BLOB)


func _draw_near(vp: Vector2, sx: float, scroll: float) -> void:
	var spots := [
		{"x": 48.0, "y": 30.0, "tuft": true},
		{"x": 130.0, "y": 200.0, "tuft": false},
		{"x": 72.0, "y": 360.0, "tuft": true},
		{"x": 150.0, "y": 80.0, "tuft": false},
		{"x": 980.0, "y": 70.0, "tuft": false},
		{"x": 1030.0, "y": 240.0, "tuft": true},
		{"x": 940.0, "y": 400.0, "tuft": true},
		{"x": 1000.0, "y": 140.0, "tuft": false},
	]
	var shift := fposmod(scroll, _NEAR_PERIOD)
	var tiles := int(ceil(vp.y / _NEAR_PERIOD)) + 2
	for tile in tiles:
		var base_y := float(tile - 1) * _NEAR_PERIOD + shift
		for spot in spots:
			var at := Vector2(float(spot.x) * sx, base_y + float(spot.y))
			if at.y < -40.0 or at.y > vp.y + 40.0:
				continue
			if bool(spot.tuft):
				_draw_tuft(at, sx)
			else:
				_draw_petal(at, sx)


func _draw_tuft(at: Vector2, sx: float) -> void:
	draw_circle(at + Vector2(-8, 4) * sx, 7.0 * sx, UiRun.TUFT)
	draw_circle(at + Vector2(8, 4) * sx, 7.0 * sx, UiRun.TUFT)
	draw_circle(at + Vector2(0, -8) * sx, 8.0 * sx, UiRun.TUFT)


func _draw_petal(at: Vector2, sx: float) -> void:
	draw_circle(at, 6.0 * sx, UiRun.PETAL)
	draw_circle(at + Vector2(0, -8) * sx, 4.5 * sx, UiRun.PETAL)
