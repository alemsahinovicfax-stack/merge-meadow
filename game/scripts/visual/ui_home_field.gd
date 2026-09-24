extends RefCounted
class_name UiHomeField
## Tokeni i StyleBoxFlat fabrike za Home — polje sezone (SeasonField).
## Generisano iz design_handoff_home_field/godot/field_export.json. Biranje sezone
## (kartica, dock, Play red) je u UiStage. Sve mjere su u px baze 1080 x 1920 i
## prenose se 1:1.

# ── Paleta Home ekrana ────────────────────────────────────────────────────────
const PAGE_BG          := Color("2e4733")
const CHROME           := Color("1a241e")
const ACTIVE_RIM       := Color("fff6d6")
const WARM_WHITE       := Color("fff8f0")
const INK              := Color("1a1a14")
const INK_SOFT         := Color("3d3d33")
const OUTLINE          := Color("2d3436")
const COIN_GOLD        := Color("ffd56b")
const COIN_GOLD_EDGE   := Color("d6a82f")
const UI_GOLD          := Color("e8c44a")
const UI_GOLD_EDGE     := Color("ba9d3b")
const PEACH            := Color("ffb88c")
const PEACH_EDGE       := Color("e8a374")
const LAVENDER         := Color("d4a5ff")
const LAVENDER_EDGE    := Color("aa84cc")
const MINT             := Color("a8e6cf")
const MINT_EDGE        := Color("7fc9ac")
const WELL             := Color("22342a")
const WELL_EDGE        := Color("16211b")

# ── Novo u polju ─────────────────────────────────────────────────────────────
const SOIL_FILL        := Color(0.102, 0.102, 0.078, 0.10)
const SOIL_EDGE        := Color(0.102, 0.102, 0.078, 0.19)
const FLOWER_SHADOW    := Color(0.102, 0.102, 0.078, 0.13)
const COUNT_FILL       := Color(1, 0.973, 0.941, 0.80)
const COUNT_EDGE       := Color(0.102, 0.102, 0.078, 0.26)
const PANEL_FILL       := Color(1, 0.973, 0.941, 0.13)
const PANEL_EDGE       := Color(1, 0.973, 0.941, 0.28)
## Minimum koji na #2E4733 još drži 4.5:1 — ne spuštati.
const DISABLED_FILL    := Color(1, 0.973, 0.941, 0.07)
const DISABLED_EDGE    := Color(1, 0.973, 0.941, 0.20)
const DISABLED_INK     := Color(1, 0.973, 0.941, 0.68)
const SUB_ON_DARK      := Color(1, 0.965, 0.839, 0.90)
const SCRIM            := Color(0.078, 0.102, 0.086, 0.62)
const SHEET_EDGE       := Color(1, 0.973, 0.941, 0.30)

# ── Layout polja ─────────────────────────────────────────────────────────────
const PAGE            := Vector2i(1080, 1597)
const PAGE_Y          := 143
const PAGE_PADDING    := 24
const BLOCK_GAP       := 16
const TOP_ROW_H       := 124
const BACK_W          := 300
const MEADOW          := Vector2i(1032, 605)   # flex: ono što ostane u VBoxu
const MEADOW_INNER    := Vector2i(1020, 593)
const BASKET_H        := 180   # 18x2 padding + 136 kolona + 3x2 border = 178
const UPGRADE_H       := 192   # 16x2 padding + 154 redova + 3x2 border
const UPGRADE_LEFT_W  := 680
const UPGRADE_BTN     := Vector2i(300, 154)
const PLAY_ROW_H      := 176
const PLAY_W          := 656                   # 1032 dok Endless nije otključan
const ENDLESS_W       := 360
const SHEET_H         := 1308
const PICKER_ROW_H    := 148
const MIN_TOUCH       := 120
const MIN_TEXT        := 38
const MIN_NUMBER      := 44

## Trake livade, kao udio visine: sky 0–56 %, far 56–78 %, near 78–100 %.
const MEADOW_BANDS := [0.56, 0.78]

## 13 mjesta: [x %, y % od poda livade, veličina px, indeks u rosteru, koliko cvjetova treba].
## Bliža mjesta traže manje, pa livada raste od igrača prema horizontu.
const MEADOW_SPOTS := [
	[10, 40, 76, 0, 5], [29, 42, 76, 1, 5], [51, 40, 76, 2, 5], [72, 42, 76, 3, 5], [90, 38, 84, 4, 5],
	[17, 27, 96, 5, 5], [37, 25, 96, 0, 1], [59, 27, 96, 1, 1], [84, 24, 96, 2, 1],
	[11, 9, 112, 3, 1], [33, 7, 112, 4, 1], [88, 8, 112, 5, 1], [52, 1, 128, 5, 10],
]
const PIP_SIZE := 190
const PIP_X_PCT := 68
const PIP_BOTTOM_PCT := 3

## Boja livade po sezoni — postojeće vrijednosti iz SeasonTheme.home_field_tint().
const MEADOW_GROUND := {
	"country_bloom": Color("e6f2db"),
	"frost_orchard": Color("d1e6ff"),
	"lantern_meadow": Color("ebd6ff"),
	"amber_canopy": Color("ffebc7"),
	"moonlit_warren": Color("b8bdff"),
	"coral_tide": Color("ffe0d6"),
	"starfall_glade": Color("dbccff"),
	"ember_fen": Color("ffc79e"),
}

const MAGNET_BASE_RADIUS := 40
const MAGNET_STEP := 48
const LOOT_MULTIPLIERS := [1.0, 1.25, 1.5, 1.75, 2.0]
const UPGRADE_MAX_LEVEL := 4
const UPGRADE_FLOWER_COST := 2
const LOADOUT_SPAWN_BONUS_PCT := 5


# ── Izvedene boje ─────────────────────────────────────────────────────────────
## Pod livade. Fallback vrijedi samo za sezonu bez upisanog tinta.
static func meadow_ground(season_id: String, mood: Color = MINT) -> Color:
	if MEADOW_GROUND.has(season_id):
		return MEADOW_GROUND[season_id]
	return mood.lerp(WARM_WHITE, 0.45)

static func meadow_sky(ground: Color) -> Color:
	return ground.lerp(Color.WHITE, 0.30)

static func meadow_near(ground: Color) -> Color:
	return Color(ground.r * 0.93, ground.g * 0.93, ground.b * 0.93)

static func magnet_radius(level: int) -> int:
	return MAGNET_BASE_RADIUS + MAGNET_STEP * level

static func loot_multiplier(level: int) -> float:
	return LOOT_MULTIPLIERS[clampi(level, 0, UPGRADE_MAX_LEVEL)]


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

## Okvir livade. Namjerno ista geometrija kao aktivna kartica sezone
## (1032, radius 26, rim 6 px) — zato prelaz radi kao jedan rect tween.
static func meadow_frame(season_id: String, mood: Color = MINT) -> StyleBoxFlat:
	var sb := _box(meadow_ground(season_id, mood), 26, 6, ACTIVE_RIM)
	return _shadow(sb, 22, 10, Color(0.078, 0.102, 0.086, 0.38))

## Prazno mjesto u zemlji — pill, ne blijedi cvijet.
static func soil_spot(h: int) -> StyleBoxFlat:
	return _box(SOIL_FILL, int(h / 2.0), 3, SOIL_EDGE)

static func flower_shadow(h: int) -> StyleBoxFlat:
	return _box(FLOWER_SHADOW, int(h / 2.0))

## Čip "{n} / 13 grown" gore lijevo u livadi.
static func meadow_count() -> StyleBoxFlat:
	return _box(COUNT_FILL, 18, 2, COUNT_EDGE)

## Tihi panel na tamnoj stranici — BackButton, BasketCard, UpgradeCard.
static func field_panel(radius: int = 22) -> StyleBoxFlat:
	return _shadow(_box(PANEL_FILL, radius, 3, PANEL_EDGE), 16, 8, Color(0.078, 0.102, 0.086, 0.26))

static func back_button() -> StyleBoxFlat:
	return _box(PANEL_FILL, 22, 3, Color(1, 0.973, 0.941, 0.34))

## Korpa. state: empty | chosen | locked
static func basket_card(state: String) -> StyleBoxFlat:
	match state:
		"empty":
			return _shadow(_box(PANEL_FILL, 22, 4, UI_GOLD), 16, 8, Color(0.078, 0.102, 0.086, 0.26))
		"locked":
			return _shadow(_box(Color(1, 0.973, 0.941, 0.06), 22, 3, Color(1, 0.973, 0.941, 0.18)), 16, 8, Color(0.078, 0.102, 0.086, 0.26))
		_:
			return field_panel(22)

static func basket_button(chosen: bool) -> StyleBoxFlat:
	if chosen:
		return _box(Color(1, 0.973, 0.941, 0.16), 20, 3, Color(1, 0.965, 0.839, 0.40))
	return _box(UI_GOLD, 20, 3, UI_GOLD_EDGE)

## Kartica nadogradnje. flash = trenutak poslije kupovine (0.4 s).
static func upgrade_card(flash: bool = false) -> StyleBoxFlat:
	if flash:
		return _shadow(_box(PANEL_FILL, 22, 4, ACTIVE_RIM), 16, 8, Color(0.078, 0.102, 0.086, 0.26))
	return field_panel(22)

## Čip nivoa "Lv 1 / 4".
static func upgrade_level(flash: bool = false) -> StyleBoxFlat:
	if flash:
		return _box(COIN_GOLD, 16, 2, COIN_GOLD_EDGE)
	return _box(Color(1, 0.973, 0.941, 0.14), 16, 2, Color(1, 0.965, 0.839, 0.36))

static func upgrade_segment(filled: bool) -> StyleBoxFlat:
	if filled:
		return _box(MINT, 8, 2, MINT_EDGE)
	return _box(Color(1, 0.973, 0.941, 0.20), 8)

## Dugme nadogradnje. state: ready | blocked | maxed
static func upgrade_button(state: String) -> StyleBoxFlat:
	match state:
		"ready":
			return _box(UI_GOLD, 20, 3, UI_GOLD_EDGE)
		"maxed":
			return _box(Color(1, 0.973, 0.941, 0.10), 20, 3, Color(1, 0.965, 0.839, 0.34))
		_:
			return _box(DISABLED_FILL, 20, 3, DISABLED_EDGE)

static func upgrade_button_ink(state: String) -> Color:
	match state:
		"ready":
			return OUTLINE
		"maxed":
			return ACTIVE_RIM
		_:
			return DISABLED_INK

## Tekst dugmeta nadogradnje — razlog stoji na kontroli koja odbija.
static func upgrade_button_label(state: String, have: int) -> String:
	match state:
		"ready":
			return "Upgrade"
		"maxed":
			return "Maxed"
		_:
			return "Need %d" % maxi(1, UPGRADE_FLOWER_COST - have)

## Okvir cvijeta (gold rim + tamni well) — korpa 128, picker 104, cijena 46.
static func art_frame(size: int) -> StyleBoxFlat:
	var radius := 28 if size >= 120 else (24 if size >= 96 else 12)
	return _box(COIN_GOLD, radius, 3, COIN_GOLD_EDGE)

static func art_well(size: int) -> StyleBoxFlat:
	var radius := 19 if size >= 120 else (16 if size >= 96 else 8)
	return _box(WELL, radius, 2, WELL_EDGE)

static func art_frame_locked(size: int) -> StyleBoxFlat:
	var radius := 28 if size >= 120 else (24 if size >= 96 else 12)
	return _box(Color(1, 0.973, 0.941, 0.10), radius, 3, Color(1, 0.965, 0.839, 0.30))

static func play_button() -> StyleBoxFlat:
	return _shadow(_box(PEACH, 26, 4, PEACH_EDGE), 16, 8, Color(0.078, 0.102, 0.086, 0.30))

static func endless_button() -> StyleBoxFlat:
	return _shadow(_box(LAVENDER, 26, 4, LAVENDER_EDGE), 16, 8, Color(0.078, 0.102, 0.086, 0.30))

static func tutorial_hint() -> StyleBoxFlat:
	return _shadow(_box(ACTIVE_RIM, 20, 3, COIN_GOLD_EDGE), 16, 8, Color(0.078, 0.102, 0.086, 0.30))

## Bottom sheet pickera.
static func picker_sheet() -> StyleBoxFlat:
	var sb := _box(CHROME, 32)
	sb.corner_radius_bottom_left = 0
	sb.corner_radius_bottom_right = 0
	sb.border_width_top = 3
	sb.border_color = SHEET_EDGE
	return sb

## Red pickera. state: row | chosen | locked
static func picker_row(state: String) -> StyleBoxFlat:
	match state:
		"chosen":
			return _box(Color(1, 0.973, 0.941, 0.16), 20, 4, ACTIVE_RIM)
		"locked":
			return _box(Color(1, 0.973, 0.941, 0.05), 20, 2, Color(1, 0.973, 0.941, 0.16))
		_:
			return _box(Color(1, 0.973, 0.941, 0.10), 20, 2, Color(1, 0.973, 0.941, 0.26))

static func picker_chip(chosen: bool) -> StyleBoxFlat:
	if chosen:
		return _box(ACTIVE_RIM, 18, 3, COIN_GOLD_EDGE)
	return _box(Color(1, 0.973, 0.941, 0.06), 18, 2, Color(1, 0.965, 0.839, 0.26))


# ── Tekstovi koji se računaju ────────────────────────────────────────────────
static func magnet_effect(level: int) -> String:
	if level >= UPGRADE_MAX_LEVEL:
		return "Pull radius %d px · fully upgraded" % magnet_radius(UPGRADE_MAX_LEVEL)
	return "Pull radius %d px → %d px" % [magnet_radius(level), magnet_radius(level + 1)]

static func loot_effect(level: int) -> String:
	if level >= UPGRADE_MAX_LEVEL:
		return "Run loot ×2.0 · fully upgraded"
	return "Run loot ×%s → ×%s" % [str(loot_multiplier(level)), str(loot_multiplier(level + 1))]

static func level_text(level: int) -> String:
	return "Lv %d / %d" % [level, UPGRADE_MAX_LEVEL]

## Cijena mora znati ime cvijeta PRIJE tapa — zvati pick_upgrade_flower_type()
## pri svakom refreshu, ne tek pri trošenju.
static func cost_text(flower_name: String) -> String:
	if flower_name.is_empty():
		return "2 × any ★1 flower"
	return "%d × %s" % [UPGRADE_FLOWER_COST, flower_name]

static func have_text(have: int) -> String:
	if have >= UPGRADE_FLOWER_COST:
		return ""          # dostupno — broj ne treba
	if have <= 0:
		return "none yet"
	return "you have %d" % have

static func rarity_pips(rarity: int) -> String:
	var r := clampi(rarity, 1, 3)
	return "★".repeat(r) + "☆".repeat(3 - r)


# ── Animacije ────────────────────────────────────────────────────────────────
const ANIM := {
	"field_open": 0.28,
	"field_close": 0.24,
	"chrome_in": 0.18,
	"chrome_stagger": 0.06,
	"flower_settle": 0.20,
	"flower_stagger": 0.024,
	"sheet_in": 0.24,
	"scrim_in": 0.18,
	"segment_fill": 0.22,
	"card_flash_in": 0.16,
	"card_flash_out": 0.24,
	"press": 0.08,
	"basket_pulse": 1.2,
	"pip_bubble_in": 0.16,
	"pip_bubble_hold": 1.8,
}

## Kartica sezone → okvir livade. Isti Panel, samo rect + bg_color.
static func tween_open_field(shell: Control, to_rect: Rect2, ground: Color) -> Tween:
	var t := shell.create_tween().set_parallel(true)
	t.tween_property(shell, "position", to_rect.position, ANIM.field_open) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(shell, "size", to_rect.size, ANIM.field_open) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var sb: StyleBoxFlat = shell.get_theme_stylebox("panel")
	t.tween_property(sb, "bg_color", ground, ANIM.field_open)
	return t

## Chrome ulazi iza livade: fade, bez pomaka — VBox djeca ne smiju dobiti ručni position.
static func tween_chrome_in(blocks: Array) -> void:
	for i in blocks.size():
		var c: Control = blocks[i]
		c.modulate.a = 0.0
		var t := c.create_tween()
		t.tween_interval(ANIM.chrome_stagger * float(i))
		t.tween_property(c, "modulate:a", 1.0, ANIM.chrome_in).set_ease(Tween.EASE_OUT)

## Cvjetovi sjedaju jednom, pri otvaranju. Poslije toga livada je statična.
static func tween_flowers_settle(flowers: Array) -> void:
	for i in flowers.size():
		var f: Control = flowers[i]
		f.scale = Vector2(0.9, 0.9)
		var t := f.create_tween()
		t.tween_interval(ANIM.flower_stagger * i)
		t.tween_property(f, "scale", Vector2.ONE, ANIM.flower_settle).set_ease(Tween.EASE_OUT)
