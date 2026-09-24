class_name ShopPriceTag
extends PanelContainer

## Cjenovnik za pravi novac (design_handoff_shop · components.PriceTag.money).
## Store string moze biti dug ("Rp 57.900") — preko 7 znakova font pada na 44,
## a tag raste u sirinu umjesto da reze tekst.

var _price: Label
var _sub: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_theme_stylebox_override("panel", UiShop.price_tag_style(false))
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 0)
	add_child(col)
	_price = Label.new()
	_price.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_price)
	_sub = Label.new()
	_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_sub)


func configure(price_text: String, sub_text: String, min_w: float = UiShop.MONEY_PRICE_MIN_W) -> void:
	if _price == null:
		return
	custom_minimum_size = Vector2(min_w, UiShop.MONEY_ROW_H)
	_price.text = price_text
	UiShop.style(_price, UiShop.price_font_px(price_text), UiShop.PRICE_INK, UiShop.HEAVY)
	_sub.text = sub_text
	_sub.visible = not sub_text.is_empty()
	UiShop.style(_sub, UiShop.FONT_BODY, UiShop.PRICE_SUB_INK, UiShop.BOLD)


func get_price_text() -> String:
	return _price.text if _price else ""
