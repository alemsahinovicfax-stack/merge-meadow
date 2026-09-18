class_name CampStashTab
extends PanelContainer

## Tab Seeds | Flowers (design_handoff_camp · StashTabs): ikona u okviru,
## naslov + broj tipova, podnaslov ("Arena fuel" / "reward").

signal tab_pressed(kind: String)

const MIN_LABEL_PX := 34

var kind: String = UiCamp.TAB_SEEDS
var _active: bool = false
var _count: int = 0
var _pressing: bool = false
var _label_px: int = UiCamp.FONT_TAB

var _icon: CampArtFrame
var _label: Label
var _count_panel: PanelContainer
var _count_label: Label
var _sub: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(0, UiCamp.TABS_H)
	_build()
	_apply()
	resized.connect(_fit_label)


func setup(tab_kind: String) -> void:
	kind = tab_kind
	_build()
	_apply()


func set_active(on: bool) -> void:
	_active = on
	_apply()


func is_active() -> bool:
	return _active


func set_count(count: int) -> void:
	_count = count
	if _count_label:
		_count_label.text = str(count)
	_fit_label()


func get_count_text() -> String:
	return _count_label.text if _count_label else ""


func get_title() -> String:
	return _label.text if _label else ""


func _build() -> void:
	if _icon != null:
		return
	var row := HBoxContainer.new()
	row.name = "TabRow"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", UiCamp.TAB_GAP)
	add_child(row)
	_icon = CampArtFrame.new()
	_icon.name = "TabIcon"
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_icon)
	var text_col := VBoxContainer.new()
	text_col.name = "TextWrap"
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 8)
	row.add_child(text_col)
	var top := HBoxContainer.new()
	top.name = "TopRow"
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_theme_constant_override("separation", UiCamp.TAB_GAP)
	text_col.add_child(top)
	_label = Label.new()
	_label.name = "TabLabel"
	_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_label)
	_count_panel = PanelContainer.new()
	_count_panel.name = "TabCount"
	_count_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_panel.custom_minimum_size = Vector2(UiCamp.TAB_COUNT_MIN_W, UiCamp.TAB_COUNT_H)
	top.add_child(_count_panel)
	_count_label = Label.new()
	_count_label.name = "TabCountLabel"
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count_panel.add_child(_count_label)
	_sub = Label.new()
	_sub.name = "TabSub"
	text_col.add_child(_sub)


func _apply() -> void:
	if _icon == null:
		return
	var seed := kind == UiCamp.TAB_SEEDS
	_icon.configure_frame(UiCamp.TAB_ICON, 22, 3, 0.0, 0, 0, UiCamp.TAB_ICON_ART)
	_icon.set_icon(
		seed,
		UiAssets.get_chrome_icon("icon_seed") if seed else UiAssets.get_arena_icon("icon_crystal"),
		UiCamp.TAB_ICON_ART
	)
	_label.text = "Seeds" if seed else "Flowers"
	_sub.text = "Arena fuel" if seed else "reward"
	_count_label.text = str(_count)
	add_theme_stylebox_override("panel", UiCamp.tab_style(_active))
	_count_panel.add_theme_stylebox_override("panel", UiCamp.tab_count_style(_active))
	UiCamp.style_label(_count_label, UiCamp.FONT_TAB, UiCamp.tab_ink(_active))
	UiCamp.style_label(_sub, UiCamp.FONT_TAB_SUB, UiCamp.tab_sub_ink(_active), UiCamp.SEMI)
	_fit_label()


## Uzak tab (387 px kad je "Merge" vidljiv) — naslov se smanjuje do 34 px
## umjesto da gura broj preko ruba.
func _fit_label() -> void:
	if _label == null or size.x <= 0.0:
		return
	var box := get_theme_stylebox("panel")
	var chrome := (box.get_margin(SIDE_LEFT) + box.get_margin(SIDE_RIGHT)) if box else 36.0
	var avail := size.x - chrome - UiCamp.TAB_ICON - UiCamp.TAB_GAP * 2.0
	var count_w := maxf(
		UiCamp.TAB_COUNT_MIN_W,
		32.0 + UiCamp.tight_font(UiCamp.FONT_TAB).get_string_size(
			_count_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, UiCamp.FONT_TAB
		).x
	)
	var px := UiCamp.FONT_TAB
	while px > MIN_LABEL_PX:
		var w := UiCamp.tight_font(px).get_string_size(_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		if w + count_w <= avail:
			break
		px -= 2
	_label_px = px
	UiCamp.style_label(_label, px, UiCamp.tab_ink(_active))


func _gui_input(event: InputEvent) -> void:
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
	elif _pressing:
		_pressing = false
		tab_pressed.emit(kind)
	accept_event()
