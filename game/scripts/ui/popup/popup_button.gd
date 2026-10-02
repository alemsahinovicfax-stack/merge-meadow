class_name PopupButton
extends HubPressable

## Pop-up sistem · PopupButton / AdButton (design_handoff_popups § Sistem).
## kind: primary (peach) · secondary (bijelo) · ad (lavanda, video oznaka) · disabled · loading · done.
## h 132 (reklama uvijek 120), radius 36, rub 4, tvrda sjena 0 8 0; pritisak: y +6, sjena 2.
## Sadržaj centriran, gap 16: [video 64×48] [ikona 56 | crtež cvijeta] [✓] tekst 48 (reklama 44) [•••].
## Tri tačke „čeka" su jedini loop (0,9 s, pomak 0,15 s).

const GAP := 16.0
const ICON := 56.0
const BADGE := Vector2(64, 48)
const CHECK := 40.0
const GLYPH := 32.0
const DOT := 14.0
const DOT_GAP := 10.0

var kind: String = "secondary"
var label: String = ""
var ad: bool = false
var icon_tex: Texture2D = null
## Crtež sjemena/cvijeta umjesto ikone (dugme nadogradnje = cijena).
var art_type: String = ""
var art_tier: int = 3
var art_size: float = 81.0
var check: bool = false
## Nacrtan znak umjesto ikone: "play" (pun ink trougao).
var glyph: String = ""
var dots: bool = false

var _dot_t: float = 0.0


func _ready() -> void:
	super()
	set_process(false)
	_sync()


## Postavi sve odjednom. `kind` disabled/loading/done gasi dodir.
func configure(p_kind: String, p_label: String, p_ad: bool = false, p_icon: Texture2D = null) -> PopupButton:
	kind = p_kind
	label = p_label
	ad = p_ad
	icon_tex = p_icon
	dots = kind == "loading"
	check = kind == "done"
	_sync()
	return self


func set_art(type_id: String, tier: int = 3, side: float = 81.0) -> PopupButton:
	art_type = type_id
	art_tier = tier
	art_size = side
	queue_redraw()
	return self


func height() -> float:
	return float(UiPopups.button_height(ad))


func _sync() -> void:
	disabled = kind in ["disabled", "loading", "done"]
	custom_minimum_size.y = height()
	set_process(dots and is_visible_in_tree())
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process(dots and is_visible_in_tree())


func _process(delta: float) -> void:
	_dot_t = fmod(_dot_t + delta, UiPopups.ANIM.dots)
	queue_redraw()


func _apply_state() -> void:
	queue_redraw()


func content_width() -> float:
	var px := UiPopups.AD_BUTTON_TEXT if ad else UiPopups.BUTTON_TEXT
	var parts: Array[float] = []
	if ad:
		parts.append(BADGE.x)
	if not glyph.is_empty():
		parts.append(GLYPH)
	elif icon_tex != null:
		parts.append(ICON)
	elif not art_type.is_empty():
		parts.append(art_size)
	if check:
		parts.append(CHECK)
	if not label.is_empty():
		parts.append(UiPopups.text_w(900, px, label))
	if dots:
		parts.append(DOT * 3.0 + DOT_GAP * 2.0)
	var w := 0.0
	for p in parts:
		w += p
	return w + GAP * maxf(0.0, parts.size() - 1)


func _draw() -> void:
	var h := height()
	var press := is_pressing() and not disabled
	var dy := 6.0 if press else 0.0
	var sb := UiPopups.button(kind, ad)
	if press:
		sb = UiPopups.button_pressed(sb)
	var rect := Rect2(0.0, dy, size.x, h)
	draw_style_box(sb, rect)
	var ink := UiPopups.button_ink(kind)
	var px := UiPopups.AD_BUTTON_TEXT if ad else UiPopups.BUTTON_TEXT
	var x := (size.x - content_width()) * 0.5
	var cy := rect.get_center().y
	if ad:
		var badge := UiPopups.icon("icon_video")
		if badge:
			var col := Color(1, 1, 1, 0.45) if kind == "disabled" else Color.WHITE
			draw_texture_rect(badge, Rect2(Vector2(x, cy - BADGE.y * 0.5), BADGE), false, col)
		x += BADGE.x + GAP
	if glyph == "play":
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + 2.0, cy - 20.0), Vector2(x + GLYPH, cy), Vector2(x + 2.0, cy + 20.0)
		]), ink)
		x += GLYPH + GAP
	elif icon_tex != null:
		var col := Color(1, 1, 1, 0.5) if kind == "disabled" else Color.WHITE
		draw_texture_rect(icon_tex, Rect2(Vector2(x, cy - ICON * 0.5), Vector2(ICON, ICON)), false, col)
		x += ICON + GAP
	elif not art_type.is_empty():
		UiPopups.draw_flower(self, Vector2(x + art_size * 0.5, cy), art_type, art_tier, art_size)
		x += art_size + GAP
	if check:
		UiPopups.draw_check(self, Vector2(x + CHECK * 0.5, cy), CHECK, ink, 6.0)
		x += CHECK + GAP
	if not label.is_empty():
		UiPopups.draw_text(self, 900, px, label, Vector2(x, cy - px * 0.5), ink)
		x += UiPopups.text_w(900, px, label) + GAP
	if dots:
		for i in 3:
			var phase := fmod(_dot_t - i * 0.15 + UiPopups.ANIM.dots, UiPopups.ANIM.dots) / UiPopups.ANIM.dots
			var a := 0.25 + 0.75 * clampf(1.0 - absf(phase - 0.4) / 0.4, 0.0, 1.0)
			draw_circle(Vector2(x + DOT * 0.5 + i * (DOT + DOT_GAP), cy), DOT * 0.5, Color(ink, a))
