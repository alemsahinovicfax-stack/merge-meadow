extends Control

## Journal / Bloom Album — smjer 1a (design_handoff_journal).
## PageHead 175 + lista. NEW ostaje vidljiv cijelu posjetu iako se tab badge
## briše na otvaranje. Sezonska poglavlja i auto-scroll na prvi NEW.

const JournalRow := preload("res://scripts/ui/collection_journal_row.gd")

const ROWS_PER_FRAME := 6

@onready var root_vbox: VBoxContainer = %RootVBox
@onready var page_head: VBoxContainer = %PageHead
@onready var title_row: HBoxContainer = %TitleRow
@onready var title_accent: Panel = %TitleAccent
@onready var title_label: Label = %BloomAlbumTitle
@onready var golden_plaque: PanelContainer = %GoldenPlaque
@onready var plaque_label: Label = %PlaqueLabel
@onready var summary_wrap: HBoxContainer = %SummaryWrap
@onready var summary_pad: Control = %SummaryPad
@onready var summary_label: Label = %SummaryLabel
@onready var divider_gap: Control = %DividerGap
@onready var head_divider: ColorRect = %HeadDivider
@onready var list_scroll: ScrollContainer = %ListScroll
@onready var list: VBoxContainer = %List
@onready var back_button: UiClickButton = %BackButton
@onready var golden_edge: Panel = %GoldenFrameEdge
@onready var golden_band: Panel = %GoldenFrameGold

var _pending_entries: Array[Dictionary] = []
var _slots: Array[Dictionary] = []
var _build_index: int = 0
var _building: bool = false
var _new_snapshot: Dictionary = {}
var _scroll_season: int = -1
var _scroll_row: int = -1


func _ready() -> void:
	$Bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Bg.color = UiJournal.PAGE_BG
	back_button.clicked.connect(_on_back_pressed)
	_style_head()
	set_process(false)
	if GameState.is_meta_hub_embedded(self):
		_apply_frame()
		return
	_begin_visit()


func _process(_delta: float) -> void:
	if not _building or list == null:
		set_process(false)
		return
	var n := 0
	while n < ROWS_PER_FRAME and _build_index < _slots.size():
		var slot: Dictionary = _slots[_build_index]
		var row := JournalRow.new()
		(slot["group"] as Node).add_child(row)
		row.apply(slot["entry"])
		_build_index += 1
		n += 1
	if _build_index >= _slots.size():
		_building = false
		set_process(false)
		# Skrol tek kad lista ima punu visinu, inace se zaustavi na tadasnjem maksimumu.
		call_deferred("_scroll_to_new")


func _style_head() -> void:
	title_accent.add_theme_stylebox_override("panel", UiJournal.flat(UiJournal.COIN_GOLD, 5))
	UiStage.style(title_label, 900, UiJournal.TITLE_FONT, UiJournal.INK)
	UiStage.style(summary_label, 800, UiJournal.SUMMARY_FONT, UiJournal.SUB_INK)
	UiStage.style(plaque_label, 900, UiJournal.PLAQUE_FONT, UiJournal.INK)
	golden_plaque.add_theme_stylebox_override("panel", UiJournal.golden_plaque_style())
	golden_plaque.custom_minimum_size.y = UiJournal.PLAQUE_H


func _begin_visit() -> void:
	var raw := GameState.get_collection_journal_entries()
	_new_snapshot.clear()
	_scroll_season = -1
	_scroll_row = -1
	var season_i := -1
	var row_i := 0
	var last_sid := ""
	for entry in raw:
		var sid := SeedCatalog.season_id_for(str(entry.get("type_id", "")))
		if sid != last_sid:
			season_i += 1
			row_i = 0
			last_sid = sid
		if bool(entry.get("is_new", false)) and _scroll_season < 0:
			_new_snapshot[str(entry.get("type_id", ""))] = int(entry.get("new_tier", 0))
			_scroll_season = season_i
			_scroll_row = row_i
		elif bool(entry.get("is_new", false)):
			_new_snapshot[str(entry.get("type_id", ""))] = int(entry.get("new_tier", 0))
		row_i += 1
	GameState.mark_collection_journal_viewed()
	_pending_entries = raw
	_apply_frame()
	_start_list_build()
	if is_inside_tree():
		get_tree().call_group("meta_hub", "refresh_top_bar")


func refresh_for_meta_hub() -> void:
	_begin_visit()


func on_meta_page_left() -> void:
	_new_snapshot.clear()
	_scroll_season = -1
	for entry in _pending_entries:
		entry["is_new"] = false
		entry["new_tier"] = 0
	var built := _rows()
	for i in built.size():
		if i < _pending_entries.size():
			built[i].apply(_pending_entries[i])


func _rows() -> Array[CollectionJournalRow]:
	var out: Array[CollectionJournalRow] = []
	if list == null:
		return out
	_collect_rows(list, out)
	return out


func _collect_rows(n: Node, out: Array[CollectionJournalRow]) -> void:
	for child in n.get_children():
		if child is CollectionJournalRow:
			out.append(child)
		else:
			_collect_rows(child, out)


func _start_list_build() -> void:
	_clear_list()
	_slots.clear()
	_build_index = 0
	summary_label.text = UiJournal.summary_text(_pending_entries)
	var groups := _make_groups(_pending_entries)
	for slot in groups:
		_slots.append(slot)
	_building = not _slots.is_empty()
	set_process(_building)
	if not _building:
		list_scroll.scroll_vertical = 0


func _make_groups(entries: Array[Dictionary]) -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	var counts := _season_counts(entries)
	list.add_child(_spacer(UiJournal.LIST_TOP))
	var season_i := -1
	var row_i := 0
	var last_sid := ""
	var group: VBoxContainer = null
	for entry in entries:
		var sid := SeedCatalog.season_id_for(str(entry.get("type_id", "")))
		if sid != last_sid:
			if season_i >= 0:
				list.add_child(_spacer(UiJournal.SEASON_GAP))
			season_i += 1
			row_i = 0
			last_sid = sid
			group = VBoxContainer.new()
			group.mouse_filter = Control.MOUSE_FILTER_IGNORE
			group.add_theme_constant_override("separation", UiJournal.SEASON_HEADER_GAP)
			group.add_child(_season_header(sid, counts.get(sid, {})))
			list.add_child(group)
		slots.append({
			"group": group,
			"entry": entry,
			"season": season_i,
			"row": row_i,
		})
		row_i += 1
	list.add_child(_spacer(UiJournal.LIST_BOTTOM))
	return slots


func _season_counts(entries: Array[Dictionary]) -> Dictionary:
	var out := {}
	for entry in entries:
		var sid := SeedCatalog.season_id_for(str(entry.get("type_id", "")))
		if not out.has(sid):
			out[sid] = {"kept": 0, "total": 0}
		out[sid]["total"] = int(out[sid]["total"]) + 1
		var state := str(entry.get("state", ""))
		if state == "album_t2" or state == "album_t3":
			out[sid]["kept"] = int(out[sid]["kept"]) + 1
	return out


func _season_header(season_id: String, count: Dictionary) -> HBoxContainer:
	var header := HBoxContainer.new()
	header.name = "SeasonHeader"
	header.custom_minimum_size.y = UiJournal.SEASON_HEADER_H
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 18)
	var def := SeasonCatalog.get_def(season_id)
	var name := Label.new()
	name.text = def.display_name if def else season_id
	UiStage.style(name, 900, UiJournal.SEASON_NAME_FONT, UiJournal.INK)
	header.add_child(name)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 3)
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rule.color = Color(UiJournal.INK, 0.14)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(rule)
	if not GameState.is_season_playable(season_id):
		var lock := TextureRect.new()
		lock.custom_minimum_size = Vector2(UiJournal.SEASON_LOCK_ICON, UiJournal.SEASON_LOCK_ICON)
		lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lock.texture = UiAssets.get_chrome_icon("icon_lock_ink")
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		header.add_child(lock)
	var kept := int(count.get("kept", 0))
	var total := int(count.get("total", 0))
	var num := Label.new()
	num.text = "%d / %d kept" % [kept, total]
	UiStage.style(num, 800, UiJournal.SEASON_COUNT_FONT, UiJournal.SUB_INK)
	header.add_child(num)
	return header


func _spacer(h: int) -> Control:
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0, h)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return pad


func _scroll_to_new() -> void:
	if list_scroll == null or _scroll_season < 0:
		return
	var y := UiJournal.row_y(_scroll_season, _scroll_row) - UiJournal.AUTO_SCROLL_LEAD
	list_scroll.scroll_vertical = maxi(0, y)


func _clear_list() -> void:
	if list == null:
		return
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()


func _apply_frame() -> void:
	var golden := GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_JOURNAL_FRAME) == "journal_gold"
	golden_edge.visible = golden
	golden_band.visible = golden
	if golden:
		golden_edge.add_theme_stylebox_override("panel", UiJournal.golden_frame_style(false, 38))
		golden_band.add_theme_stylebox_override("panel", UiJournal.golden_frame_style(true, 35))
	title_accent.visible = not golden
	title_label.visible = not golden
	golden_plaque.visible = golden
	summary_pad.visible = not golden
	summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if golden else HORIZONTAL_ALIGNMENT_LEFT
	head_divider.color = Color(UiJournal.GOLD_EDGE, 0.45) if golden else Color(UiJournal.INK, 0.1)
	page_head.custom_minimum_size.y = 219.0 if golden else float(UiJournal.HEAD_H)
	var top_pad := page_head.get_node_or_null("TopPad") as Control
	if top_pad:
		top_pad.custom_minimum_size.y = 40.0 if golden else 30.0
	divider_gap.custom_minimum_size.y = 14.0 if golden else 24.0
	if root_vbox:
		root_vbox.offset_left = 44.0 if golden else float(UiJournal.PAD_X)
		root_vbox.offset_right = -44.0 if golden else -float(UiJournal.PAD_X)


func _on_back_pressed() -> void:
	if GameState.meta_hub_active:
		GameState.go_to_meta_page(MetaHubPages.CAMP)
	else:
		SceneRouter.change_to(GameState.SCENE_CAMP)


func set_meta_hub_mode(enabled: bool) -> void:
	if back_button:
		back_button.visible = not enabled
