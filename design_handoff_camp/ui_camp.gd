class_name UiCamp
extends RefCounted

## Camp — docs/04-experience/design-drafts/camp-cd-brief.md
## Dizajn: design_handoff_camp/README.md · smjer 1b (tabovi + hero sezona)
## Sve mjere su u px baze 1080x1920. Camp zauzima 1597 px izmedju
## headera (143) i footera (180) iz UiChrome.
##
## Iz UiPalette se koriste samo postojece boje: MINT, LAVENDER, PEACH,
## PEACH_EDGE, GOLD, GOLD_INK, WARM_WHITE, OUTLINE, PRICE_BG, UI_TEXT,
## ICON_MODULATE, RARITY_BG_1..3, RARITY_BG_LOCKED, CORNER_RADIUS (12),
## CORNER_RADIUS_PANEL (20), CORNER_RADIUS_CTA (26).
## Sve ostalo je definisano ovdje.
##
## Bez shadera, gradijenata i blura. Sjena samo kao StyleBoxFlat shadow.
## Pravila i brojevi nisu mijenjani: tap = 1, drzanje = 10/s, 500 + 20.

# --- Nove nijanse (sve izvedene iz ui_palette.gd) ---
const COIN_GOLD := Color("#FFD56B")        # novcic, isti kao u headeru
const GOLD_EDGE := Color("#D6A82F")        # COIN_GOLD, 20 % tamnije
const RIM_EDGE := Color("#CBC2B6")         # WARM_WHITE #FFF8F0, 20 % tamnije
const WELL := Color("#22342A")             # livada #293D2E, 20 % tamnije
const WELL_EDGE := Color("#16211B")        # WELL, 30 % tamnije
const MEADOW_BG := Color("#2E4733")        # pozadina stranice, iz hub chromea
const DARK_INK := Color("#1A1A14")         # tekst na tintu sezone
const SUB_INK := Color("#555C5E")          # UI_TEXT posvijetljen do 6,5:1 na krem
const TAB_INK := Color("#4A5153")          # neaktivan tab, 7,7:1 na krem
const SEASON_INK := Color("#3D3D33")       # DARK_INK posvijetljen, 7,3:1 na tintu
const SEASON_INK_DIM := Color("#44443A")   # Unlock kad nedostaje, 8,0:1
const DISABLED_BG := Color("#E4E4E0")      # = RARITY_BG_LOCKED, lokalno ime
const DISABLED_EDGE := Color("#B6B6B2")
const DISABLED_INK := Color("#5C5C58")     # 5,3:1 na DISABLED_BG
const MINT_EDGE := Color("#7FC9AC")        # MINT, 20 % tamnije
const HOLD_FREEZE := Color("#FFDCC2")      # PEACH desaturisan, zamrznut fill
const STOP_BTN_BG := Color("#FFF3E6")      # WARM_WHITE + PEACH 8 %
const WARN_PINK := Color("#FFCCD5")        # prodaja rezervisanog
const WARN_PINK_EDGE := Color("#E89AAA")
const SHADOW := Color(0.078, 0.125, 0.102, 0.26)   # #14201A @ 26 %
const SHADOW_CHIP := Color(0.078, 0.102, 0.086, 0.24)
const HINT_BG := Color("#3F4547")          # UI_TEXT @ 88 % na krem, spljosteno

# --- Tintovi sezona (kartica SeasonLink) ---
const SEASON_FROST := Color("#C5D5E8")
const SEASON_FROST_EDGE := Color("#9FB4CC")
const SEASON_LANTERN := Color("#C9B8E0")   # = UiPalette.LAVENDER porodica
const SEASON_LANTERN_EDGE := Color("#A193B3")
const SEASON_AMBER := Color("#E8C48A")
const SEASON_AMBER_EDGE := Color("#BA9D6E")

# --- Vertikalni budzet: 24 + 422 + 223 + 904 + 24 = 1597 ---
const PAGE_H := 1597
const PAGE_PAD := 24
const CONTENT_H := 1549                # PAGE_H - 2 * PAGE_PAD
const SEASON_H := 422                  # hero, nikad se ne mijenja
const SECTION_GAP_MIN := 20
const SECTION_H_DEFAULT := 904         # 6 tipova, 3 reda
const SECTION_PAD := 18
const SECTION_INNER_GAP := 14
const SECTION_W := 1032
const SECTION_INNER_W := 992           # SECTION_W - 2 * (border 2 + PAD 18)

# --- Sekcija: tabovi, grid, Trade bar ---
const TABS_H := 132
const TAB_ICON := 84
const TAB_ICON_ART := 48
const TAB_COUNT_H := 72
const TAB_COUNT_MIN_W := 96
const SHORTCUT_W := 190                # "Merge >" plocica
const TAB_W := 387                     # (992 - 14 - 14 - 190) / 2
const GRID_COLS := 2
const GRID_GAP := 14
const GRID_MAX_ROWS := 4
const TRADE_H := 152
const TRADE_H_STRIP := 224             # + ReservedWarning 60 + gap 12
const TRADE_PAD := 16
const TRADE_ART := 88
const TRADE_INFO_W := 406
const TRADE_BTN := Vector2(430, 120)
const WARN_STRIP_H := 60
const FEEDBACK_H := 58
const FEEDBACK_OFFSET := Vector2(-16, -20)   # gornji desni ugao bara
const EMPTY_BLOCK_H := 400
const EMPTY_ART := 110
const EMPTY_CTA_H := 110
const HINT_H := 62                     # ScrollHint, samo smjer 1a

# --- Chip ---
const CHIP_SIZE := Vector2(489, 176)
const CHIP_H_RESERVED := 244           # + ReservedBadge red
const CHIP_PAD := 14
const CHIP_PAD_SELECTED := 11          # border 2 -> 5, ukupna sirina ista
const CHIP_BORDER := 2
const CHIP_BORDER_SELECTED := 5
const CHIP_ART_FRAME := 104
const CHIP_ART_WELL_INSET := 10        # ukljucuje border, ne sabiraj dvaput
const CHIP_ART_SEED := 66
const CHIP_ART_FLOWER := 70
const CHIP_BODY_W := 343               # 489 - 2*2 - 2*14 - 104 - 14
const CHIP_LIFT := 3                   # y pomak kad je odabran
const PILL_H := 62
const PILL_GAP := 10
const COUNT_PILL_W := 128
const PRICE_PILL_W := 205
const BADGE_H := 56
const FONT_CHIP_NAME := 40
const FONT_PIPS := 32
const FONT_COUNT := 48
const FONT_PRICE := 46
const FONT_EACH := 30
const FONT_BADGE := 38
const FONT_BADGE_FLOOR := 34

# --- SeasonLink ---
const SEASON_W := 1032
const SEASON_PAD := 22
const SEASON_HEAD_H := 100
const SEASON_BAR_H := 18
const SEASON_SPLIT_W := 5
const UNLOCK_BTN_H := 132
const BURST_SIZE := 520
const BURST_BORDER := 14
const SEASON_COMPACT_H := 157          # strip, koristi ga samo smjer 1a

# --- Trajanja animacija (sekunde) ---
const T_CHIP_SELECT := 0.12
const T_CHIP_PRESS := 0.08
const T_TAP_POP := 0.09
const T_TAP_FLY := 0.26
const T_HOLD_RESET := 0.14
const T_AUTO_SWITCH := 0.20
const T_AUTO_SWITCH_HOLD := 0.60
const T_HOLD_STOP := 0.14
const T_TAB_CHANGE := 0.16
const T_UNLOCK_BURST := 0.42
const T_UNLOCK_FILL := 0.20

# --- Stanja (stringovi da smoke testovi mogu porediti) ---
const CHIP_IDLE := "idle"
const CHIP_SELECTED := "selected"
const CHIP_PRESSED := "pressed"
const CHIP_DISABLED := "disabled"

const TRADE_IDLE := "idle"
const TRADE_TAP := "tap"
const TRADE_HOLD := "hold"
const TRADE_SWITCH := "switch"
const TRADE_WARN := "warn"
const TRADE_HOLD_STOP := "holdstop"
const TRADE_DISABLED := "disabled"

const SEASON_SHORT := "short"
const SEASON_READY := "ready"
const SEASON_UNLOCKING := "unlocking"


# --- Pomocne ---

## Visina Trade bara za dato stanje. Stanja s upozorenjem su 224 px.
static func trade_height(state: String) -> int:
	return TRADE_H_STRIP if state == TRADE_WARN or state == TRADE_HOLD_STOP else TRADE_H


## Visina grida za dati broj redova (chip 176, rezervisan 244).
## `row_heights` je lista visina po redu; vraca zbir s gapovima.
static func grid_height(row_heights: Array[int]) -> int:
	if row_heights.is_empty():
		return 0
	var total := 0
	for h in row_heights:
		total += h
	return total + GRID_GAP * (row_heights.size() - 1)


## Gornja granica grida da se sekcija zatvori u 1597 px.
static func grid_budget(state: String) -> int:
	return CONTENT_H - SECTION_GAP_MIN - SEASON_H \
		- 2 * SECTION_PAD - TABS_H - 2 * SECTION_INNER_GAP - trade_height(state)


## Visina sekcije za dati grid i stanje Tradea.
static func section_height(grid_h: int, state: String) -> int:
	if grid_h <= 0:
		return 2 * SECTION_PAD + TABS_H + 2 * SECTION_INNER_GAP \
			+ EMPTY_BLOCK_H + trade_height(state)
	return 2 * SECTION_PAD + TABS_H + 2 * SECTION_INNER_GAP \
		+ grid_h + trade_height(state)


static func season_tint(season_id: String) -> Color:
	match season_id:
		"lantern_meadow":
			return SEASON_LANTERN
		"amber_canopy":
			return SEASON_AMBER
		_:
			return SEASON_FROST


static func season_tint_edge(season_id: String) -> Color:
	match season_id:
		"lantern_meadow":
			return SEASON_LANTERN_EDGE
		"amber_canopy":
			return SEASON_AMBER_EDGE
		_:
			return SEASON_FROST_EDGE


static func rarity_bg(rarity: int) -> Color:
	match clampi(rarity, 1, 3):
		2:
			return UiPalette.RARITY_BG_2
		3:
			return UiPalette.RARITY_BG_3
		_:
			return UiPalette.RARITY_BG_1


## Rub rarity podloge: ista boja, 20 % tamnije.
static func rarity_edge(rarity: int) -> Color:
	return rarity_bg(rarity).darkened(0.2)


# --- StyleBoxFlat fabrike ---

## Panel sekcije (StashSection). Isti stil nosi i kartica u smjeru 1a.
static func section_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.WARM_WHITE
	s.border_color = UiPalette.OUTLINE
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_CTA)
	s.set_content_margin_all(SECTION_PAD)
	s.shadow_color = SHADOW
	s.shadow_offset = Vector2(0, 8)
	s.shadow_size = 0
	return s


## Chip u listi. `state` je jedna od CHIP_* konstanti.
static func chip_style(state: String, rarity: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	var bg := rarity_bg(rarity)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.shadow_color = SHADOW_CHIP
	match state:
		CHIP_SELECTED:
			s.bg_color = bg.lerp(Color.WHITE, 0.14)
			s.border_color = UiPalette.PEACH
			s.set_border_width_all(CHIP_BORDER_SELECTED)
			s.set_content_margin_all(CHIP_PAD_SELECTED)
			s.shadow_offset = Vector2(0, 10)
		CHIP_PRESSED:
			s.bg_color = Color(bg.r * 0.92, bg.g * 0.92, bg.b * 0.92, bg.a)
			s.border_color = UiPalette.PEACH
			s.set_border_width_all(CHIP_BORDER_SELECTED)
			s.set_content_margin_all(CHIP_PAD_SELECTED)
			s.shadow_offset = Vector2(0, 3)
		CHIP_DISABLED:
			s.bg_color = UiPalette.RARITY_BG_LOCKED
			s.border_color = DISABLED_EDGE
			s.set_border_width_all(CHIP_BORDER)
			s.set_content_margin_all(CHIP_PAD)
			s.shadow_offset = Vector2(0, 4)
		_:
			s.bg_color = bg
			s.border_color = rarity_edge(rarity)
			s.set_border_width_all(CHIP_BORDER)
			s.set_content_margin_all(CHIP_PAD)
			s.shadow_offset = Vector2(0, 6)
	s.shadow_size = 0
	return s


## Ink na chipu — jedini slucaj kad se mijenja je "nema zaliha".
static func chip_ink(state: String) -> Color:
	return DISABLED_INK if state == CHIP_DISABLED else UiPalette.UI_TEXT


## Okvir za art. `seed` = krug (sjeme), inace kvadrat r 26 (cvijet).
static func art_frame_style(seed: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.WARM_WHITE if seed else UiPalette.GOLD
	s.border_color = RIM_EDGE if seed else GOLD_EDGE
	s.set_border_width_all(3)
	if seed:
		s.set_corner_radius_all(CHIP_ART_FRAME / 2)
	else:
		s.set_corner_radius_all(26)
	return s


## Tamni well u okviru (isti obrazac kao Arena chip).
static func art_well_style(seed: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = WELL
	s.border_color = WELL_EDGE
	s.set_border_width_all(2)
	if seed:
		s.set_corner_radius_all((CHIP_ART_FRAME - 2 * CHIP_ART_WELL_INSET) / 2)
	else:
		s.set_corner_radius_all(18)
	return s


## Brojac (sjeme ili kristal) na chipu.
static func count_pill_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(UiPalette.WARM_WHITE.r, UiPalette.WARM_WHITE.g, UiPalette.WARM_WHITE.b, 0.70)
	s.border_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.20)
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 2)
	s.set_content_margin_all(0)
	s.content_margin_left = 14
	s.content_margin_right = 14
	return s


## Cijena po komadu. Uvijek nosi rijec "each".
static func price_pill_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.PRICE_BG
	s.border_color = GOLD_EDGE
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 2)
	s.content_margin_left = 12
	s.content_margin_right = 12
	return s


## Badge za rezervisano sezonsko cvijece.
## `at_floor` = broj je na granici, drzanje se ovdje prekida.
static func reserved_badge_style(season_id: String, at_floor: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	if at_floor:
		s.bg_color = UiPalette.PRICE_BG
		s.border_color = GOLD_EDGE
		s.set_border_width_all(3)
	else:
		s.bg_color = season_tint(season_id)
		s.border_color = season_tint_edge(season_id)
		s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 2)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s


## Tekst badgea. Ime sezone nose Trade upozorenje i hero kartica —
## na 343 px tijela chipa ne staje bez skracivanja.
static func reserved_badge_text(have: int, need: int, at_floor: bool) -> String:
	return "Hold stops here" if at_floor else "Kept · %d / %d" % [have, need]


## Overlay koji pojacava odabir (iznad chipa, bez hit-testa).
static func select_mark_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0, 0, 0, 0)
	s.border_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.55)
	s.set_border_width_all(4)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL - 5)
	return s


## Tab u redu Seeds | Flowers.
static func tab_style(active: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	if active:
		s.bg_color = UiPalette.PEACH
		s.border_color = UiPalette.PEACH_EDGE
		s.set_border_width_all(4)
	else:
		s.bg_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.06)
		s.border_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.18)
		s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.content_margin_left = 18
	s.content_margin_right = 18
	return s


static func tab_ink(active: bool) -> Color:
	return UiPalette.UI_TEXT if active else TAB_INK


## Brojac tipova na tabu.
static func tab_count_style(active: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	if active:
		s.bg_color = Color(UiPalette.WARM_WHITE.r, UiPalette.WARM_WHITE.g, UiPalette.WARM_WHITE.b, 0.80)
	else:
		s.bg_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.08)
	s.border_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.20)
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 4)
	s.content_margin_left = 18
	s.content_margin_right = 18
	return s


## "Merge >" precica na kraj reda tabova. Vodi na Arena tab.
static func shortcut_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.MINT
	s.border_color = MINT_EDGE
	s.set_border_width_all(3)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	return s


## Panel Trade bara.
static func trade_bar_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.WARM_WHITE
	s.border_color = UiPalette.OUTLINE
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.set_content_margin_all(TRADE_PAD)
	s.shadow_color = SHADOW
	s.shadow_offset = Vector2(0, 6)
	s.shadow_size = 0
	return s


## Trade dugme. `state` je jedna od TRADE_* konstanti.
static func trade_button_style(state: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.set_border_width_all(3)
	match state:
		TRADE_HOLD:
			s.bg_color = UiPalette.PEACH_EDGE
			s.border_color = UiPalette.PEACH_EDGE
		TRADE_HOLD_STOP:
			s.bg_color = STOP_BTN_BG
			s.border_color = UiPalette.PEACH_EDGE
		TRADE_DISABLED:
			s.bg_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.10)
			s.border_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.22)
		_:
			s.bg_color = UiPalette.PEACH
			s.border_color = UiPalette.PEACH_EDGE
	return s


## Ink na Trade dugmetu.
static func trade_button_ink(state: String) -> Color:
	return DISABLED_INK if state == TRADE_DISABLED else UiPalette.UI_TEXT


## Tekst dugmeta: [naslov, podnaslov].
static func trade_button_text(state: String) -> PackedStringArray:
	match state:
		TRADE_HOLD:
			return PackedStringArray(["Trading", "10 / s"])
		TRADE_HOLD_STOP:
			return PackedStringArray(["Tap to sell 1", "no hold for this one"])
		TRADE_WARN:
			return PackedStringArray(["Trade", "sells reserved"])
		TRADE_DISABLED:
			return PackedStringArray(["Trade", "nothing to trade"])
		_:
			return PackedStringArray(["Trade", "hold 10 / s"])


## Fill koji prati drzanje. Kad drzanje stane, fill se zamrzne u HOLD_FREEZE.
static func hold_fill_color(state: String) -> Color:
	return HOLD_FREEZE if state == TRADE_HOLD_STOP else UiPalette.PEACH


## Strip iznad reda u Trade baru.
## `stop` = drzanje je stalo na granici (amber); inace prodaja
## rezervisanog cvijeca (pink).
static func warn_strip_style(stop: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.PRICE_BG if stop else WARN_PINK
	s.border_color = GOLD_EDGE if stop else WARN_PINK_EDGE
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 2)
	s.content_margin_left = 18
	s.content_margin_right = 18
	return s


## Tekst stripa. `season_name` je citljivo ime sezone, ne id.
static func warn_strip_text(stop: bool, season_name: String, need: int, left: int) -> String:
	if stop:
		return "Hold stopped · %s keeps %d of these" % [season_name, need]
	return "%s needs %d more of these" % [season_name, left]


## "+N" pop iznad Trade dugmeta, leti do coin chipa u headeru.
static func feedback_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = COIN_GOLD
	s.border_color = GOLD_EDGE
	s.set_border_width_all(3)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 4)
	s.content_margin_left = 18
	s.content_margin_right = 18
	return s


## Kartica sljedece sezone (hero, 1032 x 422).
static func season_card_style(season_id: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = season_tint(season_id)
	s.border_color = season_tint_edge(season_id)
	s.set_border_width_all(3)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_CTA)
	s.set_content_margin_all(SEASON_PAD)
	s.shadow_color = SHADOW
	s.shadow_offset = Vector2(0, 8)
	s.shadow_size = 0
	return s


## Podloga trake napretka na kartici sezone.
static func progress_track_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(DARK_INK.r, DARK_INK.g, DARK_INK.b, 0.20)
	s.set_corner_radius_all(SEASON_BAR_H / 2)
	return s


## Ispuna trake. `coins` = novcici (gold), inace cvijece (krem).
static func progress_fill_style(coins: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = COIN_GOLD if coins else UiPalette.WARM_WHITE
	s.set_corner_radius_all(SEASON_BAR_H / 2)
	return s


## Unlock dugme. `state` je jedna od SEASON_* konstanti.
static func unlock_button_style(state: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.set_border_width_all(3)
	match state:
		SEASON_READY:
			s.bg_color = UiPalette.GOLD
			s.border_color = UiPalette.GOLD_INK
		SEASON_UNLOCKING:
			s.bg_color = COIN_GOLD
			s.border_color = GOLD_EDGE
		_:
			s.bg_color = Color(UiPalette.WARM_WHITE.r, UiPalette.WARM_WHITE.g, UiPalette.WARM_WHITE.b, 0.55)
			s.border_color = Color(DARK_INK.r, DARK_INK.g, DARK_INK.b, 0.30)
	return s


static func unlock_button_ink(state: String) -> Color:
	if state == SEASON_READY or state == SEASON_UNLOCKING:
		return UiPalette.UI_TEXT
	return SEASON_INK_DIM


## Prsten koji pukne kad sezona bude otkljucana (bez blura, samo border).
static func unlock_burst_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0, 0, 0, 0)
	s.border_color = Color(1.0, 0.961, 0.820, 0.55)   # #FFF5D1 @ 55 %
	s.set_border_width_all(BURST_BORDER)
	s.set_corner_radius_all(BURST_SIZE / 2)
	return s


## Prazno stanje: isprekidani okvir za ikonu.
static func empty_art_style(seed: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.05)
	s.border_color = Color(UiPalette.UI_TEXT.r, UiPalette.UI_TEXT.g, UiPalette.UI_TEXT.b, 0.28)
	s.set_border_width_all(4)
	if seed:
		s.set_corner_radius_all(EMPTY_ART / 2)
	else:
		s.set_corner_radius_all(26)
	return s


## CTA u praznom stanju ("Play a run >" / "Merge in Arena >").
static func empty_cta_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.MINT
	s.border_color = MINT_EDGE
	s.set_border_width_all(3)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.content_margin_left = 36
	s.content_margin_right = 36
	return s


## Broj tipova u naslovu police — koristi ga samo smjer 1a.
## U 1b broj stoji na tabu, pa ovaj sloj ne postoji.
static func hint_pill_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = HINT_BG
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 4)
	s.content_margin_left = 20
	s.content_margin_right = 20
	return s
