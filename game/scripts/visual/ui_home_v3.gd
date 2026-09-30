class_name UiHomeV3
extends RefCounted

## Home v3 (design_handoff_home_v3, runda 2): biranje sezone u dva taba i prelaz
## kartica → livada. Mjere su px stranice 1080 x 1633 (od y 143), prenose se 1:1
## iz HomeScreen.dc.html / home_v3_export.json. Polje (chrome) je i dalje u
## UiHomeField; ovdje je samo ono sto biranje i prelaz dodaju.

# ── Paleta ────────────────────────────────────────────────────────────────────
const CREAM := Color("#FFF8F0")
const INK := Color("#2D3436")
const INK_DEEP := Color("#1A1A14")
const PEACH := Color("#FFB88C")
const GOLD := Color("#FFD56B")
const MINT := Color("#A8E6CF")
const STAR_INK := Color("#9E6645")
const TOAST_BG := Color("#2D3436")
const TAB_TRACK := Color(0.176, 0.204, 0.212, 0.10)
const DOT_IDLE := Color(0.176, 0.204, 0.212, 0.28)
const DIVIDER := Color(0.176, 0.204, 0.212, 0.35)
const MISSING_DISC := Color(1.0, 0.973, 0.941, 0.55)
const MISSING_ART := Color(0.0, 0.0, 0.0, 0.28)
const DIM_ART := Color(1.0, 1.0, 1.0, 0.5)   ## samo „coming soon" (runda 3)
const CARD_SHADOW := Color(0.102, 0.102, 0.078, 0.26)
const BTN_SHADOW := Color(0.102, 0.102, 0.078, 0.28)
const ARROW_SHADOW := Color(0.102, 0.102, 0.078, 0.24)
const TAB_SHADOW := Color(0.102, 0.102, 0.078, 0.22)
const PIP_SHADOW := Color(0.102, 0.102, 0.078, 0.14)

# ── Layout stranice ───────────────────────────────────────────────────────────
const PAGE := Vector2(1080, 1633)
const TABS_RECT := Rect2(24, 24, 1032, 124)
const TABS_PAD := 8.0
const TAB_SIZE := Vector2(508, 108)
const TAB_ICON := 56.0
const TAB_LABEL := 46
const CARD_RECT := Rect2(24, 172, 1032, 1160)
const CARD_RADIUS := 48.0
const CARD_BORDER := 4.0
const CARD_SHADOW_Y := 12.0
## = UiHomeField.MEADOW_BANDS: nebo round(h * 0.32), daljina do round(h * 0.68).
const BANDS := [0.32, 0.68]
const NAME_SIZE := 80
const ROSTER_TOP := 230.0
## Runda 3: kartica nosi svih sest cvjetova, dva reda po tri. Redoslijed je
## redoslijed rostera: 0–2 = trojka iz runde 2 (1 = potpisni cvijet, „oko"),
## 3–5 = ostala tri. Zona 230–830, pa nista ne ulazi u strelice ni u status red.
const ROSTER_EYE := 220.0
const ROSTER_DISC := 180.0
const ROSTER_SIDE_DROP := 26.0
## Runda 4: tri kolone istim korakom u OBA reda (red 2 je imao tjesnji, 228).
## Siri korak od 240 bi gurnuo najsire ime preko strelica.
const ROSTER_COLUMNS_X := [276.0, 516.0, 756.0]
const ROSTER_PITCH := 240.0
const ROSTER_ROW2_TOP := 560.0
const ROSTER6 := [
	Rect2(186, 256, 180, 180), Rect2(406, 230, 220, 220), Rect2(666, 256, 180, 180),
	Rect2(186, 560, 180, 180), Rect2(426, 560, 180, 180), Rect2(666, 560, 180, 180),
]
## Vidljivi cvijet zauzima ~78 % diska (img 82 %, crtez 95 % svog kvadrata).
const ART_FILL := 0.78
## Runda 4: 34 (bilo 38), 12 ispod diska (bilo 18), prelom na 220 (bilo 300) —
## jedan red ako stane, inace dva uravnotezena; tri reda nikad.
const MISSING_NAME := 34
const MISSING_NAME_GAP := 12.0
const MISSING_NAME_MAX_W := 220.0
const MISSING_NAME_MAX_LINES := 2
## Pravilo za sadrzaj: svako NOVO ime cvijeta mora stati u dva reda od <= 234
## px na 34/900. Cuva ga season_home_smoke nad svih 8 sezona.
const MISSING_NAME_CONTENT_MAX_W := 234.0
const PREMIUM_RIM_INSET := 14.0
const PREMIUM_RIM_WIDTH := 8
const PREMIUM_RIM_RADIUS := 36
## Zakljucana besplatna sezona (locked i unlock): ravni veo preko svakog diska,
## crtez se ne crta. Jedan katanac na bloku — LOCK_BADGE gore desno je ukinut.
const LOCK_VEIL := Color("#E3D9CC")
const ROSTER_LOCK := Rect2(456, 436, 120, 120)
const ROSTER_LOCK_ICON := 60.0
## Tap na Unlock dize veo disk po disk — jedini trenutak kad se cvijece pokaze.
const REVEAL_SEC := 0.30
const REVEAL_STAGGER := 0.04
const STATUS_TOP := 830.0
const STATUS_H := 280.0
const OPEN_GATE := 150.0
const GATE_ARCH := Vector2(72, 62)
const GATE_ARCH_BOTTOM := 34.0
const NEED_CHIP_H := 120.0
const NEED_GAP := 24.0
const ACTION_H := 140.0
const ARROW_SIZE := 120.0
const PREV_RECT := Rect2(52, 852, 120, 120)
const NEXT_RECT := Rect2(908, 852, 120, 120)
const DOTS_TOP := 1352.0
const DOT_H := 24.0
const DOT_W := 24.0
const DOT_W_CURRENT := 64.0
const DOT_GAP := 22.0
const TOAST_RECT := Rect2(240, 1250, 600, 100)
const TOAST_LABEL := 44
## Hub swipe zivi samo na praznom pojasu lijevo/desno od Playa.
const HUB_SWIPE_ZONES := [Rect2(0, 1392, 280, 241), Rect2(800, 1392, 280, 241)]

# ── Putujuci objekti (P2–P4): biranje → polje ─────────────────────────────────
const NAME_CARD_TOP := 244.0
const NAME_FIELD_TOP := 36.0
const NAME_CARD_SIZE := 80.0
const NAME_FIELD_SIZE := 56.0
const NAME_CARD_LS := -0.015
const NAME_FIELD_LS := -0.01
const PIP_CARD_POS := Vector2(425, 1027)
const PIP_CARD_SIZE := 230.0
const PIP_FIELD_SIZE := 190.0
## Senka ispod Pipa: [left, bottom, w, h] u px Pipove kutije.
const PIP_SHADOW_CARD := [45.0, 8.0, 140.0, 30.0]
const PIP_SHADOW_FIELD := [35.0, 6.0, 120.0, 26.0]
const PLAY_CARD := {
	"rect": Rect2(280, 1413, 520, 180), "border": 4.0, "shadow_y": 10.0, "shadow_a": 0.30,
	"text": 76.0, "tri_h": 30.0, "tri_w": 48.0, "gap": 24.0, "margin": 8.0,
}
const PLAY_FIELD := {
	"rect": Rect2(324, 1461, 432, 140), "border": 3.0, "shadow_y": 8.0, "shadow_a": 0.28,
	"text": 64.0, "tri_h": 26.0, "tri_w": 42.0, "gap": 22.0, "margin": 6.0,
}
const PLAY_BACK_DISC := 104.0
const PLAY_BACK_LABEL := 66

# ── Pokret (runda 2) ──────────────────────────────────────────────────────────
const OPEN_SEC := 0.56
const CLOSE_SEC := 0.44
const SWAP_SEC := 0.22
const SNAP_SEC := 0.18
const SWAP_OFFSET := 90.0
const SWIPE_MIN := 60.0
const TAP_SLOP := 12.0
const RUBBER := 40.0
const RUBBER_FACTOR := 0.35
const SELECT_OUT := Vector2(0.02, 0.30)
const SELECT_LIFT := 24.0
const CONTENT_OUT := Vector2(0.02, 0.40)
const FLOWER_START := 0.20
const FLOWER_STAGGER := 12.0 / 560.0
const FLOWER_FADE := 100.0 / 560.0
const FLOWER_SETTLE := 200.0 / 560.0
const FLOWER_SCALE_FROM := 0.9
const NOTE_IN := Vector2(0.30, 0.60)
const FIELD_CHROME_IN := Vector2(0.60, 0.92)
const FIELD_CHROME_Y := 16.0
const FIELD_SIDE_SLIDE := 254.0
const TOAST_SEC := 1.4

const TNUM_TAG := 0x746E756D   # OpenType "tnum"

static var _num_fonts: Dictionary = {}


# ── Boje sezone (iste funkcije crtaju karticu i livadu, pa je sav nevidljiv) ──
static func ground(season_id: String) -> Color:
	return UiHomeField.meadow_ground(season_id)

static func sky(g: Color) -> Color:
	return UiHomeField.meadow_sky(g)

static func near(g: Color) -> Color:
	return UiHomeField.meadow_near(g)

## Pozadina stranice = najsvjetlija nijansa mood boje (nova svjetlija varijanta).
static func page_bg(g: Color) -> Color:
	return Color8(
		roundi(g.r8 + (255 - g.r8) * 0.55), roundi(g.g8 + (255 - g.g8) * 0.55), roundi(g.b8 + (255 - g.b8) * 0.55)
	)


# ── Tempo ─────────────────────────────────────────────────────────────────────
## ease in-out cubic — geometrija kartice, imena, Pipa i Playa (P10).
static func ease_t(u: float) -> float:
	return 4.0 * u * u * u if u < 0.5 else 1.0 - pow(-2.0 * u + 2.0, 3.0) / 2.0

static func ease_out(k: float) -> float:
	return 1.0 - pow(1.0 - k, 3.0)

static func win(u: float, a: float, b: float) -> float:
	return clampf((u - a) / (b - a), 0.0, 1.0)

static func card_rect_at(e: float, page: Vector2 = PAGE) -> Rect2:
	var to := Rect2(Vector2.ZERO, page)
	return Rect2(CARD_RECT.position.lerp(to.position, e), CARD_RECT.size.lerp(to.size, e))

## Pipova kutija (gornji lijevi ugao) za zadata stopala na polju.
static func pip_field_pos(feet: Vector2) -> Vector2:
	return feet - Vector2(PIP_FIELD_SIZE * 0.5, PIP_FIELD_SIZE)

static func play_params(e: float) -> Dictionary:
	var out := {}
	for key in PLAY_CARD:
		var a: Variant = PLAY_CARD[key]
		var b: Variant = PLAY_FIELD[key]
		if a is Rect2:
			out[key] = Rect2((a as Rect2).position.lerp((b as Rect2).position, e), (a as Rect2).size.lerp((b as Rect2).size, e))
		else:
			out[key] = lerpf(float(a), float(b), e)
	return out


# ── Tekst ─────────────────────────────────────────────────────────────────────
## Font za brojeve (font-variant-numeric: tabular-nums).
static func num_font(weight: int, px: int) -> Font:
	var key := "%d_%d" % [weight, px]
	if _num_fonts.has(key):
		return _num_fonts[key] as Font
	var base := UiStage.font(weight, px) as FontVariation
	var fv := base.duplicate() as FontVariation
	fv.opentype_features = {TNUM_TAG: 1}
	_num_fonts[key] = fv
	return fv

static func text_w(weight: int, px: float, text: String, tracking_em: float = 0.0, tabular: bool = false) -> float:
	var n := maxi(1, ceili(px - 0.001))
	var f := num_font(weight, n) if tabular else UiStage.font(weight, n, 1.0, tracking_em)
	return UiStage.text_w(f, n, text) * px / float(n)

## Tekst ciji line box (visina = px, kao CSS `font: W px/1`) pocinje na `pos`.
## Razlomljena velicina se crta iz najblize vece cijele i skalira — glatko u tweenu.
static func draw_text(
	canvas: CanvasItem, weight: int, px: float, text: String, pos: Vector2, color: Color,
	tracking_em: float = 0.0, tabular: bool = false
) -> void:
	var n := maxi(1, ceili(px - 0.001))
	var f := num_font(weight, n) if tabular else UiStage.font(weight, n, 1.0, tracking_em)
	var k := px / float(n)
	canvas.draw_set_transform(pos, 0.0, Vector2(k, k))
	canvas.draw_string(f, Vector2(0.0, f.get_ascent(n)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, n, color)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


# ── Oblici ────────────────────────────────────────────────────────────────────
## Ploca s tvrdom sjenkom `0 Y 0` (crta se ispod, kao CSS box-shadow).
static func draw_panel(
	canvas: CanvasItem, rect: Rect2, fill: Color, radius: float, border: float = 0.0,
	edge: Color = INK, shadow_y: float = 0.0, shadow: Color = BTN_SHADOW
) -> void:
	if shadow_y > 0.01:
		canvas.draw_style_box(UiStage.box(shadow, roundi(radius)), Rect2(rect.position + Vector2(0.0, shadow_y), rect.size))
	var sb := UiStage.box(fill, roundi(radius), roundi(border), edge)
	if fill.a <= 0.0:
		sb.draw_center = false
	canvas.draw_style_box(sb, rect)

## CSS `border: Wpx dashed` na krugu ili pilulici (crtice ~2W, razmak ~1.2W).
static func draw_dashed_round_rect(canvas: CanvasItem, rect: Rect2, radius: float, width: float, color: Color) -> void:
	var inset := rect.grow(-width * 0.5)
	var r := minf(maxf(radius - width * 0.5, 0.0), minf(inset.size.x, inset.size.y) * 0.5)
	var pts := UiStage.rounded_rect_points(inset, r, 24)
	pts.append(pts[0])
	var total := 0.0
	for i in pts.size() - 1:
		total += pts[i].distance_to(pts[i + 1])
	var period := width * 3.2
	var count := maxi(1, roundi(total / period))
	period = total / float(count)
	var dash := period * 0.62
	var seg := PackedVector2Array()
	var cursor := 0.0
	for i in pts.size() - 1:
		var a := pts[i]
		var b := pts[i + 1]
		var seg_len := a.distance_to(b)
		var t := 0.0
		while t < seg_len:
			var phase := fmod(cursor + t, period)
			var on := phase < dash
			var step := (dash - phase) if on else (period - phase)
			var t2 := minf(seg_len, t + maxf(step, 0.001))
			if on:
				if seg.is_empty():
					seg.append(a.lerp(b, t / seg_len))
				seg.append(a.lerp(b, t2 / seg_len))
			elif seg.size() >= 2:
				canvas.draw_polyline(seg, color, width, true)
				seg = PackedVector2Array()
			else:
				seg = PackedVector2Array()
			t = t2
		cursor += seg_len
	if seg.size() >= 2:
		canvas.draw_polyline(seg, color, width, true)

## Chevron iz CSS kvadrata `size x size` s rubom `w` na dvije strane, rotiran 45°.
## left: rub lijevo + dolje (‹); inace desno + gore (›). `center` = centar kvadrata.
static func draw_chevron(canvas: CanvasItem, center: Vector2, size: float, w: float, left: bool, color: Color) -> void:
	var o := size + w
	var arms: Array[Rect2] = []
	if left:
		arms = [Rect2(0, 0, w, o), Rect2(0, size, o, w)]
	else:
		arms = [Rect2(size, 0, w, o), Rect2(0, 0, o, w)]
	var rot := Transform2D(PI * 0.25, Vector2.ZERO)
	var c := Vector2(o, o) * 0.5
	for arm in arms:
		var poly := PackedVector2Array()
		for p in UiStage.rect_points(arm):
			poly.append(center + rot * (p - c))
		canvas.draw_colored_polygon(poly, color)

## Kvacica „Yours": kvadrat 22 x 40, rub 9 desno + dolje, rotate(45) translate(-4,-6).
static func draw_check(canvas: CanvasItem, box_pos: Vector2, color: Color) -> void:
	var w := 22.0 + 9.0
	var h := 40.0 + 9.0
	var c := Vector2(w, h) * 0.5
	var rot := Transform2D(PI * 0.25, Vector2.ZERO)
	for arm in [Rect2(22, 0, 9, h), Rect2(0, 40, w, 9)]:
		var poly := PackedVector2Array()
		for p in UiStage.rect_points(arm):
			poly.append(box_pos + c + rot * (p - c + Vector2(-4.0, -6.0)))
		canvas.draw_colored_polygon(poly, color)

## Cvijet (odrezan crtez; bez SVG-a proceduralni ★3) u disku precnika `d`.
static func draw_flower(canvas: CanvasItem, center: Vector2, type_id: String, d: float) -> void:
	if type_id.is_empty():
		return
	CampPlantDraw.draw_cropped_plant(canvas, center, type_id, 3, d * ART_FILL)


## Pip + senka (pill rgba .14) u kutiji `rect`; senka je [left, bottom, w, h].
static func draw_pip(canvas: CanvasItem, rect: Rect2, shadow: Array) -> void:
	var sh := Rect2(
		rect.position.x + float(shadow[0]), rect.end.y - float(shadow[1]) - float(shadow[3]),
		float(shadow[2]), float(shadow[3])
	)
	canvas.draw_style_box(UiStage.box(PIP_SHADOW, roundi(sh.size.y * 0.5)), sh)
	var tex := PipAssets.get_texture()
	if tex != null:
		canvas.draw_texture_rect(tex, rect, false)
	else:
		PipDraw.draw_pip(canvas, rect.get_center(), rect.size.x / 56.0)

static func pip_shadow_at(e: float) -> Array:
	var out: Array = []
	for i in 4:
		out.append(lerpf(float(PIP_SHADOW_CARD[i]), float(PIP_SHADOW_FIELD[i]), e))
	return out
