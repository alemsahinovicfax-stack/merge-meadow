class_name SeedBagChip
extends PanelContainer

## Garden bag cell — tap to select for trade (count >= 1).

signal chip_pressed(type_id: String)

const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const PICKUP_ASSETS := preload("res://scripts/visual/pickup_assets.gd")
const SeedBagIcon := preload("res://scripts/camp/seed_bag_icon.gd")
const RarityStars := preload("res://scripts/ui/rarity_stars.gd")
const PRICE_PILL_BG := Color("#FFE8B8")
const CHIP_MIN_H := 110.0
const NAME_FONT := 26
const COUNT_FONT := 32
const STAR_FONT := 22
const PRICE_FONT := 36
const COIN_SIDE := 36.0

var _type_id: String = "clover"
var _count: int = 0
var _display_name: String = ""
var _rarity: int = 1
var _trade_eligible: bool = false
var _tap_enabled: bool = false
var _selected: bool = false
var _quota_display: bool = false

var _icon: Control
var _stars_row: HBoxContainer
var _name_label: Label
var _count_label: Label
var _price_label: Label
var _price_pill: Control
var _coin_icon: TextureRect
var _panel_style: StyleBoxFlat


func _ready() -> void:
	custom_minimum_size = Vector2(0, CHIP_MIN_H)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ensure_children()
	_refresh_labels()
	_apply_visual_state()


func apply(type_id: String, count: int, display_name: String, rarity: int) -> void:
	_type_id = type_id
	_count = count
	_display_name = display_name
	_rarity = rarity
	_quota_display = false
	_trade_eligible = count >= 1
	_tap_enabled = _trade_eligible
	_ensure_children()
	_refresh_labels()
	if _icon and _icon.has_method("setup"):
		_icon.call("setup", _type_id)
	_apply_visual_state()


func get_type_id() -> String:
	return _type_id


func set_selected(on: bool) -> void:
	_selected = on and _trade_eligible
	_apply_visual_state()


func set_trade_eligible(eligible: bool) -> void:
	_trade_eligible = eligible
	_tap_enabled = _trade_eligible and not _quota_display
	if not _trade_eligible:
		_selected = false
	_apply_visual_state()


func set_count_quota_display(on: bool) -> void:
	_quota_display = on
	if on:
		_trade_eligible = false
		_tap_enabled = false
		_selected = false
	_refresh_labels()
	_apply_visual_state()


func get_count_label_text() -> String:
	if _count_label == null:
		return ""
	return _count_label.text


func _ensure_children() -> void:
	if _icon != null:
		return
	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = UI_PALETTE.WARM_WHITE
	_panel_style.set_corner_radius_all(12)
	_panel_style.set_border_width_all(2)
	_panel_style.border_color = Color(UI_PALETTE.OUTLINE.r, UI_PALETTE.OUTLINE.g, UI_PALETTE.OUTLINE.b, 0.16)
	_panel_style.content_margin_left = 6
	_panel_style.content_margin_top = 6
	_panel_style.content_margin_right = 6
	_panel_style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", _panel_style)

	var row := HBoxContainer.new()
	row.name = "ChipRow"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(row)

	var icon_col := VBoxContainer.new()
	icon_col.name = "IconCol"
	icon_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_col.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_col.alignment = BoxContainer.ALIGNMENT_CENTER
	icon_col.add_theme_constant_override("separation", 0)
	row.add_child(icon_col)

	_icon = SeedBagIcon.new()
	_icon.name = "PlantIcon"
	_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_col.add_child(_icon)

	_stars_row = RarityStars.make_row(_rarity, STAR_FONT)
	icon_col.add_child(_stars_row)

	var text_col := VBoxContainer.new()
	text_col.name = "TextCol"
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	text_col.add_theme_constant_override("separation", 2)
	row.add_child(text_col)

	_name_label = Label.new()
	_name_label.name = "NameLabel"
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.add_theme_font_size_override("font_size", NAME_FONT)
	text_col.add_child(_name_label)

	_count_label = Label.new()
	_count_label.name = "CountLabel"
	_count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_count_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_count_label.add_theme_font_size_override("font_size", COUNT_FONT)
	text_col.add_child(_count_label)

	var price_pill := PanelContainer.new()
	price_pill.name = "PricePill"
	price_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	price_pill.size_flags_horizontal = Control.SIZE_SHRINK_END
	price_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_price_pill = price_pill
	var pill_style := StyleBoxFlat.new()
	pill_style.bg_color = PRICE_PILL_BG
	pill_style.set_corner_radius_all(8)
	pill_style.set_border_width_all(1)
	pill_style.border_color = Color(UI_PALETTE.OUTLINE.r, UI_PALETTE.OUTLINE.g, UI_PALETTE.OUTLINE.b, 0.22)
	pill_style.content_margin_left = 8
	pill_style.content_margin_top = 6
	pill_style.content_margin_right = 8
	pill_style.content_margin_bottom = 6
	price_pill.add_theme_stylebox_override("panel", pill_style)
	row.add_child(price_pill)

	var price_row := HBoxContainer.new()
	price_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	price_row.add_theme_constant_override("separation", 4)
	price_pill.add_child(price_row)

	_price_label = Label.new()
	_price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_price_label.custom_minimum_size = Vector2(24, 0)
	_price_label.add_theme_font_size_override("font_size", PRICE_FONT)
	_price_label.add_theme_color_override("font_color", UI_PALETTE.OUTLINE)
	_price_label.clip_text = false
	_price_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	price_row.add_child(_price_label)

	_coin_icon = TextureRect.new()
	_coin_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_coin_icon.custom_minimum_size = Vector2(COIN_SIDE, COIN_SIDE)
	_coin_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_coin_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_coin_icon.texture = PICKUP_ASSETS.get_coin_texture()
	price_row.add_child(_coin_icon)

	TEXT_LAYOUT.ink(_name_label)
	TEXT_LAYOUT.ink(_count_label)


func _refresh_labels() -> void:
	if _name_label == null or _count_label == null or _price_label == null:
		return
	_name_label.text = _display_name
	if _quota_display:
		_count_label.text = "%d/4" % _count
	else:
		_count_label.text = "×%d" % _count
	_price_label.text = "%d" % GameState.seed_exchange_coins_per_seed(_type_id)
	_price_label.add_theme_color_override("font_color", UI_PALETTE.OUTLINE)
	if _stars_row:
		RarityStars.apply_row(_stars_row, _rarity, STAR_FONT)
	TEXT_LAYOUT.ink(_name_label)
	TEXT_LAYOUT.ink(_count_label)


func _apply_visual_state() -> void:
	if _panel_style == null:
		return
	var rarity_bg := UI_PALETTE.rarity_bg_color(_rarity, false)
	if _selected:
		_panel_style.set_border_width_all(4)
		_panel_style.border_color = UI_PALETTE.PEACH
		_panel_style.bg_color = rarity_bg.lightened(0.12)
	else:
		_panel_style.set_border_width_all(2)
		_panel_style.border_color = Color(
			UI_PALETTE.OUTLINE.r, UI_PALETTE.OUTLINE.g, UI_PALETTE.OUTLINE.b, 0.16
		)
		_panel_style.bg_color = rarity_bg
	if _price_pill:
		_price_pill.visible = not _quota_display
	modulate = Color(1, 1, 1, 1) if (_tap_enabled or _quota_display) else Color(1, 1, 1, 0.55)
	mouse_filter = Control.MOUSE_FILTER_STOP if _tap_enabled else Control.MOUSE_FILTER_IGNORE


func _gui_input(event: InputEvent) -> void:
	if not _tap_enabled:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			chip_pressed.emit(_type_id)
			accept_event()
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			chip_pressed.emit(_type_id)
			accept_event()
