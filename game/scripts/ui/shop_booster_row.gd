class_name ShopBoosterRow
extends PanelContainer

## Booster kartica (design_handoff_shop · components.BoosterCard). Use postoji samo
## kad ima zalihe; Merge Hint koji je vec aktivan vodi u Arenu, a pun bag blokira
## Loot Burst. Cijene i ucinak su isti kao prije.

signal buy_pressed(booster_id: String)
signal use_pressed(booster_id: String)
signal arena_pressed(booster_id: String)

const ICONS := {
	MonetizationConfig.BOOSTER_MERGE_HINT: "icon_target",
	MonetizationConfig.BOOSTER_LOOT_BURST: "icon_seed",
}

var booster_id: String = ""

var _icon: TextureRect
var _name: Label
var _desc: Label
var _count_label: Label
var _status: ShopPurchaseStatus
var _use: CampButton
var _price: ShopPriceTag
var _buy: CampButton
var _use_mode: String = UiShop.USE_NONE
var _buy_mode: String = UiShop.BUY_IDLE
var _built: bool = false


func apply(id: String, busy_sku: String = "") -> void:
	booster_id = id
	_ensure_built()
	_use_mode = UiShop.use_mode(booster_id)
	_buy_mode = UiShop.buy_mode(MonetizationConfig.booster_sku(booster_id), busy_sku)
	_refresh()


func get_use_mode() -> String:
	return _use_mode


func get_buy_mode() -> String:
	return _buy_mode


func get_use_text() -> String:
	return _use.get_title() if _use and _use.visible else ""


func is_use_enabled() -> bool:
	return _use != null and _use.visible and not _use.disabled


func get_count_text() -> String:
	return _count_label.text if _count_label else ""


func get_status() -> ShopPurchaseStatus:
	return _status


func _ready() -> void:
	_ensure_built()
	if not booster_id.is_empty():
		_refresh()


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", UiShop.card_style(UiShop.SLOT_PAD))

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 20)
	add_child(col)

	var top := HBoxContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_theme_constant_override("separation", 20)
	col.add_child(top)

	var disc := PanelContainer.new()
	disc.name = "IconDisc"
	disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	disc.custom_minimum_size = Vector2(UiShop.BOOSTER_DISC_SIZE, UiShop.BOOSTER_DISC_SIZE)
	disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	disc.add_theme_stylebox_override("panel", UiShop.booster_disc_style())
	top.add_child(disc)
	_icon = TextureRect.new()
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.custom_minimum_size = Vector2(UiShop.BOOSTER_ICON, UiShop.BOOSTER_ICON)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	disc.add_child(_icon)

	var text_col := VBoxContainer.new()
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_col.add_theme_constant_override("separation", 8)
	top.add_child(text_col)
	_name = Label.new()
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(_name)
	_desc = Label.new()
	_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_col.add_child(_desc)
	_status = ShopPurchaseStatus.new()
	_status.name = "PurchaseStatus"
	text_col.add_child(_status)
	_status.cleared.connect(_refresh)

	var count := PanelContainer.new()
	count.name = "BoosterCount"
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count.custom_minimum_size = UiShop.COUNT_SIZE
	count.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	count.add_theme_stylebox_override("panel", UiShop.count_style())
	top.add_child(count)
	var count_col := VBoxContainer.new()
	count_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_col.alignment = BoxContainer.ALIGNMENT_CENTER
	count_col.add_theme_constant_override("separation", 0)
	count.add_child(count_col)
	var have := Label.new()
	have.mouse_filter = Control.MOUSE_FILTER_IGNORE
	have.text = "You have"
	have.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiShop.style(have, UiShop.FONT_BODY, UiShop.SUB_INK, UiShop.BOLD)
	count_col.add_child(have)
	_count_label = Label.new()
	_count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_col.add_child(_count_label)

	var action := HBoxContainer.new()
	action.name = "ActionRow"
	action.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action.custom_minimum_size.y = UiShop.MONEY_ROW_H
	action.add_theme_constant_override("separation", 16)
	col.add_child(action)

	_use = CampButton.new()
	_use.label_text = ""
	_use.custom_minimum_size.y = UiShop.MONEY_ROW_H
	_use.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action.add_child(_use)
	_use.set_fonts(UiShop.FONT_BUTTON, UiShop.FONT_BUTTON_SUB)
	_use.set_press_scale(0.97)
	_use.clicked.connect(_on_use)

	_price = ShopPriceTag.new()
	action.add_child(_price)

	_buy = CampButton.new()
	_buy.label_text = ""
	_buy.custom_minimum_size = Vector2(UiShop.BOOSTER_BUY_W, UiShop.MONEY_ROW_H)
	action.add_child(_buy)
	_buy.set_fonts(UiShop.FONT_BUTTON, UiShop.FONT_BUTTON_SUB)
	_buy.set_press_scale(0.97)
	_buy.clicked.connect(func() -> void: buy_pressed.emit(booster_id))


func _on_use() -> void:
	if _use_mode == UiShop.USE_ARMED:
		arena_pressed.emit(booster_id)
	elif _use_mode == UiShop.USE_ON:
		use_pressed.emit(booster_id)


func _refresh() -> void:
	if booster_id.is_empty():
		return
	var sku := MonetizationConfig.booster_sku(booster_id)
	_icon.texture = UiAssets.get_arena_icon(str(ICONS.get(booster_id, "icon_target")))
	if _icon.texture == null:
		_icon.texture = UiAssets.get_chrome_icon("icon_seed")
	_name.text = MonetizationConfig.get_product_title(sku)
	UiShop.style(_name, UiShop.FONT_NAME, UiShop.INK, UiShop.HEAVY)
	_desc.text = _desc_text()
	_desc.visible = not _status.visible
	UiShop.style(_desc, UiShop.FONT_BODY, UiShop.SUB_INK, UiShop.REGULAR, 1.2)
	_count_label.text = str(GameState.get_booster_count(booster_id))
	UiShop.style(_count_label, UiShop.FONT_COUNT, UiShop.INK, UiShop.HEAVY)

	_use.visible = _use_mode != UiShop.USE_NONE
	if _use.visible:
		match _use_mode:
			UiShop.USE_ARMED:
				_use.set_text("Go to Arena ↗", "hint is ready")
				_use.set_styles(UiShop.button_style("use"), UiShop.button_style("use", true))
				_use.set_ink(UiShop.INK)
				_use.disabled = false
			UiShop.USE_FULL:
				_use.set_text("Bag is full", "trade seeds in Camp first")
				_use.set_styles(UiShop.button_style("disabled"))
				_use.set_ink(UiShop.button_ink("disabled"))
				_use.disabled = true
			_:
				var sub := "for your next Arena round"
				if booster_id == MonetizationConfig.BOOSTER_LOOT_BURST:
					sub = "+5 seeds now"
				_use.set_text("Use one", sub)
				_use.set_styles(UiShop.button_style("use"), UiShop.button_style("use", true))
				_use.set_ink(UiShop.INK)
				_use.disabled = false

	_price.configure(IAPManager.get_price_label(sku), "each", UiShop.BOOSTER_PRICE_MIN_W)
	_price.visible = _buy_mode == UiShop.BUY_IDLE
	_buy.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL if not _use.visible else Control.SIZE_SHRINK_END
	)
	UiShopButtons.apply_money(_buy, _buy_mode, "Buy 1", "+1 to your stock", false)


func _desc_text() -> String:
	if booster_id == MonetizationConfig.BOOSTER_MERGE_HINT:
		if _use_mode == UiShop.USE_ARMED:
			return "Hint ready for your next Arena round"
		return "Highlights your next merge pair in the Arena."
	return "Adds 5 seeds to your camp bag right away."
