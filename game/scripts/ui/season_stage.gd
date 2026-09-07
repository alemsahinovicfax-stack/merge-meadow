extends Control

## Home Season Stage — dual-band + in-card roster (HOME-08 A).

const CONTRAST := preload("res://scripts/ui/season_card_contrast.gd")

const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const SWIPE_LOCK_PX := 20.0
const SNAP_SEC := 0.22
const BAND_TWEEN_SEC := 0.25
const PREVIEW_MIN := 110.0
const HERO_MIN := 300.0
const RATIO_HERO := 4.0
const RATIO_PREVIEW := 1.0
const STRETCH_CENTER := 1.35
const STRETCH_SIDE := 1.0
const FONT_HERO_CENTER := 28
const FONT_HERO_SIDE := 20
const FONT_PREVIEW_CENTER := 16
const FONT_PREVIEW_SIDE := 14
const PRESS_NONE := 0
const PRESS_PAID := 1
const PRESS_FREE := 2

@onready var paid_band: Control = %PaidBand
@onready var free_band: Control = %FreeBand
@onready var paid_motion: Control = %PaidMotion
@onready var strip_motion: Control = %StripMotion
@onready var paid_row: HBoxContainer = %PaidRow
@onready var row: HBoxContainer = $BandColumn/FreeBand/StripMotion/Row
@onready var paid_left_slot: PanelContainer = %PaidLeftSlot
@onready var paid_center_slot: PanelContainer = %PaidCenterSlot
@onready var paid_right_slot: PanelContainer = %PaidRightSlot
@onready var paid_left_title: Label = %PaidLeftTitle
@onready var paid_center_title: Label = %PaidCenterTitle
@onready var paid_right_title: Label = %PaidRightTitle
@onready var left_slot: PanelContainer = %LeftSlot
@onready var center_slot: PanelContainer = %CenterSlot
@onready var right_slot: PanelContainer = %RightSlot
@onready var left_title: Label = %LeftTitle
@onready var center_title: Label = %CenterTitle
@onready var right_title: Label = %RightTitle
@onready var browser: Control = %SeasonBrowser
@onready var unlock_sheet: Control = %SeasonUnlockSheet
@onready var free_roster: Control = %FreeRoster
@onready var paid_roster: Control = %PaidRoster
@onready var unlock_gate: Control = %UnlockGate
@onready var band_column: Control = %BandColumn
@onready var season_field: Control = %SeasonField

var _pressing: bool = false
var _swiped: bool = false
var _press_band: int = PRESS_NONE
var _press_start: Vector2 = Vector2.ZERO
var _bounce_tween: Tween = null
var _band_tween: Tween = null
var _slide_busy: bool = false
var _band_tween_busy: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_to_group(BLOCK_HUB_SWIPE_GROUP)
	gui_input.connect(_on_stage_gui_input)
	if paid_motion:
		_ignore_hits(paid_motion)
	if strip_motion:
		_ignore_hits(strip_motion)
	if browser:
		if browser.has_signal("unlock_requested"):
			browser.unlock_requested.connect(open_unlock_sheet)
		if browser.has_signal("season_selected"):
			browser.season_selected.connect(_on_browser_selected)
	if unlock_sheet and unlock_sheet.has_signal("unlocked"):
		unlock_sheet.unlocked.connect(_on_unlocked)
	if unlock_gate and unlock_gate.has_signal("unlock_clicked"):
		unlock_gate.unlock_clicked.connect(_on_gate_unlocked)
	var seasons_btn: Control = get_node_or_null("%SeasonsButton") as Control
	if seasons_btn:
		seasons_btn.visible = false
		seasons_btn.set("label_text", "")
	refresh()


func _ignore_hits(n: Control) -> void:
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		if c is Control:
			_ignore_hits(c as Control)


func refresh() -> void:
	_fill_strips()
	if not _band_tween_busy:
		_apply_band_heights()
	_refresh_unlock_gate()
	_refresh_roster()
	_sync_season_field()
	_notify_home_badge()


func _fill_strips() -> void:
	_fill_free_slots()
	_fill_paid_slots()


func _apply_band_heights() -> void:
	var paid_hero := GameState.home_band == "paid"
	if paid_band:
		paid_band.size_flags_stretch_ratio = RATIO_HERO if paid_hero else RATIO_PREVIEW
		paid_band.custom_minimum_size.y = HERO_MIN if paid_hero else PREVIEW_MIN
	if free_band:
		free_band.size_flags_stretch_ratio = RATIO_PREVIEW if paid_hero else RATIO_HERO
		free_band.custom_minimum_size.y = PREVIEW_MIN if paid_hero else HERO_MIN


func cycle_free_strip(dir: int) -> void:
	if GameState.home_band == "paid":
		return
	if not _can_cycle(dir):
		_play_bounce(row)
		return
	_play_slide(dir)


func cycle_paid_strip(dir: int) -> void:
	if not _can_cycle_paid(dir):
		_play_bounce(paid_row)
		return
	_play_paid_slide(dir)


func swap_home_band(to_band: String, focus_id: String) -> void:
	if _band_tween_busy or _slide_busy:
		return
	var target := "paid" if to_band == "paid" else "free"
	if target == "paid":
		if not focus_id.is_empty():
			GameState.set_paid_strip_focus(focus_id)
			if GameState.is_season_playable(focus_id):
				GameState.set_active_season(focus_id)
	elif not focus_id.is_empty():
		if GameState.is_season_playable(focus_id):
			GameState.set_active_season(focus_id)
		elif GameState.is_free_selectable(focus_id):
			GameState.set_free_strip_focus(focus_id)
	var already := GameState.home_band == target
	if already:
		_fill_strips()
		_refresh_unlock_gate()
		_refresh_roster()
		_notify_home_badge()
		return
	GameState.set_home_band(target)
	_fill_strips()
	_refresh_unlock_gate()
	_refresh_roster()
	_tween_band_heights()


func open_unlock_sheet(season_id: String) -> void:
	if unlock_sheet and unlock_sheet.has_method("open_unlock_sheet"):
		unlock_sheet.call("open_unlock_sheet", season_id)


func open_browser() -> void:
	if browser and browser.has_method("open_browser"):
		browser.call("open_browser")


func open_season_field() -> bool:
	if not GameState.open_home_season_field():
		return false
	if browser and browser.visible and browser.has_method("close"):
		browser.call("close")
	_sync_season_field()
	return true


func close_season_field() -> void:
	GameState.close_home_season_field()
	_sync_season_field()
	refresh()


func snap_carousel_to_active() -> bool:
	if GameState.home_season_field_open:
		return false
	var id := GameState.active_season_id
	if id.is_empty() or not GameState.is_season_playable(id):
		id = SeasonCatalog.DEFAULT_SEASON_ID
	var def: SeasonDef = GameState.get_season_def(id)
	if def == null:
		return false
	if _band_tween:
		_band_tween.kill()
		_band_tween = null
	_band_tween_busy = false
	var band := "paid" if def.is_paid() else "free"
	GameState.set_home_band(band)
	if def.is_paid():
		GameState.set_paid_strip_focus(id)
	else:
		GameState.set_free_strip_focus(id)
	refresh()
	_apply_band_heights()
	return true


func _sync_season_field() -> void:
	var open := GameState.home_season_field_open
	if open:
		if is_in_group(BLOCK_HUB_SWIPE_GROUP):
			remove_from_group(BLOCK_HUB_SWIPE_GROUP)
	elif not is_in_group(BLOCK_HUB_SWIPE_GROUP):
		add_to_group(BLOCK_HUB_SWIPE_GROUP)
	if band_column:
		band_column.visible = not open
	if season_field:
		season_field.visible = open
		season_field.mouse_filter = (
			Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
		)
		if open and season_field.has_method("apply_season"):
			season_field.call("apply_season", GameState.home_season_field_id)
		elif not open and season_field.has_method("dismiss_flowers"):
			season_field.call("dismiss_flowers")
	var seasons_btn: Control = get_node_or_null("%SeasonsButton") as Control
	if seasons_btn:
		seasons_btn.visible = false
	_notify_home_field_backdrop()


func _is_hub_on_home() -> bool:
	if not is_inside_tree():
		return true
	var hubs := get_tree().get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		return true
	var hub: Node = hubs[0]
	if hub.has_method("current_page_index"):
		return int(hub.call("current_page_index")) == MetaHubPages.MAIN
	return true


func _try_close_field_on_back() -> bool:
	if not GameState.home_season_field_open:
		return false
	if not is_visible_in_tree():
		return false
	if not _is_hub_on_home():
		return false
	close_season_field()
	return true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	var back := false
	if event.is_action_pressed("ui_cancel"):
		back = true
	elif event is InputEventKey:
		var key := event as InputEventKey
		back = key.pressed and key.keycode == KEY_ESCAPE
	if not back:
		return
	if _try_close_field_on_back():
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_try_close_field_on_back()


func _notify_home_field_backdrop() -> void:
	var n: Node = get_parent()
	while n:
		if n.has_method("sync_field_backdrop"):
			n.call("sync_field_backdrop")
			return
		n = n.get_parent()


func _on_browser_selected(season_id: String) -> void:
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		refresh()
		return
	var band := "paid" if def.is_paid() else "free"
	swap_home_band(band, season_id)


func _on_unlocked(_season_id: String) -> void:
	refresh()
	if browser and browser.visible and browser.has_method("open_browser"):
		browser.call("open_browser")


func _on_gate_unlocked() -> void:
	refresh()


func _overlay_blocks_input() -> bool:
	if browser and browser.visible:
		return true
	if unlock_sheet and unlock_sheet.visible:
		return true
	return false


func _on_stage_gui_input(event: InputEvent) -> void:
	if GameState.home_season_field_open:
		accept_event()
		return
	if _slide_busy or _band_tween_busy or _overlay_blocks_input():
		accept_event()
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			_begin_press(mb.position)
		else:
			_end_press(mb.position)
		accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_begin_press(touch.position)
		else:
			_end_press(touch.position)
		accept_event()
	elif event is InputEventMouseMotion and _pressing:
		_update_press((event as InputEventMouseMotion).position)
		accept_event()
	elif event is InputEventScreenDrag and _pressing:
		_update_press((event as InputEventScreenDrag).position)
		accept_event()


func _begin_press(pos: Vector2) -> void:
	if _overlay_blocks_input() or _band_tween_busy or _slide_busy:
		return
	_pressing = true
	_swiped = false
	_press_band = _band_at(pos)
	_press_start = pos


func _update_press(pos: Vector2) -> void:
	if not _pressing or _swiped or _slide_busy or _band_tween_busy:
		return
	if _press_band == PRESS_NONE:
		return
	var dx := pos.x - _press_start.x
	var dy := pos.y - _press_start.y
	if maxf(absf(dx), absf(dy)) < SWIPE_LOCK_PX:
		return
	_swiped = true
	if absf(dy) >= absf(dx):
		_on_vertical_swipe(dy)
		return
	if _is_preview_press():
		return
	var dir := 1 if dx < 0.0 else -1
	if _press_band == PRESS_PAID:
		cycle_paid_strip(dir)
	elif _press_band == PRESS_FREE:
		cycle_free_strip(dir)


func _on_vertical_swipe(dy: float) -> void:
	if dy > 0.0:
		_select_focused_or_last_playable()
		return
	_play_bounce(_hero_row())


func _select_focused_or_last_playable() -> void:
	var focus := GameState.home_hero_center_id()
	if GameState.is_season_playable(focus):
		GameState.set_active_season(focus)
		refresh()
		return
	var pick := GameState.last_playable_for_home_select()
	if not pick.is_empty():
		GameState.set_active_season(pick, false)
	refresh()


func _hero_row() -> Control:
	return paid_row if GameState.home_band == "paid" else row


func _end_press(pos: Vector2) -> void:
	if _pressing and not _swiped and not _slide_busy and not _band_tween_busy:
		_handle_tap(pos)
	_pressing = false
	_swiped = false
	_press_band = PRESS_NONE


func _band_at(local_pos: Vector2) -> int:
	if not is_inside_tree():
		return PRESS_NONE
	var global_pos := get_global_transform() * local_pos
	if paid_band and paid_band.get_global_rect().has_point(global_pos):
		return PRESS_PAID
	if free_band and free_band.get_global_rect().has_point(global_pos):
		return PRESS_FREE
	return PRESS_NONE


func _is_preview_press() -> bool:
	if GameState.home_band == "paid":
		return _press_band == PRESS_FREE
	return _press_band == PRESS_PAID


func _handle_tap(pos: Vector2) -> void:
	if GameState.home_season_field_open:
		return
	if _slide_busy or _band_tween_busy or _overlay_blocks_input():
		return
	if not is_inside_tree():
		return
	var global_pos := get_global_transform() * pos
	if _try_tap_paid(global_pos):
		return
	_try_tap_free(global_pos)


func _try_tap_paid(global_pos: Vector2) -> bool:
	if paid_left_slot and paid_left_slot.visible and paid_left_slot.get_global_rect().has_point(global_pos):
		_on_paid_slot_tapped(GameState.paid_left_id(), "left")
		return true
	if paid_right_slot and paid_right_slot.visible and paid_right_slot.get_global_rect().has_point(global_pos):
		_on_paid_slot_tapped(GameState.paid_right_id(), "right")
		return true
	if paid_center_slot and paid_center_slot.visible and paid_center_slot.get_global_rect().has_point(global_pos):
		_on_paid_slot_tapped(GameState.paid_center_id(), "center")
		return true
	return false


func _try_tap_free(global_pos: Vector2) -> bool:
	if left_slot and left_slot.visible and left_slot.get_global_rect().has_point(global_pos):
		_on_free_slot_tapped(GameState.strip_left_id(), "left")
		return true
	if right_slot and right_slot.visible and right_slot.get_global_rect().has_point(global_pos):
		_on_free_slot_tapped(GameState.strip_right_id(), "right")
		return true
	if center_slot and center_slot.visible and center_slot.get_global_rect().has_point(global_pos):
		_on_free_slot_tapped(GameState.strip_center_id(), "center")
		return true
	return false


func _on_paid_slot_tapped(season_id: String, which: String) -> void:
	if season_id.is_empty():
		return
	var paid_is_hero := GameState.home_band == "paid"
	if not paid_is_hero:
		swap_home_band("paid", season_id)
		return
	if which == "center":
		if GameState.is_season_playable(season_id):
			open_season_field()
		else:
			open_browser()
		return
	cycle_paid_strip(-1 if which == "left" else 1)


func _on_free_slot_tapped(season_id: String, which: String) -> void:
	if season_id.is_empty():
		return
	var free_is_hero := GameState.home_band != "paid"
	if not free_is_hero:
		if GameState.is_free_selectable(season_id) or GameState.is_season_playable(season_id):
			swap_home_band("free", season_id)
			return
		swap_home_band("free", "")
		_play_bounce(row)
		return
	if which == "left":
		cycle_free_strip(-1)
		return
	if which == "right":
		if GameState.is_free_selectable(season_id):
			cycle_free_strip(1)
		else:
			_play_bounce(row)
		return
	if GameState.is_season_playable(season_id):
		open_season_field()
	else:
		open_browser()


func _can_cycle(dir: int) -> bool:
	if dir > 0:
		var right_id := GameState.strip_right_id()
		return not right_id.is_empty() and GameState.is_free_selectable(right_id)
	if dir < 0:
		return not GameState.strip_left_id().is_empty()
	return false


func _can_cycle_paid(dir: int) -> bool:
	if dir > 0:
		return not GameState.paid_right_id().is_empty()
	if dir < 0:
		return not GameState.paid_left_id().is_empty()
	return false


func _fill_slot(slot: PanelContainer, title: Label, season_id: String, locked: bool, preview: bool) -> void:
	if slot == null or title == null:
		return
	if season_id.is_empty():
		slot.visible = false
		return
	slot.visible = true
	var def: SeasonDef = GameState.get_season_def(season_id)
	var name := def.display_name if def else season_id
	title.text = "🔒\n%s" % name if locked else name
	if not GameState.is_season_playable(season_id):
		title.text = "🔒\n%s" % name
		locked = true
	title.add_theme_font_size_override("font_size", _slot_font(slot == center_slot, preview))
	title.add_theme_color_override("font_color", CONTRAST.title_color(season_id))
	_apply_card_color(slot, _mood_color(season_id), locked, season_id)


func _fill_paid_slot(slot: PanelContainer, title: Label, season_id: String, is_hero_band: bool) -> void:
	if slot == null or title == null:
		return
	if season_id.is_empty():
		slot.visible = false
		return
	slot.visible = true
	var def: SeasonDef = GameState.get_season_def(season_id)
	var name := def.display_name if def else season_id
	var owned := GameState.is_season_playable(season_id)
	if owned:
		title.text = name
	else:
		var price := _paid_price_label(def)
		title.text = "🔒\n%s\n%s" % [name, price]
	title.add_theme_font_size_override("font_size", _slot_font(slot == paid_center_slot, not is_hero_band))
	title.add_theme_color_override("font_color", CONTRAST.title_color(season_id))
	_apply_card_color(slot, _mood_color(season_id), not owned, season_id)


func _paid_price_label(def: SeasonDef) -> String:
	if def == null or def.iap_product_id.is_empty():
		return "—"
	return IAPManager.get_price_label(def.iap_product_id)


func _slot_font(is_center: bool, preview: bool) -> int:
	if preview:
		return FONT_PREVIEW_CENTER if is_center else FONT_PREVIEW_SIDE
	return FONT_HERO_CENTER if is_center else FONT_HERO_SIDE


func _play_slide(dir: int) -> void:
	if _slide_busy or _band_tween_busy:
		return
	_slide_busy = true
	if _bounce_tween:
		_bounce_tween.kill()
	_reset_strip_offset()
	_reset_paid_offset()
	_reset_row_stretches(left_slot, center_slot, right_slot)
	var slots: Array[Control] = [left_slot, center_slot, right_slot]
	_play_inplace_morph(slots, _apply_free_cycle.bind(dir), _finish_free_morph)


func _play_paid_slide(dir: int) -> void:
	if _slide_busy or _band_tween_busy:
		return
	_slide_busy = true
	if _bounce_tween:
		_bounce_tween.kill()
	_reset_paid_offset()
	_reset_strip_offset()
	_reset_row_stretches(paid_left_slot, paid_center_slot, paid_right_slot)
	var slots: Array[Control] = [paid_left_slot, paid_center_slot, paid_right_slot]
	_play_inplace_morph(slots, _apply_paid_cycle.bind(dir), _finish_paid_morph)


func _apply_free_cycle(dir: int) -> void:
	GameState.cycle_free_strip(dir)
	_fill_free_slots()
	_refresh_unlock_gate()
	_refresh_roster()


func _finish_free_morph() -> void:
	_reset_slot_alphas([left_slot, center_slot, right_slot])
	refresh()
	_slide_busy = false


func _apply_paid_cycle(dir: int) -> void:
	GameState.cycle_paid_strip(dir)
	_fill_paid_slots()
	_refresh_unlock_gate()
	_refresh_roster()


func _finish_paid_morph() -> void:
	_reset_slot_alphas([paid_left_slot, paid_center_slot, paid_right_slot])
	refresh()
	_slide_busy = false


func _fill_free_slots() -> void:
	var preview := GameState.home_band == "paid"
	_fill_slot(left_slot, left_title, GameState.strip_left_id(), false, preview)
	_fill_slot(center_slot, center_title, GameState.strip_center_id(), false, preview)
	var right_id := GameState.strip_right_id()
	_fill_slot(right_slot, right_title, right_id, GameState.is_strip_right_locked(), preview)


func _fill_paid_slots() -> void:
	var is_hero_band := GameState.home_band == "paid"
	_fill_paid_slot(paid_left_slot, paid_left_title, GameState.paid_left_id(), is_hero_band)
	_fill_paid_slot(paid_center_slot, paid_center_title, GameState.paid_center_id(), is_hero_band)
	_fill_paid_slot(paid_right_slot, paid_right_title, GameState.paid_right_id(), is_hero_band)


func _refresh_roster() -> void:
	var hero_id := GameState.home_hero_center_id()
	var paid_hero := GameState.home_band == "paid"
	var gate_up := unlock_gate != null and unlock_gate.visible
	if free_roster:
		if free_roster.has_method("apply_season"):
			free_roster.call("apply_season", hero_id)
		free_roster.visible = not paid_hero and not gate_up
	if paid_roster:
		if paid_roster.has_method("apply_season"):
			paid_roster.call("apply_season", hero_id)
		paid_roster.visible = paid_hero


func _refresh_unlock_gate() -> void:
	if unlock_gate == null:
		return
	if unlock_gate.has_method("refresh_gate"):
		unlock_gate.call("refresh_gate", GameState.strip_center_id(), GameState.home_band != "paid")


func _play_inplace_morph(slots: Array[Control], mid: Callable, done: Callable) -> void:
	var half := BAND_TWEEN_SEC * 0.5
	_reset_slot_alphas(slots)
	if _bounce_tween:
		_bounce_tween.kill()
	_bounce_tween = create_tween()
	_bounce_tween.set_trans(Tween.TRANS_SINE)
	_bounce_tween.set_ease(Tween.EASE_OUT)
	_bounce_tween.set_parallel(true)
	var faded := false
	for slot in slots:
		if slot == null:
			continue
		faded = true
		_bounce_tween.tween_property(slot, "modulate:a", 0.0, half)
	if not faded:
		mid.call()
		done.call()
		return
	_bounce_tween.chain()
	_bounce_tween.set_parallel(false)
	_bounce_tween.tween_callback(mid)
	_bounce_tween.chain()
	_bounce_tween.set_parallel(true)
	for slot in slots:
		if slot == null:
			continue
		_bounce_tween.tween_property(slot, "modulate:a", 1.0, half)
	_bounce_tween.chain()
	_bounce_tween.set_parallel(false)
	_bounce_tween.tween_callback(done)


func _reset_slot_alphas(slots: Array[Control]) -> void:
	for slot in slots:
		if slot:
			slot.modulate.a = 1.0


func _reset_strip_offset() -> void:
	if strip_motion == null:
		return
	strip_motion.offset_left = 0.0
	strip_motion.offset_right = 0.0


func _reset_paid_offset() -> void:
	if paid_motion == null:
		return
	paid_motion.offset_left = 0.0
	paid_motion.offset_right = 0.0


func _reset_row_stretches(left: Control, center: Control, right: Control) -> void:
	if left:
		left.size_flags_stretch_ratio = STRETCH_SIDE
	if center:
		center.size_flags_stretch_ratio = STRETCH_CENTER
	if right:
		right.size_flags_stretch_ratio = STRETCH_SIDE


func _play_bounce(target: Control) -> void:
	if target == null:
		return
	if _bounce_tween:
		_bounce_tween.kill()
	target.modulate.a = 1.0
	_bounce_tween = create_tween()
	_bounce_tween.tween_property(target, "modulate:a", 0.55, SNAP_SEC * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_bounce_tween.tween_property(target, "modulate:a", 1.0, SNAP_SEC * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _tween_band_heights() -> void:
	if paid_band == null or free_band == null:
		_apply_band_heights()
		_notify_home_badge()
		return
	if _band_tween:
		_band_tween.kill()
	_band_tween_busy = true
	var paid_hero := GameState.home_band == "paid"
	var paid_ratio := RATIO_HERO if paid_hero else RATIO_PREVIEW
	var free_ratio := RATIO_PREVIEW if paid_hero else RATIO_HERO
	var paid_min := HERO_MIN if paid_hero else PREVIEW_MIN
	var free_min := PREVIEW_MIN if paid_hero else HERO_MIN
	_band_tween = create_tween()
	_band_tween.set_parallel(true)
	_band_tween.set_trans(Tween.TRANS_SINE)
	_band_tween.set_ease(Tween.EASE_OUT)
	_band_tween.tween_property(paid_band, "size_flags_stretch_ratio", paid_ratio, BAND_TWEEN_SEC)
	_band_tween.tween_property(free_band, "size_flags_stretch_ratio", free_ratio, BAND_TWEEN_SEC)
	_band_tween.tween_property(paid_band, "custom_minimum_size:y", paid_min, BAND_TWEEN_SEC)
	_band_tween.tween_property(free_band, "custom_minimum_size:y", free_min, BAND_TWEEN_SEC)
	_band_tween.finished.connect(_finish_band_tween, CONNECT_ONE_SHOT)


func _finish_band_tween() -> void:
	_band_tween_busy = false
	_apply_band_heights()
	_notify_home_badge()


func _notify_home_badge() -> void:
	if owner and owner.has_method("_refresh_play_theme_badge"):
		owner.call("_refresh_play_theme_badge")


func _mood_color(season_id: String) -> Color:
	return CONTRAST.mood_color(season_id)


func _apply_card_color(card: PanelContainer, color: Color, locked: bool, season_id: String) -> void:
	if card == null:
		return
	var box := StyleBoxFlat.new()
	box.bg_color = color.darkened(0.25) if locked else color
	box.set_corner_radius_all(16)
	box.set_content_margin_all(12)
	if locked:
		box.bg_color.a = 0.72
	var show_outline := (
		not season_id.is_empty()
		and season_id == GameState.active_season_id
		and GameState.is_season_playable(season_id)
	)
	if show_outline:
		box.set_border_width_all(5)
		box.border_color = Color("FFF6D6")
		box.shadow_size = 2
		box.shadow_color = Color("1A1A14")
		box.shadow_offset = Vector2.ZERO
	card.add_theme_stylebox_override("panel", box)
