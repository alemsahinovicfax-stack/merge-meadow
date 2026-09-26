extends Control

const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const HomeBasketPickerIcon := preload("res://scripts/ui/home_basket_picker_icon.gd")

const PICKER_ROW_MIN_HEIGHT := 148.0
const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const LOCKED_SEED_MODULATE := Color(0.45, 0.45, 0.45, 1)
## Biranje sezone: kolona 24 px od rubova, 23 px ispod Play reda (1430 + 180).
const SELECT_COLUMN_OFFSETS := Vector4(24, 24, -24, -23)
## v2: u polju kolona pokriva cijelu stranicu — livada je pozadina, ne prozor.
const FIELD_COLUMN_OFFSETS := Vector4(0, 0, 0, 0)
const FIELD_PLAY_SIZE := Vector2(656, 176)
const HINT_PAD := Vector2(27, 23)

enum ChestUiState { LOCKED, READY, OPENING, CLAIMED }

@onready var tutorial_hint: Label = %TutorialHint
@onready var tutorial_hint_panel: PanelContainer = %TutorialHintPanel
@onready var field_overlay: Control = %FieldOverlay
@onready var season_label: Label = %SeasonLabel
@onready var grown_chip: PanelContainer = %GrownChip
@onready var grown_count: Label = %Count
@onready var gift_chest: HomeGiftCard = %GiftChest
@onready var field_basket: FieldBasketButton = %BasketButton
@onready var upgrades_button: FieldUpgradesButton = %UpgradesButton
@onready var bottom_row: Control = %BottomRow
@onready var field_play_button: CampButton = %FieldPlayButton
@onready var upgrades_overlay: Control = %UpgradesOverlay
@onready var upgrades_panel: PanelContainer = %UpgradesPanel
@onready var upgrades_vbox: VBoxContainer = %UpgradesVBox
@onready var upgrades_title: Label = %UpgradesTitle
@onready var upgrades_sub: Label = %UpgradesSub
@onready var upgrades_close_button: UiClickButton = %UpgradesCloseButton
@onready var magnet_title: Label = %MagnetTitle
@onready var magnet_button: UiClickButton = %MagnetButton
@onready var loot_boost_title: Label = %LootBoostTitle
@onready var loot_boost_button: UiClickButton = %LootBoostButton
@onready var home_column: VBoxContainer = %HomeColumn
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

var _chest_ui_state: ChestUiState = ChestUiState.LOCKED
var _play_disc: HomePlayDisc = null
var _basket_locked: bool = false
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
	if field_play_button:
		field_play_button.clicked.connect(_on_play_pressed)
	endless_play_button.clicked.connect(_on_endless_play_pressed)
	if seasons_row_button:
		seasons_row_button.clicked.connect(_on_seasons_row_pressed)
	if upgrades_button:
		upgrades_button.clicked.connect(_open_upgrades_sheet)
	if upgrades_close_button:
		upgrades_close_button.clicked.connect(_close_upgrades_sheet)
	if upgrades_overlay:
		var up_dim := upgrades_overlay.get_node_or_null("Dim") as Control
		if up_dim:
			up_dim.gui_input.connect(_on_upgrades_dim_gui_input)
	if gift_chest:
		gift_chest.gui_input.connect(_on_daily_chest_gui_input)
		gift_chest.drop = true
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
	if field_basket:
		field_basket.clicked.connect(_on_basket_pressed)
	_bind_meadow_signal()
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


## v2: raspored polja je apsolutan u FieldOverlayu, pa se u VBoxu nema sta dokirati.
func _dock_field_blocks() -> void:
	_field_blocks_docked = true


## Redoslijed iz handoffa: Play, Seasons, Endless, Gift, Basket, Upgrades, ime + cip.
## `from_top` kaze klizi li element odozgo (gornja grupa) ili odozdo (donji red).
func play_field_chrome_in() -> void:
	var items: Array = []
	var from_top: Array = []
	for pair in [
		[field_play_button, false], [seasons_row_button, false], [endless_play_button, false],
		[gift_chest, true], [field_basket, true], [upgrades_button, true],
		[season_label, true], [grown_chip, true],
	]:
		var node: Control = pair[0] as Control
		if node and node.visible:
			items.append(node)
			from_top.append(bool(pair[1]))
	if not items.is_empty():
		UiHomeField.tween_chrome_in(items, from_top)



func _exit_tree() -> void:
	if field_basket:
		field_basket.stop_attention()


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
		field_basket,
		gift_chest,
		upgrades_button,
		bottom_row,
		field_play_button,
		play_row,
		play_button,
		endless_play_button,
		basket_picker_overlay,
		upgrades_overlay,
	]:
		_set_block_hub_swipe(node as Control, open)
	# Ime i cip su info — swipe mora proci kroz njih.
	_set_block_hub_swipe(season_label, false)
	_set_block_hub_swipe(grown_chip, false)
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


## v2: ime sezone je Label na nebu; tagline otpada (stoji na kartici jedan tap nazad).
func _refresh_season_name_chip() -> void:
	if season_label == null:
		return
	if not GameState.home_season_field_open:
		season_label.text = ""
		return
	var def: SeasonDef = GameState.get_season_def(GameState.home_season_field_id)
	season_label.text = def.display_name if def else GameState.home_season_field_id


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


## v2: u polju kolona nestaje s puta (offseti 0) pa livada uzima cijelu stranicu,
## a sve kontrole zive u FieldOverlayu na apsolutnim pozicijama.
func _apply_mode_layout(field_open: bool) -> void:
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
		season_stage.custom_minimum_size.y = float(UiHomeField.MEADOW.size.y) if field_open else 0.0
	var play_row: Control = get_node_or_null("%PlayRow") as Control
	if play_row:
		play_row.visible = not field_open
	if field_overlay:
		field_overlay.visible = field_open
	if not field_open:
		_close_upgrades_sheet()
	_apply_field_overlay_styles()
	_apply_play_layout(field_open)
	_refresh_chest_card()
	_refresh_tutorial_hint()
	_refresh_upgrades_button()
	_refresh_grown_chip()


## Stilovi naljepnica — postavljaju se jednom po ulasku, boje ne ovise o sezoni.
func _apply_field_overlay_styles() -> void:
	if field_overlay == null or not field_overlay.visible:
		return
	if season_label:
		season_label.add_theme_font_override("font", UiStage.font(900, 56))
	if grown_chip:
		grown_chip.add_theme_stylebox_override(
			"panel", UiStage.pad(UiHomeField.grown_chip(), 26, 14, 26, 14)
		)
		var icon := grown_chip.get_node_or_null("Row/Icon") as TextureRect
		if icon and icon.texture == null:
			icon.texture = UiAssets.get_chrome_icon("icon_flower")
		if grown_count:
			grown_count.add_theme_font_override("font", UiStage.font(900, 44))
		var word := grown_chip.get_node_or_null("Row/Word") as Label
		if word:
			word.add_theme_font_override("font", UiStage.font(800, 38))
	if tutorial_hint_panel:
		tutorial_hint_panel.add_theme_stylebox_override(
			"panel", UiStage.pad(UiHomeField.tutorial_hint(), HINT_PAD.x, HINT_PAD.y, HINT_PAD.x, HINT_PAD.y)
		)


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
		_style_field_bottom_row()
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


## Donji red: Seasons 236 x 124 · Play 432 x 140 (centar x 540) · Endless 236 x 124.
func _style_field_bottom_row() -> void:
	if field_play_button:
		field_play_button.custom_minimum_size = Vector2(UiHomeField.PLAY_BTN.size)
		field_play_button.set_styles(
			UiHomeField.play_button(), UiHomeField.pressed_sticker(UiHomeField.play_button())
		)
		field_play_button.set_fonts(60, 38)
		field_play_button.set_ink(UiHomeField.INK)
		field_play_button.set_text("Play")
		field_play_button.set_icon(null, 0.0)
		field_play_button.set_press_scale(1.0)
		var f_title := field_play_button.get_title_label()
		if f_title:
			f_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			f_title.add_theme_font_override("font", UiStage.font(900, 60))
	if seasons_row_button:
		seasons_row_button.custom_minimum_size = Vector2(UiHomeField.SEASONS_BTN.size)
		seasons_row_button.add_theme_stylebox_override("panel", UiHomeField.seasons_button())
		seasons_row_button.label_text = "‹  Seasons"
		seasons_row_button.font_size = 40
		var back_label := seasons_row_button.get_node_or_null("ContentRow/Label") as Label
		if back_label:
			back_label.add_theme_font_override("font", UiStage.font(800, 40))
			back_label.add_theme_color_override("font_color", UiHomeField.INK)
	if endless_play_button:
		endless_play_button.custom_minimum_size = Vector2(UiHomeField.ENDLESS_BTN.size)
		endless_play_button.add_theme_stylebox_override("panel", UiHomeField.endless_button())
		endless_play_button.label_text = "∞  Endless"
		endless_play_button.font_size = 40
		var e_label := endless_play_button.get_node_or_null("ContentRow/Label") as Label
		if e_label:
			e_label.add_theme_font_override("font", UiStage.font(800, 40))
			e_label.add_theme_color_override("font_color", UiHomeField.INK)


func _on_endless_play_pressed() -> void:
	if not GameState.home_season_field_open:
		return
	var field_id := GameState.home_season_field_id
	if not field_id.is_empty():
		GameState.set_active_season(field_id)
	GameState.begin_endless_run(GameState.EndlessDifficulty.HARD)
	SceneRouter.change_to(GameState.SCENE_RUN)


func _refresh_field_upgrades() -> void:
	if upgrades_vbox == null:
		return
	_refresh_upgrades_button()
	if not GameState.home_season_field_open:
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


## Svaki novi red ide ODMAH iza naslova, pa je redoslijed poziva obrnut od
## redoslijeda na ekranu: naslov · Lv N / 4 · 4 segmenta · efekat · cijena.
func _ensure_upgrade_extras() -> void:
	_magnet_have = _ensure_extra_label(magnet_title, "MagnetHave", _magnet_have)
	_magnet_cost = _ensure_extra_label(magnet_title, "MagnetCost", _magnet_cost)
	_magnet_effect = _ensure_extra_label(magnet_title, "MagnetEffect", _magnet_effect)
	_ensure_segment_row(magnet_title, "MagnetSegments")
	_magnet_level = _ensure_extra_label(magnet_title, "MagnetLevel", _magnet_level)
	_loot_have = _ensure_extra_label(loot_boost_title, "LootHave", _loot_have)
	_loot_cost = _ensure_extra_label(loot_boost_title, "LootCost", _loot_cost)
	_loot_effect = _ensure_extra_label(loot_boost_title, "LootEffect", _loot_effect)
	_ensure_segment_row(loot_boost_title, "LootSegments")
	_loot_level = _ensure_extra_label(loot_boost_title, "LootLevel", _loot_level)


## Cetiri segmenta 64 x 18 ispod naslova — nivo se vidi i bez citanja.
func _ensure_segment_row(after: Label, row_name: String) -> HBoxContainer:
	if after == null or after.get_parent() == null:
		return null
	var found := after.get_parent().get_node_or_null(row_name) as HBoxContainer
	if found:
		return found
	var row := HBoxContainer.new()
	row.name = row_name
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	for i in UiHomeField.UPGRADE_MAX_LEVEL:
		var seg := Panel.new()
		seg.name = "Seg_%d" % i
		seg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		seg.custom_minimum_size = Vector2(UiHomeField.UPGRADE_SEG)
		row.add_child(seg)
	after.get_parent().add_child(row)
	after.get_parent().move_child(row, after.get_index() + 1)
	return row


func _paint_segments(title: Label, row_name: String, level: int) -> void:
	if title == null or title.get_parent() == null:
		return
	var row := title.get_parent().get_node_or_null(row_name) as HBoxContainer
	if row == null:
		return
	for i in row.get_child_count():
		var seg := row.get_child(i) as Panel
		if seg:
			seg.add_theme_stylebox_override("panel", UiHomeField.upgrade_segment(i < level))


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
	if upgrades_vbox:
		var row_btn: Control = magnet_button if kind == "magnet" else loot_boost_button
		var row: Control = (
			row_btn.get_parent().get_parent() as Control
			if row_btn and row_btn.get_parent()
			else null
		)
		if row:
			row.custom_minimum_size = Vector2(UiHomeField.UPGRADE_CARD)
			if row is PanelContainer:
				(row as PanelContainer).add_theme_stylebox_override("panel", UiHomeField.upgrade_card(flash))
	if title:
		title.text = "Magnet" if kind == "magnet" else "Loot Boost"
		title.add_theme_font_override("font", UiStage.font(900, 52))
		title.add_theme_font_size_override("font_size", 52)
		title.add_theme_color_override("font_color", UiHomeField.INK)
	_paint_segments(title, "MagnetSegments" if kind == "magnet" else "LootSegments", level)
	if level_lab:
		level_lab.text = UiHomeField.level_text(level)
		level_lab.add_theme_font_override("font", UiStage.font(900, 44))
		level_lab.add_theme_font_size_override("font_size", 44)
		level_lab.add_theme_color_override("font_color", UiHomeField.INK)
		level_lab.add_theme_stylebox_override("normal", UiHomeField.upgrade_level(flash))
	if effect_lab:
		effect_lab.text = effect
		effect_lab.add_theme_font_override("font", UiStage.font(800, 44))
		effect_lab.add_theme_font_size_override("font_size", 44)
		effect_lab.add_theme_color_override("font_color", UiHomeField.INK_SOFT)
	if cost_lab:
		if maxed:
			cost_lab.text = "Nothing left to buy"
		elif flash:
			cost_lab.text = "Spent 2 × %s" % flower_name
		else:
			cost_lab.text = UiHomeField.cost_text(flower_name)
		cost_lab.add_theme_font_override("font", UiStage.font(800, 44))
		cost_lab.add_theme_font_size_override("font_size", 44)
		cost_lab.add_theme_color_override("font_color", UiHomeField.INK)
	# v2: cip "you have N" otpada — razlog vec pise na dugmetu ("Need N").
	if have_lab:
		have_lab.visible = false
	if btn:
		btn.label_text = UiHomeField.upgrade_button_label(state, have)
		btn.font_size = 44
		btn.custom_minimum_size = Vector2(UiHomeField.UPGRADE_BTN)
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
	# v2: poklon se vidi i u polju — gornja lijeva plocica iznad korpe.
	var field_open := GameState.home_season_field_open
	daily_chest_card.visible = not field_open
	if gift_chest:
		gift_chest.visible = field_open
	var claimable := false
	if not GameState.tutorial_complete:
		_chest_ui_state = ChestUiState.LOCKED
	elif GameState.can_claim_daily_chest():
		_chest_ui_state = ChestUiState.READY
		claimable = true
	else:
		_chest_ui_state = ChestUiState.CLAIMED
	daily_chest_card.claimable = claimable
	if gift_chest:
		gift_chest.claimable = claimable


## Roze tacka na Gift kartici = poklon ceka (DailyGiftCard u dizajnu).
func is_gift_claimable() -> bool:
	if GameState.home_season_field_open:
		return gift_chest != null and gift_chest.visible and gift_chest.claimable
	return daily_chest_card != null and daily_chest_card.visible and daily_chest_card.claimable


func is_basket_attention_active() -> bool:
	return field_basket != null and field_basket.is_attention_running()


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


## v2: korpa je plocica 180 ispod Gifta; +5 % stoji na njoj, ne samo u pickeru.
func _refresh_basket_card() -> void:
	if field_basket == null:
		return
	_basket_locked = not GameState.loadout_enabled()
	var type_id := GameState.get_loadout_type()
	var state := "locked" if _basket_locked else ("empty" if type_id.is_empty() else "chosen")
	field_basket.apply_state(state, type_id)
	if not GameState.home_season_field_open:
		field_basket.stop_attention()


func _sync_basket_attention() -> void:
	if field_basket == null:
		return
	if not GameState.home_season_field_open:
		field_basket.stop_attention()


func _on_basket_pressed() -> void:
	if _basket_locked or not GameState.loadout_enabled():
		if field_basket:
			field_basket.shake()
		if tutorial_hint and tutorial_hint_panel:
			tutorial_hint.text = "Merge your first flower in the Arena to unlock the basket."
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
	picker_panel.offset_top = -float(UiHomeField.SHEET_BASKET_H)
	picker_panel.offset_bottom = 0.0
	if picker_clear_button:
		picker_clear_button.custom_minimum_size.y = 132.0
		picker_clear_button.font_size = 46
	if picker_close_button:
		picker_close_button.custom_minimum_size.y = 132.0
		picker_close_button.font_size = 46
	var title := picker_panel.get_node_or_null("PickerVBox/PickerTitle") as Label
	if title:
		title.text = "Basket seed"
		title.add_theme_font_override("font", UiStage.font(900, 56))
		title.add_theme_font_size_override("font_size", 56)
		title.add_theme_color_override("font_color", UiHomeField.INK)
	var dim := basket_picker_overlay.get_node_or_null("Dim") as ColorRect if basket_picker_overlay else null
	if dim:
		dim.color = UiHomeField.SCRIM


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


## ── Polje v2: cip izraslih, ulaz u nadogradnje, sheet ────────────────────────

func _bind_meadow_signal() -> void:
	if season_stage == null:
		return
	var meadow := season_stage.get_node_or_null("%SeasonField")
	if meadow == null or not meadow.has_signal("grown_changed"):
		return
	if not meadow.is_connected("grown_changed", _on_meadow_grown_changed):
		meadow.connect("grown_changed", _on_meadow_grown_changed)


func _on_meadow_grown_changed(grown: int, total: int) -> void:
	_set_grown_text(grown, total)


func _refresh_grown_chip() -> void:
	if grown_chip == null:
		return
	grown_chip.visible = GameState.home_season_field_open
	if not grown_chip.visible:
		return
	var grown := 0
	if season_stage:
		var meadow := season_stage.get_node_or_null("%SeasonField")
		if meadow and meadow.has_method("get_meadow_grown_count"):
			grown = int(meadow.call("get_meadow_grown_count"))
	_set_grown_text(grown, UiHomeField.MEADOW_SPOTS.size())


func _set_grown_text(grown: int, total: int) -> void:
	if grown_count:
		grown_count.text = "%d / %d" % [grown, total]
	_center_grown_chip()


## Cip je centriran na x 540 — sirina ovisi o broju, pa se racuna poslije teksta.
func _center_grown_chip() -> void:
	if grown_chip == null or not grown_chip.visible:
		return
	var w := grown_chip.get_combined_minimum_size().x
	# Godot jos nije prelomio red kad stigne prvi refresh.
	if w < 40.0:
		await get_tree().process_frame
		if grown_chip == null or not is_instance_valid(grown_chip):
			return
		w = grown_chip.get_combined_minimum_size().x
	grown_chip.size = Vector2(w, UiHomeField.GROWN_CHIP_H)
	grown_chip.position = Vector2(540.0 - w * 0.5, float(UiHomeField.GROWN_CHIP_Y))


## Zlatna tacka = bar jedna nadogradnja se moze kupiti sada.
func _refresh_upgrades_button() -> void:
	if upgrades_button == null:
		return
	upgrades_button.visible = GameState.home_season_field_open
	if not upgrades_button.visible:
		return
	var flower_id := GameState.pick_upgrade_flower_type("")
	var have := int(GameState.garden_crystal_stash.get(flower_id, 0)) if not flower_id.is_empty() else 0
	var room := (
		GameState.magnet_level < GameState.MAGNET_MAX_LEVEL
		or GameState.multiplier_level < GameState.MULTIPLIER_MAX_LEVEL
	)
	upgrades_button.set_levels(
		GameState.magnet_level,
		GameState.multiplier_level,
		room and have >= GameState.UPGRADE_FLOWER_COST
	)


func _open_upgrades_sheet() -> void:
	if not GameState.home_season_field_open or upgrades_overlay == null:
		return
	_fit_upgrades_panel()
	_refresh_field_upgrades()
	upgrades_overlay.visible = true


func _close_upgrades_sheet() -> void:
	if upgrades_overlay:
		upgrades_overlay.visible = false


func _on_upgrades_dim_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if tapped:
		_close_upgrades_sheet()


func _fit_upgrades_panel() -> void:
	if upgrades_panel == null:
		return
	upgrades_panel.add_theme_stylebox_override(
		"panel", UiStage.pad(UiHomeField.picker_sheet(), 24, 20, 24, 28)
	)
	upgrades_panel.offset_top = -float(UiHomeField.SHEET_UPGRADES_H)
	if upgrades_title:
		upgrades_title.add_theme_font_override("font", UiStage.font(900, 56))
		upgrades_title.add_theme_color_override("font_color", UiHomeField.INK)
	if upgrades_sub:
		upgrades_sub.add_theme_font_override("font", UiStage.font(800, 40))
		upgrades_sub.add_theme_color_override("font_color", UiHomeField.INK_SOFT)
	if upgrades_close_button:
		upgrades_close_button.custom_minimum_size.y = 132.0
		upgrades_close_button.font_size = 44
		upgrades_close_button.add_theme_stylebox_override("panel", UiHomeField.seasons_button())
	var dim := upgrades_overlay.get_node_or_null("Dim") as ColorRect if upgrades_overlay else null
	if dim:
		dim.color = UiHomeField.SCRIM


func _on_basket_type_picked(type_id: String) -> void:
	if GameState.set_loadout(type_id):
		_refresh_basket_card()
		_close_basket_picker()
