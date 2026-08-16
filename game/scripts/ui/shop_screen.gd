extends Control

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const PICKUP_ASSETS := preload("res://scripts/visual/pickup_assets.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const CosmeticRow := preload("res://scripts/ui/shop_cosmetic_row.gd")
const BoosterRow := preload("res://scripts/ui/shop_booster_row.gd")
const CATALOG := preload("res://scripts/monetization/cosmetic_catalog.gd")

const SHOP_SECTION_TITLE := 32
const SHOP_HINT := 20
const SHOP_BODY := 24
const SHOP_BUTTON := 26

@onready var coins_label: Label = $RootVBox/ResourceBar/HBox/CoinsRow/CoinsLabel
@onready var seeds_label: Label = $RootVBox/ResourceBar/HBox/SeedsRow/SeedsLabel
@onready var wallet_icon: TextureRect = $RootVBox/ResourceBar/HBox/CoinsRow/WalletIcon
@onready var seeds_icon: TextureRect = $RootVBox/ResourceBar/HBox/SeedsRow/SeedsIcon
@onready var top_bar: HBoxContainer = $RootVBox/TopBar
@onready var resource_bar: PanelContainer = $RootVBox/ResourceBar
@onready var main_scroll: ScrollContainer = $RootVBox/MainScroll
@onready var main_content: VBoxContainer = $RootVBox/MainScroll/MainContent
@onready var cosmetics_list: VBoxContainer = $RootVBox/MainScroll/MainContent/CoinShopPanel/VBox/CosmeticsList
@onready var boosters_list: VBoxContainer = $RootVBox/MainScroll/MainContent/BoosterPanel/VBox/BoostersList
@onready var status_label: Label = $RootVBox/MainScroll/MainContent/IapPanel/VBox/StatusLabel
@onready var remove_ads_button: UiClickButton = $RootVBox/MainScroll/MainContent/IapPanel/VBox/RemoveAdsButton
@onready var remove_ads_desc: Label = $RootVBox/MainScroll/MainContent/IapPanel/VBox/RemoveAdsDesc
@onready var starter_pack_button: UiClickButton = $RootVBox/MainScroll/MainContent/IapPanel/VBox/StarterPackButton
@onready var starter_pack_desc: Label = $RootVBox/MainScroll/MainContent/IapPanel/VBox/StarterPackDesc
@onready var restore_button: UiClickButton = $RootVBox/MainScroll/MainContent/IapPanel/VBox/RestoreButton
@onready var reset_dev_button: UiClickButton = $RootVBox/MainScroll/MainContent/IapPanel/VBox/ResetDevButton
@onready var back_button: UiClickButton = $RootVBox/TopBar/BackButton
@onready var title_label: Label = $RootVBox/TopBar/TitleLabel
@onready var root_vbox: VBoxContainer = $RootVBox

var _ui_ready: bool = false
var _refresh_pending: bool = false
var _shop_lists_built: bool = false
var _hub_embedded: bool = false


func _ready() -> void:
	$Dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hub_embedded = bool(get_meta("meta_hub_embedded", false))
	_setup_typography()
	var coin_tex := PICKUP_ASSETS.get_coin_texture()
	if wallet_icon and coin_tex:
		wallet_icon.texture = coin_tex
	var seed_tex := PICKUP_ASSETS.get_seed_texture()
	if seeds_icon and seed_tex:
		seeds_icon.texture = seed_tex
	if remove_ads_button:
		remove_ads_button.clicked.connect(_on_remove_ads_pressed)
	if starter_pack_button:
		starter_pack_button.clicked.connect(_on_starter_pack_pressed)
	if restore_button:
		restore_button.clicked.connect(_on_restore_pressed)
	if reset_dev_button:
		reset_dev_button.clicked.connect(_on_reset_dev_pressed)
	if back_button:
		back_button.clicked.connect(_on_back_pressed)
	call_deferred("_finish_ready")


func _finish_ready() -> void:
	if not is_inside_tree():
		return
	_ui_ready = true
	call_deferred("_build_shop_lists_deferred")


func _build_shop_lists_deferred() -> void:
	if not is_inside_tree():
		return
	_ensure_shop_lists_built()
	_connect_iap_signals()
	_refresh_ui()


func _connect_iap_signals() -> void:
	if IAPManager.purchase_completed.is_connected(_on_purchase_completed):
		return
	IAPManager.purchase_completed.connect(_on_purchase_completed)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	IAPManager.catalog_updated.connect(_on_catalog_updated)
	IAPManager.restore_completed.connect(_on_restore_completed)


func _ensure_shop_lists_built() -> void:
	if _shop_lists_built:
		return
	if cosmetics_list == null or boosters_list == null:
		push_error("ShopScreen: list container missing — skip dynamic rows")
		return
	_shop_lists_built = true
	for entry in GameState.get_cosmetic_shop_entries():
		var item_id := str(entry.get("id", ""))
		if item_id.is_empty():
			continue
		var row := ShopCosmeticRow.new()
		cosmetics_list.add_child(row)
		row.apply(item_id)
		# Signal already emits item_id — do not .bind (double-arg breaks buy).
		row.buy_pressed.connect(_on_cosmetic_buy)
		row.equip_pressed.connect(_on_cosmetic_equip)
	for booster_id in CONFIG.all_booster_ids():
		var brow := ShopBoosterRow.new()
		boosters_list.add_child(brow)
		brow.apply(booster_id)
		brow.buy_pressed.connect(_on_booster_buy)
		brow.use_pressed.connect(_on_booster_use)


func _on_catalog_updated() -> void:
	if _ui_ready and _shop_lists_built:
		_refresh_ui()


func _setup_typography() -> void:
	if title_label:
		TEXT_LAYOUT.screen_title(title_label)
	if coins_label:
		TEXT_LAYOUT.stat_label(coins_label)
	if seeds_label:
		TEXT_LAYOUT.stat_label(seeds_label)
	var coins_caption := get_node_or_null("RootVBox/ResourceBar/HBox/CoinsRow/CoinsCaption")
	if coins_caption is Label:
		TEXT_LAYOUT.caption_label(coins_caption)
	var seeds_caption := get_node_or_null("RootVBox/ResourceBar/HBox/SeedsRow/SeedsCaption")
	if seeds_caption is Label:
		TEXT_LAYOUT.caption_label(seeds_caption)
	_apply_scroll_typography()
	if root_vbox and not _hub_embedded:
		SAFE_AREA.apply_top_margin(root_vbox, 8.0)
		SAFE_AREA.apply_bottom_margin(root_vbox, 8.0)


func _apply_scroll_typography() -> void:
	if main_content == null:
		return
	var coin_panel := main_content.get_node_or_null("CoinShopPanel/VBox")
	if coin_panel:
		var coin_title := coin_panel.get_node_or_null("CoinShopTitle")
		if coin_title is Label:
			_shop_section_title(coin_title)
		var coin_hint := coin_panel.get_node_or_null("CoinShopHint")
		if coin_hint is Label:
			_shop_hint_label(coin_hint)
	var booster_panel := main_content.get_node_or_null("BoosterPanel/VBox")
	if booster_panel:
		var booster_title := booster_panel.get_node_or_null("BoosterTitle")
		if booster_title is Label:
			_shop_section_title(booster_title)
		var booster_hint := booster_panel.get_node_or_null("BoosterHint")
		if booster_hint is Label:
			_shop_hint_label(booster_hint)
	var iap_panel := main_content.get_node_or_null("IapPanel/VBox")
	if iap_panel:
		var iap_title := iap_panel.get_node_or_null("IapTitle")
		if iap_title is Label:
			_shop_section_title(iap_title)
	for label in [status_label, remove_ads_desc, starter_pack_desc]:
		if label:
			TEXT_LAYOUT.body_label_scroll(label)
			label.add_theme_font_size_override("font_size", SHOP_BODY)
	if remove_ads_button:
		remove_ads_button.font_size = SHOP_BUTTON
	if starter_pack_button:
		starter_pack_button.font_size = SHOP_BUTTON
	if restore_button:
		restore_button.font_size = SHOP_BUTTON
	if reset_dev_button:
		reset_dev_button.font_size = SHOP_BUTTON


func _shop_section_title(label: Label) -> void:
	TEXT_LAYOUT.section_title_scroll(label)
	label.add_theme_font_size_override("font_size", SHOP_SECTION_TITLE)


func _shop_hint_label(label: Label) -> void:
	TEXT_LAYOUT.caption_label_scroll(label)
	label.add_theme_font_size_override("font_size", SHOP_HINT)


func _refresh_ui() -> void:
	if not _ui_ready or not is_inside_tree():
		return
	if _refresh_pending:
		return
	_refresh_pending = true
	call_deferred("_apply_refresh")


func _apply_refresh() -> void:
	_refresh_pending = false
	if not is_inside_tree():
		return
	_update_resources()
	_refresh_cosmetic_rows()
	_refresh_booster_rows()
	_refresh_iap_section()
	_notify_hub_chrome()


func _refresh_cosmetic_rows() -> void:
	if cosmetics_list == null:
		return
	for child in cosmetics_list.get_children():
		if child is CosmeticRow and child.item_id != "":
			child.apply(child.item_id)


func _refresh_booster_rows() -> void:
	if boosters_list == null:
		return
	for child in boosters_list.get_children():
		if child is BoosterRow and child.booster_id != "":
			child.apply(child.booster_id)


func _update_resources() -> void:
	if coins_label:
		coins_label.text = "%d" % GameState.wallet_coins
	if seeds_label:
		seeds_label.text = "%d / %d" % [
			GameState.sum_seed_bag(GameState.seed_bag),
			GameState.SEED_BAG_SOFT_CAP,
		]


func _on_cosmetic_buy(item_id: String) -> void:
	if status_label:
		status_label.text = GameState.buy_cosmetic_with_coins(item_id)
	_refresh_ui()


func _on_cosmetic_equip(item_id: String) -> void:
	if GameState.equip_cosmetic(item_id) and status_label:
		status_label.text = "%s equipped." % CATALOG.get_title(item_id)
	_refresh_ui()


func _on_booster_buy(booster_id: String) -> void:
	var sku := CONFIG.booster_sku(booster_id)
	if sku.is_empty():
		return
	status_label.text = "Processing purchase…"
	IAPManager.purchase(sku)


func _on_booster_use(booster_id: String) -> void:
	if status_label:
		status_label.text = GameState.use_booster(booster_id)
	_refresh_ui()


func _refresh_iap_section() -> void:
	if status_label == null or remove_ads_button == null:
		return
	status_label.text = "Optional real-money purchases — Fair F2P."
	if remove_ads_desc:
		remove_ads_desc.text = CONFIG.get_product_description(CONFIG.SKU_REMOVE_ADS)
	if starter_pack_desc:
		starter_pack_desc.text = CONFIG.get_product_description(CONFIG.SKU_STARTER_PACK)
	remove_ads_button.label_text = _product_button_label(CONFIG.SKU_REMOVE_ADS)
	starter_pack_button.label_text = _product_button_label(CONFIG.SKU_STARTER_PACK)
	remove_ads_button.disabled = IAPManager.owns_product(CONFIG.SKU_REMOVE_ADS)
	starter_pack_button.disabled = IAPManager.owns_product(CONFIG.SKU_STARTER_PACK)
	if restore_button:
		restore_button.visible = not IAPManager.is_stub_mode()
		restore_button.disabled = IAPManager.is_busy()
	if reset_dev_button:
		reset_dev_button.visible = Engine.is_editor_hint() and IAPManager.is_stub_mode()
		reset_dev_button.disabled = IAPManager.is_busy()


func _product_button_label(sku: String) -> String:
	var owned := IAPManager.owns_product(sku)
	var prefix := CONFIG.get_product_title(sku)
	var price := IAPManager.get_price_label(sku)
	if owned:
		return "%s — Owned" % prefix
	return "%s — %s" % [prefix, price]


func _on_remove_ads_pressed() -> void:
	status_label.text = "Processing purchase…"
	IAPManager.purchase(CONFIG.SKU_REMOVE_ADS)


func _on_starter_pack_pressed() -> void:
	status_label.text = "Processing purchase…"
	IAPManager.purchase(CONFIG.SKU_STARTER_PACK)


func _on_restore_pressed() -> void:
	status_label.text = "Restoring purchases…"
	IAPManager.restore_purchases()


func _on_reset_dev_pressed() -> void:
	IAPManager.reset_purchases_for_dev()
	status_label.text = "Dev reset — you can test purchases again."


func _on_purchase_completed(sku: String) -> void:
	match sku:
		CONFIG.SKU_REMOVE_ADS:
			status_label.text = "Ads removed — interstitials are off."
		CONFIG.SKU_STARTER_PACK:
			status_label.text = "Starter pack unlocked — +%d coins, +%d seeds, +%d booster!" % [
				CONFIG.STARTER_PACK_COINS,
				CONFIG.STARTER_PACK_SEEDS,
				CONFIG.STARTER_PACK_BOOSTERS,
			]
		_:
			var booster_id := CONFIG.sku_booster_id(sku)
			if not booster_id.is_empty():
				status_label.text = "Booster added to inventory!"
			else:
				status_label.text = "Purchase complete: %s" % sku
	_refresh_ui()


func _on_purchase_failed(_sku: String, reason: String) -> void:
	status_label.text = "Purchase failed — %s" % reason.replace("_", " ")
	_refresh_ui()


func _on_restore_completed() -> void:
	status_label.text = "Purchases restored."
	_refresh_ui()


func _on_back_pressed() -> void:
	if GameState.meta_hub_active:
		GameState.go_to_meta_home()
	else:
		SceneRouter.change_to(GameState.SCENE_MAIN)


func set_meta_hub_mode(enabled: bool) -> void:
	_hub_embedded = enabled
	if top_bar:
		top_bar.visible = not enabled
	if resource_bar:
		resource_bar.visible = not enabled
	if back_button:
		back_button.visible = not enabled


func refresh_for_meta_hub() -> void:
	_refresh_ui()


func _notify_hub_chrome() -> void:
	if not _hub_embedded or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "refresh_top_bar")
