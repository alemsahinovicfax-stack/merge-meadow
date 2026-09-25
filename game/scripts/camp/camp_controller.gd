extends Control

## Camp (design_handoff_camp · smjer 1b): hero sljedece besplatne sezone gore,
## sekcija Seeds | Flowers s jednim Trade barom dolje. Pravila: tap = 1 komad,
## drzanje = 10/s s auto prelazom na sljedeci tip; drzanje staje na granici
## ★3 cvijeca koje sljedeca sezona trazi (tap prodaje dalje).

const PICKUP_ASSETS := preload("res://scripts/visual/pickup_assets.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const DRAG_SCROLL := preload("res://scripts/ui/drag_scroll.gd")

const TRADE_HOLD_RATE := 10.0
## Save ide na otpuštanje, plus periodično da dug hold ne izgubi puno.
const TRADE_SAVE_EVERY := 30

@onready var root_vbox: VBoxContainer = %RootVBox
@onready var header_panel: PanelContainer = %HeaderPanel
@onready var home_button: UiClickButton = %HomeButton
@onready var collection_button: UiClickButton = %CollectionButton
@onready var collection_badge: Label = %CollectionBadge
@onready var settings_button: UiClickButton = %SettingsButton
@onready var resource_bar: HBoxContainer = %ResourceBar
@onready var wallet_icon: TextureRect = %WalletIcon
@onready var seeds_icon: TextureRect = %SeedsIcon
@onready var coins_label: Label = %CoinsLabel
@onready var seeds_label: Label = %SeedsLabel
@onready var season_link_card: PanelContainer = %SeasonLinkCard
@onready var stash_section: PanelContainer = %StashSection
@onready var seeds_tab: CampStashTab = %SeedsTab
@onready var flowers_tab: CampStashTab = %FlowersTab
@onready var stash_scroll: ScrollContainer = %StashScroll
@onready var seed_bag_grid: GridContainer = %SeedBagGrid
@onready var crystal_grid: GridContainer = %CrystalGrid
@onready var empty_state: VBoxContainer = %EmptyState
@onready var empty_art: PanelContainer = %EmptyArt
@onready var empty_icon: TextureRect = %EmptyIcon
@onready var empty_title: Label = %EmptyTitle
@onready var empty_cta: CampButton = %EmptyCta
@onready var exchange_bar: CampTradeBar = %ExchangeBar
@onready var exchange_button: CampButton = %ExchangeButton
@onready var footer_bar: MarginContainer = %FooterBar
@onready var merge_button: UiClickButton = %MergeButton
@onready var play_button: UiClickButton = %PlayButton

var _meta_hub_embedded: bool = false
var _active_tab: String = UiCamp.TAB_SEEDS
var _selected_trade_type: String = ""
var _selected_crystal_type: String = ""
var _force_default_trade_select: bool = false
var _force_default_crystal_select: bool = false
var _pending_trade_save: bool = false
var _trades_since_save: int = 0
var _hold_repeating: bool = false
var _hold_sold: int = 0
var _tab_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_meta_hub_embedded = bool(get_meta("meta_hub_embedded", false))
	GameState.ensure_loot_in_camp_bag()
	_setup_stash()
	_setup_trade_button()
	home_button.clicked.connect(_on_main_menu_pressed)
	collection_button.clicked.connect(_on_collection_pressed)
	settings_button.clicked.connect(_on_settings_pressed)
	play_button.clicked.connect(_on_play_pressed)
	merge_button.clicked.connect(_on_merge_pressed)
	_setup_resource_icons()
	_setup_typography()
	_setup_safe_area()
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


func _setup_stash() -> void:
	stash_section.add_theme_stylebox_override("panel", UiCamp.section_style())
	seeds_tab.setup(UiCamp.TAB_SEEDS)
	flowers_tab.setup(UiCamp.TAB_FLOWERS)
	seeds_tab.tab_pressed.connect(_on_tab_pressed)
	flowers_tab.tab_pressed.connect(_on_tab_pressed)
	empty_cta.set_styles(UiCamp.empty_cta_style(), UiCamp.empty_cta_style(true))
	empty_cta.set_fonts(UiCamp.FONT_EMPTY_CTA)
	empty_cta.set_ink(UiCamp.INK)
	empty_cta.custom_minimum_size.y = UiCamp.EMPTY_CTA_H
	empty_cta.clicked.connect(_on_empty_cta_pressed)
	UiCamp.style_label(empty_title, UiCamp.FONT_EMPTY_TITLE, UiCamp.INK)
	stash_scroll.gui_input.connect(_on_scroll_gui_input)


func _setup_trade_button() -> void:
	exchange_button.auto_repeat = true
	exchange_button.auto_repeat_rate = TRADE_HOLD_RATE
	exchange_button.ghost_when_disabled = false
	exchange_button.repeat_guard = _can_repeat_trade
	exchange_button.clicked.connect(_on_exchange_pressed)
	exchange_button.press_ended.connect(_on_trade_press_ended)
	exchange_button.repeat_blocked.connect(_on_trade_repeat_blocked)


func _on_scroll_gui_input(event: InputEvent) -> void:
	var dy := DRAG_SCROLL.drag_delta(event)
	if is_zero_approx(dy):
		return
	DRAG_SCROLL.apply(stash_scroll, dy)
	stash_scroll.accept_event()


func _exit_tree() -> void:
	_flush_trade_save()


func _flush_trade_save() -> void:
	if not _pending_trade_save:
		return
	_pending_trade_save = false
	_trades_since_save = 0
	GameState.save_player_save()


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
	if coins_label:
		TEXT_LAYOUT.stat_label(coins_label)
	if seeds_label:
		TEXT_LAYOUT.stat_label(seeds_label)


func _setup_safe_area() -> void:
	if header_panel and not _meta_hub_embedded:
		SAFE_AREA.apply_top_margin(header_panel, 8.0)
		SAFE_AREA.apply_horizontal_margins(header_panel)
	if footer_bar:
		SAFE_AREA.apply_bottom_margin(footer_bar, 4.0 if _meta_hub_embedded else 8.0)


func _apply_hub_chrome() -> void:
	var show_local_chrome := not _meta_hub_embedded
	for node in [header_panel, home_button, settings_button, collection_button, resource_bar, footer_bar]:
		if node:
			(node as Control).visible = show_local_chrome
	if root_vbox:
		root_vbox.offset_bottom = 0.0 if _meta_hub_embedded else -72.0
		if footer_bar and not _meta_hub_embedded:
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


func _refresh_ui(_status: String = "") -> void:
	_refresh_wallet_labels()
	if season_link_card and season_link_card.has_method("refresh"):
		season_link_card.call("refresh")
	_rebuild_seed_bag_grid()
	_rebuild_crystal_grid()
	_refresh_stash_view()
	_refresh_collection_badge()
	_notify_hub_chrome()


func _refresh_garden_card() -> void:
	_rebuild_seed_bag_grid()
	_refresh_stash_view()


func _refresh_crystal_card() -> void:
	_rebuild_crystal_grid()
	_refresh_stash_view()


# --- Tabovi i raspored ---

func _on_flowers() -> bool:
	return _active_tab == UiCamp.TAB_FLOWERS


func _active_grid() -> GridContainer:
	return crystal_grid if _on_flowers() else seed_bag_grid


func _selected_type() -> String:
	return _selected_crystal_type if _on_flowers() else _selected_trade_type


func _count_of(type_id: String) -> int:
	var source: Dictionary = GameState.garden_crystal_stash if _on_flowers() else GameState.seed_bag
	return int(source.get(type_id, 0))


func _on_tab_pressed(kind: String) -> void:
	if kind == _active_tab:
		return
	if exchange_button.is_holding():
		exchange_button.end_press()
	_active_tab = kind
	stash_scroll.scroll_vertical = 0
	_refresh_stash_view()
	_play_tab_change()


func _play_tab_change() -> void:
	if not is_inside_tree():
		return
	var grid := _active_grid()
	if _tab_tween:
		_tab_tween.kill()
	grid.modulate.a = 0.0
	grid.position.x = UiCamp.TAB_SLIDE_PX
	_tab_tween = create_tween()
	_tab_tween.set_parallel(true)
	_tab_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tab_tween.tween_property(grid, "modulate:a", 1.0, UiCamp.T_TAB_CHANGE)
	_tab_tween.tween_property(grid, "position:x", 0.0, UiCamp.T_TAB_CHANGE)


## Tabovi, prazno stanje, Trade bar i visina grida — bez rebuilda chipova.
func _refresh_stash_view() -> void:
	var flowers := _on_flowers()
	var seed_types := seed_bag_grid.get_child_count()
	var flower_types := crystal_grid.get_child_count()
	seeds_tab.set_active(not flowers)
	flowers_tab.set_active(flowers)
	seeds_tab.set_count(seed_types)
	flowers_tab.set_count(flower_types)
	seed_bag_grid.visible = not flowers
	crystal_grid.visible = flowers
	var empty := (flower_types if flowers else seed_types) == 0
	empty_state.visible = empty
	stash_scroll.visible = not empty
	if empty:
		_apply_empty_state(flowers)
	_refresh_trade_bar()
	_apply_stash_layout()


func _apply_empty_state(flowers: bool) -> void:
	empty_art.add_theme_stylebox_override("panel", UiCamp.empty_art_style(not flowers))
	empty_icon.texture = (
		UiAssets.get_arena_icon("icon_crystal") if flowers else UiAssets.get_chrome_icon("icon_seed")
	)
	# Bez rečenice ispod naslova — CTA vec kaze odakle stvari dolaze (v2).
	empty_title.text = "No flowers yet" if flowers else "Your bag is empty"
	empty_cta.set_text("Merge in Arena ↗" if flowers else "Play a run ↗")


## v2: sekcija je uvijek iste visine (1253 s karticom sezone, 1549 bez nje), pa
## nema rupe u sredini stranice. Lista uzima ostatak i skrola kad ima vise redova.
func _apply_stash_layout() -> void:
	var hero := season_link_card.visible
	stash_section.custom_minimum_size.y = UiCamp.section_height(hero)
	stash_section.size_flags_vertical = Control.SIZE_FILL


# --- Chipovi ---

func _clear_grid(grid: GridContainer) -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()


func _validate_trade_selection() -> void:
	if _selected_trade_type.is_empty():
		return
	if int(GameState.seed_bag.get(_selected_trade_type, 0)) >= 1:
		return
	# Depleted type — fall back to next remaining in ASC order (first entry).
	_selected_trade_type = GameState.first_exchangeable_type_in_bag()


func _validate_crystal_selection() -> void:
	if _selected_crystal_type.is_empty():
		return
	if int(GameState.garden_crystal_stash.get(_selected_crystal_type, 0)) >= 1:
		return
	var entries := GameState.get_garden_crystal_entries()
	_selected_crystal_type = str(entries[0].get("type_id", "")) if not entries.is_empty() else ""


func _next_type_after(entries_before: Array, depleted_type: String, source: Dictionary) -> String:
	var idx := -1
	for i in entries_before.size():
		if str(entries_before[i].get("type_id", "")) == depleted_type:
			idx = i
			break
	for i in range(idx + 1, entries_before.size()):
		var tid := str(entries_before[i].get("type_id", ""))
		if int(source.get(tid, 0)) >= 1:
			return tid
	for i in range(0, maxi(idx, 0)):
		var tid := str(entries_before[i].get("type_id", ""))
		if int(source.get(tid, 0)) >= 1:
			return tid
	return ""


func _rebuild_seed_bag_grid() -> void:
	_clear_grid(seed_bag_grid)
	var entries := GameState.get_seed_bag_entries()
	if _force_default_trade_select:
		_force_default_trade_select = false
		_selected_trade_type = str(entries[0].get("type_id", "")) if not entries.is_empty() else ""
	else:
		_validate_trade_selection()
	for entry in entries:
		var type_id := str(entry.get("type_id", ""))
		var chip := CampStashChip.new()
		seed_bag_grid.add_child(chip)
		chip.setup(
			"seed", type_id, int(entry.get("count", 0)), str(entry.get("display_name", "")),
			int(entry.get("rarity", 1)), GameState.seed_exchange_coins_per_seed(type_id)
		)
		chip.chip_pressed.connect(_on_seed_chip_pressed)
		chip.set_selected(type_id == _selected_trade_type)


func _rebuild_crystal_grid() -> void:
	_clear_grid(crystal_grid)
	var entries := GameState.get_garden_crystal_entries()
	if _force_default_crystal_select:
		_force_default_crystal_select = false
		_selected_crystal_type = str(entries[0].get("type_id", "")) if not entries.is_empty() else ""
	else:
		_validate_crystal_selection()
	var reserve := _reserve_info()
	for entry in entries:
		var type_id := str(entry.get("type_id", ""))
		var chip := CampStashChip.new()
		crystal_grid.add_child(chip)
		chip.setup(
			"flower", type_id, int(entry.get("count", 0)), str(entry.get("display_name", "")),
			int(entry.get("rarity", 1)), GameState.crystal_exchange_coins_for_type(type_id)
		)
		chip.chip_pressed.connect(_on_crystal_chip_pressed)
		chip.set_selected(type_id == _selected_crystal_type)
		_apply_reserve_to_chip(chip, reserve)


func _on_seed_chip_pressed(type_id: String) -> void:
	if int(GameState.seed_bag.get(type_id, 0)) < 1:
		return
	_selected_trade_type = type_id
	_refresh_chip_selection()
	_refresh_trade_bar()
	_apply_stash_layout()


func _on_crystal_chip_pressed(type_id: String) -> void:
	if int(GameState.garden_crystal_stash.get(type_id, 0)) < 1:
		return
	_selected_crystal_type = type_id
	_refresh_chip_selection()
	_refresh_trade_bar()
	_apply_stash_layout()


func _refresh_chip_selection() -> void:
	for chip in seed_bag_grid.get_children():
		(chip as CampStashChip).set_selected(chip.get_type_id() == _selected_trade_type, true)
	for chip in crystal_grid.get_children():
		(chip as CampStashChip).set_selected(chip.get_type_id() == _selected_crystal_type, true)


## Tokom trgovanja broj chipova može samo padati — rebuild nije potreban.
func _sync_chip_counts(grid: GridContainer, source: Dictionary) -> void:
	for child in grid.get_children():
		var chip := child as CampStashChip
		var count := int(source.get(chip.get_type_id(), 0))
		if count < 1:
			grid.remove_child(chip)
			chip.queue_free()
		else:
			chip.set_count(count)


# --- Rezervisano ★3 cvijece ---

## ★3 tip i broj koji sljedeca besplatna sezona trazi (npr. 20 Harvest Pumpkin
## za Frost Orchard); prazno kad nema sljedece sezone.
func _reserve_info() -> Dictionary:
	var next_id := GameState.next_locked_free_id()
	if next_id.is_empty():
		return {}
	var def: SeasonDef = GameState.get_season_def(next_id)
	if def == null or def.t3_flowers_required <= 0:
		return {}
	var prev := GameState.previous_free_id_for(next_id)
	if prev.is_empty():
		return {}
	var type_id := GameState.star3_type_id_for_season(prev)
	if type_id.is_empty():
		return {}
	return {
		"type_id": type_id,
		"need": def.t3_flowers_required,
		"season_id": next_id,
		"season_name": def.display_name,
	}


func _reserve_for(type_id: String) -> Dictionary:
	if not _on_flowers() or type_id.is_empty():
		return {}
	var info := _reserve_info()
	if info.is_empty() or str(info.get("type_id", "")) != type_id:
		return {}
	return info


func _apply_reserve_to_chip(chip: CampStashChip, reserve: Dictionary) -> void:
	var type_id := chip.get_type_id()
	if reserve.is_empty() or str(reserve.get("type_id", "")) != type_id:
		chip.set_reserved(false)
		return
	var have := int(GameState.garden_crystal_stash.get(type_id, 0))
	var need := int(reserve.get("need", 0))
	chip.set_reserved(true, have, need, str(reserve.get("season_id", "")), have == need)


## Guard prije svakog auto-tika: drzanje ne smije odvesti rezervisani tip ispod granice.
func _can_repeat_trade() -> bool:
	var type_id := _selected_type()
	if type_id.is_empty():
		return false
	var reserve := _reserve_for(type_id)
	if reserve.is_empty():
		return true
	return _count_of(type_id) - 1 >= int(reserve.get("need", 0))


# --- Trade ---

func _trade_state() -> String:
	var type_id := _selected_type()
	if type_id.is_empty() or _count_of(type_id) < 1:
		return UiCamp.TRADE_DISABLED
	var reserve := _reserve_for(type_id)
	if not reserve.is_empty():
		var have := _count_of(type_id)
		var need := int(reserve.get("need", 0))
		if have == need:
			return UiCamp.TRADE_HOLD_STOP
		if have < need:
			return UiCamp.TRADE_WARN
	if _hold_repeating and exchange_button.is_holding():
		return UiCamp.TRADE_HOLD
	return UiCamp.TRADE_IDLE


func _refresh_trade_bar() -> void:
	var state := _trade_state()
	var type_id := _selected_type()
	var info := {}
	if not type_id.is_empty():
		var flowers := _on_flowers()
		info = {
			"kind": "flower" if flowers else "seed",
			"type_id": type_id,
			"label": GameState.get_seed_display_name(type_id),
			"rarity": GameState.get_seed_rarity(type_id),
			"price": (
				GameState.crystal_exchange_coins_for_type(type_id)
				if flowers
				else GameState.seed_exchange_coins_per_seed(type_id)
			),
		}
		var reserve := _reserve_for(type_id)
		if not reserve.is_empty():
			var need := int(reserve.get("need", 0))
			info["need"] = need
			info["season_name"] = str(reserve.get("season_name", ""))
			info["left"] = maxi(need - _count_of(type_id), 0)
	exchange_bar.apply_state(state, info)


## Jedan komad; kad se tip isprazni, selekcija prelazi na sljedeći (za hold).
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
		_selected_trade_type = _next_type_after(entries_before, type_id, GameState.seed_bag)
	_mark_trade_save()
	return true


func _crystal_step() -> bool:
	if _selected_crystal_type.is_empty():
		return false
	var crystal_type := _selected_crystal_type
	if int(GameState.garden_crystal_stash.get(crystal_type, 0)) < 1:
		var leftover := GameState.get_garden_crystal_entries()
		_selected_crystal_type = str(leftover[0].get("type_id", "")) if not leftover.is_empty() else ""
		return false
	var entries_before: Array = GameState.get_garden_crystal_entries()
	if not GameState.exchange_garden_crystal(crystal_type, false):
		return false
	if int(GameState.garden_crystal_stash.get(crystal_type, 0)) < 1:
		_selected_crystal_type = _next_type_after(entries_before, crystal_type, GameState.garden_crystal_stash)
	_mark_trade_save()
	return true


func _on_exchange_pressed() -> void:
	var repeat := exchange_button.last_click_was_repeat
	var coins_before := GameState.wallet_coins
	var type_before := _selected_type()
	var traded := _crystal_step() if _on_flowers() else _trade_step()
	if not traded:
		_refresh_stash_view()
		return
	if repeat:
		_hold_repeating = true
	_hold_sold += 1
	exchange_bar.add_gain(GameState.wallet_coins - coins_before)
	var switched := _selected_type() != type_before and not _selected_type().is_empty()
	_refresh_trade_light()
	# Fill je prodani dio gomile; tap ga kratko pokaze, drzanje ga puni.
	if repeat:
		exchange_bar.on_hold_tick(_hold_sold, _sellable_left())
	else:
		exchange_bar.on_tap_hint(_hold_sold, _sellable_left())
	if switched:
		exchange_bar.flash_switch()


## Koliko se jos komada odabranog tipa smije prodati (rezervisano cvijece ne racuna).
func _sellable_left() -> int:
	var type_id := _selected_type()
	if type_id.is_empty():
		return 0
	var have := _count_of(type_id)
	var reserve := _reserve_for(type_id)
	if reserve.is_empty():
		return have
	return maxi(have - int(reserve.get("need", 0)), 0)


func _on_trade_press_ended() -> void:
	_hold_repeating = false
	_hold_sold = 0
	exchange_bar.release_gain()
	exchange_bar.on_press_ended()
	_flush_trade_save()
	_refresh_ui()


func _on_trade_repeat_blocked() -> void:
	_hold_repeating = false
	_refresh_trade_bar()
	_apply_stash_layout()


## Hold radi 10/s — pun rebuild grida bi 10× u sekundi rušio i gradio sve chipove.
func _refresh_trade_light() -> void:
	_refresh_wallet_labels()
	var flowers := _on_flowers()
	_sync_chip_counts(
		crystal_grid if flowers else seed_bag_grid,
		GameState.garden_crystal_stash if flowers else GameState.seed_bag
	)
	if flowers:
		var reserve := _reserve_info()
		for chip in crystal_grid.get_children():
			_apply_reserve_to_chip(chip as CampStashChip, reserve)
	_refresh_chip_selection()
	_refresh_stash_view()
	_refresh_live_chrome()


## Header i link-season prate svaki pojedini trade, ne tek otpuštanje dugmeta.
## U hub-u je vidljiv hub-ov top bar, a ne Campova ResourceBar.
func _refresh_live_chrome() -> void:
	_notify_hub_chrome()
	if season_link_card and season_link_card.has_method("refresh"):
		season_link_card.call("refresh")


func _refresh_wallet_labels() -> void:
	if coins_label:
		coins_label.text = "%d" % GameState.wallet_coins
	if seeds_label:
		seeds_label.text = "%d / %d" % [
			GameState.sum_seed_bag(GameState.seed_bag),
			GameState.SEED_BAG_SOFT_CAP,
		]


func _refresh_collection_badge() -> void:
	if collection_badge == null:
		return
	collection_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var news := GameState.count_collection_journal_news()
	collection_badge.visible = news > 0 and not _meta_hub_embedded
	collection_badge.text = "!" if news == 1 else str(mini(news, 9))


# --- Navigacija ---

func _on_empty_cta_pressed() -> void:
	if _on_flowers():
		_on_merge_pressed()
	else:
		_on_play_pressed()


func _on_merge_pressed() -> void:
	GameState.go_to_merge_arena()


func _on_collection_pressed() -> void:
	GameState.go_to_collection_journal()


func _on_main_menu_pressed() -> void:
	GameState.go_to_meta_home()


func _on_settings_pressed() -> void:
	_refresh_ui()


func _on_play_pressed() -> void:
	GameState.notify_camp_play()
	GameState.begin_campaign_run()
	SceneRouter.change_to(GameState.SCENE_RUN)
