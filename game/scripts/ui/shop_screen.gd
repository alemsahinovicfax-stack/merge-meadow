extends Control

## Shop v2 — design_handoff_shop_v2 (jedan dizajn, 2026-10-02): tezga na livadi. Tenda s
## četiri taba (Seasons · Looks · Boosters · Support) iznad toplog pergamenta `#FBEDD7`;
## svaki tab je svoj ScrollContainer (neaktivni su skriveni, ne brišu se → pamte skrol dok
## si u Shopu). Ulaz iz footera uvijek otvara Seasons od vrha; „More in Shop" iz Ormara
## otvara Looks na slotu (zaglavlje bljesne). Na svakoj kartici koja prodaje je jedno dugme
## koje nosi cijenu i kupuje. SKU-ovi i cijene su nepromijenjeni.

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TOAST_RECT := Rect2(190, 1456, 700, 100)
const SLOT_FLASH_SEC := 1.2
const ENTRY_OVERRIDE_MSEC := 2000

@onready var bg: ColorRect = $Bg

var _hub_embedded: bool = false
var _built: bool = false
## Hub gradi Shop dok je igrač na Homeu (perf 2026-10-10): sve kartice u _ready su bile jedan
## frejm od ~140 ms. U hubu ide jedan korak (kartica) po frejmu; ulaz i getteri dovrše odmah.
var _build_steps: Array[Callable] = []
var _tab: String = "seasons"
var _tab_bar: ShopTabBar
var _pages: Dictionary = {}
var _contents: Dictionary = {}
var _page_tween: Tween
var _confirm_id: String = ""
var _confirm_timer: SceneTreeTimer
var _busy_sku: String = ""
var _season_cards: Dictionary = {}
var _cosmetic_cards: Dictionary = {}
var _slot_headers: Dictionary = {}
var _booster_cards: Dictionary = {}
var _support_cards: Dictionary = {}
var _boosters_end: Control
var _restore: _RestoreLink
var _toast: _Toast
var _entry_override: String = ""
var _entry_override_slot: String = ""
var _entry_override_at: int = 0


func _ready() -> void:
	_hub_embedded = bool(get_meta("meta_hub_embedded", false))
	bg.color = UiShopV2.PAGE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	_connect_iap_signals()
	if not _hub_embedded:
		SAFE_AREA.apply_top_margin(_tab_bar, 8.0)
	GameState.cosmetics_changed.connect(func(_slots: Array) -> void: refresh_shop())
	call_deferred("refresh_shop")


func _connect_iap_signals() -> void:
	if IAPManager.purchase_completed.is_connected(_on_purchase_completed):
		return
	IAPManager.purchase_completed.connect(_on_purchase_completed)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	IAPManager.catalog_updated.connect(_on_catalog_updated)
	IAPManager.restore_completed.connect(_on_restore_completed)


# --- gradnja ---


func _build() -> void:
	if _built:
		return
	_built = true
	for tab_id in UiShopV2.TABS:
		_make_page(tab_id)
	_queue_seasons()
	_queue_looks()
	_queue_boosters()
	_queue_support()
	_tab_bar = ShopTabBar.new()
	_tab_bar.name = "ShopTabBar"
	_tab_bar.z_index = 3
	add_child(_tab_bar)
	_tab_bar.tab_selected.connect(select_tab)
	_toast = _Toast.new()
	_toast.name = "Toast"
	_toast.z_index = 6
	_toast.position = TOAST_RECT.position
	_toast.size = TOAST_RECT.size
	add_child(_toast)
	_show_page(_tab, false)
	if _hub_embedded and is_inside_tree():
		get_tree().process_frame.connect(_build_next_step)
	else:
		_finish_build()


## Ostatak gradnje odmah: ulaz u Shop, tabovi, getteri.
func _finish_build() -> void:
	while not _build_steps.is_empty():
		_build_steps.pop_front().call()
	if is_inside_tree() and get_tree().process_frame.is_connected(_build_next_step):
		get_tree().process_frame.disconnect(_build_next_step)
		refresh_shop()


func _build_next_step() -> void:
	if not _build_steps.is_empty():
		_build_steps.pop_front().call()
	if _build_steps.is_empty():
		get_tree().process_frame.disconnect(_build_next_step)
		refresh_shop()


func _make_page(tab_id: String) -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "TabPage_%s" % tab_id.capitalize()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.visible = false
	add_child(scroll)
	var pad := MarginContainer.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_left", UiShopV2.PAGE_PAD_X)
	pad.add_theme_constant_override("margin_right", UiShopV2.PAGE_PAD_X)
	pad.add_theme_constant_override("margin_top", UiShopV2.CONTENT_TOP)
	pad.add_theme_constant_override("margin_bottom", UiShopV2.CONTENT_BOTTOM)
	scroll.add_child(pad)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override(
		"separation", UiShopV2.LOOKS_SLOT_GAP if tab_id == "looks" else UiShopV2.CARD_GAP
	)
	pad.add_child(box)
	_pages[tab_id] = scroll
	_contents[tab_id] = box


func _queue_seasons() -> void:
	for def in SeasonCatalog.paid_defs():
		if not def.iap_product_id.is_empty():
			_build_steps.append(_add_season_card.bind(def.id, def.iap_product_id))


func _add_season_card(season_id: String, sku: String) -> void:
	var card := SeasonPackCard.new()
	card.name = "SeasonCard_%s" % season_id
	(_contents["seasons"] as VBoxContainer).add_child(card)
	card.apply(sku)
	card.buy_pressed.connect(_on_money_buy)
	card.open_home_pressed.connect(_on_open_on_home)
	_season_cards[sku] = card


func _queue_looks() -> void:
	for slot in CosmeticCatalog.slots():
		var slot_id := str(slot.get("id", ""))
		var items: Array[String] = []
		for it in CosmeticCatalog.items_in_slot(slot_id):
			var iid := str(it.get("id", ""))
			if CosmeticCatalog.is_shop_item(iid):
				items.append(iid)
		if items.is_empty():
			continue
		_build_steps.append(_add_slot_group.bind(slot))
		for iid in items:
			_build_steps.append(_add_cosmetic_card.bind(slot_id, iid))
	_build_steps.append(_add_looks_end)


func _add_slot_group(slot: Dictionary) -> void:
	var slot_id := str(slot.get("id", ""))
	var group := VBoxContainer.new()
	group.name = "LooksSlot_%s" % slot_id
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.add_theme_constant_override("separation", 20)
	(_contents["looks"] as VBoxContainer).add_child(group)
	var head := _SlotHeader.new()
	head.name = "SlotHeader"
	head.title = str(slot.get("title", slot_id))
	head.icon = UiWardrobe.icon(str(slot.get("icon", "")))
	group.add_child(head)
	_slot_headers[slot_id] = head


func _add_cosmetic_card(slot_id: String, iid: String) -> void:
	var group := (_contents["looks"] as Node).get_node("LooksSlot_%s" % slot_id)
	var card := ShopCosmeticCard.new()
	card.name = "CosmeticCard_%s" % iid
	group.add_child(card)
	card.configure(iid)
	card.buy_requested.connect(_on_cosmetic_buy_requested)
	card.buy_confirmed.connect(_on_cosmetic_buy_confirmed)
	card.short_tapped.connect(_on_cosmetic_short)
	_cosmetic_cards[iid] = card


func _add_looks_end() -> void:
	var end := CenterContainer.new()
	end.name = "TabEnd"
	end.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(_contents["looks"] as VBoxContainer).add_child(end)
	var link := _PillLink.new()
	link.name = "WardrobeLink"
	link.text = UiShopV2.S_WARDROBE
	link.icon = UiAssets.get_chrome_icon("icon_wardrobe")
	if link.icon == null:
		link.icon = UiWardrobe.icon("res://assets/ui/wardrobe/icon_wardrobe.svg")
	end.add_child(link)
	link.clicked.connect(_on_wardrobe_link)


func _queue_boosters() -> void:
	for booster_id in CONFIG.all_booster_ids():
		_build_steps.append(_add_booster_card.bind(booster_id))
	_build_steps.append(_add_boosters_end)


func _add_booster_card(booster_id: String) -> void:
	var card := ShopBoosterCard.new()
	card.name = "BoosterCard_%s" % booster_id
	(_contents["boosters"] as VBoxContainer).add_child(card)
	card.setup(booster_id)
	card.buy_pressed.connect(_on_money_buy)
	_booster_cards[booster_id] = card


func _add_boosters_end() -> void:
	_boosters_end = _AllSet.new()
	_boosters_end.name = "TabEnd"
	(_contents["boosters"] as VBoxContainer).add_child(_boosters_end)


func _queue_support() -> void:
	for sku in [CONFIG.SKU_REMOVE_ADS, CONFIG.SKU_STARTER_PACK]:
		_build_steps.append(_add_support_card.bind(sku))
	_build_steps.append(_add_support_end)


func _add_support_card(sku: String) -> void:
	var card := ShopSupportCard.new()
	card.name = "SupportCard_%s" % sku
	(_contents["support"] as VBoxContainer).add_child(card)
	card.setup(sku)
	card.buy_pressed.connect(_on_money_buy)
	_support_cards[sku] = card


func _add_support_end() -> void:
	var end := CenterContainer.new()
	end.name = "TabEnd"
	end.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(_contents["support"] as VBoxContainer).add_child(end)
	_restore = _RestoreLink.new()
	_restore.name = "RestoreLink"
	end.add_child(_restore)
	_restore.clicked.connect(_on_restore_pressed)


# --- tabovi i ulaz ---


func select_tab(tab_id: String, animated: bool = true) -> void:
	_finish_build()
	if not _pages.has(tab_id):
		return
	if tab_id == _tab and (_pages[tab_id] as Control).visible:
		return
	_show_page(tab_id, animated)


func _show_page(tab_id: String, animated: bool) -> void:
	var old := _tab
	_tab = tab_id
	if _tab_bar != null:
		_tab_bar.set_active(tab_id, animated)
	_cancel_confirm()
	if _page_tween != null and _page_tween.is_valid():
		_page_tween.kill()
	var incoming := _pages[tab_id] as Control
	for id in _pages:
		var p := _pages[id] as Control
		if id != tab_id and id != old:
			p.visible = false
	incoming.visible = true
	incoming.position.x = 0.0
	incoming.modulate.a = 1.0
	if not animated or old == tab_id or not is_inside_tree():
		(_pages[old] as Control).visible = old == tab_id
		return
	var outgoing := _pages[old] as Control
	var dir := 1.0 if UiShopV2.TABS.find(tab_id) > UiShopV2.TABS.find(old) else -1.0
	incoming.modulate.a = 0.0
	incoming.position.x = dir * UiShopV2.TAB_SLIDE_PX
	_page_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_page_tween.tween_property(outgoing, "modulate:a", 0.0, UiShopV2.T_TAB)
	_page_tween.tween_property(incoming, "modulate:a", 1.0, UiShopV2.T_TAB)
	_page_tween.tween_property(incoming, "position:x", 0.0, UiShopV2.T_TAB)
	_page_tween.chain().tween_callback(func() -> void:
		outgoing.visible = false
		outgoing.modulate.a = 1.0
	)


## Ulaz u Shop (hub ga zove kad Shop postane aktivna stranica): Seasons od vrha, osim
## kad je upravo stigao link iz Ormara.
func _enter_shop() -> void:
	_finish_build()
	for id in _pages:
		(_pages[id] as ScrollContainer).scroll_vertical = 0
	if not _entry_override.is_empty() and Time.get_ticks_msec() - _entry_override_at < ENTRY_OVERRIDE_MSEC:
		var slot := _entry_override_slot
		_entry_override = ""
		_show_page("looks", false)
		_scroll_to_slot(slot)
		return
	_entry_override = ""
	_show_page("seasons", false)


## Ormar · „More in Shop": Looks, skrol na zaglavlje slota, zaglavlje bljesne 1,2 s.
func show_cosmetic_slot(slot: String) -> void:
	_finish_build()
	_entry_override = "looks"
	_entry_override_slot = slot
	_entry_override_at = Time.get_ticks_msec()
	_show_page("looks", false)
	_scroll_to_slot(slot)


func _scroll_to_slot(slot: String) -> void:
	var head := _slot_headers.get(slot) as _SlotHeader
	if head == null:
		return
	await get_tree().process_frame
	if not is_instance_valid(head):
		return
	var scroll := _pages["looks"] as ScrollContainer
	var box := _contents["looks"] as Control
	var y := head.get_global_rect().position.y - box.get_global_rect().position.y
	scroll.scroll_vertical = int(maxf(0.0, y))
	head.flash(SLOT_FLASH_SEC)


func active_tab() -> String:
	return _tab


# --- osvježavanje ---


func refresh_shop() -> void:
	if not _built or not _build_steps.is_empty() or not is_inside_tree():
		return
	var restoring := _busy_sku == "restore"
	for iid in _cosmetic_cards:
		(_cosmetic_cards[iid] as ShopCosmeticCard).configure(str(iid), _confirm_id)
	for sku in _season_cards:
		(_season_cards[sku] as SeasonPackCard).apply(str(sku), _iap_busy_sku(), false, restoring)
	var loot_on := GameState.can_buy_loot_burst()
	for booster_id in _booster_cards:
		var card := _booster_cards[booster_id] as ShopBoosterCard
		card.apply(_iap_busy_sku(), false, restoring)
		if booster_id == CONFIG.BOOSTER_LOOT_BURST:
			card.visible = loot_on
	_boosters_end.visible = GameState.merge_hint_owned and not loot_on
	for sku in _support_cards:
		(_support_cards[sku] as ShopSupportCard).apply(_iap_busy_sku(), false, restoring)
	_restore.visible = not IAPManager.is_stub_mode()
	_restore.set_busy(restoring)
	_notify_hub_chrome()


## Restore nije SKU: dok traje, sva IAP dugmad su prigušena (money.dim).
func _iap_busy_sku() -> String:
	return "restore" if _busy_sku == "restore" else _busy_sku


func _on_catalog_updated() -> void:
	refresh_shop()


# --- kozmetika ---


func _on_cosmetic_buy_requested(item_id: String) -> void:
	_confirm_id = item_id
	refresh_shop()
	_confirm_timer = get_tree().create_timer(UiShopV2.T_CONFIRM_TIMEOUT)
	_confirm_timer.timeout.connect(_on_confirm_timeout.bind(item_id, _confirm_timer))


func _on_confirm_timeout(item_id: String, timer: SceneTreeTimer) -> void:
	if timer != _confirm_timer or _confirm_id != item_id:
		return
	_cancel_confirm()


func _cancel_confirm() -> void:
	if _confirm_id.is_empty():
		return
	_confirm_id = ""
	_confirm_timer = null
	refresh_shop()


func _on_cosmetic_buy_confirmed(item_id: String) -> void:
	var cost := CosmeticCatalog.get_coin_cost(item_id)
	var result := GameState.buy_cosmetic_with_coins(item_id)
	_confirm_id = ""
	_confirm_timer = null
	refresh_shop()
	var card := _cosmetic_cards.get(item_id) as ShopCosmeticCard
	if card == null:
		return
	if result.begins_with("Purchased"):
		card.show_bought()
		_spend_pop(cost)
		GameState.cosmetics_changed.emit([CosmeticCatalog.get_slot(item_id)])
	else:
		card.show_status(UiShopV2.S_FAILED, UiShopV2.STATUS_FAIL_BG)


func _on_cosmetic_short(_item_id: String) -> void:
	_cancel_confirm()
	if is_inside_tree():
		get_tree().call_group("meta_hub", "pulse_coin_chip")


func _spend_pop(amount: int) -> void:
	if amount <= 0 or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "show_coin_spend_pop", amount)


func _on_wardrobe_link() -> void:
	if not GameState.meta_hub_active:
		SceneRouter.change_to(GameState.SCENE_MAIN)
		return
	GameState.go_to_meta_page(MetaHubPages.MAIN)
	for menu in get_tree().get_nodes_in_group("main_menu"):
		if menu.has_method("open_wardrobe_from_shop"):
			menu.call("open_wardrobe_from_shop")
			return
	var hubs := get_tree().get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		return
	var host: Node = hubs[0].get_node("RootVBox/SwipePager").call("get_pages_host")
	var home := host.get_node_or_null("Page_%d" % MetaHubPages.MAIN)
	if home != null and home.has_method("open_wardrobe_from_shop"):
		home.call("open_wardrobe_from_shop")


# --- pravi novac ---


func _on_money_buy(sku: String) -> void:
	if IAPManager.is_busy() or IAPManager.owns_product(sku):
		return
	var season_id := CONFIG.season_id_for_sku(sku)
	if not season_id.is_empty() and GameState.is_test_locked_season(season_id):
		return
	_cancel_confirm()
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


func _on_purchase_completed(sku: String) -> void:
	_busy_sku = ""
	refresh_shop()
	match sku:
		CONFIG.SKU_REMOVE_ADS:
			_toast.show_text(UiShopV2.S_TOAST_ADS)
		CONFIG.SKU_STARTER_PACK:
			_toast.show_text(UiShopV2.S_TOAST_PACK)
		CONFIG.SKU_BOOSTER_LOOT_BURST:
			var flower := str(IAPManager.last_loot_burst.get("flower", ""))
			if not flower.is_empty():
				_toast.show_text(UiShopV2.S_TOAST_LOOT % GameState.get_seed_display_name(flower))


func _on_purchase_failed(sku: String, reason: String) -> void:
	if _busy_sku == sku:
		_busy_sku = ""
	refresh_shop()
	var parts := UiShopV2.status_for(reason)
	if parts.is_empty():
		return
	var card := _card_for(sku)
	if card != null:
		card.show_status(str(parts[0]), parts[1])


func _on_restore_completed() -> void:
	_busy_sku = ""
	refresh_shop()
	_toast.show_text(UiShopV2.S_TOAST_RESTORED)


func _card_for(sku: String) -> ShopCard:
	_finish_build()
	if _season_cards.has(sku):
		return _season_cards[sku]
	if _support_cards.has(sku):
		return _support_cards[sku]
	var booster_id := CONFIG.sku_booster_id(sku)
	if _booster_cards.has(booster_id):
		return _booster_cards[booster_id]
	return null


func _clear_status_for(sku: String) -> void:
	var card := _card_for(sku)
	if card != null:
		card.clear_status()


# --- hub ---


func set_meta_hub_mode(enabled: bool) -> void:
	_hub_embedded = enabled


func refresh_for_meta_hub() -> void:
	_enter_shop()
	refresh_shop()


func _notify_hub_chrome() -> void:
	if not _hub_embedded or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "refresh_top_bar")


# --- za smoke testove ---


func get_cosmetic_card(item_id: String) -> ShopCosmeticCard:
	_finish_build()
	return _cosmetic_cards.get(item_id) as ShopCosmeticCard


func get_booster_card(booster_id: String) -> ShopBoosterCard:
	_finish_build()
	return _booster_cards.get(booster_id) as ShopBoosterCard


func get_season_card(sku: String) -> SeasonPackCard:
	_finish_build()
	return _season_cards.get(sku) as SeasonPackCard


func get_support_card(sku: String) -> ShopSupportCard:
	_finish_build()
	return _support_cards.get(sku) as ShopSupportCard


func get_tab_bar() -> ShopTabBar:
	return _tab_bar


func page_node(tab_id: String) -> ScrollContainer:
	_finish_build()
	return _pages.get(tab_id) as ScrollContainer


func is_restore_visible() -> bool:
	_finish_build()
	return _restore != null and _restore.visible


func is_all_set_visible() -> bool:
	_finish_build()
	return _boosters_end != null and _boosters_end.visible


func get_confirm_id() -> String:
	return _confirm_id


func get_toast_text() -> String:
	return _toast.text if _toast != null and _toast.visible else ""


# --- male komponente ---


## Zaglavlje slota: ikona 64 + naslov 48; iz Ormara bljesne `#FFF6D6` s ink rubom.
class _SlotHeader:
	extends Control

	var title: String = ""
	var icon: Texture2D
	var _flash: float = 0.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(UiShopV2.CARD_W, 96)

	func flash(sec: float) -> void:
		_flash = 1.0
		queue_redraw()
		var tw := create_tween()
		tw.tween_interval(sec)
		tw.tween_callback(func() -> void:
			_flash = 0.0
			queue_redraw()
		)

	func is_flashing() -> bool:
		return _flash > 0.0

	func _draw() -> void:
		if _flash > 0.0:
			draw_style_box(UiShopV2.box(UiShopV2.CARD_YOURS, 48, 4), Rect2(Vector2.ZERO, size))
		if icon != null:
			draw_texture_rect(icon, Rect2(20, 16, 64, 64), false)
		UiHomeV3.draw_text(self, 900, 48, title, Vector2(20.0 + 64.0 + 16.0, 24.0), UiShopV2.INK)


## Pilula s ikonom i tekstom (Looks → Wardrobe): bijela, rub 4, tvrda sjena 8.
class _PillLink:
	extends HubPressable

	var text: String = ""
	var icon: Texture2D

	func _ready() -> void:
		super()
		custom_minimum_size = Vector2(36.0 + 64.0 + 18.0 + UiHomeV3.text_w(900, 44, text) + 48.0, 120.0 + 8.0)

	func _apply_state() -> void:
		queue_redraw()

	func _draw() -> void:
		var down := 4.0 if is_pressing() else 0.0
		var r := Rect2(Vector2(0, down), Vector2(size.x, 120))
		draw_style_box(UiShopV2.box(UiShopV2.SHADOW_CARD, 60), Rect2(Vector2(0, 8), r.size))
		draw_style_box(UiShopV2.box(UiShopV2.CARD, 60, 4), r)
		if icon != null:
			draw_texture_rect(icon, Rect2(36, down + 28.0, 64, 64), false)
		UiHomeV3.draw_text(self, 900, 44, text, Vector2(36.0 + 64.0 + 18.0, down + 38.0), UiShopV2.INK)


## Restore purchases: podvučen link 38/800, h 120.
class _RestoreLink:
	extends HubPressable

	var _busy: bool = false

	func _ready() -> void:
		super()
		custom_minimum_size = Vector2(32.0 * 2.0 + UiHomeV3.text_w(800, 38, UiShopV2.S_RESTORE), 120)

	func set_busy(on: bool) -> void:
		_busy = on
		disabled = on or IAPManager.is_busy()
		queue_redraw()

	func _draw() -> void:
		var t := UiShopV2.S_RESTORING if _busy else UiShopV2.S_RESTORE
		var ink := UiShopV2.INK_SUB if _busy else UiShopV2.INK
		var w := UiHomeV3.text_w(800, 38, t)
		var x := (size.x - w) * 0.5
		UiHomeV3.draw_text(self, 800, 38, t, Vector2(x, 41.0), ink)
		draw_line(Vector2(x, 41.0 + 38.0 + 8.0), Vector2(x + w, 41.0 + 38.0 + 8.0), ink, 3.0)


## Boosters bez ponude: Pip + „All set here".
class _AllSet:
	extends Control

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(UiShopV2.CARD_W, 24.0 + 180.0 + 8.0 + 40.0)

	func _draw() -> void:
		var pip := PipAssets.get_texture()
		if pip != null:
			var ps := pip.get_size()
			var k := 180.0 / maxf(ps.x, ps.y)
			draw_texture_rect(pip, Rect2(Vector2(size.x * 0.5 - ps.x * k * 0.5, 24.0), ps * k), false)
		var w := UiHomeV3.text_w(900, 40, UiShopV2.S_ALL_SET)
		UiHomeV3.draw_text(self, 900, 40, UiShopV2.S_ALL_SET, Vector2(size.x * 0.5 - w * 0.5, 24.0 + 180.0 + 8.0), UiShopV2.INK_SUB)


## Toast: pilula sistema (popups) na y 1456 stranice, drži 1,6 s.
class _Toast:
	extends Control

	var text: String = ""
	var _tw: Tween

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		visible = false

	func show_text(t: String) -> void:
		text = t
		visible = true
		modulate.a = 0.0
		queue_redraw()
		if _tw != null and _tw.is_valid():
			_tw.kill()
		_tw = create_tween()
		_tw.tween_property(self, "modulate:a", 1.0, 0.2)
		_tw.tween_interval(UiShopV2.T_TOAST)
		_tw.tween_property(self, "modulate:a", 0.0, 0.25)
		_tw.tween_callback(hide)

	## S1 · toast sistema (design_handoff_popups): pilula s mint ✓, centrirana u svom okviru.
	func _draw() -> void:
		var w := PopupToast.pill_width(text, true)
		PopupToast.draw_pill(self, Rect2((size.x - w) * 0.5, (size.y - UiPopups.TOAST_H) * 0.5, w, UiPopups.TOAST_H), text, null, "check")
