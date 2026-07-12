class_name ShopCosmeticRow
extends PanelContainer

signal buy_pressed(item_id: String)
signal equip_pressed(item_id: String)

const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const CATALOG := preload("res://scripts/monetization/cosmetic_catalog.gd")

var item_id: String = ""
var _title: Label
var _desc: Label
var _action: Button
var _built: bool = false


func apply(cosmetic_id: String) -> void:
	item_id = cosmetic_id
	if _built:
		_refresh()


func _ready() -> void:
	_ensure_built()
	if _action and not _action.pressed.is_connected(_on_action):
		_action.pressed.connect(_on_action)
	if not item_id.is_empty():
		_refresh()


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	custom_minimum_size = Vector2(0, 88)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.98, 0.94, 0.92)
	style.set_corner_radius_all(10)
	style.set_border_width_all(2)
	style.border_color = Color(UI_PALETTE.OUTLINE.r, UI_PALETTE.OUTLINE.g, UI_PALETTE.OUTLINE.b, 0.1)
	style.content_margin_left = 12.0
	style.content_margin_top = 8.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 8.0
	add_theme_stylebox_override("panel", style)

	var root := HBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 4)
	root.add_child(text_col)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 20)
	_title.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)
	text_col.add_child(_title)

	_desc = Label.new()
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.add_theme_font_size_override("font_size", 15)
	_desc.add_theme_color_override("font_color", Color(0.4, 0.42, 0.4))
	text_col.add_child(_desc)

	_action = Button.new()
	_action.custom_minimum_size = Vector2(132, 52)
	_action.add_theme_font_size_override("font_size", 16)
	root.add_child(_action)


func _refresh() -> void:
	if not _built or item_id.is_empty():
		return
	_title.text = CATALOG.get_title(item_id)
	_desc.text = CATALOG.get_description(item_id)
	var cost := CATALOG.get_coin_cost(item_id)
	var owned := GameState.owns_cosmetic(item_id)
	var equipped := GameState.is_cosmetic_equipped(item_id)
	if owned and equipped:
		_action.text = "Equipped"
		_action.disabled = true
	elif owned:
		_action.text = "Equip"
		_action.disabled = false
	else:
		_action.text = "%d coins" % cost
		_action.disabled = GameState.wallet_coins < cost


func _on_action() -> void:
	if item_id.is_empty():
		return
	if GameState.owns_cosmetic(item_id):
		equip_pressed.emit(item_id)
	else:
		buy_pressed.emit(item_id)
