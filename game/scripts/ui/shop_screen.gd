extends Control

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var remove_ads_button: UiClickButton = $Panel/VBox/RemoveAdsButton
@onready var remove_ads_desc: Label = $Panel/VBox/RemoveAdsDesc
@onready var starter_pack_button: UiClickButton = $Panel/VBox/StarterPackButton
@onready var starter_pack_desc: Label = $Panel/VBox/StarterPackDesc
@onready var restore_button: UiClickButton = $Panel/VBox/RestoreButton
@onready var reset_dev_button: UiClickButton = $Panel/VBox/ResetDevButton
@onready var back_button: UiClickButton = $Panel/VBox/BackButton


func _ready() -> void:
	$Dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	remove_ads_button.clicked.connect(_on_remove_ads_pressed)
	starter_pack_button.clicked.connect(_on_starter_pack_pressed)
	restore_button.clicked.connect(_on_restore_pressed)
	reset_dev_button.clicked.connect(_on_reset_dev_pressed)
	back_button.clicked.connect(_on_back_pressed)
	IAPManager.purchase_completed.connect(_on_purchase_completed)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	IAPManager.catalog_updated.connect(_refresh_ui)
	IAPManager.restore_completed.connect(_on_restore_completed)
	_refresh_ui()


func _refresh_ui() -> void:
	status_label.text = "Support the game — optional purchases."
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
