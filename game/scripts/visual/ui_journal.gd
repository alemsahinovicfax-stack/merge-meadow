class_name UiJournal
extends RefCounted

## Journal / Bloom Album — Claude Design handoff (design_handoff_journal/README.md).
## Sve mjere u px baze 1080x1920, prenos 1:1. Smjer 1a (Varijanta A, pastel hub) je default.
## Ide u game/scripts/visual/ui_journal.gd. Isti obrazac kao ui_chrome.gd / ui_camp.gd.

# --- Boje (postojeće iz ui_palette / ui_chrome / ui_camp, ništa novo osim CAPTION_INK iz Camp ScrollHint) ---
const PAGE_BG := Color("#FFF8F0")          # UiPalette.WARM_WHITE — Varijanta A
const PAGE_BG_B := Color("#2E4733")        # Camp MeadowBg — Varijanta B
const INK := Color("#2D3436")              # UiPalette.OUTLINE
const SUB_INK := Color("#555C5E")          # 6,5:1 na krem
const CAPTION_INK := Color("#3F4547")      # ≥ 6,2:1 na sve tri rarity boje
const DISABLED_INK := Color("#5C5C58")     # 5,3:1 na RARITY_BG_LOCKED
const RARITY_EDGE_1 := Color("#93AAC0")    # RARITY_BG_1 × 0,8
const RARITY_EDGE_2 := Color("#B39DCC")
const RARITY_EDGE_3 := Color("#CCBA93")
const RARITY_EDGE_LOCKED := Color("#B6B6B2")
const RIM := Color("#FFF8F0")
const RIM_EDGE := Color("#CBC2B6")
const WELL := Color("#22342A")
const WELL_EDGE := Color("#16211B")
const COIN_GOLD := Color("#FFD56B")
const GOLD_EDGE := Color("#D6A82F")
const NEW_PINK := Color("#FFCCD5")         # = UiChrome.BADGE_PINK — "novo" svuda
const CHROME_DEEP := Color("#1A241E")

# --- Page ---
const PAGE_H := 1633
const PAD_X := 24
const HEAD_H := 175            # A: 30 + naslov 64 + 8 + summary 46 + 24 + divider 3
const HEAD_H_B := 174
const TITLE_FONT := 60
const SUMMARY_FONT := 38
const ACCENT_W := 10
const ACCENT_H := 56

# --- Lista ---
const LIST_TOP := 16
const ROW_H := 200
const ROW_GAP := 20
const SEASON_HEADER_H := 60
const SEASON_HEADER_GAP := 20   # header → prvi red
const SEASON_GAP := 36          # zadnji red → sljedeći header
const LIST_BOTTOM := 24
const SEASON_NAME_FONT := 40
const SEASON_COUNT_FONT := 36
const SEASON_LOCK_ICON := 34
const AUTO_SCROLL_LEAD := 330   # 1,5 × (ROW_H + ROW_GAP)

# --- BloomRow ---
const ROW_W_A := 1032
const ROW_W_B := 992
const NAME_FONT := 44
const STARS_FONT := 32
const CAPTION_FONT := 38
const CAPTION_LINE := 45
const CAPTION_MAX_LINES := 2
const INFO_GAP := 12
const NAME_STARS_GAP := 16
const ROW_INNER_GAP := 24       # InfoColumn ↔ TierStrip

# --- TierSlot ---
const SLOT := 112
const SLOT_GAP := 18
const WELL_INSET := 10
const ART := 88                 # box za FlowerAssets / CampPlantDraw (draw_fitted_plant, side = 88)
const TIER_LABEL_FONT := 32
const TIER_LABEL_GAP := 8
const HALO_GROW := 9

# --- NewBadge ---
const NEW_BADGE_H := 46
const NEW_BADGE_FONT := 30
const NEW_BADGE_SPACING := 2    # ~0,06em
const NEW_BADGE_OFFSET := Vector2(28, -18)   # od gornjeg lijevog ugla reda (izvan panela)

# --- Journal tab ---
const TAB_DOT := 30             # samo za opciju 1f; 1e = postojeći HubTab badge

# --- Golden Album ---
const GOLD_FRAME_INSET := 12
const GOLD_EDGE_W := 13         # 3 edge + 7 gold + 3 edge
const GOLD_BAND_W := 7
const PLAQUE_H := 92
const PLAQUE_FONT := 56

const CAPTION := {
	"locked": "Keep playing to discover this bloom.",
	"seen": "Spotted in runs — merge to T2, then Keep in Album.",
	"album_t2": "In your Album (T2 bloom). Merge to T3 for crystal.",
	"album_t3": "Crystal bloom saved in Album!",
}
const NEW_CAPTION := {
	1: "New discovery!",
	2: "New bloom kept in Album!",
	3: "New crystal in Album!",
}


static func caption_for(entry: Dictionary, show_new: bool) -> String:
	var state := str(entry.get("state", "locked"))
	var new_tier := int(entry.get("new_tier", 0))
	if show_new and state != "locked" and new_tier > 0:
		return str(NEW_CAPTION.get(clampi(new_tier, 1, 3), CAPTION[state]))
	return str(CAPTION.get(state, CAPTION["locked"]))


## "Album: 5 blooms kept · 4 spotted" — kept = album_t2 + album_t3, spotted = samo seen.
static func summary_text(entries: Array) -> String:
	var kept := 0
	var spotted := 0
	for e in entries:
		match str(e.get("state", "")):
			"album_t2", "album_t3":
				kept += 1
			"seen":
				spotted += 1
	return "Album: %d %s kept · %d spotted" % [kept, "bloom" if kept == 1 else "blooms", spotted]


## Koliko tiera je popunjeno (0–3). T1 je popunjen za svako stanje osim locked (isto kao danas).
static func filled_tiers(state: String) -> int:
	match state:
		"album_t3":
			return 3
		"album_t2":
			return 2
		"seen":
			return 1
	return 0


static func rarity_stars(rarity: int) -> String:
	var r := clampi(rarity, 1, 3)
	return "★".repeat(r) + "☆".repeat(3 - r)


static func row_style(rarity: int, locked: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.rarity_bg_color(rarity, locked)
	s.border_color = RARITY_EDGE_LOCKED if locked else [RARITY_EDGE_1, RARITY_EDGE_2, RARITY_EDGE_3][clampi(rarity, 1, 3) - 1]
	s.set_border_width_all(3)
	s.set_corner_radius_all(26)
	s.content_margin_left = 31.0
	s.content_margin_right = 27.0
	s.content_margin_top = 23.0
	s.content_margin_bottom = 23.0
	s.shadow_color = _a(INK, 0.12)
	s.shadow_size = 4
	s.shadow_offset = Vector2(0, 4)
	return s


## kind: "empty" | "bloom" (T1/T2) | "crystal" (T3)
static func tier_frame_style(kind: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	match kind:
		"bloom":
			s.bg_color = RIM
			s.border_color = RIM_EDGE
			s.set_border_width_all(3)
			s.set_corner_radius_all(SLOT / 2)
		"crystal":
			s.bg_color = COIN_GOLD
			s.border_color = GOLD_EDGE
			s.set_border_width_all(3)
			s.set_corner_radius_all(30)
		_:
			s.bg_color = _a(INK, 0.05)
			s.border_color = _a(INK, 0.32)
			s.set_border_width_all(4)
			s.set_corner_radius_all(SLOT / 2)
	return s


static func tier_well_style(crystal: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = WELL
	s.border_color = WELL_EDGE
	s.set_border_width_all(2)
	s.set_corner_radius_all(20 if crystal else (SLOT - WELL_INSET * 2) / 2)
	return s


static func tier_halo_style(crystal: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = NEW_PINK
	s.border_color = INK
	s.set_border_width_all(3)
	s.set_corner_radius_all(30 + HALO_GROW if crystal else (SLOT + HALO_GROW * 2) / 2)
	return s


static func new_badge_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = NEW_PINK
	s.border_color = INK
	s.set_border_width_all(3)
	s.set_corner_radius_all(NEW_BADGE_H / 2)
	s.content_margin_left = 21.0
	s.content_margin_right = 21.0
	s.shadow_color = _a(INK, 0.22)
	s.shadow_size = 1
	s.shadow_offset = Vector2(0, 3)
	return s


static func flat(color: Color, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	return s


## Varijanta B — krem "stranica albuma" (isti recept kao Camp StashSection).
static func album_page_style(golden: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PAGE_BG
	if golden:
		s.border_color = GOLD_EDGE
		s.set_border_width_all(GOLD_EDGE_W)
		s.set_corner_radius_all(34)
	else:
		s.border_color = _a(INK, 0.16)
		s.set_border_width_all(2)
		s.set_corner_radius_all(26)
	s.shadow_color = Color(0.078, 0.125, 0.102, 0.26)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 8)
	return s


## GoldenFrame: dva Panela bez centra — edge (13, r 38) pa gold (7, r 35) uvučen 3 px.
static func golden_frame_style(gold_band: bool, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = COIN_GOLD if gold_band else GOLD_EDGE
	s.set_border_width_all(GOLD_BAND_W if gold_band else GOLD_EDGE_W)
	s.set_corner_radius_all(radius)
	return s


static func golden_plaque_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = COIN_GOLD
	s.border_color = GOLD_EDGE
	s.set_border_width_all(3)
	s.set_corner_radius_all(22)
	s.content_margin_left = 47.0
	s.content_margin_right = 47.0
	s.shadow_color = GOLD_EDGE
	s.shadow_size = 1
	s.shadow_offset = Vector2(0, 5)
	return s


static func tab_dot_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = NEW_PINK
	s.border_color = CHROME_DEEP
	s.set_border_width_all(3)
	s.set_corner_radius_all(TAB_DOT / 2)
	return s


## y reda u sadržaju liste (redovi idu sezona po sezona, 6 po sezoni u seasons.json).
static func row_y(season_index: int, row_in_season: int) -> int:
	var group_h := SEASON_HEADER_H + SEASON_HEADER_GAP + 6 * ROW_H + 5 * ROW_GAP
	return LIST_TOP + season_index * (group_h + SEASON_GAP) + SEASON_HEADER_H + SEASON_HEADER_GAP + row_in_season * (ROW_H + ROW_GAP)


static func _a(c: Color, alpha: float) -> Color:
	return Color(c.r, c.g, c.b, alpha)
