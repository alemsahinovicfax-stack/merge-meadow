extends RefCounted
class_name UiHome
## Tokeni i StyleBoxFlat fabrike za Home — scenu biranja sezone.
## Generisano iz design_handoff_home/godot/home_export.json (smjer 1a Season Trail).
## Sve mjere su u px baze 1080 x 1920 i prenose se 1:1.

# ── Paleta ────────────────────────────────────────────────────────────────────
const MINT             := Color("a8e6cf")
const MINT_EDGE        := Color("7fc9ac")
const LAVENDER         := Color("d4a5ff")
const LAVENDER_EDGE    := Color("aa84cc")
const PEACH            := Color("ffb88c")
const PEACH_EDGE       := Color("e8a374")
const COIN_GOLD        := Color("ffd56b")
const COIN_GOLD_EDGE   := Color("d6a82f")
const UI_GOLD          := Color("e8c44a")
const UI_GOLD_EDGE     := Color("ba9d3b")
const PRICE_BG         := Color("ffe8b8")
const WARM_WHITE       := Color("fff8f0")
const ACTIVE_RIM       := Color("fff6d6")
const INK              := Color("1a1a14")
const INK_SOFT         := Color("3d3d33")
const INK_DISABLED     := Color("44443a")
const OUTLINE          := Color("2d3436")
const CHROME           := Color("1a241e")
const WELL             := Color("22342a")
const WELL_EDGE        := Color("16211b")
const GIFT_READY       := Color("ffc77a")
const GIFT_TAKEN       := Color("6e7a6b")
const GIFT_TAKEN_EDGE  := Color("4e5a4c")
const PAGE_BG          := Color("2e4733")  # usklađeno s Campom; danas je u kodu #243329

# ── Layout ────────────────────────────────────────────────────────────────────
const BASE            := Vector2i(1080, 1920)
const HEADER_H        := 143
const FOOTER_H        := 180
const PAGE            := Vector2i(1080, 1597)
const PAGE_PADDING    := 24
const BLOCK_GAP       := 16
const TOP_ROW_H       := 130
const PROGRESS_W      := 420
const STAGE           := Vector2i(1032, 1231)
const CARD_GAP        := 14
const PLAY_H          := 156
const MIN_TOUCH       := 120
const MIN_TEXT        := 38
const MIN_NUMBER      := 44

## Visina kartice po varijanti.
const CARD_H := {
	"collapsed": 128,
	"expanded": 440,
	"nextlock": 320,
	"poster": 644,
	"premium": 556,
	"hero": 965,          # samo smjer 1b Season Shelf
}

## Veličina fonta imena sezone po varijanti.
const NAME_SIZE := {
	"collapsed": 48, "expanded": 64, "nextlock": 52,
	"poster": 64, "premium": 60, "hero": 68,
}

# ── Mood boje sezona (izvor: season_card_contrast.gd) ─────────────────────────
const SEASON_MOOD := {
	"country_bloom": Color("a8e6cf"),
	"frost_orchard": Color("c5d5e8"),
	"lantern_meadow": Color("c9b8e0"),
	"amber_canopy": Color("e8c48a"),
	"moonlit_warren": Color("3d3a6b"),
	"coral_tide": Color("e8a090"),
	"starfall_glade": Color("6b5b95"),
	"ember_fen": Color("c45c26"),
}

## Sezone kojima naslov ide u cream, ne u tamni ink.
const SEASON_TITLE_CREAM := ["moonlit_warren", "starfall_glade", "ember_fen"]


# ── Izvedene boje ─────────────────────────────────────────────────────────────
## Fill zaključane kartice (iza next locka).
static func locked_fill(mood: Color) -> Color:
	return Color(mood.r * 0.55, mood.g * 0.55, mood.b * 0.55).lerp(PAGE_BG, 0.45)

## Fill coming-soon kartice (Ember Fen).
static func soon_fill(mood: Color) -> Color:
	return mood.lerp(PAGE_BG, 0.44)

## Border kartice = mood x 0.8.
static func card_border(mood: Color) -> Color:
	return Color(mood.r * 0.8, mood.g * 0.8, mood.b * 0.8)

## Naslov na kartici — tamni ink ili cream, po sezoni.
static func title_color(season_id: String) -> Color:
	return ACTIVE_RIM if season_id in SEASON_TITLE_CREAM else INK

## Sekundarni tekst na kartici.
static func sub_color(season_id: String) -> Color:
	return Color(1, 0.965, 0.839, 0.90) if season_id in SEASON_TITLE_CREAM else INK_SOFT


# ── StyleBoxFlat fabrike ──────────────────────────────────────────────────────
static func _box(fill: Color, radius: int, border: int = 0, border_color: Color = Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.set_corner_radius_all(radius)
	if border > 0:
		sb.set_border_width_all(border)
		sb.border_color = border_color
	return sb

static func _shadow(sb: StyleBoxFlat, size: int, offset_y: int, color: Color) -> StyleBoxFlat:
	sb.shadow_size = size
	sb.shadow_offset = Vector2(0, offset_y)
	sb.shadow_color = color
	return sb

## Kartica sezone. state: active | unlocked | next | locked | soon
static func season_card(season_id: String, state: String) -> StyleBoxFlat:
	var mood: Color = SEASON_MOOD.get(season_id, MINT)
	var fill := mood
	var border := 3
	var border_color := card_border(mood)
	match state:
		"locked":
			fill = locked_fill(mood)
			border_color = Color(1, 0.965, 0.839, 0.34)
		"soon":
			fill = soon_fill(mood)
			border_color = Color(1, 0.965, 0.839, 0.34)
		"active":
			border = 6
			border_color = ACTIVE_RIM
	var sb := _box(fill, 26, border, border_color)
	if state == "active":
		return _shadow(sb, 22, 10, Color(0.078, 0.102, 0.086, 0.38))
	return _shadow(sb, 16, 8, Color(0.078, 0.102, 0.086, 0.26))

## Play dugme (peach CTA).
static func play_button() -> StyleBoxFlat:
	return _shadow(_box(PEACH, 26, 4, PEACH_EDGE), 16, 8, Color(0.078, 0.102, 0.086, 0.30))

## Unlock dugme. state: blocked | ready | spent
static func unlock_button(state: String) -> StyleBoxFlat:
	match state:
		"ready":
			return _box(UI_GOLD, 20, 3, UI_GOLD_EDGE)
		"spent":
			return _box(COIN_GOLD, 20, 3, COIN_GOLD_EDGE)
		_:
			return _box(Color(1, 0.973, 0.941, 0.55), 20, 3, Color(0.102, 0.102, 0.078, 0.30))

## Boja teksta na Unlock dugmetu za isto stanje.
static func unlock_ink(state: String) -> Color:
	return OUTLINE if state in ["ready", "spent"] else INK_DISABLED

## Premium CTA. state: premium | busy | soon | owned
static func premium_cta(state: String) -> StyleBoxFlat:
	match state:
		"premium":
			return _box(LAVENDER, 20, 3, LAVENDER_EDGE)
		"busy":
			return _box(Color(1, 0.973, 0.941, 0.55), 20, 3, Color(0.102, 0.102, 0.078, 0.30))
		"soon":
			return _box(Color(1, 0.973, 0.941, 0.16), 20, 3, Color(1, 0.965, 0.839, 0.40))
		_:
			return _box(Color(1, 0.973, 0.941, 0.20), 20, 3, Color(1, 0.965, 0.839, 0.40))

## ActiveBadge / "Playing now".
static func active_badge() -> StyleBoxFlat:
	return _box(ACTIVE_RIM, 16, 3, COIN_GOLD_EDGE)

## NewBadge nakon otključavanja (živi ~3 s).
static func new_badge() -> StyleBoxFlat:
	return _box(MINT, 16, 3, MINT_EDGE)

## PriceTag — cijena je proizvoljan string iz store-a.
static func price_tag() -> StyleBoxFlat:
	return _box(PRICE_BG, 18, 3, COIN_GOLD_EDGE)

## Okvir cvijeta u rosteru (gold rim + tamni well kao sjemenka u Areni).
static func art_frame(size: int = 116) -> StyleBoxFlat:
	return _box(COIN_GOLD, int(round(size * 0.22)), 3, COIN_GOLD_EDGE)

static func art_well(size: int = 116) -> StyleBoxFlat:
	return _box(WELL, int(round(size * 0.15)), 2, WELL_EDGE)

## Prozirni panel na tamnoj pozadini (PremiumSection, ProgressIndicator).
static func hub_panel(radius: int = 20) -> StyleBoxFlat:
	return _box(Color(1, 0.973, 0.941, 0.12), radius, 2, Color(1, 0.973, 0.941, 0.30))

## Panel rostera unutar kartice — svjetlija ili tamnija po mood boji.
static func roster_panel(season_id: String) -> StyleBoxFlat:
	if season_id in SEASON_TITLE_CREAM:
		return _box(Color(1, 0.973, 0.941, 0.13), 20, 2, Color(1, 0.973, 0.941, 0.28))
	return _box(Color(0.102, 0.102, 0.078, 0.13), 20, 2, Color(0.102, 0.102, 0.078, 0.22))

## Daily gift kartica. taken = preuzeto danas.
static func daily_gift(taken: bool) -> StyleBoxFlat:
	var sb := _box(GIFT_TAKEN if taken else GIFT_READY, 20, 3, GIFT_TAKEN_EDGE if taken else COIN_GOLD_EDGE)
	return _shadow(sb, 14, 6, Color(0.078, 0.102, 0.086, 0.26))

## Tutorial hint iznad Playa.
static func tutorial_hint() -> StyleBoxFlat:
	return _shadow(_box(ACTIVE_RIM, 20, 3, COIN_GOLD_EDGE), 16, 8, Color(0.078, 0.102, 0.086, 0.30))

## Segment ProgressIndicatora (2 / 4 free seasons).
static func progress_segment(filled: bool) -> StyleBoxFlat:
	if filled:
		return _box(MINT, 9, 2, MINT_EDGE)
	return _box(Color(1, 0.973, 0.941, 0.22), 9)

## Traka napretka: track + fill. kind: coins | flowers
static func bar_track(season_id: String) -> StyleBoxFlat:
	if season_id in SEASON_TITLE_CREAM:
		return _box(Color(1, 0.973, 0.941, 0.22), 13)
	return _box(Color(0.102, 0.102, 0.078, 0.20), 13)

static func bar_fill(kind: String) -> StyleBoxFlat:
	return _box(COIN_GOLD if kind == "coins" else WARM_WHITE, 13)


# ── Animacije (trajanja iz animations tabele) ────────────────────────────────
const ANIM := {
	"card_expand": 0.22,
	"scroll_to_focus": 0.25,
	"progress_bar": 0.35,
	"unlock_burst": 0.9,
	"unlock_button": 0.18,
	"new_badge_in": 0.3,
	"new_badge_hold": 3.0,
	"gift_pulse": 1.2,
	"press": 0.08,
	"purchasing_pulse": 0.8,
}

## Kartica se otvara / zatvara — jedini layout tween na sceni.
static func tween_card_height(card: Control, to_h: int) -> Tween:
	var t := card.create_tween()
	t.tween_property(card, "custom_minimum_size:y", float(to_h), ANIM.card_expand) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	return t

## Unlock prsten: Sprite2D, samo scale + alpha, nula redrawa.
## Vidi cd_capability_test/t5_perf/cheap_pulse.gd i pulse_ring.png.
static func tween_unlock_burst(ring: Sprite2D) -> Tween:
	ring.scale = Vector2(0.6, 0.6)
	ring.modulate.a = 0.9
	var t := ring.create_tween().set_parallel(true)
	t.tween_property(ring, "scale", Vector2(1.25, 1.25), ANIM.unlock_burst).set_ease(Tween.EASE_OUT)
	t.tween_property(ring, "modulate:a", 0.0, ANIM.unlock_burst).set_ease(Tween.EASE_OUT)
	return t
