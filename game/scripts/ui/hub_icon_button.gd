class_name HubIconButton
extends HubPressable

## Icon tile u hub headeru (Settings) — tile 100 x 100 u hit-zoni 124 x 140.

const PRESSED_SCALE := 0.96

var _icon_texture: Texture2D = null
var _style_normal: StyleBoxFlat = null
var _style_pressed: StyleBoxFlat = null
var _tile: PanelContainer = null
var _icon: TextureRect = null


func _ready() -> void:
	super()
	custom_minimum_size = Vector2(UiChrome.SETTINGS_SLOT_W, UiChrome.SETTINGS_HIT_H)
	_build()
	resized.connect(_layout)
	_layout()
	_apply_state()


func set_icon(tex: Texture2D) -> void:
	_icon_texture = tex
	if _icon:
		_icon.texture = tex


func _apply_state() -> void:
	if _tile == null:
		return
	var pressing := is_pressing()
	_tile.add_theme_stylebox_override("panel", _style_pressed if pressing else _style_normal)
	_tile.scale = Vector2.ONE * (PRESSED_SCALE if pressing else 1.0)


func _build() -> void:
	_style_normal = UiChrome.icon_button_style(false)
	_style_pressed = UiChrome.icon_button_style(true)
	_tile = PanelContainer.new()
	_tile.name = "Tile"
	_tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tile)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tile.add_child(center)
	_icon = TextureRect.new()
	_icon.name = "Icon"
	_icon.custom_minimum_size = Vector2(UiChrome.SETTINGS_ICON_SIZE, UiChrome.SETTINGS_ICON_SIZE)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.texture = _icon_texture
	center.add_child(_icon)


func _layout() -> void:
	if _tile == null:
		return
	_tile.position = Vector2(UiChrome.SETTINGS_LEAD, floorf((size.y - UiChrome.SETTINGS_SIZE) * 0.5))
	_tile.size = Vector2(UiChrome.SETTINGS_SIZE, UiChrome.SETTINGS_SIZE)
	_tile.pivot_offset = _tile.size * 0.5
