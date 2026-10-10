class_name ShopCosmeticCard
extends ShopCard

## Shop v2 · CosmeticCard: pregled 984 x 300 (ItemPreview iz Ormara, vrsta = slot.preview iz
## cosmetics.json) + red: ime 52 · jedno dugme s cijenom u coinima. Coin kupovina u dva tapa
## na istom dugmetu (coins.buy → coins.confirm, 3 s bez tapa → nazad). Nema dovoljno coina:
## coins.short — drhtaj + puls coin chipa, bez rečenice. Kupljeno: kartica `#FFF6D6`,
## EquippedBadge na pregledu kad je nošeno, dugme postane „Wearing" / „Owned".

signal buy_requested(item_id: String)
signal buy_confirmed(item_id: String)
signal short_tapped(item_id: String)

const PREVIEW_POS := Vector2(24, 24)

var item_id: String = ""
var preview: ItemPreview
var _state: String = ""
var _worn: bool = false
var _badge: Control


func _ready() -> void:
	_ensure()


func _ensure() -> void:
	if preview != null:
		return
	set_card_height(4.0 + PAD + UiShopV2.PREVIEW_SIZE.y + PAD + float(UiShopV2.BUTTON_H) + PAD + 4.0)
	preview = ItemPreview.new()
	preview.name = "CosmeticPreview"
	preview.preview_size = ItemPreview.SIZE_STAGE
	preview.async_atlas = true
	preview.position = PREVIEW_POS
	preview.size = UiShopV2.PREVIEW_SIZE
	add_child(preview)
	_badge = _Badge.new()
	_badge.name = "EquippedBadge"
	_badge.position = Vector2(UiShopV2.PREVIEW_SIZE.x - 16.0 - 64.0, 16.0)
	preview.add_child(_badge)
	_make_buy()
	buy.clicked.connect(_on_buy)
	buy.short_tapped.connect(func() -> void: short_tapped.emit(item_id))


func configure(p_item_id: String, confirm_id: String = "") -> void:
	_ensure()
	item_id = p_item_id
	var item := CosmeticCatalog.get_item(item_id)
	var slot := CosmeticCatalog.get_slot(item_id)
	var sd := CosmeticCatalog.get_slot_def(slot)
	var args: Dictionary = sd.get("preview_args", {})
	_state = UiShopV2.cosmetic_state(item, confirm_id)
	_worn = GameState.get_equipped_cosmetic(slot) == item_id
	yours = _state == UiShopV2.OWNED_STATE
	_badge.visible = _worn
	var fill := UiShopV2.CARD_YOURS if yours else UiShopV2.CARD
	preview.set_frame(UiShopV2.BORDER, UiShopV2.RADIUS_PREVIEW, UiShopV2.INK, fill)
	var pip := CosmeticCatalog.get_recolor(GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_PIP_SKIN))
	preview.configure(
		str(sd.get("preview", "swatch")), CosmeticCatalog.get_look(item_id), pip, "country_bloom",
		str(args.get("subject", "pip"))
	)
	buy.configure(_state, str(CosmeticCatalog.get_coin_cost(item_id)), UiShopV2.S_WEARING if _worn else UiShopV2.S_OWNED)
	queue_redraw()


## Upravo kupljeno: Pip (ili lik) u pregledu skoči.
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
		UiShopV2.COINS_BUY:
			buy_requested.emit(item_id)
		UiShopV2.COINS_CONFIRM:
			buy_confirmed.emit(item_id)


func _draw() -> void:
	_draw_card_bg(UiShopV2.CARD_YOURS if yours else UiShopV2.CARD)
	_draw_name_block(CosmeticCatalog.get_title(item_id))


class _Badge:
	extends Control

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(64, 64)

	func _draw() -> void:
		var c := size * 0.5
		draw_circle(c, 32.0, UiShopV2.DISC)
		draw_circle(c, 28.0, UiShopV2.INK)
		draw_polyline(PackedVector2Array([c + Vector2(-9, 1), c + Vector2(-3, 7), c + Vector2(9, -5)]), UiShopV2.DISC, 5.0, true)
