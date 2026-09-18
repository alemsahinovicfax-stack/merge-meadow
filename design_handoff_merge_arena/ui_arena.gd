class_name UiArena
extends RefCounted

## Merge Arena — docs/04-experience/design-drafts/merge-arena-cd-brief.md
## Dizajn: design_handoff_merge_arena/README.md · smjer B (sadnica: rim + well)
## Sve mjere su u px baze 1080x1920. Arena zauzima 1597 px izmedju
## headera (143) i footera (180) iz UiChrome.

# --- Nove nijanse (sve izvedene iz ui_palette.gd) ---
const SEED_WELL := Color("#22342A")        # livada #293D2E, 20 % tamnije
const SEED_WELL_EDGE := Color("#16211B")
const RIM_EDGE := Color("#CBC2B6")         # warm white #FFF8F0, 20 % tamnije
const GOLD_EDGE := Color("#D6A82F")        # coin gold #FFD56B, 20 % tamnije
const PULSE_GOLD := Color("#F2D940")
const FLOWER_CORE := Color("#FFE8B8")      # iz seed_clover.svg

const BAG_BODY := Color("#9E7A52")
const BAG_BODY_EDGE := Color("#735738")
const BAG_NECK := Color("#B89466")
const NEST := Color("#9E7A52")
const NEST_EDGE := Color("#735738")
const NEST_INNER := Color("#6E5238")

const MUNCHER_AWAKE := Color("#8C61B8")
const MUNCHER_AWAKE_EDGE := Color("#6F4D93")
const MUNCHER_ASLEEP := Color("#7A579E")
const MUNCHER_ASLEEP_EDGE := Color("#61457E")
const MUNCHER_FROZEN := Color("#A6D1FA")
const MUNCHER_FROZEN_EDGE := Color("#6FA8DC")
const FROST_SHELL := Color(0.91, 0.96, 1.0, 0.42)
const MOUTH := Color("#FFCCD5")
const MOUTH_EDGE := Color("#E89AAA")

# --- Vertikalni budzet: 120 + 128 + 1133 + 140 + 76 = 1597 ---
const HUD_H := 120
const HINT_H := 128            # 2 reda na 38 px — rezervisano, layout ne skace
const PLAYFIELD_Y := 248
const PLAYFIELD_H := 1133
const DONE_Y := 1397
const DONE_H := 140
const PILL_CLEARANCE := 24     # cisto ispod Done, iznad NavLockPill

# --- SeedChip ---
const CHIP_SIZE := 134                 # nepromijenjen
const CHIP_MIN_CENTER_DIST := 142.8    # nepromijenjen
const CHIP_T2_RADIUS := 38
const RIM_BORDER := 3
const RIM_BAND_T1 := 11                # vidljiv cream: RIM_BORDER + RIM_BAND = 14
const RIM_BAND_T2 := 15                # vidljiv cream: 18
const WELL_BORDER := 2
const FLOWER_SIZE_T1 := 78
const FLOWER_SIZE_T2 := 84
const CHIP_SHADOW_OFFSET := 6

# --- SeedBag / Muncher / Pip ---
const BAG_SIZE := Vector2(214, 178)
const BAG_SIZE_EMPTY := Vector2(214, 126)
const BAG_NECK_SIZE := Vector2(118, 34)
const BAG_HIT := Vector2(280, 250)
const BAG_COUNTER_R := 42
const MUNCHER_SIZE := 104              # bio 56 — ARENA_PEST_EAT_RADIUS ostaje 36
const MUNCHER_VISUAL_R := 52
const FROST_SHELL_SIZE := 140
const NEST_SIZE := Vector2(210, 104)
const PIP_SIZE := 150

# --- Rešetkasti spawn ---
## Na 1080 x 1133 s keepout zonama ostaje ~40 legalnih pozicija pri
## CHIP_MIN_CENTER_DIST. Slucajni spawn puca iznad ~22 sjemenke, pa
## ARENA_MAX_CHIPS (30) zahtijeva rešetku.
const GRID_STEP_DENSE := 150.0      # > 24 sjemenke
const GRID_STEP_LOOSE := 164.0      # <= 24
const GRID_JITTER_DENSE := 3.5
const GRID_JITTER_LOOSE := 9.0


## Legalne pozicije za spawn, heksagonalna rešetka s keepout zonama.
## `count` bira korak i jitter; vrati Array[Vector2] duzine >= count.
static func spawn_slots(count: int, rng: RandomNumberGenerator) -> Array:
	var dense := count > 24
	var step := GRID_STEP_DENSE if dense else GRID_STEP_LOOSE
	var jitter := GRID_JITTER_DENSE if dense else GRID_JITTER_LOOSE
	var row_step := step * 0.866
	var x0 := 83.0
	var x1 := 997.0
	var y0 := 83.0
	var y1 := 1050.0
	var cols := int((x1 - x0) / step) + 1
	var rows := int((y1 - y0) / row_step) + 1
	var ox := x0 + (x1 - x0 - (cols - 1) * step) * 0.5
	var oy := y0 + (y1 - y0 - (rows - 1) * row_step) * 0.5
	var out: Array = []
	for r in rows:
		var odd := r % 2 == 1
		var c_off := step * 0.5 if odd else 0.0
		var c_n := cols - 1 if odd else cols
		for c in c_n:
			var x := ox + c_off + c * step
			var y := oy + r * row_step
			if x > 355.0 and x < 725.0 and y > 744.0:
				continue          # keepout: SeedBag
			if x < 300.0 and y > 860.0:
				continue          # keepout: ArenaPip
			if x > 430.0 and x < 650.0 and y < 140.0:
				continue          # keepout: MuncherNest
			if x > 700.0 and y < 130.0:
				continue          # keepout: ComboMeter
			out.append(Vector2(x, y))
	out.shuffle()
	out = out.slice(0, count)
	for i in out.size():
		out[i] += Vector2(rng.randf_range(-jitter, jitter), rng.randf_range(-jitter, jitter))
	return out


## Rim (tijelo sjemenke). `tier` 1 ili 2; `mythic` = zvjezdica 3.
static func chip_rim_style(tier: int, mythic: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color("#FFD56B") if mythic else UiPalette.WARM_WHITE
	s.border_color = GOLD_EDGE if mythic else RIM_EDGE
	s.set_border_width_all(RIM_BORDER)
	if tier == 2:
		s.set_corner_radius_all(CHIP_T2_RADIUS)
	else:
		s.set_corner_radius_all(int(CHIP_SIZE * 0.5))
	s.shadow_color = Color(0.078, 0.125, 0.102, 0.42)
	s.shadow_size = 0
	s.shadow_offset = Vector2(0, CHIP_SHADOW_OFFSET)
	return s


## Well — tamna udubina koja nosi kontrast cvijeta.
static func chip_well_style(tier: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = SEED_WELL
	s.border_color = SEED_WELL_EDGE
	s.set_border_width_all(WELL_BORDER)
	s.set_corner_radius_all(26 if tier == 2 else int(CHIP_SIZE * 0.5))
	return s


## Inset wella od ivice rima (ukljucuje RIM_BORDER).
static func chip_well_inset(tier: int) -> int:
	return RIM_BORDER + (RIM_BAND_T2 if tier == 2 else RIM_BAND_T1)


## Combo pill. Od 5 dobija zlatnu varijantu + bonus red.
static func combo_style(combo: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	var big := combo >= 5
	s.bg_color = Color("#FFD56B") if big else Color("#FFEAA7")
	s.border_color = GOLD_EDGE if big else Color("#E0C97F")
	s.set_border_width_all(3)
	s.set_corner_radius_all(20)
	return s


## Pill u HUD-u (DailyTask, StashCounter). `done` = zavrsen dnevni zadatak.
static func hud_pill_style(done: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color("#A8E6CF") if done else UiPalette.WARM_WHITE
	s.border_color = Color("#7FBFA3") if done else RIM_EDGE
	s.set_border_width_all(3)
	s.set_corner_radius_all(20)
	return s
