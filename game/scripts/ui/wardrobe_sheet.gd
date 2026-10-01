class_name WardrobeSheet
extends Control

## Ormar (design_handoff_wardrobe/design/Wardrobe.dc.html) — treći sheet polja sezone
## (porodica BasketSheet 1326 / UpgradesSheet 922). Gradi se iz CosmeticCatalog:
## ništa ovdje ne zna za konkretan slot. Raspored: SheetHead → PreviewStage 1032 x 300
## (uvijek vidljiv) → SlotTabs 120 → ItemGrid (skrola) → Close.
## Jedan tap = izbor (najviše jedna stavka po slotu; Default skida). Zatvaranje JE
## snimanje: Close, tap na scrim, povlačenje > 160 px i Android back rade isto —
## GameState.apply_wardrobe(pending) na početku zatvaranja (jedan save).

## (pending, changed) — emituje se na POČETKU zatvaranja, poslije snimanja.
signal applied(pending: Dictionary, changed: Array)
## Sheet je sasvim spušten (ApplyMoment na polju kreće odavde).
signal close_finished(changed: Array)
signal shop_requested(slot_id: String)

const OPEN_GROUP := "wardrobe_sheet_open"
const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"

const Y_GRABBER := 23.0
const Y_TITLE := 57.0
const Y_SUB := 125.0
const Y_STAGE := 193.0
const Y_TABS := 517.0
const Y_GRID := 661.0
const Y_CLOSE := 1166.0
const GRID_TOP_PAD := 6.0

var pending: Dictionary = {}
var _saved: Dictionary = {}
var _slot: String = ""
var _season: String = ""
var _is_open: bool = false
var _closing: bool = false
var _changed: Array = []
var _tween: Tween

var _scrim: ColorRect
var _sheet: Panel
var _head: Control
var _title: Label
var _sub: Label
var _stage: Control
var _stage_preview: ItemPreview
var _stage_chips: Control
var _tabs_scroll: ScrollContainer
var _tabs_box: HBoxContainer
var _grid_scroll: ScrollContainer
var _grid: Control
var _close: CloseButton

var _drag_on: bool = false
var _drag_start: float = 0.0
var _drag_y: float = 0.0


func _ready() -> void:
	name = "WardrobeOverlay"
	# Ista ravan kao BasketPickerOverlay / UpgradesOverlay (z 45) — iznad chromea polja.
	z_index = 45
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build()


func is_open() -> bool:
	return _is_open


func is_closing() -> bool:
	return _closing


func current_slot() -> String:
	return _slot


func sheet_node() -> Panel:
	return _sheet


func open_y() -> float:
	return size.y - float(UiWardrobe.SHEET_H)


# ── Otvaranje / zatvaranje ────────────────────────────────────────────────────

func open(season_id: String = "", animated: bool = true) -> void:
	if _is_open:
		return
	_is_open = true
	_closing = false
	_changed = []
	_season = season_id
	_saved = {}
	for sid in CosmeticCatalog.slot_ids():
		var eq := GameState.get_equipped_cosmetic(sid)
		if not eq.is_empty():
			_saved[sid] = eq
	pending = _saved.duplicate()
	var ids := _visible_slot_ids()
	if _slot.is_empty() or not ids.has(_slot):
		_slot = ids[0] if not ids.is_empty() else ""
	visible = true
	add_to_group(OPEN_GROUP)
	add_to_group(BLOCK_HUB_SWIPE_GROUP)
	_rebuild_all()
	_grid_scroll.scroll_vertical = 0
	_kill_tween()
	if animated:
		_sheet.position.y = size.y
		_scrim.modulate.a = 0.0
		_tween = create_tween().set_parallel()
		_tween.tween_property(_sheet, "position:y", open_y(), UiWardrobe.T_OPEN) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_scrim, "modulate:a", 1.0, UiWardrobe.T_OPEN * 0.62)
	else:
		_sheet.position.y = open_y()
		_scrim.modulate.a = 1.0
	call_deferred("_ensure_tab_visible")


## Zatvori i primijeni. Prihvata zatvaranje usred otvaranja (tween iz trenutnog
## položaja, trajanje × preostali put).
func close(animated: bool = true) -> void:
	if not _is_open or _closing:
		return
	_closing = true
	_changed = GameState.apply_wardrobe(pending)
	GameState.cosmetics.mark_wardrobe_seen()
	applied.emit(pending.duplicate(), _changed.duplicate())
	_kill_tween()
	var travel := maxf(0.0, size.y - _sheet.position.y)
	var u := clampf(travel / float(UiWardrobe.SHEET_H), 0.0, 1.0)
	if not animated or u <= 0.001:
		_finish_close()
		return
	_tween = create_tween().set_parallel()
	_tween.tween_property(_sheet, "position:y", size.y, UiWardrobe.T_CLOSE * u) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(_scrim, "modulate:a", 0.0, UiWardrobe.T_CLOSE * u)
	_tween.chain().tween_callback(_finish_close)


func _finish_close() -> void:
	_kill_tween()
	_is_open = false
	_closing = false
	_drag_on = false
	visible = false
	if is_in_group(OPEN_GROUP):
		remove_from_group(OPEN_GROUP)
	if is_in_group(BLOCK_HUB_SWIPE_GROUP):
		remove_from_group(BLOCK_HUB_SWIPE_GROUP)
	close_finished.emit(_changed.duplicate())


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null


func _unhandled_input(event: InputEvent) -> void:
	if not _is_open or _closing or event.is_echo():
		return
	var back := event.is_action_pressed("ui_cancel")
	if not back and event is InputEventKey:
		var k := event as InputEventKey
		back = k.pressed and k.keycode == KEY_ESCAPE
	if back:
		get_viewport().set_input_as_handled()
		close()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and _is_open:
		close()
	elif what == NOTIFICATION_RESIZED and _sheet != null and _is_open and not _closing and _tween == null:
		_sheet.position.y = open_y()


# ── Izbor ─────────────────────────────────────────────────────────────────────

## Tap na karticu: id "" = Default. Ista stavka ponovo = samo skok na pozornici.
func pick(slot_id: String, item_id: String) -> void:
	if _closing:
		return
	if str(pending.get(slot_id, "")) != item_id:
		if item_id.is_empty():
			pending.erase(slot_id)
		else:
			pending[slot_id] = item_id
		_sync_cards()
		_refresh_stage()
	_stage_preview.hop()


func select_slot(slot_id: String) -> void:
	if slot_id == _slot or not CosmeticCatalog.get_slot_def(slot_id).has("id"):
		return
	_slot = slot_id
	_rebuild_tabs()
	_rebuild_grid()
	_refresh_stage()
	_grid_scroll.scroll_vertical = 0
	call_deferred("_ensure_tab_visible")


func changed_slots() -> Array:
	var out: Array = []
	for sid in CosmeticCatalog.slot_ids():
		if str(_saved.get(sid, "")) != str(pending.get(sid, "")):
			out.append(sid)
	return out


# ── Gradnja ───────────────────────────────────────────────────────────────────

func _build() -> void:
	_scrim = ColorRect.new()
	_scrim.name = "WardrobeScrim"
	_scrim.color = UiWardrobe.SCRIM
	_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_scrim.gui_input.connect(_on_scrim_input)
	add_child(_scrim)

	_sheet = Panel.new()
	_sheet.name = "WardrobeSheet"
	_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	_sheet.add_theme_stylebox_override("panel", UiWardrobe.sheet())
	_sheet.size = Vector2(UiHomeField.PAGE.x, UiWardrobe.SHEET_H)
	_sheet.position = Vector2(0.0, float(UiHomeField.PAGE.y))
	add_child(_sheet)

	_head = Control.new()
	_head.name = "SheetHead"
	_head.mouse_filter = Control.MOUSE_FILTER_STOP
	_head.mouse_default_cursor_shape = Control.CURSOR_DRAG
	_head.position = Vector2.ZERO
	_head.size = Vector2(UiHomeField.PAGE.x, Y_STAGE - 8.0)
	_head.gui_input.connect(_on_head_input)
	_head.draw.connect(_draw_grabber)
	_sheet.add_child(_head)

	_title = Label.new()
	_title.name = "SheetTitle"
	_title.text = UiWardrobe.TITLE
	UiStage.style(_title, 900, UiWardrobe.TITLE_PX, UiWardrobe.INK)
	_title.position = Vector2(UiWardrobe.SHEET_PAD.x, Y_TITLE)
	_head.add_child(_title)
	_sub = Label.new()
	_sub.name = "SheetSub"
	_sub.text = UiWardrobe.SUB
	UiStage.style(_sub, 800, UiWardrobe.SUB_PX, UiWardrobe.INK_SOFT)
	_sub.position = Vector2(UiWardrobe.SHEET_PAD.x, Y_SUB)
	_head.add_child(_sub)

	_stage = Control.new()
	_stage.name = "PreviewStage"
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.position = Vector2(UiWardrobe.SHEET_PAD.x, Y_STAGE)
	_stage.size = Vector2(UiWardrobe.STAGE)
	_sheet.add_child(_stage)
	_stage_preview = ItemPreview.new()
	_stage_preview.name = "ItemPreview"
	_stage_preview.preview_size = ItemPreview.SIZE_STAGE
	_stage_preview.size = Vector2(UiWardrobe.STAGE)
	_stage_preview.set_frame(
		float(UiWardrobe.STAGE_BORDER), float(UiWardrobe.STAGE_RADIUS), UiWardrobe.STICKER_EDGE, UiWardrobe.STICKER
	)
	_stage.add_child(_stage_preview)
	_stage_chips = StageChips.new()
	_stage_chips.name = "StageChips"
	_stage_chips.size = Vector2(UiWardrobe.STAGE)
	_stage.add_child(_stage_chips)

	_tabs_scroll = ScrollContainer.new()
	_tabs_scroll.name = "SlotTabs"
	_tabs_scroll.position = Vector2(UiWardrobe.SHEET_PAD.x, Y_TABS)
	_tabs_scroll.size = Vector2(UiWardrobe.STAGE.x, UiWardrobe.TAB_H)
	_tabs_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_tabs_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tabs_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	_sheet.add_child(_tabs_scroll)
	_tabs_box = HBoxContainer.new()
	_tabs_box.name = "Tabs"
	_tabs_box.add_theme_constant_override("separation", UiWardrobe.TAB_GAP)
	_tabs_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tabs_box.custom_minimum_size = Vector2(0, UiWardrobe.TAB_H)
	_tabs_scroll.add_child(_tabs_box)

	_grid_scroll = ScrollContainer.new()
	_grid_scroll.name = "ItemGrid"
	_grid_scroll.position = Vector2(UiWardrobe.SHEET_PAD.x, Y_GRID - GRID_TOP_PAD)
	_grid_scroll.size = Vector2(UiWardrobe.STAGE.x, UiWardrobe.GRID_VIEW_H + GRID_TOP_PAD)
	_grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_grid_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_grid_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	_sheet.add_child(_grid_scroll)
	_grid = Control.new()
	_grid.name = "Grid"
	_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grid_scroll.add_child(_grid)

	_close = CloseButton.new()
	_close.name = "CloseButton"
	_close.position = Vector2(UiWardrobe.SHEET_PAD.x, Y_CLOSE)
	_close.size = Vector2(UiWardrobe.STAGE.x, UiWardrobe.CLOSE_H)
	_close.tapped.connect(close)
	_sheet.add_child(_close)


func _draw_grabber() -> void:
	var g := Vector2(UiWardrobe.GRABBER)
	var r := Rect2(Vector2((_head.size.x - g.x) * 0.5, Y_GRABBER), g)
	_head.draw_style_box(UiStage.box(UiWardrobe.GRABBER_FILL, int(g.y / 2.0)), r)


func _visible_slot_ids() -> Array[String]:
	return CosmeticCatalog.slot_ids()


func _rebuild_all() -> void:
	_rebuild_tabs()
	_rebuild_grid()
	_refresh_stage()


func _rebuild_tabs() -> void:
	for c in _tabs_box.get_children():
		_tabs_box.remove_child(c)
		c.queue_free()
	var slots := CosmeticCatalog.slots()
	var widths: Array = []
	for sd in slots:
		widths.append(UiWardrobe.tab_width(UiHomeV3.text_w(900, UiWardrobe.TAB_FONT, str(sd.get("title", "")))))
	var fill := UiWardrobe.tabs_fill(widths)
	var n := slots.size()
	var fill_w := (float(UiWardrobe.STAGE.x) - float(UiWardrobe.TAB_GAP * maxi(0, n - 1))) / float(maxi(1, n))
	for i in n:
		var sd: Dictionary = slots[i]
		var sid := str(sd.get("id", ""))
		var tab := SlotTab.new()
		tab.name = "SlotTab_%s" % sid
		tab.slot_id = sid
		tab.title = str(sd.get("title", sid))
		tab.icon = UiWardrobe.icon(str(sd.get("icon", "")))
		tab.active = sid == _slot
		tab.dot = _slot_has_new(sid)
		var w := fill_w if fill else float(widths[i])
		tab.custom_minimum_size = Vector2(floorf(w), UiWardrobe.TAB_H)
		tab.tapped.connect(select_slot.bind(sid))
		_tabs_box.add_child(tab)


func _ensure_tab_visible() -> void:
	for t in _tabs_box.get_children():
		var tab := t as SlotTab
		if tab == null or not tab.active:
			continue
		var x := tab.position.x
		var w := tab.size.x
		var view := _tabs_scroll.size.x
		var s := float(_tabs_scroll.scroll_horizontal)
		if x + w > s + view - float(UiWardrobe.TAB_EDGE_KEEP) or x < s:
			_tabs_scroll.scroll_horizontal = int(maxf(0.0, x - float(UiWardrobe.TAB_EDGE_KEEP)))


func _slot_has_new(slot_id: String) -> bool:
	for it in CosmeticCatalog.items_in_slot(slot_id):
		if GameState.cosmetics.is_new(str(it.get("id", ""))):
			return true
	return false


func _pip_recolor() -> Dictionary:
	return CosmeticCatalog.get_recolor(str(pending.get(CosmeticCatalog.SLOT_PIP_SKIN, "")))


func _rebuild_grid() -> void:
	for c in _grid.get_children():
		_grid.remove_child(c)
		c.queue_free()
	var sd := CosmeticCatalog.get_slot_def(_slot)
	if sd.is_empty():
		return
	var items := CosmeticCatalog.items_in_slot(_slot)
	var by_id := {}
	for it in items:
		by_id[str(it.get("id", ""))] = it
	var cells := UiWardrobe.grid_cells(sd, items, GameState.cosmetics.owned)
	var worn := str(pending.get(_slot, ""))
	var pip := _pip_recolor()
	var index := 0
	for cell in cells:
		var pos := Vector2(UiWardrobe.cell_pos(index)) + Vector2(0.0, GRID_TOP_PAD)
		if cell == "@shop":
			var link := ShopLinkCell.new()
			link.name = "ShopLink"
			link.position = pos
			link.tapped.connect(_on_shop_link)
			_grid.add_child(link)
			index += 1
		elif cell == "@empty":
			var empty := EmptyState.new()
			empty.name = "EmptyState"
			empty.text = str(sd.get("empty_text", ""))
			empty.position = pos
			empty.shop_tapped.connect(_on_shop_link)
			_grid.add_child(empty)
			index += UiWardrobe.EMPTY_SPAN
		else:
			var item: Dictionary = by_id.get(cell, {})
			var owned := cell.is_empty() or GameState.owns_cosmetic(cell)
			var state := UiWardrobe.card_state(cell, owned, worn)
			var card := ItemCard.new()
			card.position = pos
			_grid.add_child(card)
			card.setup(sd, item, state, not cell.is_empty() and GameState.cosmetics.is_new(cell), pip, _season)
			card.tapped.connect(pick.bind(_slot, cell))
			index += 1
	var rows := UiWardrobe.grid_rows(cells)
	var h := GRID_TOP_PAD + float(rows) * float(UiWardrobe.CARD.y) + float(maxi(0, rows - 1)) * float(UiWardrobe.CARD_GAP) + float(UiWardrobe.CARD_GAP)
	_grid.custom_minimum_size = Vector2(UiWardrobe.STAGE.x, h)
	_grid.size = _grid.custom_minimum_size


func _sync_cards() -> void:
	var worn := str(pending.get(_slot, ""))
	var pip := _pip_recolor()
	var sd := CosmeticCatalog.get_slot_def(_slot)
	for c in _grid.get_children():
		var card := c as ItemCard
		if card == null:
			continue
		var owned := card.is_default() or GameState.owns_cosmetic(card.item_id)
		card.set_state(UiWardrobe.card_state(card.item_id, owned, worn))
		# meadow pregled nosi Pipa u izabranom skinu.
		if str(sd.get("preview", "")) == "meadow":
			card.preview.pip_recolor = pip
			card.preview.queue_redraw()


func _refresh_stage() -> void:
	var sd := CosmeticCatalog.get_slot_def(_slot)
	var worn := str(pending.get(_slot, ""))
	var args: Dictionary = sd.get("preview_args", {})
	_stage_preview.configure(
		str(sd.get("preview", "swatch")), CosmeticCatalog.get_look(worn), _pip_recolor(), _season,
		str(args.get("subject", "pip"))
	)
	var chips := _stage_chips as StageChips
	chips.name_text = CosmeticCatalog.get_title(worn) if not worn.is_empty() else str(sd.get("default_title", ""))
	chips.where_text = UiWardrobe.where_text(sd.get("applies_to", []), CosmeticCatalog.surfaces())
	chips.queue_redraw()


# ── Ulaz ──────────────────────────────────────────────────────────────────────

func _on_scrim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_scrim.accept_event()
			close()


func _on_head_input(event: InputEvent) -> void:
	if _closing:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		_head.accept_event()
		if mb.pressed:
			_drag_on = true
			_drag_start = mb.global_position.y
			_drag_y = 0.0
			_kill_tween()
		elif _drag_on:
			_drag_on = false
			if _drag_y > float(UiWardrobe.DRAG_CLOSE_PX):
				close()
			else:
				_kill_tween()
				_tween = create_tween()
				_tween.tween_property(_sheet, "position:y", open_y(), UiWardrobe.T_SNAP) \
					.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				_tween.tween_callback(func() -> void: _tween = null)
	elif event is InputEventMouseMotion and _drag_on:
		var mm := event as InputEventMouseMotion
		_head.accept_event()
		var k := get_global_transform_with_canvas().get_scale().y
		_drag_y = maxf(0.0, (mm.global_position.y - _drag_start) / maxf(0.001, k))
		_sheet.position.y = open_y() + _drag_y


## Za smoke testove: povlačenje sheeta za `dy` px pa otpuštanje.
func simulate_drag(dy: float) -> void:
	_drag_y = maxf(0.0, dy)
	_sheet.position.y = open_y() + _drag_y
	if _drag_y > float(UiWardrobe.DRAG_CLOSE_PX):
		close()
	else:
		_sheet.position.y = open_y()


func _on_shop_link() -> void:
	shop_requested.emit(_slot)


# ── Za smoke testove ──────────────────────────────────────────────────────────

func get_cards() -> Array[ItemCard]:
	var out: Array[ItemCard] = []
	for c in _grid.get_children():
		if c is ItemCard and not c.is_queued_for_deletion():
			out.append(c as ItemCard)
	return out


func get_card(item_id: String) -> ItemCard:
	for card in get_cards():
		if card.item_id == item_id:
			return card
	return null


func get_tabs() -> Array[SlotTab]:
	var out: Array[SlotTab] = []
	for c in _tabs_box.get_children():
		if c is SlotTab and not c.is_queued_for_deletion():
			out.append(c as SlotTab)
	return out


func grid_cell_nodes() -> Array[Control]:
	var out: Array[Control] = []
	for c in _grid.get_children():
		if not c.is_queued_for_deletion():
			out.append(c as Control)
	return out


func stage_preview() -> ItemPreview:
	return _stage_preview


func stage_texts() -> PackedStringArray:
	var chips := _stage_chips as StageChips
	return PackedStringArray([chips.name_text, chips.where_text])


func close_button() -> WardrobePressable:
	return _close


func grid_scroll() -> ScrollContainer:
	return _grid_scroll


func tabs_scroll() -> ScrollContainer:
	return _tabs_scroll


# ══ Unutrašnje komponente ═════════════════════════════════════════════════════

## StageName (lijevo dolje, 900 40) i StageWhere (desno gore, 800 36) — chipovi.
class StageChips extends Control:
	var name_text: String = ""
	var where_text: String = ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var inset := float(UiWardrobe.STAGE_CHIP_INSET)
		if not name_text.is_empty():
			var tw := UiHomeV3.text_w(900, 40, name_text)
			var r := Rect2(inset, size.y - inset - float(UiWardrobe.STAGE_CHIP_H), tw + 40.0 + 4.0, float(UiWardrobe.STAGE_CHIP_H))
			draw_style_box(UiWardrobe.label_chip(18), r)
			UiHomeV3.draw_text(self, 900, 40, name_text, Vector2(r.position.x + 22.0, r.position.y + (r.size.y - 40.0) * 0.5), UiWardrobe.STICKER)
		if not where_text.is_empty():
			var tw2 := UiHomeV3.text_w(800, 36, where_text)
			var w2 := tw2 + 36.0 + 4.0
			var r2 := Rect2(size.x - inset - w2, inset, w2, float(UiWardrobe.WHERE_CHIP_H))
			draw_style_box(UiWardrobe.label_chip(16), r2)
			UiHomeV3.draw_text(self, 800, 36, where_text, Vector2(r2.position.x + 20.0, r2.position.y + (r2.size.y - 36.0) * 0.5), UiWardrobe.STICKER)


## SlotTab: ikona 56 + naslov 40/900; aktivni = PEACH + rub 3 ink (navigacija),
## mirni = bijeli + ROW_EDGE. Tačka „new" 36 gore desno.
class SlotTab extends WardrobePressable:
	var slot_id: String = ""
	var title: String = ""
	var icon: Texture2D
	var active: bool = false
	var dot: bool = false

	func _ready() -> void:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_style_box(UiWardrobe.tab(active), r)
		var tw := UiHomeV3.text_w(900, UiWardrobe.TAB_FONT, title)
		var content := float(UiWardrobe.TAB_ICON + UiWardrobe.TAB_INNER_GAP) + tw
		var x := maxf(float(UiWardrobe.TAB_PAD_X), (size.x - content) * 0.5)
		var ic := float(UiWardrobe.TAB_ICON)
		if icon != null:
			draw_texture_rect(icon, Rect2(Vector2(x, (size.y - ic) * 0.5), Vector2(ic, ic)), false)
		UiHomeV3.draw_text(
			self, 900, UiWardrobe.TAB_FONT, title,
			Vector2(x + ic + float(UiWardrobe.TAB_INNER_GAP), (size.y - float(UiWardrobe.TAB_FONT)) * 0.5), UiWardrobe.INK
		)
		if dot:
			var d := Rect2(size.x - 28.0, -8.0, 36.0, 36.0)
			draw_style_box(UiStage.box(UiWardrobe.MINT, 18, 4, UiWardrobe.INK), d)


## ShopLink ćelija mreže (240 x 272, isprekidan rub) — jedini put u Shop iz ormara.
class ShopLinkCell extends WardrobePressable:
	var _icon: Texture2D

	func _ready() -> void:
		custom_minimum_size = Vector2(UiWardrobe.CARD)
		size = custom_minimum_size
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_icon = UiWardrobe.icon(UiWardrobe.ICON_SHOP)

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		if is_pressed():
			draw_style_box(UiStage.box(UiWardrobe.PRESSED_TINT, UiWardrobe.CARD_RADIUS), r)
		UiHomeV3.draw_dashed_round_rect(self, r, float(UiWardrobe.CARD_RADIUS), 3.0, UiWardrobe.DASH_EDGE)
		var f := UiStage.font(900, 38)
		var lines := UiStage.balance_lines(UiWardrobe.SHOP_LINK, f, 38, size.x - 30.0)
		var total := 72.0 + 16.0 + 40.0 * float(lines.size())
		var y := (size.y - total) * 0.5
		if _icon != null:
			draw_texture_rect(_icon, Rect2(Vector2((size.x - 72.0) * 0.5, y), Vector2(72, 72)), false)
		y += 72.0 + 16.0
		for line in lines:
			var w := UiHomeV3.text_w(900, 38, line)
			UiHomeV3.draw_text(self, 900, 38, line, Vector2((size.x - w) * 0.5, y + 1.0), UiWardrobe.INK)
			y += 40.0


## Dugme „More in Shop" (EmptyState): bijelo, rub 3 ink, tvrda sjena 6.
class ShopButton extends WardrobePressable:
	var _icon: Texture2D

	func _ready() -> void:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_icon = UiWardrobe.icon(UiWardrobe.ICON_SHOP)
		var w := 22.0 + 64.0 + 16.0 + UiHomeV3.text_w(900, 44, UiWardrobe.SHOP_LINK) + 32.0
		custom_minimum_size = Vector2(ceilf(w), UiWardrobe.SHOP_BTN_H)
		size = custom_minimum_size

	func _draw() -> void:
		var off := 4.0 if is_pressed() else 0.0
		var r := Rect2(Vector2(0.0, off), size)
		draw_style_box(UiWardrobe.shop_button(is_pressed()), r)
		if _icon != null:
			draw_texture_rect(_icon, Rect2(Vector2(22.0, off + (size.y - 64.0) * 0.5), Vector2(64, 64)), false)
		UiHomeV3.draw_text(self, 900, 44, UiWardrobe.SHOP_LINK, Vector2(22.0 + 64.0 + 16.0, off + (size.y - 44.0) * 0.5), UiWardrobe.INK)


## EmptyState: slot bez ijedne tvoje stavke — rečenica slota + ShopLink dugme,
## preko 3 kolone (768 x 272), isprekidan rub.
class EmptyState extends Control:
	signal shop_tapped
	var text: String = ""
	var _label: Label
	var _button: ShopButton

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_PASS
		var w := float(UiWardrobe.CARD.x * UiWardrobe.EMPTY_SPAN + UiWardrobe.CARD_GAP * (UiWardrobe.EMPTY_SPAN - 1))
		custom_minimum_size = Vector2(w, UiWardrobe.CARD.y)
		size = custom_minimum_size
		_label = Label.new()
		_label.name = "EmptyText"
		_label.text = text
		_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStage.style(_label, 800, 40, UiWardrobe.INK, 1.15)
		_label.position = Vector2(32, 28)
		_label.size = Vector2(w - 64.0, 96.0)
		add_child(_label)
		_button = ShopButton.new()
		_button.name = "ShopLink"
		add_child(_button)
		_button.position = Vector2(32.0, size.y - 28.0 - float(UiWardrobe.SHOP_BTN_H))
		_button.tapped.connect(func() -> void: shop_tapped.emit())

	func shop_button() -> WardrobePressable:
		return _button

	func _draw() -> void:
		UiHomeV3.draw_dashed_round_rect(self, Rect2(Vector2.ZERO, size), float(UiWardrobe.CARD_RADIUS), 3.0, UiWardrobe.DASH_EDGE)


## Close 1032 x 132 — zatvori i primijeni (nema Save).
class CloseButton extends WardrobePressable:
	func _ready() -> void:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	func _draw() -> void:
		draw_style_box(UiWardrobe.close_button(is_pressed()), Rect2(Vector2.ZERO, size))
		var w := UiHomeV3.text_w(900, 46, UiWardrobe.CLOSE_TEXT)
		UiHomeV3.draw_text(self, 900, 46, UiWardrobe.CLOSE_TEXT, Vector2((size.x - w) * 0.5, (size.y - 46.0) * 0.5), UiWardrobe.INK)
