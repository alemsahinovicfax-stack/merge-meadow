class_name ShopJumpChip
extends HubPressable

## Chip u sticky redu Shopa (design_handoff_shop · layout.JumpChip). Tap skroluje
## do sekcije, a scroll-spy pali onaj koji je trenutno na ekranu.

var section: String = ""

var _tile: PanelContainer
var _label: Label
var _active: bool = false


func _ready() -> void:
	super()
	custom_minimum_size.y = UiShop.JUMP_H
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build()
	_apply_state()


func setup(section_id: String, text: String) -> void:
	section = section_id
	if _label:
		_label.text = text
	_apply_state()


func set_active(on: bool) -> void:
	if _active == on:
		return
	_active = on
	_apply_state()


func is_active() -> bool:
	return _active


func get_label_text() -> String:
	return _label.text if _label else ""


func _build() -> void:
	_tile = PanelContainer.new()
	_tile.name = "Tile"
	_tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_tile)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_tile.add_child(_label)


func _apply_state() -> void:
	if _tile == null:
		return
	_tile.add_theme_stylebox_override("panel", UiShop.jump_chip_style(_active))
	UiShop.style(
		_label,
		UiShop.JUMP_FONT,
		UiShop.jump_chip_ink(_active),
		UiShop.HEAVY if _active else UiShop.BOLD
	)
	_tile.modulate.a = 0.82 if is_pressing() else 1.0
