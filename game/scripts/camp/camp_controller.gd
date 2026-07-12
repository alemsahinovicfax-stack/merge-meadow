extends Control

const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")

@onready var gh_beds_grid: HBoxContainer = $RootVBox/MainScroll/Content/GreenhouseRow/VBox/GhBedsGrid
@onready var gh_hint_label: Label = $RootVBox/MainScroll/Content/GreenhouseRow/VBox/GhHintLabel
@onready var beds_grid: GridContainer = $RootVBox/MainScroll/Content/BedsGrid
@onready var main_scroll: ScrollContainer = $RootVBox/MainScroll
@onready var scroll_content: VBoxContainer = $RootVBox/MainScroll/Content
@onready var info_label: Label = $RootVBox/MainScroll/Content/InfoLabel
@onready var plant_hint_label: Label = $RootVBox/MainScroll/Content/PlantHintLabel
@onready var bag_chips: HBoxContainer = $RootVBox/MainScroll/Content/BagChips
@onready var coins_label: Label = $RootVBox/TopStrip/VBox/ResourceBar/CoinsRow/CoinsLabel
@onready var seeds_label: Label = $RootVBox/TopStrip/VBox/ResourceBar/SeedsRow/SeedsLabel
@onready var wallet_icon: TextureRect = $RootVBox/TopStrip/VBox/ResourceBar/CoinsRow/WalletIcon
@onready var daily_chest_button: UiClickButton = $RootVBox/TopStrip/VBox/ResourceBar/DailyChestButton
@onready var context_panel: PanelContainer = $RootVBox/ContextPanel
@onready var context_label: Label = $RootVBox/ContextPanel/VBox/ContextLabel
@onready var context_actions: HBoxContainer = $RootVBox/ContextPanel/VBox/ContextActions
@onready var keep_button: UiClickButton = $RootVBox/ContextPanel/VBox/ContextActions/KeepButton
@onready var donate_button: UiClickButton = $RootVBox/ContextPanel/VBox/ContextActions/DonateButton
@onready var sprinkler_label: Label = $RootVBox/MainScroll/Content/UpgradeCards/SprinklerCard/HBox/SprinklerLabel
@onready var upgrade_button: UiClickButton = $RootVBox/MainScroll/Content/UpgradeCards/SprinklerCard/HBox/UpgradeButton
@onready var multiplier_label: Label = $RootVBox/MainScroll/Content/UpgradeCards/LootCard/HBox/MultiplierLabel
@onready var upgrade_multiplier_button: UiClickButton = (
	$RootVBox/MainScroll/Content/UpgradeCards/LootCard/HBox/UpgradeMultiplierButton
)
@onready var loadout_button: UiClickButton = $RootVBox/MainScroll/Content/SecondaryRow/LoadoutButton
@onready var clear_blooms_button: UiClickButton = $RootVBox/MainScroll/Content/SecondaryRow/ClearBloomsButton
@onready var exchange_button: UiClickButton = $RootVBox/MainScroll/Content/SecondaryRow/ExchangeButton
@onready var home_button: UiClickButton = $RootVBox/TopStrip/VBox/TopBar/HomeButton
@onready var play_button: UiClickButton = $FooterBar/PlayButton
@onready var settings_button: UiClickButton = $RootVBox/TopStrip/VBox/TopBar/SettingsButton
@onready var companion_hint: Label = $RootVBox/MainScroll/Content/CompanionCard/VBox/CompanionHint
@onready var pip_companion_slot: Control = $RootVBox/MainScroll/Content/CompanionCard/VBox/CompanionRow/PipSlot
@onready var mochi_companion_slot: Control = $RootVBox/MainScroll/Content/CompanionCard/VBox/CompanionRow/MochiSlot

var _selected_garden: int = -1
var _selected_greenhouse: int = -1
var _garden_buttons: Array[CampBed] = []
var _gh_buttons: Array[CampBed] = []
var _planted_during_camp1: bool = false
var _selected_plant_type: String = ""
var _bag_chip_nodes: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.ensure_loot_in_camp_bag()
	keep_button.clicked.connect(_on_keep_pressed)
	donate_button.clicked.connect(_on_donate_pressed)
	upgrade_button.clicked.connect(_on_upgrade_pressed)
	upgrade_multiplier_button.clicked.connect(_on_upgrade_multiplier_pressed)
	exchange_button.clicked.connect(_on_exchange_pressed)
	daily_chest_button.clicked.connect(_on_daily_chest_pressed)
	loadout_button.clicked.connect(_on_loadout_pressed)
	clear_blooms_button.clicked.connect(_on_clear_blooms_pressed)
	home_button.clicked.connect(_on_main_menu_pressed)
	play_button.clicked.connect(_on_play_pressed)
	if main_scroll:
		main_scroll.resized.connect(_sync_scroll_width)
	_setup_wallet_icon()
	_setup_safe_area()
	_build_garden_beds()
	_build_greenhouse_beds()
	_ensure_default_plant_selection()
	_refresh_ui()


func _ensure_default_plant_selection() -> void:
	if not _selected_plant_type.is_empty():
		if int(GameState.seed_bag.get(_selected_plant_type, 0)) > 0:
			return
	var loadout := GameState.get_loadout_type()
	if not loadout.is_empty() and int(GameState.seed_bag.get(loadout, 0)) > 0:
		_selected_plant_type = loadout
		return
	var sorted := GameState.get_sorted_bag_types(false)
	if not sorted.is_empty():
		_selected_plant_type = sorted[0]
	else:
		_selected_plant_type = ""


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


func _build_garden_beds() -> void:
	for child in beds_grid.get_children():
		child.queue_free()
	_garden_buttons.clear()
	for i in GameState.get_garden_bed_capacity():
		var bed := CampBed.new()
		bed.setup(i, false)
		bed.bed_tapped.connect(_on_garden_bed_tapped)
		beds_grid.add_child(bed)
		_garden_buttons.append(bed)


func _sync_garden_bed_buttons() -> void:
	if _garden_buttons.size() == GameState.get_garden_bed_capacity():
		return
	_build_garden_beds()
	_clear_selection()


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


func _selected_bed_index() -> Dictionary:
	if _selected_garden >= 0:
		return {"index": _selected_garden, "greenhouse": false}
	if _selected_greenhouse >= 0:
		return {"index": _selected_greenhouse, "greenhouse": true}
	return {}


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
		var type_id := GameState.resolve_plant_type(in_greenhouse, _selected_plant_type)
		if type_id.is_empty():
			if in_greenhouse:
				return "Greenhouse takes ★★★ seeds only — none in your bag yet."
			return "No garden seeds in bag — run again!"
		if GameState.plant_seed_in_bed(index, type_id, in_greenhouse):
			var name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
			if GameState.should_highlight_first_bed() and index == 0:
				_planted_during_camp1 = true
			return "Planted %s (from bag)" % name
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
		if tier >= GameState.MAX_MERGE_TIER:
			return "Selected %s crystal — keep or donate to Loot Boost." % type_name
		if tier >= 2:
			return "Selected %s bloom — keep or donate to Sprinkler." % type_name
		return "Selected %s — tap a match to merge." % type_name

	if selected == index:
		_clear_selection()
		return "Deselected."

	if GameState.try_merge_beds(selected, index, in_greenhouse):
		_clear_selection()
		var merged_tier := GameState.get_bed_tier(index, in_greenhouse)
		if merged_tier >= GameState.MAX_MERGE_TIER:
			return "Merged into a crystal bloom!"
		return "Merged into a bigger bloom!"
	_clear_selection()
	return "No match — same type and tier only."


func _refresh_ui(status: String = "") -> void:
	_sync_garden_bed_buttons()
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

	if coins_label:
		coins_label.text = "%d" % GameState.wallet_coins
	if seeds_label:
		seeds_label.text = "%d / %d" % [
			GameState.sum_seed_bag(GameState.seed_bag),
			GameState.SEED_BAG_SOFT_CAP,
		]
	_rebuild_bag_chips()
	_refresh_plant_hint()

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

	if GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL:
		upgrade_button.label_text = "Maxed"
		upgrade_button.disabled = true
	else:
		upgrade_button.label_text = "Upgrade"
		upgrade_button.disabled = GameState.sprinkler_donations < GameState.MAGNET_COST_T2

	if GameState.multiplier_level >= GameState.MULTIPLIER_MAX_LEVEL:
		upgrade_multiplier_button.label_text = "Maxed"
		upgrade_multiplier_button.disabled = true
	else:
		upgrade_multiplier_button.label_text = "Upgrade"
		upgrade_multiplier_button.disabled = (
			GameState.multiplier_donations < GameState.MULTIPLIER_COST_T3
		)

	var exch_type := GameState.first_exchangeable_type_in_bag()
	exchange_button.disabled = exch_type.is_empty()
	if exch_type.is_empty():
		exchange_button.label_text = "Trade extras"
	else:
		var name: String = GameState.SEED_DISPLAY_NAMES.get(exch_type, exch_type.capitalize())
		exchange_button.label_text = "Trade 3× %s" % name

	if GameState.can_claim_daily_chest():
		daily_chest_button.visible = true
		daily_chest_button.disabled = false
		daily_chest_button.label_text = "Daily chest"
	elif not GameState.tutorial_complete:
		daily_chest_button.visible = false
	else:
		daily_chest_button.visible = false

	loadout_button.disabled = not GameState.loadout_enabled()
	if GameState.loadout_enabled():
		loadout_button.label_text = GameState.format_loadout_label()
	else:
		loadout_button.label_text = "Basket (locked)"

	var bloom_count := GameState.count_blooms_on_beds(2)
	clear_blooms_button.visible = bloom_count >= 2
	clear_blooms_button.disabled = bloom_count <= 0
	clear_blooms_button.label_text = "Album: keep all (%d)" % bloom_count

	_refresh_companion_ui()

	gh_hint_label.text = "★★★ seeds only"

	_refresh_context_panel()
	call_deferred("_sync_scroll_width")

	if status != "":
		info_label.text = status
	elif GameState.tutorial_complete and GameState.get_loadout_type().is_empty():
		info_label.text = "Equip your basket before the next run."
	elif GameState.should_highlight_first_bed():
		if _planted_during_camp1:
			info_label.text = "Collect more of the same seed to merge."
		else:
			info_label.text = "Plant your seed — tap the glowing bed."
	elif GameState.tutorial_step == GameState.TutorialStep.CAMP_MERGE:
		info_label.text = "Tap two matching sprouts to merge."
	elif GameState.sum_seed_bag(GameState.seed_bag) > 0 and GameState.empty_garden_beds() > 0:
		info_label.text = "Tap an empty bed to plant from your bag."
	elif GameState.count_flowers_tier(1) >= 2:
		info_label.text = "Two sprouts ready — merge them!"
	else:
		info_label.text = (
			"Pick a seed chip, plant on empty beds, merge matching sprouts."
		)


func _refresh_plant_hint() -> void:
	if plant_hint_label == null:
		return
	if GameState.should_highlight_first_bed():
		plant_hint_label.text = "Tutorial: tap the glowing bed to plant Clover."
		return
	if _selected_plant_type.is_empty():
		plant_hint_label.text = "Tap a seed chip below, then tap an empty bed."
		return
	var name: String = GameState.SEED_DISPLAY_NAMES.get(
		_selected_plant_type, _selected_plant_type.capitalize()
	)
	var count := int(GameState.seed_bag.get(_selected_plant_type, 0))
	plant_hint_label.text = "Planting: %s × %d — tap empty bed" % [name, count]


func _rebuild_bag_chips() -> void:
	if bag_chips == null:
		return
	for child in bag_chips.get_children():
		child.queue_free()
	_bag_chip_nodes.clear()
	var types := GameState.get_sorted_bag_types(false)
	if types.is_empty():
		var empty := Label.new()
		empty.text = "Bag empty — play a run"
		empty.add_theme_font_size_override("font_size", 16)
		empty.add_theme_color_override("font_color", Color(0.75, 0.85, 0.75))
		bag_chips.add_child(empty)
		return
	for type_id in types:
		var count := int(GameState.seed_bag.get(type_id, 0))
		var name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
		var chip := UiClickButton.new()
		chip.custom_minimum_size = Vector2(0, 44)
		chip.font_size = 16
		chip.label_text = "%s ×%d" % [name, count]
		chip.button_variant = "primary" if type_id == _selected_plant_type else "secondary"
		chip.clicked.connect(_on_bag_chip_pressed.bind(type_id))
		bag_chips.add_child(chip)
		_bag_chip_nodes[type_id] = chip
	for type_id in GameState.get_sorted_bag_types(true):
		var gh_count := int(GameState.seed_bag.get(type_id, 0))
		if gh_count <= 0:
			continue
		var gh_name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
		var gh_chip := UiClickButton.new()
		gh_chip.custom_minimum_size = Vector2(0, 44)
		gh_chip.font_size = 15
		gh_chip.label_text = "%s ★★★ ×%d" % [gh_name, gh_count]
		gh_chip.button_variant = "accent" if type_id == _selected_plant_type else "subtle"
		gh_chip.clicked.connect(_on_greenhouse_chip_pressed.bind(type_id))
		bag_chips.add_child(gh_chip)


func _on_bag_chip_pressed(type_id: String) -> void:
	_selected_plant_type = type_id
	info_label.text = "Selected %s for planting." % GameState.SEED_DISPLAY_NAMES.get(
		type_id, type_id.capitalize()
	)
	_refresh_ui()


func _on_greenhouse_chip_pressed(type_id: String) -> void:
	_selected_plant_type = type_id
	info_label.text = "Selected %s for greenhouse beds." % GameState.SEED_DISPLAY_NAMES.get(
		type_id, type_id.capitalize()
	)
	_refresh_ui()


func _refresh_context_panel() -> void:
	var sel := _selected_bed_index()
	if sel.is_empty():
		context_panel.visible = false
		return

	var tier := GameState.get_bed_tier(sel.index, sel.greenhouse)
	var type_name: String = GameState.SEED_DISPLAY_NAMES.get(
		GameState.get_bed_type(sel.index, sel.greenhouse),
		GameState.get_bed_type(sel.index, sel.greenhouse).capitalize()
	)

	if tier <= 0:
		context_panel.visible = false
		return

	context_panel.visible = true
	if tier == 1:
		context_label.text = "%s sprout — tap a match to merge" % type_name
		context_actions.visible = false
		return

	context_actions.visible = true
	context_label.text = "%s T%d selected" % [type_name, tier]

	var keep_sel := _selected_keepable_bed()
	keep_button.disabled = keep_sel.is_empty()
	keep_button.label_text = "Keep → Album"

	var t3 := _selected_t3_bed()
	if not t3.is_empty():
		donate_button.label_text = "Donate crystal"
		var can := GameState.multiplier_donations < GameState.MULTIPLIER_COST_T3
		can = can and GameState.multiplier_level < GameState.MULTIPLIER_MAX_LEVEL
		donate_button.disabled = not can
		if GameState.multiplier_level >= GameState.MULTIPLIER_MAX_LEVEL:
			donate_button.label_text = "Boost maxed — use Keep"
		return

	var t2 := _selected_t2_bed()
	if not t2.is_empty():
		donate_button.label_text = "Donate bloom"
		var can_t2 := GameState.sprinkler_donations < GameState.MAGNET_COST_T2
		can_t2 = can_t2 and GameState.magnet_level < GameState.MAGNET_MAX_LEVEL
		donate_button.disabled = not can_t2
		if GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL:
			donate_button.label_text = "Sprinkler maxed — use Keep"
		return

	donate_button.disabled = true
	donate_button.label_text = "Donate"


func _selected_keepable_bed() -> Dictionary:
	if _selected_garden >= 0 and GameState.get_bed_tier(_selected_garden, false) >= 2:
		return {"index": _selected_garden, "greenhouse": false}
	if _selected_greenhouse >= 0 and GameState.get_bed_tier(_selected_greenhouse, true) >= 2:
		return {"index": _selected_greenhouse, "greenhouse": true}
	return {}


func _selected_t3_bed() -> Dictionary:
	if _selected_garden >= 0 and GameState.get_bed_tier(_selected_garden, false) == GameState.MAX_MERGE_TIER:
		return {"index": _selected_garden, "greenhouse": false}
	if _selected_greenhouse >= 0 and GameState.get_bed_tier(_selected_greenhouse, true) == GameState.MAX_MERGE_TIER:
		return {"index": _selected_greenhouse, "greenhouse": true}
	return {}


func _selected_t2_bed() -> Dictionary:
	if _selected_garden >= 0 and GameState.get_bed_tier(_selected_garden, false) == 2:
		return {"index": _selected_garden, "greenhouse": false}
	if _selected_greenhouse >= 0 and GameState.get_bed_tier(_selected_greenhouse, true) == 2:
		return {"index": _selected_greenhouse, "greenhouse": true}
	return {}


func _on_keep_pressed() -> void:
	var sel := _selected_keepable_bed()
	if sel.is_empty():
		return
	var type_name: String = GameState.SEED_DISPLAY_NAMES.get(
		GameState.get_bed_type(sel.index, sel.greenhouse),
		GameState.get_bed_type(sel.index, sel.greenhouse).capitalize()
	)
	var tier := GameState.get_bed_tier(sel.index, sel.greenhouse)
	if GameState.keep_bloom_from_bed(sel.index, sel.greenhouse):
		_clear_selection()
		info_label.text = (
			"%s T%d saved to Album — gredica slobodna! (Keep = kolekcija, ne zauzima slot)"
			% [type_name, tier]
		)
		GameState.auto_plant_from_bag()
	_refresh_ui()


func _on_donate_pressed() -> void:
	var t3 := _selected_t3_bed()
	if not t3.is_empty():
		if GameState.donate_crystal_from_bed(t3.index, t3.greenhouse):
			_clear_selection()
			info_label.text = "Crystal donated!"
		_refresh_ui()
		return
	var t2 := _selected_t2_bed()
	if t2.is_empty():
		return
	if GameState.donate_bloom_from_bed(t2.index, t2.greenhouse):
		_clear_selection()
		info_label.text = "Bloom donated!"
	_refresh_ui()


func _on_upgrade_pressed() -> void:
	var had_bonus := GameState.bonus_garden_beds_unlocked()
	if GameState.try_upgrade_magnet():
		if not had_bonus and GameState.bonus_garden_beds_unlocked():
			info_label.text = "Sprinkler maxed — +3 garden beds!"
		else:
			info_label.text = "Sprinkler upgraded!"
	_refresh_ui()


func _on_upgrade_multiplier_pressed() -> void:
	if GameState.try_upgrade_multiplier():
		info_label.text = "Loot Boost upgraded — ×%.2g next run!" % GameState.get_loot_multiplier()
	_refresh_ui()


func _on_exchange_pressed() -> void:
	var type_id := GameState.first_exchangeable_type_in_bag()
	if type_id.is_empty():
		return
	if GameState.exchange_seeds_from_bag(type_id):
		var name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
		info_label.text = "Traded 3× %s for %d coins." % [name, GameState.EXCHANGE_COINS_REWARD]
	_refresh_ui()


func _on_daily_chest_pressed() -> void:
	info_label.text = GameState.claim_daily_chest()
	_refresh_ui()


func _on_loadout_pressed() -> void:
	if not GameState.loadout_enabled():
		info_label.text = "Merge your first flower to unlock the basket."
		return
	info_label.text = GameState.cycle_loadout_from_bag()
	if not GameState.get_loadout_type().is_empty():
		_selected_plant_type = GameState.get_loadout_type()
	_refresh_ui()


func _on_clear_blooms_pressed() -> void:
	var kept := GameState.keep_all_blooms_on_beds()
	if kept <= 0:
		info_label.text = "No T2/T3 blooms on beds."
	else:
		info_label.text = "Kept %d blooms in Album — beds cleared for merging!" % kept
	_clear_selection()
	_refresh_ui()


func _refresh_companion_ui() -> void:
	var active := GameState.get_active_companion_id()
	if pip_companion_slot and pip_companion_slot.has_method("set_selected"):
		pip_companion_slot.set_selected(active == GameState.COMPANION_PIP)
	if mochi_companion_slot and mochi_companion_slot.has_method("set_selected"):
		mochi_companion_slot.set_selected(active == GameState.COMPANION_MOCHI)
	if pip_companion_slot:
		pip_companion_slot.queue_redraw()
	if mochi_companion_slot:
		mochi_companion_slot.queue_redraw()
	if companion_hint:
		companion_hint.text = GameState.format_mochi_unlock_hint()
	var unlock_msg := GameState.poll_mochi_unlock_toast()
	if not unlock_msg.is_empty():
		info_label.text = unlock_msg


func _on_companion_slot_pressed(companion_id: String) -> void:
	info_label.text = GameState.try_set_active_companion(companion_id)
	_refresh_ui()


func _on_main_menu_pressed() -> void:
	SceneRouter.change_to(GameState.SCENE_MAIN)


func _on_play_pressed() -> void:
	GameState.notify_camp_play()
	GameState.begin_campaign_run()
	SceneRouter.change_to(GameState.SCENE_RUN)
