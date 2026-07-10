extends Control

const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")

@onready var gh_beds_grid: HBoxContainer = $Greenhouse/VBox/GhBedsGrid
@onready var gh_hint_label: Label = $Greenhouse/VBox/GhHintLabel
@onready var beds_grid: GridContainer = $GardenLayer/VBox/BedsGrid
@onready var info_label: Label = $GardenLayer/VBox/InfoLabel
@onready var seed_bag_label: Label = $GardenLayer/VBox/SeedBagLabel
@onready var wallet_label: Label = $GardenLayer/VBox/WalletRow/WalletLabel
@onready var wallet_icon: TextureRect = $GardenLayer/VBox/WalletRow/WalletIcon
@onready var collection_label: Label = $GardenLayer/VBox/CollectionLabel
@onready var sprinkler_label: Label = $GardenLayer/VBox/SprinklerLabel
@onready var donate_button: UiClickButton = $GardenLayer/VBox/ActionRow/DonateButton
@onready var upgrade_button: UiClickButton = $GardenLayer/VBox/ActionRow/UpgradeButton
@onready var exchange_button: UiClickButton = $GardenLayer/VBox/ExchangeButton
@onready var loadout_button: UiClickButton = $GardenLayer/VBox/LoadoutButton
@onready var main_menu_button: UiClickButton = $GardenLayer/VBox/MainMenuButton
@onready var play_button: UiClickButton = $GardenLayer/VBox/PlayButton
@onready var settings_button: UiClickButton = $SettingsButton

var _selected_garden: int = -1
var _selected_greenhouse: int = -1
var _garden_buttons: Array[CampBed] = []
var _gh_buttons: Array[CampBed] = []
var _planted_during_camp1: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.ensure_loot_in_camp_bag()
	donate_button.clicked.connect(_on_donate_pressed)
	upgrade_button.clicked.connect(_on_upgrade_pressed)
	exchange_button.clicked.connect(_on_exchange_pressed)
	loadout_button.clicked.connect(_on_loadout_pressed)
	main_menu_button.clicked.connect(_on_main_menu_pressed)
	play_button.clicked.connect(_on_play_pressed)
	_setup_wallet_icon()
	_setup_safe_area()
	_build_garden_beds()
	_build_greenhouse_beds()
	_refresh_ui()


func _setup_wallet_icon() -> void:
	var tex := UI_ASSETS.get_kenney_icon("wallet")
	if wallet_icon and tex:
		wallet_icon.texture = tex


func _setup_safe_area() -> void:
	if settings_button:
		SAFE_AREA.apply_top_margin(settings_button, 8.0)
		SAFE_AREA.apply_horizontal_margins(settings_button)


func _build_garden_beds() -> void:
	for child in beds_grid.get_children():
		child.queue_free()
	_garden_buttons.clear()
	for i in GameState.CAMP_BED_COUNT:
		var bed := CampBed.new()
		bed.setup(i, false)
		bed.bed_tapped.connect(_on_garden_bed_tapped)
		beds_grid.add_child(bed)
		_garden_buttons.append(bed)


func _build_greenhouse_beds() -> void:
	for child in gh_beds_grid.get_children():
		child.queue_free()
	_gh_buttons.clear()
	for i in GameState.GREENHOUSE_SLOT_COUNT:
		var bed := CampBed.new()
		bed.setup(i, true)
		bed.bed_tapped.connect(_on_greenhouse_bed_tapped)
		gh_beds_grid.add_child(bed)
		_gh_buttons.append(bed)


func _clear_selection() -> void:
	_selected_garden = -1
	_selected_greenhouse = -1


func _on_garden_bed_tapped(index: int) -> void:
	_selected_greenhouse = -1
	var status := _handle_bed_tap(index, false)
	_refresh_ui(status)


func _on_greenhouse_bed_tapped(index: int) -> void:
	_selected_garden = -1
	var status := _handle_bed_tap(index, true)
	_refresh_ui(status)


func _handle_bed_tap(index: int, in_greenhouse: bool) -> String:
	var selected := _selected_greenhouse if in_greenhouse else _selected_garden

	if GameState.bed_is_empty(index, in_greenhouse):
		if not in_greenhouse:
			_selected_garden = -1
		else:
			_selected_greenhouse = -1
		var type_id := GameState.first_seed_type_in_bag(in_greenhouse)
		if type_id.is_empty():
			if in_greenhouse:
				return "Greenhouse takes ★★★ seeds only — none in your bag yet."
			return "No garden seeds in bag — run again!"
		if GameState.plant_seed_in_bed(index, type_id, in_greenhouse):
			var name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
			if GameState.should_highlight_first_bed() and index == 0:
				_planted_during_camp1 = true
			return "Planted %s!" % name
		return "Could not plant here."

	if selected < 0:
		if in_greenhouse:
			_selected_greenhouse = index
		else:
			_selected_garden = index
		var tier := GameState.get_bed_tier(index, in_greenhouse)
		var type_name: String = GameState.SEED_DISPLAY_NAMES.get(
			GameState.get_bed_type(index, in_greenhouse),
			GameState.get_bed_type(index, in_greenhouse).capitalize()
		)
		if tier >= 2:
			return (
				"Selected %s bloom. Keep for collection, or Donate to Sprinkler."
				% type_name
			)
		return "Selected %s T%d — tap a match to merge." % [type_name, tier]

	if selected == index:
		_clear_selection()
		return "Deselected."

	if GameState.try_merge_beds(selected, index, in_greenhouse):
		_clear_selection()
		return "Merged into a bigger bloom! Nice! The meadow feels brighter."
	_clear_selection()
	return "No match — same type and tier only."


func _refresh_ui(status: String = "") -> void:
	for i in _garden_buttons.size():
		var bed := _garden_buttons[i]
		bed.set_bed_state(
			GameState.get_bed_type(i, false),
			GameState.get_bed_tier(i, false),
			i == _selected_garden,
			false
		)
		bed.set_highlighted(GameState.should_highlight_first_bed() and i == 0)
	for i in _gh_buttons.size():
		var bed := _gh_buttons[i]
		bed.set_bed_state(
			GameState.get_bed_type(i, true),
			GameState.get_bed_tier(i, true),
			i == _selected_greenhouse,
			true
		)

	seed_bag_label.text = GameState.format_seed_bag_label()
	wallet_label.text = "Wallet: %d coins" % GameState.wallet_coins
	collection_label.text = GameState.format_collection_label()

	var t2_kept := GameState.count_all_flowers_tier(2)
	sprinkler_label.text = (
		"Sprinkler Lv %d / %d  (reach %dpx)  |  donated %d/%d  |  T2 kept: %d"
		% [
			GameState.magnet_level,
			GameState.MAGNET_MAX_LEVEL,
			int(GameState.get_magnet_radius()),
			GameState.sprinkler_donations,
			GameState.MAGNET_COST_T2,
			t2_kept,
		]
	)

	var can_donate := _selected_t2_bed().size() > 0 and GameState.sprinkler_donations < GameState.MAGNET_COST_T2
	donate_button.disabled = not can_donate or GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL
	donate_button.label_text = "Donate bloom to Sprinkler (%d/%d)" % [
		GameState.sprinkler_donations, GameState.MAGNET_COST_T2
	]

	if GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL:
		upgrade_button.label_text = "Sprinkler maxed"
		upgrade_button.disabled = true
	else:
		upgrade_button.label_text = "Upgrade Sprinkler"
		upgrade_button.disabled = GameState.sprinkler_donations < GameState.MAGNET_COST_T2

	var exch_type := GameState.first_exchangeable_type_in_bag()
	exchange_button.disabled = exch_type.is_empty()
	if exch_type.is_empty():
		exchange_button.label_text = "Trade extras (need 3× same seed)"
	else:
		var name: String = GameState.SEED_DISPLAY_NAMES.get(exch_type, exch_type.capitalize())
		exchange_button.label_text = "Trade 3× %s → %d coins" % [name, GameState.EXCHANGE_COINS_REWARD]

	loadout_button.disabled = not GameState.loadout_enabled()
	if GameState.loadout_enabled():
		loadout_button.label_text = GameState.format_loadout_label()
	else:
		loadout_button.label_text = "Fill your basket later"

	gh_hint_label.text = "★★★ seeds only (2 slots)"

	if status != "":
		info_label.text = status
	elif GameState.tutorial_complete and GameState.get_loadout_type().is_empty():
		info_label.text = (
			"Clover will show up more in your next run! Fill your basket before Play."
		)
	elif GameState.should_highlight_first_bed():
		if _planted_during_camp1:
			info_label.text = "Collect more of the same seed to merge into a flower."
		else:
			info_label.text = "Plant your seed here! Tap the glowing bed."
	elif GameState.tutorial_step == GameState.TutorialStep.CAMP_MERGE:
		info_label.text = "Tap two matching sprouts to merge into a flower."
	elif GameState.sum_seed_bag(GameState.seed_bag) > 0 and GameState.empty_garden_beds() > 0:
		info_label.text = "Plant your seed here! Tap an empty bed."
	elif GameState.count_flowers_tier(1) >= 2:
		info_label.text = "Two sprouts ready — merge them, then keep or donate the bloom."
	else:
		info_label.text = (
			"Merge T1+T1 → T2 bloom. Keep blooms for your collection, "
			+ "or donate to upgrade the sprinkler."
		)


func _selected_t2_bed() -> Dictionary:
	if _selected_garden >= 0 and GameState.get_bed_tier(_selected_garden, false) == 2:
		return {"index": _selected_garden, "greenhouse": false}
	if _selected_greenhouse >= 0 and GameState.get_bed_tier(_selected_greenhouse, true) == 2:
		return {"index": _selected_greenhouse, "greenhouse": true}
	return {}


func _on_donate_pressed() -> void:
	var sel := _selected_t2_bed()
	if sel.is_empty():
		return
	if GameState.donate_bloom_from_bed(sel.index, sel.greenhouse):
		_clear_selection()
		info_label.text = "Bloom donated! Donate one more to unlock upgrade."
	_refresh_ui()


func _on_upgrade_pressed() -> void:
	if GameState.try_upgrade_magnet():
		info_label.text = "Sprinkler upgraded — Pip reaches farther next run!"
	_refresh_ui()


func _on_exchange_pressed() -> void:
	var type_id := GameState.first_exchangeable_type_in_bag()
	if type_id.is_empty():
		return
	if GameState.exchange_seeds_from_bag(type_id):
		var name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
		info_label.text = "Traded 3× %s for %d coins." % [name, GameState.EXCHANGE_COINS_REWARD]
	_refresh_ui()


func _on_loadout_pressed() -> void:
	if not GameState.loadout_enabled():
		info_label.text = "Fill your basket later — merge your first flower!"
		return
	var status := GameState.toggle_loadout_from_bag()
	info_label.text = status
	_refresh_ui()


func _on_main_menu_pressed() -> void:
	SceneRouter.change_to(GameState.SCENE_MAIN)


func _on_play_pressed() -> void:
	GameState.notify_camp_play()
	GameState.begin_campaign_run()
	SceneRouter.change_to(GameState.SCENE_RUN)