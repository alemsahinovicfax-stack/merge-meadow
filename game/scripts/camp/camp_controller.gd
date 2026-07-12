extends Control

const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")

@onready var main_scroll: ScrollContainer = $RootVBox/MainScroll
@onready var scroll_content: VBoxContainer = $RootVBox/MainScroll/Content
@onready var info_label: Label = $RootVBox/MainScroll/Content/InfoLabel
@onready var merge_hint_label: Label = $RootVBox/MainScroll/Content/MergeHintLabel
@onready var garden_stash_label: Label = $RootVBox/MainScroll/Content/GardenStashCard/HBox/GardenStashLabel
@onready var crystal_exchange_button: UiClickButton = (
	$RootVBox/MainScroll/Content/GardenStashCard/HBox/CrystalExchangeButton
)
@onready var coins_label: Label = $RootVBox/TopStrip/VBox/ResourceBar/CoinsRow/CoinsLabel
@onready var seeds_label: Label = $RootVBox/TopStrip/VBox/ResourceBar/SeedsRow/SeedsLabel
@onready var wallet_icon: TextureRect = $RootVBox/TopStrip/VBox/ResourceBar/CoinsRow/WalletIcon
@onready var daily_chest_button: UiClickButton = $RootVBox/TopStrip/VBox/ResourceBar/DailyChestButton
@onready var sprinkler_label: Label = $RootVBox/MainScroll/Content/UpgradeCards/SprinklerCard/HBox/SprinklerLabel
@onready var upgrade_button: UiClickButton = $RootVBox/MainScroll/Content/UpgradeCards/SprinklerCard/HBox/UpgradeButton
@onready var multiplier_label: Label = $RootVBox/MainScroll/Content/UpgradeCards/LootCard/HBox/MultiplierLabel
@onready var upgrade_multiplier_button: UiClickButton = (
	$RootVBox/MainScroll/Content/UpgradeCards/LootCard/HBox/UpgradeMultiplierButton
)
@onready var loadout_button: UiClickButton = $RootVBox/MainScroll/Content/SecondaryRow/LoadoutButton
@onready var exchange_button: UiClickButton = $RootVBox/MainScroll/Content/SecondaryRow/ExchangeButton
@onready var home_button: UiClickButton = $RootVBox/TopStrip/VBox/TopBar/HomeButton
@onready var collection_button: UiClickButton = $RootVBox/TopStrip/VBox/TopBar/CollectionButton
@onready var collection_badge: Label = $RootVBox/TopStrip/VBox/TopBar/CollectionButton/CollectionBadge
@onready var merge_button: UiClickButton = $FooterBar/FooterHBox/MergeButton
@onready var play_button: UiClickButton = $FooterBar/FooterHBox/PlayButton
@onready var settings_button: UiClickButton = $RootVBox/TopStrip/VBox/TopBar/SettingsButton
@onready var companion_hint: Label = $RootVBox/MainScroll/Content/CompanionCard/VBox/CompanionHint
@onready var pip_companion_slot: Control = $RootVBox/MainScroll/Content/CompanionCard/VBox/CompanionRow/PipSlot
@onready var mochi_companion_slot: Control = $RootVBox/MainScroll/Content/CompanionCard/VBox/CompanionRow/MochiSlot


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.ensure_loot_in_camp_bag()
	upgrade_button.clicked.connect(_on_upgrade_pressed)
	upgrade_multiplier_button.clicked.connect(_on_upgrade_multiplier_pressed)
	exchange_button.clicked.connect(_on_exchange_pressed)
	crystal_exchange_button.clicked.connect(_on_crystal_exchange_pressed)
	daily_chest_button.clicked.connect(_on_daily_chest_pressed)
	loadout_button.clicked.connect(_on_loadout_pressed)
	home_button.clicked.connect(_on_main_menu_pressed)
	collection_button.clicked.connect(_on_collection_pressed)
	play_button.clicked.connect(_on_play_pressed)
	merge_button.clicked.connect(_on_merge_pressed)
	if main_scroll:
		main_scroll.resized.connect(_sync_scroll_width)
	_setup_wallet_icon()
	_setup_safe_area()
	_refresh_ui()
	if GameState.should_offer_merge_arena() and GameState.should_prompt_merge_tutorial():
		call_deferred("_on_merge_pressed")


func _setup_wallet_icon() -> void:
	var tex := UI_ASSETS.get_kenney_icon("wallet")
	if wallet_icon and tex:
		wallet_icon.texture = tex


func _setup_safe_area() -> void:
	if settings_button:
		SAFE_AREA.apply_top_margin($RootVBox/TopStrip, 8.0)
		SAFE_AREA.apply_horizontal_margins($RootVBox/TopStrip)
	if pip_companion_slot and pip_companion_slot.has_signal("slot_pressed"):
		pip_companion_slot.slot_pressed.connect(_on_companion_slot_pressed)
	if mochi_companion_slot and mochi_companion_slot.has_signal("slot_pressed"):
		mochi_companion_slot.slot_pressed.connect(_on_companion_slot_pressed)


func _sync_scroll_width() -> void:
	if scroll_content and main_scroll:
		scroll_content.custom_minimum_size.x = main_scroll.size.x


func _refresh_ui(status: String = "") -> void:
	if coins_label:
		coins_label.text = "%d" % GameState.wallet_coins
	if seeds_label:
		seeds_label.text = "%d / %d" % [
			GameState.sum_seed_bag(GameState.seed_bag),
			GameState.SEED_BAG_SOFT_CAP,
		]

	sprinkler_label.text = (
		"Sprinkler Lv %d/%d · donated %d/%d · reach %dpx"
		% [
			GameState.magnet_level,
			GameState.MAGNET_MAX_LEVEL,
			GameState.sprinkler_donations,
			GameState.MAGNET_COST_T2,
			int(GameState.get_magnet_radius()),
		]
	)
	multiplier_label.text = (
		"%s · donated %d/%d"
		% [
			GameState.format_loot_multiplier_label(),
			GameState.multiplier_donations,
			GameState.MULTIPLIER_COST_T3,
		]
	)

	upgrade_button.disabled = (
		GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL
		or GameState.sprinkler_donations < GameState.MAGNET_COST_T2
	)
	upgrade_multiplier_button.disabled = (
		GameState.multiplier_level >= GameState.MULTIPLIER_MAX_LEVEL
		or GameState.multiplier_donations < GameState.MULTIPLIER_COST_T3
	)

	var exch_type := GameState.first_exchangeable_type_in_bag()
	var crystal_total := GameState.get_garden_crystal_total()
	exchange_button.disabled = exch_type.is_empty()
	exchange_button.label_text = "Trade 3 seeds → %d coins" % GameState.EXCHANGE_COINS_REWARD

	if garden_stash_label:
		garden_stash_label.text = GameState.format_garden_crystal_stash_label()
	if crystal_exchange_button:
		crystal_exchange_button.disabled = crystal_total <= 0
		crystal_exchange_button.label_text = "Exchange → %d coins" % GameState.CRYSTAL_EXCHANGE_COINS

	if GameState.can_claim_daily_chest():
		daily_chest_button.visible = true
		daily_chest_button.disabled = false
	else:
		daily_chest_button.visible = GameState.tutorial_complete

	loadout_button.disabled = not GameState.loadout_enabled()
	if GameState.loadout_enabled():
		loadout_button.label_text = GameState.format_loadout_label()

	var bag_count := GameState.sum_seed_bag(GameState.seed_bag)
	if merge_hint_label:
		if GameState.should_prompt_merge_tutorial():
			merge_hint_label.text = "Tutorial: open Merge and drag same seeds together."
		elif bag_count > 0:
			if crystal_total > 0:
				merge_hint_label.text = (
					"Seeds to merge + %d garden crystals — use Exchange card above."
					% crystal_total
				)
			else:
				merge_hint_label.text = "You have seeds to merge — tap Merge below."
		elif crystal_total > 0:
			merge_hint_label.text = (
				"%d crystals in garden stash — tap Exchange for coins."
				% crystal_total
			)
		else:
			merge_hint_label.text = "Run → collect seeds → Merge here."

	if collection_badge:
		collection_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var news := GameState.count_collection_journal_news()
		collection_badge.visible = news > 0
		collection_badge.text = "!" if news == 1 else str(mini(news, 9))

	_refresh_companion_ui()
	call_deferred("_sync_scroll_width")

	if status != "":
		info_label.text = status
	elif info_label.text.is_empty():
		info_label.text = "Welcome to camp — upgrade, merge, then Play."


func _refresh_companion_ui() -> void:
	var active := GameState.get_active_companion_id()
	if pip_companion_slot and pip_companion_slot.has_method("set_selected"):
		pip_companion_slot.set_selected(active == GameState.COMPANION_PIP)
	if mochi_companion_slot and mochi_companion_slot.has_method("set_selected"):
		mochi_companion_slot.set_selected(active == GameState.COMPANION_MOCHI)
	if companion_hint:
		companion_hint.text = GameState.format_mochi_unlock_hint()
	var unlock_msg := GameState.poll_mochi_unlock_toast()
	if not unlock_msg.is_empty():
		info_label.text = unlock_msg


func _on_companion_slot_pressed(companion_id: String) -> void:
	_refresh_ui(GameState.try_set_active_companion(companion_id))


func _on_merge_pressed() -> void:
	GameState.go_to_merge_arena()


func _on_upgrade_pressed() -> void:
	if GameState.try_upgrade_magnet():
		_refresh_ui("Sprinkler upgraded!")
	else:
		_refresh_ui()


func _on_upgrade_multiplier_pressed() -> void:
	if GameState.try_upgrade_multiplier():
		_refresh_ui("Loot Boost upgraded — ×%.2g next run!" % GameState.get_loot_multiplier())
	else:
		_refresh_ui()


func _on_exchange_pressed() -> void:
	var type_id := GameState.first_exchangeable_type_in_bag()
	if type_id.is_empty():
		_refresh_ui("Need 3 of the same seed type to trade.")
		return
	if GameState.exchange_seeds_from_bag(type_id):
		var name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
		_refresh_ui("Traded 3× %s for %d coins." % [name, GameState.EXCHANGE_COINS_REWARD])


func _on_crystal_exchange_pressed() -> void:
	var crystal_type := GameState.first_garden_crystal_type()
	if crystal_type.is_empty():
		_refresh_ui("No crystals yet — merge T3 in the arena.")
		return
	if GameState.exchange_garden_crystal(crystal_type):
		var name: String = GameState.SEED_DISPLAY_NAMES.get(crystal_type, crystal_type.capitalize())
		_refresh_ui("Traded %s crystal for %d coins." % [name, GameState.CRYSTAL_EXCHANGE_COINS])


func _on_daily_chest_pressed() -> void:
	_refresh_ui(GameState.claim_daily_chest())


func _on_loadout_pressed() -> void:
	if not GameState.loadout_enabled():
		_refresh_ui("Merge your first flower to unlock the basket.")
		return
	_refresh_ui(GameState.cycle_loadout_from_bag())


func _on_collection_pressed() -> void:
	GameState.go_to_collection_journal()


func _on_main_menu_pressed() -> void:
	SceneRouter.change_to(GameState.SCENE_MAIN)


func _on_play_pressed() -> void:
	GameState.notify_camp_play()
	GameState.begin_campaign_run()
	SceneRouter.change_to(GameState.SCENE_RUN)
