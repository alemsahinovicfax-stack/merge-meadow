extends Control

## Journal / Bloom Album — smjer 1a (design_handoff_journal).
## PageHead 175 + lista. NEW ostaje vidljiv cijelu posjetu iako se tab badge
## briše na otvaranje. Sezonska poglavlja i auto-scroll na prvi NEW.
## Redoslijed (2026-10-06): aktivna sezona, pa djelimično otključane, pa potpune, pa bez
## ijednog cvijeta (UiJournal.order_seasons). Lista se puni po 3 sezone: na ulazu prve tri,
## a kad igrač skrola do kraja učitanog, sljedeće tri — i tako dok ne ponestane sezona.
## Svaki ulazak počinje opet od tri (izlazak zadrži samo prve tri). Redovi se grade u
## frejmovima po vremenskom budžetu (tekstura cvijeta + red), pa ulazak ne zastaje.

const JournalRow := preload("res://scripts/ui/collection_journal_row.gd")

const SEASONS_PER_CHUNK := 3
## Rad po frejmu (µs): učitavanje tekstura + gradnja redova; uvijek bar jedan red.
const FRAME_BUDGET_USEC := 6000
## Sljedeće tri sezone kreću kad je do kraja učitanog ostalo manje od ovoga (px).
const LOAD_AHEAD_PX := 400.0

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

## Sezone u redoslijedu prikaza: [{sid, entries, kept, total, unlocked}].
var _order: Array[Dictionary] = []
## Sezone koje su na listi (ili u gradnji), istim redom: [{sid, group, gap, rows, sig}].
var _groups: Array[Dictionary] = []
## Redovi koji čekaju gradnju: [{group_index, entry}].
var _work: Array[Dictionary] = []
var _building: bool = false
var _bottom: Control = null
var _new_snapshot: Dictionary = {}
var _scroll_season: int = -1
var _scroll_row: int = -1
var _pending_scroll: bool = false
## Igrač je na stranici: tek tada skrol do kraja učitava sljedeće tri (posle izlaska
## skraćivanje liste pomjeri skrol, a to ne smije odmah vratiti obrisane sezone).
var _active: bool = false


func _ready() -> void:
	if not GameState.cosmetics_changed.is_connected(_on_cosmetics_changed):
		GameState.cosmetics_changed.connect(_on_cosmetics_changed)
	$Bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Bg.color = UiJournal.PAGE_BG
	back_button.clicked.connect(_on_back_pressed)
	list_scroll.get_v_scroll_bar().value_changed.connect(_on_scrolled)
	_style_head()
	set_process(false)
	if GameState.is_meta_hub_embedded(self):
		_apply_frame()
		return
	_begin_visit()


## Učitane sezone i redoslijed (testovi).
func loaded_season_count() -> int:
	return _groups.size()


func total_season_count() -> int:
	return _order.size()


func is_building() -> bool:
	return _building


func season_order() -> Array[String]:
	var out: Array[String] = []
	for s in _order:
		out.append(str(s["sid"]))
	return out


func _process(_delta: float) -> void:
	if not _building or list == null:
		set_process(false)
		return
	var t0 := Time.get_ticks_usec()
	var built := 0
	while not _work.is_empty() and (built == 0 or Time.get_ticks_usec() - t0 < FRAME_BUDGET_USEC):
		var item: Dictionary = _work.pop_front()
		var entry: Dictionary = item["entry"]
		# Tekstura prije reda: crtež cvijeta se učita ovdje, u budžetu, a ne u _draw.
		var filled := UiJournal.filled_tiers(str(entry.get("state", "locked")))
		for tier in range(1, filled + 1):
			FlowerAssets.get_texture(str(entry.get("type_id", "")), tier)
		var g: Dictionary = _groups[int(item["group_index"])]
		var row := JournalRow.new()
		(g["group"] as Node).add_child(row)
		row.apply(entry)
		(g["rows"] as Array).append(row)
		built += 1
	if not _work.is_empty():
		return
	_building = false
	set_process(false)
	if _pending_scroll:
		_pending_scroll = false
		# Skrol tek kad lista ima punu visinu, inace se zaustavi na tadasnjem maksimumu.
		call_deferred("_scroll_to_new")
	call_deferred("_maybe_load_more")


func _style_head() -> void:
	title_accent.add_theme_stylebox_override("panel", UiJournal.flat(UiJournal.COIN_GOLD, 5))
	UiStage.style(title_label, 900, UiJournal.TITLE_FONT, UiJournal.INK)
	UiStage.style(summary_label, 800, UiJournal.SUMMARY_FONT, UiJournal.SUB_INK)
	UiStage.style(plaque_label, 900, UiJournal.PLAQUE_FONT, UiJournal.INK)
	golden_plaque.add_theme_stylebox_override("panel", UiJournal.golden_plaque_style())
	golden_plaque.custom_minimum_size.y = UiJournal.PLAQUE_H


func _begin_visit() -> void:
	_active = true
	var raw := GameState.get_collection_journal_entries()
	GameState.mark_collection_journal_viewed()
	_order = UiJournal.order_seasons(raw, GameState.active_season_id)
	_new_snapshot.clear()
	_scroll_season = -1
	_scroll_row = -1
	for si in _order.size():
		var entries: Array = _order[si]["entries"]
		for ri in entries.size():
			var entry: Dictionary = entries[ri]
			if not bool(entry.get("is_new", false)):
				continue
			_new_snapshot[str(entry.get("type_id", ""))] = int(entry.get("new_tier", 0))
			if _scroll_season < 0:
				_scroll_season = si
				_scroll_row = ri
	_apply_frame()
	summary_label.text = UiJournal.summary_text(raw)
	# Prve tri sezone; ako je prvi NEW dalje, onoliko trojki koliko treba da se vidi.
	var want := mini(SEASONS_PER_CHUNK, _order.size())
	if _scroll_season >= 0:
		want = mini(_order.size(), (_scroll_season / SEASONS_PER_CHUNK + 1) * SEASONS_PER_CHUNK)
	_sync_groups(want)
	if _scroll_season >= 0:
		_pending_scroll = _building
		if not _building:
			call_deferred("_scroll_to_new")
	else:
		list_scroll.scroll_vertical = 0
	if is_inside_tree():
		get_tree().call_group("meta_hub", "refresh_top_bar")


func refresh_for_meta_hub() -> void:
	_begin_visit()


## Odlazak: NEW se gasi na izgrađenim redovima, a lista se skrati na prve tri sezone —
## sljedeći ulazak opet učitava po tri.
func on_meta_page_left() -> void:
	_active = false
	_new_snapshot.clear()
	_scroll_season = -1
	_pending_scroll = false
	for s in _order:
		for entry in s["entries"]:
			entry["is_new"] = false
			entry["new_tier"] = 0
	for gi in _groups.size():
		var entries: Array = _order[gi]["entries"] if gi < _order.size() else []
		var rows: Array = _groups[gi]["rows"]
		for i in rows.size():
			if i < entries.size():
				(rows[i] as CollectionJournalRow).apply(entries[i])
	_trim_groups(SEASONS_PER_CHUNK)


## Potpis sezone: sve što određuje redove i zaglavlje osim napretka unutar reda.
func _season_signature(s: Dictionary) -> String:
	var sid := str(s["sid"])
	var parts := PackedStringArray([sid, str(s["kept"]), str(s["total"]), str(GameState.is_season_playable(sid))])
	for entry in s["entries"]:
		parts.append(str(entry.get("type_id", "")))
	return "|".join(parts)


## Lista = prvih `want` sezona iz _order. Sezona koja je već na istom mjestu s istim
## potpisom i svim redovima samo osvježi redove (bez rušenja); od prve razlike nadalje
## gradi se iznova.
func _sync_groups(want: int) -> void:
	var keep := 0
	while keep < _groups.size() and keep < want:
		var g: Dictionary = _groups[keep]
		var entries: Array = _order[keep]["entries"]
		if str(g["sig"]) != _season_signature(_order[keep]) or (g["rows"] as Array).size() != entries.size():
			break
		keep += 1
	_trim_groups(keep)
	for i in keep:
		var rows: Array = _groups[i]["rows"]
		var entries: Array = _order[i]["entries"]
		for r in rows.size():
			(rows[r] as CollectionJournalRow).apply(entries[r])
	while _groups.size() < want:
		_add_season(_groups.size())


func _add_season(index: int) -> void:
	if list == null or index >= _order.size():
		return
	if list.get_child_count() == 0:
		list.add_child(_spacer(UiJournal.LIST_TOP))
	if _bottom == null or not is_instance_valid(_bottom):
		_bottom = _spacer(UiJournal.LIST_BOTTOM)
		list.add_child(_bottom)
	var s: Dictionary = _order[index]
	var gap: Control = null
	if index > 0:
		gap = _spacer(UiJournal.SEASON_GAP)
		list.add_child(gap)
	var group := VBoxContainer.new()
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.add_theme_constant_override("separation", UiJournal.SEASON_HEADER_GAP)
	group.add_child(_season_header(str(s["sid"]), s))
	list.add_child(group)
	list.move_child(_bottom, list.get_child_count() - 1)
	_groups.append({"sid": s["sid"], "group": group, "gap": gap, "rows": [], "sig": _season_signature(s)})
	for entry in s["entries"]:
		_work.append({"group_index": index, "entry": entry})
	_building = true
	set_process(true)


## Ostavi prvih `count` sezona; ostale (i njihov nedovršen rad) se brišu.
func _trim_groups(count: int) -> void:
	while _groups.size() > count:
		var g: Dictionary = _groups.pop_back()
		for key in ["group", "gap"]:
			var n: Node = g.get(key)
			if n != null and is_instance_valid(n):
				n.get_parent().remove_child(n)
				n.queue_free()
	var kept: Array[Dictionary] = []
	for item in _work:
		if int(item["group_index"]) < _groups.size():
			kept.append(item)
	_work = kept
	_building = not _work.is_empty()
	set_process(_building)
	if _groups.is_empty():
		_clear_list()


func _on_scrolled(_value: float) -> void:
	_maybe_load_more()


## Do kraja učitanog je ostalo malo (ili lista ne puni ekran) — učitaj sljedeće tri.
func _maybe_load_more() -> void:
	if not _active or _building or list == null or list_scroll == null or _groups.size() >= _order.size():
		return
	if not list_scroll.is_visible_in_tree():
		return
	# Visina iz minimalne veličine, ne iz `size`: raspored kontejnera kasni frejm, a stara
	# (mala) visina bi odmah učitala sve sezone.
	var bottom := float(list_scroll.scroll_vertical) + list_scroll.size.y
	if bottom < list.get_combined_minimum_size().y - LOAD_AHEAD_PX:
		return
	var want := mini(_order.size(), _groups.size() + SEASONS_PER_CHUNK)
	while _groups.size() < want:
		_add_season(_groups.size())


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
	_groups.clear()
	_work.clear()
	_building = false
	_bottom = null
	if list == null:
		return
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()


func _on_cosmetics_changed(slots: Array) -> void:
	if slots.has(CosmeticCatalog.SLOT_JOURNAL_FRAME) and golden_edge != null:
		_apply_frame()


func _apply_frame() -> void:
	# Ormar: okvir dolazi iz look.frame opremljene stavke (cosmetics.json).
	var golden := not CosmeticCatalog.get_album_frame(
		GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_JOURNAL_FRAME)
	).is_empty()
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
