# ui_home_v3.gd — Home v3 constants. Same names as ui_stage.gd / ui_home_field.gd where they exist.
class_name UIHomeV3
extends RefCounted

# palette (existing)
const WARM_WHITE := Color("#FFF8F0")
const INK := Color("#2D3436")
const INK_DEEP := Color("#1A1A14")
const INK_SOFT := Color("#555C5E")
const PEACH := Color("#FFB88C")
const COIN_GOLD := Color("#FFD56B")
const MINT := Color("#A8E6CF")
const LAVENDER := Color("#D4A5FF")
const PINK_DOT := Color("#FFCCD5")
const SHADOW := Color(0.102, 0.102, 0.078, 0.26)
const TAB_TRACK := Color(0.176, 0.204, 0.212, 0.10)

const SEASON_GROUND := {
	"country_bloom": Color("#E6F2DB"), "frost_orchard": Color("#D1E6FF"),
	"lantern_meadow": Color("#EBD6FF"), "amber_canopy": Color("#FFEBC7"),
	"moonlit_warren": Color("#B8BDFF"), "coral_tide": Color("#FFE0D6"),
	"starfall_glade": Color("#DBCCFF"), "ember_fen": Color("#FFC79E"),
}
const FREE_ORDER := ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy"]
const PREMIUM_ORDER := ["moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]
const UNLOCK_COINS := 500
const UNLOCK_STARS3 := 20

static func sky(g: Color) -> Color: return g.lerp(Color.WHITE, 0.30)
static func near(g: Color) -> Color: return Color(g.r * 0.93, g.g * 0.93, g.b * 0.93)
static func page_bg(g: Color) -> Color: return g.lerp(Color.WHITE, 0.55) # NEW light variant

# layout (page px, page origin y = 143)
const PAGE := Vector2(1080, 1633)
const TABS_RECT := Rect2(24, 24, 1032, 124)
const TABS_PAD := 8
const TAB_SIZE := Vector2(508, 108)
const TAB_RADIUS := 54
const TAB_LABEL := 46
const CARD_RECT := Rect2(24, 172, 1032, 1160)
const CARD_RADIUS := 48
const CARD_BORDER := 4
const CARD_SHADOW_Y := 12
const CARD_BANDS := [0.32, 0.36, 0.32]   # = UiHomeField.MEADOW_BANDS 0.32 / 0.68; px = round(h * 0.32), round(h * 0.68)
const CARD_NAME_Y := 72
const CARD_NAME_SIZE := 80
const ROSTER_TOP := 230
# round 3: all six flowers, two rows of three (card px). Replaces ROSTER_DISCS [260, 330, 260] / GAP 36 / SIDE_DROP 70.
# Order = roster order: 0..2 = round-2 trio (1 = signature flower, the eye), 3..5 = the other three.
const ROSTER_EYE := 220
const ROSTER_DISC := 180
const ROSTER_GAP := 48
const ROSTER_SIDE_DROP := 26
const ROSTER_ROW2_TOP := 552
const ROSTER6 := [Rect2(178, 256, 180, 180), Rect2(406, 230, 220, 220), Rect2(674, 256, 180, 180), Rect2(198, 552, 180, 180), Rect2(426, 552, 180, 180), Rect2(654, 552, 180, 180)]
const MISSING_NAME_GAP := 18
# locked free season (status locked + unlock): flat veil on every disc, art not drawn, no missing marks
const LOCK_VEIL := Color("#E3D9CC")   # = locked basket grey (field)
const ROSTER_LOCK := Rect2(456, 436, 120, 120)   # status locked only; in unlock the Unlock button carries the lock
const ROSTER_LOCK_ICON := 60
# LOCK_BADGE (896, 40, 96) is removed; DIM_ART .5 now only for coming soon
const REVEAL_MS := 300
const REVEAL_STAGGER_MS := 40
const ROSTER_ART_SCALE := 0.82
const MISSING_ART_MODULATE := Color(0, 0, 0, 0.28)
const MISSING_NAME_SIZE := 38
const PREMIUM_RIM_INSET := 14
const PREMIUM_RIM_WIDTH := 8
const STATUS_TOP := 830
const NEED_CHIP_H := 120
const ACTION_BTN_H := 140
const ARROW_SIZE := 120
const ARROW_Y := 680 # inside card
const ARROW_INSET := 28
const OPEN_GATE := 150
const DOTS_INTERACTIVE := false   # indicator only
const DOTS_Y := 1352
const PLAY_RECT := Rect2(280, 1413, 520, 180)
const PLAY_LABEL := 76
const PLAY_BACK_LABEL := 66
const PLAY_BACK_DISC := 104

# field (unchanged from ui_home_field.gd, listed for the tween)
const GIFT_RECT := Rect2(24, 24, 180, 180)
const BASKET_RECT := Rect2(24, 220, 180, 180)
const UPGRADES_RECT := Rect2(876, 24, 180, 180)
const SEASONS_BTN_RECT := Rect2(70, 1477, 236, 124)
const FIELD_PLAY_RECT := Rect2(324, 1461, 432, 140)
const ENDLESS_BTN_RECT := Rect2(774, 1477, 236, 124)

# motion — round 2 (same numbers as HomeScreen T / FieldScreen W and home_v3_export.json)
const OPEN_MS := 560
const CLOSE_MS := 440
const SWAP_MS := 220
const SNAP_MS := 180
const SWAP_OFFSET := 90
const SWAP_ALPHA_FROM := 0.4
const SWIPE_MIN := 60
const TAP_SLOP := 12
const RUBBER := 40
const RUBBER_FACTOR := 0.35
const SELECT_OUT := Vector2(0.02, 0.30)     # tabs, arrows, dots (u)
const SELECT_LIFT := 24
const CONTENT_OUT := Vector2(0.02, 0.40)    # roster, status, lock, premium rim (u)
const FLOWER_START := 0.20                  # u
const FLOWER_STAGGER_MS := 12
const FLOWER_FADE_MS := 100
const FLOWER_SETTLE_MS := 200
const FLOWER_SCALE_FROM := 0.9
const NOTE_IN := Vector2(0.30, 0.60)
const FIELD_CHROME_IN := Vector2(0.60, 0.92)
const FIELD_CHROME_Y := 16
const FIELD_SIDE_SLIDE := 254
const ATTENTION_RING := {"ms": 1200, "scale": 1.16, "alpha": 0.7}   # the only loop, runs at u = 1 only
const OPEN_TRANSITION_MOUSE_FILTER := Control.MOUSE_FILTER_IGNORE   # group never eats taps (tabs sit under it); SeasonCard / PlayButton / FieldClip (u = 1) take input

# single travelling objects (geometry on eased t = TRANS_CUBIC EASE_IN_OUT)
const NAME_CARD := {"top": 244, "size": 80, "ls_em": -0.015, "cx": 540}
const NAME_FIELD := {"top": 36, "size": 56, "ls_em": -0.01, "cx": 540}
const PIP_CARD_POS := Vector2(425, 1027)
const PIP_CARD_SIZE := 230
const PIP_FIELD_SIZE := 190
const PIP_HOME_FEET := Vector2(756, 1404)       # = UiHomeField.PIP_DEFAULT_BASE
const PIP_SHADOW_CARD := Rect2(45, 8, 140, 30)  # left, bottom, w, h
const PIP_SHADOW_FIELD := Rect2(35, 6, 120, 26)
const PLAY_CARD := {"rect": Rect2(280, 1413, 520, 180), "border": 4, "shadow_y": 10, "shadow_a": 0.30, "text": 76, "tri_h": 30, "tri_w": 48, "gap": 24, "margin": 8}
const PLAY_FIELD := {"rect": Rect2(324, 1461, 432, 140), "border": 3, "shadow_y": 8, "shadow_a": 0.28, "text": 64, "tri_h": 26, "tri_w": 42, "gap": 22, "margin": 6}

## UiHomeField.ANIM old -> new (round 2)
const ANIM_CHANGES := {
	"field_open": [0.28, 0.56],
	"card_content_out": [0.12, "u .02-.40"],
	"bands_in_delay": [0.16, "removed"],
	"bands_in": [0.18, "removed"],
	"chrome_delay": [0.22, 0.336],
	"chrome_in": [0.18, 0.179],
	"chrome_stagger": [0.06, 0.0],
	"chrome_out": [0.12, "removed (close = open reversed)"],
	"field_close": [0.24, 0.44],
	"flower_settle": [0.20, 0.20],
	"flower_stagger": [0.024, 0.012],
}

static func ease_t(u: float) -> float:
	return 4.0 * u * u * u if u < 0.5 else 1.0 - pow(-2.0 * u + 2.0, 3.0) / 2.0

static func win(u: float, a: float, b: float) -> float:
	return clampf((u - a) / (b - a), 0.0, 1.0)

enum PlayMode { RETURN_TO_ACTIVE, OPEN_FIELD, START_RUN }

static func play_mode(viewed: String, active: String, field_open: bool) -> int:
	if field_open: return PlayMode.START_RUN
	return PlayMode.OPEN_FIELD if viewed == active else PlayMode.RETURN_TO_ACTIVE
