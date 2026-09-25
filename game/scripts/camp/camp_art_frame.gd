class_name CampArtFrame
extends Control

## Okvir za art u Campu (design_handoff_camp · ArtFrame + ArtWell): sjeme = cream
## krug, cvijet = coin gold zaobljen kvadrat, tamni well kao Arena chip.
## Crta cvijet (ArenaChipDraw) ili jednobojnu ikonu (tabovi, bez wella).

var seed_shape: bool = true
var type_id: String = ""
var tier: int = 1
var frame_side: float = UiCamp.CHIP_ART_FRAME
var frame_radius: int = 26
var frame_border: int = 3
var well_inset: float = UiCamp.CHIP_ART_WELL_INSET
var well_radius: int = 18
var well_border: int = 2
var art_size: float = UiCamp.CHIP_ART_SEED
var icon: Texture2D = null
var icon_size: float = UiCamp.TAB_ICON_ART


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sync_min_size()


## Okvir chipa (104), Trade bara (88) ili kartice sezone (52).
func configure_frame(side: float, radius: int, border: int, inset: float, inner_radius: int, inner_border: int, art: float) -> void:
	frame_side = side
	frame_radius = radius
	frame_border = border
	well_inset = inset
	well_radius = inner_radius
	well_border = inner_border
	art_size = art
	_sync_min_size()
	queue_redraw()


func set_art(seed: bool, art_type_id: String, art_tier: int) -> void:
	seed_shape = seed
	type_id = art_type_id
	tier = art_tier
	icon = null
	queue_redraw()


## Ikona bez wella (tab Seeds / Flowers).
func set_icon(seed: bool, texture: Texture2D, side: float) -> void:
	seed_shape = seed
	icon = texture
	icon_size = side
	type_id = ""
	well_inset = 0.0
	queue_redraw()


func _sync_min_size() -> void:
	custom_minimum_size = Vector2(frame_side, frame_side)


func _draw() -> void:
	var rect := Rect2((size - Vector2(frame_side, frame_side)) * 0.5, Vector2(frame_side, frame_side))
	# Prazan okvir (Trade bar bez odabira) — samo obris, bez tamnog wella.
	if icon == null and type_id.is_empty():
		draw_style_box(UiCamp.trade_art_empty_style(seed_shape), rect)
		return
	draw_style_box(UiCamp.art_frame_style(seed_shape, frame_side, frame_radius, frame_border), rect)
	if well_inset > 0.0:
		var well_side := frame_side - well_inset * 2.0
		draw_style_box(
			UiCamp.art_well_style(seed_shape, well_side, well_radius, well_border), rect.grow(-well_inset)
		)
	var center := rect.get_center()
	if icon != null:
		var half := Vector2(icon_size, icon_size) * 0.5
		draw_texture_rect(icon, Rect2(center - half, half * 2.0), false)
	elif not type_id.is_empty():
		ArenaChipDraw.draw_flower(self, center, type_id, tier, art_size)
