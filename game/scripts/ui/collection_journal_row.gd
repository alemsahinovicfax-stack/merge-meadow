class_name CollectionJournalRow
extends Control

const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const READABILITY := preload("res://scripts/ui/ui_readability.gd")
const TYPO := preload("res://scripts/ui/ui_typography.gd")
const BloomIcon := preload("res://scripts/ui/collection_bloom_icon.gd")

const TIER_ICON_SIZE := 64.0

## NEW badge hovers above the card's top-right corner, so it must live outside
## the PanelContainer (which forces all its children to the same content rect).
var _panel: PanelContainer

var _entry: Dictionary = {}
var _built: bool = false
var _title: Label
var _stars: Label
var _new_badge: Label
var _tier_icons: Array[Control] = []
var _tier_captions: Array[Label] = []


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


func _get_minimum_size() -> Vector2:
	if _panel:
		return _panel.get_combined_minimum_size()
	return Vector2.ZERO


func get_tier_icon(tier: int) -> Control:
	var idx := tier - 1
	if idx < 0 or idx >= _tier_icons.size():
		return null
	return _tier_icons[idx]


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	custom_minimum_size = Vector2(0, 120)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_contents = false

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_theme_stylebox_override("panel", UI_PALETTE.rarity_bg_style(1, true))
	add_child(_panel)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel.add_child(root)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	root.add_child(title_row)

	_title = Label.new()
	TEXT_LAYOUT.card_title_scroll_readable(_title)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)
	title_row.add_child(_title)

	_stars = Label.new()
	_stars.size_flags_horizontal = Control.SIZE_SHRINK_END
	_stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_stars.add_theme_font_size_override("font_size", READABILITY.font(TYPO.BODY))
	_stars.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)
	title_row.add_child(_stars)

	# Floats above the panel's top-right corner (outside its bounds) — sibling
	# of _panel, not a child of it, since PanelContainer forces children to
	# share one content rect and can't host a freely-anchored overlay.
	_new_badge = Label.new()
	_new_badge.text = "NEW"
	_new_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TEXT_LAYOUT.caption_label_scroll_readable(_new_badge)
	_new_badge.add_theme_color_override("font_color", Color(1.0, 0.953, 0.918))
	var badge_bg := StyleBoxFlat.new()
	badge_bg.bg_color = Color(0.851, 0.478, 0.333)
	badge_bg.set_corner_radius_all(20)
	badge_bg.set_border_width_all(2)
	badge_bg.border_color = Color(0.722, 0.373, 0.243)
	badge_bg.content_margin_left = 16.0
	badge_bg.content_margin_right = 16.0
	badge_bg.content_margin_top = 6.0
	badge_bg.content_margin_bottom = 6.0
	_new_badge.add_theme_stylebox_override("normal", badge_bg)
	_new_badge.anchor_left = 1.0
	_new_badge.anchor_right = 1.0
	_new_badge.anchor_top = 0.0
	_new_badge.anchor_bottom = 0.0
	_new_badge.offset_left = -22.0
	_new_badge.offset_right = -22.0
	_new_badge.offset_top = -16.0
	_new_badge.offset_bottom = -16.0
	_new_badge.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_new_badge.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_new_badge)

	var tier_row := HBoxContainer.new()
	tier_row.name = "TierIconsRow"
	tier_row.add_theme_constant_override("separation", 44)
	tier_row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(tier_row)

	for tier in [1, 2, 3]:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 6)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		tier_row.add_child(col)

		var icon: Control = BloomIcon.new()
		icon.name = "TierIcon%d" % tier
		icon.custom_minimum_size = Vector2(TIER_ICON_SIZE, TIER_ICON_SIZE)
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		col.add_child(icon)
		_tier_icons.append(icon)

		var cap := Label.new()
		cap.text = "T%d" % tier
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		TEXT_LAYOUT.caption_label_scroll_readable(cap)
		col.add_child(cap)
		_tier_captions.append(cap)


func _refresh() -> void:
	var state := str(_entry.get("state", "locked"))
	var kept_tier := int(_entry.get("kept_tier", 0))
	var rarity := int(_entry.get("rarity", 1))
	var type_id := str(_entry.get("type_id", ""))
	var locked_entry := state == "locked"

	_title.text = str(_entry.get("display_name", "?"))
	_stars.text = "★".repeat(clampi(rarity, 1, 3))
	_new_badge.visible = bool(_entry.get("is_new", false))

	for i in 3:
		var tier := i + 1
		var unlocked := false
		if not locked_entry:
			if tier == 1:
				unlocked = true
			else:
				unlocked = kept_tier >= tier
		var icon := _tier_icons[i]
		if icon.has_method("apply"):
			icon.call("apply", type_id, tier if unlocked else 0, not unlocked)
		var cap: Label = _tier_captions[i]
		if unlocked:
			cap.add_theme_color_override("font_color", Color(0.22, 0.48, 0.28))
		else:
			cap.add_theme_color_override("font_color", Color(0.55, 0.58, 0.55))

	_panel.add_theme_stylebox_override("panel", UI_PALETTE.rarity_bg_style(rarity, locked_entry))
