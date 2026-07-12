extends Control

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")
const AlmanacRow := preload("res://scripts/ui/shop_almanac_row.gd")

@onready var coins_label: Label = $RootVBox/ResourceBar/HBox/CoinsRow/CoinsLabel
@onready var seeds_label: Label = $RootVBox/ResourceBar/HBox/SeedsRow/SeedsLabel
@onready var wallet_icon: TextureRect = $RootVBox/ResourceBar/HBox/CoinsRow/WalletIcon
@onready var top_progress_title: Label = $RootVBox/TopProgress/VBox/TopProgressTitle
@onready var top_progress_caption: Label = $RootVBox/TopProgress/VBox/TopProgressCaption
@onready var top_progress_bar: ProgressBar = $RootVBox/TopProgress/VBox/TopProgressRow/TopProgressBar
@onready var top_progress_label: Label = $RootVBox/TopProgress/VBox/TopProgressRow/TopProgressLabel
@onready var top_coin_button: UiClickButton = $RootVBox/TopProgress/VBox/TopCoinButton
@onready var almanac_scroll: ScrollContainer = $RootVBox/AlmanacScroll
@onready var almanac_list: VBoxContainer = $RootVBox/AlmanacScroll/AlmanacList
@onready var status_label: Label = $RootVBox/IapPanel/VBox/StatusLabel
@onready var remove_ads_button: UiClickButton = $RootVBox/IapPanel/VBox/RemoveAdsButton
@onready var remove_ads_desc: Label = $RootVBox/IapPanel/VBox/RemoveAdsDesc
@onready var starter_pack_button: UiClickButton = $RootVBox/IapPanel/VBox/StarterPackButton
@onready var starter_pack_desc: Label = $RootVBox/IapPanel/VBox/StarterPackDesc
@onready var restore_button: UiClickButton = $RootVBox/IapPanel/VBox/RestoreButton
@onready var reset_dev_button: UiClickButton = $RootVBox/IapPanel/VBox/ResetDevButton
@onready var back_button: UiClickButton = $RootVBox/TopBar/BackButton

var _rebuild_pending: bool = false


func _ready() -> void:
	$Dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_top_progress_bar()
	var tex := UI_ASSETS.get_kenney_icon("wallet")
	if wallet_icon and tex:
		wallet_icon.texture = tex
	top_coin_button.clicked.connect(_on_coin_unlock_pressed)
	remove_ads_button.clicked.connect(_on_remove_ads_pressed)
	starter_pack_button.clicked.connect(_on_starter_pack_pressed)
	restore_button.clicked.connect(_on_restore_pressed)
	reset_dev_button.clicked.connect(_on_reset_dev_pressed)
	back_button.clicked.connect(_on_back_pressed)
	IAPManager.purchase_completed.connect(_on_purchase_completed)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	IAPManager.catalog_updated.connect(_refresh_ui)
	IAPManager.restore_completed.connect(_on_restore_completed)
	if almanac_scroll:
		almanac_scroll.resized.connect(_sync_almanac_width)
	visibility_changed.connect(_on_visibility_changed)
	_refresh_ui()


func _on_visibility_changed() -> void:
	if visible:
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


func _sync_almanac_width() -> void:
	if almanac_list and almanac_scroll:
		almanac_list.custom_minimum_size.x = almanac_scroll.size.x


func _refresh_ui() -> void:
	_update_resources()
	_refresh_top_progress()
	_request_almanac_rebuild()
	_refresh_iap_section()


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


func _request_almanac_rebuild() -> void:
	if _rebuild_pending:
		return
	_rebuild_pending = true
	call_deferred("_rebuild_almanac")


func _rebuild_almanac() -> void:
	_rebuild_pending = false
	if almanac_list == null:
		return
	for child in almanac_list.get_children():
		almanac_list.remove_child(child)
		child.queue_free()
	call_deferred("_populate_almanac")


func _populate_almanac() -> void:
	if not is_inside_tree() or almanac_list == null:
		return
	for entry in GameState.get_almanac_chain_ui_data():
		var row := AlmanacRow.new()
		almanac_list.add_child(row)
		row.apply(entry)
		if not bool(entry.get("spawn_unlocked", true)) and bool(entry.get("can_coin_unlock", false)):
			row.coin_unlock_pressed.connect(_on_row_coin_unlock_pressed)
	call_deferred("_sync_almanac_width")


func _refresh_iap_section() -> void:
	if status_label == null:
		return
	status_label.text = "Optional real-money purchases — Fair F2P."
	remove_ads_desc.text = CONFIG.get_product_description(CONFIG.SKU_REMOVE_ADS)
	starter_pack_desc.text = CONFIG.get_product_description(CONFIG.SKU_STARTER_PACK)
	remove_ads_button.label_text = _product_button_label(CONFIG.SKU_REMOVE_ADS)
	starter_pack_button.label_text = _product_button_label(CONFIG.SKU_STARTER_PACK)
	remove_ads_button.disabled = IAPManager.owns_product(CONFIG.SKU_REMOVE_ADS)
	starter_pack_button.disabled = IAPManager.owns_product(CONFIG.SKU_STARTER_PACK)
	restore_button.visible = not IAPManager.is_stub_mode()
	restore_button.disabled = IAPManager.is_busy()
	reset_dev_button.visible = Engine.is_editor_hint() and IAPManager.is_stub_mode()
	reset_dev_button.disabled = IAPManager.is_busy()


func _product_button_label(sku: String) -> String:
	var owned := IAPManager.owns_product(sku)
	var prefix := CONFIG.get_product_title(sku)
	var price := IAPManager.get_price_label(sku)
	if owned:
		return "%s — Owned" % prefix
	return "%s — %s" % [prefix, price]


func _on_row_coin_unlock_pressed() -> void:
	_do_coin_unlock()


func _on_coin_unlock_pressed() -> void:
	_do_coin_unlock()


func _do_coin_unlock() -> void:
	if status_label:
		status_label.text = GameState.try_coin_unlock_next_seed()
	_update_resources()
	_refresh_top_progress()
	_request_almanac_rebuild()


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
			status_label.text = "Starter pack unlocked — +%d coins, +%d seeds!" % [
				CONFIG.STARTER_PACK_COINS,
				CONFIG.STARTER_PACK_SEEDS,
			]
		_:
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
