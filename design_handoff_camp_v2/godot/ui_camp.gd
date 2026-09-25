## Camp v2 — samo IZMIJENJENE i NOVE konstante/fabrike.
## Spoji u game/scripts/visual/ui_camp.gd (isti nazivi). Sve ostalo iz v1 ostaje.
## Brief: docs/04-experience/design-drafts/camp-v2-cd-brief.md

# --- Vertikalni budzet: 24 + 276 + 20 + 1253 + 24 = 1597 ---
const SEASON_H := 276                  # bilo 422
const SECTION_GAP := 20                # FIKSAN; StackGap vise nije size_flags_vertical = 3
const SECTION_H := 1253                # CONTENT_H - SEASON_H - SECTION_GAP; ne zavisi od broja tipova
const SECTION_H_NO_SEASON := 1549      # = CONTENT_H
# OBRISATI: SECTION_GAP_MIN, SECTION_H_DEFAULT, GRID_MAX_ROWS

# --- Tabovi ---
const TABS_H := 120                    # bilo 132
const TAB_ICON := 76                   # bilo 84
const TAB_ICON_ART := 44               # bilo 48
const TAB_COUNT_H := 56                # bilo 60
const TAB_COUNT_MIN_W := 80            # bilo 88
const TAB_GAP := 14
const TAB_INACTIVE_BG := Color("#F1EBE4")     # INK 6 % na krem, puna boja
const TAB_INACTIVE_EDGE := Color("#D9D3CC")
const TAB_COUNT_INACTIVE_BG := Color("#E6DFD8")
const FONT_TAB_COUNT := 42
# OBRISATI: FONT_TAB_SUB, SHORTCUT_W, SHORTCUT_ICON, FONT_SHORTCUT

# --- Chip (vanjska mjera ista 489 x 176, i rezervisan) ---
const CHIP_H_RESERVED := 176           # bilo 244 — badge ide u red pipsa
const CHIP_ART_FRAME := 128            # bilo 104
const CHIP_ART_FRAME_RADIUS := 28      # cvijet; sjeme = krug
const CHIP_ART_WELL_INSET := 8         # bilo 10
const CHIP_ART_SEED := 96              # bilo 66
const CHIP_ART_FLOWER := 100           # bilo 70
const CHIP_BODY_W := 315               # 489 - 2*(14+2) - 128 - 14
const PILL_H := 52                     # bilo 62
const PILL_ICON := 30
const PRICE_COIN := 32
const BADGE_H := 42                    # bilo 56
const BADGE_ICON := 28
const FONT_CHIP_NAME := 38             # bilo 40
const FONT_PIPS := 34                  # bilo 32 (min 34)
const FONT_COUNT := 42
const FONT_PRICE := 42
const FONT_BADGE := 34
# OBRISATI: FONT_EACH, FONT_BADGE_FLOOR

# --- Trade bar ---
const TRADE_PAD := 14                  # bilo 16 (152 = 2 + 14 + 120 + 14 + 2)
const TRADE_ART := 104                 # bilo 88
const TRADE_ART_WELL_INSET := 7
const TRADE_ART_SEED := 80             # bilo 56
const TRADE_ART_FLOWER := 84           # bilo 60
const TRADE_BTN := Vector2(300, 120)   # bilo 430 x 120
const TRADE_BTN_ICON := 40
const FONT_TRADE_LABEL := 42
const FONT_BTN := 46
const FONT_WARN := 36
const FEEDBACK_H := 62
const FONT_FEEDBACK := 42
const FLY_COIN := 44
const FLY_COIN_MAX := 3
const COIN_BUMP_RING := 6
const TRADE_DISABLED_BG := Color("#EAE4DD")
const TRADE_DISABLED_EDGE := Color("#C9C4BE")
# OBRISATI: FONT_TRADE_SUB, FONT_BTN_SUB, trade_info_text()

# --- Prazno stanje ---
const EMPTY_ART := 120
const EMPTY_ART_ICON := 56
const EMPTY_CTA_H := 120               # dodir
const EMPTY_CTA_VISUAL_H := 100        # panel unutra, margin 10 gore/dolje
const FONT_EMPTY_TITLE := 46
const FONT_EMPTY_CTA := 42
const EMPTY_GAP := 28
# OBRISATI: EMPTY_BLOCK_H, EMPTY_BODY_MAX_W, FONT_EMPTY_BODY

# --- SeasonLinkCard ---
const SEASON_HEAD_H := 120             # bilo 100
const SEASON_PROGRESS_H := 86
const SEASON_GAP := 20
const SEASON_ART_FRAME := 56
const SEASON_ART := 40
const SEASON_SPLIT_H := 86
const UNLOCK_BTN := Vector2(300, 120)  # bilo 988 x 132
const UNLOCK_LOCK_ICON := 40
const FONT_UNLOCK := 48
# OBRISATI: FONT_SEASON_EYEBROW, FONT_SEASON_CAP, FONT_HOME_HINT, HOME_HINT_H,
#           UNLOCK_BTN_H, home_hint_style()

# --- Animacije (nove) ---
const T_TAP_FILL_DRAIN := 0.30
const T_HOLD_RAMP := 0.30
const T_FLY_COIN := 0.26
const T_COIN_BUMP := 0.14


# --- Pomocne (zamjenjuju v1) ---

static func section_height(hero_visible: bool) -> int:
	return SECTION_H if hero_visible else SECTION_H_NO_SEASON


## Visina liste (ScrollContainer) — sekcija je fiksna, lista uzima ostatak.
static func grid_budget(state: String, hero_visible: bool = true) -> int:
	return section_height(hero_visible) - 2 * (SECTION_PAD + SECTION_BORDER) - TABS_H \
		- 2 * SECTION_INNER_GAP - trade_height(state)


## Jedna rijec, bez podnaslova. "Unlocked" samo u trenutku otkljucavanja.
static func unlock_button_text(state: String) -> String:
	return "Unlocked" if state == SEASON_UNLOCKING else "Unlock"


## Trade dugme: jedna rijec + opciona ikona. Stanje nosi boja + ikona, ne podnaslov.
static func trade_button_text(state: String) -> String:
	match state:
		TRADE_HOLD:
			return "Trading"
		TRADE_HOLD_STOP:
			return "Sell 1"
	return "Trade"


## "" = bez ikone.
static func trade_button_icon(state: String) -> String:
	match state:
		TRADE_WARN:
			return "res://assets/ui/camp/icon_lock.svg"
		TRADE_HOLD_STOP:
			return "res://assets/ui/camp/icon_hold_stop.svg"
	return ""


## Fill = prodani dio gomile tokom ovog drzanja (sold / (sold + sellable)).
static func hold_fill_ratio(sold: int, sellable_left: int) -> float:
	var total := sold + sellable_left
	return 0.0 if total <= 0 else clampf(float(sold) / float(total), 0.0, 1.0)


static func trade_button_style(state: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.set_border_width_all(3)
	match state:
		TRADE_HOLD:
			s.bg_color = UiPalette.PEACH_EDGE
			s.border_color = UiPalette.PEACH_EDGE
		TRADE_HOLD_STOP:
			s.bg_color = HOLD_FREEZE
			s.border_color = UiPalette.PEACH_EDGE
		TRADE_WARN:
			s.bg_color = WARN_PINK
			s.border_color = WARN_PINK_EDGE
		TRADE_DISABLED:
			s.bg_color = TRADE_DISABLED_BG
			s.border_color = TRADE_DISABLED_EDGE
		_:
			s.bg_color = UiPalette.PEACH
			s.border_color = UiPalette.PEACH_EDGE
	return s


## Strip: bez "of these" u stop varijanti (kraće, stane u 960).
static func warn_strip_text(stop: bool, season_name: String, need: int, left: int) -> String:
	if stop:
		return "Hold stopped · %s keeps %d" % [season_name, need]
	return "%s needs %d more of these" % [season_name, left]


## Uvijek "Kept · N / M"; na granici se mijenja samo stil (amber), ne tekst.
static func reserved_badge_text(have: int, need: int, _at_floor: bool = false) -> String:
	return "Kept · %d / %d" % [mini(have, need), need]


static func tab_style(active: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	if active:
		s.bg_color = UiPalette.PEACH
		s.border_color = UiPalette.PEACH_EDGE
		s.set_border_width_all(4)
	else:
		s.bg_color = TAB_INACTIVE_BG
		s.border_color = TAB_INACTIVE_EDGE
		s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.content_margin_left = 18
	s.content_margin_right = 18
	return s


static func tab_count_style(active: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = alpha(UiPalette.WARM_WHITE, 0.80) if active else TAB_COUNT_INACTIVE_BG
	s.border_color = alpha(INK, 0.20)
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 2)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s


## Prsten preko coin chipa u headeru dok drzanje prodaje (bez blura).
static func coin_bump_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = Color("#FFF5D1")
	s.set_border_width_all(COIN_BUMP_RING)
	s.set_corner_radius_all(26)
	return s


## Prazan TradeArt kad nema sta prodati (mockup isprekidan; ovdje pun rub).
static func trade_art_empty_style(seed: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = alpha(INK, 0.05)
	s.border_color = alpha(INK, 0.28)
	s.set_border_width_all(4)
	s.set_corner_radius_all(int(TRADE_ART / 2.0) if seed else 24)
	s.corner_detail = 16
	return s


## EmptyCta: vizuelni panel 100 unutar Control-a 120 (margin 10).
static func empty_cta_style(pressed: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = MINT_EDGE.lerp(UiPalette.MINT, 0.5) if pressed else UiPalette.MINT
	s.border_color = MINT_EDGE
	s.set_border_width_all(3)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.content_margin_left = 36
	s.content_margin_right = 36
	s.expand_margin_top = -10
	s.expand_margin_bottom = -10
	return s
