extends Control

const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const HomeBasketPickerIcon := preload("res://scripts/ui/home_basket_picker_icon.gd")

const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const SHEET_PAD := Vector4(24, 24, 24, 28)   # lijevo, gore, desno, dolje (design_handoff_popups)

enum ChestUiState { LOCKED, READY, OPENING, CLAIMED }

@onready var tutorial_hint_panel: Control = %TutorialHintPanel
@onready var field_overlay: Control = %FieldOverlay
@onready var field_overlay_inner: Control = %FieldOverlayInner
@onready var top_chrome: Control = %TopChrome
@onready var grown_chip: PanelContainer = %GrownChip
@onready var grown_count: Label = %Count
@onready var gift_chest: HomeGiftCard = %GiftChest
@onready var field_basket: FieldBasketButton = %BasketButton
@onready var upgrades_button: FieldUpgradesButton = %UpgradesButton
@onready var bottom_row: Control = %BottomRow
@onready var upgrades_overlay: Control = %UpgradesOverlay
@onready var upgrades_panel: PanelContainer = %UpgradesPanel
@onready var upgrades_vbox: VBoxContainer = %UpgradesVBox
@onready var upgrades_title: Label = %UpgradesTitle
@onready var upgrades_close_button: PopupButton = %UpgradesCloseButton
@onready var magnet_title: Label = %MagnetTitle
@onready var magnet_button: PopupButton = %MagnetButton
@onready var loot_boost_title: Label = %LootBoostTitle
@onready var loot_boost_button: PopupButton = %LootBoostButton
@onready var seasons_row_button: UiClickButton = %SeasonsRowButton
@onready var endless_play_button: UiClickButton = %EndlessPlayButton
@onready var stage_hint: HomeStageHint = %StageHint
@onready var background: ColorRect = $Background
@onready var basket_picker_overlay: Control = %BasketPickerOverlay
@onready var picker_panel: PanelContainer = %PickerPanel
@onready var picker_list: GridContainer = %PickerList
@onready var picker_footer: HBoxContainer = %PickerFooter
@onready var picker_clear_button: PopupButton = %PickerClearButton
@onready var picker_close_button: PopupButton = %PickerCloseButton
@onready var season_stage: Control = %SeasonStage

var _chest_ui_state: ChestUiState = ChestUiState.LOCKED
var _transition_blocker: Control
var _basket_locked: bool = false
var _upgrade_flash_kind: String = ""
var _magnet_effect: Label
var _twin_title: Label
var _twin_button: PopupButton
var _twin_effect: Label
var _loot_effect: Label
## H3 · poklon (PopupModal „RewardOverlay"), H2 · oblačić na korpi.
var reward_overlay: PopupModal
var _gift_button: PopupButton
var _basket_hint: CoachBubble
var _sheet_drag: Dictionary = {}
## Ormar (design_handoff_wardrobe)
var wardrobe_button: FieldWardrobeButton
var wardrobe_sheet: WardrobeSheet
var _apply_toast: ApplyToast


func _ready() -> void:
	_ensure_upgrade_extras()
	_ensure_wardrobe()
	_ensure_transition_blocker()
	if season_stage:
		season_stage.connect("play_run_requested", _start_run)
		season_stage.call("bind_field_chrome", {
			"overlay": field_overlay,
			"inner": field_overlay_inner,
			"top": top_chrome,
			"seasons": seasons_row_button,
			"endless": endless_play_button,
			"hint": tutorial_hint_panel,
		})
	endless_play_button.clicked.connect(_on_endless_play_pressed)
	if seasons_row_button:
		seasons_row_button.clicked.connect(_on_seasons_row_pressed)
	if upgrades_button:
		upgrades_button.clicked.connect(_open_upgrades_sheet)
	if upgrades_close_button:
		upgrades_close_button.clicked.connect(_dismiss_sheet.bind(upgrades_panel, _close_upgrades_sheet))
	if upgrades_overlay:
		var up_dim := upgrades_overlay.get_node_or_null("Dim") as Control
		if up_dim:
			up_dim.gui_input.connect(_on_upgrades_dim_gui_input)
		upgrades_panel.gui_input.connect(_on_sheet_drag.bind(upgrades_panel, _close_upgrades_sheet))
	if gift_chest:
		gift_chest.gui_input.connect(_on_daily_chest_gui_input)
		gift_chest.drop = true
	if picker_clear_button:
		picker_clear_button.clicked.connect(_on_basket_clear_picked)
	if picker_close_button:
		picker_close_button.clicked.connect(_dismiss_sheet.bind(picker_panel, _close_basket_picker))
	if basket_picker_overlay:
		var dim := basket_picker_overlay.get_node_or_null("Dim") as Control
		if dim:
			dim.gui_input.connect(_on_picker_dim_gui_input)
		picker_panel.gui_input.connect(_on_sheet_drag.bind(picker_panel, _close_basket_picker))
	if magnet_button:
		magnet_button.clicked.connect(_on_field_magnet_pressed)
	if loot_boost_button:
		loot_boost_button.clicked.connect(_on_field_loot_boost_pressed)
	if field_basket:
		field_basket.clicked.connect(_on_basket_pressed)
	_bind_meadow_signal()
	_setup_typography()
	_setup_safe_area()
	if OS.is_debug_build() and not GameState.skip_debug_season_unlock:
		GameState.debug_playtest_two_free()
	_refresh_menu()
	_refresh_chest_card()
	_refresh_basket_card()


func _setup_typography() -> void:
	_basket_hint = CoachBubble.new()
	_basket_hint.name = "BasketHint"
	tutorial_hint_panel.add_child(_basket_hint)
	_style_sheet(picker_panel, basket_picker_overlay, UiHomeField.SHEET_BASKET_H)
	_style_sheet(upgrades_panel, upgrades_overlay, UiHomeField.SHEET_UPGRADES_H)
	_style_sheet_label(picker_panel.get_node("PickerVBox/PickerTitle") as Label, 900, UiPopups.PLATE_TITLE, UiPopups.OUTLINE)
	_style_sheet_label(upgrades_title, 900, UiPopups.PLATE_TITLE, UiPopups.OUTLINE)
	_style_sheet_label(magnet_title, 900, 52, UiPopups.OUTLINE)
	_style_sheet_label(loot_boost_title, 900, 52, UiPopups.OUTLINE)
	picker_clear_button.configure("secondary", UiPopups.S_BASKET_CLEAR, false, UiPopups.icon("icon_basket"))
	picker_close_button.configure("secondary", UiPopups.S_CLOSE)
	upgrades_close_button.configure("secondary", UiPopups.S_CLOSE)


## Sheet sistema: krem, rub 4 gore, radius 36, ručka 120 × 12, padding 24 / 24 / 24 / 28.
func _style_sheet(panel: PanelContainer, overlay: Control, h: int) -> void:
	var sb := UiPopups.sheet_panel()
	sb.content_margin_left = SHEET_PAD.x
	sb.content_margin_top = SHEET_PAD.y
	sb.content_margin_right = SHEET_PAD.z
	sb.content_margin_bottom = SHEET_PAD.w
	panel.add_theme_stylebox_override("panel", sb)
	panel.offset_top = -float(h)
	panel.offset_bottom = 0.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var handle := panel.find_child("SheetHandle", true, false) as Panel
	if handle:
		handle.add_theme_stylebox_override("panel", UiPopups.sheet_handle())
	var dim := overlay.get_node_or_null("Dim") as ColorRect
	if dim:
		dim.color = UiPopups.SCRIM


func _style_sheet_label(label: Label, weight: int, px: int, color: Color) -> void:
	if label == null:
		return
	label.add_theme_font_override("font", UiPopups.font(weight, px))
	label.add_theme_font_size_override("font_size", px)
	label.add_theme_color_override("font_color", color)


func _setup_safe_area() -> void:
	pass


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
	if tutorial_hint_panel:
		var show := first and open
		if show and not tutorial_hint_panel.visible:
			_show_basket_hint(false)
		tutorial_hint_panel.visible = show


## H2 · oblačić s repom lijevo prema korpi (u HINT_RECT), ikona Arene na mint disku.
func _show_basket_hint(pop: bool) -> void:
	if _basket_hint == null:
		return
	_basket_hint.setup([{
		"text": UiPopups.S_HINT_BASKET, "icon": UiAssets.get_chrome_icon("tab_arena"), "disc": UiPopups.MINT
	}], "left")
	_basket_hint.max_w = 600.0
	_basket_hint.setup(_basket_hint.rows, "left")
	var basket_c := Vector2(UiHomeField.BASKET_RECT.get_center())
	var tip := Vector2(UiHomeField.BASKET_RECT.end.x + 12.0, basket_c.y) - Vector2(UiHomeField.HINT_RECT.position)
	_basket_hint.point_at(tip, 0.5)
	_basket_hint.visible = true
	if pop:
		_basket_hint.pop_in()


## Home v3: livada (SeasonStage) pokriva stranicu, pa nema tamne pozadine polja;
## chrome polja je u FieldOverlayu koji SeasonStage klipuje na rect kartice.
func sync_field_backdrop() -> void:
	var open := GameState.home_season_field_open
	_apply_mode_layout(open)
	_sync_loadout_to_open_season()
	_refresh_basket_card()
	_refresh_endless_button()
	_refresh_seasons_row_button()
	_refresh_field_upgrades()
	_sync_field_hub_swipe_chrome()


func _sync_field_hub_swipe_chrome() -> void:
	var open := GameState.home_season_field_open
	for node in [
		seasons_row_button,
		field_basket,
		gift_chest,
		upgrades_button,
		bottom_row,
		endless_play_button,
		basket_picker_overlay,
		upgrades_overlay,
		wardrobe_button,
	]:
		_set_block_hub_swipe(node as Control, open)
	# Cip je info — swipe mora proci kroz njega.
	_set_block_hub_swipe(grown_chip, false)
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


## Play: tuđa kartica → nazad na sezonu u kojoj se igra ("focus"); ta sezona →
## polje ("field"); polje → run. Jedno dugme (SeasonStage · PlayButton).
func home_play_action() -> String:
	if season_stage == null:
		return "field"
	var a := str(season_stage.call("play_action"))
	return "focus" if a == "back" else a


func get_play_button() -> Control:
	return season_stage.get_node_or_null("%PlayButton") as Control if season_stage else null


func _start_run() -> void:
	if not GameState.home_season_field_open:
		return
	var id := GameState.active_season_id
	if id.is_empty() or not GameState.is_season_playable(id):
		GameState.set_active_season(SeasonCatalog.DEFAULT_SEASON_ID)
	GameState.begin_campaign_run()
	SceneRouter.change_to(GameState.SCENE_RUN)


func refresh_play_chip() -> void:
	pass


## Home v3: Play nosi samo „Play" / „Back" — ime sezone je na kartici.
func get_play_chip_text() -> String:
	return ""


## Chrome polja: vidljiv dok je polje otvoreno (i dok traje zatvaranje — stanje
## se zatvara tek kad prelaz stigne do kartice).
func _apply_mode_layout(field_open: bool) -> void:
	if field_overlay:
		field_overlay.visible = field_open
	if not field_open:
		_close_upgrades_sheet()
		_close_wardrobe(false)
	_apply_field_overlay_styles()
	if field_open:
		_style_field_bottom_row()
	_refresh_chest_card()
	_refresh_tutorial_hint()
	_refresh_upgrades_button()
	_refresh_wardrobe_button()
	_refresh_grown_chip()


## Stilovi naljepnica — postavljaju se jednom po ulasku, boje ne ovise o sezoni.
func _apply_field_overlay_styles() -> void:
	if field_overlay == null or not field_overlay.visible:
		return
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


## Donji red: Seasons 236 x 124 · Play 432 x 140 (centar x 540, JE PlayButton
## Homea) · Endless 236 x 124. Naljepnica rub 3 + sjenka 8; sadrzaj kao
## FieldScreen.dc.html: crtani chevron / dva prstena + tekst 38/900.
func _style_field_bottom_row() -> void:
	_style_sticker_button(seasons_row_button, UiHomeField.SEASONS_BTN.size, UiHomeField.seasons_button(), "Seasons", "chevron", 14)
	_style_sticker_button(endless_play_button, UiHomeField.ENDLESS_BTN.size, UiHomeField.endless_button(), "Endless", "rings", 12)


func _style_sticker_button(btn: UiClickButton, sz: Vector2i, style: StyleBoxFlat, text: String, glyph: String, gap: int) -> void:
	if btn == null:
		return
	btn.custom_minimum_size = Vector2(sz)
	btn.set_panel_styles(style, UiHomeField.pressed_sticker(style))
	btn.label_text = text
	btn.font_size = 38
	var row := btn.get_node_or_null("ContentRow") as HBoxContainer
	if row == null:
		return
	row.add_theme_constant_override("separation", gap)
	var label := row.get_node_or_null("Label") as Label
	if label:
		UiStage.style(label, 900, 38, UiHomeField.OUTLINE)
		label.add_theme_font_size_override("font_size", 38)
	if row.get_node_or_null("Glyph") == null:
		var g := HomeV3Glyph.new(glyph)
		row.add_child(g)
		row.move_child(g, 0)


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
	_style_upgrade_season_title()
	var season_id := GameState.upgrade_sheet_season_id()
	var flower_id := GameState.star3_type_id_for_season(season_id)
	var have := GameState.spendable_upgrade_flowers(season_id)
	for spec in [
		["magnet", magnet_button, magnet_title, _magnet_effect],
		["loot", loot_boost_button, loot_boost_title, _loot_effect],
		["twin", _twin_button, _twin_title, _twin_effect],
	]:
		_apply_upgrade_card(
			str(spec[0]), spec[1], spec[2], null, spec[3], null, null,
			GameState.get_upgrade_level(str(spec[0]), season_id),
			UiCamp.UP_LEVELS, "", flower_id, have
		)


## H5 · kartica nadogradnje (design_handoff_popups): ime 52 · 4 segmenta 96 × 22 · efekat 40/800;
## desno dugme koje JE cijena (crtež cvijeta T3 + „×2", „Need N", „✓ Max", „✓ Done").
func _ensure_upgrade_extras() -> void:
	_ensure_twin_card()
	_magnet_effect = _ensure_extra_label(magnet_title, "MagnetEffect", _magnet_effect)
	_ensure_segment_row(magnet_title, "MagnetSegments")
	_loot_effect = _ensure_extra_label(loot_boost_title, "LootEffect", _loot_effect)
	_ensure_segment_row(loot_boost_title, "LootSegments")
	_twin_effect = _ensure_extra_label(_twin_title, "TwinEffect", _twin_effect)
	_ensure_segment_row(_twin_title, "TwinSegments")


func _ensure_twin_card() -> void:
	if _twin_button != null:
		return
	if upgrades_vbox == null:
		return
	var cards := upgrades_vbox.get_node_or_null("Cards")
	var src := cards.get_node_or_null("LootBoostRow") if cards else null
	if src == null:
		return
	var twin := src.duplicate()
	twin.name = "TwinRow"
	_clear_unique_names(twin)
	cards.add_child(twin)
	_twin_title = twin.find_child("LootBoostTitle", true, false) as Label
	if _twin_title:
		_twin_title.name = "TwinTitle"
		_twin_title.text = "Twin Seeds"
		# Kopija može nastati prije _setup_typography — tada nosi zadanu bijelu boju i ime
		# se ne vidi na krem kartici (playtest 2026-10-08). Stil se zato daje ovdje.
		_style_sheet_label(_twin_title, 900, 52, UiPopups.OUTLINE)
	_twin_button = twin.find_child("LootBoostButton", true, false) as PopupButton
	if _twin_button:
		_twin_button.name = "TwinButton"
		if not _twin_button.clicked.is_connected(_on_field_twin_pressed):
			_twin_button.clicked.connect(_on_field_twin_pressed)


func _clear_unique_names(node: Node) -> void:
	node.unique_name_in_owner = false
	for child in node.get_children():
		_clear_unique_names(child)


func _style_upgrade_season_title() -> void:
	if upgrades_title == null:
		return
	var season_id := GameState.upgrade_sheet_season_id()
	var def: SeasonDef = GameState.get_season_def(season_id)
	upgrades_title.text = def.display_name if def != null else "Upgrades"
	# SeasonTitle (camp v3): pilula 96, ime 56 / DARK_INK centrirano u njoj. Natpis iz scene
	# ima min. visinu 92 i tekst na dnu, pa je ime sjedilo nisko — zato se ovdje poništava.
	upgrades_title.custom_minimum_size = Vector2.ZERO
	upgrades_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrades_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	upgrades_title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_style_sheet_label(upgrades_title, 900, 56, UiCamp.DARK_INK)
	var host := upgrades_title.get_parent()
	if host == null or host.name == "SeasonTitle":
		if host is PanelContainer:
			(host as PanelContainer).add_theme_stylebox_override("panel", _season_title_style(season_id))
		return
	var pill := PanelContainer.new()
	pill.name = "SeasonTitle"
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pill.custom_minimum_size = Vector2(0, 96)
	var idx := upgrades_title.get_index()
	host.remove_child(upgrades_title)
	pill.add_child(upgrades_title)
	host.add_child(pill)
	host.move_child(pill, idx)
	pill.add_theme_stylebox_override("panel", _season_title_style(season_id))


func _season_title_style(season_id: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiCamp.sheet_season_tint(season_id)
	s.border_color = UiCamp.sheet_season_tint_edge(season_id)
	s.set_border_width_all(3)
	s.set_corner_radius_all(48)
	s.content_margin_left = 36.0
	s.content_margin_right = 36.0
	s.content_margin_top = 0.0
	s.content_margin_bottom = 0.0
	return s


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
		seg.custom_minimum_size = Vector2(UiPopups.UPGRADE_SEG)
		row.add_child(seg)
	after.get_parent().add_child(row)
	after.get_parent().move_child(row, after.get_index() + 1)
	return row


func _paint_segments(title: Label, row_name: String, level: int, flash: bool) -> void:
	if title == null or title.get_parent() == null:
		return
	var row := title.get_parent().get_node_or_null(row_name) as HBoxContainer
	if row == null:
		return
	for i in row.get_child_count():
		var seg := row.get_child(i) as Panel
		if seg:
			seg.add_theme_stylebox_override("panel", UiPopups.level_segment(i < level, flash and i == level - 1))


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
	after.get_parent().add_child(lab)
	after.get_parent().move_child(lab, after.get_index() + 1)
	return lab


func _effect_text(kind: String, level: int, max_level: int) -> String:
	if kind == "magnet":
		if level >= max_level:
			return "Pull %d px" % int(GameState.get_magnet_radius_for_level(max_level))
		return "Pull %d → %d px" % [
			int(GameState.get_magnet_radius_for_level(level)),
			int(GameState.get_magnet_radius_for_level(level + 1)),
		]
	if kind == "twin":
		if level >= max_level:
			return "Twins %d %%" % int(round(UiCamp.twin_chance(max_level) * 100.0))
		return "Twins %d %% → %d %%" % [
			int(round(UiCamp.twin_chance(level) * 100.0)),
			int(round(UiCamp.twin_chance(level + 1) * 100.0)),
		]
	if level >= max_level:
		return "Loot ×%s" % str(UiHomeField.loot_multiplier(max_level))
	return "Loot ×%s → ×%s" % [str(UiHomeField.loot_multiplier(level)), str(UiHomeField.loot_multiplier(level + 1))]


func _apply_upgrade_card(
	kind: String,
	btn: PopupButton,
	title: Label,
	_level_lab: Label,
	effect_lab: Label,
	_cost_lab: Label,
	_have_lab: Label,
	level: int,
	max_level: int,
	_effect: String,
	flower_id: String,
	have: int
) -> void:
	var state := GameState.upgrade_button_state(kind)
	var maxed := state == UiCamp.UP_MAX
	var flash := _upgrade_flash_kind == kind
	var row: PanelContainer = null
	if btn and btn.get_parent():
		row = btn.get_parent().get_parent() as PanelContainer
	if row:
		row.custom_minimum_size = Vector2(UiPopups.UPGRADE_CARD)
		var sb := UiPopups.upgrade_card(flash)
		sb.content_margin_left = 36.0
		sb.content_margin_right = 36.0
		sb.content_margin_top = 24.0
		sb.content_margin_bottom = 24.0
		row.add_theme_stylebox_override("panel", sb)
	if title:
		title.text = "Magnet" if kind == "magnet" else ("Twin Seeds" if kind == "twin" else "Loot Boost")
	var seg_name := "MagnetSegments" if kind == "magnet" else ("TwinSegments" if kind == "twin" else "LootSegments")
	_paint_segments(title, seg_name, level, flash)
	if effect_lab:
		effect_lab.text = _effect_text(kind, level, max_level)
		_style_sheet_label(effect_lab, 800, 40, UiPopups.INK_SOFT)
	if btn == null:
		return
	btn.custom_minimum_size = Vector2(340, 132)
	btn.art_type = ""
	if flash:
		btn.configure("done", UiPopups.S_UPGRADE_DONE)
	elif maxed:
		btn.configure("done", UiPopups.S_UPGRADE_MAX)
	else:
		var cost := UiCamp.upgrade_coin_cost(level)
		var can := state == UiCamp.UP_CAN
		btn.configure("primary" if can else "disabled", "×%d" % UiCamp.UP_FLOWER_COST)
		btn.set_art(flower_id, 3, 64.0)
		btn.coin_text = str(cost)
		btn.flower_short = state == UiCamp.UP_SHORT_FLOWER or state == UiCamp.UP_SHORT_BOTH
		btn.coin_short = state == UiCamp.UP_SHORT_COIN or state == UiCamp.UP_SHORT_BOTH
		btn.queue_redraw()


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


func _on_field_twin_pressed() -> void:
	if not GameState.home_season_field_open:
		return
	if GameState.try_upgrade_twin():
		_flash_upgrade("twin")
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
	if gift_chest == null:
		return
	if _chest_ui_state == ChestUiState.OPENING:
		return
	# Poklon je samo na polju sezone — gornja lijeva plocica iznad korpe.
	gift_chest.visible = GameState.home_season_field_open
	var claimable := false
	if not GameState.tutorial_complete:
		_chest_ui_state = ChestUiState.LOCKED
	elif GameState.can_claim_daily_chest():
		_chest_ui_state = ChestUiState.READY
		claimable = true
	else:
		_chest_ui_state = ChestUiState.CLAIMED
	gift_chest.claimable = claimable


## Roze tacka na Gift kartici = poklon ceka (DailyGiftCard u dizajnu).
func is_gift_claimable() -> bool:
	return gift_chest != null and gift_chest.visible and gift_chest.claimable


func is_basket_attention_active() -> bool:
	return field_basket != null and field_basket.is_attention_running()


func _on_daily_chest_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if not tapped:
		return
	gift_chest.accept_event()
	_on_daily_chest_pressed()


func _on_daily_chest_pressed() -> void:
	if _chest_ui_state == ChestUiState.OPENING:
		return
	if _chest_ui_state == ChestUiState.LOCKED:
		return
	if _chest_ui_state == ChestUiState.CLAIMED:
		show_gift_tomorrow()
		return
	_chest_ui_state = ChestUiState.OPENING
	var card: HomeGiftCard = gift_chest
	card.claimable = false
	card.pivot_offset = card.size * 0.5
	var tw := create_tween()
	tw.tween_property(card, "scale", Vector2(1.05, 1.05), 0.15)
	tw.tween_property(card, "scale", Vector2.ONE, 0.2)
	tw.tween_callback(_finish_chest_claim)


func _finish_chest_claim() -> void:
	var bag_before: Dictionary = GameState.seed_bag.duplicate()
	var coins_before := int(GameState.wallet_coins)
	GameState.claim_daily_chest()
	_chest_ui_state = ChestUiState.CLAIMED
	_refresh_chest_card()
	_notify_hub_chrome()
	var seed_type := ""
	var added := 0
	for type_id in GameState.seed_bag:
		var diff := int(GameState.seed_bag[type_id]) - int(bag_before.get(type_id, 0))
		if diff > 0:
			seed_type = str(type_id)
			added = diff
	show_gift_claimed(int(GameState.wallet_coins) - coins_before, seed_type, added)


func _notify_hub_chrome() -> void:
	if not GameState.meta_hub_active or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "refresh_top_bar")


## H3 · poklon (design_handoff_popups): modal sa zlatnom pločicom „Daily gift" i nagradom kao
## chipovima (coin + crtež sjemena). Dobio manje sjemenki → napomena „Bag almost full". Već otvoren
## danas → poklon glif 176 + „Back in Nh" i OK. Zatvara se dugmetom ili tapom van.
func show_gift_claimed(coins: int, seed_type: String, added: int) -> void:
	var modal := _ensure_gift_modal()
	modal.set_title(UiPopups.S_GIFT_TITLE, "reward")
	_clear_gift_content()
	var chips: Array = [RewardChip.new().setup("coin", "", coins)]
	if not seed_type.is_empty() and added > 0:
		chips.append(RewardChip.new().setup("seed", seed_type, added))
	var tray := RewardTray.new().setup(880.0, chips)
	tray.name = "RewardTray"
	modal.content.add_child(PopupModal.centered(tray))
	if added < GameState.DAILY_CHEST_SEEDS:
		modal.content.add_child(_gift_note())
	_attach_gift_button("primary", UiPopups.S_GIFT_COLLECT)
	modal.open(true)
	tray.reveal()


func show_gift_tomorrow() -> void:
	var modal := _ensure_gift_modal()
	modal.set_title(UiPopups.S_GIFT_TITLE, "decision")
	_clear_gift_content()
	var closed := _GiftClosed.new()
	closed.name = "GiftClosed"
	closed.text = UiPopups.back_in_text()
	modal.content.add_child(closed)
	_attach_gift_button("secondary", UiPopups.S_OK)
	modal.open(true)


func is_gift_open() -> bool:
	return reward_overlay != null and reward_overlay.visible


func get_gift_text() -> String:
	if reward_overlay == null:
		return ""
	var parts: PackedStringArray = [reward_overlay.title]
	var closed := reward_overlay.content.get_node_or_null("GiftClosed")
	if closed:
		parts.append(str(closed.get("text")))
	if reward_overlay.content.get_node_or_null("ModalNote"):
		parts.append(UiPopups.S_GIFT_BAG_FULL)
	if _gift_button:
		parts.append(_gift_button.label)
	return " | ".join(parts)


func _ensure_gift_modal() -> PopupModal:
	if reward_overlay != null:
		return reward_overlay
	reward_overlay = PopupModal.new()
	reward_overlay.name = "RewardOverlay"
	reward_overlay.z_index = 40
	reward_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	reward_overlay.dismiss_on_scrim = true
	add_child(reward_overlay)
	reward_overlay.setup(UiPopups.S_GIFT_TITLE, "reward")
	_gift_button = PopupButton.new()
	_gift_button.name = "RewardOkButton"
	_gift_button.clicked.connect(_on_reward_ok_pressed)
	return reward_overlay


## Dugme poklona se čuva između otvaranja — skine se prije nego se sadržaj obriše.
func _clear_gift_content() -> void:
	if _gift_button.get_parent() != null:
		_gift_button.get_parent().remove_child(_gift_button)
	reward_overlay.clear_content()


func _attach_gift_button(kind: String, label: String) -> void:
	if _gift_button.get_parent() != null:
		_gift_button.get_parent().remove_child(_gift_button)
	_gift_button.configure(kind, label)
	reward_overlay.content.add_child(_gift_button)


func _gift_note() -> Control:
	return UiPopups.modal_note(UiPopups.S_GIFT_BAG_FULL)


func _hide_reward_overlay() -> void:
	if reward_overlay:
		reward_overlay.close(false)


func _on_reward_ok_pressed() -> void:
	if reward_overlay:
		reward_overlay.close(true)


## „Sutra opet": lavanda poklon 176 (krem traka u krst) + RIM pilula „Back in Nh".
class _GiftClosed extends Control:
	var text: String = ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(880, 304)

	func _draw() -> void:
		var g := Rect2((size.x - 176.0) * 0.5, 12.0, 176.0, 176.0)
		draw_style_box(UiPopups._box(UiPopups.LAVENDER, 40, 4), g)
		draw_rect(Rect2(g.get_center().x - 16.0, g.position.y + 4.0, 32.0, 168.0), UiPopups.WARM_WHITE)
		draw_rect(Rect2(g.position.x + 4.0, g.get_center().y - 16.0, 168.0, 32.0), UiPopups.WARM_WHITE)
		var tw := UiPopups.text_w(900, 52, text)
		var chip := Rect2((size.x - tw - 70.0) * 0.5, 216.0, tw + 70.0, 84.0)
		draw_style_box(UiPopups._box(UiPopups.ACTIVE_RIM, 42, 3, UiPopups.TRAY_EDGE), chip)
		UiPopups.draw_text_centered(self, 900, 52, text, chip, UiPopups.OUTLINE)


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
	# Jedini loop (prsten oko prazne korpe) radi samo na polju, u = 1 — ne u prelazu.
	if not GameState.home_season_field_open or _stage_transitioning():
		field_basket.stop_attention()


func _stage_transitioning() -> bool:
	return season_stage != null and bool(season_stage.call("is_field_transitioning"))


## Dok traje prelaz nijedna kontrola polja ne prima dodir (ni hub swipe).
func _ensure_transition_blocker() -> void:
	if field_overlay_inner == null or _transition_blocker != null:
		return
	_transition_blocker = Control.new()
	_transition_blocker.name = "TransitionBlocker"
	_transition_blocker.visible = false
	_transition_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	_transition_blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_transition_blocker.add_to_group(BLOCK_HUB_SWIPE_GROUP)
	field_overlay_inner.add_child(_transition_blocker)


## SeasonStage javlja pocetak i kraj prelaza kartica ↔ livada.
func on_field_transition_started(_opening: bool) -> void:
	if _transition_blocker:
		_transition_blocker.visible = true
	if field_basket:
		field_basket.stop_attention()
	_close_basket_picker()
	_close_upgrades_sheet()
	_close_wardrobe(false)


func on_field_transition_finished(opened: bool) -> void:
	if _transition_blocker:
		_transition_blocker.visible = false
	if opened:
		_refresh_basket_card()


func _sync_basket_attention() -> void:
	if field_basket == null:
		return
	if not GameState.home_season_field_open:
		field_basket.stop_attention()


func _on_basket_pressed() -> void:
	if _basket_locked or not GameState.loadout_enabled():
		if field_basket:
			field_basket.shake()
		if tutorial_hint_panel:
			tutorial_hint_panel.visible = true
			_show_basket_hint(true)
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
		_dismiss_sheet(picker_panel, _close_basket_picker)


func _open_basket_picker() -> void:
	if not GameState.home_season_field_open:
		return
	if basket_picker_overlay == null or picker_list == null:
		return
	_rebuild_picker_list()
	_fit_picker_panel()
	_open_sheet(basket_picker_overlay, picker_panel, UiHomeField.SHEET_BASKET_H)


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
	var seen: Array[String] = []
	for type_id in SeedCatalog.types_for_season(GameState.home_season_field_id):
		if int(GameState.lifetime_seeds_collected.get(type_id, 0)) < 1:
			continue
		if not GameState.is_seed_type_unlocked(type_id):
			continue
		seen.append(type_id)
	if not current.is_empty() and not seen.has(current):
		GameState.clear_loadout()
		current = ""
	if picker_clear_button:
		picker_clear_button.configure("disabled" if current.is_empty() else "secondary", UiPopups.S_BASKET_CLEAR, false, UiPopups.icon("icon_basket"))
	if seen.is_empty():
		var empty := Label.new()
		empty.name = "BasketEmpty"
		empty.text = "Seeds you catch in a run show up here"
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# PickerList je mreža s 3 kolone: natpis s prelomom bez širine lomi riječ po riječ
		# i rasteže sheet (1326 → 1581). Uzima punu širinu sadržaja sheeta.
		empty.custom_minimum_size.x = 1080.0 - SHEET_PAD.x - SHEET_PAD.z
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UiCamp.style_label(empty, 40, UiCamp.INK)
		picker_list.add_child(empty)
		return
	for type_id in seen:
		var tile := SeedTile.new().setup(
			type_id, GameState.get_seed_display_name(type_id), GameState.get_seed_rarity(type_id),
			false, type_id == current
		)
		tile.clicked.connect(func() -> void: _on_basket_type_picked(type_id))
		picker_list.add_child(tile)


func _fit_picker_panel() -> void:
	if picker_panel == null:
		return
	picker_panel.offset_top = -float(UiHomeField.SHEET_BASKET_H)
	picker_panel.offset_bottom = 0.0


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
	var season_id := GameState.upgrade_sheet_season_id()
	var ready := false
	for track in ["magnet", "loot", "twin"]:
		if GameState.upgrade_button_state(track, season_id) == UiCamp.UP_CAN:
			ready = true
	upgrades_button.set_levels(
		GameState.get_upgrade_level("magnet", season_id),
		GameState.get_upgrade_level("loot", season_id),
		GameState.get_upgrade_level("twin", season_id),
		ready
	)


func _open_upgrades_sheet() -> void:
	if not GameState.home_season_field_open or upgrades_overlay == null:
		return
	_fit_upgrades_panel()
	_refresh_field_upgrades()
	_open_sheet(upgrades_overlay, upgrades_panel, UiHomeField.SHEET_UPGRADES_H)


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
		_dismiss_sheet(upgrades_panel, _close_upgrades_sheet)


func _fit_upgrades_panel() -> void:
	if upgrades_panel == null:
		return
	upgrades_panel.offset_top = -float(UiHomeField.SHEET_UPGRADES_H)
	upgrades_panel.offset_bottom = 0.0


## Sheet sistema: ulaz y +h → 0 (320 ms cubic-out) + scrim fade; izlaz od trenutne pozicije
## nadolje (280 ms cubic-in). `_close_*` zatvara odmah (prelazi, kod); dodir ide kroz `_dismiss_sheet`.
func _open_sheet(overlay: Control, panel: Control, h: int) -> void:
	overlay.visible = true
	var dim := overlay.get_node_or_null("Dim") as CanvasItem
	if not is_inside_tree():
		return
	panel.position.y = overlay.size.y - float(h)
	UiPopups.tween_sheet_in(panel, h)
	if dim:
		dim.modulate.a = 0.0
		create_tween().tween_property(dim, "modulate:a", 1.0, UiPopups.ANIM.modal_in)


func _dismiss_sheet(panel: Control, close_fn: Callable) -> void:
	var overlay := panel.get_parent() as Control
	if overlay == null or not overlay.visible or not is_inside_tree():
		close_fn.call()
		return
	var dim := overlay.get_node_or_null("Dim") as CanvasItem
	var t := create_tween().set_parallel()
	t.tween_property(panel, "position:y", overlay.size.y, UiPopups.ANIM.sheet_out).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if dim:
		t.tween_property(dim, "modulate:a", 0.0, UiPopups.ANIM.sheet_out)
	t.chain().tween_callback(func() -> void:
		close_fn.call()
		panel.position.y = overlay.size.y - panel.size.y
		if dim:
			dim.modulate.a = 1.0
	)


## Povlačenje sheeta nadolje > 160 px zatvara; manje vraća na mjesto.
func _on_sheet_drag(event: InputEvent, panel: Control, close_fn: Callable) -> void:
	var overlay := panel.get_parent() as Control
	if overlay == null:
		return
	var rest := overlay.size.y - panel.size.y
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var pressed: bool = event.pressed
		if (event is InputEventMouseButton) and (event as InputEventMouseButton).button_index != MOUSE_BUTTON_LEFT:
			return
		if pressed:
			_sheet_drag = {"panel": panel, "y0": event.position.y + panel.position.y, "start": panel.position.y}
		elif _sheet_drag.get("panel") == panel:
			var moved := panel.position.y - rest
			_sheet_drag = {}
			if moved > UiPopups.DRAG_CLOSE_PX:
				_dismiss_sheet(panel, close_fn)
			elif moved > 0.5:
				create_tween().tween_property(panel, "position:y", rest, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	elif (event is InputEventMouseMotion or event is InputEventScreenDrag) and _sheet_drag.get("panel") == panel:
		var y_abs: float = event.position.y + panel.position.y
		panel.position.y = maxf(rest, float(_sheet_drag.start) + y_abs - float(_sheet_drag.y0))


func _on_basket_type_picked(type_id: String) -> void:
	if GameState.set_loadout(type_id):
		_refresh_basket_card()
		_close_basket_picker()


## ── Ormar (design_handoff_wardrobe) ──────────────────────────────────────────
## Pločica „Looks" (876, 1265) u desnoj koloni, sheet 1326 iste porodice kao korpa,
## ApplyMoment poslije zatvaranja: Pip skok + prsten (slot vidljiv na polju) ili
## toast (slot koji se na polju ne vidi).

func _ensure_wardrobe() -> void:
	if wardrobe_button != null or field_overlay_inner == null:
		return
	wardrobe_button = FieldWardrobeButton.new()
	field_overlay_inner.add_child(wardrobe_button)
	wardrobe_button.position = Vector2(UiHomeField.WARDROBE_RECT.position)
	wardrobe_button.size = Vector2(UiHomeField.WARDROBE_RECT.size)
	wardrobe_button.clicked.connect(_open_wardrobe)
	_apply_toast = ApplyToast.new()
	_apply_toast.name = "ApplyToast"
	field_overlay_inner.add_child(_apply_toast)
	wardrobe_sheet = WardrobeSheet.new()
	add_child(wardrobe_sheet)
	wardrobe_sheet.close_finished.connect(_on_wardrobe_closed)
	wardrobe_sheet.shop_requested.connect(_on_wardrobe_shop)


func _refresh_wardrobe_button() -> void:
	if wardrobe_button == null:
		return
	wardrobe_button.visible = GameState.home_season_field_open
	wardrobe_button.set_dot(GameState.cosmetics.has_new())


func _open_wardrobe() -> void:
	if not GameState.home_season_field_open or wardrobe_sheet == null:
		return
	if _stage_transitioning():
		return
	_close_basket_picker()
	_close_upgrades_sheet()
	wardrobe_sheet.open(GameState.home_season_field_id)


## Shop v2 · Looks → „Wardrobe": otvori polje aktivne sezone (bez prelaza) i Ormar.
func open_wardrobe_from_shop() -> void:
	if not GameState.home_season_field_open and season_stage != null:
		season_stage.call("open_season_field", GameState.active_season_id, false)
	for _i in 4:
		await get_tree().process_frame
	_open_wardrobe()


func _close_wardrobe(animated: bool = true) -> void:
	if wardrobe_sheet != null and wardrobe_sheet.is_open():
		wardrobe_sheet.close(animated)


func is_wardrobe_open() -> bool:
	return wardrobe_sheet != null and wardrobe_sheet.is_open()


func _on_wardrobe_closed(changed: Array) -> void:
	_refresh_wardrobe_button()
	if changed.is_empty() or not GameState.home_season_field_open:
		return
	var slots := {}
	for sd in CosmeticCatalog.slots():
		slots[str(sd.get("id", ""))] = sd
	if UiWardrobe.changed_on_field(changed, slots):
		var meadow := season_stage.get_node_or_null("%SeasonField") if season_stage else null
		if meadow != null and meadow.has_method("play_apply_moment"):
			meadow.call("play_apply_moment")
	var text := UiWardrobe.toast_text(changed, slots, wardrobe_sheet.pending)
	if not text.is_empty() and _apply_toast != null:
		var slot_id := str(changed[0]) if changed.size() == 1 else "pip_skin"
		var icon_path := str((slots.get(slot_id, {}) as Dictionary).get("icon", ""))
		_apply_toast.show_text(text, UiWardrobe.icon(icon_path) if not icon_path.is_empty() else null)


## ShopLink: zatvori (= snimi) i otvori Shop · Looks na istom slotu.
func _on_wardrobe_shop(slot_id: String) -> void:
	_close_wardrobe(false)
	var hubs := get_tree().get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		SceneRouter.change_to(GameState.SCENE_SHOP)
		return
	var hub := hubs[0]
	hub.call("go_to_page", MetaHubPages.SHOP)
	for _i in 30:
		await get_tree().process_frame
		var swipe := hub.get_node_or_null("RootVBox/SwipePager")
		var host: Node = swipe.call("get_pages_host") if swipe and swipe.has_method("get_pages_host") else null
		var shop := host.get_node_or_null("Page_%d" % MetaHubPages.SHOP) if host else null
		if shop != null and shop.has_method("show_cosmetic_slot"):
			shop.call("show_cosmetic_slot", slot_id)
			return


## ApplyToast: centar x 540, y 1110, h 100 · 44/900 krem na TOAST_BG · 2,6 s.
class ApplyToast extends Control:
	var text: String = ""
	var icon: Texture2D = null
	var _tween: Tween

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		visible = false

	## H7 · toast sistema (design_handoff_popups): pilula s ikonom slota na kremastom disku.
	func show_text(t: String, p_icon: Texture2D = null) -> void:
		text = t
		icon = p_icon
		size = Vector2(PopupToast.pill_width(text, icon != null), UiPopups.TOAST_H)
		position = Vector2(540.0 - size.x * 0.5, float(UiWardrobe.TOAST_Y))
		visible = true
		modulate.a = 0.0
		if _tween != null and _tween.is_valid():
			_tween.kill()
		UiPopups.tween_toast_in(self)
		_tween = create_tween()
		_tween.tween_interval(UiPopups.ANIM.toast_in + UiWardrobe.T_TOAST_HOLD)
		_tween.tween_property(self, "modulate:a", 0.0, UiPopups.ANIM.toast_out)
		_tween.tween_callback(func() -> void: visible = false)
		queue_redraw()

	func _draw() -> void:
		PopupToast.draw_pill(self, Rect2(Vector2.ZERO, size), text, icon)
