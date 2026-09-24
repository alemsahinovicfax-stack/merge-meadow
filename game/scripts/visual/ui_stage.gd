class_name UiStage
extends RefCounted

## Home Season Stage (design_handoff_home_v2, smjer 1a): mjere, boje, Nunito
## fontovi i oblici. Mjere su px baze 1080 x 1920; stage = sadrzaj 1080 x 1597
## izmedju headera (143) i footera (180). Poluprozirni rubovi iz HTML-a se ovdje
## racunaju kao neprozirni (CSS crta pozadinu i ispod ruba, StyleBoxFlat ne).

const NUNITO := preload("res://assets/fonts/nunito/Nunito-Variable.ttf")
## OpenType "wght"; FontVariation ne prepoznaje string kljuc "wght".
const AXIS_WEIGHT := 0x77676874

# --- Boje ---
const PAGE_BG := Color("#243329")
const CHROME := Color("#1A241E")
const RIM := Color("#FFF6D6")
const CREAM := Color("#FFF8F0")
const INK := Color("#2D3436")
const INK_SOFT := Color("#555C5E")
const INK_DEEP := Color("#1A1A14")
const INFO_SUB := Color("#3D3D33")
const WELL := Color("#22342A")
const COIN := Color("#FFD56B")
const GOLD := Color("#E8C44A")
const GOLD_EDGE := Color("#9C7A14")
const PEACH := Color("#FFB88C")
const PEACH_EDGE := Color("#E8A374")
const PEACH_DROP := Color("#9E6645")
const LAVENDER := Color("#D4A5FF")
const PRICE_BG := Color("#FFE8B8")
const PRICE_EDGE := Color("#D6A82F")
const PRICE_SUB := Color("#5A4A1E")
const PINK := Color("#FFCCD5")
const BLOCKED := Color("#FF8A8A")
const CARD_DROP := Color("#121A15")
const TILE_EDGE := Color("#E3D9CC")
const TILE_WELL_EDGE := Color("#CBC2B6")
const SOON_DOT := Color("#4A5550")
const RING := Color(1.0, 0.961, 0.820, 0.55)
const HINT_RING := Color(1.0, 0.961, 0.820, 0.7)
const STRIPE := Color(1.0, 1.0, 1.0, 0.08)
const BAR_TRACK := Color(1.0, 0.973, 0.941, 0.16)
const TOKEN_TRACK := Color(0.102, 0.141, 0.118, 0.45)
const MUTED_FILL := Color(1.0, 0.973, 0.941, 0.55)
const MUTED_EDGE := Color(0.102, 0.102, 0.078, 0.30)
const PILL := {1: Color("#A8E6CF"), 2: Color("#B8E0F5"), 3: Color("#FFD56B")}

# --- Stage (koordinate SeasonStage = stranica Home) ---
const STAGE := Vector2(1080, 1597)
const CARD := Rect2(24, 24, 1032, 1100)
const DOCK := Rect2(0, 1148, 1080, 222)
const PLAY_ROW := Rect2(24, 1394, 1032, 180)
const PLAY_W := 836.0
const GIFT := 180.0
const ROW_GAP := 16
const BLOCK_GAP := 24
const BOTTOM_GAP := 23
const TOAST_TOP := 250.0
const TOAST_H := 92.0
const TOAST_PAD := 40.0

# --- Kartica ---
const CARD_RADIUS := 36
const CARD_PAD := 18.0
const CARD_GAP := 22.0
const RIM_ACTIVE := 8
const RIM_PREVIEW := 4
const CARD_DROP_Y := 10.0
const TITLE_H := 170.0
const TILE_H := 236.0
const TILE_H_SIX := 214.0
const TILE_COL_GAP := 18.0
const TILE_ROW_GAP := 14.0
const WELL_D := 118.0
const WELL_D_SIX := 100.0
const ACTION_H := 130.0
const GATE_ROW_H := 96.0
const GATE_GAP := 12.0
const UNLOCK_H := 140.0
const PRICE_W := 300.0
const ART_RADIUS := 26
const BADGE_H := 72.0
const BADGE_PAD := 26.0
const ARROW_D := 96.0
const ARROW_HIT := 132.0
const LOCK_D := 150.0
const RING_D := 520.0
const RING_W := 28.0

# --- Dock ---
const TOKEN := 120.0
const TOKEN_GAP := 10.0
const GROUP_GAP := 20.0
const DOCK_PAD := 20.0
const DOCK_EDGE := 3
const DOCK_LABEL_TOP := 17.0
const DOCK_LABEL_H := 48.0
const TOKEN_TOP := 75.0

# --- Pokret ---
const T_PAGE := 0.28
const T_LIFT := 0.12
const T_SHAKE := 0.18
const T_UNLOCK := 0.42
const T_DRAIN := 0.2
const T_TOAST := 2.4
const T_TOAST_FADE := 0.15
const RUBBER := 40.0
const TAP_SLOP := 14.0
const SWIPE_MIN := 80.0
const SWIPE_VELOCITY := 320.0

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


## Tvrda sjenka `box-shadow: 0 Y 0 color` (shadow_size 1 = najmanji feather).
static func drop(s: StyleBoxFlat, color: Color, offset_y: float) -> StyleBoxFlat:
	s.shadow_color = color
	s.shadow_size = 1
	s.shadow_offset = Vector2(0.0, offset_y)
	return s


static func pad(s: StyleBoxFlat, left: float, top: float, right: float, bottom: float) -> StyleBoxFlat:
	s.content_margin_left = left
	s.content_margin_top = top
	s.content_margin_right = right
	s.content_margin_bottom = bottom
	return s


## Rub `rgba(r,g,b,a)` preko pozadine `under`, kao sto ga CSS kompozira.
static func over(under: Color, edge: Color) -> Color:
	var c := under.lerp(Color(edge.r, edge.g, edge.b), edge.a)
	c.a = 1.0
	return c


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


## Poligon presjecen s konveksnim oblikom `clip` (overflow:hidden s radiusom).
static func draw_clipped(canvas: CanvasItem, poly: PackedVector2Array, clip: PackedVector2Array, color: Color) -> void:
	for piece in Geometry2D.intersect_polygons(poly, clip):
		if piece.size() >= 3:
			canvas.draw_colored_polygon(piece, color)


## `repeating-linear-gradient(135deg, c 0 18px, transparent 18px 36px)`.
static func draw_stripes(canvas: CanvasItem, rect: Rect2, clip: PackedVector2Array, color: Color) -> void:
	var period := 36.0 / 0.70710678
	var band := 18.0 / 0.70710678
	var big := rect.size.x + rect.size.y
	var s := 0.0
	var reach := rect.size.x + rect.size.y
	while s < reach:
		var a := s
		var b := s + band
		var o := rect.position
		var quad := PackedVector2Array([
			o + Vector2(a + big, -big), o + Vector2(b + big, -big),
			o + Vector2(-big, b + big), o + Vector2(-big, a + big),
		])
		draw_clipped(canvas, quad, clip, color)
		s += period


## ▶ ispunjen u `rect` (vrh desno, na sredini visine).
static func draw_play(canvas: CanvasItem, rect: Rect2, color: Color) -> void:
	canvas.draw_colored_polygon(PackedVector2Array([
		rect.position, Vector2(rect.end.x, rect.position.y + rect.size.y * 0.5), Vector2(rect.position.x, rect.end.y)
	]), color)


## ★ s pet krakova; `r` = vanjski radius.
static func draw_star(canvas: CanvasItem, center: Vector2, r: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI * 0.5 + float(i) * PI / 5.0
		var rr := r if i % 2 == 0 else r * 0.5
		pts.append(center + Vector2(cos(a), sin(a)) * rr)
	canvas.draw_colored_polygon(pts, color)


## ✓ u `rect`.
static func draw_check(canvas: CanvasItem, rect: Rect2, width: float, color: Color) -> void:
	var pts := PackedVector2Array([
		rect.position + Vector2(0.0, rect.size.y * 0.55),
		rect.position + Vector2(rect.size.x * 0.36, rect.size.y),
		rect.position + Vector2(rect.size.x, 0.0),
	])
	canvas.draw_polyline(pts, color, width, true)


## ↗ u `rect` (dijagonala + vrh od dva kraka).
static func draw_ne_arrow(canvas: CanvasItem, rect: Rect2, width: float, color: Color) -> void:
	var tip := Vector2(rect.end.x, rect.position.y)
	var head := rect.size.x * 0.56
	canvas.draw_line(Vector2(rect.position.x, rect.end.y), tip, color, width, true)
	canvas.draw_polyline(PackedVector2Array([
		tip + Vector2(-head, 0.0), tip, tip + Vector2(0.0, head)
	]), color, width, true)


## Strelica pagera: content-box 30 x 30 + rub 9 px lijevo+dolje (ili desno+gore),
## dakle krakovi 39 px, rotirana 45 stepeni i pomaknuta 6 px (SeasonCard.dc.html).
static func draw_chevron(canvas: CanvasItem, center: Vector2, pointing_left: bool, color: Color) -> void:
	var shift := Vector2(6.0 if pointing_left else -6.0, 0.0)
	var arms: Array[Rect2] = []
	if pointing_left:
		arms = [Rect2(0, 0, 9, 39), Rect2(0, 30, 39, 9)]
	else:
		arms = [Rect2(30, 0, 9, 39), Rect2(0, 0, 39, 9)]
	var rot := Transform2D(PI * 0.25, Vector2.ZERO)
	for arm in arms:
		var pts := PackedVector2Array()
		for p in rect_points(arm):
			pts.append(center + shift + rot * (p - Vector2(19.5, 19.5)))
		canvas.draw_colored_polygon(pts, color)
