extends Sprite2D

## Smjer A — košene staze na tamnoj livadi. PNG cover je zamijenjen crtanjem.
## `apply_theme()` i dalje postavlja `modulate` (cosmetic × season) — season_run_smoke.
## Season Kit (design_handoff_seasons § Kitovi · Run): sezona s kitom crta svoje tlo,
## materijal staze (kind stripe | pebble | plank | rut — pločica iz kita), daljinu (0,35×),
## blizinu (1,0×) i ambijent (isti generički format kao polje) iz UiSeasons.run_def; tint
## sezone se ne primjenjuje (modulate = kozmetika).
## Daljina, blizina i materijal staze su STATIČNE mreže (računaju se jednom po sezoni).
## Kit se crta u slojevima-djeci (tlo, daljina, staze, materijal, rubovi, blizina, ambijent)
## koji se nacrtaju JEDNOM; skrol samo pomjera daljinu, materijal i blizinu (position.y), a
## svaki frejm se crta samo ambijent (perf 2026-10-06: ranije se cijela pozadina sa svim
## mrežama slala RenderingServeru iznova svaki frejm).

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
## Pločica materijala u kitu je široka kao unutrašnjost staze (surfaces.run: lane_w 200,
## lane_inner 192) — stoji između rubova staze, od x = _LANE_EDGE.
## Run ambijent: zone u % artboarda 1080 x 1920.
const _RUN_RECT := Vector2(1080.0, 1920.0)

var _scroll_px: float = 0.0
var _run: Dictionary = {}
var _far: Dictionary = {}
var _near: Dictionary = {}
var _lane_tile: Dictionary = {}
var _amb: Array = []
var _time: float = 0.0
var _layers: Dictionary = {}


## Sloj pozadine: crta ga `paint` jednom (i pri promjeni veličine / sezone).
class _Layer:
	extends Node2D

	var paint: Callable

	func _draw() -> void:
		if paint.is_valid():
			paint.call(self)


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
	_ensure_layers()
	_redraw_all()


func add_scroll(distance: float) -> void:
	_scroll_px += distance
	if has_kit():
		_sync_scroll()
	else:
		queue_redraw()


func has_kit() -> bool:
	return not _run.is_empty()


func ambient_count() -> int:
	return _amb.size()


## modulate = samo kozmetika (Meadow BG); sezona je u bojama kita, ne u tintu.
func _apply_meadow_cosmetic() -> void:
	var bg_id := GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_MEADOW_BG)
	modulate = CosmeticCatalog.get_meadow_modulate(bg_id)


func _on_resized() -> void:
	_redraw_all()


func _process(delta: float) -> void:
	_time += delta
	if not _amb.is_empty() and _layers.has("Ambient"):
		(_layers["Ambient"] as Node2D).queue_redraw()


func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x < 2.0 or vp.y < 2.0:
		return
	# Kit crtaju slojevi-djeca; ovdje samo Smjer A (sezona bez kita).
	if has_kit():
		return
	var sx := vp.x / 1080.0
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
	_lane_tile = {}
	_amb = []
	set_process(not _run.is_empty())
	if _run.is_empty():
		return
	var far: Dictionary = _run["far"]
	_far = _tile_mesh(UiSeasons.run_items(season_id, "far"), float(far.get("period", _FAR_PERIOD)))
	var near: Dictionary = _run["near"]
	_near = _tile_mesh(UiSeasons.run_items(season_id, "near"), float(near.get("period", _NEAR_PERIOD)))
	_lane_tile = _lane_mesh(UiSeasons.lane_tile(season_id))
	_amb = SeasonAmbient.build_parts(_run.get("ambient", {}))


## Mreža pločica (period) od −1 do pokrivene visine; items = [{shape, pal, at: [[x, y, size, rot]]}].
func _tile_mesh(items: Array, period: float) -> Dictionary:
	var meshes: Array = []
	var t := -1
	while float(t) * period < _COVER_H + period:
		for it in items:
			for a in it["at"]:
				var rot := float(a[3]) if (a as Array).size() > 3 else 0.0
				meshes.append(SeasonBackdrop.shape_at(str(it["shape"]), it["pal"], Vector2(float(a[0]), float(a[1]) + float(t) * period), float(a[2]), rot))
		t += 1
	var m := SeasonBackdrop.merge_meshes(meshes)
	m["period"] = period
	return m


## Materijal staze: pločica kita {period, items: [{k: rect | circle, x, y, w, h, r, f}]}
## ponovljena vertikalno do pokrivene visine — jedna statična mreža (širina = staza igre).
static func _lane_mesh(tile: Dictionary) -> Dictionary:
	var items: Array = tile.get("items", [])
	var period := float(tile.get("period", 0.0))
	if items.is_empty() or period < 1.0:
		return {}
	var meshes: Array = []
	var y0 := -period
	while y0 < _COVER_H + period:
		for it in items:
			var c := UiSeasons.col(str(it["f"]))
			var x := _LANE_EDGE + float(it["x"])
			var pts: PackedVector2Array
			if str(it["k"]) == "circle":
				pts = SeasonBackdrop._ellipse(Vector2(x, y0 + float(it["y"])), float(it["r"]), float(it["r"]))
			else:
				pts = SeasonBackdrop._rect_points(
					x, y0 + float(it["y"]), float(it["w"]), float(it["h"]),
					float(it.get("r", 0.0)), SeasonBackdrop.RECT_CORNER_STEPS
				)
			var idx := PackedInt32Array()
			for v in range(1, pts.size() - 1):
				idx.append_array([0, v, v + 1])
			meshes.append({"pts": pts, "idx": idx, "cols": SeasonBackdrop._filled(pts.size(), c)})
		y0 += period
	var m := SeasonBackdrop.merge_meshes(meshes)
	m["period"] = period
	return m


func _ensure_layers() -> void:
	if not _layers.is_empty():
		return
	var painters := {
		"Ground": _paint_ground, "Far": _paint_far, "Lanes": _paint_lanes,
		"LaneTiles": _paint_lane_tiles, "Edges": _paint_edges, "Near": _paint_near,
		"Ambient": _paint_ambient,
	}
	for key in painters:
		var layer := _Layer.new()
		layer.name = str(key)
		layer.paint = painters[key]
		add_child(layer)
		_layers[key] = layer


## Novi kit / nova veličina ekrana: slojevi se crtaju iznova (jednom), pa skrol.
func _redraw_all() -> void:
	var kit := has_kit()
	for key in _layers:
		var layer: Node2D = _layers[key]
		layer.visible = kit
		layer.queue_redraw()
	if kit:
		_sync_scroll()
	queue_redraw()


func _vp_sx() -> Vector2:
	var vp := get_viewport_rect().size
	return Vector2(vp.x, vp.x / 1080.0) if vp.x >= 2.0 else Vector2(1080.0, 1.0)


## Skrol = samo pomak slojeva (period pločice, bez crtanja).
func _sync_scroll() -> void:
	if _layers.is_empty():
		return
	var sx := _vp_sx().y
	var far: Dictionary = _run["far"]
	var near: Dictionary = _run["near"]
	_set_scroll(_layers["Far"], _far, _scroll_px * float(far.get("speed", 0.35)), sx, true)
	_set_scroll(_layers["Near"], _near, _scroll_px * float(near.get("speed", 1.0)), sx, true)
	_set_scroll(_layers["LaneTiles"], _lane_tile, _scroll_px, sx, false)


func _set_scroll(layer: Node2D, mesh: Dictionary, scroll: float, sx: float, scaled: bool) -> void:
	if mesh.is_empty():
		return
	layer.position = Vector2(0.0, fposmod(scroll, float(mesh["period"])) * sx)
	layer.scale = Vector2(sx, sx) if scaled else Vector2.ONE


func _paint_ground(canvas: CanvasItem) -> void:
	if has_kit():
		var vp := get_viewport_rect().size
		canvas.draw_rect(Rect2(Vector2.ZERO, vp), UiSeasons.col(str(_run["ground"])), true)


func _paint_far(canvas: CanvasItem) -> void:
	_paint_mesh(canvas, _far)


func _paint_near(canvas: CanvasItem) -> void:
	_paint_mesh(canvas, _near)


func _paint_mesh(canvas: CanvasItem, mesh: Dictionary) -> void:
	if not has_kit() or mesh.is_empty() or (mesh["pts"] as PackedVector2Array).is_empty():
		return
	RenderingServer.canvas_item_add_triangle_array(canvas.get_canvas_item(), mesh["idx"], mesh["pts"], mesh["cols"])


func _paint_lanes(canvas: CanvasItem) -> void:
	if not has_kit():
		return
	var vs := _vp_sx()
	var vp := get_viewport_rect().size
	var lane := UiSeasons.col(str(_run["lane"]))
	var w := float(UiRun.LANE_WIDTH) * vs.y
	for i in 3:
		canvas.draw_rect(Rect2(UiRun.lane_x(i, vs.x) - w * 0.5, 0.0, w, vp.y), lane, true)


## Materijal staze: ista pločica u sve tri staze (sloj se pomjera po y).
func _paint_lane_tiles(canvas: CanvasItem) -> void:
	if not has_kit() or _lane_tile.is_empty():
		return
	var vs := _vp_sx()
	var w := float(UiRun.LANE_WIDTH) * vs.y
	var ci := canvas.get_canvas_item()
	for i in 3:
		var left := UiRun.lane_x(i, vs.x) - w * 0.5
		canvas.draw_set_transform(Vector2(left, 0.0), 0.0, Vector2(vs.y, vs.y))
		RenderingServer.canvas_item_add_triangle_array(ci, _lane_tile["idx"], _lane_tile["pts"], _lane_tile["cols"])
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


func _paint_edges(canvas: CanvasItem) -> void:
	if not has_kit():
		return
	var vs := _vp_sx()
	var sx := vs.y
	var vp := get_viewport_rect().size
	var edge := UiSeasons.col(str(_run["laneEdge"]))
	var w := float(UiRun.LANE_WIDTH) * sx
	for i in 3:
		var left := UiRun.lane_x(i, vs.x) - w * 0.5
		canvas.draw_rect(Rect2(left, 0.0, _LANE_EDGE * sx, vp.y), edge, true)
		canvas.draw_rect(Rect2(left + w - _LANE_EDGE * sx, 0.0, _LANE_EDGE * sx, vp.y), edge, true)
	var seam := UiSeasons.col(str(_run["seam"]))
	for x in [405.0, 675.0]:
		var y := 0.0
		while y < vp.y:
			canvas.draw_rect(Rect2(x * sx - _SEAM_W * 0.5 * sx, y, _SEAM_W * sx, minf(_SEAM_ON, vp.y - y)), seam, true)
			y += _SEAM_ON + _SEAM_OFF


## Ambijent runa: isti generički format i kod kao polje (SeasonAmbient), jedan draw poziv.
## Jedini sloj koji se crta svaki frejm.
func _paint_ambient(canvas: CanvasItem) -> void:
	if not has_kit() or _amb.is_empty():
		return
	var sx := _vp_sx().y
	var pts := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	var still := UiSeasons.REDUCE_MOTION_STOPS_AMBIENT and GameState.reduce_motion
	SeasonAmbient.append_frame(_amb, _time, Rect2(Vector2.ZERO, _RUN_RECT * sx), sx, 1.0, still, pts, cols, idx)
	if not idx.is_empty():
		RenderingServer.canvas_item_add_triangle_array(canvas.get_canvas_item(), idx, pts, cols)


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
