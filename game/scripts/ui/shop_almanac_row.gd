class_name ShopAlmanacRow
extends PanelContainer

signal coin_unlock_pressed

const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const READABILITY := preload("res://scripts/ui/ui_readability.gd")

var _entry: Dictionary = {}
var _title: Label
var _tier_row: HBoxContainer
var _tier_labels: Array[Label] = []
var _caption: Label
var _progress_row: HBoxContainer
var _progress_label: Label
var _progress: ProgressBar
var _coin_button: UiClickButton
var _built: bool = false


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

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 6)
	add_child(root)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", READABILITY.font(22))
	_title.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)
	root.add_child(_title)

	_tier_row = HBoxContainer.new()
	_tier_row.add_theme_constant_override("separation", 8)
	root.add_child(_tier_row)
	for tier in [1, 2, 3]:
		var chip := Label.new()
		chip.add_theme_font_size_override("font_size", READABILITY.font(16))
		_tier_row.add_child(chip)
		_tier_labels.append(chip)

	_caption = Label.new()
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_font_size_override("font_size", READABILITY.font(16))
	_caption.add_theme_color_override("font_color", Color(0.38, 0.42, 0.38))
	root.add_child(_caption)

	_progress_row = HBoxContainer.new()
	_progress_row.add_theme_constant_override("separation", 10)
	root.add_child(_progress_row)

	_progress = ProgressBar.new()
	_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress.custom_minimum_size = Vector2(0, 24)
	_progress.show_percentage = false
	_style_progress_bar()
	_progress_row.add_child(_progress)

	_progress_label = Label.new()
	_progress_label.custom_minimum_size = Vector2(64, 0)
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_progress_label.add_theme_font_size_override("font_size", READABILITY.font(17))
	_progress_label.add_theme_color_override("font_color", Color(0.28, 0.42, 0.3))
	_progress_row.add_child(_progress_label)

	_coin_button = UiClickButton.new()
	_coin_button.custom_minimum_size = Vector2(0, 52)
	_coin_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_coin_button.font_size = 19
	_coin_button.button_variant = "primary"
	root.add_child(_coin_button)


func _ready() -> void:
	_ensure_built()
	if _coin_button and not _coin_button.clicked.is_connected(_on_coin_pressed):
		_coin_button.clicked.connect(_on_coin_pressed)
	if not _entry.is_empty():
		_refresh()


func _style_progress_bar() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.88, 0.9, 0.88)
	bg.set_corner_radius_all(8)
	_progress.add_theme_stylebox_override("background", bg)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.38, 0.76, 0.46)
	fill.set_corner_radius_all(8)
	_progress.add_theme_stylebox_override("fill", fill)


func _refresh() -> void:
	if not _built:
		return

	var name: String = str(_entry.get("name", "?"))
	var stars: String = str(_entry.get("stars", ""))
	var spawn_unlocked := bool(_entry.get("spawn_unlocked", false))
	var almanac_tier := int(_entry.get("almanac_tier", 0))
	var prog: Dictionary = _entry.get("tier_progress", {})
	var coin_cost := int(_entry.get("coin_cost", 0))

	if spawn_unlocked:
		_apply_panel_tint(Color(0.78, 0.94, 0.84, 0.55))
		_title.text = "%s %s" % [name, stars]
	else:
		_apply_panel_tint(Color(0.94, 0.94, 0.94, 0.7))
		_title.text = "%s %s" % [name, stars]

	_refresh_tier_chips(spawn_unlocked, almanac_tier)

	var complete := bool(prog.get("complete", false))
	var have := int(prog.get("have", 0))
	var need := maxi(1, int(prog.get("need", 1)))
	var caption := str(prog.get("caption", ""))

	if spawn_unlocked and complete:
		_caption.text = "All tiers discovered"
		_show_bar(false, 0, 1)
		_coin_button.visible = false
		custom_minimum_size.y = 96
	elif caption.is_empty():
		_caption.visible = false
		_show_bar(false, 0, 1)
		_coin_button.visible = false
		custom_minimum_size.y = 80
	else:
		_caption.visible = true
		_caption.text = caption
		_show_bar(true, have, need)
		if not spawn_unlocked and coin_cost > 0 and bool(_entry.get("can_coin_unlock", false)):
			_coin_button.visible = true
			_coin_button.label_text = "Unlock Tier 1 — %d coins" % coin_cost
			_coin_button.disabled = GameState.wallet_coins < coin_cost
			custom_minimum_size.y = 148
		else:
			_coin_button.visible = false
			custom_minimum_size.y = 112


func _refresh_tier_chips(spawn_unlocked: bool, almanac_tier: int) -> void:
	for i in _tier_labels.size():
		var tier := i + 1
		var chip := _tier_labels[i]
		if not spawn_unlocked:
			chip.text = "T%d 🔒" % tier
			chip.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		elif almanac_tier >= tier:
			chip.text = "T%d ✓" % tier
			chip.add_theme_color_override("font_color", Color(0.22, 0.52, 0.28))
		elif almanac_tier + 1 == tier:
			chip.text = "T%d …" % tier
			chip.add_theme_color_override("font_color", Color(0.72, 0.52, 0.18))
		else:
			chip.text = "T%d 🔒" % tier
			chip.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))


func _show_bar(visible_row: bool, have: int, need: int) -> void:
	_progress_row.visible = visible_row
	if visible_row:
		_progress.max_value = float(maxi(1, need))
		_progress.value = float(clampi(have, 0, need))
		_progress_label.text = "%d / %d" % [have, need]


func _apply_panel_tint(bg: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(10)
	style.set_border_width_all(2)
	style.border_color = Color(UI_PALETTE.OUTLINE.r, UI_PALETTE.OUTLINE.g, UI_PALETTE.OUTLINE.b, 0.1)
	style.content_margin_left = 12.0
	style.content_margin_top = 10.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 10.0
	add_theme_stylebox_override("panel", style)


func _on_coin_pressed() -> void:
	coin_unlock_pressed.emit()
