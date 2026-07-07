extends Control

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var remove_ads_button: UiClickButton = $Panel/VBox/RemoveAdsButton
@onready var starter_pack_button: UiClickButton = $Panel/VBox/StarterPackButton
@onready var back_button: UiClickButton = $Panel/VBox/BackButton


func _ready() -> void:
	$Dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	remove_ads_button.clicked.connect(_on_remove_ads_pressed)
	starter_pack_button.clicked.connect(_on_starter_pack_pressed)
	back_button.clicked.connect(_on_back_pressed)
	IAPManager.purchase_completed.connect(_on_purchase_completed)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	_refresh_ui()


func _refresh_ui() -> void:
	var stub_note := " (test stub)" if IAPManager.is_stub_mode() else ""
	status_label.text = "Shop — IAP test%s" % stub_note
	remove_ads_button.label_text = "Remove Ads — %s" % IAPManager.get_price_label(CONFIG.SKU_REMOVE_ADS)
	starter_pack_button.label_text = "Starter Pack — %s" % IAPManager.get_price_label(CONFIG.SKU_STARTER_PACK)
	remove_ads_button.disabled = IAPManager.owns_product(CONFIG.SKU_REMOVE_ADS)
	starter_pack_button.disabled = IAPManager.owns_product(CONFIG.SKU_STARTER_PACK)


func _on_remove_ads_pressed() -> void:
	status_label.text = "Processing purchase…"
	IAPManager.purchase(CONFIG.SKU_REMOVE_ADS)


func _on_starter_pack_pressed() -> void:
	status_label.text = "Processing purchase…"
	IAPManager.purchase(CONFIG.SKU_STARTER_PACK)


func _on_purchase_completed(sku: String) -> void:
	match sku:
		CONFIG.SKU_REMOVE_ADS:
			status_label.text = "Ads removed! (interstitials off in launch build)"
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


func _on_back_pressed() -> void:
	SceneRouter.change_to(GameState.SCENE_MAIN)
