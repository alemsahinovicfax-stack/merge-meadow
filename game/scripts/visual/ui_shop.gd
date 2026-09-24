class_name UiShop
extends RefCounted

## Shop — design_handoff_shop/README.md · design/ShopScreen.dc.html
## Sve mjere su u px baze 1080x1920. Shop zauzima 1597 px izmedju headera (143)
## i footera (180) iz UiChrome. Nijanse su iz ui_palette.gd / ui_camp.gd / ui_home.gd;
## nove su samo CONFIRM_EDGE, FAIL_PINK* (= UiCamp.WARN_PINK*) i LABEL_CHIP.
## Katalog, cijene i pravila se ne mijenjaju — ovo je samo izgled.

# --- Boje ---
const PAGE_BG := Color("#2E4733")              # = UiCamp.MEADOW_BG
const CHROME_DEEP := Color("#1A241E")          # = UiChrome.CHROME_DEEP
const CREAM := Color("#FFF8F0")                # = UiPalette.WARM_WHITE
const RIM := Color("#FFF6D6")                  # = UiHome.RIM
const INK := Color("#2D3436")                  # = UiPalette.OUTLINE
const SUB_INK := Color("#555C5E")              # 6,5:1 na krem
const DISABLED_INK := Color("#5C6264")         # = UiCamp.TRADE_DISABLED_INK
const BUSY_INK := Color("#44443A")             # = UiHome.INK_DISABLED
const PRICE_BG := Color("#FFE8B8")
const PRICE_EDGE := Color("#D6A82F")           # = UiCamp.GOLD_EDGE
const PRICE_INK := Color("#1A1A14")
const PRICE_SUB_INK := Color("#5A4A1E")
const COIN_GOLD := Color("#FFD56B")
const SPEND_COINS := Color("#E8C44A")          # = UiPalette.GOLD (Home unlock)
const SPEND_COINS_EDGE := Color("#BA9D3B")
const SPEND_COINS_PRESSED := Color("#D6B23C")
const CONFIRM_EDGE := Color("#9C7A14")
const SPEND_MONEY := Color("#D4A5FF")          # = UiPalette.LAVENDER (Home premium CTA)
const SPEND_MONEY_EDGE := Color("#AA84CC")
const SPEND_MONEY_PRESSED := Color("#C293F0")
const USE := Color("#A8E6CF")                  # = UiPalette.MINT
const USE_EDGE := Color("#7FC9AC")
const USE_PRESSED := Color("#94D6BE")
const ACTIVE := Color("#FFB88C")               # = UiPalette.PEACH
const ACTIVE_EDGE := Color("#E8A374")
const FAIL_PINK := Color("#FFCCD5")
const FAIL_PINK_EDGE := Color("#E89AAA")
const BOOSTER_DISC := Color("#E0C4FF")         # = UiPalette.RARITY_BG_2
const BOOSTER_DISC_EDGE := Color("#B39DCC")
const WELL := Color("#22342A")
const WELL_EDGE := Color("#16211B")
const ROSTER_RIM := Color("#CBC2B6")
const ALBUM_FRAME := Color("#E8C44A")
const SEASON_SUB_LIGHT := Color("#3F4648")
const SEASON_SUB_DARK := Color("#E9E1F0")
const SOON_DOT := Color("#4A5550")
const SOON_DOT_RING := Color("#6B746F")
const LABEL_CHIP := Color(0.102, 0.141, 0.118, 0.84)
const PIP_SHADOW := Color(0.071, 0.110, 0.086, 0.28)
const SHADOW := Color(0.078, 0.102, 0.086, 0.26)
const SHADOW_HEADER := Color(0.078, 0.102, 0.086, 0.22)
const SHADOW_POP := Color(0.078, 0.102, 0.086, 0.30)

# --- Stranica ---
const PAGE_H := 1597
const PAGE_PAD_X := 24
const CONTENT_TOP := 184                       # HEADER_ROW_H + 24
const CONTENT_BOTTOM := 64
const SECTION_GAP := 64
const BLOCK_GAP := 20
const CARD_W := 1032
const RADIUS_CARD := 26
const RADIUS_BUTTON := 20
const RADIUS_TAG := 18
const RADIUS_TAG_SMALL := 16

# --- ShopHeaderRow / JumpChip ---
const HEADER_ROW_H := 160
const HEADER_ROW_PAD_TOP := 20
const JUMP_H := 120
const JUMP_GAP := 14
const JUMP_FONT := 42
const T_JUMP := 0.28
const SPY_OFFSET := 304                        # CONTENT_TOP + 120

# --- SectionTitle ---
const SECTION_TITLE_H := 64
const ACCENT_SIZE := Vector2(10, 56)
const FONT_SECTION_TITLE := 56
const FONT_SECTION_SUB := 38

# --- CosmeticSlot / CosmeticCard / CosmeticPreview ---
const SLOT_PAD := 20
const SLOT_HEAD_H := 48
const FONT_SLOT_TITLE := 46
const COSMETIC_H := 284
const COSMETIC_GAP := 24
const PREVIEW_SIZE := Vector2(440, 284)
const PREVIEW_BORDER := 3
const PREVIEW_HALF_GAP := 3
const PREVIEW_RADIUS := 20
const LANE_W := 150
const LANE_EDGE_W := 4
const MOW_H := 30
const MOW_TOPS := [14.0, 107.0, 200.0]
const PIP_SPRITE := 156
const PIP_SPRITE_BOTTOM := 14
const PIP_DRAW_SCALE := 2.3
const PIP_DRAW_BOTTOM := 32
const LABEL_CHIP_H := 56
const ALBUM_INSET := 18
const ALBUM_FRAME_W := 10
const ALBUM_ROW_H := 36
const ALBUM_ROW_H_FRAMED := 32
const ACTION_ROW_H := 120
const COIN_PRICE_MIN_W := 190
const CANCEL_W := 150
const FONT_NAME := 48
const FONT_BODY := 38

# --- Kartice za pravi novac ---
const MONEY_ROW_H := 130
const MONEY_PRICE_MIN_W := 280
const BOOSTER_PRICE_MIN_W := 220
const BOOSTER_BUY_W := 280
const SEASON_PAD := 24
const SEASON_ROSTER_W := 316
const ROSTER_WELL := 96
const ROSTER_GAP := 14
const ROSTER_DOT := 52
const ROSTER_DOT_RING := 6
const FONT_SEASON_NAME := 60
const FONT_EYEBROW := 38
const BOOSTER_DISC_SIZE := 112
const BOOSTER_ICON := 64
const COUNT_SIZE := Vector2(190, 112)
const FONT_COUNT := 56
const IAP_PAD := 24
const CONTENT_CHIP_H := 76

# --- Tekst ---
const FONT_BUTTON := 46
const FONT_BUTTON_SUB := 38
const FONT_PRICE := 52
const FONT_PRICE_LONG := 44                    # minimum za cijene
const PRICE_LONG_CHARS := 7
const FONT_TAG := 40
const FONT_STATUS := 38
const FONT_TOAST := 40
const TAG_H := 76
const SEASON_TAG_H := 60
const STATUS_MIN_H := 76
const HEAVY := 0.5                             # embolden 900 (default font)
const BOLD := 0.38
const REGULAR := 0.25

# --- Trajanja (s) ---
const T_PRESS := 0.08
const T_CONFIRM_FADE := 0.12
const T_PREVIEW_POP := 0.22
const T_HALVES_MERGE := 0.20
const T_COIN_POP := 0.6
const T_STATUS_IN := 0.18
const T_STATUS_HOLD := 2.4
const T_TOAST_HOLD := 2.6
const T_BUSY_PULSE := 0.8
const BUSY_ALPHA := Vector2(0.55, 0.85)
const DIM_ALPHA := 0.5

# --- Stanja (stringovi da ih smoke testovi mogu porediti) ---
const COS_BUY := "buy"
const COS_SHORT := "short"
const COS_CONFIRM := "confirm"
const COS_OWNED := "owned"
const COS_EQUIPPED := "equipped"

const BUY_IDLE := "buy"
const BUY_BUSY := "busy"
const BUY_DIM := "dim"

const SEASON_BUY := "buy"
const SEASON_BUSY := "busy"
const SEASON_DIM := "dim"
const SEASON_OWNED := "owned"
const SEASON_SOON := "soon"

const USE_ON := "use"
const USE_ARMED := "armed"
const USE_FULL := "full"
const USE_NONE := "none"

const STATUS_OK := "ok"
const STATUS_FAIL := "fail"
const STATUS_PENDING := "pending"

const SECTIONS: Array[String] = ["looks", "seasons", "boosters", "support"]
const SECTION_LABELS: Array[String] = ["Looks", "Seasons", "Boosters", "Support"]
const SECTION_SUBS: Array[String] = [
	"for coins · looks only", "one-time · theme only",
	"optional helpers · one use each", "one-time purchases",
]

const SLOT_TITLES := {
	CosmeticCatalog.SLOT_PIP_SKIN: ["Pip skin", "in runs · wear one"],
	CosmeticCatalog.SLOT_MEADOW_BG: ["Meadow tint", "run background · wear one"],
	CosmeticCatalog.SLOT_JOURNAL_FRAME: ["Album frame", "Journal page"],
}
const SLOT_EQUIPPED_NOTE := {
	CosmeticCatalog.SLOT_PIP_SKIN: "Pip wears this in runs.",
	CosmeticCatalog.SLOT_MEADOW_BG: "Your runs use this tint.",
	CosmeticCatalog.SLOT_JOURNAL_FRAME: "Your Bloom Album wears this.",
}
const SLOT_BOUGHT := {
	CosmeticCatalog.SLOT_PIP_SKIN: "Bought · Pip wears it now",
	CosmeticCatalog.SLOT_MEADOW_BG: "Bought · your runs use it now",
	CosmeticCatalog.SLOT_JOURNAL_FRAME: "Bought · your Album wears it",
}


# --- Pravila prikaza (bez izmjene ekonomije) ---

## Stanje CosmeticCard. `confirm_id` = predmet cija je potvrda otvorena.
static func cosmetic_mode(item_id: String, confirm_id: String) -> String:
	if GameState.is_cosmetic_equipped(item_id):
		return COS_EQUIPPED
	if GameState.owns_cosmetic(item_id):
		return COS_OWNED
	if confirm_id == item_id:
		return COS_CONFIRM
	if GameState.wallet_coins >= CosmeticCatalog.get_coin_cost(item_id):
		return COS_BUY
	return COS_SHORT


## Dugme pravog novca: jedno kupovanje u isto vrijeme (IAPManager.is_busy()).
static func buy_mode(sku: String, busy_sku: String) -> String:
	if not IAPManager.is_busy():
		return BUY_IDLE
	return BUY_BUSY if sku == busy_sku else BUY_DIM


static func season_mode(def: SeasonDef, busy_sku: String) -> String:
	if GameState.is_test_locked_season(def.id):
		return SEASON_SOON
	if IAPManager.owns_product(def.iap_product_id):
		return SEASON_OWNED
	return buy_mode(def.iap_product_id, busy_sku)


## Use red boostera. Cuva hint od dvostrukog trosenja i Loot Burst od punog baga.
static func use_mode(booster_id: String) -> String:
	if booster_id == MonetizationConfig.BOOSTER_MERGE_HINT and GameState.boosters.merge_hint_active:
		return USE_ARMED
	if GameState.get_booster_count(booster_id) <= 0:
		return USE_NONE
	if booster_id == MonetizationConfig.BOOSTER_LOOT_BURST \
			and GameState.sum_seed_bag(GameState.seed_bag) >= GameState.SEED_BAG_SOFT_CAP:
		return USE_FULL
	return USE_ON


## purchase_failed reason -> [kind, naslov, podnaslov]. kind "" = samo refresh.
static func fail_text(reason: String) -> PackedStringArray:
	match reason:
		"purchase_cancelled":
			return PackedStringArray([STATUS_FAIL, "Cancelled in the store.", "Nothing was bought."])
		"purchase_pending":
			return PackedStringArray([STATUS_PENDING, "Payment pending.", "It unlocks when the store confirms."])
		"ack_failed":
			return PackedStringArray([STATUS_PENDING, "Almost there.", "The store is confirming — it will unlock."])
		"already_owned", "busy", "test_locked":
			return PackedStringArray(["", "", ""])
		_:
			return PackedStringArray([STATUS_FAIL, "The store didn’t answer.", "Nothing was bought — try again."])


## Store string moze biti dug ("Rp 57.900") — preko 7 znakova 44 px, nikad manje.
static func price_font_px(text: String) -> int:
	return FONT_PRICE_LONG if text.length() > PRICE_LONG_CHARS else FONT_PRICE


# --- Boje pregleda i sezona ---

## Boje staze za pregled: UiRun x meadow modulate x season modulate (kao lane_background.gd).
static func preview_lane_colors(meadow_id: String, season_id: String) -> Dictionary:
	var m: Color = CosmeticCatalog.get_meadow_modulate(meadow_id) * SeasonTheme.bg_modulate(season_id)
	return {
		"ground": UiRun.GROUND * m,
		"lane": UiRun.LANE * m,
		"edge": UiRun.LANE.lerp(CREAM, UiRun.LANE_EDGE.a) * m,
		"mow": UiRun.LANE.lerp(CREAM, UiRun.LANE_MOW.a) * m,
		"tuft": UiRun.TUFT * m,
		"petal": UiRun.PETAL * m,
	}


## Paleta za PipDraw; prazna = pip_idle.svg (klasicni Pip).
static func preview_pip_palette(pip_skin_id: String) -> Dictionary:
	return CosmeticCatalog.get_pip_palette(pip_skin_id)


static func season_fill(season_id: String, soon: bool) -> Color:
	var mood := SeasonCardContrast.mood_color(season_id)
	return mood.lerp(PAGE_BG, 0.44) if soon else mood


static func is_light(c: Color) -> bool:
	return _rel_lum(c) >= 0.2


static func season_ink(fill: Color) -> Color:
	return INK if is_light(fill) else CREAM


static func season_sub_ink(fill: Color) -> Color:
	return SEASON_SUB_LIGHT if is_light(fill) else SEASON_SUB_DARK


static func _rel_lum(c: Color) -> float:
	var l := c.srgb_to_linear()
	return 0.2126 * l.r + 0.7152 * l.g + 0.0722 * l.b


static func scale_rgb(c: Color, f: float) -> Color:
	return Color(c.r * f, c.g * f, c.b * f, c.a)


static func alpha(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, a)


# --- StyleBoxFlat ---

static func box(fill: Color, radius: int, border: int = 0, edge: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.set_corner_radius_all(radius)
	s.corner_detail = 12
	s.anti_aliasing = true
	if border > 0:
		s.set_border_width_all(border)
		s.border_color = edge
	return s


static func pad(s: StyleBoxFlat, x: float, y: float) -> StyleBoxFlat:
	s.content_margin_left = x
	s.content_margin_right = x
	s.content_margin_top = y
	s.content_margin_bottom = y
	return s


static func shadow(s: StyleBoxFlat, color: Color, offset: float, blur: int) -> StyleBoxFlat:
	s.shadow_color = color
	s.shadow_offset = Vector2(0, offset)
	s.shadow_size = blur
	return s


## Krem kartica (CosmeticSlot, BoosterCard, IapCard). HTML je border-box.
static func card_style(padding: int = SLOT_PAD) -> StyleBoxFlat:
	var s := box(CREAM, RADIUS_CARD, 2, alpha(INK, 0.16))
	pad(s, padding + 2, padding + 2)
	return shadow(s, SHADOW, 8, 8)


static func header_row_style() -> StyleBoxFlat:
	var s := box(PAGE_BG, 0)
	s.border_width_bottom = 2
	s.border_color = alpha(CREAM, 0.16)
	return shadow(s, SHADOW_HEADER, 6, 6)


static func jump_chip_style(active: bool) -> StyleBoxFlat:
	if active:
		return box(ACTIVE, RADIUS_BUTTON, 4, ACTIVE_EDGE)
	return box(alpha(CREAM, 0.10), RADIUS_BUTTON, 2, alpha(CREAM, 0.38))


static func jump_chip_ink(active: bool) -> Color:
	return INK if active else CREAM


static func accent_style(coins: bool) -> StyleBoxFlat:
	return box(COIN_GOLD if coins else SPEND_MONEY, 5)


static func hairline_style() -> StyleBoxFlat:
	return box(alpha(INK, 0.12), 0)


## Prozor pregleda (clip_contents na nodeu). Unutra se crta _draw().
static func preview_style() -> StyleBoxFlat:
	return box(WELL_EDGE, PREVIEW_RADIUS, PREVIEW_BORDER, WELL_EDGE)


static func label_chip_style() -> StyleBoxFlat:
	return pad(box(LABEL_CHIP, RADIUS_TAG_SMALL, 2, alpha(CREAM, 0.40)), 16, 0)


static func album_page_style() -> StyleBoxFlat:
	return pad(box(CREAM, 14), 14, 14)


## Zlatni ram (journal_gold). Crta se preko stranice, bez ispune.
static func album_frame_style() -> StyleBoxFlat:
	var s := box(Color.TRANSPARENT, 14, ALBUM_FRAME_W, ALBUM_FRAME)
	s.draw_center = false
	return s


static func price_tag_style(coins: bool) -> StyleBoxFlat:
	return pad(box(PRICE_BG, RADIUS_BUTTON, 3, PRICE_EDGE), 22 if coins else 26, 0)


## kind: "coins" | "confirm" | "money" | "use" | "disabled" | "busy_on_mood" | "cancel"
static func button_style(kind: String, pressed: bool = false) -> StyleBoxFlat:
	match kind:
		"coins":
			return box(SPEND_COINS_PRESSED if pressed else SPEND_COINS, RADIUS_BUTTON, 3, SPEND_COINS_EDGE)
		"confirm":
			return box(SPEND_COINS_PRESSED if pressed else SPEND_COINS, RADIUS_BUTTON, 4, CONFIRM_EDGE)
		"money":
			return box(SPEND_MONEY_PRESSED if pressed else SPEND_MONEY, RADIUS_BUTTON, 3, SPEND_MONEY_EDGE)
		"use":
			return box(USE_PRESSED if pressed else USE, RADIUS_BUTTON, 3, USE_EDGE)
		"busy_on_mood":
			return box(alpha(CREAM, 0.55), RADIUS_BUTTON, 3, Color(0.102, 0.102, 0.078, 0.30))
		"cancel":
			return box(alpha(INK, 0.12 if pressed else 0.06), RADIUS_BUTTON, 3, alpha(INK, 0.24))
		_:
			return box(alpha(INK, 0.10), RADIUS_BUTTON, 3, alpha(INK, 0.22))


static func button_ink(kind: String) -> Color:
	match kind:
		"disabled":
			return DISABLED_INK
		"busy_on_mood":
			return BUSY_INK
		_:
			return INK


## Owned / Wearing / Yours / iap. Tag je uvijek nizi od dugmeta (60–76 vs 120–130).
static func tag_style(kind: String) -> StyleBoxFlat:
	match kind:
		"wearing":
			return pad(box(ACTIVE, RADIUS_TAG, 3, ACTIVE_EDGE), 22, 0)
		"yours":
			return pad(box(RIM, RADIUS_TAG_SMALL, 3, PRICE_EDGE), 22, 0)
		"iap":
			return pad(box(USE, RADIUS_TAG, 3, USE_EDGE), 22, 0)
		"soon":
			return pad(box(CHROME_DEEP, RADIUS_TAG_SMALL, 3, alpha(CREAM, 0.55)), 22, 0)
		_:
			return pad(box(alpha(INK, 0.06), RADIUS_TAG, 2, alpha(INK, 0.18)), 20, 0)


static func status_style(kind: String) -> StyleBoxFlat:
	match kind:
		STATUS_FAIL:
			return pad(box(FAIL_PINK, RADIUS_TAG, 3, FAIL_PINK_EDGE), 20, 10)
		STATUS_PENDING:
			return pad(box(PRICE_BG, RADIUS_TAG, 3, PRICE_EDGE), 20, 10)
		_:
			return pad(box(USE, RADIUS_TAG, 3, USE_EDGE), 20, 10)


## SeasonPackCard. state: SEASON_*
static func season_card_style(season_id: String, state: String) -> StyleBoxFlat:
	var soon := state == SEASON_SOON
	var mood := SeasonCardContrast.mood_color(season_id)
	var edge := scale_rgb(mood, 0.8)
	var border := 3
	if state == SEASON_OWNED:
		edge = RIM
		border = 4
	elif soon:
		edge = Color(1.0, 0.965, 0.839, 0.34)
	var s := box(season_fill(season_id, soon), RADIUS_CARD, border, edge)
	pad(s, SEASON_PAD + border, SEASON_PAD + border)
	return shadow(s, SHADOW, 8, 8)


static func open_on_home_style(light: bool) -> StyleBoxFlat:
	if light:
		return box(alpha(CREAM, 0.74), RADIUS_BUTTON, 3, Color(0.102, 0.102, 0.078, 0.26))
	return box(alpha(CREAM, 0.20), RADIUS_BUTTON, 3, alpha(CREAM, 0.40))


static func soon_info_style() -> StyleBoxFlat:
	return box(alpha(CREAM, 0.16), RADIUS_BUTTON, 3, Color(1.0, 0.965, 0.839, 0.40))


static func roster_well_style() -> StyleBoxFlat:
	return box(WELL, ROSTER_WELL / 2, 3, ROSTER_RIM)


static func roster_dot_style(season_id: String, soon: bool) -> StyleBoxFlat:
	var mood := SeasonCardContrast.mood_color(season_id)
	return box(SOON_DOT if soon else mood, ROSTER_DOT / 2, ROSTER_DOT_RING,
		SOON_DOT_RING if soon else mood.lerp(CREAM, 0.55))


static func booster_disc_style() -> StyleBoxFlat:
	return box(BOOSTER_DISC, BOOSTER_DISC_SIZE / 2, 3, BOOSTER_DISC_EDGE)


static func count_style() -> StyleBoxFlat:
	return pad(box(alpha(INK, 0.06), RADIUS_BUTTON, 2, alpha(INK, 0.20)), 20, 0)


## Starter Pack sadrzaj: "coin" | "seed" | "hint".
static func content_chip_style(kind: String) -> StyleBoxFlat:
	var s: StyleBoxFlat
	match kind:
		"coin":
			s = box(COIN_GOLD, RADIUS_TAG, 3, PRICE_EDGE)
		"seed":
			s = box(USE, RADIUS_TAG, 3, USE_EDGE)
		_:
			s = box(BOOSTER_DISC, RADIUS_TAG, 3, BOOSTER_DISC_EDGE)
	s.content_margin_left = 14
	s.content_margin_right = 22
	return s


static func restore_style(busy: bool) -> StyleBoxFlat:
	if busy:
		return box(alpha(CREAM, 0.06), RADIUS_BUTTON, 3, alpha(CREAM, 0.24))
	return box(alpha(CREAM, 0.10), RADIUS_BUTTON, 3, alpha(CREAM, 0.38))


static func coin_pop_style() -> StyleBoxFlat:
	var s := box(COIN_GOLD, 36, 3, PRICE_EDGE)
	s.content_margin_left = 14
	s.content_margin_right = 22
	return shadow(s, SHADOW_POP, 6, 6)


## Toast — isti kao hub chrome (Settings placeholder).
static func toast_style() -> StyleBoxFlat:
	return UiChrome.toast_style()


# --- Tekst ---

static func style(label: Label, px: int, color: Color, weight: float = HEAVY, line_height: float = 1.0) -> void:
	UiCamp.style_label(label, px, color, weight, line_height)
