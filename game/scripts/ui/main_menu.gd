extends Control

const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const HomeBasketPickerIcon := preload("res://scripts/ui/home_basket_picker_icon.gd")
const UiAttention := preload("res://scripts/ui/ui_attention.gd")

const PICKER_ROW_MIN_HEIGHT := 148.0
const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const LOCKED_SEED_MODULATE := Color(0.45, 0.45, 0.45, 1)
## Biranje sezone: kolona 24 px od rubova, 23 px ispod Play reda (1394 + 180).
const SELECT_COLUMN_OFFSETS := Vector4(24, 24, -24, -23)
const FIELD_COLUMN_OFFSETS := Vector4(24, 24, -24, -24)
const FIELD_PLAY_SIZE := Vector2(656, 176)
const HINT_PAD := Vector2(27, 23)

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
@onready var daily_chest_card: HomeGiftCard = %DailyChestCard
@onready var stage_hint: HomeStageHint = %StageHint
@onready var background: ColorRect = $Background
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
@onready var season_name_chip: Control = %SeasonNameChip
@onready var field_top_row: HBoxContainer = %FieldTopRow
@onready var basket_button: UiClickButton = get_node_or_null("%BasketButton") as UiClickButton

var _chest_ui_state: ChestUiState = ChestUiState.LOCKED
var _play_disc: HomePlayDisc = null
var _basket_locked: bool = false
var _basket_attention: UiAttention = UiAttention.new()
var _upgrade_flash_kind: String = ""
var _magnet_effect: Label
var _magnet_level: Label
var _magnet_cost: Label
var _magnet_have: Label
var _loot_effect: Label
var _loot_level: Label
var _loot_cost: Label
var _loot_have: Label
var _field_blocks_docked: bool = false


func _ready() -> void:
	_dock_field_blocks()
	_ensure_upgrade_extras()
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
	if basket_button:
		basket_button.clicked.connect(_on_basket_pressed)
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
	UiCamp.style_label(tutorial_hint, 40, UiHomeField.OUTLINE, 0.38)
	tutorial_hint_panel.add_theme_stylebox_override(
		"panel", UiStage.pad(UiHomeField.tutorial_hint(), HINT_PAD.x, HINT_PAD.y, HINT_PAD.x, HINT_PAD.y)
	)
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
	pass


func _dock_field_blocks() -> void:
	if _field_blocks_docked or home_column == null:
		return
	_field_blocks_docked = true
	if seasons_row_button:
		seasons_row_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	if season_name_chip:
		season_name_chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		season_name_chip.layout_mode = 2


func play_field_chrome_in() -> void:
	var blocks: Array = []
	var play_row: Node = play_button.get_parent() if play_button else get_node_or_null("%PlayRow")
	for node in [field_top_row, home_top_stack, field_upgrade_stack, play_row]:
		if node is Control and (node as Control).visible:
			blocks.append(node)
	if not blocks.is_empty():
		UiHomeField.tween_chrome_in(blocks)



func _process(delta: float) -> void:
	_basket_attention.tick(delta)


func _exit_tree() -> void:
	_basket_attention.set_active(false)


func _refresh_menu() -> void:
	_refresh_tutorial_hint()
	refresh_play_chip()
	_refresh_basket_card()
	_refresh_field_upgrades()
	_refresh_endless_button()
	_refresh_seasons_row_button()
	if season_stage and season_stage.has_method("refresh"):
		season_stage.call("refresh")
	sync_field_backdrop()


## Prva sesija: na biranju sezone oblacic + prsten oko Play (StageHint), u polju
## sezone traka s porukom o korpi.
func _refresh_tutorial_hint() -> void:
	var first := not GameState.tutorial_complete
	var open := GameState.home_season_field_open
	if stage_hint:
		stage_hint.visible = first and not open
	if tutorial_hint and tutorial_hint_panel:
		tutorial_hint.text = "Merge your first flower in the Arena to unlock the basket."
		tutorial_hint_panel.visible = first and open


func sync_field_backdrop() -> void:
	var open := GameState.home_season_field_open
	if field_backdrop:
		field_backdrop.visible = open
		if open:
			field_backdrop.color = UiHomeField.PAGE_BG
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
		seasons_row_button,
		basket_card,
		play_row,
		play_button,
		endless_play_button,
		field_upgrade_stack,
		magnet_button,
		loot_boost_button,
		basket_picker_overlay,
	]:
		_set_block_hub_swipe(node as Control, open)
	_set_block_hub_swipe(season_name_chip, false)
	_set_block_hub_swipe(field_backdrop, false)
	if season_stage:
		var meadow: Control = season_stage.get_node_or_null("%SeasonField") as Control
		_set_block_hub_swipe(meadow, false)


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
		season_name_chip.set("label_text", "")
		season_name_chip.set("tagline_text", "")
		return
	var def: SeasonDef = GameState.get_season_def(GameState.home_season_field_id)
	season_name_chip.set("label_text", def.display_name if def else GameState.home_season_field_id)
	season_name_chip.set("tagline_text", def.tagline if def else "")


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
	seasons_row_button.visible = GameState.home_season_field_open
	if seasons_row_button.visible:
		seasons_row_button.custom_minimum_size = Vector2(UiHomeField.BACK_W, UiHomeField.TOP_ROW_H)
		seasons_row_button.add_theme_stylebox_override("panel", UiHomeField.back_button())
		seasons_row_button.label_text = "‹  Seasons"
		seasons_row_button.font_size = 46
		var back_label := seasons_row_button.get_node_or_null("ContentRow/Label") as Label
		if back_label:
			back_label.add_theme_color_override("font_color", UiHomeField.ACTIVE_RIM)


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


## Play na biranju sezone (SeasonStage.dc.html · PlayButton): 836 x 180, peach,
## cream disk s ▶, "Play" 72/900 i "run in {aktivna}" 38/800. U polju sezone
## (HOME-19) isto dugme dobija field izgled u _apply_play_layout().
func _setup_play_button() -> void:
	var row := play_button.get_node_or_null("ContentRow") as HBoxContainer
	if row == null:
		return
	_play_disc = HomePlayDisc.new()
	row.add_child(_play_disc)
	var camp_icon := row.get_node_or_null("CampIcon")
	row.move_child(_play_disc, camp_icon.get_index() if camp_icon else 0)
	play_button.set_text("Play")


func refresh_play_chip() -> void:
	var def: SeasonDef = GameState.get_season_def(GameState.active_season_id)
	var active_name := def.display_name if def else ""
	if play_button and not GameState.home_season_field_open:
		play_button.set_text("Play", "run in %s" % active_name)


func get_play_chip_text() -> String:
	if play_button == null:
		return ""
	var sub := play_button.get_sub()
	return sub.substr(7) if sub.begins_with("run in ") else sub


func _apply_mode_layout(field_open: bool) -> void:
	if field_top_row:
		field_top_row.visible = field_open
	if background:
		background.color = UiHomeField.PAGE_BG if field_open else UiStage.PAGE_BG
	if home_column:
		var o := FIELD_COLUMN_OFFSETS if field_open else SELECT_COLUMN_OFFSETS
		home_column.offset_left = o.x
		home_column.offset_top = o.y
		home_column.offset_right = o.z
		home_column.offset_bottom = o.w
		home_column.add_theme_constant_override(
			"separation", UiHomeField.BLOCK_GAP if field_open else UiStage.BLOCK_GAP
		)
	if season_stage:
		season_stage.custom_minimum_size.y = float(UiHomeField.MEADOW.y) if field_open else 0.0
	if home_top_stack:
		home_top_stack.visible = field_open
	_apply_play_layout(field_open)
	_refresh_chest_card()
	_refresh_tutorial_hint()


func _apply_play_layout(field_open: bool) -> void:
	if play_button == null:
		return
	var row := play_button.get_node_or_null("ContentRow") as HBoxContainer
	var col := play_button.get_text_column()
	var title := play_button.get_title_label()
	var sub := play_button.get_sub_label()
	if _play_disc:
		_play_disc.visible = not field_open
	if field_open:
		var show_endless := GameState.tutorial_complete
		play_button.custom_minimum_size = (
			FIELD_PLAY_SIZE if show_endless else Vector2(float(UiHomeField.MEADOW.x), float(UiHomeField.PLAY_ROW_H))
		)
		play_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if not show_endless else Control.SIZE_SHRINK_CENTER
		play_button.set_styles(UiHomeField.play_button(), UiHomeField.play_button())
		play_button.set_fonts(64, 38)
		play_button.set_ink(UiHomeField.INK)
		play_button.set_text("▶  Play")
		play_button.set_icon(null, 0.0)
		play_button.set_press_scale(1.0)
		if endless_play_button and endless_play_button.has_method("set_text"):
			endless_play_button.call("set_text", "Endless", "Hard · no finish line")
			endless_play_button.call("set_styles", UiHomeField.endless_button(), UiHomeField.endless_button())
			endless_play_button.call("set_fonts", 48, 38)
			endless_play_button.call("set_ink", UiHomeField.INK)
			endless_play_button.custom_minimum_size = Vector2(UiHomeField.ENDLESS_W, UiHomeField.PLAY_ROW_H)
		if row:
			row.alignment = BoxContainer.ALIGNMENT_CENTER
			row.add_theme_constant_override("separation", 14)
		if col:
			col.add_theme_constant_override("separation", 6)
		for label in [title, sub]:
			if label:
				(label as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		play_button.custom_minimum_size = Vector2(UiStage.PLAY_W, UiStage.PLAY_ROW.size.y)
		play_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var normal := UiStage.drop(
			UiStage.pad(UiStage.box(UiStage.PEACH, 32, 4, UiStage.PEACH_EDGE), 40, 4, 40, 4),
			UiStage.PEACH_DROP, 8.0
		)
		var pressed := normal.duplicate() as StyleBoxFlat
		pressed.bg_color = UiStage.PEACH.darkened(0.06)
		play_button.set_styles(normal, pressed)
		play_button.set_icon(null, 0.0)
		var def: SeasonDef = GameState.get_season_def(GameState.active_season_id)
		var active_name := def.display_name if def else ""
		play_button.set_text("Play", "run in %s" % active_name)
		if title:
			UiStage.style(title, 900, 72, UiStage.INK)
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		if sub:
			UiStage.style(sub, 800, 38, UiStage.INK)
			sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		play_button.set_press_scale(0.97)
		if row:
			row.alignment = BoxContainer.ALIGNMENT_BEGIN
			row.add_theme_constant_override("separation", 30)
		if col:
			col.add_theme_constant_override("separation", 10)


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
	_ensure_upgrade_extras()
	var flower_id := GameState.pick_upgrade_flower_type("")
	var flower_name := GameState.get_seed_display_name(flower_id) if not flower_id.is_empty() else ""
	var have := int(GameState.garden_crystal_stash.get(flower_id, 0)) if not flower_id.is_empty() else 0
	_apply_upgrade_card(
		"magnet",
		magnet_button,
		magnet_title,
		_magnet_level,
		_magnet_effect,
		_magnet_cost,
		_magnet_have,
		GameState.magnet_level,
		GameState.MAGNET_MAX_LEVEL,
		UiHomeField.magnet_effect(GameState.magnet_level),
		flower_name,
		have
	)
	_apply_upgrade_card(
		"loot",
		loot_boost_button,
		loot_boost_title,
		_loot_level,
		_loot_effect,
		_loot_cost,
		_loot_have,
		GameState.multiplier_level,
		GameState.MULTIPLIER_MAX_LEVEL,
		UiHomeField.loot_effect(GameState.multiplier_level),
		flower_name,
		have
	)


func _ensure_upgrade_extras() -> void:
	_magnet_level = _ensure_extra_label(magnet_title, "MagnetLevel", _magnet_level)
	_magnet_effect = _ensure_extra_label(magnet_title, "MagnetEffect", _magnet_effect)
	_magnet_cost = _ensure_extra_label(magnet_title, "MagnetCost", _magnet_cost)
	_magnet_have = _ensure_extra_label(magnet_title, "MagnetHave", _magnet_have)
	_loot_level = _ensure_extra_label(loot_boost_title, "LootLevel", _loot_level)
	_loot_effect = _ensure_extra_label(loot_boost_title, "LootEffect", _loot_effect)
	_loot_cost = _ensure_extra_label(loot_boost_title, "LootCost", _loot_cost)
	_loot_have = _ensure_extra_label(loot_boost_title, "LootHave", _loot_have)


func _ensure_extra_label(after: Label, extra_name: String, existing: Label) -> Label:
	if existing:
		return existing
	if after == null or after.get_parent() == null:
		return null
	var found := after.get_parent().get_node_or_null(extra_name) as Label
	if found:
		return found
	var lab := Label.new()
	lab.name = extra_name
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	after.get_parent().add_child(lab)
	after.get_parent().move_child(lab, after.get_index() + 1)
	return lab


func _apply_upgrade_card(
	kind: String,
	btn: UiClickButton,
	title: Label,
	level_lab: Label,
	effect_lab: Label,
	cost_lab: Label,
	have_lab: Label,
	level: int,
	max_level: int,
	effect: String,
	flower_name: String,
	have: int
) -> void:
	var maxed := level >= max_level
	var ready := not maxed and have >= GameState.UPGRADE_FLOWER_COST
	var state := "maxed" if maxed else ("ready" if ready else "blocked")
	var flash := _upgrade_flash_kind == kind
	if field_upgrade_stack:
		var row_btn: Control = magnet_button if kind == "magnet" else loot_boost_button
		var row: Control = (
			row_btn.get_parent().get_parent() as Control
			if row_btn and row_btn.get_parent()
			else null
		)
		if row:
			row.custom_minimum_size.y = float(UiHomeField.UPGRADE_H)
			if row is PanelContainer:
				(row as PanelContainer).add_theme_stylebox_override("panel", UiHomeField.upgrade_card(flash))
	if title:
		UiCamp.style_label(title, 38, UiHomeField.ACTIVE_RIM, 0.38)
	if level_lab:
		level_lab.text = UiHomeField.level_text(level)
		level_lab.add_theme_font_size_override("font_size", 36)
		level_lab.add_theme_color_override("font_color", UiHomeField.INK if flash else UiHomeField.ACTIVE_RIM)
		level_lab.add_theme_stylebox_override("normal", UiHomeField.upgrade_level(flash))
	if effect_lab:
		effect_lab.text = effect
		effect_lab.add_theme_font_size_override("font_size", 32)
		effect_lab.add_theme_color_override("font_color", UiHomeField.SUB_ON_DARK)
	if cost_lab:
		if maxed:
			cost_lab.text = "Nothing left to buy"
		elif flash:
			cost_lab.text = "Spent 2 × %s" % flower_name
		else:
			cost_lab.text = UiHomeField.cost_text(flower_name)
		cost_lab.add_theme_font_size_override("font_size", 32)
		cost_lab.add_theme_color_override("font_color", UiHomeField.ACTIVE_RIM)
	if have_lab:
		var have_txt := "" if maxed or ready else UiHomeField.have_text(have)
		have_lab.text = have_txt
		have_lab.visible = not have_txt.is_empty()
		have_lab.add_theme_font_size_override("font_size", 28)
		have_lab.add_theme_color_override("font_color", UiHomeField.DISABLED_INK)
	if btn:
		btn.label_text = UiHomeField.upgrade_button_label(state, have)
		btn.font_size = 48
		btn.disabled = not ready
		btn.add_theme_stylebox_override("panel", UiHomeField.upgrade_button(state))
		if btn.has_method("set_ink"):
			btn.call("set_ink", UiHomeField.upgrade_button_ink(state))


func _on_field_magnet_pressed() -> void:
	if not GameState.home_season_field_open:
		return
	if GameState.try_upgrade_magnet(""):
		_flash_upgrade("magnet")
	_refresh_field_upgrades()
	_notify_hub_chrome()


func _on_field_loot_boost_pressed() -> void:
	if not GameState.home_season_field_open:
		return
	if GameState.try_upgrade_multiplier(""):
		_flash_upgrade("loot")
	_refresh_field_upgrades()
	_notify_hub_chrome()


func _flash_upgrade(kind: String) -> void:
	_upgrade_flash_kind = kind
	var tw := create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(func() -> void:
		_upgrade_flash_kind = ""
		_refresh_field_upgrades()
	)


func _refresh_chest_card() -> void:
	if daily_chest_card == null:
		return
	if _chest_ui_state == ChestUiState.OPENING:
		return
	if GameState.home_season_field_open:
		daily_chest_card.visible = false
		return
	daily_chest_card.visible = true
	if not GameState.tutorial_complete:
		_chest_ui_state = ChestUiState.LOCKED
		daily_chest_card.claimable = false
		return
	if GameState.can_claim_daily_chest():
		_chest_ui_state = ChestUiState.READY
		daily_chest_card.claimable = true
	else:
		_chest_ui_state = ChestUiState.CLAIMED
		daily_chest_card.claimable = false


## Roze tacka na Gift kartici = poklon ceka (DailyGiftCard u dizajnu).
func is_gift_claimable() -> bool:
	return daily_chest_card != null and daily_chest_card.visible and daily_chest_card.claimable


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
	daily_chest_card.claimable = false
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
	basket_card.custom_minimum_size = Vector2(0, UiHomeField.BASKET_H)
	_basket_locked = not GameState.loadout_enabled()
	var type_id := GameState.get_loadout_type()
	var state := "locked" if _basket_locked else ("empty" if type_id.is_empty() else "chosen")
	basket_card.add_theme_stylebox_override("panel", UiHomeField.basket_card(state))
	if basket_button:
		basket_button.visible = not _basket_locked
		basket_button.label_text = "Choose" if type_id.is_empty() else "Change"
		basket_button.add_theme_stylebox_override("panel", UiHomeField.basket_button(state == "chosen"))
	if _basket_locked:
		if basket_title:
			basket_title.text = "Basket locked"
		if basket_caption:
			basket_caption.text = "Unlock after your first merge"
		if basket_visual and basket_visual.has_method("set_loadout_type"):
			basket_visual.call("set_loadout_type", "")
		_sync_basket_attention()
		basket_card.modulate = Color.WHITE
		return
	_sync_basket_attention()
	basket_card.modulate = Color.WHITE
	if type_id.is_empty():
		if basket_title:
			basket_title.text = "Tap to choose"
		if basket_caption:
			basket_caption.text = "One seed falls 5 % more often"
		if basket_visual and basket_visual.has_method("set_loadout_type"):
			basket_visual.call("set_loadout_type", "")
	else:
		var seed_name: String = GameState.get_seed_display_name(type_id)
		var stars := UiHomeField.rarity_pips(GameState.get_seed_rarity(type_id))
		if basket_title:
			basket_title.text = "%s  %s" % [seed_name, stars]
		if basket_caption:
			basket_caption.text = "Falls 5 % more often this run"
		if basket_visual and basket_visual.has_method("set_loadout_type"):
			basket_visual.call("set_loadout_type", type_id)
	if basket_title:
		basket_title.add_theme_font_size_override("font_size", 52)
		basket_title.add_theme_color_override("font_color", UiHomeField.ACTIVE_RIM)
	if basket_caption:
		basket_caption.add_theme_font_size_override("font_size", 38)
		basket_caption.add_theme_color_override("font_color", UiHomeField.SUB_ON_DARK)
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
	picker_panel.add_theme_stylebox_override("panel", UiHomeField.picker_sheet())
	picker_panel.anchor_left = 0.0
	picker_panel.anchor_right = 1.0
	picker_panel.anchor_top = 1.0
	picker_panel.anchor_bottom = 1.0
	picker_panel.offset_left = 0.0
	picker_panel.offset_right = 0.0
	picker_panel.offset_top = -float(UiHomeField.SHEET_H)
	picker_panel.offset_bottom = 0.0
	if picker_clear_button:
		picker_clear_button.custom_minimum_size.y = 132.0
		picker_clear_button.font_size = 46
	if picker_close_button:
		picker_close_button.custom_minimum_size.y = 132.0
		picker_close_button.font_size = 46
	var title := picker_panel.get_node_or_null("PickerVBox/PickerTitle") as Label
	if title:
		title.add_theme_font_size_override("font_size", 56)
		title.add_theme_color_override("font_color", UiHomeField.ACTIVE_RIM)


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
