## UiHomeField — SAMO izmjene i novo za polje v2 (design_handoff_home_field_v2).
## Nazivi prate postojeći ui_home_field.gd; što ovdje nije navedeno ostaje ili se briše
## po README § Šta se briše. Koordinate kontrola su u prostoru stranice (1080 x 1633).

# ── Paleta (novo / izmijenjeno) ──────────────────────────────────────────────
const STICKER          := Color("fff8f0")                  # krem naljepnica
const STICKER_EDGE     := Color("2d3436")                  # rub 3 px — ≥ 6.14:1 na svim trakama
const STICKER_DROP     := Color(0.102, 0.102, 0.078, 0.28) # tvrda sjena 0 8 0, samo pritisljivo
const INK_SOFT         := Color("555c5e")                  # bilo 3d3d33; isto kao UiStage.INK_SOFT
const PINK             := Color("ffccd5")
const LOCKED_TILE      := Color("efe8de")
const LOCKED_FRAME     := Color("e3d9cc")
const DISABLED         := Color("f1eae0")
const DISABLED_EDGE    := Color(0.176, 0.204, 0.212, 0.30)
const ROW_FILL         := Color("ffffff")
const ROW_EDGE         := Color(0.176, 0.204, 0.212, 0.18)
const SEGMENT_EMPTY    := Color(0.176, 0.204, 0.212, 0.16)
const SCRIM            := Color(0.102, 0.086, 0.118, 0.55)

# ── Layout ───────────────────────────────────────────────────────────────────
const PAGE          := Vector2i(1080, 1633)
const PAGE_Y        := 143
const MEADOW        := Rect2i(0, 0, 1080, 1633)   # bilo Vector2i(1032, 605) flex u VBoxu
const MEADOW_BANDS  := [0.32, 0.68]                # bilo [0.56, 0.78]

const TILE          := 180
const TILE_ICON     := 84
const GIFT_RECT     := Rect2i(24, 24, 180, 180)
const BASKET_RECT   := Rect2i(24, 220, 180, 180)
const UPGRADES_RECT := Rect2i(876, 24, 180, 180)
const DOT           := 48
const DOT_OFFSET    := Vector2i(-12, -12)
const LEVEL_SEG     := Vector2i(28, 14)
const LEVEL_SEG_GAP := 6

const SEASON_LABEL_RECT := Rect2i(228, 36, 624, 56)
const GROWN_CHIP_Y      := 112
const GROWN_CHIP_H      := 76
const HINT_RECT         := Rect2i(236, 230, 600, 184)

const BOTTOM_ROW   := Rect2i(70, 1461, 940, 148)
const SEASONS_BTN  := Rect2i(70, 1477, 236, 124)
const PLAY_BTN     := Rect2i(324, 1461, 432, 140)   # centar x 540 i bez Endlessa
const ENDLESS_BTN  := Rect2i(774, 1477, 236, 124)
const PLAY_DISC    := 88

const SHEET_BASKET_H   := 1326
const SHEET_UPGRADES_H := 922
const PICKER_ROW_H     := 148
const PICKER_PORTRAIT  := 112
const UPGRADE_CARD     := Vector2i(1032, 264)
const UPGRADE_BTN      := Vector2i(272, 128)      # bilo 300 x 154
const UPGRADE_SEG      := Vector2i(64, 18)

const KEEPOUT := [
	Rect2i(8, 8, 212, 408),       # Gift + Basket
	Rect2i(860, 8, 212, 212),     # Upgrades
	Rect2i(212, 20, 656, 184),    # ime + čip (swipe prolazi)
	Rect2i(54, 1445, 972, 188),   # donji red
]
const KEEPOUT_HINT := Rect2i(220, 214, 632, 216)

## [x %, y % od poda stranice, veličina px, indeks u rosteru, prag]. Crtati ovim redom.
const MEADOW_SPOTS := [
	[10, 55, 88, 3, 5], [26, 54, 88, 0, 5], [42, 55, 88, 1, 5], [58, 54, 88, 4, 5], [74, 55, 88, 2, 5], [90, 54, 88, 5, 5],
	[18, 40, 116, 0, 1], [50, 42, 116, 1, 1], [82, 40, 116, 2, 1],
	[12, 29, 136, 3, 1], [66, 28, 136, 4, 1], [88, 30, 136, 5, 1],
	[34, 26, 168, 5, 10],
]
const PIP_SIZE := 190
const PIP_BASE_ZONE := Rect2i(151, 1306, 778, 131)
const PIP_DEFAULT_BASE := Vector2i(756, 1404)

static func spot_base(spot: Array) -> Vector2:
	return Vector2(spot[0] * PAGE.x / 100.0, PAGE.y - spot[1] * PAGE.y / 100.0)


# ── StyleBoxFlat fabrike (novo / izmijenjeno) ─────────────────────────────────
## Naljepnica: neprozirni fill + rub 3 ink; pressable = tvrda sjena 0 8 0.
static func sticker(fill: Color, radius: int, pressable: bool = true) -> StyleBoxFlat:
	var sb := _box(fill, radius, 3, STICKER_EDGE)
	sb.corner_detail = 16
	sb.anti_aliasing = true
	if pressable:
		sb.shadow_color = STICKER_DROP
		sb.shadow_size = 1
		sb.shadow_offset = Vector2(0, 8)
	return sb

static func pressed(sb: StyleBoxFlat) -> StyleBoxFlat:
	var p := sb.duplicate() as StyleBoxFlat
	p.shadow_offset = Vector2(0, 2)
	return p

static func tile(state: String = "normal") -> StyleBoxFlat:
	return sticker(LOCKED_TILE if state == "locked" else STICKER, 32)

static func tile_icon(fill: Color) -> StyleBoxFlat:
	return _box(fill, 18, 3, STICKER_EDGE)

static func tile_well() -> StyleBoxFlat:
	return _box(WELL, 11)

static func corner_dot(fill: Color) -> StyleBoxFlat:
	return _box(fill, 24, 4, STICKER_EDGE)

static func bonus_pill() -> StyleBoxFlat:
	return _box(MINT, 18, 2, STICKER_EDGE)

static func attention_ring() -> StyleBoxFlat:
	var sb := _box(Color(0, 0, 0, 0), 32, 4, STICKER_EDGE)
	sb.draw_center = false
	return sb

static func grown_chip() -> StyleBoxFlat:
	return sticker(STICKER, 38, false)

static func tutorial_hint() -> StyleBoxFlat:
	return sticker(STICKER, 28, false)

static func seasons_button() -> StyleBoxFlat:
	return sticker(STICKER, 28)

static func play_button() -> StyleBoxFlat:
	return sticker(PEACH, 32)

static func endless_button() -> StyleBoxFlat:
	return sticker(LAVENDER, 28)

static func level_segment(filled: bool, h: int) -> StyleBoxFlat:
	if filled:
		return _box(MINT, int(h / 2.0), 2, STICKER_EDGE)
	return _box(SEGMENT_EMPTY, int(h / 2.0))

## Bottom sheet — krem (bio CHROME tamni).
static func picker_sheet() -> StyleBoxFlat:
	var sb := _box(STICKER, 36)
	sb.corner_radius_bottom_left = 0
	sb.corner_radius_bottom_right = 0
	sb.border_width_top = 3
	sb.border_color = STICKER_EDGE
	return sb

## state: row | chosen | locked
static func picker_row(state: String) -> StyleBoxFlat:
	match state:
		"chosen":
			return _box(ACTIVE_RIM, 24, 4, STICKER_EDGE)
		"locked":
			return _box(DISABLED, 24, 3, Color(0.176, 0.204, 0.212, 0.10))
		_:
			return _box(ROW_FILL, 24, 3, ROW_EDGE)

static func picker_chip(chosen: bool) -> StyleBoxFlat:
	if chosen:
		return _box(STICKER_EDGE, 18)
	return _box(Color(0, 0, 0, 0), 18, 2, DISABLED_EDGE)

static func upgrade_card(flash: bool = false) -> StyleBoxFlat:
	if flash:
		return _box(ROW_FILL, 28, 4, STICKER_EDGE)
	return _box(ROW_FILL, 28, 3, ROW_EDGE)

static func upgrade_level(_flash: bool = false) -> StyleBoxFlat:
	return _box(ACTIVE_RIM, 16, 2, STICKER_EDGE)

## state: ready | blocked | maxed
static func upgrade_button(state: String) -> StyleBoxFlat:
	match state:
		"ready":
			var sb := _box(UI_GOLD, 28, 3, STICKER_EDGE)
			sb.shadow_color = STICKER_DROP
			sb.shadow_size = 1
			sb.shadow_offset = Vector2(0, 6)
			return sb
		"maxed":
			return _box(MINT, 28, 3, STICKER_EDGE)
		_:
			return _box(DISABLED, 28, 3, DISABLED_EDGE)

static func upgrade_button_ink(state: String) -> Color:
	return INK_SOFT if state == "blocked" else OUTLINE

## Okvir cvijeta u svijetlom jeziku: zlatni fill + rub ink (bio rub COIN_GOLD_EDGE).
static func art_frame(size: int) -> StyleBoxFlat:
	var radius := 24 if size >= 96 else (18 if size >= 80 else 14)
	return _box(COIN_GOLD, radius, 3, STICKER_EDGE)

static func art_frame_locked(size: int) -> StyleBoxFlat:
	var radius := 24 if size >= 96 else (18 if size >= 80 else 14)
	return _box(LOCKED_FRAME, radius, 3, Color(0.176, 0.204, 0.212, 0.30))


# ── Tekstovi (izmijenjeno) ────────────────────────────────────────────────────
static func magnet_effect(level: int) -> String:
	if level >= UPGRADE_MAX_LEVEL:
		return "Pull radius %d px" % magnet_radius(UPGRADE_MAX_LEVEL)
	return "Pull radius %d px → %d px" % [magnet_radius(level), magnet_radius(level + 1)]

static func loot_effect(level: int) -> String:
	if level >= UPGRADE_MAX_LEVEL:
		return "Run loot ×2.0"
	return "Run loot ×%s → ×%s" % [str(loot_multiplier(level)), str(loot_multiplier(level + 1))]

static func basket_label(state: String) -> String:
	match state:
		"locked":
			return "Basket"
		"empty":
			return "Choose"
		_:
			return "+%d %%" % LOADOUT_SPAWN_BONUS_PCT

## have_text() se briše — razlog stoji na dugmetu ("Need N").


# ── Animacije (izmijenjeno / novo) ────────────────────────────────────────────
const ANIM_V2 := {
	"field_open": 0.28,
	"card_content_out": 0.12,
	"bands_in_delay": 0.16,
	"bands_in": 0.18,
	"chrome_delay": 0.22,
	"chrome_in": 0.18,
	"chrome_stagger": 0.06,
	"chrome_slide": 16,
	"chrome_out": 0.12,
	"field_close": 0.24,
	"attention": 1.2,
	"attention_scale": 1.16,
	"sheet_in": 0.24,
	"scrim_in": 0.18,
	"press": 0.08,
}

## Kartica sezone → cijela stranica. Isti Panel: rect + radius + rub + bg_color.
static func tween_open_field(shell: Control, ground: Color) -> Tween:
	var t := shell.create_tween().set_parallel(true)
	t.tween_property(shell, "position", Vector2(MEADOW.position), ANIM_V2.field_open).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(shell, "size", Vector2(MEADOW.size), ANIM_V2.field_open).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var sb: StyleBoxFlat = shell.get_theme_stylebox("panel")
	t.tween_property(sb, "bg_color", ground, ANIM_V2.field_open)
	t.tween_method(func(v: float): sb.set_corner_radius_all(int(v)), 36.0, 0.0, ANIM_V2.field_open)
	t.tween_method(func(v: float): sb.set_border_width_all(int(v)), 8.0, 0.0, ANIM_V2.field_open)
	return t

## Chrome plovi: fade + 16 px od svog ruba. `from_top` = gornja grupa (klizi dolje).
## Redoslijed: Play, Seasons, Endless, Gift, Basket, Upgrades, ime + čip.
static func tween_chrome_in(items: Array, from_top: Array) -> void:
	for i in items.size():
		var c: Control = items[i]
		var home := c.position
		var dy := -ANIM_V2.chrome_slide if bool(from_top[i]) else ANIM_V2.chrome_slide
		c.modulate.a = 0.0
		c.position = home + Vector2(0, dy)
		var t := c.create_tween().set_parallel(true)
		var delay: float = ANIM_V2.chrome_delay + ANIM_V2.chrome_stagger * float(i)
		t.tween_property(c, "modulate:a", 1.0, ANIM_V2.chrome_in).set_delay(delay).set_ease(Tween.EASE_OUT)
		t.tween_property(c, "position", home, ANIM_V2.chrome_in).set_delay(delay).set_ease(Tween.EASE_OUT)

## Jedini loop na ekranu: ripple oko prazne korpe. Zaustaviti kad se sjeme izabere.
static func tween_attention(ring: Control) -> Tween:
	ring.pivot_offset = ring.size * 0.5
	var t := ring.create_tween().set_loops()
	t.tween_callback(func(): ring.scale = Vector2.ONE; ring.modulate.a = 0.7)
	t.tween_property(ring, "scale", Vector2.ONE * ANIM_V2.attention_scale, ANIM_V2.attention * 0.6).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(ring, "modulate:a", 0.0, ANIM_V2.attention * 0.6).set_ease(Tween.EASE_OUT)
	t.tween_interval(ANIM_V2.attention * 0.4)
	return t
