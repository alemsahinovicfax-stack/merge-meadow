class_name HomeSeasonCard
extends Control

## Kartica sezone 1032 x 1100 (design_handoff_home_v2 · SeasonCard.dc.html):
## SeasonArt (flex), SeasonTitle 170, SeasonRoster 236 / 2 x 214 i jedna akcija
## po stanju. Kartica samo crta; SeasonStage prima dodir i hit_part() kaze sta
## je pogodjeno, pa press_part() salje signal.

signal tapped(season_id: String)
signal open_field_pressed(season_id: String)
signal unlock_pressed(season_id: String)
signal cta_pressed(season_id: String)
signal page_pressed(delta: int)

const ST_ACTIVE := "active"
const ST_OPEN := "open"
const ST_GATHER := "gather"
const ST_READY := "ready"
const ST_UNLOCKING := "unlocking"
const ST_FAR := "far"
const ST_PREMIUM := "premium"
const ST_PURCHASING := "purchasing"
const ST_SOON := "soon"
const GATE_STATES: Array[String] = [ST_GATHER, ST_READY, ST_UNLOCKING, ST_FAR]

const PART_NONE := ""
const PART_CARD := "card"
const PART_PREV := "prev"
const PART_NEXT := "next"
const PART_OPEN := "open"
const PART_UNLOCK := "unlock"
const PART_BUY := "buy"

const PH_DIR := "res://assets/ui/home/flowers/ph_"
const ARROW_EDGE := Color(1.0, 0.973, 0.941, 0.6)
const WELL_EDGE_55 := Color(1.0, 0.973, 0.941, 0.55)
const ICON_EDGE_40 := Color(1.0, 0.973, 0.941, 0.4)
const PREVIEW_RIM := Color(1.0, 0.973, 0.941, 0.5)
const BADGE_EDGE := Color(1.0, 0.973, 0.941, 0.55)
const BADGE_EDGE_PREMIUM := Color(0.831, 0.647, 1.0, 0.8)
const DISABLED_ARROW := 0.3
const SOON_TILE := 0.8

static var _art_cache: Dictionary = {}
static var _mono: Font = null

var season_id: String = ""
var state: String = ST_ACTIVE
var _data: Dictionary = {}
var _pressed_part: String = PART_NONE
var _unlock_t: float = 1.0
var _drain_t: float = 1.0
var _anim: Tween

var _rim: int = UiStage.RIM_ACTIVE
var _art := Rect2()
var _title := Rect2()
var _roster := Rect2()
var _action := Rect2()
var _tiles: Array[Rect2] = []
var _shown: Array[Dictionary] = []
var _prev := Rect2()
var _next := Rect2()
var _coin_row := Rect2()
var _flower_row := Rect2()
var _unlock_btn := Rect2()
var _price := Rect2()
var _buy := Rect2()


func _init() -> void:
	name = "SeasonCard"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = UiStage.CARD.size
	custom_minimum_size = UiStage.CARD.size


## data: season_id, state, name, tagline, kind (free|paid), order, roster
## [{id, name, rarity}], coins, coins_need, flowers, flowers_need, gate_type_id,
## gate_name, gate_mood, prev_name, price, prev_on, next_on.
func configure(data: Dictionary) -> void:
	_data = data
	season_id = str(data.get("season_id", ""))
	state = str(data.get("state", ST_ACTIVE))
	if state != ST_UNLOCKING:
		_stop_anim()
	_layout()
	queue_redraw()


func play_unlock() -> void:
	_stop_anim()
	_unlock_t = 0.0
	_drain_t = 0.0
	queue_redraw()
	if not is_inside_tree():
		_unlock_t = 1.0
		_drain_t = 1.0
		return
	_anim = create_tween().set_parallel(true)
	_anim.tween_method(_set_unlock_t, 0.0, 1.0, UiStage.T_UNLOCK).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_anim.tween_method(_set_drain_t, 0.0, 1.0, UiStage.T_DRAIN)


func is_unlock_playing() -> bool:
	return _anim != null and _anim.is_valid() and _anim.is_running()


func set_pressed_part(part: String) -> void:
	if _pressed_part == part:
		return
	_pressed_part = part
	queue_redraw()


## Dio kartice pod tackom `p` (lokalne koordinate kartice).
func hit_part(p: Vector2) -> String:
	if not Rect2(Vector2.ZERO, size).has_point(p):
		return PART_NONE
	if _hit_rect(_prev).has_point(p):
		return PART_PREV if _on("prev_on") else PART_NONE
	if _hit_rect(_next).has_point(p):
		return PART_NEXT if _on("next_on") else PART_NONE
	if has_open_button() and _action.has_point(p):
		return PART_OPEN
	if is_gate() and _unlock_btn.has_point(p):
		return PART_UNLOCK
	if _is_premium_actions() and _buy.has_point(p):
		return PART_BUY
	return PART_CARD


func press_part(part: String) -> void:
	match part:
		PART_PREV:
			page_pressed.emit(-1)
		PART_NEXT:
			page_pressed.emit(1)
		PART_OPEN:
			open_field_pressed.emit(season_id)
		PART_UNLOCK:
			if state == ST_READY:
				unlock_pressed.emit(season_id)
		PART_BUY:
			if state == ST_PREMIUM:
				cta_pressed.emit(season_id)
		PART_CARD:
			tapped.emit(season_id)


# --- getteri (stage + smoke) ---

func is_active() -> bool:
	return state == ST_ACTIVE


func is_gate() -> bool:
	return state in GATE_STATES


func is_six() -> bool:
	return state in [ST_PREMIUM, ST_PURCHASING, ST_SOON]


func has_open_button() -> bool:
	return state == ST_ACTIVE or state == ST_OPEN


func has_lock() -> bool:
	return state in [ST_GATHER, ST_READY, ST_FAR]


func has_roster() -> bool:
	return not _shown.is_empty()


func shown_flower_count() -> int:
	return _shown.size()


func shown_flower_names() -> PackedStringArray:
	var out := PackedStringArray()
	for entry in _shown:
		out.append(str(entry.get("name", "")))
	return out


func get_badge_text() -> String:
	return str(_badge()[0])


func has_playing_badge() -> bool:
	return state == ST_ACTIVE


func get_meta_text() -> String:
	if str(_data.get("kind", "free")) == "paid":
		return "PREMIUM PACK"
	return "FREE · %d OF %d" % [int(_data.get("order", 1)), int(_data.get("free_total", 4))]


func get_count_text() -> String:
	var total := (_data.get("roster", []) as Array).size()
	return "%d flowers" % total if is_six() else "%d flowers · %d shown" % [total, _shown.size()]


func get_unlock_title() -> String:
	return str(_unlock_texts()[0]) if is_gate() else ""


func get_unlock_sub() -> String:
	return str(_unlock_texts()[1]) if is_gate() else ""


func is_unlock_enabled() -> bool:
	return state == ST_READY


func get_buy_title() -> String:
	if not _is_premium_actions():
		return ""
	return "Waiting for store…" if state == ST_PURCHASING else "Get %s" % _name()


func get_buy_sub() -> String:
	if not _is_premium_actions():
		return ""
	return "you can keep playing" if state == ST_PURCHASING else "yours to keep"


func is_buy_enabled() -> bool:
	return state == ST_PREMIUM


func get_price_text() -> String:
	return str(_data.get("price", "")) if _is_premium_actions() else ""


func get_info_title() -> String:
	return "Coming soon" if state == ST_SOON else ""


func get_coin_text() -> String:
	return "%d / %d" % [_coins(), _int("coins_need")] if is_gate() else ""


func get_flower_text() -> String:
	return "%d / %d" % [_flowers(), _int("flowers_need")] if is_gate() else ""


func get_fill_color() -> Color:
	return _fill()


func get_rim_width() -> int:
	return _rim


func get_part_rect(part: String) -> Rect2:
	match part:
		PART_PREV:
			return _prev
		PART_NEXT:
			return _next
		PART_OPEN:
			return _action if has_open_button() else Rect2()
		PART_UNLOCK:
			return _unlock_btn if is_gate() else Rect2()
		PART_BUY:
			return _buy if _is_premium_actions() else Rect2()
		"art":
			return _art
		"title":
			return _title
		"roster":
			return _roster
		"action":
			return _action
	return Rect2()


# --- raspored (SeasonCard.dc.html · flex column, gap 22) ---

func _layout() -> void:
	_rim = UiStage.RIM_ACTIVE if state == ST_ACTIVE else UiStage.RIM_PREVIEW
	var inset := float(_rim) + UiStage.CARD_PAD
	var content := Rect2(inset, inset, size.x - inset * 2.0, size.y - inset * 2.0)
	var six := is_six()
	var roster_h := UiStage.TILE_H_SIX * 2.0 + UiStage.TILE_ROW_GAP if six else UiStage.TILE_H
	var action_h := UiStage.ACTION_H
	if is_gate():
		action_h = UiStage.GATE_ROW_H * 2.0 + UiStage.GATE_GAP * 2.0 + UiStage.UNLOCK_H
	var gap := UiStage.CARD_GAP
	var art_h := content.size.y - gap * 3.0 - UiStage.TITLE_H - roster_h - action_h
	_art = Rect2(content.position, Vector2(content.size.x, art_h))
	_title = Rect2(content.position.x, _art.end.y + gap, content.size.x, UiStage.TITLE_H)
	_roster = Rect2(content.position.x, _title.end.y + gap, content.size.x, roster_h)
	_action = Rect2(content.position.x, _roster.end.y + gap, content.size.x, action_h)

	_shown = _pick_roster(six)
	_tiles.clear()
	var tile_h := UiStage.TILE_H_SIX if six else UiStage.TILE_H
	var tile_w := (content.size.x - UiStage.TILE_COL_GAP * 2.0) / 3.0
	for i in _shown.size():
		var col := i % 3
		var row := floori(i / 3.0)
		_tiles.append(Rect2(
			_roster.position.x + float(col) * (tile_w + UiStage.TILE_COL_GAP),
			_roster.position.y + float(row) * (tile_h + UiStage.TILE_ROW_GAP),
			tile_w, tile_h
		))

	var arrow_y := _art.end.y - 16.0 - UiStage.ARROW_D
	_prev = Rect2(_art.position.x + 20.0, arrow_y, UiStage.ARROW_D, UiStage.ARROW_D)
	_next = Rect2(_art.end.x - 20.0 - UiStage.ARROW_D, arrow_y, UiStage.ARROW_D, UiStage.ARROW_D)

	_coin_row = Rect2(_action.position, Vector2(_action.size.x, UiStage.GATE_ROW_H))
	_flower_row = Rect2(_action.position.x, _coin_row.end.y + UiStage.GATE_GAP, _action.size.x, UiStage.GATE_ROW_H)
	_unlock_btn = Rect2(_action.position.x, _flower_row.end.y + UiStage.GATE_GAP, _action.size.x, UiStage.UNLOCK_H)
	_price = Rect2(_action.position, Vector2(UiStage.PRICE_W, UiStage.ACTION_H))
	var buy_x := _price.end.x + 16.0
	_buy = Rect2(buy_x, _action.position.y, _action.end.x - buy_x, UiStage.ACTION_H)


## 3 cvijeta = prvi ★1, prvi ★2 i ★3 (idx 0, 3, 5 u katalogu); preview = svih 6.
func _pick_roster(six: bool) -> Array[Dictionary]:
	var roster: Array = _data.get("roster", [])
	var out: Array[Dictionary] = []
	if six:
		for entry in roster:
			out.append(entry)
		return out
	for rarity in [1, 2, 3]:
		for entry in roster:
			if int((entry as Dictionary).get("rarity", 1)) == rarity:
				out.append(entry)
				break
	return out


func _hit_rect(r: Rect2) -> Rect2:
	var grow := (UiStage.ARROW_HIT - UiStage.ARROW_D) * 0.5
	return r.grow(grow)


# --- crtanje ---

func _draw() -> void:
	var fill := _fill()
	var ink := SeasonColors.ink(fill)
	var sub := SeasonColors.sub_ink(fill)
	var body := Rect2(Vector2.ZERO, size)
	draw_style_box(UiStage.box(UiStage.CARD_DROP, UiStage.CARD_RADIUS), Rect2(0.0, UiStage.CARD_DROP_Y, size.x, size.y))
	var rim_color := UiStage.RIM if state == ST_ACTIVE else UiStage.over(fill, PREVIEW_RIM)
	draw_style_box(UiStage.box(fill, UiStage.CARD_RADIUS, _rim, rim_color), body)
	_draw_art(fill, sub)
	_draw_title(ink, sub)
	_draw_roster(fill)
	if has_open_button():
		_draw_open_meadow()
	elif is_gate():
		_draw_gate(fill)
	elif _is_premium_actions():
		_draw_premium(fill)
	elif state == ST_SOON:
		_draw_info(fill)


func _draw_art(fill: Color, sub: Color) -> void:
	var r := _art
	draw_style_box(UiStage.box(SeasonColors.art_slot(fill), UiStage.ART_RADIUS), r)
	var clip := UiStage.rounded_rect_points(r, float(UiStage.ART_RADIUS))
	UiStage.draw_stripes(self, r, clip, UiStage.STRIPE)
	_draw_slot_label(r, sub)
	var center := r.get_center()
	if state == ST_UNLOCKING:
		_draw_ring(center, clip)
		_draw_disc(center, UiStage.COIN, UiAssets.get_chrome_icon("icon_coin"), 84.0)
	elif has_lock():
		_draw_disc(center, UiStage.CREAM, UiAssets.get_chrome_icon("icon_lock"), 80.0)
	_draw_badge(r)
	var slot := SeasonColors.art_slot(fill)
	_draw_arrow(_prev, true, _on("prev_on"), slot)
	_draw_arrow(_next, false, _on("next_on"), slot)


## "season illustration · 996 × H" (22 px mono) dok ne stigne ilustracija.
func _draw_slot_label(r: Rect2, color: Color) -> void:
	var mono := _mono_font()
	var text := "SEASON ILLUSTRATION · 996 × %d" % _slot_label_h()
	var w := mono.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	var top := r.end.y - 18.0 - 22.0
	var base := top + (22.0 + mono.get_ascent(22) - mono.get_descent(22)) * 0.5
	draw_string(mono, Vector2(r.end.x - 22.0 - w, base), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, color)


## Visina iz formule u SeasonCard.dc.html (tekst placeholdera, ne stvarni rect).
func _slot_label_h() -> int:
	var tiles := UiStage.TILE_H_SIX * 2.0 + UiStage.TILE_ROW_GAP if is_six() else UiStage.TILE_H
	var action := 316.0 if is_gate() else UiStage.ACTION_H
	return roundi(1100.0 - 16.0 - 36.0 - UiStage.CARD_GAP * 3.0 - UiStage.TITLE_H - tiles - action)


func _draw_disc(center: Vector2, fill: Color, icon: Texture2D, icon_side: float) -> void:
	var d := UiStage.LOCK_D
	draw_style_box(UiStage.box(fill, int(d * 0.5), 4, UiStage.INK), Rect2(center - Vector2(d, d) * 0.5, Vector2(d, d)))
	if icon:
		draw_texture_rect(icon, Rect2(center - Vector2(icon_side, icon_side) * 0.5, Vector2(icon_side, icon_side)), false)


## Prsten 520 px (rub 28) raste od 0,2 do 1; overflow:hidden reze ga na slotu.
func _draw_ring(center: Vector2, clip: PackedVector2Array) -> void:
	var s := lerpf(0.2, 1.0, _unlock_t)
	var outer := UiStage.RING_D * 0.5 * s
	var inner := outer - UiStage.RING_W * s
	var steps := 72
	for i in steps:
		var a0 := TAU * float(i) / float(steps)
		var a1 := TAU * float(i + 1) / float(steps)
		var quad := PackedVector2Array([
			center + Vector2(cos(a0), sin(a0)) * outer,
			center + Vector2(cos(a1), sin(a1)) * outer,
			center + Vector2(cos(a1), sin(a1)) * inner,
			center + Vector2(cos(a0), sin(a0)) * inner,
		])
		UiStage.draw_clipped(self, quad, clip, UiStage.RING)


func _draw_badge(r: Rect2) -> void:
	var spec := _badge()
	var text := str(spec[0])
	var play := bool(spec[1])
	var f := UiStage.font(900, 38, 1.0, 0.05)
	var icon_w := 50.0 if play else 0.0
	var w := 3.0 + UiStage.BADGE_PAD + icon_w + UiStage.text_w(f, 38, text) + UiStage.BADGE_PAD + 3.0
	var br := Rect2(r.position + Vector2(22.0, 22.0), Vector2(w, UiStage.BADGE_H))
	draw_style_box(UiStage.box(spec[2], int(UiStage.BADGE_H * 0.5), 3, spec[4]), br)
	var top := br.position.y + (UiStage.BADGE_H - 38.0) * 0.5
	var base := UiStage.baseline(f, 38, top)
	var x := br.position.x + 3.0 + UiStage.BADGE_PAD
	if play:
		UiStage.draw_play(self, Rect2(x + 1.0, base - 13.3 - 15.0, 29.0, 30.0), spec[3])
	draw_string(f, Vector2(x + icon_w, base), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, spec[3])


## [tekst, ▶, fill, ink, rub] — ActiveBadge iz SeasonCard.dc.html.
func _badge() -> Array:
	var dark := UiStage.CHROME
	match state:
		ST_ACTIVE:
			return ["PLAYING", true, UiStage.RIM, UiStage.INK, UiStage.INK]
		ST_OPEN:
			var label := "PREVIEW · OWNED" if str(_data.get("kind", "free")) == "paid" else "PREVIEW · UNLOCKED"
			return [label, false, dark, UiStage.CREAM, UiStage.over(dark, BADGE_EDGE)]
		ST_PREMIUM, ST_PURCHASING:
			return ["PREVIEW · PREMIUM", false, dark, UiStage.LAVENDER, UiStage.over(dark, BADGE_EDGE_PREMIUM)]
		ST_SOON:
			return ["COMING SOON", false, dark, UiStage.CREAM, UiStage.over(dark, BADGE_EDGE)]
	return ["PREVIEW · LOCKED", false, dark, UiStage.CREAM, UiStage.over(dark, BADGE_EDGE)]


## Iskljucena strelica ima `opacity:.3` na cijeloj grupi: krug i rub su 30 %
## preko slota, a chevron dobija gotovu boju (cream 30 % preko slota).
func _draw_arrow(r: Rect2, left: bool, enabled: bool, slot: Color) -> void:
	var a := 1.0 if enabled else DISABLED_ARROW
	var bg := UiStage.CHROME
	var edge := UiStage.over(bg, ARROW_EDGE)
	var s := UiStage.box(Color(bg, a), int(UiStage.ARROW_D * 0.5), 3, Color(edge, a))
	if enabled and _pressed_part == (PART_PREV if left else PART_NEXT):
		s.bg_color = bg.lightened(0.12)
	draw_style_box(s, r)
	var chevron := UiStage.CREAM if enabled else slot.lerp(UiStage.CREAM, DISABLED_ARROW)
	UiStage.draw_chevron(self, r.get_center(), left, chevron)


func _draw_title(ink: Color, sub: Color) -> void:
	var t := _title
	var f_meta := UiStage.font(900, 38, 1.0, 0.06)
	draw_string(f_meta, Vector2(t.position.x, UiStage.baseline(f_meta, 38, t.position.y)), get_meta_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 38, sub)
	var f_count := UiStage.font(900, 38)
	var count := get_count_text()
	var cw := UiStage.text_w(f_count, 38, count)
	draw_string(f_count, Vector2(t.end.x - cw, UiStage.baseline(f_count, 38, t.position.y)), count, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, sub)
	var tag_h := 38.0 * 1.15
	var gap := (UiStage.TITLE_H - 38.0 - 80.0 - tag_h) * 0.5
	var f_name := UiStage.font(900, 80, 1.0, -0.015)
	draw_string(f_name, Vector2(t.position.x, UiStage.baseline(f_name, 80, t.position.y + 38.0 + gap)), _name(), HORIZONTAL_ALIGNMENT_LEFT, t.size.x, 80, ink)
	var f_tag := UiStage.font(700, 38, 1.15)
	var tag_top := t.end.y - f_tag.get_height(38)
	draw_string(f_tag, Vector2(t.position.x, UiStage.baseline(f_tag, 38, tag_top)), str(_data.get("tagline", "")), HORIZONTAL_ALIGNMENT_LEFT, t.size.x, 38, sub)


func _draw_roster(fill: Color) -> void:
	var six := is_six()
	var soon := state == ST_SOON
	var mood := SeasonColors.mood_of(season_id)
	var well_d := UiStage.WELL_D_SIX if six else UiStage.WELL_D
	var f_name := UiStage.font(800, 38, 1.05)
	var f_pill := UiStage.font(900, 40)
	var ink := _tile_color(UiStage.INK, fill, soon)
	for i in _tiles.size():
		var tile := _tiles[i]
		var entry := _shown[i]
		draw_style_box(UiStage.box(_tile_color(UiStage.CREAM, fill, soon), 24, 3, _tile_color(UiStage.TILE_EDGE, fill, soon)), tile)
		var rarity := clampi(int(entry.get("rarity", 1)), 1, 3)
		var digit := str(rarity)
		var pill_w := 47.0 + UiStage.text_w(f_pill, 40, digit) + 12.0
		var pill := Rect2(tile.end.x - 13.0 - pill_w, tile.position.y + 13.0, pill_w, 52.0)
		draw_style_box(UiStage.box(_tile_color(UiStage.PILL[rarity], fill, soon), 16), pill)
		UiStage.draw_star(self, Vector2(pill.position.x + 28.75, pill.get_center().y - 2.0), 16.0, ink)
		draw_string(f_pill, Vector2(pill.position.x + 47.0, UiStage.baseline(f_pill, 40, pill.position.y + 6.0)), digit, HORIZONTAL_ALIGNMENT_LEFT, -1, 40, ink)
		var well := Rect2(tile.get_center().x - well_d * 0.5, tile.end.y - 103.0 - well_d, well_d, well_d)
		draw_style_box(UiStage.box(_tile_color(UiStage.WELL, fill, soon), int(well_d * 0.5), 3, _tile_color(UiStage.TILE_WELL_EDGE, fill, soon)), well)
		var inner := well_d - 6.0
		var tex := _flower_art(str(entry.get("id", "")))
		if tex != null:
			var side := inner * 0.86
			draw_texture_rect(tex, Rect2(well.get_center() - Vector2(side, side) * 0.5, Vector2(side, side)), false, Color(1, 1, 1, SOON_TILE if soon else 1.0))
		else:
			var dot := inner * 0.56
			var dot_fill := UiStage.SOON_DOT if soon else mood
			draw_style_box(
				UiStage.box(_tile_color(dot_fill, fill, soon), int(dot * 0.5), 6, _tile_color(SeasonColors.dot_edge(mood), fill, soon)),
				Rect2(well.get_center() - Vector2(dot, dot) * 0.5, Vector2(dot, dot))
			)
		var max_w := tile.size.x - 6.0 - 28.0
		var lines := UiStage.balance_lines(str(entry.get("name", "")), f_name, 38, max_w)
		var line_h := f_name.get_height(38)
		var box_top := tile.end.y - 15.0 - 80.0
		var top := box_top + (80.0 - line_h * float(lines.size())) * 0.5
		for line in lines:
			var lw := UiStage.text_w(f_name, 38, line)
			draw_string(f_name, Vector2(tile.get_center().x - lw * 0.5, UiStage.baseline(f_name, 38, top)), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, ink)
			top += line_h


## Coming-soon plocica ima `opacity:.8` na cijeloj grupi: svaka boja 20 % ka ispuni kartice.
func _tile_color(c: Color, fill: Color, soon: bool) -> Color:
	return fill.lerp(c, SOON_TILE) if soon else c


func _draw_open_meadow() -> void:
	var r := _action
	var fill := UiStage.CREAM.darkened(0.05) if _pressed_part == PART_OPEN else UiStage.CREAM
	draw_style_box(UiStage.box(fill, 26, 3, UiStage.INK), r)
	var f_title := UiStage.font(900, 46)
	draw_string(f_title, Vector2(r.position.x + 39.0, UiStage.baseline(f_title, 46, r.position.y + (r.size.y - 46.0) * 0.5)), "Open meadow", HORIZONTAL_ALIGNMENT_LEFT, -1, 46, UiStage.INK)
	var f_sub := UiStage.font(800, 38)
	var base := UiStage.baseline(f_sub, 38, r.position.y + (r.size.y - 38.0) * 0.5)
	var arrow := Rect2(r.end.x - 39.0 - 2.5 - 22.5, base - 23.0, 22.5, 23.0)
	UiStage.draw_ne_arrow(self, arrow, 3.6, UiStage.INK_SOFT)
	var text := "field · upgrades"
	var w := UiStage.text_w(f_sub, 38, text)
	draw_string(f_sub, Vector2(arrow.position.x - 14.5 - w, base), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, UiStage.INK_SOFT)


func _draw_gate(fill: Color) -> void:
	var need_c := _int("coins_need")
	var need_f := _int("flowers_need")
	var coin_ratio := float(_coins()) / maxf(float(need_c), 1.0)
	var flower_ratio := float(_flowers()) / maxf(float(need_f), 1.0)
	if state == ST_UNLOCKING:
		coin_ratio *= 1.0 - _drain_t
		flower_ratio *= 1.0 - _drain_t
	_draw_well(_coin_row, coin_ratio, UiStage.COIN)
	_draw_well(_flower_row, flower_ratio, UiStage.CREAM)
	var f_label := UiStage.font(800, 38)
	var f_num := UiStage.font(900, 46)
	var cy := _coin_row.position.y + 44.0
	var coin_disc := Rect2(_coin_row.position.x + 17.0, cy - 32.0, 64.0, 64.0)
	draw_style_box(UiStage.box(UiStage.COIN, 32), coin_disc)
	var coin_icon := UiAssets.get_chrome_icon("icon_coin")
	if coin_icon:
		draw_texture_rect(coin_icon, Rect2(coin_disc.get_center() - Vector2(22, 22), Vector2(44, 44)), false)
	draw_string(f_label, Vector2(coin_disc.end.x + 18.0, UiStage.baseline(f_label, 38, cy - 19.0)), "Coins", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, UiStage.CREAM)
	_draw_number(get_coin_text(), _coins() >= need_c, _coin_row, cy, f_num)

	var fy := _flower_row.position.y + 44.0
	var flower_disc := Rect2(_flower_row.position.x + 17.0, fy - 32.0, 64.0, 64.0)
	draw_style_box(UiStage.box(UiStage.WELL, 32, 2, UiStage.over(UiStage.WELL, ICON_EDGE_40)), flower_disc)
	var gate_tex := _flower_art(str(_data.get("gate_type_id", "")))
	if gate_tex:
		draw_texture_rect(gate_tex, Rect2(flower_disc.get_center() - Vector2(26, 26), Vector2(52, 52)), false)
	else:
		var gate_mood: Color = _data.get("gate_mood", Color("#A8E6CF"))
		draw_style_box(UiStage.box(gate_mood, 16, 5, UiStage.CREAM), Rect2(flower_disc.get_center() - Vector2(16, 16), Vector2(32, 32)))
	var gate_name := str(_data.get("gate_name", ""))
	var name_x := flower_disc.end.x + 18.0
	var base := UiStage.baseline(f_label, 38, fy - 19.0)
	var name_text := gate_name + " "
	draw_string(f_label, Vector2(name_x, base), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, UiStage.CREAM)
	var star_x := name_x + UiStage.text_w(f_label, 38, name_text)
	UiStage.draw_star(self, Vector2(star_x + 14.5, base - 13.5), 14.5, UiStage.COIN)
	draw_string(f_label, Vector2(star_x + 30.0, base), "3", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, UiStage.COIN)
	_draw_number(get_flower_text(), _flowers() >= need_f, _flower_row, fy, f_num)

	var btn := _unlock_btn
	var style: StyleBoxFlat
	match state:
		ST_READY:
			style = UiStage.box(UiStage.GOLD, 26, 4, UiStage.GOLD_EDGE)
			if _pressed_part == PART_UNLOCK:
				style.bg_color = UiStage.GOLD.darkened(0.08)
		ST_UNLOCKING:
			style = UiStage.box(UiStage.COIN, 26, 4, UiStage.GOLD_EDGE)
		_:
			style = UiStage.box(UiStage.MUTED_FILL, 26, 3, _muted_edge(fill))
	draw_style_box(style, btn)
	var texts := _unlock_texts()
	_draw_two_lines(btn, str(texts[0]), str(texts[1]), UiStage.INK, UiStage.INK, 10.0)


func _draw_well(r: Rect2, ratio: float, bar: Color) -> void:
	draw_style_box(UiStage.box(UiStage.CHROME, 22, 3, UiStage.over(UiStage.CHROME, WELL_EDGE_55)), r)
	var inner := r.grow(-3.0)
	var clip := UiStage.rounded_rect_points(inner, 19.0)
	var track := Rect2(inner.position.x, inner.end.y - 12.0, inner.size.x, 12.0)
	UiStage.draw_clipped(self, UiStage.rect_points(track), clip, UiStage.BAR_TRACK)
	var w := track.size.x * clampf(ratio, 0.0, 1.0)
	if w > 0.5:
		UiStage.draw_clipped(self, UiStage.rect_points(Rect2(track.position, Vector2(w, 12.0))), clip, bar)


func _draw_number(text: String, ok: bool, row: Rect2, cy: float, f: Font) -> void:
	var w := UiStage.text_w(f, 46, text)
	draw_string(f, Vector2(row.end.x - 27.0 - w, UiStage.baseline(f, 46, cy - 23.0)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 46, UiStage.COIN if ok else UiStage.CREAM)


func _draw_premium(fill: Color) -> void:
	draw_style_box(UiStage.box(UiStage.PRICE_BG, 26, 3, UiStage.PRICE_EDGE), _price)
	var f_price := UiStage.font(900, 56)
	var f_sub := UiStage.font(800, 38)
	var top := _price.position.y + (_price.size.y - 56.0 - 6.0 - 38.0) * 0.5
	var price := get_price_text()
	draw_string(f_price, Vector2(_price.get_center().x - UiStage.text_w(f_price, 56, price) * 0.5, UiStage.baseline(f_price, 56, top)), price, HORIZONTAL_ALIGNMENT_LEFT, -1, 56, UiStage.INK_DEEP)
	draw_string(f_sub, Vector2(_price.get_center().x - UiStage.text_w(f_sub, 38, "one-time") * 0.5, UiStage.baseline(f_sub, 38, top + 62.0)), "one-time", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, UiStage.PRICE_SUB)
	var style: StyleBoxFlat
	if state == ST_PURCHASING:
		style = UiStage.box(UiStage.MUTED_FILL, 26, 3, _muted_edge(fill))
	else:
		style = UiStage.box(UiStage.LAVENDER, 26, 4, UiStage.INK)
		if _pressed_part == PART_BUY:
			style.bg_color = UiStage.LAVENDER.darkened(0.08)
	draw_style_box(style, _buy)
	_draw_two_lines(_buy, get_buy_title(), get_buy_sub(), UiStage.INK, UiStage.INK, 10.0)


func _draw_info(fill: Color) -> void:
	var r := _action
	draw_style_box(UiStage.box(UiStage.MUTED_FILL, 26, 3, _muted_edge(fill)), r)
	var f_title := UiStage.font(900, 46)
	var f_sub := UiStage.font(800, 38)
	var top := r.position.y + (r.size.y - 46.0 - 8.0 - 38.0) * 0.5
	draw_string(f_title, Vector2(r.position.x + 39.0, UiStage.baseline(f_title, 46, top)), "Coming soon", HORIZONTAL_ALIGNMENT_LEFT, -1, 46, UiStage.INK)
	draw_string(f_sub, Vector2(r.position.x + 39.0, UiStage.baseline(f_sub, 38, top + 54.0)), "no price yet · preview the flowers", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, UiStage.INFO_SUB)


## Naslov 46/900 + podnaslov 38/800, centrirani u koloni (dugmad 130–140).
func _draw_two_lines(r: Rect2, title: String, sub: String, title_ink: Color, sub_ink: Color, gap: float) -> void:
	var f_title := UiStage.font(900, 46)
	var f_sub := UiStage.font(800, 38)
	var top := r.position.y + (r.size.y - 46.0 - gap - 38.0) * 0.5
	var cx := r.get_center().x
	draw_string(f_title, Vector2(cx - UiStage.text_w(f_title, 46, title) * 0.5, UiStage.baseline(f_title, 46, top)), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 46, title_ink)
	draw_string(f_sub, Vector2(cx - UiStage.text_w(f_sub, 38, sub) * 0.5, UiStage.baseline(f_sub, 38, top + 46.0 + gap)), sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, sub_ink)


# --- podaci ---

func _unlock_texts() -> Array:
	var name := _name()
	var gate := str(_data.get("gate_name", ""))
	var need_c := _int("coins_need")
	var need_f := _int("flowers_need")
	match state:
		ST_READY:
			return ["Unlock %s" % name, "spends %d coins + %d %s" % [need_c, need_f, gate]]
		ST_UNLOCKING:
			return ["Unlocking…", "coins and flowers spent"]
		ST_FAR:
			return ["Unlock %s first" % str(_data.get("prev_name", "")), "free seasons open in order"]
	var parts := PackedStringArray()
	if _coins() < need_c:
		parts.append("%d coins" % (need_c - _coins()))
	if _flowers() < need_f:
		parts.append("%d flowers" % (need_f - _flowers()))
	return ["Needs %s" % " + ".join(parts), "run in %s to collect" % str(_data.get("prev_name", ""))]


func _fill() -> Color:
	var mood := SeasonColors.mood_of(season_id)
	if state == ST_UNLOCKING:
		return SeasonColors.locked_fill(mood).lerp(mood, _unlock_t)
	return SeasonColors.card_fill(mood, state)


## Rub mutnog dugmeta: cream 55 % pa rgba(26,26,20,.3) preko ispune kartice.
func _muted_edge(fill: Color) -> Color:
	return UiStage.over(UiStage.over(fill, UiStage.MUTED_FILL), UiStage.MUTED_EDGE)


func _is_premium_actions() -> bool:
	return state == ST_PREMIUM or state == ST_PURCHASING


func _name() -> String:
	return str(_data.get("name", season_id))


func _coins() -> int:
	return mini(_int("coins"), _int("coins_need"))


func _flowers() -> int:
	return mini(_int("flowers"), _int("flowers_need"))


func _int(key: String) -> int:
	return int(_data.get(key, 0))


func _on(key: String) -> bool:
	return bool(_data.get(key, false))


func _set_unlock_t(v: float) -> void:
	_unlock_t = v
	queue_redraw()


func _set_drain_t(v: float) -> void:
	_drain_t = v
	queue_redraw()


func _stop_anim() -> void:
	if _anim:
		_anim.kill()
		_anim = null
	_unlock_t = 1.0
	_drain_t = 1.0


## Art cvijeta: igrin SVG (FlowerAssets T3), pa placeholder iz handoffa, pa tacka.
static func _flower_art(type_id: String) -> Texture2D:
	if type_id.is_empty():
		return null
	if _art_cache.has(type_id):
		return _art_cache[type_id] as Texture2D
	var tex := FlowerAssets.get_texture(type_id, 3)
	if tex == null:
		var path := PH_DIR + type_id + ".svg"
		if ResourceLoader.exists(path):
			tex = load(path) as Texture2D
	_art_cache[type_id] = tex
	return tex


static func _mono_font() -> Font:
	if _mono != null:
		return _mono
	var sys := SystemFont.new()
	sys.font_names = PackedStringArray(["Consolas", "Menlo", "DejaVu Sans Mono", "Droid Sans Mono", "monospace"])
	sys.font_weight = 600
	var fv := FontVariation.new()
	fv.base_font = sys
	fv.spacing_glyph = 2
	_mono = fv
	return _mono
