class_name ShopPurchaseStatus
extends PanelContainer

## Poruka na samoj kartici (design_handoff_shop · components.PurchaseStatus).
## "ok" nestaje poslije 2,4 s, "fail" i "pending" ostaju do sljedećeg tapa.

signal cleared

var _icon: TextureRect
var _title: Label
var _sub: Label
var _kind: String = ""
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	custom_minimum_size.y = UiShop.STATUS_MIN_H
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	add_child(row)
	_icon = TextureRect.new()
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.custom_minimum_size = Vector2(40, 40)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_icon)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)
	_title = Label.new()
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_title)
	_sub = Label.new()
	_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_sub)


func show_status(kind: String, title: String, sub: String = "") -> void:
	if _title == null:
		return
	_kind = kind
	add_theme_stylebox_override("panel", UiShop.status_style(kind))
	_icon.texture = UiAssets.get_arena_icon("icon_check") if kind == UiShop.STATUS_OK else null
	_icon.visible = _icon.texture != null
	_title.text = title
	UiShop.style(_title, UiShop.FONT_STATUS, UiShop.INK, UiShop.HEAVY)
	_sub.text = sub
	_sub.visible = not sub.is_empty()
	UiShop.style(_sub, UiShop.FONT_STATUS, UiShop.SUB_INK, UiShop.REGULAR)
	visible = true
	modulate.a = 0.0
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, UiShop.T_STATUS_IN)
	if kind == UiShop.STATUS_OK:
		_tween.tween_interval(UiShop.T_STATUS_HOLD)
		_tween.tween_property(self, "modulate:a", 0.0, 0.2)
		_tween.tween_callback(clear)


func get_kind() -> String:
	return _kind


func get_title_text() -> String:
	return _title.text if _title else ""


func clear() -> void:
	_kill_tween()
	_kind = ""
	visible = false
	if _title:
		_title.text = ""
	cleared.emit()


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
