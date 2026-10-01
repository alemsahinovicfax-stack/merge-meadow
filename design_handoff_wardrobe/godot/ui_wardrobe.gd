extends RefCounted
class_name UiWardrobe
## Ormar (Wardrobe) — design_handoff_wardrobe/README.md · design/Wardrobe.dc.html
## Treći sheet polja sezone (porodica BasketSheet 1326 / UpgradesSheet 922).
## Sve mjere u px baze 1080 x 1920; stranica polja 1080 x 1633 od y 143.
## Boje su postojeće (UiHomeField / UiShop / UiRun); nove su samo boje skinova u cosmetics.json.
## Ekran se gradi iz CosmeticCatalog (game/data/cosmetics/cosmetics.json) — ništa ovdje ne zna za konkretan slot.

# ── Boje (isti nazivi kao u ui_home_field.gd / ui_shop.gd) ────────────────────
const STICKER        := Color("fff8f0")   # = UiHomeField.STICKER / WARM_WHITE
const STICKER_EDGE   := Color("2d3436")   # = UiHomeField.STICKER_EDGE / OUTLINE
const STICKER_DROP   := Color(0.102, 0.102, 0.078, 0.28)
const INK            := Color("2d3436")
const INK_SOFT       := Color("555c5e")
const ACTIVE_RIM     := Color("fff6d6")   # nošena kartica (= picker_row "chosen")
const PEACH          := Color("ffb88c")   # aktivni tab (= UiShop.ACTIVE)
const PINK           := Color("ffccd5")   # glyph ormara (= UiHomeField.PINK)
const MINT           := Color("a8e6cf")   # New tag / WardrobeDot
const ROW_FILL       := Color("ffffff")
const ROW_EDGE       := Color(0.176, 0.204, 0.212, 0.18)
const DISABLED       := Color("f1eae0")   # kartica "none"
const DISABLED_EDGE  := Color(0.176, 0.204, 0.212, 0.10)
const LOCK_VEIL      := Color("e3d9cc")   # = UiHomeField.LOCKED_FRAME
const DASH_EDGE      := Color(0.176, 0.204, 0.212, 0.40)  # ShopLink / EmptyState
const WELL_EDGE      := Color("16211b")   # rub ItemPreview (= UiShop.WELL_EDGE)
const ALBUM_BG       := Color("2e4733")   # = UiShop.PAGE_BG
const LABEL_CHIP     := Color(0.102, 0.141, 0.118, 0.84)  # = UiShop.LABEL_CHIP
const LABEL_CHIP_EDGE := Color(1.0, 0.973, 0.941, 0.40)
const SCRIM          := Color(0.102, 0.086, 0.118, 0.55)  # = UiHomeField.SCRIM
const TOAST_BG       := Color("2d3436")
const RING           := Color(1.0, 0.973, 0.941, 0.55)    # ApplyRing, alpha → 0

# ── Polje: WardrobeButton i sukobi (§ Odlučeno) ───────────────────────────────
const WARDROBE_BTN       := Rect2i(876, 1265, 180, 180)   # TILE, desna kolona, 16 iznad BOTTOM_ROW
const WARDROBE_GLYPH     := 84                             # = UiHomeField.TILE_ICON
const WARDROBE_ICON      := 66
const WARDROBE_KEEPOUT   := Rect2i(860, 1249, 212, 212)   # dodati u UiHomeField.KEEPOUT
const PIP_BASE_ZONE      := Rect2i(151, 1306, 614, 131)   # bilo (151,1306,778,131)
const PIP_DEFAULT_BASE   := Vector2i(756, 1404)           # nepromijenjeno
const WARDROBE_DOT_OFFSET := Vector2i(-12, -12)           # gore lijevo, kao UpgradeDot

# ── Sheet ─────────────────────────────────────────────────────────────────────
const SHEET_H        := 1326          # = UiHomeField.SHEET_BASKET_H → top y 307 na stranici
const SHEET_RADIUS   := 36
const SHEET_PAD      := Vector4i(24, 20, 24, 28)   # l, t, r, b
const GRABBER        := Vector2i(120, 10)
const GRABBER_GAP    := 24
const TITLE_PX       := 56
const SUB_PX         := 40
const SUB_GAP        := 12
const STAGE_GAP      := 28
const STAGE          := Vector2i(1032, 300)
const STAGE_RADIUS   := 28
const STAGE_BORDER   := 3
const STAGE_CHIP_H   := 60            # StageName 40/900
const WHERE_CHIP_H   := 56            # StageWhere 36/800
const STAGE_CHIP_INSET := 16
const TABS_GAP       := 24
const TAB_H          := 120
const TAB_RADIUS     := 24
const TAB_PAD_X      := 28
const TAB_ICON       := 56
const TAB_INNER_GAP  := 12
const TAB_GAP        := 12
const TAB_FONT       := 40
const TAB_EDGE_KEEP  := 24            # aktivni tab najmanje 24 od ruba pri skrolu
const GRID_GAP_TOP   := 24
const GRID_COLS      := 4
const CARD           := Vector2i(240, 272)
const CARD_GAP       := 24            # 4 x 240 + 3 x 24 = 1032
const CARD_PAD       := 12
const CARD_RADIUS    := 28
const CARD_PREVIEW   := Vector2i(210, 150)
const CARD_PREVIEW_RADIUS := 18
const CARD_NAME_PX   := 38
const CARD_NAME_LINE := 40            # 2 reda max, balance, bez skraćivanja
const BADGE          := 60            # EquippedBadge, rub 4 krem, kvačica 5 px
const BADGE_INSET    := 18
const NEW_TAG_H      := 52            # 34/900
const EMPTY_SPAN     := 3             # EmptyState preko 3 kolone (768 x 272)
const SHOP_BTN_H     := 120
const CLOSE_H        := 132
const CLOSE_GAP      := 28
const GRID_VIEW_H    := 477           # 1326 − 3 − 48 − ostalo; 1 red + 181
const MIN_TEXT       := 34
const MIN_TOUCH      := 120

# ── Tajminzi (s) ──────────────────────────────────────────────────────────────
const T_PRESS        := 0.08
const T_OPEN         := 0.32          # sheet +1326 → 0, ease out cubic; scrim 0 → .55
const T_CLOSE        := 0.28          # 0 → +1326, ease in cubic
const DRAG_CLOSE_PX  := 160
const T_SNAP         := 0.18
const T_STAGE_HOP    := 0.28          # stage Pip 1 → 1.12 → 1, y −11 % visine
const STAGE_HOP_SCALE := 1.12
const T_APPLY_DELAY  := 0.04
const T_FIELD_HOP    := 0.28          # = Arena COMBO.pip.hop
const FIELD_HOP_SCALE := 1.18
const FIELD_HOP_Y    := 28
const T_RING         := 0.50
const RING_R         := Vector2(90, 220)
const RING_W         := 10
const T_TOAST_IN     := 0.18
const T_TOAST_HOLD   := 2.6
const TOAST_Y        := 1110
const TOAST_H        := 100

# ── Stanja kartice (stringovi za smoke testove) ───────────────────────────────
const CARD_WORN  := "worn"
const CARD_OWNED := "owned"
const CARD_NONE  := "none"     # samo source != "shop"
const PREVIEW_KINDS: Array[String] = ["companion", "meadow", "album", "swatch"]


# ── Pravila (gradi se iz kataloga) ────────────────────────────────────────────

## Da li se stavka crta u mreži: Shop stavke samo kad su tvoje; ostali izvori pod velom.
static func item_visible(item: Dictionary, owned: bool) -> bool:
	return owned or str(item.get("source", "shop")) != "shop"


static func card_state(item_id: String, owned: bool, worn_id: String) -> String:
	if not owned:
		return CARD_NONE
	return CARD_WORN if item_id == worn_id else CARD_OWNED


## Ćelije mreže jednog slota: "" = Default, id = stavka, "@shop" = ShopLink, "@empty" = EmptyState.
static func grid_cells(slot: Dictionary, items: Array, owned_ids: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	if bool(slot.get("allow_default", true)):
		out.append("")
	var any_owned := false
	for it in items:
		var own := owned_ids.has(it.id)
		any_owned = any_owned or own
		if item_visible(it, own):
			out.append(str(it.id))
	out.append("@shop" if any_owned else "@empty")
	return out


static func grid_rows(cells: PackedStringArray) -> int:
	var n := 0
	for c in cells:
		n += EMPTY_SPAN if c == "@empty" else 1
	return int(ceil(float(n) / GRID_COLS))


static func cell_pos(index: int) -> Vector2i:
	return Vector2i((index % GRID_COLS) * (CARD.x + CARD_GAP), (index / GRID_COLS) * (CARD.y + CARD_GAP))


## Tabovi: fill ako sve stane u 1032, inače prirodna širina + skrol.
static func tab_width(label_px: float) -> int:
	return TAB_PAD_X * 2 + TAB_ICON + TAB_INNER_GAP + int(ceil(label_px))


static func tabs_fill(widths: Array) -> bool:
	var total := 0
	for w in widths:
		total += int(w)
	total += TAB_GAP * maxi(0, widths.size() - 1)
	return total <= STAGE.x


## Tekst "gdje se vidi" iz slot.applies_to (bez "shop", bez duplikata).
static func where_text(applies_to: Array, surfaces: Dictionary) -> String:
	var seen: Array[String] = []
	for s in applies_to:
		if s == "shop":
			continue
		var l := str(surfaces.get(s, s))
		if not seen.has(l):
			seen.append(l)
	return " · ".join(seen)


## Toast poslije zatvaranja: samo za slotove koji se NE vide na polju (Pip skače umjesto toga).
static func toast_text(changed: Array, slots: Dictionary, pending: Dictionary) -> String:
	var off: Array = []
	for s in changed:
		if not (slots[s].applies_to as Array).has("field"):
			off.append(s)
	if off.is_empty():
		return ""
	if off.size() > 1:
		return "New looks are on"
	var sl: Dictionary = slots[off[0]]
	var id := str(pending.get(off[0], ""))
	var title := CosmeticCatalog.get_title(id) if not id.is_empty() else str(sl.default_title)
	return str(sl.toast).replace("{title}", title)


## Pravilo dvostrukog ruba za skin: L(tijelo) >= L(#A8E6CF) → najgori slučaj >= 3,00 : 1.
static func skin_body_ok(body: Color) -> bool:
	return _lum(body) >= _lum(Color("a8e6cf")) - 0.0005


static func _lum(c: Color) -> float:
	var l := c.srgb_to_linear()
	return 0.2126 * l.r + 0.7152 * l.g + 0.0722 * l.b


# ── StyleBoxFlat ──────────────────────────────────────────────────────────────
static func _box(fill: Color, radius: int, border: int = 0, edge: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.set_corner_radius_all(radius)
	s.corner_detail = 12
	s.anti_aliasing = true
	if border > 0:
		s.set_border_width_all(border)
		s.border_color = edge
	return s


## WardrobeButton = UiHomeField.tile(); glyph = UiHomeField.tile_icon(PINK).
static func wardrobe_glyph() -> StyleBoxFlat:
	return _box(PINK, 18, 3, STICKER_EDGE)


static func sheet() -> StyleBoxFlat:
	return UiHomeField.picker_sheet()


static func stage() -> StyleBoxFlat:
	return _box(Color.TRANSPARENT, STAGE_RADIUS, STAGE_BORDER, STICKER_EDGE)


static func label_chip(radius: int = 18) -> StyleBoxFlat:
	return _box(LABEL_CHIP, radius, 2, LABEL_CHIP_EDGE)


static func tab(active: bool) -> StyleBoxFlat:
	return _box(PEACH, TAB_RADIUS, 3, STICKER_EDGE) if active else _box(ROW_FILL, TAB_RADIUS, 3, ROW_EDGE)


static func card(state: String) -> StyleBoxFlat:
	match state:
		CARD_WORN:
			return _box(ACTIVE_RIM, CARD_RADIUS, 4, STICKER_EDGE)
		CARD_NONE:
			return _box(DISABLED, CARD_RADIUS, 3, DISABLED_EDGE)
		_:
			return _box(ROW_FILL, CARD_RADIUS, 3, ROW_EDGE)


static func card_ink(state: String) -> Color:
	return INK_SOFT if state == CARD_NONE else INK


static func preview_frame() -> StyleBoxFlat:
	return _box(WELL_EDGE, CARD_PREVIEW_RADIUS, 3, WELL_EDGE)


static func badge() -> StyleBoxFlat:
	return _box(INK, BADGE / 2, 4, STICKER)


static func new_tag() -> StyleBoxFlat:
	return _box(MINT, 16, 3, STICKER_EDGE)


## ShopLink kartica i EmptyState: isprekidan rub se crta u _draw() (dash 14 / gap 10, 3 px) — StyleBox nema dash.
static func dashed_cell() -> StyleBoxFlat:
	var s := _box(Color.TRANSPARENT, CARD_RADIUS)
	s.draw_center = false
	return s


static func shop_button(pressed: bool = false) -> StyleBoxFlat:
	var s := _box(ROW_FILL, 28, 3, STICKER_EDGE)
	s.shadow_color = STICKER_DROP
	s.shadow_size = 1
	s.shadow_offset = Vector2(0, 2 if pressed else 6)
	return s


static func close_button(pressed: bool = false) -> StyleBoxFlat:
	return _box(DISABLED if pressed else STICKER, 28, 3, STICKER_EDGE)


static func toast() -> StyleBoxFlat:
	return _box(TOAST_BG, 28)


# ── Tweenovi ──────────────────────────────────────────────────────────────────
static func tween_open(sheet_node: Control, scrim: Control) -> Tween:
	sheet_node.position.y = UiHomeField.PAGE.y
	scrim.modulate.a = 0.0
	var t := sheet_node.create_tween().set_parallel()
	t.tween_property(sheet_node, "position:y", float(UiHomeField.PAGE.y - SHEET_H), T_OPEN).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(scrim, "modulate:a", 1.0, T_OPEN * 0.62)
	return t


static func tween_close(sheet_node: Control, scrim: Control) -> Tween:
	var t := sheet_node.create_tween().set_parallel()
	t.tween_property(sheet_node, "position:y", float(UiHomeField.PAGE.y), T_CLOSE).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(scrim, "modulate:a", 0.0, T_CLOSE)
	return t


## ApplyMoment na polju: Pip skok u novom skinu (pivot = stopala).
static func tween_field_hop(pip: Control) -> Tween:
	pip.pivot_offset = Vector2(pip.size.x * 0.5, pip.size.y)
	var t := pip.create_tween()
	t.tween_interval(T_APPLY_DELAY)
	t.tween_property(pip, "scale", Vector2.ONE * FIELD_HOP_SCALE, T_FIELD_HOP * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(pip, "position:y", pip.position.y - FIELD_HOP_Y, T_FIELD_HOP * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(pip, "scale", Vector2.ONE, T_FIELD_HOP * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(pip, "position:y", pip.position.y, T_FIELD_HOP * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return t


## ApplyRing: Control koji crta elipsu (r, 0.42 r) rubom RING_W; tween r i alpha. Nije loop.
static func tween_ring(ring: Control) -> Tween:
	ring.set_meta("r", RING_R.x)
	ring.modulate.a = 1.0
	var t := ring.create_tween().set_parallel()
	t.tween_method(func(r: float) -> void:
		ring.set_meta("r", r)
		ring.queue_redraw(), RING_R.x, RING_R.y, T_RING).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(ring, "modulate:a", 0.0, T_RING)
	return t
