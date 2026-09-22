extends Sprite2D

## Smjer A — košene staze na tamnoj livadi. PNG cover je zamijenjen crtanjem.
## `apply_theme()` i dalje postavlja `modulate` (cosmetic × season) — season_run_smoke.

const SeasonThemeScript := preload("res://scripts/seasons/season_theme.gd")

const _MOW_PERIOD := 124.0
const _MOW_STRIPE := 40.0
const _FAR_PERIOD := 720.0
const _NEAR_PERIOD := 480.0

var _scroll_px: float = 0.0


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
	_apply_meadow_cosmetic()
	queue_redraw()


func add_scroll(distance: float) -> void:
	_scroll_px += distance
	queue_redraw()


func _apply_meadow_cosmetic() -> void:
	var bg_id := GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_MEADOW_BG)
	var cosmetic := CosmeticCatalog.get_meadow_modulate(bg_id)
	var season: Color = SeasonThemeScript.bg_modulate(GameState.active_season_id)
	modulate = cosmetic * season


func _on_resized() -> void:
	queue_redraw()


func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x < 2.0 or vp.y < 2.0:
		return
	var sx := vp.x / 1080.0
	draw_rect(Rect2(Vector2.ZERO, vp), UiRun.GROUND, true)
	_draw_far(vp, sx, _scroll_px * 0.35)
	for i in 3:
		_draw_lane(i, vp, sx, _scroll_px)
	_draw_seam(405.0 * sx, vp.y)
	_draw_seam(675.0 * sx, vp.y)
	_draw_near(vp, sx, _scroll_px)


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
