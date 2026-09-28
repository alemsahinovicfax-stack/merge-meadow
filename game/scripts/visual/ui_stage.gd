class_name UiStage
extends RefCounted

## Zajednicki Nunito fontovi (CSS `font: W px/LH`), StyleBoxFlat i oblici za
## Home (v3 biranje sezone: UiHomeV3; polje: UiHomeField) i Gift. Mjere Home
## stranice su u UiHomeV3 — ovdje su samo alati i nekoliko dijeljenih boja.

const NUNITO := preload("res://assets/fonts/nunito/Nunito-Variable.ttf")
## OpenType "wght"; FontVariation ne prepoznaje string kljuc "wght".
const AXIS_WEIGHT := 0x77676874

# --- Boje (jos ih koriste Gift, StageHint i Home v3) ---
const PAGE_BG := Color("#243329")
const CREAM := Color("#FFF8F0")
const INK := Color("#2D3436")
const INK_SOFT := Color("#555C5E")
const LAVENDER := Color("#D4A5FF")
const PINK := Color("#FFCCD5")
const HINT_RING := Color(1.0, 0.961, 0.820, 0.7)

const GIFT := 180.0

static var _fonts: Dictionary = {}


## Nunito u tezini `weight`; visina reda = px * line_height kao CSS `font: W px/LH`,
## pa je rect Labela i baseline isti kao line box u HTML-u.
static func font(weight: int, px: int, line_height: float = 1.0, tracking_em: float = 0.0) -> Font:
	var key := "%d_%d_%.3f_%.3f" % [weight, px, line_height, tracking_em]
	if _fonts.has(key):
		return _fonts[key] as Font
	var fv := FontVariation.new()
	fv.base_font = NUNITO
	fv.variation_opentype = {AXIS_WEIGHT: weight}
	var natural := NUNITO.get_ascent(px) + NUNITO.get_descent(px)
	var extra := roundi(natural - roundf(float(px) * line_height))
	var top := floori(extra * 0.5)
	fv.spacing_top = -top
	fv.spacing_bottom = -(extra - top)
	fv.spacing_glyph = roundi(tracking_em * float(px))
	_fonts[key] = fv
	return fv


static func style(label: Label, weight: int, px: int, color: Color, line_height: float = 1.0, tracking_em: float = 0.0) -> void:
	label.add_theme_font_override("font", font(weight, px, line_height, tracking_em))
	label.add_theme_font_size_override("font_size", px)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("line_spacing", 0)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE


static func text_w(f: Font, px: int, text: String) -> float:
	return f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x


## Baseline linije ciji line box pocinje na `top` (font iz font()).
static func baseline(f: Font, px: int, top: float) -> float:
	return top + f.get_ascent(px)


## Tekst centriran u `box` (line box = visina fonta), kao grid place-items:center.
static func draw_text_centered(canvas: CanvasItem, f: Font, px: int, text: String, box: Rect2, color: Color) -> void:
	var w := text_w(f, px, text)
	var h := f.get_height(px)
	var top := box.position.y + (box.size.y - h) * 0.5
	canvas.draw_string(f, Vector2(box.position.x + (box.size.x - w) * 0.5, baseline(f, px, top)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, px, color)


## CSS `text-wrap: balance` za dva reda: podjela s najkracim duzim redom.
static func balance_lines(text: String, f: Font, px: int, max_w: float) -> PackedStringArray:
	if text_w(f, px, text) <= max_w:
		return PackedStringArray([text])
	var words := text.split(" ")
	var best := PackedStringArray()
	var best_w := INF
	for i in range(1, words.size()):
		var a := " ".join(words.slice(0, i))
		var b := " ".join(words.slice(i))
		var longest := maxf(text_w(f, px, a), text_w(f, px, b))
		if longest < best_w:
			best_w = longest
			best = PackedStringArray([a, b])
	return best if not best.is_empty() else PackedStringArray([text])


# --- StyleBoxFlat ---

static func box(fill: Color, radius: int, border: int = 0, edge: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.set_corner_radius_all(radius)
	s.corner_detail = 16
	s.anti_aliasing = true
	if border > 0:
		s.set_border_width_all(border)
		s.border_color = edge
	return s


static func pad(s: StyleBoxFlat, left: float, top: float, right: float, bottom: float) -> StyleBoxFlat:
	s.content_margin_left = left
	s.content_margin_top = top
	s.content_margin_right = right
	s.content_margin_bottom = bottom
	return s


# --- Oblici ---

static func rounded_rect_points(rect: Rect2, radius: float, steps: int = 12) -> PackedVector2Array:
	var r := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	var centers: Array[Vector2] = [
		Vector2(rect.end.x - r, rect.position.y + r),
		Vector2(rect.end.x - r, rect.end.y - r),
		Vector2(rect.position.x + r, rect.end.y - r),
		Vector2(rect.position.x + r, rect.position.y + r),
	]
	var pts := PackedVector2Array()
	for k in 4:
		var a0 := -PI * 0.5 + float(k) * PI * 0.5
		for i in steps + 1:
			var a := a0 + PI * 0.5 * float(i) / float(steps)
			pts.append(centers[k] + Vector2(cos(a), sin(a)) * r)
	return pts


static func rect_points(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)
	])


## ★ s pet krakova; `r` = vanjski radius.
static func draw_star(canvas: CanvasItem, center: Vector2, r: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI * 0.5 + float(i) * PI / 5.0
		var rr := r if i % 2 == 0 else r * 0.5
		pts.append(center + Vector2(cos(a), sin(a)) * rr)
	canvas.draw_colored_polygon(pts, color)
