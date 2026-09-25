class_name HubTab
extends HubPressable

## Tab hub footera — v2: cijeli slot (216 x 141) je hit-zona, tile 184 x 108 nosi
## stanje, a ikona je jedini sadržaj (labela je uklonjena). Aktivan tab se razlikuje
## po četiri stvari: peach ploča, ikona u boji, 72 px umjesto 64 i indikator iznad.
## Ime taba ostaje kao accessible name (tooltip), nevidljivo.

const PRESSED_SCALE := 0.96
const BADGE_MAX := 9

var _text: String = ""
var _icon_dark: Texture2D = null
var _icon_light: Texture2D = null
var _active: bool = false
var _badge_count: int = 0
var _styles: Dictionary = {}
var _tile: PanelContainer = null
var _icon: TextureRect = null
var _badge: PanelContainer = null
var _badge_label: Label = null


func _ready() -> void:
	super()
	custom_minimum_size = Vector2(UiChrome.TAB_SLOT_W, UiChrome.FOOTER_CONTENT_H)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build()
	resized.connect(_layout)
	_apply_state()
	_refresh_badge()


## Ikona: u boji na peach ploči (aktivan), krem linijska na traci (neaktivan).
func setup(text: String, icon_dark: Texture2D, icon_light: Texture2D) -> void:
	_text = text
	_icon_dark = icon_dark
	_icon_light = icon_light
	tooltip_text = text
	_apply_state()


func set_active(on: bool) -> void:
	if _active == on:
		return
	_active = on
	_apply_state()


func is_active() -> bool:
	return _active


func get_tab_text() -> String:
	return _text


func set_badge_count(count: int) -> void:
	_badge_count = maxi(count, 0)
	_refresh_badge()


func get_badge_count() -> int:
	return _badge_count


func _apply_state() -> void:
	if _tile == null:
		return
	var pressing := is_pressing()
	var state := "inactive"
	if _active:
		state = "active_pressed" if pressing else "active"
	elif pressing:
		state = "pressed"
	_tile.add_theme_stylebox_override("panel", _styles[state])
	_tile.scale = Vector2.ONE * (PRESSED_SCALE if pressing and not _active else 1.0)
	var tex: Texture2D = _icon_dark if _active else _icon_light
	if tex == null:
		tex = _icon_light if _active else _icon_dark
	_icon.texture = tex
	_icon.visible = tex != null
	var side := UiChrome.TAB_ICON_SIZE_ACTIVE if _active else UiChrome.TAB_ICON_SIZE
	_icon.custom_minimum_size = Vector2(side, side)
	_icon.size = Vector2(side, side)
	# Ikone su u boji i fiksne — smije se mijenjati samo alpha, nikad RGB.
	_icon.modulate = Color(1.0, 1.0, 1.0, 1.0 if _active else UiChrome.INACTIVE_INK_ALPHA)
	_layout()


func _build() -> void:
	for state in ["inactive", "active", "pressed", "active_pressed"]:
		_styles[state] = UiChrome.tab_style(state)
	_tile = PanelContainer.new()
	_tile.name = "Tile"
	_tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tile)
	_icon = TextureRect.new()
	_icon.name = "Icon"
	_icon.custom_minimum_size = Vector2(UiChrome.TAB_ICON_SIZE, UiChrome.TAB_ICON_SIZE)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon)
	_badge = PanelContainer.new()
	_badge.name = "Badge"
	_badge.visible = false
	_badge.custom_minimum_size = Vector2(UiChrome.BADGE_SIZE, UiChrome.BADGE_SIZE)
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.add_theme_stylebox_override("panel", UiChrome.badge_style())
	add_child(_badge)
	_badge_label = Label.new()
	_badge_label.name = "Count"
	_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_badge_label.add_theme_font_size_override("font_size", UiChrome.BADGE_FONT_SIZE)
	_badge_label.add_theme_font_override("font", UiChrome.heavy_font(UiChrome.EMBOLDEN_800))
	_badge_label.add_theme_color_override("font_color", UiPalette.OUTLINE)
	_badge.add_child(_badge_label)


func _layout() -> void:
	if _tile == null:
		return
	var tile_pos := Vector2(floorf((size.x - UiChrome.TAB_TILE_W) * 0.5), UiChrome.TAB_TILE_TOP)
	_tile.position = tile_pos
	_tile.size = Vector2(UiChrome.TAB_TILE_W, UiChrome.TAB_TILE_H)
	_tile.pivot_offset = _tile.size * 0.5
	var side := float(UiChrome.TAB_ICON_SIZE_ACTIVE if _active else UiChrome.TAB_ICON_SIZE)
	var lift := float(UiChrome.TAB_ICON_ACTIVE_LIFT) if _active else 0.0
	_icon.size = Vector2(side, side)
	_icon.position = (
		tile_pos
		+ (Vector2(UiChrome.TAB_TILE_W, UiChrome.TAB_TILE_H) - Vector2(side, side)) * 0.5
		+ Vector2(0.0, lift)
	)
	if _badge.visible:
		var badge_size := _badge.get_combined_minimum_size()
		_badge.size = badge_size
		_badge.position = (
			tile_pos + Vector2(UiChrome.TAB_TILE_W - badge_size.x, 0.0) + UiChrome.BADGE_OFFSET
		)


func _refresh_badge() -> void:
	if _badge == null:
		return
	_badge.visible = _badge_count > 0
	_badge_label.text = str(_badge_count) if _badge_count <= BADGE_MAX else "%d+" % BADGE_MAX
	_layout()
