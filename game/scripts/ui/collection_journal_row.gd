class_name CollectionJournalRow
extends PanelContainer

const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const READABILITY := preload("res://scripts/ui/ui_readability.gd")
const TYPO := preload("res://scripts/ui/ui_typography.gd")
const BloomIcon := preload("res://scripts/ui/collection_bloom_icon.gd")

var _entry: Dictionary = {}
var _built: bool = false
var _icon: Control
var _title: Label
var _stars: Label
var _caption: Label
var _new_badge: Label
var _tier_row: HBoxContainer
var _tier_labels: Array[Label] = []


func apply(entry: Dictionary) -> void:
	_entry = entry
	if _built:
		_refresh()
	elif is_inside_tree():
		_ensure_built()
		_refresh()


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	custom_minimum_size = Vector2(0, 72)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := UI_PALETTE.button_style("subtle", "normal")
	add_theme_stylebox_override("panel", style)

	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(root)

	_icon = BloomIcon.new()
	_icon.custom_minimum_size = Vector2(72, 72)
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	root.add_child(_icon)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 4)
	root.add_child(text_col)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	text_col.add_child(title_row)

	_title = Label.new()
	TEXT_LAYOUT.card_title_scroll_readable(_title)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)
	title_row.add_child(_title)

	_new_badge = Label.new()
	_new_badge.text = "NEW"
	TEXT_LAYOUT.caption_label_scroll_readable(_new_badge)
	_new_badge.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85))
	var badge_bg := StyleBoxFlat.new()
	badge_bg.bg_color = Color(0.85, 0.35, 0.28)
	badge_bg.set_corner_radius_all(8)
	badge_bg.content_margin_left = 8.0
	badge_bg.content_margin_right = 8.0
	badge_bg.content_margin_top = 2.0
	badge_bg.content_margin_bottom = 2.0
	_new_badge.add_theme_stylebox_override("normal", badge_bg)
	title_row.add_child(_new_badge)

	_stars = Label.new()
	_stars.add_theme_font_size_override("font_size", READABILITY.font(TYPO.BODY))
	_stars.add_theme_color_override("font_color", Color(0.72, 0.62, 0.2))
	text_col.add_child(_stars)

	_tier_row = HBoxContainer.new()
	_tier_row.add_theme_constant_override("separation", 8)
	text_col.add_child(_tier_row)
	for tier in [1, 2, 3]:
		var chip := Label.new()
		TEXT_LAYOUT.caption_label_scroll_readable(chip)
		_tier_row.add_child(chip)
		_tier_labels.append(chip)

	_caption = Label.new()
	TEXT_LAYOUT.body_label_scroll(_caption)
	_caption.add_theme_color_override("font_color", Color(0.38, 0.42, 0.38))
	text_col.add_child(_caption)


func _refresh() -> void:
	var state := str(_entry.get("state", "locked"))
	var kept_tier := int(_entry.get("kept_tier", 0))
	var display_tier := int(_entry.get("display_tier", 0))
	var rarity := int(_entry.get("rarity", 1))
	var locked := state == "locked"

	_title.text = str(_entry.get("display_name", "?"))
	_stars.text = "★".repeat(clampi(rarity, 1, 3))
	_new_badge.visible = bool(_entry.get("is_new", false))

	if _icon.has_method("apply"):
		_icon.call("apply", str(_entry.get("type_id", "")), display_tier if not locked else 0, locked)

	for i in 3:
		var tier := i + 1
		var chip: Label = _tier_labels[i]
		if locked:
			chip.text = "T%d — ?" % tier
			chip.add_theme_color_override("font_color", Color(0.55, 0.58, 0.55))
		elif kept_tier >= tier:
			chip.text = "T%d ✓" % tier
			chip.add_theme_color_override("font_color", Color(0.22, 0.48, 0.28))
		else:
			chip.text = "T%d —" % tier
			chip.add_theme_color_override("font_color", Color(0.62, 0.64, 0.6))

	match state:
		"locked":
			_caption.text = "Keep playing to discover this bloom."
		"seen":
			_caption.text = "Spotted in runs — merge to T2, then Keep in Album."
		"album_t2":
			_caption.text = "In your Album (T2 bloom). Merge to T3 for crystal."
		"album_t3":
			_caption.text = "Crystal bloom saved in Album!"
		_:
			_caption.text = ""

	if bool(_entry.get("is_new", false)):
		var new_tier := int(_entry.get("new_tier", 1))
		if new_tier >= 3:
			_caption.text = "New crystal in Album!"
		elif new_tier >= 2:
			_caption.text = "New bloom kept in Album!"
		else:
			_caption.text = "New discovery!"
