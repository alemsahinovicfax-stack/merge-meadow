class_name UiCamp
extends RefCounted

## Camp — docs/04-experience/design-drafts/camp-cd-brief.md
## Dizajn: design_handoff_camp/README.md · smjer 1b (tabovi + hero sezona)
## Sve mjere su u px baze 1080x1920. Camp zauzima 1633 px izmedju
## headera (143) i footera (144) iz UiChrome.
##
## Prenos iz paketa, s ispravkama gdje se ui_camp.gd razilazi s .dc.html crtezom:
## - CD je "UI_TEXT" citao kao #2D3436; u ui_palette.gd je to OUTLINE (UI_TEXT je
##   #4A4A4A) — ovdje INK.
## - Rubovi panela su OUTLINE @ 16–18 %, ne puni OUTLINE.
## - shadow_size 0 u Godotu ne crta sjenu — sjene imaju mali blur.
## - Okvir cvijeta je coin gold #FFD56B (ne UI gold), brojac taba 60 × 88 · r 14,
##   rub spremnog Unlock dugmeta #BA9D3B.
## Pravila i brojevi nisu mijenjani: tap = 1, drzanje = 10/s, 500 + 20.

# --- Nijanse (izvedene iz ui_palette.gd) ---
const INK := Color("#2D3436")              # = UiPalette.OUTLINE
const COIN_GOLD := Color("#FFD56B")        # novcic, isti kao u headeru
const GOLD_EDGE := Color("#D6A82F")        # COIN_GOLD, 20 % tamnije
const UNLOCK_GOLD_EDGE := Color("#BA9D3B") # UiPalette.GOLD, 20 % tamnije
const RIM_EDGE := Color("#CBC2B6")         # WARM_WHITE #FFF8F0, 20 % tamnije
const WELL := Color("#22342A")             # livada #293D2E, 20 % tamnije
const WELL_EDGE := Color("#16211B")        # WELL, 30 % tamnije
const MEADOW_BG := Color("#2E4733")        # pozadina stranice, iz hub chromea
const DARK_INK := Color("#1A1A14")         # tekst na tintu sezone
const SUB_INK := Color("#555C5E")          # INK posvijetljen do 6,5:1 na krem
const TAB_INK := Color("#4A5153")          # neaktivan tab, 7,7:1 na krem
const SEASON_INK := Color("#3D3D33")       # DARK_INK posvijetljen, 7,3:1 na tintu
const SEASON_INK_DIM := Color("#44443A")   # Unlock kad nedostaje, 8,0:1
const DISABLED_EDGE := Color("#B6B6B2")
const DISABLED_INK := Color("#5C5C58")     # 5,3:1 na RARITY_BG_LOCKED
const TRADE_DISABLED_INK := Color("#5C6264")
const TAB_INACTIVE_BG := Color("#F1EBE4")       # INK 6 % na krem, puna boja
const TAB_INACTIVE_EDGE := Color("#D9D3CC")
const TAB_COUNT_INACTIVE_BG := Color("#E6DFD8")
const TRADE_DISABLED_BG := Color("#EAE4DD")
const TRADE_DISABLED_EDGE := Color("#C9C4BE")
const COIN_BUMP := Color("#FFF5D1")
const MINT_EDGE := Color("#7FC9AC")        # MINT, 20 % tamnije
const HOLD_FREEZE := Color("#FFDCC2")      # PEACH desaturisan, zamrznut fill
const WARN_PINK := Color("#FFCCD5")        # prodaja rezervisanog
const WARN_PINK_EDGE := Color("#E89AAA")
const BURST := Color(1.0, 0.961, 0.820, 0.55)       # #FFF5D1 @ 55 %
const SHADOW := Color(0.078, 0.102, 0.086, 0.26)    # #141A16 @ 26 %
const SHADOW_CHIP := Color(0.078, 0.102, 0.086, 0.24)

# --- Tintovi sezona (kartica SeasonLink) ---
const SEASON_FROST := Color("#C5D5E8")
const SEASON_FROST_EDGE := Color("#9FB4CC")
const SEASON_LANTERN := Color("#C9B8E0")
const SEASON_LANTERN_EDGE := Color("#A193B3")
const SEASON_AMBER := Color("#E8C48A")
const SEASON_AMBER_EDGE := Color("#BA9D6E")

# --- Vertikalni budzet (v2): 24 + 276 + 20 + 1289 + 24 = 1633 ---
const PAGE_H := 1633
const PAGE_PAD := 24
const CONTENT_H := 1585                # PAGE_H - 2 * PAGE_PAD
const SEASON_H := 276                  # hero, nikad se ne mijenja (v1: 422)
const SECTION_GAP := 20                # fiksan razmak; StackGap vise ne postoji
const SECTION_H := 1289                # CONTENT_H - SEASON_H - SECTION_GAP
const SECTION_H_NO_SEASON := 1585      # kad nema kartice sezone
const SECTION_PAD := 18
## HTML je border-box (rub unutar 1032); u Godotu content margin ne ukljucuje rub.
const SECTION_BORDER := 2
const SECTION_INNER_GAP := 14
const SECTION_W := 1032
const SECTION_INNER_W := 992

# --- Sekcija: tabovi, grid, Trade bar ---
const TABS_H := 120
const TAB_ICON := 76
const TAB_ICON_ART := 44
const TAB_COUNT_H := 56
const TAB_COUNT_MIN_W := 80
const TAB_PAD := 18
const TAB_GAP := 14
const GRID_COLS := 2
const GRID_GAP := 14
const TRADE_H := 152
const TRADE_H_STRIP := 224             # + ReservedWarning 60 + gap 12
const TRADE_PAD := 14
const TRADE_ROW_H := 120
const TRADE_ART := 104
const TRADE_ART_WELL_INSET := 7
const TRADE_ART_SEED := 80
const TRADE_ART_FLOWER := 84
const TRADE_BTN := Vector2(300, 120)
const TRADE_BTN_ICON := 40
const WARN_STRIP_H := 60
const WARN_ICON := 32
const FEEDBACK_H := 62
const FEEDBACK_OFFSET := Vector2(-16, -20)   # gornji desni ugao bara
const FEEDBACK_COIN := 30
## Novcic koji na svaki tik drzanja odleti do coin chipa u headeru (max 3 ziva).
const FLY_COIN := 44
const FLY_COIN_MAX := 3
const COIN_BUMP_RING := 6
const EMPTY_ART := 120
const EMPTY_ART_ICON := 56
const EMPTY_CTA_H := 120            # dodir
const EMPTY_CTA_VISUAL_H := 100     # panel unutar dodira
const EMPTY_GAP := 28

# --- Chip ---
const CHIP_SIZE := Vector2(489, 176)
const CHIP_H_RESERVED := 176           # v2: badge ide u red pipsa, visina ista
const CHIP_PAD := 14
const CHIP_PAD_SELECTED := 11          # border 2 -> 5, ukupna sirina ista
const CHIP_BORDER := 2
const CHIP_BORDER_SELECTED := 5
const CHIP_ART_FRAME := 128
const CHIP_ART_FRAME_RADIUS := 28      # cvijet; sjeme je krug
const CHIP_ART_WELL_INSET := 8         # ukljucuje border, ne sabiraj dvaput
const CHIP_ART_SEED := 96
const CHIP_ART_FLOWER := 100
const CHIP_BODY_W := 315               # 489 - 2*(14+2) - 128 - 14
const CHIP_LIFT := 3                   # y pomak kad je odabran
const PILL_H := 52
const PILL_GAP := 10
const PILL_ICON := 30
const PRICE_COIN := 32
const BADGE_H := 42
const BADGE_ICON := 28
const FONT_CHIP_NAME := 38
const FONT_PIPS := 34
const FONT_COUNT := 42
const FONT_PRICE := 42
const FONT_BADGE := 34

# --- Tekst ---
const FONT_TAB := 46
const FONT_TAB_COUNT := 42
const FONT_TRADE_LABEL := 42
const FONT_BTN := 46
## Podnaslov na CampButtonu Camp vise ne koristi; Shop ga koristi (ui_shop_buttons).
const FONT_BTN_SUB := 38
const FONT_WARN := 36
const FONT_FEEDBACK := 42
const FONT_EMPTY_TITLE := 46
const FONT_EMPTY_CTA := 42
const FONT_SEASON_NAME := 56
const FONT_SEASON_VALUE := 48
const FONT_UNLOCK := 48
## Emboldening za 800/900 tezine (Nunito u mockupu, default font u igri).
const HEAVY := 0.5
const SEMI := 0.25

# --- SeasonLink ---
const SEASON_W := 1032
const SEASON_PAD := 22
const SEASON_GAP := 20
const SEASON_HEAD_H := 120
const SEASON_PROGRESS_H := 86
const SEASON_PROGRESS_GAP := 24
const SEASON_ICON := 48
const SEASON_ART_FRAME := 56
const SEASON_ART := 40
const SEASON_BAR_H := 18
const SEASON_SPLIT_W := 5
const SEASON_SPLIT_H := 86
const UNLOCK_BTN := Vector2(300, 120)
const UNLOCK_LOCK_ICON := 40
const BURST_SIZE := 520
const BURST_BORDER := 14

# --- Trajanja animacija (sekunde) ---
const T_CHIP_SELECT := 0.12
const T_CHIP_PRESS := 0.08
const T_TAP_POP := 0.09
const T_TAP_FLY := 0.26
const T_TAP_FADE := 0.08
const T_HOLD_RESET := 0.14
const T_AUTO_SWITCH := 0.20
const T_HOLD_STOP := 0.14
const T_TAB_CHANGE := 0.16
const T_TAP_FILL_DRAIN := 0.30
const T_HOLD_RAMP := 0.30
const T_FLY_COIN := 0.26
const T_COIN_BUMP := 0.14
const TAB_SLIDE_PX := 24.0
const T_UNLOCK_BURST := 0.42
const T_UNLOCK_FILL := 0.20
## Poslije bursta ostane toliko prije skoka na Home (da se "unlocked" procita).
const T_UNLOCK_LINGER := 0.45

# --- Stanja (stringovi da smoke testovi mogu porediti) ---
const CHIP_IDLE := "idle"
const CHIP_SELECTED := "selected"
const CHIP_PRESSED := "pressed"
const CHIP_DISABLED := "disabled"

const TRADE_IDLE := "idle"
const TRADE_HOLD := "hold"
const TRADE_WARN := "warn"
const TRADE_HOLD_STOP := "holdstop"
const TRADE_DISABLED := "disabled"

const SEASON_SHORT := "short"
const SEASON_READY := "ready"
const SEASON_UNLOCKING := "unlocking"

const TAB_SEEDS := "seeds"
const TAB_FLOWERS := "flowers"


# --- Pomocne ---

## Visina Trade bara za dato stanje. Stanja s upozorenjem su 224 px.
static func trade_height(state: String) -> int:
	return TRADE_H_STRIP if state == TRADE_WARN or state == TRADE_HOLD_STOP else TRADE_H


## Sekcija je fiksna (v2): ne zavisi od broja tipova, pa nema rupe u sredini stranice.
static func section_height(hero_visible: bool) -> int:
	return SECTION_H if hero_visible else SECTION_H_NO_SEASON


## Visina liste unutar fiksne sekcije — ostatak poslije tabova i Trade bara.
static func grid_budget(state: String, hero_visible: bool = true) -> int:
	var chrome := 2 * (SECTION_PAD + SECTION_BORDER) + TABS_H + 2 * SECTION_INNER_GAP
	return section_height(hero_visible) - chrome - trade_height(state)


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


## "★★☆" — rarity citljiva i bez boje.
static func pips(rarity: int) -> String:
	var r := clampi(rarity, 1, 3)
	return "★".repeat(r) + "☆".repeat(3 - r)


static func alpha(color: Color, a: float) -> Color:
	return Color(color.r, color.g, color.b, a)


static var _tight_fonts: Dictionary = {}


## Font s line-heightom kao u mockupu (`font: 900 46px/1`). Default font ima
## visinu reda ~1,36 em — bez ovoga chip od 176 px ne primi ime + ★ + pillove.
static func tight_font(font_px: int, embolden: float = HEAVY, line_height: float = 1.0) -> Font:
	var key := "%d_%.2f_%.2f" % [font_px, embolden, line_height]
	if _tight_fonts.has(key):
		return _tight_fonts[key] as Font
	var base := ThemeDB.fallback_font
	var fv := FontVariation.new()
	fv.base_font = base
	fv.variation_embolden = embolden
	var extra := base.get_height(font_px) - float(font_px) * line_height
	var trim := int(ceil(extra * 0.5))
	fv.spacing_top = -trim
	fv.spacing_bottom = -trim
	_tight_fonts[key] = fv
	return fv


## Label u Camp stilu: velicina, tezina, boja; bez automatskog skracivanja.
static func style_label(
	label: Label, font_px: int, color: Color, embolden: float = HEAVY, line_height: float = 1.0
) -> void:
	label.add_theme_font_override("font", tight_font(font_px, embolden, line_height))
	label.add_theme_font_size_override("font_size", font_px)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE


# --- StyleBoxFlat fabrike ---

static func _shadow(s: StyleBoxFlat, color: Color, offset: float, blur: int) -> void:
	s.shadow_color = color
	s.shadow_offset = Vector2(0, offset)
	s.shadow_size = blur


## Panel sekcije (StashSection).
static func section_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.WARM_WHITE
	s.border_color = alpha(INK, 0.16)
	s.set_border_width_all(SECTION_BORDER)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_CTA)
	s.set_content_margin_all(SECTION_PAD + SECTION_BORDER)
	_shadow(s, SHADOW, 8, 8)
	return s


## Chip u listi. `state` je jedna od CHIP_* konstanti. `lift` pomjera crtez
## (ne node) prema gore — grid zadrzava raspored.
static func chip_style(state: String, rarity: int, lift: float = 0.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	var bg := rarity_bg(rarity)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	var pad := CHIP_PAD
	match state:
		CHIP_SELECTED:
			s.bg_color = bg.lerp(Color.WHITE, 0.14)
			s.border_color = UiPalette.PEACH
			s.set_border_width_all(CHIP_BORDER_SELECTED)
			pad = CHIP_PAD_SELECTED
			_shadow(s, alpha(SHADOW_CHIP, 0.30), 10, 8)
		CHIP_PRESSED:
			s.bg_color = Color(bg.r * 0.92, bg.g * 0.92, bg.b * 0.92, bg.a)
			s.border_color = UiPalette.PEACH
			s.set_border_width_all(CHIP_BORDER_SELECTED)
			pad = CHIP_PAD_SELECTED
			_shadow(s, SHADOW_CHIP, 3, 3)
		CHIP_DISABLED:
			s.bg_color = UiPalette.RARITY_BG_LOCKED
			s.border_color = DISABLED_EDGE
			s.set_border_width_all(CHIP_BORDER)
			_shadow(s, alpha(SHADOW_CHIP, 0.16), 4, 4)
		_:
			s.bg_color = bg
			s.border_color = rarity_edge(rarity)
			s.set_border_width_all(CHIP_BORDER)
			_shadow(s, SHADOW_CHIP, 6, 6)
	s.set_content_margin_all(pad)
	if lift > 0.0:
		s.expand_margin_top = lift
		s.expand_margin_bottom = -lift
		s.content_margin_top = pad - lift
		s.content_margin_bottom = pad + lift
	return s


## Ink na chipu — jedini slucaj kad se mijenja je "nema zaliha".
static func chip_ink(state: String) -> Color:
	return DISABLED_INK if state == CHIP_DISABLED else INK


## Okvir za art. `seed` = krug cream; cvijet = coin gold zaobljen kvadrat.
static func art_frame_style(seed: bool, side: float, radius: int, border: int = 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.WARM_WHITE if seed else COIN_GOLD
	s.border_color = RIM_EDGE if seed else GOLD_EDGE
	s.set_border_width_all(border)
	s.set_corner_radius_all(int(side / 2.0) if seed else radius)
	s.corner_detail = 16
	return s


## Tamni well u okviru (isti obrazac kao Arena chip).
static func art_well_style(seed: bool, side: float, radius: int, border: int = 2) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = WELL
	s.border_color = WELL_EDGE
	s.set_border_width_all(border)
	s.set_corner_radius_all(int(side / 2.0) if seed else radius)
	s.corner_detail = 16
	return s


## Brojac (sjeme ili kristal) na chipu.
static func count_pill_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = alpha(UiPalette.WARM_WHITE, 0.70)
	s.border_color = alpha(INK, 0.20)
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 2)
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


## Badge za rezervisano sezonsko cvijece. `at_floor` = broj je na granici.
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


## Uvijek "Kept · N / M"; na granici se mijenja samo stil (amber), ne tekst.
static func reserved_badge_text(have: int, need: int, _at_floor: bool = false) -> String:
	return "Kept · %d / %d" % [mini(have, need), need]


## Overlay koji pojacava odabir (iznad chipa, bez hit-testa).
static func select_mark_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = alpha(INK, 0.55)
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
		# Puna boja umjesto alpha podloge — kontrast teksta ne ovisi o pozadini.
		s.bg_color = TAB_INACTIVE_BG
		s.border_color = TAB_INACTIVE_EDGE
		s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.content_margin_left = TAB_PAD
	s.content_margin_right = TAB_PAD
	return s


static func tab_ink(active: bool) -> Color:
	return INK if active else TAB_INK


static func tab_sub_ink(active: bool) -> Color:
	return INK if active else SUB_INK


## Brojac tipova na tabu.
static func tab_count_style(active: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = alpha(UiPalette.WARM_WHITE, 0.80) if active else TAB_COUNT_INACTIVE_BG
	s.border_color = alpha(INK, 0.20)
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS + 2)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s


## "Merge" precica na kraju reda tabova. Vodi na Arena tab.
static func shortcut_style(pressed: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = MINT_EDGE.lerp(UiPalette.MINT, 0.5) if pressed else UiPalette.MINT
	s.border_color = MINT_EDGE
	s.set_border_width_all(3)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	return s


## Panel Trade bara.
static func trade_bar_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.WARM_WHITE
	s.border_color = alpha(INK, 0.18)
	s.set_border_width_all(2)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.set_content_margin_all(TRADE_PAD)
	_shadow(s, SHADOW_CHIP, 6, 6)
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


static func trade_button_ink(state: String) -> Color:
	return TRADE_DISABLED_INK if state == TRADE_DISABLED else INK


## Jedna rijec, bez podnaslova — stanje nose boja i ikona.
static func trade_button_text(state: String) -> String:
	match state:
		TRADE_HOLD:
			return "Trading"
		TRADE_HOLD_STOP:
			return "Sell 1"
	return "Trade"


## Ime ikone na dugmetu ("" = bez ikone). Rjesava ga UiAssets u trade baru.
static func trade_button_icon(state: String) -> String:
	match state:
		TRADE_WARN:
			return "icon_lock"
		TRADE_HOLD_STOP:
			return "icon_hold_stop"
	return ""


## Fill = prodani dio gomile tokom ovog drzanja (sold / (sold + ostatak)).
static func hold_fill_ratio(sold: int, sellable_left: int) -> float:
	var total := sold + sellable_left
	return 0.0 if total <= 0 else clampf(float(sold) / float(total), 0.0, 1.0)


## Fill koji prati drzanje. Kad drzanje stane, fill se zamrzne u HOLD_FREEZE.
static func hold_fill_color(state: String) -> Color:
	return HOLD_FREEZE if state == TRADE_HOLD_STOP else UiPalette.PEACH


## Strip iznad reda u Trade baru. `stop` = amber (drzanje stalo); inace pink.
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
		return "Hold stopped · %s keeps %d" % [season_name, need]
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
	_shadow(s, alpha(SHADOW_CHIP, 0.28), 6, 6)
	return s


## Kartica sljedece sezone (hero, 1032 x 422).
static func season_card_style(season_id: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = season_tint(season_id)
	s.border_color = season_tint_edge(season_id)
	s.set_border_width_all(3)
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_CTA)
	s.set_content_margin_all(SEASON_PAD)
	_shadow(s, SHADOW, 8, 8)
	return s


static func split_line_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = alpha(DARK_INK, 0.22)
	s.set_corner_radius_all(3)
	return s


## Podloga trake napretka na kartici sezone.
static func progress_track_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = alpha(DARK_INK, 0.20)
	s.set_corner_radius_all(int(SEASON_BAR_H / 2.0))
	return s


## Ispuna trake. `coins` = novcici (gold), inace cvijece (krem).
static func progress_fill_style(coins: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = COIN_GOLD if coins else UiPalette.WARM_WHITE
	s.set_corner_radius_all(int(SEASON_BAR_H / 2.0))
	return s


## Unlock dugme. `state` je jedna od SEASON_* konstanti.
static func unlock_button_style(state: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(UiPalette.CORNER_RADIUS_PANEL)
	s.set_border_width_all(3)
	match state:
		SEASON_READY:
			s.bg_color = UiPalette.GOLD
			s.border_color = UNLOCK_GOLD_EDGE
		SEASON_UNLOCKING:
			s.bg_color = COIN_GOLD
			s.border_color = GOLD_EDGE
		_:
			s.bg_color = alpha(UiPalette.WARM_WHITE, 0.55)
			s.border_color = alpha(DARK_INK, 0.30)
	return s


static func unlock_button_ink(state: String) -> Color:
	if state == SEASON_READY or state == SEASON_UNLOCKING:
		return INK
	return SEASON_INK_DIM


## Jedna rijec. Koliko fali vec pisu trake napretka iznad dugmeta.
static func unlock_button_text(state: String) -> String:
	return "Unlocked" if state == SEASON_UNLOCKING else "Unlock"


## Prsten koji pukne kad sezona bude otkljucana (bez blura, samo border).
static func unlock_burst_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = BURST
	s.set_border_width_all(BURST_BORDER)
	s.set_corner_radius_all(int(BURST_SIZE / 2.0))
	s.corner_detail = 24
	return s


## Prazno stanje: okvir za ikonu (mockup je isprekidan; ovdje pun rub).
static func empty_art_style(seed: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = alpha(INK, 0.05)
	s.border_color = alpha(INK, 0.28)
	s.set_border_width_all(4)
	s.set_corner_radius_all(int(EMPTY_ART / 2.0) if seed else 26)
	s.corner_detail = 16
	return s


## CTA u praznom stanju: panel 100 px unutar 120 px dodira ("Play a run ↗").
static func empty_cta_style(pressed: bool = false) -> StyleBoxFlat:
	var s := shortcut_style(pressed)
	s.content_margin_left = 36
	s.content_margin_right = 36
	s.expand_margin_top = -0.5 * (EMPTY_CTA_H - EMPTY_CTA_VISUAL_H)
	s.expand_margin_bottom = -0.5 * (EMPTY_CTA_H - EMPTY_CTA_VISUAL_H)
	return s


## Prsten preko coin chipa u headeru dok drzanje prodaje (bez blura).
static func coin_bump_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = COIN_BUMP
	s.set_border_width_all(COIN_BUMP_RING)
	s.set_corner_radius_all(26)
	return s


## Prazan TradeArt kad nema sta prodati.
static func trade_art_empty_style(seed: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = alpha(INK, 0.05)
	s.border_color = alpha(INK, 0.28)
	s.set_border_width_all(4)
	s.set_corner_radius_all(int(TRADE_ART / 2.0) if seed else 24)
	s.corner_detail = 16
	return s
