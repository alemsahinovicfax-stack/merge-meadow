class_name SeasonPackCard
extends ShopCard

## Shop v2 · SeasonCard 1032 x 364 na trakama sezone (Home v3: nebo 0–115, daljina,
## blizina 242–364). Šest portreta (5 × 148 + ★3 172, pravi crteži) i red: ime 52 + jedno
## dugme (cijena u store stringu → kupi; kupljena → ▶ Play vodi na Home). Ember Fen:
## crteži 50 %, „Coming soon" s isprekidanim rubom, bez cijene i dugmeta.
## Season Kit (design_handoff_seasons): sezona s receptom "shop" crta PANORAMU mjesta
## (SeasonBackdrop, 1024 x 356 unutar ruba, ništa izvan) umjesto traka; ime je u boji kita.

signal buy_pressed(sku: String)
signal open_home_pressed(season_id: String)

const SKY_H := 115.0
const NEAR_TOP := 242.0
const PORTRAIT_ROW_H := 176.0

var sku: String = ""
var season_id: String = ""
var _def: SeasonDef
var _state: String = ""
var _bands: Array[Color] = []
var _panorama: Dictionary = {}
var _portraits: Array[ShopFlowerPortrait] = []


func _ready() -> void:
	_ready_now()


func apply(pack_sku: String, busy_sku: String = "", pending: bool = false, restoring: bool = false) -> void:
	sku = pack_sku
	season_id = MonetizationConfig.season_id_for_sku(pack_sku)
	_def = SeasonCatalog.get_def(season_id)
	if _def == null:
		return
	if buy == null:
		_ready_now()
	_state = UiShopV2.season_state(_def, busy_sku, pending, restoring)
	var g: Color = UiHomeField.MEADOW_GROUND.get(season_id, Color("e6f2db"))
	_bands = UiShopV2.season_bands(g)
	var recipe := UiSeasons.recipe(season_id, "shop")
	_panorama = {} if recipe.is_empty() else SeasonBackdrop.scene(
		"shop:" + season_id, recipe, float(recipe.get("w", UiShopV2.CARD_W)), []
	)
	_build_portraits()
	var soon := _state == "soon"
	for p in _portraits:
		p.modulate.a = 0.5 if soon else 1.0
	buy.visible = not soon
	if not soon:
		buy.configure(_state, IAPManager.get_price_label(sku))
	queue_redraw()


func _ready_now() -> void:
	if buy != null:
		return
	set_card_height(UiShopV2.SEASON_CARD_H)
	_make_buy()
	buy.clicked.connect(_on_buy)


func _build_portraits() -> void:
	var roster: Array = []
	for r in _def.roster:
		roster.append(r)
	while _portraits.size() < roster.size():
		var p := ShopFlowerPortrait.new()
		add_child(p)
		_portraits.append(p)
	var total := 0.0
	var ds: Array[float] = []
	for r in roster:
		var d := UiShopV2.PORTRAIT_D_STAR3 if int(r.get("rarity", 1)) >= 3 else UiShopV2.PORTRAIT_D
		ds.append(float(d))
		total += float(d)
	var inner := float(UiShopV2.CARD_W) - 8.0 - PAD * 2.0
	var gap := (inner - total) / maxf(1.0, float(roster.size() - 1))
	var x := 4.0 + PAD
	for i in _portraits.size():
		var p := _portraits[i]
		p.visible = i < roster.size()
		if not p.visible:
			continue
		p.setup(str(roster[i].get("id", "")), ds[i])
		p.position = Vector2(x, 4.0 + PAD + (PORTRAIT_ROW_H - ds[i]) * 0.5)
		x += ds[i] + gap


func _on_buy() -> void:
	clear_status()
	if _state == UiShopV2.PLAY_STATE:
		open_home_pressed.emit(season_id)
	elif _state == UiShopV2.MONEY_BUY:
		buy_pressed.emit(sku)


func get_state() -> String:
	return _state


func has_panorama() -> bool:
	return not _panorama.is_empty()


func get_name_text() -> String:
	return _def.display_name if _def != null else ""


func get_price_text() -> String:
	return buy.price if buy != null and buy.visible else ""


func portrait_count() -> int:
	var n := 0
	for p in _portraits:
		if p.visible:
			n += 1
	return n


func min_portrait_d() -> float:
	var m := INF
	for p in _portraits:
		if p.visible:
			m = minf(m, p.diameter)
	return m


func _draw() -> void:
	if _def == null or _bands.size() < 3:
		return
	var w := float(UiShopV2.CARD_W)
	var full := Rect2(Vector2.ZERO, Vector2(w, card_h))
	if not _panorama.is_empty():
		_draw_panorama(full)
		_draw_front(w)
		return
	draw_style_box(UiShopV2.box(UiShopV2.SHADOW_CARD, UiShopV2.RADIUS_CARD), Rect2(Vector2(0, UiShopV2.SHADOW_CARD_Y), full.size))
	draw_style_box(UiShopV2.box(_bands[1], UiShopV2.RADIUS_CARD), full)
	var inner_r := UiShopV2.RADIUS_CARD - UiShopV2.BORDER
	var sky := UiShopV2.box(_bands[0], 0)
	sky.corner_radius_top_left = inner_r
	sky.corner_radius_top_right = inner_r
	draw_style_box(sky, Rect2(4, 4, w - 8.0, SKY_H))
	var near := UiShopV2.box(_bands[2], 0)
	near.corner_radius_bottom_left = inner_r
	near.corner_radius_bottom_right = inner_r
	draw_style_box(near, Rect2(4, 4.0 + NEAR_TOP, w - 8.0, card_h - 8.0 - NEAR_TOP))
	var edge := UiShopV2.box(Color.TRANSPARENT, UiShopV2.RADIUS_CARD, UiShopV2.BORDER)
	edge.draw_center = false
	draw_style_box(edge, full)
	_draw_front(w)


## Panorama u rectu unutar ruba; uglovi = maska u boji stranice Shopa (rub ih pokrije),
## sjena = sjena minus tijelo (maska je ne smije prekriti).
func _draw_panorama(full: Rect2) -> void:
	var inner := full.grow(-float(UiShopV2.BORDER))
	SeasonBackdrop.draw(self, _panorama, inner)
	SeasonBackdrop.draw_corner_masks(self, inner, float(UiShopV2.RADIUS_CARD - UiShopV2.BORDER), UiShopV2.PAGE)
	var shadow := SeasonBackdrop.round_rect_points(Rect2(Vector2(0, UiShopV2.SHADOW_CARD_Y), full.size), UiShopV2.RADIUS_CARD)
	for poly in Geometry2D.clip_polygons(shadow, SeasonBackdrop.round_rect_points(full, UiShopV2.RADIUS_CARD)):
		if poly.size() >= 3:
			draw_colored_polygon(poly, UiShopV2.SHADOW_CARD)
	var edge := UiShopV2.box(Color.TRANSPARENT, UiShopV2.RADIUS_CARD, UiShopV2.BORDER)
	edge.draw_center = false
	draw_style_box(edge, full)


func _draw_front(w: float) -> void:
	var ink := UiSeasons.ink_field(season_id, UiShopV2.INK_NAME_SEASON) if not _panorama.is_empty() else UiShopV2.INK_NAME_SEASON
	_draw_name_block(_def.display_name, "", 4.0 + PAD, ink)
	if _state == "soon":
		var label := UiShopV2.S_COMING_SOON
		var tw := 44.0 * 2.0 + UiHomeV3.text_w(900, 44, label)
		var r := Rect2(Vector2(w - 4.0 - PAD - tw, row_top()), Vector2(tw, UiShopV2.BUTTON_H))
		draw_style_box(UiShopV2.box(UiShopV2.DISC, UiShopV2.RADIUS_BUTTON), r)
		UiHomeV3.draw_dashed_round_rect(self, r, UiShopV2.RADIUS_BUTTON, 4.0, UiShopV2.INK)
		UiHomeV3.draw_text(self, 900, 44, label, r.position + Vector2(44.0, (r.size.y - 44.0) * 0.5), UiShopV2.INK)
