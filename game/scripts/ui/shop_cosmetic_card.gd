class_name ShopCosmeticCard
extends HBoxContainer

## Jedna kozmetika u Shopu (design_handoff_shop · components.CosmeticCard).
## Lijevo pregled "Now | With it", desno ime, opis i red akcije. Kupovina je dva
## tapa: "Buy & wear" otvori potvrdu, "Buy for ◎ n" plati. Ekonomija je ista.

signal buy_requested(item_id: String)
signal buy_confirmed(item_id: String)
signal cancel_requested(item_id: String)
signal equip_pressed(item_id: String)

var item_id: String = ""

var _mode: String = UiShop.COS_BUY
var _preview_frame: PanelContainer
var _preview: ShopCosmeticPreview
var _name: Label
var _desc: Label
var _confirm_box: VBoxContainer
var _confirm_q: Label
var _confirm_sub: Label
var _status: ShopPurchaseStatus
var _action_row: HBoxContainer
var _price_tag: PanelContainer
var _price_label: Label
var _cancel: CampButton
var _buy: CampButton
var _badge: PanelContainer
var _badge_label: Label
var _equip: CampButton
var _note: Label
var _built: bool = false


func configure(cosmetic_id: String, confirm_id: String = "") -> void:
	item_id = cosmetic_id
	_ensure_built()
	_mode = UiShop.cosmetic_mode(item_id, confirm_id)
	_apply()


func get_mode() -> String:
	return _mode


func get_name_text() -> String:
	return _name.text if _name else ""


func get_price_text() -> String:
	return _price_label.text if _price_label else ""


func get_action_text() -> String:
	if _buy and _buy.visible:
		return _buy.get_title()
	if _equip and _equip.visible:
		return _equip.get_title()
	return ""


func get_badge_text() -> String:
	return _badge_label.text if _badge and _badge.visible else ""


func is_action_enabled() -> bool:
	if _buy and _buy.visible:
		return not _buy.disabled
	if _equip and _equip.visible:
		return not _equip.disabled
	return false


func get_status() -> ShopPurchaseStatus:
	return _status


func get_preview() -> ShopCosmeticPreview:
	return _preview


func show_bought() -> void:
	var slot := CosmeticCatalog.get_slot(item_id)
	_status.show_status(UiShop.STATUS_OK, str(UiShop.SLOT_BOUGHT.get(slot, "Bought")))
	_apply()
	_pop_preview()


func _pop_preview() -> void:
	if _preview_frame == null:
		return
	_preview_frame.pivot_offset = _preview_frame.size * 0.5
	var tween := create_tween()
	tween.tween_property(_preview_frame, "scale", Vector2(1.04, 1.04), UiShop.T_PREVIEW_POP * 0.5)
	tween.tween_property(_preview_frame, "scale", Vector2.ONE, UiShop.T_PREVIEW_POP * 0.5)


func _ready() -> void:
	_ensure_built()
	if not item_id.is_empty():
		_apply()


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.y = UiShop.COSMETIC_H
	add_theme_constant_override("separation", UiShop.COSMETIC_GAP)

	_preview_frame = PanelContainer.new()
	_preview_frame.name = "PreviewFrame"
	_preview_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_frame.clip_contents = true
	_preview_frame.custom_minimum_size = UiShop.PREVIEW_SIZE
	_preview_frame.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_preview_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_preview_frame.add_theme_stylebox_override("panel", UiShop.preview_style())
	add_child(_preview_frame)
	_preview = ShopCosmeticPreview.new()
	_preview.name = "Preview"
	_preview_frame.add_child(_preview)

	var info := VBoxContainer.new()
	info.name = "Info"
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", 14)
	add_child(info)

	_name = Label.new()
	_name.name = "Name"
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	info.add_child(_name)

	_desc = Label.new()
	_desc.name = "Desc"
	_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_desc)

	_confirm_box = VBoxContainer.new()
	_confirm_box.name = "ConfirmText"
	_confirm_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_confirm_box.visible = false
	_confirm_box.add_theme_constant_override("separation", 4)
	info.add_child(_confirm_box)
	_confirm_q = Label.new()
	_confirm_q.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_confirm_box.add_child(_confirm_q)
	_confirm_sub = Label.new()
	_confirm_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_confirm_box.add_child(_confirm_sub)

	_status = ShopPurchaseStatus.new()
	_status.name = "PurchaseStatus"
	info.add_child(_status)
	_status.cleared.connect(_apply)

	_action_row = HBoxContainer.new()
	_action_row.name = "ActionRow"
	_action_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_action_row.custom_minimum_size.y = UiShop.ACTION_ROW_H
	_action_row.add_theme_constant_override("separation", 14)
	info.add_child(_action_row)

	_price_tag = PanelContainer.new()
	_price_tag.name = "PriceTag"
	_price_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price_tag.custom_minimum_size = Vector2(UiShop.COIN_PRICE_MIN_W, UiShop.ACTION_ROW_H)
	_price_tag.add_theme_stylebox_override("panel", UiShop.price_tag_style(true))
	_action_row.add_child(_price_tag)
	var price_row := HBoxContainer.new()
	price_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	price_row.alignment = BoxContainer.ALIGNMENT_CENTER
	price_row.add_theme_constant_override("separation", 10)
	_price_tag.add_child(price_row)
	var coin := TextureRect.new()
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin.custom_minimum_size = Vector2(48, 48)
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	coin.texture = UiAssets.get_chrome_icon("icon_coin")
	price_row.add_child(coin)
	_price_label = Label.new()
	_price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	price_row.add_child(_price_label)

	_cancel = _make_button("Cancel", UiShop.CANCEL_W)
	_cancel.clicked.connect(func() -> void: cancel_requested.emit(item_id))
	_buy = _make_button("Buy", 0)
	_buy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buy.clicked.connect(_on_buy)

	_badge = PanelContainer.new()
	_badge.name = "OwnedBadge"
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.custom_minimum_size.y = UiShop.TAG_H
	_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_action_row.add_child(_badge)
	_badge_label = Label.new()
	_badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_badge.add_child(_badge_label)

	_equip = _make_button("Wear it", 0)
	_equip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_equip.clicked.connect(func() -> void: equip_pressed.emit(item_id))

	_note = Label.new()
	_note.name = "EquippedNote"
	_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_note.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_action_row.add_child(_note)


func _make_button(text: String, width: float) -> CampButton:
	var btn := CampButton.new()
	btn.custom_minimum_size = Vector2(width, UiShop.ACTION_ROW_H)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.label_text = ""
	_action_row.add_child(btn)
	btn.set_text(text)
	btn.set_fonts(UiShop.FONT_BUTTON, UiShop.FONT_BUTTON_SUB)
	btn.set_press_scale(0.97)
	return btn


func _on_buy() -> void:
	if _mode == UiShop.COS_CONFIRM:
		buy_confirmed.emit(item_id)
	else:
		buy_requested.emit(item_id)


func _apply() -> void:
	var slot := CosmeticCatalog.get_slot(item_id)
	var cost := CosmeticCatalog.get_coin_cost(item_id)
	var equipped := _mode == UiShop.COS_EQUIPPED
	_preview.configure(item_id, equipped)
	_name.text = CosmeticCatalog.get_title(item_id)
	UiShop.style(_name, UiShop.FONT_NAME, UiShop.INK, UiShop.HEAVY)
	_desc.text = CosmeticCatalog.get_description(item_id)
	UiShop.style(_desc, UiShop.FONT_BODY, UiShop.SUB_INK, UiShop.REGULAR, 1.2)
	_price_label.text = str(cost)
	UiShop.style(_price_label, UiShop.FONT_PRICE, UiShop.PRICE_INK, UiShop.HEAVY)

	var confirming := _mode == UiShop.COS_CONFIRM
	var status_on := _status.visible
	_confirm_box.visible = confirming
	_desc.visible = not confirming and not status_on
	if confirming:
		_confirm_q.text = "Spend %d coins?" % cost
		UiShop.style(_confirm_q, 40, UiShop.INK, UiShop.HEAVY)
		_confirm_sub.text = "You’ll have %d left." % maxi(0, GameState.wallet_coins - cost)
		UiShop.style(_confirm_sub, UiShop.FONT_BODY, UiShop.SUB_INK, UiShop.REGULAR)

	_price_tag.visible = _mode == UiShop.COS_BUY or _mode == UiShop.COS_SHORT
	_cancel.visible = confirming
	_buy.visible = _mode != UiShop.COS_OWNED and _mode != UiShop.COS_EQUIPPED
	_badge.visible = _mode == UiShop.COS_OWNED or equipped
	_equip.visible = _mode == UiShop.COS_OWNED
	_note.visible = equipped

	if _cancel.visible:
		_cancel.set_text("Back")
		_cancel.set_styles(UiShop.button_style("cancel"), UiShop.button_style("cancel", true))
		_cancel.set_ink(UiShop.INK)
	if _buy.visible:
		match _mode:
			UiShop.COS_CONFIRM:
				_buy.set_text("Buy for %d" % cost)
				_buy.set_styles(
					UiShop.button_style("confirm"), UiShop.button_style("confirm", true)
				)
				_buy.set_ink(UiShop.INK)
				_buy.disabled = false
			UiShop.COS_SHORT:
				var missing := maxi(0, cost - GameState.wallet_coins)
				_buy.set_text("Need %d more" % missing, "earn in runs")
				_buy.set_styles(UiShop.button_style("disabled"))
				_buy.set_ink(UiShop.button_ink("disabled"))
				_buy.disabled = true
			_:
				_buy.set_text("Buy & wear")
				_buy.set_styles(UiShop.button_style("coins"), UiShop.button_style("coins", true))
				_buy.set_ink(UiShop.INK)
				_buy.disabled = false
	if _badge.visible:
		var wearing := equipped
		_badge.add_theme_stylebox_override(
			"panel", UiShop.tag_style("wearing" if wearing else "owned")
		)
		_badge_label.text = "Wearing" if wearing else "Owned"
		UiShop.style(_badge_label, UiShop.FONT_TAG, UiShop.INK, UiShop.HEAVY)
	if _equip.visible:
		_equip.set_text("Wear it")
		_equip.set_styles(UiShop.button_style("use"), UiShop.button_style("use", true))
		_equip.set_ink(UiShop.INK)
		_equip.disabled = false
	if _note.visible:
		_note.text = str(UiShop.SLOT_EQUIPPED_NOTE.get(slot, ""))
		UiShop.style(_note, UiShop.FONT_BODY, UiShop.SUB_INK, UiShop.REGULAR, 1.2)
