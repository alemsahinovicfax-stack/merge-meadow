class_name ArenaNeedRow
extends PanelContainer

## Red u "You need more seeds!" overlayu: T1 cvijet, ime, `n/4` (koliko tipu fali do T3 seta).

const SET_SIZE := 4
const ROW_H := 108.0
const ICON_SIZE := 72.0
const NAME_FONT_SIZE := 40
const COUNT_FONT_SIZE := 44

var _type_id: String = ""
var _count_label: Label = null


func setup(type_id: String, count: int, display_name: String, rarity: int) -> void:
	_type_id = type_id
	custom_minimum_size = Vector2(0.0, ROW_H)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", UiArena.need_row_style(rarity))
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 22)
	add_child(row)
	var icon := Control.new()
	icon.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func() -> void: ArenaChipDraw.draw_flower(icon, icon.size * 0.5, type_id, 1, ICON_SIZE))
	row.add_child(icon)
	var name_label := _label(display_name, NAME_FONT_SIZE)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(name_label)
	_count_label = _label("%d/%d" % [count, SET_SIZE], COUNT_FONT_SIZE)
	row.add_child(_count_label)


func get_type_id() -> String:
	return _type_id


func get_count_label_text() -> String:
	return _count_label.text if _count_label else ""


static func _label(text: String, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_font_override("font", UiChrome.heavy_font(UiChrome.EMBOLDEN_800))
	l.add_theme_color_override("font_color", UiPalette.OUTLINE)
	return l
