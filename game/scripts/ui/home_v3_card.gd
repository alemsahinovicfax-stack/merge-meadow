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

var content: HomeV3CardContent
var _scene: Dictionary = {}
var _page := Color.WHITE
var _radius: float = UiHomeV3.CARD_RADIUS
var _shadow_y: float = UiHomeV3.CARD_SHADOW_Y


func _init() -> void:
	name = "SeasonCard"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = UiHomeV3.CARD_RECT.size
	content = HomeV3CardContent.new()
	add_child(content)


## Kit sezone. `page` = boja stranice iza uglova.
func set_season(season_id: String, page: Color) -> void:
	var sc := SeasonBackdrop.field_scene(season_id)
	if is_same(sc, _scene) and page == _page:
		return
	_scene = sc
	_page = page
	queue_redraw()


func has_kit() -> bool:
	return not _scene.is_empty()


func set_shape(radius: float, shadow_y: float) -> void:
	if is_equal_approx(_radius, radius) and is_equal_approx(_shadow_y, shadow_y):
		return
	_radius = radius
	_shadow_y = shadow_y
	queue_redraw()


## Sadrzaj ostaje 1032 x 1160, centriran po x i prilijepljen uz vrh kartice.
func layout_content() -> void:
	if content:
		content.position = Vector2(roundf(size.x * 0.5 - UiHomeV3.CARD_RECT.size.x * 0.5), 0.0)
		content.size = UiHomeV3.CARD_RECT.size


func _draw() -> void:
	if _scene.is_empty():
		return
	var body := Rect2(Vector2.ZERO, size)
	SeasonBackdrop.draw(self, _scene, body)
	SeasonBackdrop.draw_corner_masks(self, body, _radius, _page)
	if _shadow_y > 0.01:
		var shadow := SeasonBackdrop.round_rect_points(Rect2(Vector2(0.0, _shadow_y), size), _radius)
		var card := SeasonBackdrop.round_rect_points(body, _radius)
		for poly in Geometry2D.clip_polygons(shadow, card):
			if poly.size() >= 3:
				draw_colored_polygon(poly, UiHomeV3.CARD_SHADOW)
