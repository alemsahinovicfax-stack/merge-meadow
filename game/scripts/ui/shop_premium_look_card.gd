class_name ShopPremiumLookCard
extends ShopCard

## Shop v2 · Looks — premium kartica za pravi novac (design_handoff_muncher_premium_pip,
## shop_export.json): pregled 984 x 300 (Sir Pip three_q 246 u pozi, tap = potpis), oznaka
## „Premium" gore lijevo, ime 52 + „Meadow Knight · Looks only" 36, jedno dugme:
##   money.buy (cijena iz prodavnice) → money.busy → owned („✓ Owned", tap = obuci) / wearing
##   („✓ Wearing", kartica `#FFF6D6`, EquippedBadge 64 gore desno).
## Samo izgled (Pillar 2): nikakav efekat na sjemenke, brzinu, munchera ni nagrade.
## Bez kupovina pravim novcem (v1): cijena u coinima, dva tapa kao kozmetika (ShopCard.coin_*).

signal buy_pressed(sku: String)
signal wear_pressed(item_id: String)

const PREVIEW_POS := Vector2(24, 24)
## Iznad Pip riga u pregledu (HOST_LIFT 4 + dijelovi do 11).
const TAG_Z := 16

var item_id: String = ""
var sku: String = ""
var preview: ItemPreview
var _state: String = ""
var _worn: bool = false
var _tag: SpecialTag
var _badge: Control


func _ready() -> void:
	_ensure()


func _ensure() -> void:
	if preview != null:
		return
	set_card_height(4.0 + PAD + UiShopV2.PREVIEW_SIZE.y + PAD + float(UiShopV2.BUTTON_H) + PAD + 4.0)
	preview = ItemPreview.new()
	preview.name = "PremiumPreview"
	preview.preview_size = ItemPreview.SIZE_STAGE
	preview.async_atlas = true
	preview.position = PREVIEW_POS
	preview.size = UiShopV2.PREVIEW_SIZE
	add_child(preview)
	# Oznaka „Special" L (design_handoff_ads_only · premium_tag.json), lijevo gore +20 na slici.
	_tag = SpecialTag.new()
	_tag.name = "PremiumTag"
	_tag.size_key = "L"
	_tag.z_index = TAG_Z
	_tag.position = UiShopV2.PREMIUM_TAG_POS
	preview.add_child(_tag)
	_badge = Control.new()
	_badge.name = "EquippedBadge"
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.z_index = TAG_Z
	_badge.size = Vector2(64, 64)
	_badge.position = Vector2(UiShopV2.PREVIEW_SIZE.x - 16.0 - 64.0, 16.0)
	_badge.draw.connect(_draw_worn_badge)
	preview.add_child(_badge)
	_make_buy(UiCoinPrice.M)
	buy.owned_tappable = true
	buy.clicked.connect(_on_buy)
	buy.short_tapped.connect(func() -> void: coin_short.emit(sku))


func configure(p_item_id: String, busy_sku: String = "", pending: bool = false, restoring: bool = false,
		confirm_id: String = "") -> void:
	_ensure()
	item_id = p_item_id
	sku = CosmeticCatalog.get_sku(item_id)
	var slot := CosmeticCatalog.get_slot(item_id)
	if MonetizationConfig.iap_enabled():
		_state = UiShopV2.money_state(sku, busy_sku, pending, restoring)
	else:
		_state = UiShopV2.coin_state(sku, confirm_id)
	_worn = _state == UiShopV2.OWNED_STATE and GameState.get_equipped_cosmetic(slot) == item_id
	yours = _worn
	_badge.visible = _worn
	preview.set_frame(UiShopV2.BORDER, UiShopV2.RADIUS_PREVIEW, UiShopV2.INK, UiShopV2.CARD_YOURS if yours else UiShopV2.CARD)
	preview.configure("companion", CosmeticCatalog.get_look(item_id), {}, "country_bloom", "pip")
	buy.owned_tappable = _state == UiShopV2.OWNED_STATE and not _worn
	buy.configure(_state, ShopCard.offer_price_text(sku), UiShopV2.S_WEARING if _worn else UiShopV2.S_YOURS)
	queue_redraw()


## Upravo kupljen / obučen: Pip u pregledu skoči.
func show_bought() -> void:
	if preview != null:
		preview.hop()


func get_state() -> String:
	return _state


func is_worn() -> bool:
	return _worn


func get_buy_button() -> ShopBuyButton:
	return buy


func _on_buy() -> void:
	clear_status()
	match _state:
		UiShopV2.MONEY_BUY:
			buy_pressed.emit(sku)
		UiShopV2.OWNED_STATE:
			if not _worn:
				wear_pressed.emit(item_id)
		_:
			_coin_tap(_state, sku)


func _draw() -> void:
	_draw_card_bg(UiShopV2.CARD_YOURS if yours else UiShopV2.CARD)
	_draw_name_block(CosmeticCatalog.get_title(item_id), CosmeticCatalog.get_subtitle(item_id))


func _draw_worn_badge() -> void:
	var c := _badge.size * 0.5
	_badge.draw_circle(c, 32.0, UiShopV2.DISC)
	_badge.draw_circle(c, 28.0, UiShopV2.INK)
	_badge.draw_polyline(PackedVector2Array([c + Vector2(-9, 1), c + Vector2(-3, 7), c + Vector2(9, -5)]), UiShopV2.DISC, 5.0, true)
