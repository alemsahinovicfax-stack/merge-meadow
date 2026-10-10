class_name UiRun
extends RefCounted

## Run (lane runner) — docs/04-experience/design-drafts/run-cd-brief.md
## Dizajn: design_handoff_run/README.md · smjer A (kosene staze na tamnoj livadi)
## Sve mjere su u px baze 1080x1920. Run je PUN ekran — nema UiChrome header/footer.
## Dijeljeni hexovi su UiArena konstante (RIM_EDGE, GOLD_EDGE, BAG_BODY).

# --- Tlo i staze -------------------------------------------------------
const GROUND := Color("#26382C")          # livada izvan staza
const LANE := Color("#3A5C41")            # kosena staza
const LANE_EDGE := Color(1.0, 0.973, 0.941, 0.20)   # warm white @ 20 %
const LANE_SEAM := Color(1.0, 0.973, 0.941, 0.16)
const LANE_MOW := Color(1.0, 0.973, 0.941, 0.055)   # pruge — SAMO unutar staze
const TUFT := Color("#436B4A")
const PETAL := Color("#7FB98B")
const BLOB := Color(1.0, 0.973, 0.941, 0.05)        # dalji parallax sloj

# --- HUD chip (Run HUD v2 · design_handoff_run_hud_v2) -------------------
const CHIP_BG := Color("#FFF8F0")
const CHIP_EDGE := UiArena.RIM_EDGE       # #CBC2B6, rub 3
const CHIP_SHADOW := Color(0.071, 0.110, 0.086, 0.42)
const CHIP_RADIUS := 30
const INK := Color("#2D3436")
const TOAST_BG := Color(0.086, 0.129, 0.106, 0.78)

# --- Pickup ------------------------------------------------------------
const COIN_SIZE := 96                      # icon_coin.svg; fill/edge ostaju za run_token i feed
const COIN_FILL := Color("#FFD56B")
const COIN_EDGE := UiArena.GOLD_EDGE

const SEED_SIZE := 120                    # kutija odrezane sadnice, bez krem kruga
const SEED_FLOWER_SIZE := 120
const SEED_PIP_SIZE := 22                 # rijetkost = BROJ pipa, ne boja
const SEED_PIP_BORDER := 3
const SEED_PIP_RADIUS := 78
const SEED_SHADOW_OFFSET := 70            # ispod baze stabljike; coin ostaje na PICKUP_SHADOW_OFFSET
const SEED_PIP_R2 := Color("#D4A5FF")
const SEED_PIP_R3 := Color("#D6A82F")

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
const STUMP := Color("#9E7A52")
const STUMP_EDGE := Color("#735738")
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

# TopHud v2: jedan red na y 60 — LevelChip · CoinChip · SeedChip · Pause. Bez Pip portreta,
# prstena, sekundi i korpe (design_handoff_run_hud_v2 § Šta se briše).
const TOP_HUD_Y := 60
const TOP_HUD_H := 128
const LEVEL_CHIP_RECT := Rect2(40, 60, 200, 128)   # širina raste s tekstom, max 464
const LEVEL_CHIP_MAX_W := 464
const LEVEL_CHIP_PAD_X := 32
const LEVEL_FLAG := Vector2(38, 57)
const LEVEL_GAP := 12
const COIN_CHIP_RECT := Rect2(520, 60, 180, 128)
const SEED_CHIP_RECT := Rect2(716, 60, 180, 128)
const PAUSE_RECT := Rect2(912, 60, 128, 128)       # 128 ≥ 120 px hit
const PAUSE_ICON := 60
const CHIP_ICON := 52
const CHIP_GAP := 10
const FEED_RECT := Rect2(462, 214, 440, 150)       # toast centar x 806 (ispod SeedChip), y 214
const CUE_TOP := 1218                              # Pip speech bubble, iznad magneta

const FONT_LEVEL := 48
const FONT_LEVEL_ENDLESS := 42
const FONT_COUNTER := 56
const FONT_TOAST := 38

# --- ProgressRail (lijevi pojas x 24–140; staze počinju na 170, kragna na 150) ---
const RAIL_RECT := Rect2(24, 200, 116, 1540)
const RAIL_TRACK := Rect2(70, 300, 28, 1400)
const RAIL_TRACK_RADIUS := 14
const RAIL_TRACK_RIM := 3
const RAIL_SHADOW_Y := 5
const RAIL_FILL := Color("#A8E6CF")
const RAIL_FILL_LOW := Color("#FFB88C")
const RAIL_FILL_RADIUS := 9
const RAIL_LOW_REMAINING := 0.17
const RAIL_MID_TICK := 4
const RAIL_START := Rect2(60, 1688, 48, 24)
const RAIL_FLAG := Rect2(73, 206, 64, 96)
const RAIL_FLAG_PIVOT := Vector2(11, 92)
const RAIL_FINISH_RING := Rect2(28, 202, 108, 108)
const RAIL_FINISH_RING_W := 6
const RAIL_PIP_SIZE := 92
const RAIL_PIP_RIM := 4
const RAIL_PIP_ART := 84
const RAIL_PIP_CENTER_X := 82.0
const RAIL_Y_START := 1700.0
const RAIL_Y_GOAL := 300.0
const RAIL_FLAG_FINISH_SCALE := 1.18
const RAIL_FLAG_FINISH_ROT := -6.0
const RAIL_FLAG_FINISH_TIME := 0.2

# --- RewardBush (šav između staza; pravila: run_hud_export.json → bush) ----
const BUSH_SIZE := Vector2(120, 140)
const BUSH_PIVOT := Vector2(60, 124)
const BUSH_HIT := Vector2(120, 160)
const BUSH_IDLE_ROT_DEG := 5.0
const BUSH_IDLE_SCALE_Y := 1.04
const BUSH_IDLE_PERIOD := 0.9
const BUSH_REWARD_COIN := Rect2(28, 10, 64, 64)
const BUSH_REWARD_SEED := Rect2(31, 18, 58, 58)
const BUSH_BURST_TIME := 0.25
const BUSH_BURST_RING := 160.0
const BUSH_BURST_RING_W := 6
const BUSH_LEAF := Vector2(36, 24)
const BUSH_LEAF_ANGLES := [-160.0, -115.0, -65.0, -20.0, 25.0, 155.0]
const BUSH_LEAF_DIST := [92.0, 106.0]
const BUSH_FLY_DELAY := 0.15
const BUSH_FLY_TIME := 0.35
const BUSH_FLY_ARC := 140.0
const BUSH_FLY_SIZE := 64.0
const BUSH_FLY_STAGGER := 0.04
const BUSH_FLY_RISE := 150.0
const BUSH_MAX_FLY_SPRITES := 4
const BUSH_FIRST_AFTER := 6.0
const BUSH_GAP_MIN := 8.0
const BUSH_GAP_MAX := 12.0
const BUSH_FAIR_PX := 300.0
const BUSH_COIN_WEIGHT := 0.6
const BUSH_COINS := Vector2i(3, 5)
const BUSH_SEEDS := Vector2i(1, 2)
const CHIP_BUMP := 1.08
const CHIP_BUMP_TIME := 0.18

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


## Čip u HUD-u (LevelChip, CoinChip, SeedChip, PauseButton): krem, rub 3 #CBC2B6, r 30,
## tvrda sjena 0 6 0. Sjena se crta ispod pa ne treba blur.
static func chip_style(radius: int = CHIP_RADIUS) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = CHIP_BG
	s.border_color = CHIP_EDGE
	s.set_border_width_all(3)
	s.set_corner_radius_all(radius)
	s.corner_detail = 12
	s.shadow_color = CHIP_SHADOW
	s.shadow_size = 1                     # 1 = tvrda sjena (0 je ne crta), kao UiPopups._hard_shadow
	s.shadow_offset = Vector2(0, 6)
	return s


## Tekst LevelChipa: „Level N", „Endless · Easy/Normal/Hard" ili „Practice" (tutorial nema broj).
static func mode_text(endless: bool, endless_label: String, uses_level: bool, level: int) -> String:
	if endless:
		return "Endless · %s" % endless_label
	if not uses_level:
		return "Practice"
	return "Level %d" % level


## Endless nema cilj → bez zastavice u čipu i bez trake napretka.
static func has_goal(endless: bool) -> bool:
	return not endless


static func rail_visible(endless: bool) -> bool:
	return not endless


## Gornja ivica ProgressPip kruga (px baze): centar ide 1700 → 300 po elapsed / duration.
static func rail_pip_y(progress: float) -> float:
	return lerpf(RAIL_Y_START, RAIL_Y_GOAL, clampf(progress, 0.0, 1.0)) - RAIL_PIP_SIZE * 0.5


## Visina punjenja unutar staze (lokalno, bez ruba): 0 na startu, puna staza na 100 %.
static func rail_fill_height(progress: float) -> float:
	var inner := RAIL_TRACK.size.y - 2.0 * RAIL_TRACK_RIM
	return maxf(0.0, roundf(clampf(progress, 0.0, 1.0) * inner) - 2.0 * RAIL_TRACK_RIM)


## Mint dok ima vremena; peach kad ostane < 17 % (upozorenje „malo vremena" s prstena).
static func rail_fill_color(progress: float) -> Color:
	return RAIL_FILL_LOW if (1.0 - clampf(progress, 0.0, 1.0)) < RAIL_LOW_REMAINING else RAIL_FILL


## Šav između staza `left` i `left + 1` (0 → x 405, 1 → x 675 na 1080).
static func bush_seam_x(left: int, viewport_width: float) -> float:
	var i := clampi(left, 0, 1)
	return (lane_x(i, viewport_width) + lane_x(i + 1, viewport_width)) * 0.5


## Mirovanje grma: jedan Tween loop na korijenu (±5°, scale.y 1 ↔ 1,04, 0,9 s ping-pong).
static func bush_idle_tween(node: Node2D) -> Tween:
	var half := BUSH_IDLE_PERIOD * 0.5
	var t := node.create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "rotation_degrees", BUSH_IDLE_ROT_DEG, half).from(-BUSH_IDLE_ROT_DEG)
	t.parallel().tween_property(node, "scale:y", BUSH_IDLE_SCALE_Y, half).from(1.0)
	t.tween_property(node, "rotation_degrees", -BUSH_IDLE_ROT_DEG, half)
	t.parallel().tween_property(node, "scale:y", 1.0, half)
	return t


## Nagrada grma: 60 % coin 3–5, 40 % sjeme 1–2. Twin / korpa / magnet se ne primjenjuju.
## `roll`, `amount_roll` ∈ [0, 1).
static func roll_bush_reward(roll: float, amount_roll: float) -> Dictionary:
	var coin := roll < BUSH_COIN_WEIGHT
	var span: Vector2i = BUSH_COINS if coin else BUSH_SEEDS
	var n := span.x + mini(int(amount_roll * float(span.y - span.x + 1)), span.y - span.x)
	return {"kind": "coin" if coin else "seed", "amount": n}


static func bush_texture_path(season_id: String, part: String) -> String:
	return "res://assets/run/bush/bush_%s_%s.svg" % [season_id, part]


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
