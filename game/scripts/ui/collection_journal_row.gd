class_name CollectionJournalRow
extends Control

## BloomRow 1032 x 200. Info lijevo, tri TierSlot desno. Prazan tier je prsten.
## Nema T1/T2/T3 natpisa ni tamnog wella — biljka sjedi na krem/zlatnom okviru.

const BloomIcon := preload("res://scripts/ui/collection_bloom_icon.gd")

var _panel: PanelContainer
var _name: Label
var _stars: Label
var _caption: Label
var _badge: PanelContainer
var _badge_label: Label
var _frames: Array[Panel] = []
var _icons: Array[Control] = []
var _halos: Array[Panel] = []
var _entry: Dictionary = {}
var _built: bool = false


func apply(entry: Dictionary) -> void:
	_entry = entry
	if _built:
		_refresh()
	elif is_inside_tree():
		_ensure_built()
		_refresh()


func _ready() -> void:
	if not _entry.is_empty() and not _built:
		_ensure_built()
		_refresh()


func get_tier_icon(tier: int) -> Control:
	var idx := tier - 1
	if idx < 0 or idx >= _icons.size():
		return null
	return _icons[idx]


func get_caption_text() -> String:
	return _caption.text if _caption else ""


func get_name_text() -> String:
	return _name.text if _name else ""


func is_new_visible() -> bool:
	return _badge != null and _badge.visible


func empty_slot_count() -> int:
	var n := 0
	for icon in _icons:
		if not icon.visible:
			n += 1
	return n


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	custom_minimum_size = Vector2(0, UiJournal.ROW_H)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false

	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)

	var row := HBoxContainer.new()
	row.name = "RowHBox"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", UiJournal.ROW_INNER_GAP)
	_panel.add_child(row)

	var info := VBoxContainer.new()
	info.name = "InfoColumn"
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", UiJournal.INFO_GAP)
	row.add_child(info)

	var name_line := HBoxContainer.new()
	name_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_line.add_theme_constant_override("separation", UiJournal.NAME_STARS_GAP)
	info.add_child(name_line)
	_name = Label.new()
	_name.name = "BloomName"
	_name.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name.clip_text = true
	_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_line.add_child(_name)
	_stars = Label.new()
	_stars.name = "RarityStars"
	_stars.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_stars.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_line.add_child(_stars)
	var name_rest := Control.new()
	name_rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_rest.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_line.add_child(name_rest)
	name_line.resized.connect(_fit_name)

	_caption = Label.new()
	_caption.name = "RowCaption"
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.max_lines_visible = UiJournal.CAPTION_MAX_LINES
	_caption.custom_minimum_size.y = float(UiJournal.CAPTION_LINE * UiJournal.CAPTION_MAX_LINES)
	info.add_child(_caption)

	var strip := HBoxContainer.new()
	strip.name = "TierStrip"
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.alignment = BoxContainer.ALIGNMENT_CENTER
	strip.custom_minimum_size = Vector2(UiJournal.SLOT * 3 + UiJournal.SLOT_GAP * 2, UiJournal.SLOT)
	strip.add_theme_constant_override("separation", UiJournal.SLOT_GAP)
	row.add_child(strip)

	for tier in [1, 2, 3]:
		var slot := Control.new()
		slot.name = "SlotBox"
		slot.custom_minimum_size = Vector2(UiJournal.SLOT, UiJournal.SLOT)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.add_child(slot)
		var halo := Panel.new()
		halo.name = "NewHalo"
		halo.visible = false
		halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		halo.position = Vector2(-UiJournal.HALO_GROW, -UiJournal.HALO_GROW)
		halo.size = Vector2(UiJournal.SLOT + UiJournal.HALO_GROW * 2, UiJournal.SLOT + UiJournal.HALO_GROW * 2)
		slot.add_child(halo)
		var frame := Panel.new()
		frame.name = "Frame"
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.size = Vector2(UiJournal.SLOT, UiJournal.SLOT)
		slot.add_child(frame)
		var icon: Control = BloomIcon.new()
		icon.name = "TierIcon%d" % tier
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2((UiJournal.SLOT - UiJournal.ART) * 0.5, (UiJournal.SLOT - UiJournal.ART) * 0.5)
		icon.size = Vector2(UiJournal.ART, UiJournal.ART)
		icon.custom_minimum_size = icon.size
		slot.add_child(icon)
		_halos.append(halo)
		_frames.append(frame)
		_icons.append(icon)

	_badge = PanelContainer.new()
	_badge.name = "NewBadge"
	_badge.visible = false
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.z_index = 2
	_badge.position = UiJournal.NEW_BADGE_OFFSET
	_badge.add_theme_stylebox_override("panel", UiJournal.new_badge_style())
	add_child(_badge)
	_badge_label = Label.new()
	_badge_label.text = "NEW"
	_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge.add_child(_badge_label)


func _refresh() -> void:
	var state := str(_entry.get("state", "locked"))
	var locked := state == "locked"
	var rarity := int(_entry.get("rarity", 1))
	var type_id := str(_entry.get("type_id", ""))
	var show_new := bool(_entry.get("is_new", false)) and not locked
	var new_tier := int(_entry.get("new_tier", 0))
	var filled := UiJournal.filled_tiers(state)
	var ink := UiJournal.DISABLED_INK if locked else UiJournal.INK
	var caption_ink := UiJournal.DISABLED_INK if locked else (UiJournal.INK if show_new else UiJournal.CAPTION_INK)
	var caption_weight := 800 if show_new else 700

	_panel.add_theme_stylebox_override("panel", UiJournal.row_style(rarity, locked))
	_name.text = str(_entry.get("display_name", "???"))
	_stars.text = UiJournal.rarity_stars(rarity)
	_caption.text = UiJournal.caption_for(_entry, show_new)
	UiStage.style(_name, 900, UiJournal.NAME_FONT, ink)
	UiStage.style(_stars, 800, UiJournal.STARS_FONT, ink)
	UiStage.style(_caption, caption_weight, UiJournal.CAPTION_FONT, caption_ink, float(UiJournal.CAPTION_LINE) / float(UiJournal.CAPTION_FONT))

	for i in 3:
		var tier := i + 1
		var on := tier <= filled
		var crystal := on and tier == 3
		var kind := "crystal" if crystal else ("bloom" if on else "empty")
		_frames[i].add_theme_stylebox_override("panel", UiJournal.tier_frame_style(kind))
		var icon := _icons[i]
		icon.visible = on
		if icon.has_method("apply"):
			icon.call("apply", type_id, tier if on else 0, not on)
		_halos[i].visible = show_new and tier == new_tier
		if _halos[i].visible:
			_halos[i].add_theme_stylebox_override("panel", UiJournal.tier_halo_style(crystal))

	_badge.visible = show_new
	if show_new:
		UiStage.style(_badge_label, 900, UiJournal.NEW_BADGE_FONT, UiJournal.INK, 1.0, 0.06)
		_badge.reset_size()
	_fit_name()


## Ime stoji uz zvjezdice; ako ne stane, samo se ime reže.
func _fit_name() -> void:
	if _name == null or _stars == null:
		return
	var line := _name.get_parent() as Control
	if line == null or line.size.x < 120.0:
		return
	var natural := UiStage.text_w(UiStage.font(900, UiJournal.NAME_FONT), UiJournal.NAME_FONT, _name.text)
	var max_w := line.size.x - _stars.get_combined_minimum_size().x - float(UiJournal.NAME_STARS_GAP)
	if max_w < 80.0:
		return
	_name.custom_minimum_size.x = minf(natural, max_w)
