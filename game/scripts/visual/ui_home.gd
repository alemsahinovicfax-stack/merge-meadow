class_name UiHome
extends RefCounted

## Home — scena biranja sezone (design_handoff_home, smjer 1a Season Trail).
## Tokeni i StyleBoxFlat fabrike iz godot/home_export.json + HomeScreen.dc.html.
## Gdje se ui_home.gd iz paketa i HTML razlikuju, prati se HTML crtez.
## Mjere su u px baze 1080 x 1920. Mood boje dolaze iz SeasonCardContrast;
## zakljucane / coming-soon boje i tamni ili svijetli tekst se RACUNAJU iz mood boje.

# --- Paleta ---
const MINT := Color("#A8E6CF")
const MINT_EDGE := Color("#7FC9AC")
const LAVENDER := Color("#D4A5FF")
const LAVENDER_EDGE := Color("#AA84CC")
const PEACH := Color("#FFB88C")
const PEACH_EDGE := Color("#E8A374")
const COIN_GOLD := Color("#FFD56B")
const COIN_GOLD_EDGE := Color("#D6A82F")
const UI_GOLD := Color("#E8C44A")
const UI_GOLD_EDGE := Color("#BA9D3B")
const PRICE_BG := Color("#FFE8B8")
const WARM_WHITE := Color("#FFF8F0")
const RIM := Color("#FFF6D6")            # active_rim + cream tekst na tamnoj kartici
const DARK_INK := Color("#1A1A14")       # naslov na svijetloj kartici
const SUB_INK := Color("#3D3D33")
const INK := Color("#2D3436")            # tekst na zlatnim / peach dugmadima
const INK_DISABLED := Color("#44443A")
const WELL := Color("#22342A")
const WELL_EDGE := Color("#16211B")
const GIFT_READY := Color("#FFC77A")
const GIFT_TAKEN := Color("#6E7A6B")
const GIFT_TAKEN_EDGE := Color("#4E5A4C")
const GIFT_BOX_TAKEN := Color("#5C6759")
const GIFT_BOX_TAKEN_EDGE := Color("#48523F")
const GIFT_RIBBON_TAKEN := Color("#8A9487")
const PAGE_BG := Color("#2E4733")        # isto kao Camp (odluka 2026-09-21)
const BURST := Color(1.0, 0.961, 0.820, 0.55)
const SUB_ON_DARK := Color(1.0, 0.965, 0.839, 0.90)
const SHADOW := Color(0.078, 0.102, 0.086, 0.26)
const SHADOW_ACTIVE := Color(0.078, 0.102, 0.086, 0.38)
const SHADOW_CTA := Color(0.078, 0.102, 0.086, 0.30)
const LUM_SPLIT := 0.45                  # isto kao SeasonCardContrast.title_color

# --- Layout ---
const PAGE_PAD := 24
const BLOCK_GAP := 16
const TOP_ROW_H := 130
const PROGRESS_W := 420
const CARD_W := 1032
const CARD_GAP := 14
const PLAY_H := 156
const PLAY_CHIP_H := 88
const HINT_BOTTOM := PAGE_PAD + PLAY_H + BLOCK_GAP   # 196

## Varijante kartice: osnovna visina, padding, razmak, font imena, visina glave.
const COLLAPSED := "collapsed"
const EXPANDED := "expanded"
const NEXTLOCK := "nextlock"
const POSTER := "poster"
const PREMIUM := "premium"
const CARD_H := {COLLAPSED: 128, EXPANDED: 440, NEXTLOCK: 320, POSTER: 644, PREMIUM: 556}
const CARD_PAD := {COLLAPSED: 18, EXPANDED: 18, NEXTLOCK: 16, POSTER: 18, PREMIUM: 18}
const CARD_SEP := {COLLAPSED: 14, EXPANDED: 14, NEXTLOCK: 12, POSTER: 14, PREMIUM: 14}
const NAME_PX := {COLLAPSED: 48, EXPANDED: 64, NEXTLOCK: 52, POSTER: 64, PREMIUM: 60}
const HEAD_H := {COLLAPSED: 0, EXPANDED: 132, NEXTLOCK: 72, POSTER: 132, PREMIUM: 132}
## Zatvorena kartica: 48 px ime + 6 + 40 px status = 94 px sadrzaja u 128 px.
const COLLAPSED_TEXT_H := 94
const CARD_RADIUS := 26
const CARD_BORDER := 3
const CARD_BORDER_ACTIVE := 6

## Stanja kartice.
const ST_ACTIVE := "active"
const ST_UNLOCKED := "unlocked"
const ST_NEXT := "next"
const ST_LOCKED := "locked"
const ST_READY := "ready"
const ST_UNLOCKING := "unlocking"
const ST_PREMIUM := "premium"
const ST_OWNED := "owned"
const ST_BUSY := "busy"
const ST_SOON := "soon"

# --- Djelovi kartice ---
const LOCK_BOX := 84
const LOCK_ICON := 48
const CHIP_H := 60
const BADGE_ROW_H := 72
const STATUS_CHIP_H := 76
const PRICE_TAG_H := 96
const OPEN_BTN := Vector2(360, 124)
const TAGLINE_H := 48
const ROSTER_PAD_V := 14
const ROSTER_PAD_H := 12
const ROSTER_BORDER := 2
const ROSTER_GAP := 12
const ROSTER_SLOT_GAP := 10
const ART_MAX := 116
const ART_MIN := 64
const PIPS_PX := 38
const UNLOCK_BTN_H := 140
const CTA_H := 130
const BAR_H_POSTER := 26
const BAR_H_COMPACT := 20
const BURST_DIAMETER := 760.0
const BURST_BORDER := 16.0

# --- Premium sekcija / TopRow ---
const PREMIUM_ROW_H := 155
const PREMIUM_HEAD_H := 90
const PREMIUM_DOT := 56
const SEGMENT_H := 18
const GIFT_ICON := 84
const RIBBON := 16

# --- Fontovi (Nunito 900 / 800 / 700 -> emboldening na default fontu) ---
const W_BLACK := 0.5
const W_BOLD := 0.38
const W_REGULAR := 0.25
const FONT_EYEBROW := 38
const FONT_STATUS := 40
const FONT_TAGLINE := 42
const FONT_CHIP := 38
const FONT_BADGE_ROW := 40
const FONT_STATUS_CHIP := 44
const FONT_STATUS_CHIP_NEXT := 40
const FONT_PRICE := 52
const FONT_OPEN := 42
const FONT_NEED := 44
const FONT_NEED_COMPACT := 40
const FONT_VALUE := 56
const FONT_VALUE_COMPACT := 48
const FONT_CAPTION := 38
const FONT_UNLOCK := 52
const FONT_BTN_SUB := 38
const FONT_CTA := 48
const FONT_SECTION_TITLE := 48
const FONT_SECTION_NOTE := 38
const FONT_CHEVRON := 40
const FONT_PROGRESS_NUM := 56
const FONT_PROGRESS_LABEL := 38
const FONT_GIFT_TITLE := 38
const FONT_GIFT_SUB := 48
const FONT_PLAY := 64
const FONT_PLAY_CHIP := 40
const FONT_HINT := 40

# --- Animacije (home_export.json -> animations) ---
const T_CARD := 0.22
const T_SCROLL := 0.25
const T_BAR := 0.35
const T_BURST := 0.9
const T_NEW_IN := 0.3
const T_NEW_HOLD := 3.0
const T_BUSY_PULSE := 0.8
const T_BOUNCE := 0.22


# --- Boje sezone ---

static func mood(season_id: String) -> Color:
	return SeasonCardContrast.mood_color(season_id)


## Svijetla mood boja nosi tamni tekst; tamna (Moonlit, Starfall, Ember) cream.
static func is_light(season_id: String) -> bool:
	var m := mood(season_id)
	return 0.2126 * m.r + 0.7152 * m.g + 0.0722 * m.b >= LUM_SPLIT


static func scale_rgb(c: Color, f: float) -> Color:
	return Color(c.r * f, c.g * f, c.b * f, c.a)


## Iza next locka: mood x 0,55 pa 45 % prema pozadini.
static func locked_fill(m: Color) -> Color:
	return scale_rgb(m, 0.55).lerp(PAGE_BG, 0.45)


## Coming soon (Ember Fen): mood 44 % prema pozadini.
static func soon_fill(m: Color) -> Color:
	return m.lerp(PAGE_BG, 0.44)


static func card_fill(season_id: String, state: String) -> Color:
	var m := mood(season_id)
	if state == ST_LOCKED:
		return locked_fill(m)
	if state == ST_SOON:
		return soon_fill(m)
	return m


## Tekst je tamni samo na svijetloj, punoj mood boji.
static func card_light(season_id: String, state: String) -> bool:
	if state == ST_LOCKED or state == ST_SOON:
		return false
	return is_light(season_id)


static func ink(light: bool) -> Color:
	return DARK_INK if light else RIM


static func sub_ink(light: bool) -> Color:
	return SUB_INK if light else SUB_ON_DARK


static func panel_fill(light: bool) -> Color:
	return Color(0.102, 0.102, 0.078, 0.13) if light else Color(1.0, 0.973, 0.941, 0.13)


static func panel_edge(light: bool) -> Color:
	return Color(0.102, 0.102, 0.078, 0.22) if light else Color(1.0, 0.973, 0.941, 0.28)


static func cream_fill(light: bool) -> Color:
	return Color(1.0, 0.973, 0.941, 0.74) if light else Color(1.0, 0.973, 0.941, 0.20)


static func cream_edge(light: bool) -> Color:
	return Color(0.102, 0.102, 0.078, 0.26) if light else Color(1.0, 0.973, 0.941, 0.40)


static func bar_track(light: bool) -> Color:
	return Color(0.102, 0.102, 0.078, 0.20) if light else Color(1.0, 0.973, 0.941, 0.22)


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


## Kartica sezone. HTML je border-box: padding + border = unutrasnji razmak.
## Zatvorena kartica vertikalno centrira 94 px teksta u 128 px.
static func season_card(season_id: String, state: String, variant: String, active: bool) -> StyleBoxFlat:
	var border := CARD_BORDER_ACTIVE if active else CARD_BORDER
	var edge := RIM
	if not active:
		if state == ST_LOCKED or state == ST_SOON:
			edge = Color(1.0, 0.965, 0.839, 0.34)
		else:
			edge = scale_rgb(mood(season_id), 0.8)
	var s := box(card_fill(season_id, state), CARD_RADIUS, border, edge)
	var p := float(CARD_PAD[variant])
	var pv := p
	if variant == COLLAPSED:
		pv = maxf((CARD_H[COLLAPSED] - COLLAPSED_TEXT_H) * 0.5 - border, 0.0)
	pad(s, p + border, pv + border)
	if active:
		return shadow(s, SHADOW_ACTIVE, 10, 22)
	return shadow(s, SHADOW, 8, 16)


## "Playing now" / "New" cip u glavi otvorene kartice (60 px).
static func eyebrow_chip(fill: Color, edge: Color) -> StyleBoxFlat:
	return pad(box(fill, 16, 3, edge), 22, 0)


## "Playing now" desno u zatvorenoj kartici (72 px).
static func badge_row() -> StyleBoxFlat:
	return pad(box(RIM, 18, 3, COIN_GOLD_EDGE), 24, 0)


static func status_chip(light: bool) -> StyleBoxFlat:
	return pad(box(cream_fill(light), 18, 2, cream_edge(light)), 22, 0)


static func price_tag() -> StyleBoxFlat:
	return pad(box(PRICE_BG, 18, 3, COIN_GOLD_EDGE), 26, 0)


static func lock_box() -> StyleBoxFlat:
	return box(Color(0.102, 0.102, 0.078, 0.26), 22, 2, Color(1.0, 0.965, 0.839, 0.34))


static func open_button(light: bool) -> StyleBoxFlat:
	return box(cream_fill(light), 20, 3, cream_edge(light))


static func roster_panel(light: bool) -> StyleBoxFlat:
	return pad(
		box(panel_fill(light), 20, ROSTER_BORDER, panel_edge(light)),
		ROSTER_PAD_H + ROSTER_BORDER, ROSTER_PAD_V + ROSTER_BORDER
	)


## Unlock dugme: blocked (mutno, ne reaguje) | ready (UI gold) | spent (coin gold).
static func unlock_button(state: String) -> StyleBoxFlat:
	match state:
		ST_READY:
			return box(UI_GOLD, 20, 3, UI_GOLD_EDGE)
		ST_UNLOCKING:
			return box(COIN_GOLD, 20, 3, COIN_GOLD_EDGE)
		_:
			return box(Color(1.0, 0.973, 0.941, 0.55), 20, 3, Color(0.102, 0.102, 0.078, 0.30))


static func unlock_ink(state: String) -> Color:
	return INK if state == ST_READY or state == ST_UNLOCKING else INK_DISABLED


## Premium CTA: premium (lavender) | busy (mutno) | soon (tiho) | owned (cream).
static func cta_button(state: String, light: bool) -> StyleBoxFlat:
	match state:
		ST_PREMIUM:
			return box(LAVENDER, 20, 3, LAVENDER_EDGE)
		ST_BUSY:
			return box(Color(1.0, 0.973, 0.941, 0.55), 20, 3, Color(0.102, 0.102, 0.078, 0.30))
		ST_SOON:
			return box(Color(1.0, 0.973, 0.941, 0.16), 20, 3, Color(1.0, 0.965, 0.839, 0.40))
		_:
			return box(cream_fill(light), 20, 3, cream_edge(light))


static func cta_ink(state: String, light: bool) -> Color:
	match state:
		ST_PREMIUM:
			return INK
		ST_BUSY:
			return INK_DISABLED
		ST_SOON:
			return RIM
		_:
			return ink(light)


## Okvir cvijeta u rosteru i gateu: coin gold + tamni well (kao Arena / Camp).
static func art_frame(side: float) -> StyleBoxFlat:
	return box(COIN_GOLD, int(round(side * 0.22)), 3, COIN_GOLD_EDGE)


static func art_well(side: float) -> StyleBoxFlat:
	return box(WELL, int(round(side * 0.15)), 2, WELL_EDGE)


## Premium sekcija i ProgressIndicator: providan panel na tamnoj pozadini.
static func hub_panel(radius: int) -> StyleBoxFlat:
	return pad(box(Color(1.0, 0.973, 0.941, 0.12), radius, 2, Color(1.0, 0.973, 0.941, 0.30)), 26, 0)


static func premium_dot(season_id: String) -> StyleBoxFlat:
	return box(mood(season_id), 16, 2, Color(1.0, 0.973, 0.941, 0.34))


static func chevron() -> StyleBoxFlat:
	return pad(box(Color(1.0, 0.973, 0.941, 0.16), 18, 2, Color(1.0, 0.965, 0.839, 0.40)), 24, 0)


static func progress_segment(filled: bool) -> StyleBoxFlat:
	if filled:
		return box(MINT, 9, 2, MINT_EDGE)
	return box(Color(1.0, 0.973, 0.941, 0.22), 9)


static func daily_gift(taken: bool) -> StyleBoxFlat:
	var s := box(GIFT_TAKEN if taken else GIFT_READY, 20, 3, GIFT_TAKEN_EDGE if taken else COIN_GOLD_EDGE)
	pad(s, 27, 0)
	return shadow(s, SHADOW, 6, 14)


static func gift_box(taken: bool) -> StyleBoxFlat:
	return box(
		GIFT_BOX_TAKEN if taken else COIN_GOLD, 18, 3,
		GIFT_BOX_TAKEN_EDGE if taken else COIN_GOLD_EDGE
	)


static func play_button(pressed: bool) -> StyleBoxFlat:
	var s := box(PEACH.darkened(0.06) if pressed else PEACH, 26, 4, PEACH_EDGE)
	pad(s, 36, 0)
	return shadow(s, SHADOW_CTA, 8, 16)


static func play_chip() -> StyleBoxFlat:
	return pad(box(Color(1.0, 0.973, 0.941, 0.80), 18, 2, Color(0.176, 0.204, 0.212, 0.26)), 28, 0)


static func tutorial_hint() -> StyleBoxFlat:
	var s := pad(box(RIM, 20, 3, COIN_GOLD_EDGE), 27, 23)
	return shadow(s, SHADOW_CTA, 8, 16)


# --- Tekst ---

static func style(label: Label, px: int, color: Color, weight: float = W_BLACK) -> void:
	UiCamp.style_label(label, px, color, weight)


## Label s "…" kad tekst ne stane (ime sezone, tagline, status).
static func ellipsis(label: Label) -> void:
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.clip_text = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
