extends Node2D

## Prepreka — tijelo 176×150 + ovratnik. Kolizija ostaje 64×64 na roditelju.
## v1 motivi: stone i stump. Hay je u UiRun.obstacle_colors, ali se ne spawna.
## Season Kit (design_handoff_seasons § Odlučeno 9): sezona s kitom crta svoje dvije
## prepreke (SVG 176 x 150; "stone" → prva, "stump" → druga) s ovratnikom u boji kita
## i sjenom ispod; kolizija 64 x 64 ostaje na roditelju.

## Iz RunScreen.dc.html (kutija 260 x 230 oko centra): sjena 168 x 40 na y +55,
## ovratnik na y +69, tijelo centrirano na y −6.
const KIT_SHADOW := Color(0.039, 0.055, 0.078, 0.30)
const KIT_SHADOW_SIZE := Vector2(168, 40)
const KIT_SHADOW_Y := 55.0
const KIT_COLLAR_Y := 69.0
const KIT_BODY_Y := -6.0
const KIT_COLLAR_EDGE_W := 3.0


static var _tex_cache: Dictionary = {}


func _ready() -> void:
	queue_redraw()


func _kind() -> String:
	var parent := get_parent()
	if parent != null and "kind" in parent:
		return str(parent.kind)
	return "stone"


## Tekstura prepreke kita za aktivnu sezonu (null = današnji kamen/panj).
func kit_texture() -> Texture2D:
	var path := UiSeasons.obstacle_texture(GameState.active_season_id, 1 if _kind() == "stump" else 0)
	if path.is_empty():
		return null
	if not _tex_cache.has(path):
		_tex_cache[path] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _tex_cache[path]


func _draw() -> void:
	var tex := kit_texture()
	if tex != null:
		_draw_kit(tex)
		return
	var body := UiRun.OBSTACLE_BODY
	var body_rect := Rect2(-body * 0.5, body)
	var collar := UiRun.OBSTACLE_COLLAR
	var collar_rect := Rect2(
		-collar.x * 0.5,
		body_rect.end.y - collar.y * 0.62,
		collar.x,
		collar.y
	)
	_draw_ellipse(collar_rect.get_center(), collar, UiRun.COLLAR)
	_draw_ellipse_outline(collar_rect.get_center(), collar * 0.5, UiRun.COLLAR_EDGE, 3.0)
	var colors: Array = UiRun.obstacle_colors(_kind())
	if _kind() == "stump":
		_draw_stump(body_rect, colors)
	else:
		_draw_stone(body_rect, colors)


func _draw_kit(tex: Texture2D) -> void:
	var collar_cols: Array = UiSeasons.run_def(GameState.active_season_id).get("collar", [])
	var collar := UiRun.OBSTACLE_COLLAR
	var fill := UiSeasons.col(str(collar_cols[0])) if collar_cols.size() > 0 else UiRun.COLLAR
	var edge := UiSeasons.col(str(collar_cols[1])) if collar_cols.size() > 1 else UiRun.COLLAR_EDGE
	var cc := Vector2(0.0, KIT_COLLAR_Y)
	_draw_ellipse(cc, collar, fill)
	_draw_ellipse_outline(cc, collar * 0.5 - Vector2.ONE * KIT_COLLAR_EDGE_W * 0.5, edge, KIT_COLLAR_EDGE_W)
	_draw_ellipse(Vector2(0.0, KIT_SHADOW_Y), KIT_SHADOW_SIZE, KIT_SHADOW)
	var body := UiRun.OBSTACLE_BODY
	draw_texture_rect(tex, Rect2(Vector2(-body.x * 0.5, KIT_BODY_Y - body.y * 0.5), body), false)


func _draw_stone(body: Rect2, colors: Array) -> void:
	var fill: Color = colors[0]
	var edge: Color = colors[1]
	var light: Color = colors[2]
	var left := body.position.x
	var top := body.position.y
	var w := body.size.x
	var h := body.size.y
	var pts := PackedVector2Array([
		Vector2(left + w * 0.08, top + h * 0.30),
		Vector2(left + w * 0.24, top + h * 0.08),
		Vector2(left + w * 0.58, top + h * 0.02),
		Vector2(left + w * 0.90, top + h * 0.20),
		Vector2(left + w * 0.98, top + h * 0.52),
		Vector2(left + w, top + h),
		Vector2(left, top + h),
		Vector2(left + w * 0.02, top + h * 0.56),
	])
	draw_colored_polygon(pts, fill)
	var facet := PackedVector2Array([
		Vector2(left + w * 0.30, top + h * 0.24),
		Vector2(left + w * 0.55, top + h * 0.16),
		Vector2(left + w * 0.48, top + h * 0.40),
	])
	draw_colored_polygon(facet, light)
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, edge, 4.0, true)


func _draw_stump(body: Rect2, colors: Array) -> void:
	var fill: Color = colors[0]
	var edge: Color = colors[1]
	var cap: Color = colors[2]
	var trunk := Rect2(body.position.x + 14.0, body.position.y + 28.0, body.size.x - 28.0, body.size.y - 28.0)
	draw_rect(trunk, fill, true)
	draw_rect(trunk, edge, false, 4.0)
	var cap_center := Vector2(body.position.x + body.size.x * 0.5, body.position.y + 34.0)
	var cap_size := Vector2(body.size.x * 0.92, 52.0)
	_draw_ellipse(cap_center, cap_size, cap)
	_draw_ellipse_outline(cap_center, cap_size * 0.5, edge, 3.0)
	draw_arc(cap_center, 22.0, 0.0, TAU, 24, UiRun.STUMP_RING, 3.0, true)
	draw_arc(cap_center, 10.0, 0.0, TAU, 16, UiRun.STUMP_RING, 2.0, true)


func _draw_ellipse(center: Vector2, size: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * float(i) / 20.0
		pts.append(center + Vector2(cos(a) * size.x * 0.5, sin(a) * size.y * 0.5))
	draw_colored_polygon(pts, color)


func _draw_ellipse_outline(center: Vector2, radius: Vector2, color: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var steps := 24
	for i in steps + 1:
		var a := TAU * float(i) / float(steps)
		pts.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_polyline(pts, color, width, true)
