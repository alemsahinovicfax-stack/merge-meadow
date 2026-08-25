extends PanelContainer

## HOME-08 — 6 T3 roster rows inside the hero-center season card.

const PLANT_ICON := preload("res://scripts/ui/collection_bloom_icon.gd")
const CREAM := Color("FFF6D6")
const FRAME := Color("1A1A14")
const ROW_H := 56.0
const ICON_S := 52.0
const NAME_FONT := 22
const STAR_FONT := 18

var _col: VBoxContainer
var _name_labels: Array[Label] = []
var _star_labels: Array[Label] = []
var _icons: Array[Control] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_frame()
	_build_rows()


func apply_season(season_id: String) -> void:
	var def: SeasonDef = GameState.get_season_def(season_id)
	var entries: Array = def.roster if def else []
	for i in 6:
		var icon: Control = _icons[i]
		var stars: Label = _star_labels[i]
		var name_l: Label = _name_labels[i]
		if i >= entries.size():
			icon.visible = false
			stars.text = ""
			name_l.text = ""
			continue
		var row: Dictionary = entries[i]
		icon.visible = true
		var type_id := str(row.get("id", ""))
		var rarity := clampi(int(row.get("rarity", 1)), 1, 3)
		var display := str(row.get("display_name", type_id))
		if icon.has_method("apply"):
			icon.call("apply", type_id, 3, false)
		stars.text = "★".repeat(rarity)
		name_l.text = display


func has_entry(display_name: String) -> bool:
	for name_l in _name_labels:
		if name_l.text == display_name:
			return true
	return false


func rarity3_display() -> String:
	for i in _star_labels.size():
		if _star_labels[i].text == "★★★":
			return _name_labels[i].text
	return ""


func _apply_frame() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(FRAME.r, FRAME.g, FRAME.b, 0.88)
	box.set_corner_radius_all(12)
	box.set_content_margin_all(12)
	box.set_border_width_all(1)
	box.border_color = Color(CREAM.r, CREAM.g, CREAM.b, 0.35)
	add_theme_stylebox_override("panel", box)


func _build_rows() -> void:
	_col = VBoxContainer.new()
	_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_col.add_theme_constant_override("separation", 2)
	add_child(_col)
	for _i in 6:
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 6)
		row.custom_minimum_size = Vector2(0, ROW_H)
		var icon := Control.new()
		icon.set_script(PLANT_ICON)
		icon.custom_minimum_size = Vector2(ICON_S, ICON_S)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var stars := Label.new()
		stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stars.add_theme_color_override("font_color", CREAM)
		stars.add_theme_font_size_override("font_size", STAR_FONT)
		stars.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		stars.custom_minimum_size = Vector2(56, 0)
		var name_l := Label.new()
		name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_l.add_theme_color_override("font_color", CREAM)
		name_l.add_theme_font_size_override("font_size", NAME_FONT)
		name_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		row.add_child(icon)
		row.add_child(stars)
		row.add_child(name_l)
		_col.add_child(row)
		_icons.append(icon)
		_star_labels.append(stars)
		_name_labels.append(name_l)
