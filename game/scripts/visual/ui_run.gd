class_name UiRun
extends RefCounted

## Run (lane runner) — docs/04-experience/design-drafts/run-cd-brief.md
## Dizajn: design_handoff_run/README.md · smjer A (kosene staze na tamnoj livadi)
## Sve mjere su u px baze 1080x1920. Run je PUN ekran — nema UiChrome header/footer.
## Dijeljeni hexovi su UiArena konstante (SEED_WELL, RIM_EDGE, GOLD_EDGE, BAG_BODY).

# --- Tlo i staze -------------------------------------------------------
const GROUND := Color("#26382C")          # livada izvan staza
const LANE := Color("#3A5C41")            # kosena staza
const LANE_EDGE := Color(1.0, 0.973, 0.941, 0.20)   # warm white @ 20 %
const LANE_SEAM := Color(1.0, 0.973, 0.941, 0.16)
const LANE_MOW := Color(1.0, 0.973, 0.941, 0.055)   # pruge — SAMO unutar staze
const TUFT := Color("#436B4A")
const PETAL := Color("#7FB98B")
const BLOB := Color(1.0, 0.973, 0.941, 0.05)        # dalji parallax sloj

# --- HUD chip ----------------------------------------------------------
const CHIP_BG := Color("#FFF8F0")
const CHIP_EDGE := UiArena.RIM_EDGE
const CHIP_SHADOW := Color(0.071, 0.110, 0.086, 0.42)
const RING_TRACK := Color(0.176, 0.204, 0.212, 0.16)
const RING_OK := Color("#A8E6CF")
const RING_LOW := Color("#FFB88C")        # ispod RING_LOW_PCT
const RING_LOW_PCT := 0.17
const DIAMOND_CHIP := Color("#B8E0F5")    # wallet bucket, ne "ovaj run"
const DIAMOND_CHIP_EDGE := Color("#8FC4DE")
const TOAST_BG := Color(0.086, 0.129, 0.106, 0.78)

# --- Pickup ------------------------------------------------------------
const COIN_SIZE := 96
const COIN_FILL := Color("#FFD56B")
const COIN_EDGE := UiArena.GOLD_EDGE
const COIN_INNER := Color("#FFE8B8")
const COIN_GLINT := Color("#FFF3D0")

const SEED_SIZE := 120                    # bio 52 (≈ 19 dp) — necitljivo
const SEED_WELL := UiArena.SEED_WELL
const SEED_WELL_EDGE := UiArena.SEED_WELL_EDGE
const SEED_WELL_SIZE := 84
const SEED_FLOWER_SIZE := 76
const SEED_PIP_SIZE := 16                 # rijetkost = BROJ pipa, ne boja
const SEED_PIP_RADIUS := 51
const SEED_PIP_R2 := Color("#D4A5FF")
const SEED_PIP_R3 := Color("#D6A82F")

const DIAMOND_SIZE := 88
const DIAMOND_FILL := Color("#7FDCE8")
const DIAMOND_EDGE := Color("#2E7F8C")
const DIAMOND_FACET := Color("#C8F3F8")

const PICKUP_SHADOW := Color(0.071, 0.110, 0.086, 0.30)
const PICKUP_SHADOW_SIZE := Vector2(64, 18)
const PICKUP_SHADOW_OFFSET := 40          # odvojena sjena = "pluta"

# --- Obstacle ----------------------------------------------------------
const OBSTACLE_BODY := Vector2(176, 150)
const OBSTACLE_COLLAR := Vector2(240, 52) # izgazena trava, zajednicki sloj
const COLLAR := Color("#C7BE9A")
const COLLAR_EDGE := Color("#A79C78")
const STONE := Color("#A9AFA6")
const STONE_EDGE := Color("#878C85")
const STONE_LIGHT := Color("#C4C9C0")
const STUMP := UiArena.BAG_BODY
const STUMP_EDGE := UiArena.BAG_BODY_EDGE
const STUMP_CAP := UiArena.BAG_NECK
const STUMP_RING := Color("#8A6A46")
const HAY := Color("#D9C98A")
const HAY_EDGE := Color("#AEA06A")
const HAY_LIGHT := Color("#EBDCA6")
const FAIL := Color("#E88B8B")

# --- Layout ------------------------------------------------------------
const SAFE_TOP := 60
const LANE_WIDTH := 200                    # pitch 270 → 70 px tla izmedju
const TRACK_LEFT := 170
const TRACK_RIGHT := 910
const PLAYER_Y_RATIO := 0.82               # nepromijenjen
const PLAYER_SIZE := 150

const TIMER_RECT := Rect2(310, 60, 460, 156)   # FIKSNO — ne skace po modu
const TIMER_RING := 104
const TIMER_RING_THICK := 14
const PAUSE_RECT := Rect2(912, 74, 128, 128)   # 128 ≥ 120 px hit
const COMPANION_RECT := Rect2(40, 232, 268, 120)
const BASKET_RECT := Rect2(40, 364, 268, 76)
const COUNTER_SIZE := Vector2(190, 120)
const COUNTER_DIAMOND_SIZE := Vector2(168, 120)
const COUNTER_GAP := 16
const BAR_RIGHT := 40
const BAR_TOP := 232
const TOAST_TOP := 386
const CUE_TOP := 1218                      # Pip speech bubble, iznad magneta

const FONT_SECONDS := 72
const FONT_COUNTER := 56
const FONT_NAME := 44
const FONT_MODE := 38                      # minimum iz briefa §4.1
const FONT_BASKET := 40
const FONT_TOAST := 38

# --- Beat trajanja -----------------------------------------------------
const FAIL_FREEZE := 0.20
const FAIL_SHAKE := 0.24
const FAIL_SHAKE_PX := 14.0
const FAIL_FLASH := 0.12
const FAIL_TOTAL := 0.46                   # prije go_to_scene(LOOT)
const FINISH_BURST := 0.32
const FINISH_STOP := 0.30
const FINISH_TOTAL := 0.62

const PAUSE_DIM := Color(22.0 / 255.0, 33.0 / 255.0, 27.0 / 255.0, 0.82)
const DESIGN_SIZE := Vector2(1080, 1920)


## Chip u HUD-u (TimerChip, CompanionChip, PickupBar, PauseButton).
static func chip_style(radius: int = 26) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = CHIP_BG
	s.border_color = CHIP_EDGE
	s.set_border_width_all(3)
	s.set_corner_radius_all(radius)
	s.shadow_color = CHIP_SHADOW
	s.shadow_size = 0
	s.shadow_offset = Vector2(0, 6)
	return s


## Diamond brojac — druga boja jer ide u wallet odmah, ne u run bag.
static func diamond_chip_style() -> StyleBoxFlat:
	var s := chip_style(26)
	s.bg_color = DIAMOND_CHIP
	s.border_color = DIAMOND_CHIP_EDGE
	return s


## BasketBadge — mint pill kad je loadout aktivan.
static func basket_style() -> StyleBoxFlat:
	var s := chip_style(20)
	s.bg_color = Color("#A8E6CF")
	s.border_color = Color("#7FBFA3")
	return s


## Boja prstena tajmera. `remaining` / `duration` u sekundama.
static func ring_color(remaining: float, duration: float) -> Color:
	if duration <= 0.0:
		return RING_OK
	return RING_OK if remaining / duration > RING_LOW_PCT else RING_LOW


## Centar lanea. Isto kao run_controller._calculate_lanes(), samo za vizual.
static func lane_x(index: int, viewport_width: float) -> float:
	var ratios := [0.25, 0.5, 0.75]
	return viewport_width * float(ratios[clampi(index, 0, 2)])


## Levo/desno staze u px baze 1080 (Rect2 bez visine — visina je viewport).
static func lane_rect(index: int) -> Rect2:
	var cx := lane_x(index, 1080.0)
	return Rect2(cx - LANE_WIDTH * 0.5, 0.0, LANE_WIDTH, 1920.0)


## Pozicije pipa rijetkosti na rimu sjemenke (lokalno, centar = Vector2.ZERO).
## rarity 1 → prazno, 2 → dva pipa, 3 → tri.
static func seed_pip_positions(rarity: int) -> Array:
	var angles: Array = []
	match clampi(rarity, 1, 3):
		2:
			angles = [-104.0, -76.0]
		3:
			angles = [-118.0, -90.0, -62.0]
		_:
			return []
	var out: Array = []
	for a in angles:
		var r := deg_to_rad(float(a))
		out.append(Vector2(cos(r), sin(r)) * float(SEED_PIP_RADIUS))
	return out


static func seed_pip_color(rarity: int) -> Color:
	return SEED_PIP_R3 if rarity >= 3 else SEED_PIP_R2


## Boje jednog motiva prepreke: [fill, edge, light].
## `kind` — "stone" | "stump" | "hay". v1 spawna samo stone i stump.
static func obstacle_colors(kind: String) -> Array:
	match kind:
		"stump":
			return [STUMP, STUMP_EDGE, STUMP_CAP]
		"hay":
			return [HAY, HAY_EDGE, HAY_LIGHT]
		_:
			return [STONE, STONE_EDGE, STONE_LIGHT]


## Timer string. Layout je 2 reda (mod + sekunde) pa najduzi mod string stane.
## Vrati [mode_line, seconds_line]; mode_line je "" u normalnom modu.
static func timer_lines(remaining: float, endless: bool, endless_label: String,
		uses_level: bool, level: int) -> Array:
	var secs := "%ds" % int(ceil(maxf(0.0, remaining)))
	if endless:
		return ["Endless · %s" % endless_label, secs]
	if uses_level:
		return ["Level %d" % level, secs]
	return ["", secs]
