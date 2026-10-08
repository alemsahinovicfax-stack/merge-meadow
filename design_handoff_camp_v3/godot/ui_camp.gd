## Camp v3 — SAMO IZMJENE. Spoji u game/scripts/visual/ui_camp.gd (class_name UiCamp).
## Handoff: design_handoff_camp_v3/README.md · podaci: camp_v3_export.json

# --- Pozadina stranice (bila MEADOW_BG #2E4733) ---
const PAGE_BG := Color("#4E3F5A")                    # dusk heather — uz chrome #2A2233
const PAGE_SHADOW := Color(0.078, 0.055, 0.102, 0.34) # = UiChrome.CHROME_SHADOW
# OBRISATI: const MEADOW_BG := Color("#2E4733")  (ili preusmjeriti na PAGE_BG)

# --- Budžet uz footer 144 (v2 raspored, Δ 36 u sekciju) ---
# SECTION_H 1289 kad je kartica 276 (v2); sa Season Kit karticom 318 ostaje 1247.

# --- Mergeable ---
const MERGE_MIN := 4
const GATE_MIN := 50
const MERGE_MARK := Vector2(64, 42)
const MERGE_MARK_ICON := 40
const MERGE_LINE_H := 48
const MERGE_LINE_GAP := 12
const MERGE_LINE_ICON := 34
const TRADE_H_MERGE := TRADE_H + MERGE_LINE_GAP + MERGE_LINE_H   # 212
const MINT := Color("#A8E6CF")
const MERGE_LAST := Color("#FFE8B8")                 # disk kad je stog tačno 4
const ICON_MERGEABLE := "res://assets/ui/camp/icon_mergeable.svg"
const T_MERGE_MARK := 0.14
const T_MERGE_LINE := 0.16
const T_MERGE_SWAP := 0.08


static func is_mergeable(count: int) -> bool:
	return count >= MERGE_MIN


## Zbroj za Arenu: cijeli stog ulazi samo ako ga ima >= 4.
static func gate_count(counts: Array) -> int:
	var n := 0
	for c in counts:
		if int(c) >= MERGE_MIN:
			n += int(c)
	return n


static func gate_open(counts: Array) -> bool:
	return gate_count(counts) >= GATE_MIN


static func merge_mark_style(last: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = MERGE_LAST if last else MINT
	s.border_color = INK
	s.set_border_width_all(2)
	s.set_corner_radius_all(int(MERGE_MARK.y / 2))
	s.corner_detail = 12
	return s


## Linija ispod TradeRow. "" = sakrij (tip ispod 4 ili Flowers tab).
static func merge_line_text(count: int) -> String:
	if count < MERGE_MIN:
		return ""
	if count == MERGE_MIN:
		return "Arena takes all 4 · sell 1 and none go"
	return "Arena takes all %d" % count


## Trade bar visina s v3 linijom.
static func trade_height_v3(state: String, merge_line: bool) -> int:
	return trade_height(state) + (MERGE_LINE_GAP + MERGE_LINE_H if merge_line else 0)


static func grid_budget_v3(state: String, hero_visible: bool, merge_line: bool) -> int:
	var chrome := 2 * (SECTION_PAD + SECTION_BORDER) + TABS_H + 2 * SECTION_INNER_GAP
	return section_height(hero_visible) - chrome - trade_height_v3(state, merge_line)


# --- Nadogradnje (po sezoni) ---
const UP_LEVELS := 4
const UP_FLOWER_COST := 2                      # ★3 iste sezone, samo iznad Kept granice
const UP_COIN_COST := [10, 20, 40, 60]
const LOOT_MULT := [1.0, 1.25, 1.5, 1.75, 2.0]
const TWIN_STEP := 0.08                        # Twin Seeds: p = 0.08 * L

const UP_CAN := "can"
const UP_SHORT_FLOWER := "short_flower"
const UP_SHORT_COIN := "short_coin"
const UP_SHORT_BOTH := "short_both"
const UP_MAX := "max"


static func magnet_radius(level: int) -> int:
	return 40 + 48 * clampi(level, 0, UP_LEVELS)


static func twin_chance(level: int) -> float:
	return TWIN_STEP * clampi(level, 0, UP_LEVELS)


## spendable_flowers = ★3 te sezone minus Kept granica (nikad < 0).
static func upgrade_state(level: int, spendable_flowers: int, coins: int) -> String:
	if level >= UP_LEVELS:
		return UP_MAX
	var ok_f := spendable_flowers >= UP_FLOWER_COST
	var ok_c := coins >= int(UP_COIN_COST[level])
	if ok_f and ok_c:
		return UP_CAN
	if not ok_f and not ok_c:
		return UP_SHORT_BOTH
	return UP_SHORT_FLOWER if not ok_f else UP_SHORT_COIN
