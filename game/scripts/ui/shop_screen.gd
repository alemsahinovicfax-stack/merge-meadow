extends Control

## Shop — design_handoff_shop (jedan dizajn, 2026-09-23).
## Cetiri sekcije u jednom skrolu (Looks · Seasons · Boosters · Support) sa
## sticky redom chipova. Kozmetika se kupuje u dva tapa i odmah se nosi; sve
## poruke stoje na samoj kartici, a ne u jednoj liniji na dnu. Ekonomija,
## katalog, SKU-ovi i cijene su nepromijenjeni.

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const CATALOG := preload("res://scripts/monetization/cosmetic_catalog.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")

const SLOT_ORDER: Array[String] = [
	CosmeticCatalog.SLOT_PIP_SKIN,
	CosmeticCatalog.SLOT_MEADOW_BG,
	CosmeticCatalog.SLOT_JOURNAL_FRAME,
]

@onready var bg: ColorRect = $Bg
@onready var shop_scroll: ScrollContainer = %ShopScroll
@onready var shop_pad: MarginContainer = %ShopPad
@onready var shop_content: VBoxContainer = %ShopContent
@onready var header_row: PanelContainer = %ShopHeaderRow
@onready var jump_row: HBoxContainer = %JumpRow
@onready var reset_dev_button: UiClickButton = %ResetDevButton

var _hub_embedded: bool = false
var _built: bool = false
var _confirm_id: String = ""
var _busy_sku: String = ""
var _chips: Array[ShopJumpChip] = []
var _sections: Dictionary = {}
var _cosmetic_cards: Dictionary = {}
var _booster_cards: Dictionary = {}
var _season_cards: Dictionary = {}
var _iap_cards: Dictionary = {}
var _restore_button: CampButton
var _fair_note: Label
var _toast: PanelContainer
var _toast_title: Label
var _toast_sub: Label
var _toast_tween: Tween
var _scroll_tween: Tween
var _active_section: String = "looks"


func _ready() -> void:
	_hub_embedded = bool(get_meta("meta_hub_embedded", false))
	bg.color = UiShop.PAGE_BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_row.add_theme_stylebox_override("panel", UiShop.header_row_style())
	_style_header_row()
	if reset_dev_button:
		reset_dev_button.clicked.connect(_on_reset_dev_pressed)
	shop_scroll.get_v_scroll_bar().value_changed.connect(_on_scrolled)
	if not _hub_embedded:
		SAFE_AREA.apply_top_margin(header_row, 8.0)
	_build_page()
	_connect_iap_signals()
	call_deferred("refresh_shop")


func _style_header_row() -> void:
	var pad := header_row.get_theme_stylebox("panel") as StyleBoxFlat
	if pad:
		pad.content_margin_left = UiShop.PAGE_PAD_X
		pad.content_margin_right = UiShop.PAGE_PAD_X
		pad.content_margin_top = UiShop.HEADER_ROW_PAD_TOP
		pad.content_margin_bottom = UiShop.HEADER_ROW_PAD_TOP
	header_row.custom_minimum_size.y = UiShop.HEADER_ROW_H


func _connect_iap_signals() -> void:
	if IAPManager.purchase_completed.is_connected(_on_purchase_completed):
		return
	IAPManager.purchase_completed.connect(_on_purchase_completed)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	IAPManager.catalog_updated.connect(_on_catalog_updated)
	IAPManager.restore_completed.connect(_on_restore_completed)


# --- gradnja ---


func _build_page() -> void:
	if _built:
		return
	_built = true
	for i in UiShop.SECTIONS.size():
		var chip := ShopJumpChip.new()
		jump_row.add_child(chip)
		chip.setup(UiShop.SECTIONS[i], UiShop.SECTION_LABELS[i])
		chip.clicked.connect(_on_jump_pressed.bind(UiShop.SECTIONS[i]))
		_chips.append(chip)
	_build_looks()
	_build_seasons()
	_build_boosters()
	_build_support()
	_build_toast()
	_set_active_section("looks")


func _section(id: String, index: int) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.name = "%sSection" % id.capitalize()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", UiShop.BLOCK_GAP)
	shop_content.add_child(box)
	box.add_child(_section_title(index))
	_sections[id] = box
	return box


func _section_title(index: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "SectionTitle"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.custom_minimum_size.y = UiShop.SECTION_TITLE_H
	row.add_theme_constant_override("separation", 16)
	var accent := Panel.new()
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	accent.custom_minimum_size = UiShop.ACCENT_SIZE
	accent.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	accent.add_theme_stylebox_override("panel", UiShop.accent_style(index == 0))
	row.add_child(accent)
	var title := Label.new()
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.text = UiShop.SECTION_LABELS[index]
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiShop.style(title, UiShop.FONT_SECTION_TITLE, UiShop.CREAM, UiShop.HEAVY)
	row.add_child(title)
	var sub := Label.new()
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub.text = UiShop.SECTION_SUBS[index]
	sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiShop.style(sub, UiShop.FONT_SECTION_SUB, UiShop.alpha(UiShop.CREAM, 0.78), UiShop.BOLD)
	row.add_child(sub)
	return row


func _build_looks() -> void:
	var section := _section("looks", 0)
	var by_slot: Dictionary = {}
	for entry in GameState.get_cosmetic_shop_entries():
		var item_id := str(entry.get("id", ""))
		if item_id.is_empty():
			continue
		var slot := CATALOG.get_slot(item_id)
		if not by_slot.has(slot):
			by_slot[slot] = []
		(by_slot[slot] as Array).append(item_id)
	for slot in SLOT_ORDER:
		if not by_slot.has(slot):
			continue
		section.add_child(_cosmetic_slot(slot, by_slot[slot]))
	for slot in by_slot:
		if SLOT_ORDER.has(slot):
			continue
		section.add_child(_cosmetic_slot(str(slot), by_slot[slot]))


func _cosmetic_slot(slot: String, ids: Array) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "CosmeticSlot_%s" % slot
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiShop.card_style(UiShop.SLOT_PAD))
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", UiShop.BLOCK_GAP)
	panel.add_child(col)
	var head := HBoxContainer.new()
	head.name = "SlotHead"
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.custom_minimum_size.y = UiShop.SLOT_HEAD_H
	head.add_theme_constant_override("separation", 16)
	col.add_child(head)
	var titles: Array = UiShop.SLOT_TITLES.get(slot, [slot, ""])
	var title := Label.new()
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.text = str(titles[0])
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiShop.style(title, UiShop.FONT_SLOT_TITLE, UiShop.INK, UiShop.HEAVY)
	head.add_child(title)
	var where := Label.new()
	where.mouse_filter = Control.MOUSE_FILTER_IGNORE
	where.text = str(titles[1]) if titles.size() > 1 else ""
	where.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	where.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiShop.style(where, UiShop.FONT_BODY, UiShop.SUB_INK, UiShop.BOLD)
	head.add_child(where)
	var first := true
	for item_id in ids:
		if not first:
			var line := Panel.new()
			line.mouse_filter = Control.MOUSE_FILTER_IGNORE
			line.custom_minimum_size.y = 2
			line.add_theme_stylebox_override("panel", UiShop.hairline_style())
			col.add_child(line)
		first = false
		var card := ShopCosmeticCard.new()
		card.name = "Cosmetic_%s" % item_id
		col.add_child(card)
		card.configure(str(item_id))
		card.buy_requested.connect(_on_cosmetic_buy_requested)
		card.buy_confirmed.connect(_on_cosmetic_buy_confirmed)
		card.cancel_requested.connect(_on_cosmetic_cancel)
		card.equip_pressed.connect(_on_cosmetic_equip)
		_cosmetic_cards[str(item_id)] = card
	return panel


func _build_seasons() -> void:
	var section := _section("seasons", 1)
	for def in SeasonCatalog.paid_defs():
		var sku := def.iap_product_id
		if sku.is_empty():
			continue
		var card := SeasonPackCard.new()
		card.name = "SeasonPack_%s" % def.id
		section.add_child(card)
		card.apply(sku)
		card.buy_pressed.connect(_on_money_buy)
		card.open_home_pressed.connect(_on_open_on_home)
		_season_cards[sku] = card


func _build_boosters() -> void:
	var section := _section("boosters", 2)
	for booster_id in CONFIG.all_booster_ids():
		var card := ShopBoosterRow.new()
		card.name = "Booster_%s" % booster_id
		section.add_child(card)
		card.apply(booster_id)
		card.buy_pressed.connect(_on_booster_buy)
		card.use_pressed.connect(_on_booster_use)
		card.arena_pressed.connect(_on_booster_arena)
		_booster_cards[booster_id] = card


func _build_support() -> void:
	var section := _section("support", 3)
	section.add_child(_iap_card(CONFIG.SKU_REMOVE_ADS))
	section.add_child(_iap_card(CONFIG.SKU_STARTER_PACK))
	_restore_button = CampButton.new()
	_restore_button.name = "RestoreButton"
	_restore_button.label_text = ""
	_restore_button.custom_minimum_size.y = UiShop.MONEY_ROW_H
	section.add_child(_restore_button)
	_restore_button.set_fonts(UiShop.FONT_BUTTON, UiShop.FONT_BUTTON_SUB)
	_restore_button.set_press_scale(0.97)
	_restore_button.clicked.connect(_on_restore_pressed)
	_fair_note = Label.new()
	_fair_note.name = "FairNote"
	_fair_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fair_note.text = (
		"Everything here is optional. Looks and seasons change how the meadow looks"
		+ " — never how runs, merges or rewards work."
	)
	_fair_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_fair_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiShop.style(_fair_note, UiShop.FONT_BODY, UiShop.alpha(UiShop.CREAM, 0.78), UiShop.REGULAR, 1.2)
	section.add_child(_fair_note)


func _iap_card(sku: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "IapCard_%s" % sku
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiShop.card_style(UiShop.IAP_PAD))
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 18)
	panel.add_child(col)
	var title := Label.new()
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.text = CONFIG.get_product_title(sku)
	UiShop.style(title, UiShop.FONT_NAME, UiShop.INK, UiShop.HEAVY)
	col.add_child(title)
	var desc := Label.new()
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.text = _iap_desc(sku)
	UiShop.style(desc, UiShop.FONT_BODY, UiShop.SUB_INK, UiShop.REGULAR, 1.2)
	col.add_child(desc)
	var contents: HBoxContainer = null
	if sku == CONFIG.SKU_STARTER_PACK:
		contents = HBoxContainer.new()
		contents.mouse_filter = Control.MOUSE_FILTER_IGNORE
		contents.add_theme_constant_override("separation", 14)
		col.add_child(contents)
		contents.add_child(_content_chip("coin", "icon_coin", "+%d coins" % CONFIG.STARTER_PACK_COINS))
		contents.add_child(_content_chip("seed", "icon_seed", "+%d seeds" % CONFIG.STARTER_PACK_SEEDS))
		contents.add_child(_content_chip("hint", "icon_target", "+1 Merge Hint"))
	var status := ShopPurchaseStatus.new()
	status.name = "PurchaseStatus"
	col.add_child(status)
	var action := HBoxContainer.new()
	action.name = "ActionRow"
	action.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action.custom_minimum_size.y = UiShop.MONEY_ROW_H
	action.add_theme_constant_override("separation", 16)
	col.add_child(action)
	var price := ShopPriceTag.new()
	action.add_child(price)
	var buy := CampButton.new()
	buy.label_text = ""
	buy.custom_minimum_size.y = UiShop.MONEY_ROW_H
	buy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action.add_child(buy)
	buy.set_fonts(UiShop.FONT_BUTTON, UiShop.FONT_BUTTON_SUB)
	buy.set_press_scale(0.97)
	buy.clicked.connect(_on_money_buy.bind(sku))
	var badge := PanelContainer.new()
	badge.name = "OwnedBadge"
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.custom_minimum_size.y = UiShop.TAG_H
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.add_theme_stylebox_override("panel", UiShop.tag_style("iap"))
	action.add_child(badge)
	var badge_label := Label.new()
	badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_child(badge_label)
	var owned_note := Label.new()
	owned_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	owned_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	owned_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	owned_note.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	action.add_child(owned_note)
	_iap_cards[sku] = {
		"panel": panel,
		"price": price,
		"buy": buy,
		"badge": badge,
		"badge_label": badge_label,
		"note": owned_note,
		"status": status,
		"contents": contents,
	}
	status.cleared.connect(_refresh_iap_cards)
	return panel


func _content_chip(kind: String, icon_name: String, text: String) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.custom_minimum_size.y = UiShop.CONTENT_CHIP_H
	chip.add_theme_stylebox_override("panel", UiShop.content_chip_style(kind))
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 14)
	chip.add_child(row)
	var icon := TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.custom_minimum_size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.texture = UiAssets.get_chrome_icon(icon_name)
	if icon.texture == null:
		icon.texture = UiAssets.get_arena_icon(icon_name)
	row.add_child(icon)
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiShop.style(label, UiShop.FONT_TAG, UiShop.INK, UiShop.HEAVY)
	row.add_child(label)
	return chip


func _iap_desc(sku: String) -> String:
	if sku == CONFIG.SKU_REMOVE_ADS:
		return (
			"Turns off the ad between runs. Rewarded videos stay optional"
			+ " — they only play when you tap them."
		)
	return "A one-time bundle to get going."


func _build_toast() -> void:
	_toast = PanelContainer.new()
	_toast.name = "PurchaseToast"
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.visible = false
	_toast.z_index = 4
	_toast.add_theme_stylebox_override("panel", UiShop.toast_style())
	add_child(_toast)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 4)
	_toast.add_child(col)
	_toast_title = Label.new()
	_toast_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_toast_title)
	_toast_sub = Label.new()
	_toast_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_toast_sub)


# --- osvjezavanje ---


func refresh_shop() -> void:
	if not _built or not is_inside_tree():
		return
	for item_id in _cosmetic_cards:
		(_cosmetic_cards[item_id] as ShopCosmeticCard).configure(str(item_id), _confirm_id)
	for booster_id in _booster_cards:
		(_booster_cards[booster_id] as ShopBoosterRow).apply(str(booster_id), _busy_sku)
	for sku in _season_cards:
		(_season_cards[sku] as SeasonPackCard).apply(str(sku), _busy_sku)
	_refresh_iap_cards()
	if reset_dev_button:
		reset_dev_button.visible = Engine.is_editor_hint() and IAPManager.is_stub_mode()
	_notify_hub_chrome()


func _refresh_iap_cards() -> void:
	for sku in _iap_cards:
		var parts: Dictionary = _iap_cards[sku]
		var owned := IAPManager.owns_product(str(sku))
		var price: ShopPriceTag = parts["price"]
		var buy: CampButton = parts["buy"]
		var badge: PanelContainer = parts["badge"]
		var badge_label: Label = parts["badge_label"]
		var note: Label = parts["note"]
		price.visible = not owned
		buy.visible = not owned
		badge.visible = owned
		note.visible = owned
		if not owned:
			price.configure(IAPManager.get_price_label(str(sku)), "one-time")
			var label := "Remove ads"
			var sub := "for good, on this account"
			if str(sku) == CONFIG.SKU_STARTER_PACK:
				label = "Get the pack"
				sub = "once per account"
			UiShopButtons.apply_money(buy, UiShop.buy_mode(str(sku), _busy_sku), label, sub)
		else:
			badge_label.text = (
				"Ads are off" if str(sku) == CONFIG.SKU_REMOVE_ADS else "Claimed"
			)
			UiShop.style(badge_label, UiShop.FONT_TAG, UiShop.INK, UiShop.HEAVY)
			note.text = (
				"Thanks for supporting Merge Meadow."
				if str(sku) == CONFIG.SKU_REMOVE_ADS
				else "+15 coins, +8 seeds and 1 Merge Hint were added."
			)
			UiShop.style(note, UiShop.FONT_BODY, UiShop.SUB_INK, UiShop.REGULAR, 1.2)
	if _restore_button:
		var stub := IAPManager.is_stub_mode()
		_restore_button.visible = not stub
		var busy := IAPManager.is_busy() and _busy_sku == "restore"
		_restore_button.set_text(
			"Restoring…" if busy else "Restore purchases",
			"asking the store" if busy else "bought before on this store account?"
		)
		_restore_button.set_styles(UiShop.restore_style(busy))
		_restore_button.set_ink(UiShop.CREAM)
		_restore_button.disabled = IAPManager.is_busy()


# --- chipovi i skrol ---


func _on_jump_pressed(section_id: String) -> void:
	var box := _sections.get(section_id) as Control
	if box == null:
		return
	var target := maxf(0.0, _content_top_of(box) - float(UiShop.CONTENT_TOP))
	if _scroll_tween != null and _scroll_tween.is_valid():
		_scroll_tween.kill()
	_scroll_tween = create_tween()
	_scroll_tween.set_trans(Tween.TRANS_CUBIC)
	_scroll_tween.set_ease(Tween.EASE_OUT)
	_scroll_tween.tween_property(shop_scroll, "scroll_vertical", int(target), UiShop.T_JUMP)
	_set_active_section(section_id)


func _on_scrolled(_value: float) -> void:
	_sync_spy()


func _sync_spy() -> void:
	var scroll := float(shop_scroll.scroll_vertical)
	var bar := shop_scroll.get_v_scroll_bar()
	if bar != null and scroll >= bar.max_value - bar.page - 2.0:
		_set_active_section(UiShop.SECTIONS[UiShop.SECTIONS.size() - 1])
		return
	var current: String = UiShop.SECTIONS[0]
	for section_id in UiShop.SECTIONS:
		var box := _sections.get(section_id) as Control
		if box == null:
			continue
		if _content_top_of(box) <= scroll + float(UiShop.SPY_OFFSET):
			current = section_id
	_set_active_section(current)


## y sekcije unutar sadrzaja skrola. ShopPad se pomjera sa skrolom, pa se njegova
## pozicija ne smije sabirati (inace drugi skok gubi vec preskrolanu visinu).
func _content_top_of(box: Control) -> float:
	return box.position.y + shop_content.position.y


func _set_active_section(section_id: String) -> void:
	_active_section = section_id
	for chip in _chips:
		chip.set_active(chip.section == section_id)


# --- kozmetika ---


func _on_cosmetic_buy_requested(item_id: String) -> void:
	_confirm_id = item_id
	refresh_shop()


func _on_cosmetic_cancel(_item_id: String) -> void:
	_confirm_id = ""
	refresh_shop()


func _on_cosmetic_buy_confirmed(item_id: String) -> void:
	var cost := CATALOG.get_coin_cost(item_id)
	var result := GameState.buy_cosmetic_with_coins(item_id)
	_confirm_id = ""
	var card := _cosmetic_cards.get(item_id) as ShopCosmeticCard
	refresh_shop()
	if card == null:
		return
	if result.begins_with("Purchased"):
		card.show_bought()
		_spend_pop(cost)
	else:
		card.get_status().show_status(UiShop.STATUS_FAIL, result)


func _on_cosmetic_equip(item_id: String) -> void:
	if not GameState.equip_cosmetic(item_id):
		return
	refresh_shop()
	var card := _cosmetic_cards.get(item_id) as ShopCosmeticCard
	if card:
		card.get_status().show_status(UiShop.STATUS_OK, "Wearing it now")


func _spend_pop(amount: int) -> void:
	if amount <= 0 or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "show_coin_spend_pop", amount)


# --- boosteri ---


func _on_booster_use(booster_id: String) -> void:
	var message := GameState.use_booster(booster_id)
	refresh_shop()
	var card := _booster_cards.get(booster_id) as ShopBoosterRow
	if card:
		card.get_status().show_status(UiShop.STATUS_OK, message)


func _on_booster_arena(_booster_id: String) -> void:
	if GameState.meta_hub_active:
		GameState.go_to_meta_page(MetaHubPages.ARENA)
	else:
		SceneRouter.change_to(GameState.SCENE_MERGE_ARENA)


func _on_booster_buy(booster_id: String) -> void:
	var sku := CONFIG.booster_sku(booster_id)
	if sku.is_empty():
		return
	_on_money_buy(sku)


# --- pravi novac ---


func _on_money_buy(sku: String) -> void:
	if IAPManager.is_busy() or IAPManager.owns_product(sku):
		return
	var season_id := CONFIG.season_id_for_sku(sku)
	if not season_id.is_empty() and GameState.is_test_locked_season(season_id):
		return
	_busy_sku = sku
	_clear_status_for(sku)
	IAPManager.purchase(sku)
	refresh_shop()


func _on_open_on_home(season_id: String) -> void:
	if season_id.is_empty():
		return
	GameState.set_paid_strip_focus(season_id)
	GameState.set_home_band("paid")
	if GameState.meta_hub_active:
		GameState.go_to_meta_page(MetaHubPages.MAIN)
	else:
		SceneRouter.change_to(GameState.SCENE_MAIN)


func _on_restore_pressed() -> void:
	if IAPManager.is_busy():
		return
	_busy_sku = "restore"
	IAPManager.restore_purchases()
	refresh_shop()


func _on_reset_dev_pressed() -> void:
	IAPManager.reset_purchases_for_dev()
	refresh_shop()


func _on_catalog_updated() -> void:
	refresh_shop()


func _on_purchase_completed(sku: String) -> void:
	_busy_sku = ""
	refresh_shop()
	var status := _status_for(sku)
	match sku:
		CONFIG.SKU_REMOVE_ADS:
			_show_toast("Ads are off", "Thanks for supporting Merge Meadow.")
		CONFIG.SKU_STARTER_PACK:
			_show_toast("+15 coins · +8 seeds · +1 Merge Hint", "Starter Pack added")
		_:
			if CONFIG.is_season_sku(sku):
				var def: SeasonDef = SeasonCatalog.get_def(CONFIG.season_id_for_sku(sku))
				var name := def.display_name if def else CONFIG.get_product_title(sku)
				if status:
					status.show_status(UiShop.STATUS_OK, "%s is yours." % name, "Pick it on Home.")
			else:
				var booster_id := CONFIG.sku_booster_id(sku)
				if not booster_id.is_empty() and status:
					status.show_status(
						UiShop.STATUS_OK,
						"+1 %s · you have %d"
						% [
							CONFIG.get_product_title(sku),
							GameState.get_booster_count(booster_id),
						]
					)


func _on_purchase_failed(sku: String, reason: String) -> void:
	if _busy_sku == sku:
		_busy_sku = ""
	refresh_shop()
	var parts := UiShop.fail_text(reason)
	if parts[0].is_empty():
		return
	var status := _status_for(sku)
	if status:
		status.show_status(parts[0], parts[1], parts[2])


func _on_restore_completed() -> void:
	_busy_sku = ""
	refresh_shop()
	_show_toast("Purchases restored", "")


func _status_for(sku: String) -> ShopPurchaseStatus:
	if _iap_cards.has(sku):
		return (_iap_cards[sku] as Dictionary)["status"] as ShopPurchaseStatus
	if _season_cards.has(sku):
		return (_season_cards[sku] as SeasonPackCard).get_status()
	var booster_id := CONFIG.sku_booster_id(sku)
	if _booster_cards.has(booster_id):
		return (_booster_cards[booster_id] as ShopBoosterRow).get_status()
	return null


func _clear_status_for(sku: String) -> void:
	var status := _status_for(sku)
	if status:
		status.clear()


func _show_toast(title: String, sub: String) -> void:
	if _toast == null:
		return
	_toast_title.text = title
	UiShop.style(_toast_title, UiShop.FONT_TOAST, UiShop.INK, UiShop.HEAVY)
	_toast_sub.text = sub
	_toast_sub.visible = not sub.is_empty()
	UiShop.style(_toast_sub, UiShop.FONT_BODY, UiShop.SUB_INK, UiShop.REGULAR)
	_toast.reset_size()
	var toast_size := _toast.get_combined_minimum_size()
	_toast.size = Vector2(minf(960.0, maxf(toast_size.x, 520.0)), toast_size.y)
	_toast.position = Vector2((size.x - _toast.size.x) * 0.5, float(UiShop.CONTENT_TOP))
	_toast.visible = true
	_toast.modulate.a = 0.0
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_property(_toast, "modulate:a", 1.0, 0.2)
	_toast_tween.tween_interval(UiShop.T_TOAST_HOLD)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.25)
	_toast_tween.tween_callback(_toast.hide)


# --- hub ---


func set_meta_hub_mode(enabled: bool) -> void:
	_hub_embedded = enabled


func refresh_for_meta_hub() -> void:
	refresh_shop()


func _notify_hub_chrome() -> void:
	if not _hub_embedded or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "refresh_top_bar")


# --- za smoke testove ---


func get_cosmetic_card(item_id: String) -> ShopCosmeticCard:
	return _cosmetic_cards.get(item_id) as ShopCosmeticCard


func get_booster_card(booster_id: String) -> ShopBoosterRow:
	return _booster_cards.get(booster_id) as ShopBoosterRow


func get_season_card(sku: String) -> SeasonPackCard:
	return _season_cards.get(sku) as SeasonPackCard


func get_jump_chips() -> Array[ShopJumpChip]:
	return _chips


func active_section() -> String:
	return _active_section


func section_node(section_id: String) -> Control:
	return _sections.get(section_id) as Control


func is_restore_visible() -> bool:
	return _restore_button != null and _restore_button.visible


func get_fair_note_text() -> String:
	return _fair_note.text if _fair_note else ""


func get_iap_status(sku: String) -> ShopPurchaseStatus:
	return _status_for(sku)


func get_confirm_id() -> String:
	return _confirm_id
