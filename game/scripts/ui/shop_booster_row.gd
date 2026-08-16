class_name ShopBoosterRow
extends VBoxContainer

signal buy_pressed(booster_id: String)
signal use_pressed(booster_id: String)

const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const TYPO := preload("res://scripts/ui/ui_typography.gd")

var booster_id: String = ""
var _title: Label
var _desc: Label
var _count: Label
var _buy: Button
var _use: Button
var _built: bool = false


func apply(id: String) -> void:
	booster_id = id
	if _built:
		_refresh()


func _ready() -> void:
	_ensure_built()
	if _buy and not _buy.pressed.is_connected(_on_buy):
		_buy.pressed.connect(_on_buy)
	if _use and not _use.pressed.is_connected(_on_use):
		_use.pressed.connect(_on_use)
	if not booster_id.is_empty():
		_refresh()


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	custom_minimum_size = Vector2(0, 108)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 8)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	add_child(top)

	_title = Label.new()
	TEXT_LAYOUT.card_title_scroll(_title)
	_title.add_theme_font_size_override("font_size", 28)
	_title.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)
	top.add_child(_title)

	_count = Label.new()
	_count.add_theme_font_size_override("font_size", TYPO.BODY)
	_count.add_theme_color_override("font_color", Color(0.35, 0.38, 0.55))
	top.add_child(_count)

	_desc = Label.new()
	TEXT_LAYOUT.body_label_scroll(_desc)
	_desc.add_theme_color_override("font_color", Color(0.42, 0.4, 0.48))
	add_child(_desc)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	add_child(row)

	_use = Button.new()
	_use.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_use.custom_minimum_size = Vector2(0, 56)
	_use.add_theme_font_size_override("font_size", 26)
	row.add_child(_use)

	_buy = Button.new()
	_buy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buy.custom_minimum_size = Vector2(0, 56)
	_buy.add_theme_font_size_override("font_size", 26)
	row.add_child(_buy)


func _refresh() -> void:
	if not _built or booster_id.is_empty():
		return
	var sku := CONFIG.booster_sku(booster_id)
	_title.text = CONFIG.get_product_title(sku)
	_desc.text = CONFIG.get_product_description(sku)
	var owned := GameState.get_booster_count(booster_id)
	_count.text = "×%d" % owned
	_use.text = "Use"
	_use.disabled = owned <= 0
	_buy.text = "Buy %s" % IAPManager.get_price_label(sku)
	_buy.disabled = IAPManager.is_busy()


func _on_buy() -> void:
	if not booster_id.is_empty():
		buy_pressed.emit(booster_id)


func _on_use() -> void:
	if not booster_id.is_empty():
		use_pressed.emit(booster_id)
