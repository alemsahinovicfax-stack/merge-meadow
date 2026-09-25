class_name CampStashTab
extends PanelContainer

## Tab Seeds | Flowers (design_handoff_camp_v2 · StashTabs): ikona u okviru, ime i
## broj tipova uz desni rub. Bez podnaslova ("Arena fuel" / "reward") i bez Merge
## precice — red sluzi samo za biranje izmedju dva taba.

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
	row.add_theme_constant_override("separation", 16)
	add_child(row)
	_icon = CampArtFrame.new()
	_icon.name = "TabIcon"
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_icon)
	_label = Label.new()
	_label.name = "TabLabel"
	_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_label)
	_count_panel = PanelContainer.new()
	_count_panel.name = "TabCount"
	_count_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_count_panel.custom_minimum_size = Vector2(UiCamp.TAB_COUNT_MIN_W, UiCamp.TAB_COUNT_H)
	row.add_child(_count_panel)
	_count_label = Label.new()
	_count_label.name = "TabCountLabel"
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count_panel.add_child(_count_label)


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
	_count_label.text = str(_count)
	add_theme_stylebox_override("panel", UiCamp.tab_style(_active))
	_count_panel.add_theme_stylebox_override("panel", UiCamp.tab_count_style(_active))
	UiCamp.style_label(_count_label, UiCamp.FONT_TAB_COUNT, UiCamp.tab_ink(_active))
	_fit_label()


## Tab je sada 489 px (nema Merge precice), ali naslov i dalje pada do 34 px
## umjesto da gura brojac preko ruba.
func _fit_label() -> void:
	if _label == null or size.x <= 0.0:
		return
	var box := get_theme_stylebox("panel")
	var chrome := (box.get_margin(SIDE_LEFT) + box.get_margin(SIDE_RIGHT)) if box else 36.0
	var avail := size.x - chrome - UiCamp.TAB_ICON - 32.0
	var count_w := maxf(
		UiCamp.TAB_COUNT_MIN_W,
		32.0 + UiCamp.tight_font(UiCamp.FONT_TAB_COUNT).get_string_size(
			_count_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, UiCamp.FONT_TAB_COUNT
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
