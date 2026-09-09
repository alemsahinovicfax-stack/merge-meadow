extends Control

const PICKUP_ASSETS := preload("res://scripts/visual/pickup_assets.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const SeedBagChipScript := preload("res://scripts/camp/seed_bag_chip.gd")
const CrystalStashChipScript := preload("res://scripts/camp/crystal_stash_chip.gd")
const DRAG_SCROLL := preload("res://scripts/ui/drag_scroll.gd")

const TRADE_HOLD_RATE := 10.0
## Save ide na otpuštanje, plus periodično da dug hold ne izgubi puno.
const TRADE_SAVE_EVERY := 30

@onready var root_vbox: VBoxContainer = %RootVBox
@onready var header_panel: PanelContainer = %HeaderPanel
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
@onready var garden_title: Label = %GardenTitle
@onready var garden_cliff: Label = %GardenCliff
@onready var bag_label: Label = %BagLabel
@onready var seed_bag_scroll: ScrollContainer = %SeedBagScroll
@onready var seed_bag_grid: GridContainer = %SeedBagGrid
@onready var crystal_title: Label = %CrystalTitle
@onready var crystal_cliff: Label = %CrystalCliff
@onready var crystal_total_label: Label = %CrystalTotalLabel
@onready var crystal_scroll: ScrollContainer = %CrystalScroll
@onready var crystal_grid: GridContainer = %CrystalGrid
@onready var crystal_exchange_button: UiClickButton = %CrystalExchangeButton
@onready var exchange_button: UiClickButton = %ExchangeButton
@onready var upgrade_cards: VBoxContainer = %UpgradeCards
@onready var sprinkler_label: Label = %SprinklerLabel
@onready var sprinkler_caption: Label = %SprinklerCaption
@onready var upgrade_button: UiClickButton = %UpgradeButton
@onready var multiplier_label: Label = %MultiplierLabel
@onready var multiplier_caption: Label = %MultiplierCaption
@onready var upgrade_multiplier_button: UiClickButton = %UpgradeMultiplierButton
@onready var footer_bar: MarginContainer = %FooterBar
@onready var merge_button: UiClickButton = %MergeButton
@onready var play_button: UiClickButton = %PlayButton
@onready var season_link_card: PanelContainer = %SeasonLinkCard

var _meta_hub_embedded: bool = false
var _selected_trade_type: String = ""
var _selected_crystal_type: String = ""
var _force_default_trade_select: bool = false
var _force_default_crystal_select: bool = false
var _pending_trade_save: bool = false
var _trades_since_save: int = 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_meta_hub_embedded = bool(get_meta("meta_hub_embedded", false))
	GameState.ensure_loot_in_camp_bag()
	upgrade_button.clicked.connect(_on_upgrade_pressed)
	upgrade_multiplier_button.clicked.connect(_on_upgrade_multiplier_pressed)
	exchange_button.clicked.connect(_on_exchange_pressed)
	crystal_exchange_button.clicked.connect(_on_crystal_exchange_pressed)
	_setup_trade_buttons()
	_setup_drag_scroll()
	home_button.clicked.connect(_on_main_menu_pressed)
	collection_button.clicked.connect(_on_collection_pressed)
	play_button.clicked.connect(_on_play_pressed)
	merge_button.clicked.connect(_on_merge_pressed)
	if settings_button:
		settings_button.clicked.connect(_on_settings_pressed)
	_setup_resource_icons()
	_setup_typography()
	_setup_safe_area()
	_hide_upgrade_cards()
	_hide_seeds_flowers_chrome()
	_apply_hub_chrome()
	_force_default_trade_select = true
	_force_default_crystal_select = true
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

func _setup_trade_buttons() -> void:
	for button in [exchange_button, crystal_exchange_button]:
		if button == null:
			continue
		button.auto_repeat = true
		button.auto_repeat_rate = TRADE_HOLD_RATE
		button.ghost_when_disabled = true
	exchange_button.press_ended.connect(_on_trade_press_ended)
	crystal_exchange_button.press_ended.connect(_on_trade_press_ended)


func _setup_drag_scroll() -> void:
	if seed_bag_scroll:
		seed_bag_scroll.gui_input.connect(_on_scroll_gui_input.bind(seed_bag_scroll))
	if crystal_scroll:
		crystal_scroll.gui_input.connect(_on_scroll_gui_input.bind(crystal_scroll))


func _on_scroll_gui_input(event: InputEvent, scroll: ScrollContainer) -> void:
	var dy := DRAG_SCROLL.drag_delta(event)
	if is_zero_approx(dy):
		return
	DRAG_SCROLL.apply(scroll, dy)
	scroll.accept_event()


func _exit_tree() -> void:
	_flush_trade_save()


func _flush_trade_save() -> void:
	if not _pending_trade_save:
		return
	_pending_trade_save = false
	_trades_since_save = 0
	GameState.save_player_save()


func _on_trade_press_ended() -> void:
	_flush_trade_save()
	_refresh_ui()


func _mark_trade_save() -> void:
	_pending_trade_save = true
	_trades_since_save += 1
	if _trades_since_save >= TRADE_SAVE_EVERY:
		_flush_trade_save()


func _setup_resource_icons() -> void:
	var coin_tex := PICKUP_ASSETS.get_coin_texture()
	if wallet_icon and coin_tex:
		wallet_icon.texture = coin_tex
	var seed_tex := PICKUP_ASSETS.get_seed_texture()
	if seeds_icon and seed_tex:
		seeds_icon.texture = seed_tex

func _setup_typography() -> void:
	if camp_title:
		camp_title.visible = false
		camp_title.text = ""
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
	if garden_title:
		TEXT_LAYOUT.section_title_scroll(garden_title)
	if crystal_title:
		TEXT_LAYOUT.section_title_scroll(crystal_title)

func _setup_safe_area() -> void:
	if header_panel and not _meta_hub_embedded:
		SAFE_AREA.apply_top_margin(header_panel, 8.0)
		SAFE_AREA.apply_horizontal_margins(header_panel)
	if footer_bar:
		SAFE_AREA.apply_bottom_margin(footer_bar, 4.0 if _meta_hub_embedded else 8.0)

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
	_force_default_crystal_select = true
	_refresh_ui()

func _notify_hub_chrome() -> void:
	if not _meta_hub_embedded or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "refresh_top_bar")

func _hide_upgrade_cards() -> void:
	if upgrade_cards:
		upgrade_cards.visible = false


func _hide_seeds_flowers_chrome() -> void:
	if garden_cliff:
		garden_cliff.visible = false
		garden_cliff.text = ""
	if bag_label:
		bag_label.visible = false
	if crystal_total_label:
		crystal_total_label.visible = false
	if crystal_cliff:
		crystal_cliff.visible = false


func _refresh_ui(status: String = "") -> void:
	_hide_upgrade_cards()
	_hide_seeds_flowers_chrome()
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
	if season_link_card and season_link_card.has_method("refresh"):
		season_link_card.refresh()
	_refresh_collection_badge()
	_set_status_toast(status)
	_notify_hub_chrome()

func _refresh_upgrade_cards() -> void:
	var magnet_maxed := GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL
	var can_spend := GameState.can_spend_flowers_for_upgrade(_selected_crystal_type)
	sprinkler_label.text = "Sprinkler  Lv %d/%d" % [
		GameState.magnet_level,
		GameState.MAGNET_MAX_LEVEL,
	]
	if magnet_maxed:
		sprinkler_caption.text = "Max level · reach %dpx" % int(GameState.get_magnet_radius())
		upgrade_button.label_text = "Maxed"
		upgrade_button.disabled = true
	else:
		var now_px := int(GameState.get_magnet_radius_for_level(GameState.magnet_level))
		var next_px := int(GameState.get_magnet_radius_for_level(GameState.magnet_level + 1))
		var cost_bit := "Spend 2 flowers" if can_spend else "Need 2 flowers"
		sprinkler_caption.text = "Wider seed magnet next run · %d→%d px · %s" % [
			now_px,
			next_px,
			cost_bit,
		]
		upgrade_button.label_text = "Upgrade"
		upgrade_button.disabled = not can_spend

	var loot_maxed := GameState.multiplier_level >= GameState.MULTIPLIER_MAX_LEVEL
	multiplier_label.text = GameState.format_loot_multiplier_label()
	if loot_maxed:
		multiplier_caption.text = "Max level"
		upgrade_multiplier_button.label_text = "Maxed"
		upgrade_multiplier_button.disabled = true
	else:
		var cur_mult := GameState.get_loot_multiplier_for_level(GameState.multiplier_level)
		var next_mult := GameState.get_loot_multiplier_for_level(GameState.multiplier_level + 1)
		var loot_cost := "Spend 2 flowers" if can_spend else "Need 2 flowers"
		multiplier_caption.text = "More loot next run · now ×%s, next ×%s · %s" % [
			_format_loot_times(cur_mult),
			_format_loot_times(next_mult),
			loot_cost,
		]
		upgrade_multiplier_button.label_text = "Upgrade"
		upgrade_multiplier_button.disabled = not can_spend


func _format_loot_times(mult: float) -> String:
	var snapped_v := snappedf(mult, 0.01)
	if is_equal_approx(snapped_v, snappedf(snapped_v, 1.0)):
		return "%d.0" % int(round(snapped_v))
	return str(snapped_v)


func _refresh_garden_card() -> void:
	_validate_trade_selection()
	_rebuild_seed_bag_grid()
	_refresh_exchange_button()

func _refresh_crystal_card() -> void:
	_validate_crystal_selection()
	if crystal_cliff:
		crystal_cliff.visible = false
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
	exchange_button.disabled = _selected_trade_type.is_empty()
	exchange_button.label_text = "Trade"

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
	if int(GameState.garden_crystal_stash.get(_selected_crystal_type, 0)) >= 1:
		return
	var entries := GameState.get_garden_crystal_entries()
	if entries.is_empty():
		_selected_crystal_type = ""
	else:
		_selected_crystal_type = str(entries[0].get("type_id", ""))


func _next_crystal_type_after(entries_before: Array, depleted_type: String) -> String:
	var idx := -1
	for i in entries_before.size():
		if str(entries_before[i].get("type_id", "")) == depleted_type:
			idx = i
			break
	for i in range(idx + 1, entries_before.size()):
		var tid := str(entries_before[i].get("type_id", ""))
		if int(GameState.garden_crystal_stash.get(tid, 0)) >= 1:
			return tid
	for i in range(0, maxi(idx, 0)):
		var tid := str(entries_before[i].get("type_id", ""))
		if int(GameState.garden_crystal_stash.get(tid, 0)) >= 1:
			return tid
	return ""

func _refresh_crystal_exchange_button() -> void:
	if crystal_exchange_button == null:
		return
	crystal_exchange_button.disabled = _selected_crystal_type.is_empty()
	crystal_exchange_button.label_text = "Trade"

func _rebuild_crystal_grid() -> void:
	if crystal_grid == null:
		return
	for child in crystal_grid.get_children():
		crystal_grid.remove_child(child)
		child.queue_free()
	var entries := GameState.get_garden_crystal_entries()
	crystal_grid.visible = not entries.is_empty()
	if _force_default_crystal_select:
		_force_default_crystal_select = false
		if entries.is_empty():
			_selected_crystal_type = ""
		else:
			_selected_crystal_type = str(entries[0].get("type_id", ""))
	else:
		_validate_crystal_selection()
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

func _garden_cliff_text(_bag_count: int, _crystal_total: int) -> String:
	return ""


func _refresh_collection_badge() -> void:
	if collection_badge == null:
		return
	collection_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var news := GameState.count_collection_journal_news()
	collection_badge.visible = news > 0 and not _meta_hub_embedded
	collection_badge.text = "!" if news == 1 else str(mini(news, 9))

func _set_status_toast(_status: String) -> void:
	if status_toast:
		status_toast.visible = false

func _on_merge_pressed() -> void:
	GameState.go_to_merge_arena()

func _on_upgrade_pressed() -> void:
	GameState.try_upgrade_magnet(_selected_crystal_type)
	_refresh_ui()

func _on_upgrade_multiplier_pressed() -> void:
	GameState.try_upgrade_multiplier(_selected_crystal_type)
	_refresh_ui()

## Jedno sjeme; kad se tip isprazni, selekcija prelazi na sljedeći (za hold).
func _trade_step() -> bool:
	if _selected_trade_type.is_empty():
		return false
	var type_id := _selected_trade_type
	if GameState.seed_exchange_take_count(int(GameState.seed_bag.get(type_id, 0))) <= 0:
		_selected_trade_type = GameState.first_exchangeable_type_in_bag()
		return false
	var entries_before: Array = GameState.get_seed_bag_entries()
	if not GameState.exchange_seeds_from_bag(type_id, false):
		return false
	if int(GameState.seed_bag.get(type_id, 0)) < 1:
		_selected_trade_type = _next_trade_type_after(entries_before, type_id)
	_mark_trade_save()
	return true


func _crystal_step() -> bool:
	if _selected_crystal_type.is_empty():
		return false
	var crystal_type := _selected_crystal_type
	if int(GameState.garden_crystal_stash.get(crystal_type, 0)) < 1:
		var leftover := GameState.get_garden_crystal_entries()
		_selected_crystal_type = (
			str(leftover[0].get("type_id", "")) if not leftover.is_empty() else ""
		)
		return false
	var entries_before: Array = GameState.get_garden_crystal_entries()
	if not GameState.exchange_garden_crystal(crystal_type, false):
		return false
	if int(GameState.garden_crystal_stash.get(crystal_type, 0)) < 1:
		_selected_crystal_type = _next_crystal_type_after(entries_before, crystal_type)
	_mark_trade_save()
	return true


func _on_exchange_pressed() -> void:
	if _trade_step():
		_refresh_trade_light()
	else:
		_refresh_exchange_button()

func _on_crystal_exchange_pressed() -> void:
	if _crystal_step():
		_refresh_crystal_light()
	else:
		_refresh_crystal_exchange_button()


## Hold radi 6/s — pun rebuild grida bi 6× u sekundi rušio i gradio sve chipove.
func _refresh_trade_light() -> void:
	_refresh_wallet_labels()
	_sync_chip_counts(seed_bag_grid, GameState.seed_bag)
	_refresh_seed_chip_selection()
	_refresh_exchange_button()
	_refresh_live_chrome()


func _refresh_crystal_light() -> void:
	_refresh_wallet_labels()
	_sync_chip_counts(crystal_grid, GameState.garden_crystal_stash)
	_refresh_crystal_chip_selection()
	_refresh_crystal_exchange_button()
	_refresh_live_chrome()


## Header i link-season prate svaki pojedini trade, ne tek otpuštanje dugmeta.
## U hub-u je vidljiv hub-ov top bar, a ne Campova ResourceBar.
func _refresh_live_chrome() -> void:
	_notify_hub_chrome()
	if season_link_card and season_link_card.has_method("refresh"):
		season_link_card.refresh()


func _refresh_wallet_labels() -> void:
	if coins_label:
		coins_label.text = "%d" % GameState.wallet_coins
	if seeds_label:
		seeds_label.text = "%d / %d" % [
			GameState.sum_seed_bag(GameState.seed_bag),
			GameState.SEED_BAG_SOFT_CAP,
		]


## Tokom trgovanja broj chipova može samo padati — rebuild nije potreban.
func _sync_chip_counts(grid: GridContainer, source: Dictionary) -> void:
	if grid == null:
		return
	for child in grid.get_children():
		if not child.has_method("get_type_id") or not child.has_method("set_count"):
			continue
		var count := int(source.get(str(child.call("get_type_id")), 0))
		if count < 1:
			grid.remove_child(child)
			child.queue_free()
		else:
			child.call("set_count", count)


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
