extends Control

const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const HomeBasketPickerIcon := preload("res://scripts/ui/home_basket_picker_icon.gd")
const UiAttention := preload("res://scripts/ui/ui_attention.gd")

const PICKER_ROW_MIN_HEIGHT := 128.0
const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const LOCKED_SEED_MODULATE := Color(0.45, 0.45, 0.45, 1)

enum ChestUiState { LOCKED, READY, OPENING, CLAIMED }

@onready var tutorial_hint: Label = %TutorialHint
@onready var settings_button: UiClickButton = %SettingsButton
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
@onready var play_button: UiClickButton = %PlayButton
@onready var play_theme_badge: Label = %PlayThemeBadge
@onready var seasons_row_button: UiClickButton = %SeasonsRowButton
@onready var endless_play_button: UiClickButton = %EndlessPlayButton
@onready var daily_chest_card: PanelContainer = %DailyChestCard
@onready var daily_title: Label = %DailyTitle
@onready var daily_caption: Label = %DailyCaption
@onready var chest_visual: Control = %ChestVisual
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
@onready var decor_mound_left: ColorRect = $DecorMoundLeft
@onready var decor_mound_right: ColorRect = $DecorMoundRight

var _chest_ui_state: ChestUiState = ChestUiState.LOCKED
var _chest_pulsing: bool = false
var _chest_pulse_t: float = 0.0
var _style_daily_ready: StyleBox = null
var _style_daily_claimed: StyleBox = null
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
	if settings_button:
		settings_button.clicked.connect(_on_settings_pressed)
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
	_cache_daily_styles()
	_setup_typography()
	_setup_safe_area()
	if OS.is_debug_build() and not GameState.skip_debug_season_unlock:
		GameState.debug_playtest_two_free()
	var pip_portrait: Control = get_node_or_null("%PipPortrait") as Control
	if pip_portrait:
		pip_portrait.visible = false
	_refresh_menu()
	_refresh_chest_card()
	_refresh_basket_card()


func _setup_typography() -> void:
	if daily_title:
		TEXT_LAYOUT.card_title_scroll(daily_title)
	if daily_caption:
		TEXT_LAYOUT.caption_label_scroll(daily_caption)
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
	if settings_button:
		SAFE_AREA.apply_top_margin(settings_button, 8.0)
		SAFE_AREA.apply_horizontal_margins(settings_button)
	if field_upgrade_stack:
		SAFE_AREA.apply_horizontal_margins(field_upgrade_stack)
	if home_top_stack:
		SAFE_AREA.apply_top_margin(home_top_stack, 8.0)
		SAFE_AREA.apply_horizontal_margins(home_top_stack)
	if season_name_chip:
		SAFE_AREA.apply_top_margin(season_name_chip, 8.0)
	if home_column:
		SAFE_AREA.apply_bottom_margin(home_column, 8.0)


func _cache_daily_styles() -> void:
	if daily_chest_card == null:
		return
	var current := daily_chest_card.get_theme_stylebox("panel")
	if current:
		_style_daily_ready = current
		_style_daily_claimed = current.duplicate()
		if _style_daily_claimed is StyleBoxFlat:
			var claimed := _style_daily_claimed as StyleBoxFlat
			claimed.bg_color = Color(0.55, 0.62, 0.56, 0.72)
			claimed.border_color = Color(0.176, 0.204, 0.212, 0.18)
			claimed.set_border_width_all(2)


func _process(delta: float) -> void:
	_chest_attention.tick(delta)
	_basket_attention.tick(delta)
	_chest_pulsing = _chest_attention.active


func _exit_tree() -> void:
	_stop_chest_pulse()
	_basket_attention.set_active(false)


func _refresh_menu() -> void:
	var hub := GameState.tutorial_complete
	tutorial_hint.visible = not hub
	play_button.label_text = "Play"
	_refresh_play_theme_badge()
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
	if decor_mound_left:
		decor_mound_left.visible = not open
	if decor_mound_right:
		decor_mound_right.visible = not open
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
		settings_button,
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


func _refresh_play_theme_badge() -> void:
	if play_theme_badge == null:
		return
	play_theme_badge.visible = false


func home_play_action() -> String:
	if GameState.home_season_field_open:
		return "run"
	if GameState.is_season_playable(GameState.home_hero_center_id()):
		return "open_field"
	return "snap"


func _on_play_pressed() -> void:
	var action := home_play_action()
	if action == "run":
		GameState.begin_campaign_run()
		SceneRouter.change_to(GameState.SCENE_RUN)
		return
	if action == "open_field":
		if season_stage and season_stage.has_method("open_season_field"):
			season_stage.call("open_season_field")
		return
	if season_stage and season_stage.has_method("snap_carousel_to_active"):
		season_stage.call("snap_carousel_to_active")


func _on_endless_play_pressed() -> void:
	if not GameState.home_season_field_open:
		return
	var field_id := GameState.home_season_field_id
	if not field_id.is_empty():
		GameState.set_active_season(field_id)
	GameState.begin_endless_run(GameState.EndlessDifficulty.HARD)
	SceneRouter.change_to(GameState.SCENE_RUN)


func _on_settings_pressed() -> void:
	if tutorial_hint:
		tutorial_hint.text = "Settings coming soon."
		tutorial_hint.visible = true


func _refresh_field_upgrades() -> void:
	if field_upgrade_stack == null:
		return
	var open := GameState.home_season_field_open
	field_upgrade_stack.visible = open
	if not open:
		return
	_layout_field_upgrades_below_settings()
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
	call_deferred("_layout_field_upgrades_below_settings")


func _layout_field_upgrades_below_settings() -> void:
	if field_upgrade_stack == null or settings_button == null:
		return
	if not field_upgrade_stack.visible:
		return
	var parent := field_upgrade_stack.get_parent() as Control
	if parent == null:
		return
	var below := settings_button.get_global_rect().end.y + 8.0
	var local_top := (parent.get_global_transform_with_canvas().affine_inverse() * Vector2(0.0, below)).y
	field_upgrade_stack.offset_top = local_top
	var min_h := field_upgrade_stack.get_combined_minimum_size().y
	if min_h < 80.0:
		min_h = 152.0
	field_upgrade_stack.offset_bottom = field_upgrade_stack.offset_top + min_h


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
		_stop_chest_pulse()
		return
	daily_chest_card.visible = true
	if GameState.can_claim_daily_chest():
		_chest_ui_state = ChestUiState.READY
		daily_title.text = "Daily gift"
		daily_caption.text = "Tap to open"
		if _style_daily_ready:
			daily_chest_card.add_theme_stylebox_override("panel", _style_daily_ready)
		if chest_visual:
			chest_visual.modulate = Color.WHITE
		_start_chest_pulse()
	else:
		_chest_ui_state = ChestUiState.CLAIMED
		daily_title.text = "Daily gift"
		daily_caption.text = "Back tomorrow"
		if _style_daily_claimed:
			daily_chest_card.add_theme_stylebox_override("panel", _style_daily_claimed)
		if chest_visual:
			chest_visual.modulate = Color(0.75, 0.75, 0.75, 1)
		_stop_chest_pulse()


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


func set_meta_hub_mode(_enabled: bool) -> void:
	# Bug-022: Settings stays on Home (top-right) in hub mode.
	if settings_button:
		settings_button.visible = true


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
			tutorial_hint.visible = true
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
