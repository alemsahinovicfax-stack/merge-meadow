class_name CampStashChip
extends PanelContainer

## Seeds / Flowers chip (design_handoff_camp · CampChip). Jedan za oba:
## "seed" = T1 iz vrece (cream krug), "flower" = T3 iz stasha (gold kvadrat).
## Tap bira tip za Trade; povlacenje skrola listu.

signal chip_pressed(type_id: String)

const DRAG_SCROLL := preload("res://scripts/ui/drag_scroll.gd")

var _kind: String = "seed"
var _type_id: String = ""
var _count: int = 0
var _display_name: String = ""
var _rarity: int = 1
var _price: int = 1
var _state: String = UiCamp.CHIP_IDLE
var _selected: bool = false
var _pressing: bool = false
var _drag_dist: float = 0.0
var _scroll: ScrollContainer
var _lift: float = 0.0
var _lift_tween: Tween

var _reserved: bool = false
var _have: int = 0
var _need: int = 0
var _season_id: String = ""
var _at_floor: bool = false

var _art: CampArtFrame
var _name_label: Label
var _pips_label: Label
var _badge: PanelContainer
var _badge_icon: TextureRect
var _badge_label: Label
var _count_icon: TextureRect
var _count_label: Label
var _price_label: Label
var _each_label: Label
var _count_pill: PanelContainer
var _price_pill: PanelContainer
var _mark: Panel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ensure_children()
	_apply_all()


func setup(kind: String, type_id: String, count: int, display_name: String, rarity: int, price: int) -> void:
	_kind = kind
	_type_id = type_id
	_count = count
	_display_name = display_name
	_rarity = clampi(rarity, 1, 3)
	_price = price
	_ensure_children()
	_apply_all()


func get_type_id() -> String:
	return _type_id


func get_kind() -> String:
	return _kind


func get_count() -> int:
	return _count


func get_state() -> String:
	return _state


func is_selected() -> bool:
	return _selected


func is_reserved() -> bool:
	return _reserved


func get_badge_text() -> String:
	return _badge_label.text if _badge_label and _reserved else ""


## Lagani update za hold-trade — bez ponovnog crtanja arta.
func set_count(count: int) -> void:
	_count = count
	if _count_label:
		_count_label.text = str(count)
	_apply_style()


func set_selected(on: bool, animate: bool = false) -> void:
	if _selected == on:
		return
	_selected = on
	var target := float(UiCamp.CHIP_LIFT) if on else 0.0
	if _lift_tween:
		_lift_tween.kill()
		_lift_tween = null
	if animate and is_inside_tree():
		_lift_tween = create_tween()
		_lift_tween.tween_method(_set_lift, _lift, target, UiCamp.T_CHIP_SELECT) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		_lift = target
	_apply_style()


## Rezervisano ★3 cvijece za sljedecu besplatnu sezonu (badge + visina 244).
func set_reserved(on: bool, have: int = 0, need: int = 0, season_id: String = "", at_floor: bool = false) -> void:
	_reserved = on
	_have = have
	_need = need
	_season_id = season_id
	_at_floor = at_floor and on
	_ensure_children()
	_apply_badge()


func _set_lift(value: float) -> void:
	_lift = value
	_apply_style()


func _ensure_children() -> void:
	if _art != null:
		return
	var row := HBoxContainer.new()
	row.name = "ChipRow"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", UiCamp.CHIP_PAD)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(row)

	_art = CampArtFrame.new()
	_art.name = "ArtFrame"
	_art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_art)

	var body := VBoxContainer.new()
	body.name = "ChipBody"
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 6)
	row.add_child(body)

	var name_block := VBoxContainer.new()
	name_block.name = "NameBlock"
	name_block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_block.add_theme_constant_override("separation", 4)
	body.add_child(name_block)

	_name_label = Label.new()
	_name_label.name = "ChipName"
	_name_label.clip_text = true
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name_label.custom_minimum_size = Vector2(1, 0)
	name_block.add_child(_name_label)

	_pips_label = Label.new()
	_pips_label.name = "RarityPips"
	name_block.add_child(_pips_label)

	_badge = PanelContainer.new()
	_badge.name = "ReservedBadge"
	_badge.visible = false
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.custom_minimum_size = Vector2(0, UiCamp.BADGE_H)
	body.add_child(_badge)
	var badge_row := HBoxContainer.new()
	badge_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_row.add_theme_constant_override("separation", 10)
	_badge.add_child(badge_row)
	_badge_icon = _make_icon(UiCamp.PILL_ICON)
	badge_row.add_child(_badge_icon)
	_badge_label = Label.new()
	_badge_label.name = "BadgeLabel"
	_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_badge_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_badge_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_badge_label.clip_text = true
	_badge_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_badge_label.custom_minimum_size = Vector2(1, 0)
	badge_row.add_child(_badge_label)

	var pill_row := HBoxContainer.new()
	pill_row.name = "PillRow"
	pill_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill_row.add_theme_constant_override("separation", UiCamp.PILL_GAP)
	body.add_child(pill_row)

	_count_pill = PanelContainer.new()
	_count_pill.name = "CountPill"
	_count_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_pill.custom_minimum_size = Vector2(0, UiCamp.PILL_H)
	_count_pill.add_theme_stylebox_override("panel", UiCamp.count_pill_style())
	pill_row.add_child(_count_pill)
	var count_row := HBoxContainer.new()
	count_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_row.add_theme_constant_override("separation", 10)
	_count_pill.add_child(count_row)
	_count_icon = _make_icon(UiCamp.PILL_ICON)
	count_row.add_child(_count_icon)
	_count_label = Label.new()
	_count_label.name = "CountLabel"
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	count_row.add_child(_count_label)

	_price_pill = PanelContainer.new()
	_price_pill.name = "PricePill"
	_price_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price_pill.custom_minimum_size = Vector2(0, UiCamp.PILL_H)
	_price_pill.add_theme_stylebox_override("panel", UiCamp.price_pill_style())
	pill_row.add_child(_price_pill)
	var price_row := HBoxContainer.new()
	price_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	price_row.add_theme_constant_override("separation", 8)
	_price_pill.add_child(price_row)
	var coin := _make_icon(UiCamp.PRICE_COIN)
	coin.texture = UiAssets.get_chrome_icon("icon_coin")
	price_row.add_child(coin)
	_price_label = Label.new()
	_price_label.name = "PriceLabel"
	_price_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	price_row.add_child(_price_label)
	_each_label = Label.new()
	_each_label.name = "EachLabel"
	_each_label.text = "each"
	_each_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	price_row.add_child(_each_label)

	_mark = Panel.new()
	_mark.name = "SelectMark"
	_mark.visible = false
	_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mark.add_theme_stylebox_override("panel", UiCamp.select_mark_style())
	add_child(_mark)


func _make_icon(side: float) -> TextureRect:
	var t := TextureRect.new()
	t.custom_minimum_size = Vector2(side, side)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


func _apply_all() -> void:
	if _art == null:
		return
	var seed := _kind == "seed"
	_art.configure_frame(
		UiCamp.CHIP_ART_FRAME, 26, 3, UiCamp.CHIP_ART_WELL_INSET, 18, 2,
		UiCamp.CHIP_ART_SEED if seed else UiCamp.CHIP_ART_FLOWER
	)
	_art.set_art(seed, _type_id, 1 if seed else 3)
	_name_label.text = _display_name
	_pips_label.text = UiCamp.pips(_rarity)
	_count_label.text = str(_count)
	_price_label.text = str(_price)
	_count_icon.texture = (
		UiAssets.get_chrome_icon("icon_seed") if seed else UiAssets.get_arena_icon("icon_crystal")
	)
	UiCamp.style_label(_price_label, UiCamp.FONT_PRICE, UiCamp.INK)
	UiCamp.style_label(_each_label, UiCamp.FONT_EACH, UiCamp.INK, UiCamp.SEMI)
	_apply_badge()
	_apply_style()


func _apply_badge() -> void:
	if _badge == null:
		return
	_badge.visible = _reserved
	custom_minimum_size = Vector2(0, UiCamp.CHIP_H_RESERVED if _reserved else UiCamp.CHIP_SIZE.y)
	if not _reserved:
		return
	_badge.add_theme_stylebox_override("panel", UiCamp.reserved_badge_style(_season_id, _at_floor))
	_badge_icon.texture = UiAssets.get_camp_icon("icon_hold_stop" if _at_floor else "icon_reserved")
	_badge_label.text = UiCamp.reserved_badge_text(_have, _need, _at_floor)
	UiCamp.style_label(
		_badge_label, UiCamp.FONT_BADGE_FLOOR if _at_floor else UiCamp.FONT_BADGE, UiCamp.DARK_INK
	)


func _apply_style() -> void:
	if _art == null:
		return
	if _count < 1:
		_state = UiCamp.CHIP_DISABLED
	elif _pressing:
		_state = UiCamp.CHIP_PRESSED
	elif _selected:
		_state = UiCamp.CHIP_SELECTED
	else:
		_state = UiCamp.CHIP_IDLE
	var lift := _lift if _state == UiCamp.CHIP_SELECTED else 0.0
	add_theme_stylebox_override("panel", UiCamp.chip_style(_state, _rarity, lift))
	var ink := UiCamp.chip_ink(_state)
	UiCamp.style_label(_name_label, UiCamp.FONT_CHIP_NAME, ink, UiCamp.HEAVY, 1.05)
	UiCamp.style_label(_pips_label, UiCamp.FONT_PIPS, ink)
	UiCamp.style_label(_count_label, UiCamp.FONT_COUNT, ink)
	_mark.visible = _state == UiCamp.CHIP_SELECTED or _state == UiCamp.CHIP_PRESSED
	_mark.position.y = -lift
	queue_sort()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN and _mark != null:
		# SelectMark ide preko cijelog chipa (inset 0), ne samo sadrzaja.
		var lift := _lift if _state == UiCamp.CHIP_SELECTED else 0.0
		fit_child_in_rect(_mark, Rect2(Vector2(0.0, -lift), size))


func _get_scroll() -> ScrollContainer:
	if _scroll == null or not is_instance_valid(_scroll):
		_scroll = DRAG_SCROLL.find_scroll(self)
	return _scroll


func _gui_input(event: InputEvent) -> void:
	if _count < 1:
		return
	var dy := DRAG_SCROLL.drag_delta(event)
	if not is_zero_approx(dy):
		_drag_dist += absf(dy)
		if _drag_dist >= DRAG_SCROLL.TAP_SLOP and _pressing:
			_pressing = false
			_apply_style()
		DRAG_SCROLL.apply(_get_scroll(), dy)
		accept_event()
		return
	var down := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		down = mb.pressed
	elif event is InputEventScreenTouch:
		down = (event as InputEventScreenTouch).pressed
	else:
		return
	if down:
		_pressing = true
		_drag_dist = 0.0
		_apply_style()
	else:
		var was_tap := _pressing and _drag_dist < DRAG_SCROLL.TAP_SLOP
		_pressing = false
		_apply_style()
		if was_tap:
			chip_pressed.emit(_type_id)
	accept_event()
