extends RefCounted
class_name UiPopups
## Pop-up sistem (design_handoff_popups). Modal · Sheet · Coach · Toast · Pop + PopupButton / AdButton / RewardChip.
## Sve u px baze 1080 x 1920. Ravne boje, radius, rub, jedna tvrda sjena. Bez blura, glowa, gradijenata.
## Imena boja ista kao u UiHomeField / UiWardrobe gdje postoje.

# ── Paleta ────────────────────────────────────────────────────────────────────
const WARM_WHITE     := Color("fff8f0")   # = UiHomeField.STICKER — paneli, oblačići
const OUTLINE        := Color("2d3436")   # = UiHomeField.STICKER_EDGE — rub, tekst, toast
const INK_SOFT       := Color("555c5e")
const ACTIVE_RIM     := Color("fff6d6")   # tray, izabrano, decision plate
const ROW_FILL       := Color("ffffff")   # secondary dugme, chip
const PEACH          := Color("ffb88c")   # primary
const LAVENDER       := Color("d4a5ff")   # reklama
const LAVENDER_LIGHT := Color("ead2ff")   # NOVO: svjetlija LAVENDER — reklama se učitava
const COIN_GOLD      := Color("ffd56b")   # poklon plate, +N, ×2
const MINT           := Color("a8e6cf")   # završio, gotovo, ✓
const PINK           := Color("ffccd5")   # pao, −N, pola
const DISABLED       := Color("f1eae0")
const DISABLED_EDGE  := Color(0.176, 0.204, 0.212, 0.30)
const TRAY_EDGE      := Color(0.176, 0.204, 0.212, 0.18)
const SEGMENT_EMPTY  := Color(0.176, 0.204, 0.212, 0.16)
const LOCKED_FRAME   := Color("e3d9cc")
const WELL           := Color("22342a")
const STAR_INK       := Color("7a4a28")   # NOVO: tamnija od #9E6645 → 4,5:1 i na ACTIVE_RIM
const SCRIM          := Color(0.102, 0.086, 0.118, 0.55)  # = UiHomeField.SCRIM, isti za hub i run
const DROP           := Color(0.102, 0.102, 0.078, 0.28)  # = STICKER_DROP
const PANEL_DROP     := Color(0.078, 0.055, 0.102, 0.45)
const RUN_DROP       := Color(0.039, 0.055, 0.047, 0.55)
const TOAST_RIM      := Color(1.0, 0.973, 0.941, 0.90)

# ── Mjere ─────────────────────────────────────────────────────────────────────
const ARTBOARD := Vector2i(1080, 1920)
const PAGE_RECT := Rect2i(0, 143, 1080, 1633)
const MIN_TOUCH := 120
const MIN_TEXT := 34

const MODAL_W := 984
const MODAL_RADIUS := 48
const MODAL_BORDER := 4
const MODAL_SHADOW := 14
const MODAL_PAD := Vector4i(92, 48, 48, 48)   # top, right, bottom, left
const MODAL_GAP := 36
const PLATE_H := 112
const PLATE_PAD_X := 52
const PLATE_TITLE := 56
const BANNER_H := 180
const BANNER_TITLE := 104

const TRAY_RADIUS := 36
const TRAY_PAD := 36
const TRAY_PAD_STAMP := 56
const STAMP_H := 64

const CHIP_H := 132
const CHIP_ART := 92
const CHIP_NUMBER := 56
const CHIP_WAS := 40

const SHEET_BASKET_H := 1326     # = UiHomeField.SHEET_BASKET_H
const SHEET_UPGRADES_H := 922    # = UiHomeField.SHEET_UPGRADES_H
const SHEET_RADIUS := 36
const SHEET_EDGE := 4            # Ormar 3 → 4 (README § Sistem)
const HANDLE := Vector2i(120, 12)
const DRAG_CLOSE_PX := 160

const SEED_TILE := Vector2i(328, 410)
const SEED_FRAME := 194
const SEED_ART := 134
const UPGRADE_CARD := Vector2i(1032, 264)
const UPGRADE_SEG := Vector2i(96, 22)
const UPGRADE_BTN := Vector2i(300, 132)
const NEED_TILE := Vector2i(264, 244)
const NEED_DOT := Vector2i(44, 22)

const COACH_RADIUS := 32
const COACH_BORDER := 4
const COACH_PAD := Vector2i(34, 26)
const COACH_MAX_W := 760
const COACH_TAIL := Vector2i(52, 32)
const COACH_TAIL_INNER := Vector2i(36, 24)
const COACH_TEXT := 44

const TOAST_H := 100
const TOAST_TEXT := 44
const TOAST_DISC := 60
const TOAST_STEP := 116
const TOAST_MAX := 2
const TOAST_Y_WARDROBE := 1253   # = UiWardrobe.TOAST_Y (1110 stranice)
const TOAST_Y_SEASON := 1393     # = UiHomeV3.TOAST_Y (1250 stranice)
const TOAST_Y_TOP := 167         # 24 ispod headera

const POP_SIZE := 64
const POP_STROKE := 10

const BUTTON_H := 132
const AD_BUTTON_H := 120         # uvijek < BUTTON_H
const BUTTON_RADIUS := 36
const BUTTON_BORDER := 4
const BUTTON_SHADOW := 8
const BUTTON_TEXT := 48
const AD_BUTTON_TEXT := 44

const ANIM := {
	"modal_in": 0.22, "modal_out": 0.16, "sheet_in": 0.32, "sheet_out": 0.28,
	"coach_in": 0.18, "coach_out": 0.14, "toast_in": 0.18, "toast_out": 0.16,
	"chip_in": 0.24, "chip_stagger": 0.09, "upgrade_flash": 0.4,
	"pop_rise": 0.42, "pop_spend": 0.6, "ring": 1.2, "dots": 0.9,
}

# ── StyleBoxFlat fabrike ──────────────────────────────────────────────────────
static func _box(fill: Color, radius: int, border: int = 0, edge: Color = OUTLINE) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.set_corner_radius_all(radius)
	sb.corner_detail = 16
	sb.anti_aliasing = true
	if border > 0:
		sb.set_border_width_all(border)
		sb.border_color = edge
	return sb

static func _hard_shadow(sb: StyleBoxFlat, y: int, c: Color) -> StyleBoxFlat:
	sb.shadow_color = c
	sb.shadow_size = 1
	sb.shadow_offset = Vector2(0, y)
	return sb

static func scrim() -> StyleBoxFlat:
	return _box(SCRIM, 0)

static func modal_panel(on_run: bool = false) -> StyleBoxFlat:
	return _hard_shadow(_box(WARM_WHITE, MODAL_RADIUS, MODAL_BORDER), MODAL_SHADOW, RUN_DROP if on_run else PANEL_DROP)

## tone: reward | success | fail | decision
static func modal_plate(tone: String) -> StyleBoxFlat:
	var fill := ACTIVE_RIM
	match tone:
		"reward": fill = COIN_GOLD
		"success": fill = MINT
		"fail": fill = PINK
	return _box(fill, PLATE_H / 2, MODAL_BORDER)

static func reward_tray() -> StyleBoxFlat:
	return _box(ACTIVE_RIM, TRAY_RADIUS, 3, TRAY_EDGE)

static func half_stamp() -> StyleBoxFlat:
	return _box(PINK, STAMP_H / 2, 3)

static func reward_chip() -> StyleBoxFlat:
	return _box(ROW_FILL, CHIP_H / 2, 3)

static func chip_art_disc() -> StyleBoxFlat:
	return _box(ACTIVE_RIM, CHIP_ART / 2, 3, TRAY_EDGE)

static func double_tag() -> StyleBoxFlat:
	return _box(COIN_GOLD, 27, 3)

static func sheet_panel() -> StyleBoxFlat:
	var sb := _box(WARM_WHITE, SHEET_RADIUS)
	sb.corner_radius_bottom_left = 0
	sb.corner_radius_bottom_right = 0
	sb.border_width_top = SHEET_EDGE
	sb.border_color = OUTLINE
	return sb

static func sheet_handle() -> StyleBoxFlat:
	return _box(Color(0.176, 0.204, 0.212, 0.28), HANDLE.y / 2)

## state: open | chosen | locked
static func seed_tile(state: String) -> StyleBoxFlat:
	match state:
		"chosen": return _box(ACTIVE_RIM, 32, 4)
		"locked": return _box(DISABLED, 32, 3, Color(0.176, 0.204, 0.212, 0.10))
	return _box(ROW_FILL, 32, 3, TRAY_EDGE)

static func seed_frame(locked: bool) -> StyleBoxFlat:
	return _box(LOCKED_FRAME, 34, 3, DISABLED_EDGE) if locked else _box(COIN_GOLD, 34, 3)

static func upgrade_card(flash: bool = false) -> StyleBoxFlat:
	return _box(ACTIVE_RIM, 32, 4) if flash else _box(ROW_FILL, 32, 3, TRAY_EDGE)

static func level_segment(filled: bool, flash: bool = false) -> StyleBoxFlat:
	if filled:
		return _box(COIN_GOLD if flash else MINT, UPGRADE_SEG.y / 2, 3)
	return _box(SEGMENT_EMPTY, UPGRADE_SEG.y / 2)

static func need_tile() -> StyleBoxFlat:
	return _box(ROW_FILL, 32, 3, TRAY_EDGE)

static func need_dot(filled: bool) -> StyleBoxFlat:
	return _box(MINT, NEED_DOT.y / 2, 3) if filled else _box(SEGMENT_EMPTY, NEED_DOT.y / 2)

static func coach_bubble(on_run: bool = false) -> StyleBoxFlat:
	return _hard_shadow(_box(WARM_WHITE, COACH_RADIUS, COACH_BORDER), 8, RUN_DROP if on_run else DROP)

static func coach_icon_disc(fill: Color = MINT) -> StyleBoxFlat:
	return _box(fill, 36, 3)

## Rep: dva trougla (Polygon2D) — OUTLINE 52 x 32, pa WARM_WHITE 36 x 24 pomjeren 5 px prema panelu.
static func coach_tail_points(dir: String, outer: bool) -> PackedVector2Array:
	var w := float(COACH_TAIL.x if outer else COACH_TAIL_INNER.x) * 0.5
	var h := float(COACH_TAIL.y if outer else COACH_TAIL_INNER.y)
	var o := 0.0 if outer else -5.0
	match dir:
		"up": return PackedVector2Array([Vector2(-w, -o), Vector2(w, -o), Vector2(0, -h - o)])
		"left": return PackedVector2Array([Vector2(-o, -w), Vector2(-o, w), Vector2(-h - o, 0)])
		"right": return PackedVector2Array([Vector2(o, -w), Vector2(o, w), Vector2(h + o, 0)])
	return PackedVector2Array([Vector2(-w, o), Vector2(w, o), Vector2(0, h + o)])

static func toast() -> StyleBoxFlat:
	return _box(OUTLINE, TOAST_H / 2, 3, TOAST_RIM)

static func toast_disc(fill: Color = WARM_WHITE) -> StyleBoxFlat:
	return _box(fill, TOAST_DISC / 2)

static func nav_lock_pill() -> StyleBoxFlat:
	return _box(OUTLINE, 32, 3, WARM_WHITE)

## kind: primary | secondary | ad | disabled | loading | done
static func button(kind: String, ad: bool = false) -> StyleBoxFlat:
	match kind:
		"primary": return _hard_shadow(_box(PEACH, BUTTON_RADIUS, BUTTON_BORDER), BUTTON_SHADOW, DROP)
		"ad": return _hard_shadow(_box(LAVENDER, BUTTON_RADIUS, BUTTON_BORDER), BUTTON_SHADOW, DROP)
		"disabled": return _box(DISABLED, BUTTON_RADIUS, BUTTON_BORDER, DISABLED_EDGE)
		"loading": return _box(LAVENDER_LIGHT, BUTTON_RADIUS, BUTTON_BORDER)
		"done": return _box(MINT, BUTTON_RADIUS, BUTTON_BORDER)
	return _hard_shadow(_box(ROW_FILL, BUTTON_RADIUS, BUTTON_BORDER), BUTTON_SHADOW, DROP)

static func button_pressed(sb: StyleBoxFlat) -> StyleBoxFlat:
	var p := sb.duplicate() as StyleBoxFlat
	p.shadow_offset = Vector2(0, 2)
	return p

static func button_height(ad: bool) -> int:
	return AD_BUTTON_H if ad else BUTTON_H

static func button_ink(kind: String) -> Color:
	return INK_SOFT if kind == "disabled" else OUTLINE

## Leteća poruka: fill + outline (Label: font_outline_color = OUTLINE, outline_size = POP_STROKE * 2).
static func pop_color(spend: bool) -> Color:
	return PINK if spend else COIN_GOLD

# ── Tweenovi ─────────────────────────────────────────────────────────────────
static func tween_modal_in(panel: Control) -> Tween:
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2.ONE * 0.9
	panel.modulate.a = 0.0
	var t := panel.create_tween().set_parallel()
	t.tween_property(panel, "scale", Vector2.ONE, ANIM.modal_in).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "modulate:a", 1.0, ANIM.modal_in)
	return t

static func tween_sheet_in(sheet: Control, h: int) -> Tween:
	var y1 := sheet.position.y
	sheet.position.y = y1 + h
	return sheet.create_tween().tween_property(sheet, "position:y", y1, ANIM.sheet_in).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func tween_coach_in(bubble: Control, tail_tip: Vector2) -> Tween:
	bubble.pivot_offset = tail_tip
	bubble.scale = Vector2.ONE * 0.85
	bubble.modulate.a = 0.0
	var t := bubble.create_tween().set_parallel()
	t.tween_property(bubble, "scale", Vector2.ONE, ANIM.coach_in).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(bubble, "modulate:a", 1.0, ANIM.coach_in)
	return t

static func tween_toast_in(toast_node: Control) -> Tween:
	var y1 := toast_node.position.y
	toast_node.position.y = y1 + 24
	toast_node.modulate.a = 0.0
	var t := toast_node.create_tween().set_parallel()
	t.tween_property(toast_node, "position:y", y1, ANIM.toast_in).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(toast_node, "modulate:a", 1.0, ANIM.toast_in)
	return t

## Nagrada: chipovi iskoče jedan za drugim (nije loop).
static func tween_reward_reveal(chips: Array) -> void:
	for i in chips.size():
		var c: Control = chips[i]
		c.pivot_offset = c.size * 0.5
		c.scale = Vector2.ONE * 0.6
		c.modulate.a = 0.0
		var t := c.create_tween().set_parallel()
		t.tween_property(c, "scale", Vector2.ONE, ANIM.chip_in).set_delay(i * ANIM.chip_stagger).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(c, "modulate:a", 1.0, ANIM.chip_in).set_delay(i * ANIM.chip_stagger)
