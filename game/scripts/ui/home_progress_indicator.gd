class_name HomeProgressIndicator
extends PanelContainer

## "2 / 4 free seasons" + segmenti (HomeScreen.dc.html · ProgressIndicator).
## Broj segmenata = broj besplatnih sezona u seasons.json, ne zakucanih 4.

var _number: Label
var _label: Label
var _segments: HBoxContainer


func _init() -> void:
	name = "ProgressIndicator"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", UiHome.hub_panel(20))
	var col := VBoxContainer.new()
	col.name = "Col"
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 14)
	add_child(col)
	var top := HBoxContainer.new()
	top.name = "Top"
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_theme_constant_override("separation", 14)
	col.add_child(top)
	_number = Label.new()
	_number.name = "ProgressNumber"
	UiHome.style(_number, UiHome.FONT_PROGRESS_NUM, UiHome.RIM, UiHome.W_BLACK)
	top.add_child(_number)
	_label = Label.new()
	_label.name = "ProgressLabel"
	_label.text = "free seasons"
	_label.size_flags_vertical = Control.SIZE_SHRINK_END
	UiHome.style(_label, UiHome.FONT_PROGRESS_LABEL, Color(1.0, 0.965, 0.839, 0.86), UiHome.W_REGULAR)
	top.add_child(_label)
	_segments = HBoxContainer.new()
	_segments.name = "Segments"
	_segments.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_segments.add_theme_constant_override("separation", 10)
	col.add_child(_segments)


func refresh() -> void:
	var defs := SeasonCatalog.free_defs_sorted()
	var done := 0
	for def in defs:
		if GameState.is_season_playable(def.id):
			done += 1
	_number.text = "%d / %d" % [done, defs.size()]
	while _segments.get_child_count() < defs.size():
		var seg := Panel.new()
		seg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		seg.custom_minimum_size.y = UiHome.SEGMENT_H
		seg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_segments.add_child(seg)
	for i in _segments.get_child_count():
		var seg := _segments.get_child(i) as Panel
		seg.visible = i < defs.size()
		seg.add_theme_stylebox_override("panel", UiHome.progress_segment(i < done))


func get_text() -> String:
	return _number.text
