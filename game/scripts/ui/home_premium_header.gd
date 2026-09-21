class_name HomePremiumHeader
extends PanelContainer

## Red "Premium seasons" ispod besplatnog puta (HomeScreen.dc.html · PremiumSection).
## Zatvoren (155 px): tackice mood boja + "Free path never needs them" + "N ↓".
## Otvoren (90 px, premium kartice ispod): "Preview before you buy" + "↑".

signal toggled

const DRAG_SCROLL := preload("res://scripts/ui/drag_scroll.gd")

var open: bool = false
var _dots: HBoxContainer
var _title: Label
var _note: Label
var _chevron: PanelContainer
var _chevron_label: Label
var _pressing: bool = false
var _drag_dist: float = 0.0


func _init() -> void:
	name = "PremiumSection"
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.name = "Row"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 20)
	add_child(row)
	_dots = HBoxContainer.new()
	_dots.name = "PremiumDots"
	_dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dots.add_theme_constant_override("separation", 10)
	_dots.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_dots)
	var text := VBoxContainer.new()
	text.name = "Text"
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	text.add_theme_constant_override("separation", 8)
	row.add_child(text)
	_title = Label.new()
	_title.name = "Title"
	_title.text = "Premium seasons"
	UiHome.style(_title, UiHome.FONT_SECTION_TITLE, UiHome.RIM, UiHome.W_BLACK)
	text.add_child(_title)
	_note = Label.new()
	_note.name = "Note"
	UiHome.style(_note, UiHome.FONT_SECTION_NOTE, Color(1.0, 0.965, 0.839, 0.82), UiHome.W_REGULAR)
	UiHome.ellipsis(_note)
	text.add_child(_note)
	_chevron = PanelContainer.new()
	_chevron.name = "PremiumChevron"
	_chevron.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chevron.custom_minimum_size.y = 76
	_chevron.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_chevron.add_theme_stylebox_override("panel", UiHome.chevron())
	row.add_child(_chevron)
	_chevron_label = Label.new()
	_chevron_label.name = "Text"
	UiHome.style(_chevron_label, UiHome.FONT_CHEVRON, UiHome.RIM, UiHome.W_BLACK)
	_chevron.add_child(_chevron_label)


func configure(season_ids: Array[String], is_open: bool) -> void:
	open = is_open
	var h := UiHome.PREMIUM_HEAD_H if open else UiHome.PREMIUM_ROW_H
	custom_minimum_size = Vector2(0.0, h)
	add_theme_stylebox_override("panel", UiHome.hub_panel(20 if open else 26))
	_note.text = "Preview before you buy" if open else "Free path never needs them"
	# CD crta "↓" i kad je otvoreno; "↑" jasnije kaze da tap zatvara.
	_chevron_label.text = "↑" if open else "%d  ↓" % season_ids.size()
	_dots.visible = not open
	# Tackice se ponovo koriste: queue_free + novi child bi do kraja frejma
	# duplirao sirinu reda (i kolone iza njega).
	while _dots.get_child_count() < season_ids.size():
		var dot := Panel.new()
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dot.custom_minimum_size = Vector2(UiHome.PREMIUM_DOT, UiHome.PREMIUM_DOT)
		_dots.add_child(dot)
	for i in _dots.get_child_count():
		var dot := _dots.get_child(i) as Panel
		dot.visible = i < season_ids.size()
		if dot.visible:
			dot.add_theme_stylebox_override("panel", UiHome.premium_dot(season_ids[i]))


func get_note_text() -> String:
	return _note.text


func get_chevron_text() -> String:
	return _chevron_label.text


func _gui_input(event: InputEvent) -> void:
	var dy := DRAG_SCROLL.drag_delta(event)
	if not is_zero_approx(dy):
		_drag_dist += absf(dy)
		DRAG_SCROLL.apply(DRAG_SCROLL.find_scroll(self), dy)
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
	else:
		if _pressing and _drag_dist < DRAG_SCROLL.TAP_SLOP:
			toggled.emit()
		_pressing = false
	accept_event()
