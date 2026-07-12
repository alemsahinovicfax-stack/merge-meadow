extends Control

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")
const CosmeticRow := preload("res://scripts/ui/shop_cosmetic_row.gd")
const BoosterRow := preload("res://scripts/ui/shop_booster_row.gd")
const CATALOG := preload("res://scripts/monetization/cosmetic_catalog.gd")

@onready var coins_label: Label = $RootVBox/ResourceBar/HBox/CoinsRow/CoinsLabel
@onready var seeds_label: Label = $RootVBox/ResourceBar/HBox/SeedsRow/SeedsLabel
@onready var wallet_icon: TextureRect = $RootVBox/ResourceBar/HBox/CoinsRow/WalletIcon
@onready var top_progress_title: Label = $RootVBox/TopProgress/VBox/TopProgressTitle
@onready var top_progress_caption: Label = $RootVBox/TopProgress/VBox/TopProgressCaption
@onready var top_progress_bar: ProgressBar = $RootVBox/TopProgress/VBox/TopProgressRow/TopProgressBar
@onready var top_progress_label: Label = $RootVBox/TopProgress/VBox/TopProgressRow/TopProgressLabel
@onready var top_coin_button: UiClickButton = $RootVBox/TopProgress/VBox/TopCoinButton
@onready var main_scroll: ScrollContainer = $RootVBox/MainScroll
@onready var main_content: VBoxContainer = $RootVBox/MainScroll/MainContent
@onready var almanac_list: VBoxContainer = $RootVBox/MainScroll/MainContent/AlmanacList
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

var _ui_ready: bool = false
var _refresh_pending: bool = false
var _shop_lists_built: bool = false
var _last_scroll_width: float = -1.0


func _ready() -> void:
	$Dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_top_progress_bar()
	var tex := UI_ASSETS.get_kenney_icon("wallet")
	if wallet_icon and tex:
		wallet_icon.texture = tex
	if top_coin_button:
		top_coin_button.clicked.connect(_on_coin_unlock_pressed)
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
	IAPManager.purchase_completed.connect(_on_purchase_completed)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	IAPManager.catalog_updated.connect(_on_catalog_updated)
	IAPManager.restore_completed.connect(_on_restore_completed)
	if main_scroll:
		main_scroll.resized.connect(_sync_scroll_width)
	call_deferred("_finish_ready")


func _finish_ready() -> void:
	if not is_inside_tree():
		return
	_ui_ready = true
	_ensure_shop_lists_built()
	_refresh_ui()


func _ensure_shop_lists_built() -> void:
	if _shop_lists_built or almanac_list == null:
		return
	_shop_lists_built = true
	var entries := GameState.get_almanac_chain_ui_data()
	# Almanac rows built as simple labels to avoid Godot crash with many dynamic rows.
	for entry in entries:
		var line := Label.new()
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 18)
		line.text = _format_almanac_line(entry)
		almanac_list.add_child(line)
	for entry in GameState.get_cosmetic_shop_entries():
		var item_id := str(entry.get("id", ""))
		var row := CosmeticRow.new()
		row.apply(item_id)
		cosmetics_list.add_child(row)
		row.buy_pressed.connect(_on_cosmetic_buy.bind(item_id))
		row.equip_pressed.connect(_on_cosmetic_equip.bind(item_id))
	for booster_id in CONFIG.all_booster_ids():
		var brow := BoosterRow.new()
		brow.apply(booster_id)
		boosters_list.add_child(brow)
		brow.buy_pressed.connect(_on_booster_buy.bind(booster_id))
		brow.use_pressed.connect(_on_booster_use.bind(booster_id))


func _on_catalog_updated() -> void:
	if _ui_ready and _shop_lists_built:
		_refresh_ui()


func _style_top_progress_bar() -> void:
	if top_progress_bar == null:
		return
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.86, 0.9, 0.86)
	bg.set_corner_radius_all(10)
	top_progress_bar.add_theme_stylebox_override("background", bg)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.35, 0.72, 0.44)
	fill.set_corner_radius_all(10)
	top_progress_bar.add_theme_stylebox_override("fill", fill)
	top_progress_bar.show_percentage = false


func _sync_scroll_width() -> void:
	if main_content == null or main_scroll == null:
		return
	var width := main_scroll.size.x
	if width <= 1.0 or is_equal_approx(width, _last_scroll_width):
		return
	_last_scroll_width = width
	main_content.custom_minimum_size.x = width


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
	_refresh_top_progress()
	_refresh_almanac_rows()
	_refresh_cosmetic_rows()
	_refresh_booster_rows()
	_refresh_iap_section()
	_sync_scroll_width()


func _format_almanac_line(entry: Dictionary) -> String:
	var name: String = str(entry.get("name", "?"))
	var stars: String = str(entry.get("stars", ""))
	var spawn_unlocked := bool(entry.get("spawn_unlocked", false))
	var prog: Dictionary = entry.get("tier_progress", {})
	if spawn_unlocked and bool(prog.get("complete", false)):
		return "%s %s — all tiers discovered" % [name, stars]
	var caption := str(prog.get("caption", ""))
	if caption.is_empty():
		return "%s %s" % [name, stars]
	var have := int(prog.get("have", 0))
	var need := maxi(1, int(prog.get("need", 1)))
	return "%s %s — %s (%d/%d)" % [name, stars, caption, have, need]


func _refresh_almanac_rows() -> void:
	if almanac_list == null:
		return
	var entries := GameState.get_almanac_chain_ui_data()
	for i in entries.size():
		if i >= almanac_list.get_child_count():
			break
		var row := almanac_list.get_child(i)
		if row is Label:
			row.text = _format_almanac_line(entries[i])


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


func _refresh_top_progress() -> void:
	if top_progress_bar == null:
		return
	var prog := GameState.get_almanac_top_progress()
	if bool(prog.get("complete", false)):
		top_progress_title.text = str(prog.get("title", "Almanac complete"))
		top_progress_caption.text = ""
		top_progress_bar.max_value = 1.0
		top_progress_bar.value = 1.0
		top_progress_label.text = "✓"
		top_coin_button.visible = false
		return

	var have := int(prog.get("have", 0))
	var need := maxi(1, int(prog.get("need", 1)))
	top_progress_title.text = str(prog.get("title", "Progress"))
	top_progress_caption.text = str(prog.get("caption", ""))
	top_progress_bar.max_value = float(need)
	top_progress_bar.value = float(clampi(have, 0, need))
	top_progress_label.text = "%d / %d" % [have, need]

	if bool(prog.get("show_coin", false)):
		var cost := int(prog.get("coin_cost", 0))
		top_coin_button.visible = cost > 0
		top_coin_button.label_text = "Unlock now — %d coins" % cost
		top_coin_button.disabled = GameState.wallet_coins < cost
	else:
		top_coin_button.visible = false


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


func _on_coin_unlock_pressed() -> void:
	_do_coin_unlock()


func _do_coin_unlock() -> void:
	if status_label:
		status_label.text = GameState.try_coin_unlock_next_seed()
	_refresh_ui()


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
	SceneRouter.change_to(GameState.SCENE_MAIN)
