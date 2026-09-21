extends Control

const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const HomeBasketPickerIcon := preload("res://scripts/ui/home_basket_picker_icon.gd")
const UiAttention := preload("res://scripts/ui/ui_attention.gd")

const PICKER_ROW_MIN_HEIGHT := 128.0
const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const LOCKED_SEED_MODULATE := Color(0.45, 0.45, 0.45, 1)
## HomeColumn: biranje sezone = padding 24 (design_handoff_home); polje sezone
## zadrzava stari raspored dok ne dobije svoj brief (lijevo, vrh, desno, dno).
const TRAIL_COLUMN_OFFSETS := Vector4(24, 24, -24, -24)
const FIELD_COLUMN_OFFSETS := Vector4(48, 380, -48, -24)
const FIELD_COLUMN_SEPARATION := 12
const PLAY_ICON_TRAIL := 56.0
const PLAY_ICON_FIELD := 44.0
const FIELD_PLAY_SIZE := Vector2(320, 96)

enum ChestUiState { LOCKED, READY, OPENING, CLAIMED }

@onready var tutorial_hint: Label = %TutorialHint
@onready var tutorial_hint_panel: PanelContainer = %TutorialHintPanel
@onready var field_upgrade_stack: VBoxContainer = %FieldUpgradeStack
@onready var magnet_title: Label = %MagnetTitle
@onready var magnet_button: UiClickButton = %MagnetButton
@onready var loot_boost_title: Label = %LootBoostTitle
@onready var loot_boost_button: UiClickButton = %LootBoostButton
@onready var home_top_stack: VBoxContainer = %HomeTopStack
@onready var home_column: VBoxContainer = %HomeColumn
@onready var basket_card: PanelContainer = %BasketCard
@onready var basket_visual: Control = %BasketVisual
@onready var basket_title: Label = %BasketTitle
@onready var basket_caption: Label = %BasketCaption
@onready var play_button: CampButton = %PlayButton
@onready var seasons_row_button: UiClickButton = %SeasonsRowButton
@onready var endless_play_button: UiClickButton = %EndlessPlayButton
@onready var daily_chest_card: PanelContainer = %DailyChestCard
@onready var daily_title: Label = %DailyTitle
@onready var daily_caption: Label = %DailyCaption
@onready var gift_icon: Panel = %GiftIcon
@onready var gift_ribbon_v: ColorRect = %RibbonV
@onready var gift_ribbon_h: ColorRect = %RibbonH
@onready var top_row: HBoxContainer = %TopRow
@onready var progress_indicator: HomeProgressIndicator = %ProgressIndicator
@onready var reward_overlay: Control = %RewardOverlay
@onready var reward_title: Label = %RewardTitle
@onready var reward_body: Label = %RewardBody
@onready var reward_ok_button: UiClickButton = %RewardOkButton
@onready var basket_picker_overlay: Control = %BasketPickerOverlay
@onready var picker_panel: PanelContainer = %PickerPanel
@onready var picker_list: VBoxContainer = %PickerList
@onready var picker_footer: VBoxContainer = %PickerFooter
@onready var picker_clear_button: UiClickButton = %PickerClearButton
@onready var picker_close_button: UiClickButton = %PickerCloseButton
@onready var season_stage: Control = %SeasonStage
@onready var field_backdrop: ColorRect = %FieldBackdrop
@onready var season_name_chip: UiClickButton = %SeasonNameChip

var _chest_ui_state: ChestUiState = ChestUiState.LOCKED
var _chest_pulsing: bool = false
var _chest_pulse_t: float = 0.0
var _play_spacer: Control = null
var _play_chip: PanelContainer = null
var _play_chip_label: Label = null
var _field_safe_shift: float = 0.0
var _basket_locked: bool = false
var _basket_attention: UiAttention = UiAttention.new()
var _chest_attention: UiAttention = UiAttention.new()


func _ready() -> void:
	play_button.clicked.connect(_on_play_pressed)
	endless_play_button.clicked.connect(_on_endless_play_pressed)
	if seasons_row_button:
		seasons_row_button.clicked.connect(_on_seasons_row_pressed)
	if picker_clear_button:
		picker_clear_button.clicked.connect(_on_basket_clear_picked)
	if picker_close_button:
		picker_close_button.clicked.connect(_close_basket_picker)
	if basket_picker_overlay:
		var dim := basket_picker_overlay.get_node_or_null("Dim") as Control
		if dim:
			dim.gui_input.connect(_on_picker_dim_gui_input)
	if magnet_button:
		magnet_button.clicked.connect(_on_field_magnet_pressed)
	if loot_boost_button:
		loot_boost_button.clicked.connect(_on_field_loot_boost_pressed)
	if reward_ok_button:
		reward_ok_button.clicked.connect(_on_reward_ok_pressed)
	if daily_chest_card:
		daily_chest_card.gui_input.connect(_on_daily_chest_gui_input)
		daily_chest_card.resized.connect(_on_daily_chest_resized)
		_on_daily_chest_resized()
		_chest_attention.bind(daily_chest_card, UiAttention.Kind.CHEST)
	if basket_card:
		basket_card.gui_input.connect(_on_basket_card_gui_input)
		if not basket_card.resized.is_connected(_on_basket_card_resized):
			basket_card.resized.connect(_on_basket_card_resized)
		_on_basket_card_resized()
		_basket_attention.bind(basket_card, UiAttention.Kind.BASKET)
	_setup_play_button()
	_setup_typography()
	_setup_safe_area()
	if OS.is_debug_build() and not GameState.skip_debug_season_unlock:
		GameState.debug_playtest_two_free()
	_refresh_menu()
	_refresh_chest_card()
	_refresh_basket_card()


func _setup_typography() -> void:
	UiHome.style(tutorial_hint, UiHome.FONT_HINT, UiHome.INK, UiHome.W_BOLD)
	tutorial_hint_panel.add_theme_stylebox_override("panel", UiHome.tutorial_hint())
	if basket_title:
		TEXT_LAYOUT.card_title_scroll(basket_title)
	if basket_caption:
		TEXT_LAYOUT.caption_label_scroll(basket_caption)
	if magnet_title:
		TEXT_LAYOUT.caption_label_scroll(magnet_title)
	if loot_boost_title:
		TEXT_LAYOUT.caption_label_scroll(loot_boost_title)
	if reward_title:
		TEXT_LAYOUT.card_title_scroll(reward_title)
	if reward_body:
		TEXT_LAYOUT.body_label_scroll(reward_body)


func _setup_safe_area() -> void:
	if field_upgrade_stack:
		SAFE_AREA.apply_top_margin(field_upgrade_stack, 8.0)
		SAFE_AREA.apply_horizontal_margins(field_upgrade_stack)
	if home_top_stack:
		SAFE_AREA.apply_top_margin(home_top_stack, 8.0)
		SAFE_AREA.apply_horizontal_margins(home_top_stack)
	if season_name_chip:
		SAFE_AREA.apply_top_margin(season_name_chip, 8.0)
	# Polje sezone: stari raspored je bio pomjeren za safe area + 8 px; biranje
	# sezone stoji tacno na paddingu 24 (hub footer vec pokriva safe area).
	_field_safe_shift = SAFE_AREA.get_insets(get_viewport()).z + 8.0



func _process(delta: float) -> void:
	_chest_attention.tick(delta)
	_basket_attention.tick(delta)
	_chest_pulsing = _chest_attention.active


func _exit_tree() -> void:
	_stop_chest_pulse()
	_basket_attention.set_active(false)


func _refresh_menu() -> void:
	var hub := GameState.tutorial_complete
	tutorial_hint.text = "First run: tap Play. Seeds you bring back become flowers in the Arena."
	tutorial_hint_panel.visible = not hub
	refresh_play_chip()
	refresh_progress_indicator()
	_refresh_basket_card()
	_refresh_field_upgrades()
	_refresh_endless_button()
	_refresh_seasons_row_button()
	if season_stage and season_stage.has_method("refresh"):
		season_stage.call("refresh")
	sync_field_backdrop()


func sync_field_backdrop() -> void:
	var open := GameState.home_season_field_open
	if field_backdrop:
		field_backdrop.visible = open
		if open:
			field_backdrop.color = SeasonTheme.home_field_tint(GameState.home_season_field_id)
			field_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_mode_layout(open)
	_sync_loadout_to_open_season()
	_refresh_basket_card()
	_refresh_endless_button()
	_refresh_seasons_row_button()
	_refresh_season_name_chip()
	_refresh_field_upgrades()
	_sync_field_hub_swipe_chrome()


func _sync_field_hub_swipe_chrome() -> void:
	var open := GameState.home_season_field_open
	var play_row: Control = get_node_or_null("%PlayRow") as Control
	for node in [
		daily_chest_card,
		basket_card,
		season_name_chip,
		play_row,
		field_upgrade_stack,
		magnet_button,
		loot_boost_button,
	]:
		_set_block_hub_swipe(node as Control, open)


func _set_block_hub_swipe(ctrl: Control, enabled: bool) -> void:
	if ctrl == null:
		return
	if enabled:
		if not ctrl.is_in_group(BLOCK_HUB_SWIPE_GROUP):
			ctrl.add_to_group(BLOCK_HUB_SWIPE_GROUP)
	elif ctrl.is_in_group(BLOCK_HUB_SWIPE_GROUP):
		ctrl.remove_from_group(BLOCK_HUB_SWIPE_GROUP)


func _refresh_season_name_chip() -> void:
	if season_name_chip == null:
		return
	var open := GameState.home_season_field_open
	season_name_chip.visible = open
	season_name_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not open:
		season_name_chip.label_text = ""
		return
	var def: SeasonDef = GameState.get_season_def(GameState.home_season_field_id)
	season_name_chip.label_text = def.display_name if def else GameState.home_season_field_id


func _on_seasons_row_pressed() -> void:
	if season_stage and season_stage.has_method("close_season_field"):
		season_stage.call("close_season_field")


func _refresh_endless_button() -> void:
	if endless_play_button == null:
		return
	endless_play_button.visible = (
		GameState.tutorial_complete and GameState.home_season_field_open
	)


func _refresh_seasons_row_button() -> void:
	if seasons_row_button == null:
		return
	seasons_row_button.visible = (
		GameState.tutorial_complete and GameState.home_season_field_open
	)


## Odluka 2026-09-21: Play pokrece run u aktivnoj sezoni odmah (1 korak umjesto 3).
## Polje sezone se otvara samo tapom na aktivnu karticu ili "Open meadow ↗".
func home_play_action() -> String:
	return "run"


func _on_play_pressed() -> void:
	var id := GameState.active_season_id
	if id.is_empty() or not GameState.is_season_playable(id):
		GameState.set_active_season(SeasonCatalog.DEFAULT_SEASON_ID)
	GameState.begin_campaign_run()
	SceneRouter.change_to(GameState.SCENE_RUN)


## Play na biranju sezone: 1032 x 156, peach, ikona + "Play" lijevo, cip s imenom
## aktivne sezone desno ("Play · Country Bloom"). U polju sezone ostaje staro dugme.
func _setup_play_button() -> void:
	var row := play_button.get_node_or_null("ContentRow") as HBoxContainer
	if row == null:
		return
	_play_spacer = Control.new()
	_play_spacer.name = "PlaySpacer"
	_play_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_play_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_play_spacer)
	_play_chip = PanelContainer.new()
	_play_chip.name = "PlaySeasonChip"
	_play_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_play_chip.custom_minimum_size.y = UiHome.PLAY_CHIP_H
	_play_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_play_chip.add_theme_stylebox_override("panel", UiHome.play_chip())
	row.add_child(_play_chip)
	_play_chip_label = Label.new()
	_play_chip_label.name = "Text"
	UiHome.style(_play_chip_label, UiHome.FONT_PLAY_CHIP, UiHome.INK, UiHome.W_BOLD)
	_play_chip.add_child(_play_chip_label)
	play_button.set_icon(UiAssets.get_play_icon(), PLAY_ICON_TRAIL)
	play_button.set_text("Play")


func refresh_play_chip() -> void:
	if _play_chip_label == null:
		return
	var def: SeasonDef = GameState.get_season_def(GameState.active_season_id)
	_play_chip_label.text = def.display_name if def else ""


func get_play_chip_text() -> String:
	return _play_chip_label.text if _play_chip_label and _play_chip.visible else ""


func refresh_progress_indicator() -> void:
	if progress_indicator:
		progress_indicator.refresh()


func _apply_mode_layout(field_open: bool) -> void:
	if top_row:
		top_row.visible = not field_open
	if home_column:
		var o := FIELD_COLUMN_OFFSETS if field_open else TRAIL_COLUMN_OFFSETS
		home_column.offset_left = o.x
		home_column.offset_top = o.y - (_field_safe_shift if field_open else 0.0)
		home_column.offset_right = o.z
		home_column.offset_bottom = o.w - (_field_safe_shift if field_open else 0.0)
		home_column.add_theme_constant_override(
			"separation", FIELD_COLUMN_SEPARATION if field_open else UiHome.BLOCK_GAP
		)
	_apply_play_layout(field_open)


func _apply_play_layout(field_open: bool) -> void:
	if play_button == null:
		return
	var row := play_button.get_node_or_null("ContentRow") as HBoxContainer
	if field_open:
		play_button.custom_minimum_size = FIELD_PLAY_SIZE
		play_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		play_button.set_styles(
			UiPalette.button_style("primary", "normal"), UiPalette.button_style("primary", "pressed")
		)
		play_button.set_fonts(40)
		play_button.set_ink(UiPalette.UI_TEXT)
		play_button.set_icon(UiAssets.get_play_icon(), PLAY_ICON_FIELD)
		play_button.set_press_scale(1.0)
		if row:
			row.alignment = BoxContainer.ALIGNMENT_CENTER
	else:
		play_button.custom_minimum_size = Vector2(0, UiHome.PLAY_H)
		play_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		play_button.set_styles(UiHome.play_button(false), UiHome.play_button(true))
		play_button.set_fonts(UiHome.FONT_PLAY)
		play_button.set_ink(UiHome.INK)
		play_button.set_icon(UiAssets.get_play_icon(), PLAY_ICON_TRAIL)
		play_button.set_press_scale(0.97)
		if row:
			row.alignment = BoxContainer.ALIGNMENT_BEGIN
	if _play_spacer:
		_play_spacer.visible = not field_open
	if _play_chip:
		_play_chip.visible = not field_open


func _on_endless_play_pressed() -> void:
	if not GameState.home_season_field_open:
		return
	var field_id := GameState.home_season_field_id
	if not field_id.is_empty():
		GameState.set_active_season(field_id)
	GameState.begin_endless_run(GameState.EndlessDifficulty.HARD)
	SceneRouter.change_to(GameState.SCENE_RUN)


func _refresh_field_upgrades() -> void:
	if field_upgrade_stack == null:
		return
	var open := GameState.home_season_field_open
	field_upgrade_stack.visible = open
	if not open:
		return
	_apply_field_upgrade_button(
		magnet_button,
		GameState.magnet_level,
		GameState.MAGNET_MAX_LEVEL
	)
	_apply_field_upgrade_button(
		loot_boost_button,
		GameState.multiplier_level,
		GameState.MULTIPLIER_MAX_LEVEL
	)


func _apply_field_upgrade_button(btn: UiClickButton, level: int, max_level: int) -> void:
	if btn == null:
		return
	var maxed := level >= max_level
	btn.label_text = "Maxed" if maxed else "Upgrade"
	btn.disabled = maxed or not GameState.can_spend_flowers_for_upgrade("")


func _on_field_magnet_pressed() -> void:
	if not GameState.home_season_field_open:
		return
	GameState.try_upgrade_magnet("")
	_refresh_field_upgrades()


func _on_field_loot_boost_pressed() -> void:
	if not GameState.home_season_field_open:
		return
	GameState.try_upgrade_multiplier("")
	_refresh_field_upgrades()


func _refresh_chest_card() -> void:
	if daily_chest_card == null:
		return
	if _chest_ui_state == ChestUiState.OPENING:
		return
	if not GameState.tutorial_complete:
		_chest_ui_state = ChestUiState.LOCKED
		daily_chest_card.visible = false
		_fit_progress_indicator(false)
		_stop_chest_pulse()
		return
	daily_chest_card.visible = true
	_fit_progress_indicator(true)
	if GameState.can_claim_daily_chest():
		_chest_ui_state = ChestUiState.READY
		_style_daily_gift(false)
		_start_chest_pulse()
	else:
		_chest_ui_state = ChestUiState.CLAIMED
		_style_daily_gift(true)
		_stop_chest_pulse()


## Daily gift u TopRow-u (HomeScreen.dc.html · DailyGiftCard): ikona od tri ravna
## oblika (kutija + dvije trake), "Daily gift" 38 px + "Tap to open" 48 px.
func _style_daily_gift(taken: bool) -> void:
	daily_title.text = "Daily gift"
	daily_caption.text = "Back tomorrow" if taken else "Tap to open"
	daily_chest_card.add_theme_stylebox_override("panel", UiHome.daily_gift(taken))
	UiHome.style(
		daily_title, UiHome.FONT_GIFT_TITLE,
		Color(1.0, 0.973, 0.941, 0.88) if taken else UiHome.SUB_INK, UiHome.W_REGULAR
	)
	UiHome.style(daily_caption, UiHome.FONT_GIFT_SUB, UiHome.WARM_WHITE if taken else UiHome.DARK_INK, UiHome.W_BLACK)
	if gift_icon:
		gift_icon.add_theme_stylebox_override("panel", UiHome.gift_box(taken))
	var ribbon := UiHome.GIFT_RIBBON_TAKEN if taken else UiHome.WARM_WHITE
	if gift_ribbon_v:
		gift_ribbon_v.color = ribbon
	if gift_ribbon_h:
		gift_ribbon_h.color = ribbon


## Bez Daily gifta (prije kraja tutoriala) ProgressIndicator zauzima cijeli red.
func _fit_progress_indicator(gift_visible: bool) -> void:
	if progress_indicator == null:
		return
	progress_indicator.custom_minimum_size.x = UiHome.PROGRESS_W if gift_visible else 0.0
	progress_indicator.size_flags_horizontal = (
		Control.SIZE_FILL if gift_visible else Control.SIZE_EXPAND_FILL
	)


func _start_chest_pulse() -> void:
	_chest_attention.set_active(true)
	_chest_pulsing = true


func _stop_chest_pulse() -> void:
	_chest_attention.set_active(false)
	_chest_pulsing = false
	_chest_pulse_t = 0.0


func is_chest_attention_active() -> bool:
	return _chest_attention.active


func is_basket_attention_active() -> bool:
	return _basket_attention.active


func _on_basket_card_resized() -> void:
	if basket_card:
		basket_card.pivot_offset = basket_card.size * 0.5


func _on_daily_chest_resized() -> void:
	if daily_chest_card:
		daily_chest_card.pivot_offset = daily_chest_card.size * 0.5


func _on_daily_chest_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if not tapped:
		return
	daily_chest_card.accept_event()
	_on_daily_chest_pressed()


func _on_daily_chest_pressed() -> void:
	if _chest_ui_state == ChestUiState.OPENING:
		return
	if _chest_ui_state == ChestUiState.LOCKED:
		return
	if _chest_ui_state == ChestUiState.CLAIMED:
		_show_reward_overlay(
			"Come back tomorrow",
			"Daily chest already opened today."
		)
		return
	_chest_ui_state = ChestUiState.OPENING
	_stop_chest_pulse()
	var tw := create_tween()
	tw.tween_property(daily_chest_card, "scale", Vector2(1.05, 1.05), 0.15)
	tw.tween_property(daily_chest_card, "scale", Vector2.ONE, 0.2)
	tw.tween_callback(_finish_chest_claim)


func _finish_chest_claim() -> void:
	var msg := GameState.claim_daily_chest()
	_chest_ui_state = ChestUiState.CLAIMED
	_refresh_chest_card()
	_notify_hub_chrome()
	_show_reward_overlay("Daily gift!", msg)


func _notify_hub_chrome() -> void:
	if not GameState.meta_hub_active or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "refresh_top_bar")


func _show_reward_overlay(title: String, body: String) -> void:
	if reward_overlay == null:
		return
	if reward_title:
		reward_title.text = title
	if reward_body:
		reward_body.text = body
	reward_overlay.visible = true


func _hide_reward_overlay() -> void:
	if reward_overlay:
		reward_overlay.visible = false


func _on_reward_ok_pressed() -> void:
	_hide_reward_overlay()


func refresh_for_meta_hub() -> void:
	_refresh_menu()
	_refresh_chest_card()
	_refresh_basket_card()


func _sync_loadout_to_open_season() -> void:
	if not GameState.home_season_field_open:
		return
	var loadout := GameState.get_loadout_type()
	if loadout.is_empty():
		return
	var pool: Array[String] = SeedCatalog.types_for_season(GameState.home_season_field_id)
	if not pool.has(loadout):
		GameState.clear_loadout()


func _refresh_basket_card() -> void:
	if basket_card == null:
		return
	basket_card.visible = GameState.home_season_field_open
	_basket_locked = not GameState.loadout_enabled()
	if _basket_locked:
		if basket_title:
			basket_title.text = "Basket"
		if basket_caption:
			basket_caption.text = "Unlock after first merge"
		if basket_visual and basket_visual.has_method("set_loadout_type"):
			basket_visual.call("set_loadout_type", "")
		_sync_basket_attention()
		basket_card.modulate = Color(0.78, 0.78, 0.78, 1)
		return
	_sync_basket_attention()
	if not _basket_attention.active:
		basket_card.modulate = Color.WHITE
	var type_id := GameState.get_loadout_type()
	if type_id.is_empty():
		if basket_title:
			basket_title.text = "Basket"
		if basket_caption:
			basket_caption.text = "Tap to choose"
		if basket_visual and basket_visual.has_method("set_loadout_type"):
			basket_visual.call("set_loadout_type", "")
	else:
		var name: String = GameState.get_seed_display_name(type_id)
		var stars := "★".repeat(GameState.get_seed_rarity(type_id))
		if basket_title:
			basket_title.text = name
		if basket_caption:
			basket_caption.text = "%s  (+%.0f%% spawn)" % [stars, GameState.LOADOUT_SPAWN_BONUS * 100.0]
		if basket_visual and basket_visual.has_method("set_loadout_type"):
			basket_visual.call("set_loadout_type", type_id)
	_sync_basket_attention()


func _sync_basket_attention() -> void:
	var on := (
		basket_card != null
		and basket_card.visible
		and GameState.home_season_field_open
		and GameState.loadout_enabled()
		and not _basket_locked
		and GameState.get_loadout_type().is_empty()
	)
	_basket_attention.set_active(on)


func _on_basket_card_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if not tapped:
		return
	if basket_card:
		basket_card.accept_event()
	_on_basket_pressed()


func _on_basket_pressed() -> void:
	if _basket_locked or not GameState.loadout_enabled():
		if tutorial_hint:
			tutorial_hint.text = "Merge your first flower to unlock the basket."
			tutorial_hint_panel.visible = true
		return
	_open_basket_picker()


func _on_picker_dim_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if tapped:
		_close_basket_picker()


func _open_basket_picker() -> void:
	if not GameState.home_season_field_open:
		return
	if basket_picker_overlay == null or picker_list == null:
		return
	_rebuild_picker_list()
	basket_picker_overlay.visible = true
	_fit_picker_panel()


func _close_basket_picker() -> void:
	if basket_picker_overlay:
		basket_picker_overlay.visible = false


func _rebuild_picker_list() -> void:
	if picker_list == null:
		return
	for child in picker_list.get_children():
		picker_list.remove_child(child)
		child.queue_free()
	var current := GameState.get_loadout_type()
	if picker_clear_button:
		picker_clear_button.disabled = current.is_empty()
	for type_id in SeedCatalog.types_for_season(GameState.home_season_field_id):
		var unlocked := GameState.is_seed_type_unlocked(type_id)
		var display_name: String = GameState.get_seed_display_name(type_id)
		var stars := "★".repeat(GameState.get_seed_rarity(type_id))
		var row := UiClickButton.new()
		row.custom_minimum_size = Vector2(0, PICKER_ROW_MIN_HEIGHT)
		row.font_size = 22
		row.label_text = "%s %s" % [display_name, stars]
		row.set_meta("seed_type_id", type_id)
		row.button_variant = "primary" if unlocked and type_id == current else "subtle"
		if unlocked:
			row.clicked.connect(func() -> void: _on_basket_type_picked(type_id))
		else:
			row.disabled = true
			row.modulate = LOCKED_SEED_MODULATE
			row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		picker_list.add_child(row)
		_layout_picker_flower_row(row, type_id)
	_fit_picker_panel()


func _fit_picker_panel() -> void:
	if picker_panel == null:
		return
	var vbox := picker_panel.get_node_or_null("PickerVBox") as Control
	if vbox == null:
		return
	var inner := vbox.get_combined_minimum_size()
	var pad_y := 0.0
	var style := picker_panel.get_theme_stylebox("panel")
	if style:
		pad_y = style.get_margin(SIDE_TOP) + style.get_margin(SIDE_BOTTOM)
	var half := (inner.y + pad_y) * 0.5
	picker_panel.offset_left = -280.0
	picker_panel.offset_right = 280.0
	picker_panel.offset_top = -half
	picker_panel.offset_bottom = half


func _layout_picker_flower_row(row: UiClickButton, type_id: String) -> void:
	var hbox := row.get_node_or_null("ContentRow") as Container
	if hbox == null:
		return
	var label := hbox.get_node_or_null("Label") as Label
	var legacy_icon := hbox.get_node_or_null("Icon") as Control
	var vbox := VBoxContainer.new()
	vbox.name = "ContentRow"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	var plant: Control = HomeBasketPickerIcon.new()
	plant.name = "PlantIcon"
	plant.set("type_id", type_id)
	row.remove_child(hbox)
	if label:
		hbox.remove_child(label)
	if legacy_icon:
		hbox.remove_child(legacy_icon)
	vbox.add_child(plant)
	if label:
		vbox.add_child(label)
	if legacy_icon:
		vbox.add_child(legacy_icon)
	row.add_child(vbox)
	hbox.queue_free()


func _on_basket_clear_picked() -> void:
	GameState.clear_loadout()
	_refresh_basket_card()
	_close_basket_picker()


func _on_basket_type_picked(type_id: String) -> void:
	if GameState.set_loadout(type_id):
		_refresh_basket_card()
		_close_basket_picker()
