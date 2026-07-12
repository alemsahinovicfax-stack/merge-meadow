class_name BloomInboxItem
extends PanelContainer

signal action_pressed(action: String, index: int)

const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const READABILITY := preload("res://scripts/ui/ui_readability.gd")

var inbox_index: int = -1
var _type_id: String = ""
var _tier: int = 0
var _title: Label
var _donate_btn: UiClickButton
var _keep_btn: UiClickButton
var _basket_btn: UiClickButton


func setup(index: int, type_id: String, tier: int) -> void:
	inbox_index = index
	_type_id = type_id
	_tier = tier
	if _donate_btn == null:
		_build()
	_refresh()


func _build() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.97, 0.9, 0.95)
	style.set_corner_radius_all(10)
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	add_theme_stylebox_override("panel", style)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	add_child(col)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", READABILITY.font(16))
	_title.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)
	col.add_child(_title)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	col.add_child(row)

	_donate_btn = UiClickButton.new()
	_donate_btn.custom_minimum_size = Vector2(0, 40)
	_donate_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_donate_btn.font_size = 14
	_donate_btn.clicked.connect(func() -> void: action_pressed.emit("donate", inbox_index))
	row.add_child(_donate_btn)

	_keep_btn = UiClickButton.new()
	_keep_btn.custom_minimum_size = Vector2(0, 40)
	_keep_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_keep_btn.font_size = 14
	_keep_btn.label_text = "Keep"
	_keep_btn.button_variant = "accent"
	_keep_btn.clicked.connect(func() -> void: action_pressed.emit("keep", inbox_index))
	row.add_child(_keep_btn)

	_basket_btn = UiClickButton.new()
	_basket_btn.custom_minimum_size = Vector2(0, 40)
	_basket_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_basket_btn.font_size = 14
	_basket_btn.label_text = "Basket"
	_basket_btn.button_variant = "subtle"
	_basket_btn.clicked.connect(func() -> void: action_pressed.emit("basket", inbox_index))
	row.add_child(_basket_btn)


func _refresh() -> void:
	if _donate_btn == null:
		return
	var name: String = GameState.SEED_DISPLAY_NAMES.get(_type_id, _type_id.capitalize())
	_title.text = "%s T%d" % [name, _tier]
	if _tier == 2:
		var can := GameState.sprinkler_donations < GameState.MAGNET_COST_T2
		can = can and GameState.magnet_level < GameState.MAGNET_MAX_LEVEL
		_donate_btn.label_text = "Donate"
		_donate_btn.disabled = not can
		if GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL:
			_donate_btn.label_text = "Maxed"
	else:
		var can_t3 := GameState.multiplier_donations < GameState.MULTIPLIER_COST_T3
		can_t3 = can_t3 and GameState.multiplier_level < GameState.MULTIPLIER_MAX_LEVEL
		_donate_btn.label_text = "Donate"
		_donate_btn.disabled = not can_t3
		if GameState.multiplier_level >= GameState.MULTIPLIER_MAX_LEVEL:
			_donate_btn.label_text = "Maxed"
