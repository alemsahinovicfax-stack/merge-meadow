class_name ShopCosmeticRow
extends HBoxContainer

signal buy_pressed(item_id: String)
signal equip_pressed(item_id: String)

const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const CATALOG := preload("res://scripts/monetization/cosmetic_catalog.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")

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
	custom_minimum_size = Vector2(0, 100)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 12)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 6)
	add_child(text_col)

	_title = Label.new()
	TEXT_LAYOUT.card_title_scroll(_title)
	_title.add_theme_font_size_override("font_size", 28)
	_title.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)
	text_col.add_child(_title)

	_desc = Label.new()
	TEXT_LAYOUT.body_label_scroll(_desc)
	_desc.add_theme_color_override("font_color", Color(0.4, 0.42, 0.4))
	text_col.add_child(_desc)

	_action = Button.new()
	_action.custom_minimum_size = Vector2(168, 60)
	_action.add_theme_font_size_override("font_size", 26)
	add_child(_action)


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
