class_name RunProgressRail
extends Control

## Run HUD v2 · ProgressRail (design_handoff_run_hud_v2): lijevi pojas x 24–140, dno = start,
## vrh = zastavica. ProgressPip (glava iz pip_hud_classic) se penje po elapsed / duration.
## Po frejmu se mijenja samo `position.y` oznake i visina punjenja; boja jednom na 17 %.
## U Endlessu je sakrivena (nema cilja). Mjere su px baze 1080 × 1920, lokalno od RAIL_RECT.

const START_TEX := "res://assets/run/progress/progress_start.svg"
const FLAG_TEX := "res://assets/run/progress/progress_flag.svg"
const PIP_TEX := "res://assets/pip/hud/pip_hud_classic.svg"

var track: Panel
var fill: Panel
var flag: TextureRect
var finish_ring: Panel
var marker: Panel

var _fill_style: StyleBoxFlat
var _progress: float = -1.0
var _low: bool = false
var _finished: bool = false
var _flag_tween: Tween


func _init() -> void:
	name = "ProgressRail"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = UiRun.RAIL_RECT.position
	size = UiRun.RAIL_RECT.size
	_build()


func _build() -> void:
	var o := UiRun.RAIL_RECT.position
	track = Panel.new()
	track.name = "RailTrack"
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.position = UiRun.RAIL_TRACK.position - o
	track.size = UiRun.RAIL_TRACK.size
	# Bez clip_children (dodatni prolaz u GL Compat): punjenje i oznaka su po konstrukciji
	# unutar ruba staze.
	var ts := StyleBoxFlat.new()
	ts.bg_color = UiRun.CHIP_BG
	ts.border_color = UiRun.INK
	ts.set_border_width_all(UiRun.RAIL_TRACK_RIM)
	ts.set_corner_radius_all(UiRun.RAIL_TRACK_RADIUS)
	ts.shadow_color = UiRun.CHIP_SHADOW
	ts.shadow_offset = Vector2(0, UiRun.RAIL_SHADOW_Y)
	ts.shadow_size = 1
	track.add_theme_stylebox_override("panel", ts)
	add_child(track)

	# Punjenje i oznaka 50 % su u „padding boxu" staze (unutar ruba 3), kao u mockupu.
	var rim := float(UiRun.RAIL_TRACK_RIM)
	fill = Panel.new()
	fill.name = "RailFill"
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fill_style = StyleBoxFlat.new()
	_fill_style.bg_color = UiRun.RAIL_FILL
	_fill_style.set_corner_radius_all(UiRun.RAIL_FILL_RADIUS)
	fill.add_theme_stylebox_override("panel", _fill_style)
	fill.position = Vector2(rim * 2.0, 0.0)
	fill.size = Vector2(UiRun.RAIL_TRACK.size.x - rim * 4.0, 0.0)
	track.add_child(fill)

	var tick := ColorRect.new()
	tick.name = "MidTick"
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tick.color = UiRun.INK
	tick.position = Vector2(rim, UiRun.RAIL_TRACK.size.y * 0.5)
	tick.size = Vector2(UiRun.RAIL_TRACK.size.x - rim * 2.0, UiRun.RAIL_MID_TICK)
	track.add_child(tick)

	var start := _texture_rect("ProgressStart", START_TEX, UiRun.RAIL_START)
	add_child(start)

	finish_ring = Panel.new()
	finish_ring.name = "FinishRing"
	finish_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finish_ring.position = UiRun.RAIL_FINISH_RING.position - o
	finish_ring.size = UiRun.RAIL_FINISH_RING.size
	var rs := StyleBoxFlat.new()
	rs.draw_center = false
	rs.border_color = UiRun.RAIL_FILL
	rs.set_border_width_all(UiRun.RAIL_FINISH_RING_W)
	rs.set_corner_radius_all(int(UiRun.RAIL_FINISH_RING.size.x * 0.5))
	rs.corner_detail = 16
	finish_ring.add_theme_stylebox_override("panel", rs)
	finish_ring.visible = false
	add_child(finish_ring)

	flag = _texture_rect("ProgressFlag", FLAG_TEX, UiRun.RAIL_FLAG)
	flag.pivot_offset = UiRun.RAIL_FLAG_PIVOT
	add_child(flag)

	marker = Panel.new()
	marker.name = "ProgressPip"
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var side := float(UiRun.RAIL_PIP_SIZE)
	marker.size = Vector2(side, side)
	marker.position = Vector2(UiRun.RAIL_PIP_CENTER_X - side * 0.5 - o.x, UiRun.rail_pip_y(0.0) - o.y)
	marker.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	var ms := StyleBoxFlat.new()
	ms.bg_color = UiRun.CHIP_BG
	ms.border_color = UiRun.INK
	ms.set_border_width_all(UiRun.RAIL_PIP_RIM)
	ms.set_corner_radius_all(int(side * 0.5))
	ms.corner_detail = 16
	ms.shadow_color = UiRun.CHIP_SHADOW
	ms.shadow_offset = Vector2(0, 6)
	ms.shadow_size = 1
	marker.add_theme_stylebox_override("panel", ms)
	add_child(marker)
	_build_marker_art()


## Glava aktivnog companiona: Pip = statični HUD krop (bez riga koji se animira svaki frejm).
func _build_marker_art() -> void:
	var art := float(UiRun.RAIL_PIP_ART)
	var inset := float(UiRun.RAIL_PIP_RIM)
	var id := GameState.get_active_companion_id()
	if id == CompanionConfig.ID_PIP or not ResourceLoader.exists(PIP_TEX):
		var pip := TextureRect.new()
		pip.name = "Art"
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pip.texture = load(PIP_TEX) as Texture2D if ResourceLoader.exists(PIP_TEX) else null
		pip.position = Vector2(inset, inset + 2.0)
		pip.size = Vector2(art, art)
		marker.add_child(pip)
		return
	var other := _CompanionHead.new()
	other.name = "Art"
	other.companion_id = id
	other.position = Vector2(inset, inset)
	other.size = Vector2(art, art)
	marker.add_child(other)


func _texture_rect(node_name: String, path: String, rect: Rect2) -> TextureRect:
	var t := TextureRect.new()
	t.name = node_name
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture = load(path) as Texture2D if ResourceLoader.exists(path) else null
	t.position = rect.position - UiRun.RAIL_RECT.position
	t.size = rect.size
	return t


## Novi run: oznaka na startu, punjenje prazno, zastavica spuštena.
func reset() -> void:
	_finished = false
	if _flag_tween != null and _flag_tween.is_valid():
		_flag_tween.kill()
	flag.position = UiRun.RAIL_FLAG.position - UiRun.RAIL_RECT.position
	flag.scale = Vector2.ONE
	flag.rotation_degrees = 0.0
	finish_ring.visible = false
	_progress = -1.0
	set_progress(0.0)


func set_progress(p: float) -> void:
	var v := clampf(p, 0.0, 1.0)
	if is_equal_approx(v, _progress):
		return
	_progress = v
	marker.position.y = UiRun.rail_pip_y(v) - UiRun.RAIL_RECT.position.y
	var h := UiRun.rail_fill_height(v)
	var bottom := UiRun.RAIL_TRACK.size.y - float(UiRun.RAIL_TRACK_RIM) * 2.0
	fill.size.y = h
	fill.position.y = bottom - h
	fill.visible = h > 0.5
	var low := UiRun.rail_fill_color(v) == UiRun.RAIL_FILL_LOW
	if low != _low:
		_low = low
		_fill_style.bg_color = UiRun.RAIL_FILL_LOW if low else UiRun.RAIL_FILL


func get_progress() -> float:
	return maxf(_progress, 0.0)


func is_low() -> bool:
	return _low


## 100 %: zastavica se podigne (scale 1,18, −6°, 0,2 s) i dobije mint prsten 108.
func finish() -> void:
	set_progress(1.0)
	if _finished:
		return
	_finished = true
	finish_ring.visible = true
	var up := Vector2(flag.position.x, UiRun.RAIL_FLAG.position.y - UiRun.RAIL_RECT.position.y - 6.0)
	if GameState.reduce_motion:
		flag.position = up
		flag.scale = Vector2.ONE * UiRun.RAIL_FLAG_FINISH_SCALE
		flag.rotation_degrees = UiRun.RAIL_FLAG_FINISH_ROT
		return
	_flag_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var t := UiRun.RAIL_FLAG_FINISH_TIME
	_flag_tween.tween_property(flag, "position", up, t)
	_flag_tween.tween_property(flag, "scale", Vector2.ONE * UiRun.RAIL_FLAG_FINISH_SCALE, t)
	_flag_tween.tween_property(flag, "rotation_degrees", UiRun.RAIL_FLAG_FINISH_ROT, t)


func flag_center() -> Vector2:
	return flag.get_global_rect().get_center()


## Glava ne-Pip companiona (Mochi): crta se jednom, ne svaki frejm.
class _CompanionHead:
	extends Control

	var companion_id: String = ""

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()

	func _draw() -> void:
		var side := minf(size.x, size.y)
		if side >= 1.0:
			CompanionAssets.draw_portrait(self, companion_id, size * 0.5, side)
