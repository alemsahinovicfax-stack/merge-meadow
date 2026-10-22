class_name UiLevels
extends RefCounted

## Leveli koji rastu + Endless (design_handoff_leveli_endless, 2026-10-22). Pojasevi težine,
## Endless dugme / HUD / kraj, cilj na kraju levela, par prepreka, spreman sanduk. Brojevi i
## tajming iz godot/*.json paketa; sve mjere u px baze 1080 × 1920.

const DIR := "res://assets/levels_endless/"

# --- A1 · pojasevi: pojas = ceil(level / 5), kraj pojasa (5/10/15/20) = sanduk ---------
const BANDS := [
	{"n": 1, "id": "stroll", "name": "Stroll", "from": 1, "to": 5, "fill": Color("#A8E6CF")},
	{"n": 2, "id": "jog", "name": "Jog", "from": 6, "to": 10, "fill": Color("#FFD56B")},
	{"n": 3, "id": "dash", "name": "Dash", "from": 11, "to": 15, "fill": Color("#FF9F5A")},
	{"n": 4, "id": "sprint", "name": "Sprint", "from": 16, "to": 20, "fill": Color("#F27C8E")},
]
## Pločica pojasa na kamenu: 72 × 30 (kraj pojasa 86 × 30 sa zvjezdicom), vrh = vrh kamena + 100.
const TAG := Vector2(72, 30)
const TAG_PEAK := Vector2(86, 30)
const TAG_TOP := 100.0
## Zastavica pojasa uz prvi kamen pojasa (1 / 6 / 11 / 16): 180 × 214, dno stuba na (16, 206).
const FLAG := Vector2(180, 214)
const FLAG_FOOT_Y := 206.0
const FLAG_DROP := 40.0
const FLAG_LABEL := Rect2(28, 118, 0, 52)
## LevelChip: [zastavica] Level N [pločica 40 h].
const CHIP_TAG_H := 40.0

# --- A2 · najava levela ----------------------------------------------------------
const INTRO_Y := 560.0
const INTRO_POP := 0.18
const INTRO_SUB := Vector2(0.10, 0.30)
const INTRO_FLY := Vector2(0.74, 1.12)
const INTRO_TOTAL := 1.12
const INTRO_CHIP_BUMP := Vector2(1.06, 1.18)
const INTRO_PLATE_H := 180.0
const INTRO_PLATE_PAD := 64.0
const INTRO_PLATE_GAP := 28.0
const INTRO_FONT := 96
const INTRO_TAG_H := 60.0
const INTRO_SUB_H := 88.0
const INTRO_SUB_DISC := 60.0
const INTRO_SUB_FONT := 44
const INTRO_GAP := 22.0
const INTRO_FLY_TO := Vector2(-300.0, 24.0)
const INTRO_FLY_SCALE := 0.36
const S_REPLAY := "Replay"

# --- A3 · nalet (bez teksta) -------------------------------------------------------
const GUST_TOTAL := 0.42
const GUST_STREAK := 0.36
const GUST_LEAN := 0.30
const GUST_JOLT := 0.16
const GUST_STAGGER := 0.03
const GUST_X := [178.0, 405.0, 675.0, 902.0, 540.0]
const GUST_Y := [260.0, 120.0, 180.0, 300.0, 1180.0]
const GUST_TRAVEL := 900.0
const GUST_ALPHA := 0.62
const GUST_SIZE := Vector2(18, 240)
const GUST_JOLT_PX := 10.0
const GUST_LEAN_Y := 0.06

# --- A4 · par prepreka (jedan predmet preko dvije staze) ------------------------------
## SVG je proširen na 496 / 276 × 228 (viewBox od y −8) da mint zastavica ne bude odsječena;
## sidro (centar sudara) je zato 8 px niže nego u paketu.
const PAIR_WIDE := Vector2(496, 228)
const PAIR_SIDE := Vector2(276, 228)
const PAIR_WIDE_ANCHOR := Vector2(230, 159)
const PAIR_SIDE_ANCHOR := Vector2(120, 159)
const PAIR_WIDE_COLLAR := Vector2(510, 56)
const PAIR_WIDE_SHADOW := Vector2(440, 44)
const PAIR_SIDE_COLLAR := Vector2(240, 52)
const PAIR_SIDE_SHADOW := Vector2(168, 40)

# --- A6 · cilj na kraju levela ---------------------------------------------------
const GATE_POST := Vector2(120, 440)
const GATE_POST_X := [78.0, 882.0]
const GATE_POST_TOP := -372.0
const GATE_ARCH := Rect2(90, -480, 900, 240)
const GATE_ARCH_PIVOT := Vector2(450, 150)
const GATE_TAPE := Rect2(140, -40, 800, 80)
const GATE_HALF := Vector2(420, 80)
const GATE_HALF_PIVOT := Vector2(12, 40)
const GATE_HALF_X := [148.0, 932.0]
const FINISH_TAPE := 0.36
const FINISH_FLAP := 0.5
const FINISH_TAPE_DEG := 78.0
const FINISH_FLAP_DEG := 6.0
const FINISH_ARCH := 0.24
const FINISH_ARCH_BUMP := 1.06
const FINISH_CONFETTI := 0.9
const FINISH_CONFETTI_N := 10
const FINISH_BANNER := 0.12

# --- B · Endless -------------------------------------------------------------
const TIER_SEC := 20
## Boja stepenice po „toplini" pojaseva: 0–2 · 3–5 · 6–8 · 9+.
const UNLOCK_LEVEL := 15
const S_LOCKED_TOAST := "Beat Level 15 to unlock Endless"
const S_UNLOCKED := "Endless unlocked!"
const S_PACE := "Pace %d"
const S_BEST := "Best %s"
const S_WAS := "Was %s"
const S_NEW_BEST := "New best!"
const S_ENDLESS := "Endless"
const S_ALL_YOURS := "All yours"
const S_QUIT_ALL_YOURS := "If you quit · all yours"
## Dugme 236 × 124: zaključano krem + prsten napretka (pređeno / 15) + katanac; otvoreno lavanda.
const BTN_RING := Rect2(12, 16, 92, 92)
const BTN_RING_R := 39.0
## Katanac je u CD markupu dijete prstena (92 × 92 na 12, 16) — ovdje u koordinatama dugmeta.
const BTN_SHACKLE := Rect2(12 + 28, 16 + 14, 36, 30)
const BTN_BODY := Rect2(12 + 22, 16 + 36, 48, 42)
const BTN_BEST := Rect2(28, 100, 180, 48)
const BTN_BURST := Rect2(18, -38, 200, 200)
const LOCK_SHAKE_PX := 8.0
const LOCK_SHAKE_SEC := 0.3
const UNLOCK_DELAY := 0.4
const UNLOCK_SHAKE := 0.18
const UNLOCK_POP := Vector2(0.18, 0.44)
const UNLOCK_FLIP := Vector2(0.30, 0.66)
const UNLOCK_BURST := Vector2(0.48, 0.92)
const UNLOCK_BUBBLE := 0.62
const UNLOCK_BUBBLE_HOLD := 2.2
## Endless HUD: LevelChip u dva reda (prstenovi + sat + Pace / trofej + Best).
const HUD_PAD_X := 26.0
const HUD_RINGS := Vector2(46, 26)
const HUD_CLOCK_FONT := 52
const HUD_CLOCK_MIN_W := 112.0
const HUD_PACE_H := 46.0
const HUD_PACE_FONT := 28
const HUD_BEST_FONT := 28
const HUD_TROPHY := 30.0
const HUD_NEW_BEST_H := 36.0
const HUD_NEW_BEST_FONT := 26
## B4 · nova stepenica: pilula ispod čipa.
const PACE_PILL_POS := Vector2(40, 214)
const PACE_PILL_H := 88.0
const PACE_PILL_FONT := 48
const PACE_PILL_ICON := 40.0
const PACE_IN := 0.16
const PACE_OUT := Vector2(0.70, 0.92)
const PACE_TOTAL := 0.92
## B5 · novi rekord: oko LevelChipa, jednom po runu.
const BEST_TOTAL := 0.9
const BEST_RING := 0.36
const BEST_CONFETTI := 0.86
const BEST_TROPHY := 0.4
const BEST_CONFETTI_N := 8
const SOFT := Color("#555C5E")
const RIM := Color("#FFF6D6")
const GOLD := Color("#FFD56B")
const MINT := Color("#A8E6CF")
const LAVENDER := Color("#D4A5FF")
const CREAM := Color("#FFF8F0")
const INK := Color("#2D3436")
const INK_18 := Color(0.176, 0.204, 0.212, 0.18)

# --- C · spreman sanduk ------------------------------------------------------------
const CHEST_CYCLE := 1.8
const CHEST_CYCLE_BIG := 1.5
const CHEST_HOP := 26.0
const CHEST_HOP_BIG := 34.0
const CHEST_WIGGLE := 8.0
const CHEST_WIGGLE_BIG := 10.0
const CHEST_PHASE := 0.23
const CHEST_SHADOW := Rect2(20, 160, 160, 28)
const CHEST_SPARK_SEC := 1.6
const CHEST_TAG_GAP := 4.0
const CHEST_TAG_H := 58.0


static func band_of(level: int) -> int:
	return clampi(ceili(float(clampi(level, 1, 20)) / 5.0), 1, 4)


static func is_peak(level: int) -> bool:
	return level % 5 == 0


static func band(n: int) -> Dictionary:
	return BANDS[clampi(n, 1, 4) - 1]


static func band_fill(n: int) -> Color:
	return band(n)["fill"]


static func pace_band(tier: int) -> int:
	if tier < 3:
		return 1
	if tier < 6:
		return 2
	if tier < 9:
		return 3
	return 4


static func tag_size(level: int) -> Vector2:
	return TAG_PEAK if is_peak(level) else TAG


static func tag_tex(level: int) -> Texture2D:
	return tex("bands/tag_%d%s.svg" % [band_of(level), "_peak" if is_peak(level) else ""])


static func flag_tex(band_n: int) -> Texture2D:
	return tex("bands/flag_%d.svg" % band_n)


static func pair_tex(season_id: String, wide: bool) -> Texture2D:
	return tex("obstacles/%s_pair_%s.svg" % [season_id, "wide" if wide else "side"])


static func gate_tex(season_id: String, part: String) -> Texture2D:
	return tex("finish/%s_%s.svg" % [season_id, part])


## Pozicija i veličina pločice pojasa unutar kamena (kamen 180 × 140 × k).
static func stone_tag_rect(level: int, k: float) -> Rect2:
	var s := tag_size(level) * k
	return Rect2(Vector2(LevelPathKit.STONE_BOX.x * 0.5 * k - s.x * 0.5, TAG_TOP * k), s)


## Sat preživljenog vremena (isto kao UiRun.endless_clock).
static func clock(sec: float) -> String:
	return UiRun.endless_clock(sec)


static var _cache: Dictionary = {}


static func tex(rel: String) -> Texture2D:
	if _cache.has(rel):
		return _cache[rel]
	var path := DIR + rel
	var t: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	_cache[rel] = t
	return t


# --- easing (isti kao run_stage.js) ---

static func out_back(t: float) -> float:
	var c := 1.70158
	return 1.0 + (c + 1.0) * pow(t - 1.0, 3.0) + c * pow(t - 1.0, 2.0)


static func out3(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3.0)


static func in2(t: float) -> float:
	return t * t


static func io2(t: float) -> float:
	return 2.0 * t * t if t < 0.5 else 1.0 - pow(-2.0 * t + 2.0, 2.0) * 0.5


## sin-zvono na [a, b], 0 izvan.
static func bell(t: float, a: float, b: float) -> float:
	if t <= a or t >= b:
		return 0.0
	return sin(PI * (t - a) / (b - a))


static func clamp01(v: float) -> float:
	return clampf(v, 0.0, 1.0)
