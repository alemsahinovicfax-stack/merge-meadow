class_name ShopSupportCard
extends ShopCard

## Shop v2 · Support kartice.
##   remove_ads   — jedan red: ime + „No ads between runs" · dugme (kupljeno → „Ads off").
##   starter_pack — pločice sadržaja (100 coina · Pip Blossom · 5 sjemenki × 10) + red s
##                  „6d left" (zadnji dan u satima) · dugme. Istekao (7 dana, nije kupljen):
##                  siv veo 84 % preko cijele kartice + katanac 128 + „Expired"; veo guta tap.

signal buy_pressed(sku: String)

const STARTER_TILES_H := 228.0
const COIN_TILE_W := 236.0
const SKIN_TILE_W := 296.0
const TILE_GAP := 16.0

var sku: String = ""
var _state: String = ""
var _starter_state: String = ""
var _veil: Control


func setup(p_sku: String) -> void:
	sku = p_sku
	if sku == MonetizationConfig.SKU_STARTER_PACK:
		set_card_height(4.0 + PAD + STARTER_TILES_H + PAD + float(UiShopV2.BUTTON_H) + PAD + 4.0)
		var tiles := _Tiles.new()
		tiles.name = "StarterContent"
		tiles.card = self
		tiles.position = Vector2(4.0 + PAD, 4.0 + PAD)
		tiles.size = Vector2(UiShopV2.CARD_W - 8.0 - PAD * 2.0, STARTER_TILES_H)
		add_child(tiles)
	else:
		set_card_height(4.0 + PAD + float(UiShopV2.BUTTON_H) + PAD + 4.0)
	_make_buy()
	buy.clicked.connect(_on_buy)
	if sku == MonetizationConfig.SKU_STARTER_PACK:
		_veil = _Veil.new()
		_veil.name = "ExpiredVeil"
		_veil.position = Vector2(-4, -4)
		_veil.size = Vector2(UiShopV2.CARD_W + 8.0, card_h + 8.0)
		_veil.visible = false
		add_child(_veil)


func apply(busy_sku: String, pending: bool, restoring: bool) -> void:
	_state = UiShopV2.money_state(sku, busy_sku, pending, restoring)
	var label := UiShopV2.S_ADS_OFF
	if sku == MonetizationConfig.SKU_STARTER_PACK:
		label = UiShopV2.S_CLAIMED
		_starter_state = UiShopV2.starter_state(busy_sku)
		if _starter_state == UiShopV2.STARTER_EXPIRED:
			_state = UiShopV2.MONEY_DIM
		_veil.visible = _starter_state == UiShopV2.STARTER_EXPIRED
	yours = _state == UiShopV2.OWNED_STATE
	buy.configure(_state, IAPManager.get_price_label(sku), label)
	queue_redraw()
	for c in get_children():
		if c is _Tiles:
			c.queue_redraw()


func get_state() -> String:
	return _state


func get_starter_state() -> String:
	return _starter_state


func is_expired_veil_visible() -> bool:
	return _veil != null and _veil.visible


func _on_buy() -> void:
	clear_status()
	if _state == UiShopV2.MONEY_BUY:
		buy_pressed.emit(sku)


func _draw() -> void:
	_draw_card_bg(UiShopV2.CARD_YOURS if yours else UiShopV2.CARD)
	if sku == MonetizationConfig.SKU_REMOVE_ADS:
		_draw_name_block(UiShopV2.S_REMOVE_ADS, UiShopV2.S_REMOVE_ADS_SUB, 4.0 + 32.0)
		return
	if _starter_state == UiShopV2.STARTER_AVAILABLE and status_text.is_empty():
		_draw_starter_name_with_time()
	else:
		_draw_name_block(UiShopV2.S_STARTER_PACK)


func _draw_starter_name_with_time() -> void:
	var x := 4.0 + PAD
	var top := row_top()
	var block := NAME_PX * 1.05 + 8.0 + STATUS_H
	var y := top + (float(UiShopV2.BUTTON_H) - block) * 0.5
	UiHomeV3.draw_text(self, 900, NAME_PX, UiShopV2.S_STARTER_PACK, Vector2(x, y + NAME_PX * 0.025), UiShopV2.INK)
	y += NAME_PX * 1.05 + 8.0
	var text := UiShopV2.starter_time_text()
	var w := 14.0 + 30.0 + 10.0 + UiHomeV3.text_w(900, UiShopV2.FONT_STATUS, text) + 22.0
	var chip := Rect2(Vector2(x, y), Vector2(w, STATUS_H))
	draw_style_box(UiShopV2.box(UiShopV2.DISC, 28, 3), chip)
	var c := chip.position + Vector2(14.0 + 15.0, STATUS_H * 0.5)
	draw_arc(c, 13.0, 0.0, TAU, 24, UiShopV2.INK, 4.0, true)
	draw_line(c, c + Vector2(0, -7), UiShopV2.INK, 4.0, true)
	draw_line(c, c + Vector2(6, 0), UiShopV2.INK, 4.0, true)
	UiHomeV3.draw_text(self, 900, UiShopV2.FONT_STATUS, text, chip.position + Vector2(14.0 + 30.0 + 10.0, (STATUS_H - UiShopV2.FONT_STATUS) * 0.5), UiShopV2.INK)


## Pločice sadržaja Starter Packa.
class _Tiles:
	extends Control

	var card: ShopSupportCard

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var h := size.y
		var coin := Rect2(0, 0, ShopSupportCard.COIN_TILE_W, h)
		var skin := Rect2(coin.end.x + ShopSupportCard.TILE_GAP, 0, ShopSupportCard.SKIN_TILE_W, h)
		var seeds := Rect2(skin.end.x + ShopSupportCard.TILE_GAP, 0, size.x - skin.end.x - ShopSupportCard.TILE_GAP, h)
		for t in [[coin, UiShopV2.COIN_TILE], [skin, UiShopV2.CARD_YOURS], [seeds, UiShopV2.SEED_TILE]]:
			draw_style_box(UiShopV2.box(t[1], 24, 4), t[0])
		# 100 coina
		var tex := UiAssets.get_chrome_icon("icon_coin")
		var coin_txt := str(MonetizationConfig.STARTER_PACK_COINS)
		var top := (h - 96.0 - 12.0 - 52.0) * 0.5
		if tex != null:
			draw_texture_rect(tex, Rect2(coin.get_center().x - 48.0, top, 96, 96), false)
		var cw := UiHomeV3.text_w(900, 52, coin_txt, 0.0, true)
		UiHomeV3.draw_text(self, 900, 52, coin_txt, Vector2(coin.get_center().x - cw * 0.5, top + 108.0), UiShopV2.INK, 0.0, true)
		# Pip Blossom
		var pip := PipAssets.get_texture(MonetizationConfig.STARTER_PACK_COSMETIC)
		var skin_name := CosmeticCatalog.get_title(MonetizationConfig.STARTER_PACK_COSMETIC)
		top = (h - 152.0 - 4.0 - 34.0) * 0.5
		if pip != null:
			var ps := pip.get_size()
			var k := 152.0 / maxf(ps.x, ps.y)
			var dw := ps * k
			draw_texture_rect(pip, Rect2(Vector2(skin.get_center().x - dw.x * 0.5, top + (152.0 - dw.y) * 0.5), dw), false)
		var nw := UiHomeV3.text_w(900, 34, skin_name)
		UiHomeV3.draw_text(self, 900, 34, skin_name, Vector2(skin.get_center().x - nw * 0.5, top + 156.0), UiShopV2.INK)
		if GameState.owns_cosmetic(MonetizationConfig.STARTER_PACK_COSMETIC) and not GameState.starter_pack_owned:
			var bc := Vector2(skin.end.x - 12.0 - 30.0, 12.0 + 30.0)
			draw_circle(bc, 30.0, UiShopV2.DISC)
			draw_circle(bc, 26.0, UiShopV2.INK)
			draw_polyline(PackedVector2Array([bc + Vector2(-9, 1), bc + Vector2(-3, 7), bc + Vector2(9, -5)]), UiShopV2.DISC, 5.0, true)
		# 5 sjemenki × 10
		var types := MonetizationConfig.STARTER_PACK_SEED_TYPES
		var span := 68.0 * types.size() + 8.0 * (types.size() - 1)
		top = (h - 68.0 - 16.0 - 48.0) * 0.5
		var x0 := seeds.get_center().x - span * 0.5
		for i in types.size():
			var c := Vector2(x0 + 34.0 + float(i) * 76.0, top + 34.0)
			draw_circle(c, 34.0, UiShopV2.INK)
			draw_circle(c, 31.0, UiShopV2.DISC)
			draw_circle(c, 26.0, Color("#16211B"))
			draw_circle(c, 24.0, Color("#22342A"))
			CampPlantDraw.draw_cropped_plant(self, c, types[i], 1, 40.0)
		var times := "×%d" % MonetizationConfig.STARTER_PACK_SEEDS_EACH
		var tw := UiHomeV3.text_w(900, 48, times, 0.0, true)
		UiHomeV3.draw_text(self, 900, 48, times, Vector2(seeds.get_center().x - tw * 0.5, top + 84.0), UiShopV2.INK, 0.0, true)


## Istekao: veo preko cijele kartice, katanac i „Expired"; guta tap.
class _Veil:
	extends Control

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton or event is InputEventScreenTouch:
			accept_event()

	func _draw() -> void:
		draw_style_box(UiShopV2.box(UiShopV2.VEIL, UiShopV2.RADIUS_CARD), Rect2(Vector2.ZERO, size))
		var block := 128.0 + 20.0 + 72.0
		var top := (size.y - block) * 0.5
		var c := Vector2(size.x * 0.5, top + 64.0)
		draw_circle(c + Vector2(0, 6), 64.0, Color(UiShopV2.SHADOW_CARD, 0.24))
		draw_circle(c, 64.0, UiShopV2.INK)
		draw_circle(c, 60.0, UiShopV2.DISC)
		var lock := UiAssets.get_chrome_icon("icon_lock")
		if lock != null:
			draw_texture_rect(lock, Rect2(c - Vector2(32, 32), Vector2(64, 64)), false)
		var label := UiShopV2.S_EXPIRED
		var w := 30.0 * 2.0 + UiHomeV3.text_w(900, 44, label)
		var r := Rect2(Vector2(size.x * 0.5 - w * 0.5, top + 128.0 + 20.0), Vector2(w, 72))
		draw_style_box(UiShopV2.box(UiShopV2.DISC, 36, 4), r)
		UiHomeV3.draw_text(self, 900, 44, label, r.position + Vector2(30.0, 14.0), UiShopV2.INK)
