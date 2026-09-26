class_name UiArena
extends RefCounted

## Merge Arena — docs/04-experience/design-drafts/merge-arena-cd-brief.md
## Dizajn: design_handoff_merge_arena/README.md · smjer B (sadnica: cream rim + tamni well).
## Sve mjere su u px baze 1080x1920; u hubu Arena ima 1633 px izmedju headera (143) i footera (144).

# --- Boje (izvedene iz ui_palette.gd) ---
const SEED_WELL := Color("#22342A")  # livada #293D2E, 20 % tamnije
const SEED_WELL_EDGE := Color("#16211B")
const RIM_EDGE := Color("#CBC2B6")  # warm white, 20 % tamnije
const GOLD_EDGE := Color("#D6A82F")  # coin gold, 20 % tamnije
const PEACH_EDGE := Color("#E8A374")  # peach, 20 % tamnije
const COIN_GOLD := Color("#FFD56B")
const PULSE_GOLD := Color("#F2D940")
const FLASH := Color("#FFF5D1")
const CHIP_SHADOW := Color(0.078, 0.125, 0.102, 0.42)
const CHIP_SHADOW_DRAG := Color(0.078, 0.125, 0.102, 0.34)
const OVERLAY_DIM := Color(0.059, 0.078, 0.071, 0.82)
## Livada — iste vrijednosti kao prije redizajna (arena_feel_a_smoke ih poredi tacno).
const MEADOW_BASE := Color(0.16, 0.24, 0.18, 1.0)
const MEADOW_LUSH := Color(0.20, 0.36, 0.22, 1.0)

const BAG_BODY := Color("#9E7A52")
const BAG_BODY_EDGE := Color("#735738")
const BAG_NECK := Color("#B89466")
const BAG_NECK_EDGE := Color("#7A5C3C")
const NEST := Color("#9E7A52")
const NEST_EDGE := Color("#735738")
const NEST_INNER := Color("#6E5238")
const NEST_INNER_EDGE := Color("#543E2A")

const MUNCHER_AWAKE := Color("#8C61B8")
const MUNCHER_AWAKE_EDGE := Color("#6F4D93")
const MUNCHER_ASLEEP := Color("#7A579E")
const MUNCHER_ASLEEP_EDGE := Color("#61457E")
const MUNCHER_FROZEN := Color("#A6D1FA")
const MUNCHER_FROZEN_EDGE := Color("#6FA8DC")
const MUNCHER_MOUTH_IDLE := Color("#5C3F7E")
const FROST_SHELL := Color(0.91, 0.965, 1.0, 0.42)
const FROST_SHELL_EDGE := Color("#DCF0FF")
const MOUTH := Color("#FFCCD5")
const MOUTH_EDGE := Color("#E89AAA")

# --- Vertikalni budzet: Playfield uzima cijelu stranicu osim donjeg pojasa ---
## NavLockPill viri 36 px iznad footera; 44 px ga drzi dalje od vrece i Pipa.
const FIELD_BOTTOM_GAP := 44

# --- SeedChip ---
const CHIP_T2_RADIUS := 38
const CHIP_T2_WELL_RADIUS := 27
const RIM_BORDER := 3
const RIM_BAND_T1 := 5   # vidljiv cream: 8 px
const RIM_BAND_T2 := 8   # vidljiv cream: 11 px
const WELL_BORDER := 2
const T2_HAIRLINE_INSET := 5
const T2_HAIRLINE_RADIUS := 33
const T2_HAIRLINE_W := 2
## Hint je deblji od cream ruba. StyleBox crta rub unutar recta, pa je
## HINT_*_OUT koliko prsten viri van čipa (10 / 12), a širina 12 / 14 prelazi rub za 2 px.
const HINT_PULSE_W := 12.0
const HINT_PULSE_OUT := 10.0
const HINT_PARTNER_W := 14.0
const HINT_PARTNER_OUT := 12.0
const FLOWER_SIZE_T1 := 80.0
const FLOWER_SIZE_T2 := 88.0
const FLOWER_SIZE_T3 := 140.0
const CHIP_SHADOW_OFFSET := 6.0
const CHIP_SHADOW_OFFSET_DRAG := 18.0

# --- SeedBag / Muncher / Pip ---
const BAG_SIZE := Vector2(214, 178)
const BAG_SIZE_EMPTY := Vector2(214, 126)
const BAG_NECK_SIZE := Vector2(118, 34)
const BAG_HIT := Vector2(280, 250)
const BAG_COUNTER_R := 42.0
const BAG_BOTTOM_GAP := 40.0
## Keepout relativno na (centar vrece, dno vrece) — stit oko vrece, siri od same vrece.
const BAG_KEEPOUT := Rect2(-185, -349, 370, 520)
const MUNCHER_VISUAL_R := 52.0
const FROST_SHELL_R := 70.0
const NEST_SIZE := Vector2(210, 104)
## Gnijezdo je 2026-09-24 otislo ~200 px gore (HUD red je otpao); nize od ovoga
## header odsijece "zzz" iznad usnulog munchera.
const NEST_Y := 108.0
## Spawn keepout gnijezda (samo spawn — gnijezdo je overlay, ne prepreka).
const NEST_KEEPOUT_HALF_W := 110.0
const NEST_KEEPOUT_BOTTOM := 190.0
## Meta leta T3 kristala — gornji desni ugao polja, gdje je stajao stash brojac.
const CRYSTAL_EXIT_INSET := Vector2(120, 90)
const PIP_SIZE := 150.0
const PIP_INSET := Vector2(30, 26)  # od lijevog ruba i dna polja
const PIP_KEEPOUT_GROW := Vector2(120, 97)

# --- Rešetkasti spawn (hex) ---
## Polje je 1080 x 1553 (cijela hub stranica) — s keepoutima ostaje ~60 pozicija pri
## min. razmaku 142,8 px; slucajni spawn puca iznad ~22 sjemenke, pa rešetka nosi pour.
const GRID_STEP_DENSE := 150.0
const GRID_STEP_LOOSE := 164.0
const GRID_JITTER_DENSE := 3.5
const GRID_JITTER_LOOSE := 9.0
const GRID_DENSE_ABOVE := 32

static var _styles: Dictionary = {}


## Slobodne spawn pozicije: hex rešetka unutar `bounds` (centri), bez keepout zona i
## dalje od `min_dist` od zauzetih. `total` (polje poslije poura) bira korak i jitter.
## Vraca izmijesane pozicije — pozivalac uzme koliko treba.
static func spawn_slots(
	total: int,
	bounds: Rect2,
	keepouts: Array[Rect2],
	occupied: Array[Vector2],
	min_dist: float,
	rng: RandomNumberGenerator
) -> Array[Vector2]:
	var dense := total > GRID_DENSE_ABOVE
	var step := GRID_STEP_DENSE if dense else GRID_STEP_LOOSE
	var jitter := GRID_JITTER_DENSE if dense else GRID_JITTER_LOOSE
	var row_step := step * 0.866
	var cols := int(bounds.size.x / step) + 1
	var rows := int(bounds.size.y / row_step) + 1
	var ox := bounds.position.x + (bounds.size.x - (cols - 1) * step) * 0.5
	var oy := bounds.position.y + (bounds.size.y - (rows - 1) * row_step) * 0.5
	var out: Array[Vector2] = []
	for r in rows:
		var odd := r % 2 == 1
		var c_off := step * 0.5 if odd else 0.0
		var c_n := cols - 1 if odd else cols
		for c in c_n:
			var p := Vector2(ox + c_off + c * step, oy + r * row_step)
			if _in_any(p, keepouts) or _too_close(p, occupied, min_dist):
				continue
			out.append(p)
	for i in range(out.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := out[i]
		out[i] = out[j]
		out[j] = tmp
	for i in out.size():
		out[i] += Vector2(rng.randf_range(-jitter, jitter), rng.randf_range(-jitter, jitter))
	return out


## Rim (tijelo sjemenke): T1 krug, T2 zaobljen kvadrat; mythic (★3) = gold.
static func chip_rim_style(tier: int, mythic: bool) -> StyleBoxFlat:
	var key := "rim_%d_%s" % [tier, mythic]
	if _styles.has(key):
		return _styles[key]
	var s := _round(_chip_radius(tier))
	s.bg_color = COIN_GOLD if mythic else UiPalette.WARM_WHITE
	s.border_color = GOLD_EDGE if mythic else RIM_EDGE
	s.set_border_width_all(RIM_BORDER)
	_styles[key] = s
	return s


## Tvrda sjena ispod sjemenke (bez blura) — crta se kao pomaknut oblik rima.
static func chip_shadow_style(tier: int, dragging: bool) -> StyleBoxFlat:
	var key := "shadow_%d_%s" % [tier, dragging]
	if _styles.has(key):
		return _styles[key]
	var s := _round(_chip_radius(tier))
	s.bg_color = CHIP_SHADOW_DRAG if dragging else CHIP_SHADOW
	_styles[key] = s
	return s


## Well — tamna udubina koja nosi kontrast svakoj boji cvijeta.
static func chip_well_style(tier: int) -> StyleBoxFlat:
	var key := "well_%d" % tier
	if _styles.has(key):
		return _styles[key]
	var s := _round(CHIP_T2_WELL_RADIUS if tier == 2 else 999)
	s.bg_color = SEED_WELL
	s.border_color = SEED_WELL_EDGE
	s.set_border_width_all(WELL_BORDER)
	_styles[key] = s
	return s


## T2 unutrasnji prsten — razlika T1/T2 i bez boje.
static func chip_hairline_style(mythic: bool) -> StyleBoxFlat:
	var key := "hair_%s" % mythic
	if _styles.has(key):
		return _styles[key]
	var s := _round(T2_HAIRLINE_RADIUS)
	s.draw_center = false
	s.set_border_width_all(T2_HAIRLINE_W)
	s.border_color = GOLD_EDGE if mythic else RIM_EDGE
	_styles[key] = s
	return s


## Prsten oko sjemenke (pulse / partner / merge). Nije kesiran — boja/alpha se mijenja.
static func ring_style(corner_radius: float, width: float, color: Color) -> StyleBoxFlat:
	var s := _round(corner_radius)
	s.draw_center = false
	s.set_border_width_all(int(width))
	s.border_color = color
	return s


static func chip_well_inset(tier: int) -> int:
	return RIM_BORDER + (RIM_BAND_T2 if tier == 2 else RIM_BAND_T1)


static func chip_corner_radius(tier: int) -> float:
	return float(_chip_radius(tier))


static func cue_style() -> StyleBoxFlat:
	var s := _round(24)
	s.bg_color = UiPalette.WARM_WHITE
	s.border_color = RIM_EDGE
	s.set_border_width_all(4)
	_pad(s, 32, 20)
	return s


static func overlay_panel_style() -> StyleBoxFlat:
	var s := _round(26)
	s.bg_color = UiPalette.WARM_WHITE
	s.border_color = Color(UiPalette.OUTLINE, 0.14)
	s.set_border_width_all(3)
	s.content_margin_left = 48.0
	s.content_margin_right = 48.0
	s.content_margin_top = 48.0
	s.content_margin_bottom = 44.0
	s.shadow_color = Color(0.059, 0.078, 0.071, 0.45)
	s.shadow_size = 1
	s.shadow_offset = Vector2(0, 14)
	return s


static func need_row_style(rarity: int) -> StyleBoxFlat:
	var s := _round(20)
	s.bg_color = UiPalette.rarity_bg_color(rarity)
	s.border_color = Color(UiPalette.OUTLINE, 0.14)
	s.set_border_width_all(2)
	_pad(s, 26, 0)
	return s


static func _chip_radius(tier: int) -> int:
	return CHIP_T2_RADIUS if tier == 2 else 999


static func _round(radius: float) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(int(radius))
	s.corner_detail = 16
	s.anti_aliasing = true
	return s


static func _pad(s: StyleBoxFlat, x: float, y: float) -> void:
	s.content_margin_left = x
	s.content_margin_right = x
	s.content_margin_top = y
	s.content_margin_bottom = y


static func _in_any(p: Vector2, zones: Array[Rect2]) -> bool:
	for z in zones:
		if z.has_point(p):
			return true
	return false


static func _too_close(p: Vector2, occupied: Array[Vector2], min_dist: float) -> bool:
	for o in occupied:
		if p.distance_to(o) < min_dist:
			return true
	return false
