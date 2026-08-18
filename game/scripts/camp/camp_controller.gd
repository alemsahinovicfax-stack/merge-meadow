extends Control

const PICKUP_ASSETS := preload("res://scripts/visual/pickup_assets.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const SeedBagChipScript := preload("res://scripts/camp/seed_bag_chip.gd")
const CrystalStashChipScript := preload("res://scripts/camp/crystal_stash_chip.gd")

@onready var root_vbox: VBoxContainer = %RootVBox
@onready var top_strip: PanelContainer = %TopStrip
@onready var home_button: UiClickButton = %HomeButton
@onready var camp_title: Label = %CampTitle
@onready var collection_button: UiClickButton = %CollectionButton
@onready var collection_badge: Label = %CollectionBadge
@onready var settings_button: UiClickButton = %SettingsButton
@onready var resource_bar: HBoxContainer = %ResourceBar
@onready var wallet_icon: TextureRect = %WalletIcon
@onready var seeds_icon: TextureRect = %SeedsIcon
@onready var coins_label: Label = %CoinsLabel
@onready var seeds_label: Label = %SeedsLabel
@onready var status_toast: PanelContainer = %StatusToast
@onready var status_label: Label = %StatusLabel
@onready var garden_cliff: Label = %GardenCliff
@onready var bag_label: Label = %BagLabel
@onready var seed_bag_grid: GridContainer = %SeedBagGrid
@onready var crystal_cliff: Label = %CrystalCliff
@onready var crystal_total_label: Label = %CrystalTotalLabel
@onready var crystal_grid: GridContainer = %CrystalGrid
@onready var crystal_exchange_button: UiClickButton = %CrystalExchangeButton
@onready var exchange_button: UiClickButton = %ExchangeButton
@onready var sprinkler_label: Label = %SprinklerLabel
@onready var sprinkler_caption: Label = %SprinklerCaption
@onready var upgrade_button: UiClickButton = %UpgradeButton
@onready var multiplier_label: Label = %MultiplierLabel
@onready var multiplier_caption: Label = %MultiplierCaption
@onready var upgrade_multiplier_button: UiClickButton = %UpgradeMultiplierButton
@onready var companion_title: Label = %CompanionTitle
@onready var companion_hint: Label = %CompanionHint
@onready var pip_companion_slot: Control = %PipSlot
@onready var mochi_companion_slot: Control = %MochiSlot
@onready var footer_bar: MarginContainer = %FooterBar
@onready var merge_button: UiClickButton = %MergeButton
@onready var play_button: UiClickButton = %PlayButton

var _meta_hub_embedded: bool = false
var _selected_trade_type: String = ""
var _selected_crystal_type: String = ""
var _force_default_trade_select: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_meta_hub_embedded = bool(get_meta("meta_hub_embedded", false))
	GameState.ensure_loot_in_camp_bag()
	upgrade_button.clicked.connect(_on_upgrade_pressed)
	upgrade_multiplier_button.clicked.connect(_on_upgrade_multiplier_pressed)
	exchange_button.clicked.connect(_on_exchange_pressed)
	crystal_exchange_button.clicked.connect(_on_crystal_exchange_pressed)
	home_button.clicked.connect(_on_main_menu_pressed)
	collection_button.clicked.connect(_on_collection_pressed)
	play_button.clicked.connect(_on_play_pressed)
	merge_button.clicked.connect(_on_merge_pressed)
	if settings_button:
		settings_button.clicked.connect(_on_settings_pressed)
	_setup_resource_icons()
	_setup_typography()
	_setup_safe_area()
	_apply_hub_chrome()
	_force_default_trade_select = true
	if _meta_hub_embedded:
		call_deferred("_refresh_ui")
	else:
		_refresh_ui()
	if (
		not _meta_hub_embedded
		and GameState.should_offer_merge_arena()
		and GameState.should_prompt_merge_tutorial()
	):
		call_deferred("_on_merge_pressed")

func _setup_resource_icons() -> void:
	var coin_tex := PICKUP_ASSETS.get_coin_texture()
	if wallet_icon and coin_tex:
		wallet_icon.texture = coin_tex
	var seed_tex := PICKUP_ASSETS.get_seed_texture()
	if seeds_icon and seed_tex:
		seeds_icon.texture = seed_tex

func _setup_typography() -> void:
	if camp_title:
		TEXT_LAYOUT.screen_title(camp_title)
	if coins_label:
		TEXT_LAYOUT.stat_label(coins_label)
	if seeds_label:
		TEXT_LAYOUT.stat_label(seeds_label)
	if status_label:
		TEXT_LAYOUT.body_label_scroll(status_label)
	if garden_cliff:
		TEXT_LAYOUT.caption_label_scroll(garden_cliff)
	if bag_label:
		TEXT_LAYOUT.body_label_scroll(bag_label)
	if crystal_cliff:
		TEXT_LAYOUT.caption_label_scroll(crystal_cliff)
	if crystal_total_label:
		TEXT_LAYOUT.body_label_scroll(crystal_total_label)
	if sprinkler_label:
		TEXT_LAYOUT.card_title_scroll(sprinkler_label)
	if sprinkler_caption:
		TEXT_LAYOUT.caption_label_scroll(sprinkler_caption)
	if multiplier_label:
		TEXT_LAYOUT.card_title_scroll(multiplier_label)
	if multiplier_caption:
		TEXT_LAYOUT.caption_label_scroll(multiplier_caption)
	if companion_title:
		TEXT_LAYOUT.card_title_scroll(companion_title)
	if companion_hint:
		TEXT_LAYOUT.caption_label_scroll(companion_hint)
	var garden_title := get_node_or_null("RootVBox/MainScroll/ContentMargin/Content/GardenCard/GardenVBox/GardenTitle")
	if garden_title is Label:
		TEXT_LAYOUT.section_title_scroll(garden_title)
	var crystal_title := get_node_or_null(
		"RootVBox/MainScroll/ContentMargin/Content/CrystalCard/CrystalVBox/CrystalTitle"
	)
	if crystal_title is Label:
		TEXT_LAYOUT.section_title_scroll(crystal_title)
	var run_prep_title := get_node_or_null(
		"RootVBox/MainScroll/ContentMargin/Content/RunPrepCard/RunPrepVBox/RunPrepTitle"
	)
	if run_prep_title is Label:
		TEXT_LAYOUT.section_title_scroll(run_prep_title)

func _setup_safe_area() -> void:
	if top_strip and not _meta_hub_embedded:
		SAFE_AREA.apply_top_margin(top_strip, 8.0)
		SAFE_AREA.apply_horizontal_margins(top_strip)
	if footer_bar:
		SAFE_AREA.apply_bottom_margin(footer_bar, 4.0 if _meta_hub_embedded else 8.0)
	if pip_companion_slot and pip_companion_slot.has_signal("slot_pressed"):
		pip_companion_slot.slot_pressed.connect(_on_companion_slot_pressed)
	if mochi_companion_slot and mochi_companion_slot.has_signal("slot_pressed"):
		mochi_companion_slot.slot_pressed.connect(_on_companion_slot_pressed)

func _apply_hub_chrome() -> void:
	var show_local_chrome := not _meta_hub_embedded
	if home_button:
		home_button.visible = show_local_chrome
	if settings_button:
		settings_button.visible = show_local_chrome
	if collection_button:
		collection_button.visible = show_local_chrome
	if resource_bar:
		resource_bar.visible = show_local_chrome
	if footer_bar:
		footer_bar.visible = show_local_chrome
	if root_vbox:
		if _meta_hub_embedded:
			root_vbox.offset_bottom = 0.0
		else:
			root_vbox.offset_bottom = -72.0
			if footer_bar:
				footer_bar.offset_top = -72.0

func set_meta_hub_mode(enabled: bool) -> void:
	_meta_hub_embedded = enabled
	_apply_hub_chrome()

func refresh_for_meta_hub() -> void:
	_force_default_trade_select = true
	_refresh_ui()

func _notify_hub_chrome() -> void:
	if not _meta_hub_embedded or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "refresh_top_bar")

func _refresh_ui(status: String = "") -> void:
	if coins_label:
		coins_label.text = "%d" % GameState.wallet_coins
	if seeds_label:
		seeds_label.text = "%d / %d" % [
			GameState.sum_seed_bag(GameState.seed_bag),
			GameState.SEED_BAG_SOFT_CAP,
		]

	_refresh_upgrade_cards()
	_refresh_garden_card()
	_refresh_crystal_card()
	_refresh_companion_ui()
	_refresh_collection_badge()
	_set_status_toast(status)
	_notify_hub_chrome()

func _refresh_upgrade_cards() -> void:
	var magnet_maxed := GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL
	var magnet_ready := GameState.sprinkler_donations >= GameState.MAGNET_COST_T2
	sprinkler_label.text = "Sprinkler  Lv %d/%d" % [
		GameState.magnet_level,
		GameState.MAGNET_MAX_LEVEL,
	]
	if magnet_maxed:
		sprinkler_caption.text = "Max level · reach %dpx" % int(GameState.get_magnet_radius())
		upgrade_button.label_text = "Maxed"
		upgrade_button.disabled = true
	elif magnet_ready:
		sprinkler_caption.text = "Donated %d/%d T2 — ready" % [
			GameState.sprinkler_donations,
			GameState.MAGNET_COST_T2,
		]
		upgrade_button.label_text = "Upgrade"
		upgrade_button.disabled = false
	else:
		sprinkler_caption.text = "Donated %d/%d T2 — donate in Arena" % [
			GameState.sprinkler_donations,
			GameState.MAGNET_COST_T2,
		]
		upgrade_button.label_text = "Upgrade"
		upgrade_button.disabled = true

	var loot_maxed := GameState.multiplier_level >= GameState.MULTIPLIER_MAX_LEVEL
	var loot_ready := GameState.multiplier_donations >= GameState.MULTIPLIER_COST_T3
	multiplier_label.text = GameState.format_loot_multiplier_label()
	if loot_maxed:
		multiplier_caption.text = "Max level"
		upgrade_multiplier_button.label_text = "Maxed"
		upgrade_multiplier_button.disabled = true
	elif loot_ready:
		multiplier_caption.text = "Donated %d/%d T3 — ready" % [
			GameState.multiplier_donations,
			GameState.MULTIPLIER_COST_T3,
		]
		upgrade_multiplier_button.label_text = "Upgrade"
		upgrade_multiplier_button.disabled = false
	else:
		multiplier_caption.text = "Donated %d/%d T3 — donate in Arena" % [
			GameState.multiplier_donations,
			GameState.MULTIPLIER_COST_T3,
		]
		upgrade_multiplier_button.label_text = "Upgrade"
		upgrade_multiplier_button.disabled = true

func _refresh_garden_card() -> void:
	var bag_count := GameState.sum_seed_bag(GameState.seed_bag)
	var crystal_total := GameState.get_garden_crystal_total()
	_validate_trade_selection()
	if bag_label:
		if bag_count <= 0:
			bag_label.text = "Seeds: 0 / %d — Play to collect" % GameState.SEED_BAG_SOFT_CAP
		else:
			bag_label.text = "Seeds: %d / %d" % [bag_count, GameState.SEED_BAG_SOFT_CAP]
	_rebuild_seed_bag_grid()
	_refresh_exchange_button()
	if garden_cliff:
		garden_cliff.text = _garden_cliff_text(bag_count, crystal_total)

func _refresh_crystal_card() -> void:
	var crystal_total := GameState.get_garden_crystal_total()
	_validate_crystal_selection()
	if crystal_total_label:
		crystal_total_label.text = "Flowers: %d" % crystal_total
	if crystal_cliff:
		if crystal_total <= 0:
			crystal_cliff.text = "Merge T3 in Arena → flowers here"
		else:
			crystal_cliff.text = "Tap a flower type, then Exchange for coins."
	_rebuild_crystal_grid()
	_refresh_crystal_exchange_button()

func _validate_trade_selection() -> void:
	if _selected_trade_type.is_empty():
		return
	if int(GameState.seed_bag.get(_selected_trade_type, 0)) >= 1:
		return
	# Depleted type — fall back to next remaining in ASC order (first entry).
	_selected_trade_type = GameState.first_exchangeable_type_in_bag()


func _next_trade_type_after(entries_before: Array, depleted_type: String) -> String:
	var idx := -1
	for i in entries_before.size():
		if str(entries_before[i].get("type_id", "")) == depleted_type:
			idx = i
			break
	for i in range(idx + 1, entries_before.size()):
		var tid := str(entries_before[i].get("type_id", ""))
		if int(GameState.seed_bag.get(tid, 0)) >= 1:
			return tid
	for i in range(0, maxi(idx, 0)):
		var tid := str(entries_before[i].get("type_id", ""))
		if int(GameState.seed_bag.get(tid, 0)) >= 1:
			return tid
	return ""

func _refresh_exchange_button() -> void:
	if exchange_button == null:
		return
	var has_select := not _selected_trade_type.is_empty()
	exchange_button.disabled = not has_select
	if has_select:
		var bag_count := int(GameState.seed_bag.get(_selected_trade_type, 0))
		var take := GameState.seed_exchange_take_count(bag_count)
		var coins := GameState.seed_exchange_coins_for_take(take, _selected_trade_type)
		var seed_name: String = GameState.SEED_DISPLAY_NAMES.get(
			_selected_trade_type, _selected_trade_type.capitalize()
		)
		exchange_button.label_text = "Trade %d× %s → %d coins" % [take, seed_name, coins]
	else:
		exchange_button.label_text = "Select a seed to trade"

func _rebuild_seed_bag_grid() -> void:
	if seed_bag_grid == null:
		return
	for child in seed_bag_grid.get_children():
		seed_bag_grid.remove_child(child)
		child.queue_free()
	var entries := GameState.get_seed_bag_entries()
	seed_bag_grid.visible = not entries.is_empty()
	if _force_default_trade_select:
		_force_default_trade_select = false
		if entries.is_empty():
			_selected_trade_type = ""
		else:
			_selected_trade_type = str(entries[0].get("type_id", ""))
	else:
		_validate_trade_selection()
	for entry in entries:
		var type_id := str(entry.get("type_id", ""))
		var count := int(entry.get("count", 0))
		var chip: PanelContainer = SeedBagChipScript.new()
		seed_bag_grid.add_child(chip)
		chip.call(
			"apply",
			type_id,
			count,
			str(entry.get("display_name", "")),
			int(entry.get("rarity", 1))
		)
		if chip.has_signal("chip_pressed"):
			chip.connect("chip_pressed", _on_seed_chip_pressed)
		if chip.has_method("set_selected"):
			chip.call("set_selected", type_id == _selected_trade_type)


func _on_seed_chip_pressed(type_id: String) -> void:
	var count := int(GameState.seed_bag.get(type_id, 0))
	if count < 1:
		return
	_selected_trade_type = type_id
	_refresh_seed_chip_selection()
	_refresh_exchange_button()


func _refresh_seed_chip_selection() -> void:
	if seed_bag_grid == null:
		return
	for child in seed_bag_grid.get_children():
		if child.has_method("get_type_id"):
			var tid := str(child.call("get_type_id"))
			if child.has_method("set_selected"):
				child.call("set_selected", tid == _selected_trade_type)

func _validate_crystal_selection() -> void:
	if _selected_crystal_type.is_empty():
		return
	if int(GameState.garden_crystal_stash.get(_selected_crystal_type, 0)) < 1:
		_selected_crystal_type = ""

func _refresh_crystal_exchange_button() -> void:
	if crystal_exchange_button == null:
		return
	var has_select := not _selected_crystal_type.is_empty()
	crystal_exchange_button.disabled = not has_select
	if has_select:
		var crystal_name: String = GameState.SEED_DISPLAY_NAMES.get(
			_selected_crystal_type, _selected_crystal_type.capitalize()
		)
		var coins := GameState.crystal_exchange_coins_for_type(_selected_crystal_type)
		crystal_exchange_button.label_text = "Exchange %s → %d coins" % [
			crystal_name,
			coins,
		]
	else:
		crystal_exchange_button.label_text = "Select a flower to exchange"

func _rebuild_crystal_grid() -> void:
	if crystal_grid == null:
		return
	for child in crystal_grid.get_children():
		crystal_grid.remove_child(child)
		child.queue_free()
	var entries := GameState.get_garden_crystal_entries()
	crystal_grid.visible = not entries.is_empty()
	for entry in entries:
		var type_id := str(entry.get("type_id", ""))
		var count := int(entry.get("count", 0))
		var chip: PanelContainer = CrystalStashChipScript.new()
		crystal_grid.add_child(chip)
		chip.call(
			"apply",
			type_id,
			count,
			str(entry.get("display_name", "")),
			int(entry.get("rarity", 1))
		)
		if chip.has_signal("chip_pressed"):
			chip.connect("chip_pressed", _on_crystal_chip_pressed)
		if chip.has_method("set_selected"):
			chip.call("set_selected", type_id == _selected_crystal_type)

func _on_crystal_chip_pressed(type_id: String) -> void:
	if int(GameState.garden_crystal_stash.get(type_id, 0)) < 1:
		return
	_selected_crystal_type = type_id
	_refresh_crystal_chip_selection()
	_refresh_crystal_exchange_button()

func _refresh_crystal_chip_selection() -> void:
	if crystal_grid == null:
		return
	for child in crystal_grid.get_children():
		if child.has_method("get_type_id") and child.has_method("set_selected"):
			child.call("set_selected", str(child.call("get_type_id")) == _selected_crystal_type)

func _garden_cliff_text(bag_count: int, crystal_total: int) -> String:
	if GameState.should_prompt_merge_tutorial():
		return "Tutorial: open Merge and drag same seeds together."
	var need_t2 := GameState.MAGNET_COST_T2 - GameState.sprinkler_donations
	if (
		GameState.magnet_level < GameState.MAGNET_MAX_LEVEL
		and need_t2 > 0
		and need_t2 <= 1
	):
		return "1 more T2 to upgrade Sprinkler."
	if bag_count > 0:
		return "Bag seeds are T1 — pour in Arena or trade 3→coins. T2 blooms resolve in Arena."
	if crystal_total > 0:
		return "%d flowers ready — exchange for coins." % crystal_total
	if GameState.count_collection_journal_news() > 0:
		return "New blooms in Journal — swipe to the Journal tab."
	return "Run → collect seeds → Merge here."


func _refresh_collection_badge() -> void:
	if collection_badge == null:
		return
	collection_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var news := GameState.count_collection_journal_news()
	collection_badge.visible = news > 0 and not _meta_hub_embedded
	collection_badge.text = "!" if news == 1 else str(mini(news, 9))

func _set_status_toast(status: String) -> void:
	if status_toast == null or status_label == null:
		return
	if status.is_empty():
		return
	status_label.text = status
	status_toast.visible = true

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
		_set_status_toast(unlock_msg)

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
	if _selected_trade_type.is_empty():
		_refresh_ui("Tap a seed to select, then Trade.")
		return
	var type_id := _selected_trade_type
	var bag_count := int(GameState.seed_bag.get(type_id, 0))
	var take := GameState.seed_exchange_take_count(bag_count)
	if take <= 0:
		_selected_trade_type = GameState.first_exchangeable_type_in_bag()
		_refresh_ui("No seeds left to trade.")
		return
	var coins := GameState.seed_exchange_coins_for_take(take, type_id)
	var entries_before: Array = GameState.get_seed_bag_entries()
	if GameState.exchange_seeds_from_bag(type_id):
		var seed_name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
		if int(GameState.seed_bag.get(type_id, 0)) < 1:
			_selected_trade_type = _next_trade_type_after(entries_before, type_id)
		# else keep same type for spam Trade
		_refresh_ui("Traded %d× %s for %d coins." % [take, seed_name, coins])

func _on_crystal_exchange_pressed() -> void:
	if _selected_crystal_type.is_empty():
		_refresh_ui("Tap a flower to select, then Exchange.")
		return
	var crystal_type := _selected_crystal_type
	if int(GameState.garden_crystal_stash.get(crystal_type, 0)) < 1:
		_selected_crystal_type = ""
		_refresh_ui("No flowers of that type left.")
		return
	if GameState.exchange_garden_crystal(crystal_type):
		var crystal_name: String = GameState.SEED_DISPLAY_NAMES.get(
			crystal_type, crystal_type.capitalize()
		)
		var coins := GameState.crystal_exchange_coins_for_type(crystal_type)
		# Keep select while count >= 1; _validate_crystal_selection clears when gone.
		_refresh_ui("Traded %s flower for %d coins." % [crystal_name, coins])


func _on_collection_pressed() -> void:
	GameState.go_to_collection_journal()

func _on_main_menu_pressed() -> void:
	GameState.go_to_meta_home()

func _on_settings_pressed() -> void:
	_refresh_ui("Settings coming soon — full screen in a future update.")

func _on_play_pressed() -> void:
	GameState.notify_camp_play()
	GameState.begin_campaign_run()
	SceneRouter.change_to(GameState.SCENE_RUN)
