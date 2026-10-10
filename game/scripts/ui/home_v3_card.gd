class_name HomeV3Card
extends Control

## SeasonCard (HomeScreen.dc.html): minijatura livade, radius 48 i sjenka 0 12 0.
## Rub (CardEdge) je poseban cvor iznad polja. Sadrzaj (ime cvijeca, status) je dijete
## `content`, jer blijedi odvojeno (CONTENT_OUT), a livada ostaje — kartica se u prelazu
## raširi u livadu.
## Season Kit (design_handoff_seasons, faze 1 + 2): svih 8 sezona crta ISTI recept kao
## polje (SeasonBackdrop) u rectu kartice — na u = 1 isti pikseli kao livada, bez šava.
## SeasonBackdrop ne crta ništa izvan recta (rez geometrije); uglovi = maska u boji
## stranice (bez clip_children), sjena = sjena minus tijelo. Stare tri trake su obrisane.
## Livada svake sezone je svoj sloj, nacrtan jednom (perf 2026-10-10): prelaz između sezona
## je ranije iznova bilježio i slao cijelu mrežu livade (~10 ms skripte + 10–20 ms rendera
## po swipeu). Sada se samo sakrije jedan sloj i pokaže drugi; crta se iznova samo kad se
## promijeni veličina (otvaranje polja).

var content: HomeV3CardContent
var _scene: Dictionary = {}
var _page := Color.WHITE
var _radius: float = UiHomeV3.CARD_RADIUS
var _shadow_y: float = UiHomeV3.CARD_SHADOW_Y
var _backdrops: Control
var _layers: Dictionary = {}
var _layer: _Backdrop = null
var _frame: _Frame


class _Backdrop:
	extends Control

	var scene: Dictionary = {}

	func _draw() -> void:
		SeasonBackdrop.draw(self, scene, Rect2(Vector2.ZERO, size))


## Maske uglova i sjena — iznad livade, ispod sadržaja.
class _Frame:
	extends Control

	var card: HomeV3Card

	func _draw() -> void:
		card._draw_frame(self)


func _init() -> void:
	name = "SeasonCard"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = UiHomeV3.CARD_RECT.size
	_backdrops = _full_rect(Control.new(), "Backdrops")
	add_child(_backdrops)
	_frame = _full_rect(_Frame.new(), "Frame") as _Frame
	_frame.card = self
	add_child(_frame)
	content = HomeV3CardContent.new()
	add_child(content)


func _full_rect(c: Control, node_name: String) -> Control:
	c.name = node_name
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	return c


## Kit sezone. `page` = boja stranice iza uglova.
func set_season(season_id: String, page: Color) -> void:
	var sc := SeasonBackdrop.field_scene(season_id)
	if page != _page:
		_page = page
		_frame.queue_redraw()
	if is_same(sc, _scene):
		return
	_scene = sc
	if _layer != null:
		_layer.visible = false
	_layer = _layers.get(season_id) as _Backdrop
	if _layer == null:
		_layer = _full_rect(_Backdrop.new(), "Backdrop_%s" % season_id) as _Backdrop
		_layers[season_id] = _layer
		_backdrops.add_child(_layer)
	_layer.scene = sc
	_layer.visible = true


func has_kit() -> bool:
	return not _scene.is_empty()


func set_shape(radius: float, shadow_y: float) -> void:
	if is_equal_approx(_radius, radius) and is_equal_approx(_shadow_y, shadow_y):
		return
	_radius = radius
	_shadow_y = shadow_y
	_frame.queue_redraw()


## Sadrzaj ostaje 1032 x 1160, centriran po x i prilijepljen uz vrh kartice.
func layout_content() -> void:
	if content:
		content.position = Vector2(roundf(size.x * 0.5 - UiHomeV3.CARD_RECT.size.x * 0.5), 0.0)
		content.size = UiHomeV3.CARD_RECT.size


func _draw_frame(canvas: CanvasItem) -> void:
	if _scene.is_empty():
		return
	var body := Rect2(Vector2.ZERO, size)
	SeasonBackdrop.draw_corner_masks(canvas, body, _radius, _page)
	if _shadow_y > 0.01:
		var shadow := SeasonBackdrop.round_rect_points(Rect2(Vector2(0.0, _shadow_y), size), _radius)
		var card := SeasonBackdrop.round_rect_points(body, _radius)
		for poly in Geometry2D.clip_polygons(shadow, card):
			if poly.size() >= 3:
				canvas.draw_colored_polygon(poly, UiHomeV3.CARD_SHADOW)
