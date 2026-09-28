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
const CARD_BANDS := [0.327, 0.363, 0.31]
const CARD_NAME_Y := 72
const CARD_NAME_SIZE := 80
const ROSTER_TOP := 230
const ROSTER_DISCS := [260, 330, 260]
const ROSTER_GAP := 36
const ROSTER_SIDE_DROP := 70
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

# motion
const OPEN_MS := 560
const CLOSE_MS := 440
const SWAP_MS := 220
const SWAP_OFFSET := 90
const CHROME_OUT_END := 0.30
const CARD_TEXT_OUT_END := 0.40
const FIELD_IN := Vector2(0.55, 0.85)
const FIELD_CHROME_IN := Vector2(0.72, 1.0)
const FIELD_SIDE_SLIDE := 254

enum PlayMode { RETURN_TO_ACTIVE, OPEN_FIELD, START_RUN }

static func play_mode(viewed: String, active: String, field_open: bool) -> int:
	if field_open: return PlayMode.START_RUN
	return PlayMode.OPEN_FIELD if viewed == active else PlayMode.RETURN_TO_ACTIVE
