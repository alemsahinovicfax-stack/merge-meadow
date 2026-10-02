class_name ShopBoosterCard
extends ShopCard

## Shop v2 · BoosterCard.
##   merge_hint — jednokratna kupovina: vinjeta Arene 984 x 300 (Country Bloom polje, 5
##                sjemenki, zlatni puls na istim, MergeHintMark na najbližoj) + „Marks the
##                closest match"; kupljen → kartica `#FFF6D6` + „Yours".
##   loot_burst — više puta: portret ★3 cvijeta (204) s „+5", katanac + ime sljedeće
##                sezone + have / 20 i traka (have puna, +5 isprekidano). Nestaje kad su sve
##                besplatne sezone otključane (to odlučuje ShopScreen).

signal buy_pressed(sku: String)

const VIGNETTE := [["daisy", 150.0, "drag"], ["clover", 330.0, "idle"], ["daisy", 516.0, "pulse"],
	["tulip", 704.0, "idle"], ["daisy", 880.0, "pulse"]]
const VIS_POS := Vector2(24, 24)
const LOOT_H := 260.0
const BAR_W := 624.0

var booster_id: String = ""
var sku: String = ""
var _state: String = ""
var _target: Dictionary = {}
var _visual: Control
var _meadow: ArenaMeadowBg
var _portrait: ShopFlowerPortrait


func setup(p_booster_id: String) -> void:
	booster_id = p_booster_id
	sku = MonetizationConfig.booster_sku(booster_id)
	var vis_h := UiShopV2.PREVIEW_SIZE.y if booster_id == MonetizationConfig.BOOSTER_MERGE_HINT else LOOT_H
	set_card_height(4.0 + PAD + vis_h + PAD + float(UiShopV2.BUTTON_H) + PAD + 4.0)
	_visual = Control.new()
	_visual.name = "MergeHintVignette" if booster_id == MonetizationConfig.BOOSTER_MERGE_HINT else "LootBurstVisual"
	_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual.clip_contents = true
	_visual.position = VIS_POS
	_visual.size = Vector2(UiShopV2.PREVIEW_SIZE.x, vis_h)
	add_child(_visual)
	if booster_id == MonetizationConfig.BOOSTER_MERGE_HINT:
		_meadow = ArenaMeadowBg.new()
		_meadow.size = Vector2(1080, 1633)
		_meadow.position = Vector2(-52 + 4, -640 + 4)
		_visual.add_child(_meadow)
		_meadow.set_season("country_bloom")
		_meadow.set_t3_level(1.0, false)
	else:
		_portrait = ShopFlowerPortrait.new()
		_portrait.position = Vector2(36, 24)
	var over := _Overlay.new()
	over.card = self
	over.size = _visual.size
	if _portrait != null:
		_visual.add_child(over)
		_visual.add_child(_portrait)
		var badge := _Overlay.new()
		badge.card = self
		badge.plus_only = true
		badge.size = _visual.size
		_visual.add_child(badge)
	else:
		_visual.add_child(over)
	_make_buy()
	buy.clicked.connect(_on_buy)


func apply(busy_sku: String, pending: bool, restoring: bool) -> void:
	_state = UiShopV2.money_state(sku, busy_sku, pending, restoring)
	yours = _state == UiShopV2.OWNED_STATE
	if booster_id == MonetizationConfig.BOOSTER_LOOT_BURST:
		_target = GameState.get_loot_burst_target()
		if not _target.is_empty():
			_portrait.setup(str(_target["flower"]), UiShopV2.LOOT_PORTRAIT)
	buy.configure(_state, IAPManager.get_price_label(sku), UiShopV2.S_YOURS)
	queue_redraw()
	for c in _visual.get_children():
		if c is _Overlay:
			c.queue_redraw()


func get_state() -> String:
	return _state


func get_loot_target() -> Dictionary:
	return _target


func _on_buy() -> void:
	clear_status()
	if _state == UiShopV2.MONEY_BUY:
		buy_pressed.emit(sku)


func _draw() -> void:
	var fill := UiShopV2.CARD_YOURS if yours else UiShopV2.CARD
	_draw_card_bg(fill)
	if booster_id == MonetizationConfig.BOOSTER_MERGE_HINT:
		_draw_name_block(UiShopV2.S_MERGE_HINT, UiShopV2.S_MERGE_HINT_SUB)
	else:
		_draw_name_block(UiShopV2.S_LOOT_BURST)


func _bands() -> Array[Color]:
	var from_id := str(_target.get("from", "country_bloom"))
	return UiShopV2.season_bands(UiHomeField.MEADOW_GROUND.get(from_id, Color("e6f2db")))


## Sloj iznad pozadine vinjete: sjemenke + oznaka (Merge Hint) ili trake + napredak (Loot
## Burst); okvir s maskiranim uglovima crta zadnji sloj.
class _Overlay:
	extends Control

	var card: ShopBoosterCard
	var plus_only: bool = false

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if card == null:
			return
		var fill := UiShopV2.CARD_YOURS if card.yours else UiShopV2.CARD
		if card.booster_id == MonetizationConfig.BOOSTER_MERGE_HINT:
			for v in ShopBoosterCard.VIGNETTE:
				var c := Vector2(float(v[1]) - 4.0, 150.0 - 4.0)
				var ring := ArenaChipDraw.Ring.PULSE if str(v[2]) == "pulse" else ArenaChipDraw.Ring.NONE
				ArenaChipDraw.draw_chip(self, c, str(v[0]), 1, false, ring, 1.0, str(v[2]) == "drag")
			UiShopV2.draw_merge_hint(self, Vector2(516.0 - 4.0, 150.0 - 4.0))
			ShopCard.draw_frame_masked(self, Rect2(Vector2.ZERO, size), UiShopV2.RADIUS_PREVIEW, UiShopV2.BORDER, fill)
			return
		if plus_only:
			_draw_plus()
			ShopCard.draw_frame_masked(self, Rect2(Vector2.ZERO, size), UiShopV2.RADIUS_PREVIEW, UiShopV2.BORDER, fill)
			return
		var b := card._bands()
		draw_rect(Rect2(Vector2.ZERO, size), b[1])
		draw_rect(Rect2(0, 0, size.x, 82), b[0])
		draw_rect(Rect2(0, 174, size.x, size.y - 174), b[2])
		var t := card.get_loot_target()
		if t.is_empty():
			return
		var x := 316.0 - 4.0
		var y := 52.0 - 4.0
		var lock := UiAssets.get_chrome_icon("icon_lock")
		if lock != null:
			draw_texture_rect(lock, Rect2(x, y + 4.0, 52, 52), false)
		var next_def: SeasonDef = SeasonCatalog.get_def(str(t["next"]))
		var name_text := next_def.display_name if next_def != null else ""
		var count := "%d / %d" % [int(t["have"]), int(t["need"])]
		var cw := UiHomeV3.text_w(900, 44, count, 0.0, true)
		UiHomeV3.draw_text(self, 900, 44, name_text, Vector2(x + 66.0, y + 8.0), UiShopV2.INK_NAME_SEASON)
		UiHomeV3.draw_text(self, 900, 44, count, Vector2(x + ShopBoosterCard.BAR_W - cw, y + 8.0), UiShopV2.INK_NAME_SEASON, 0.0, true)
		var bar := Rect2(x, y + 60.0 + 26.0, ShopBoosterCard.BAR_W, 52)
		draw_style_box(UiShopV2.box(UiShopV2.DISC, 26), bar)
		var need := maxf(1.0, float(t["need"]))
		var have_w := roundf(ShopBoosterCard.BAR_W * minf(float(t["have"]), need) / need)
		if have_w > 0.0:
			var hb := UiShopV2.box(UiShopV2.OWNED, 0)
			hb.corner_radius_top_left = 26
			hb.corner_radius_bottom_left = 26
			hb.border_width_right = 4
			hb.border_color = UiShopV2.INK
			draw_style_box(hb, Rect2(bar.position, Vector2(have_w, 52)))
		var add_w := roundf(ShopBoosterCard.BAR_W * float(t["add"]) / need) - 8.0
		var add_x := have_w + 4.0
		add_w = minf(add_w, ShopBoosterCard.BAR_W - add_x - 4.0)
		if add_w > 8.0:
			var ar := Rect2(bar.position + Vector2(add_x, 4.0), Vector2(add_w, 44.0))
			draw_style_box(UiShopV2.box(UiShopV2.SEED_TILE, 18), ar)
			UiHomeV3.draw_dashed_round_rect(self, ar, 18.0, 3.0, UiShopV2.INK)
		var edge := UiShopV2.box(Color.TRANSPARENT, 26, 4)
		edge.draw_center = false
		draw_style_box(edge, bar)

	func _draw_plus() -> void:
		var r := Rect2(176.0 - 4.0, 156.0 - 4.0, 22.0 * 2.0 + UiHomeV3.text_w(900, 48, "+5"), 76.0)
		draw_style_box(UiShopV2.box(UiShopV2.INK, 38, 4, UiShopV2.DISC), r)
		UiHomeV3.draw_text(self, 900, 48, "+5", r.position + Vector2(22.0, 14.0), UiShopV2.DISC)
