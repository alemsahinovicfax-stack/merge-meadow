class_name HomeV3CardContent
extends Control

## CardContent (HomeScreen.dc.html): premium rub, lokot, tri cvijeta u diskovima i
## jedan status po stanju. Ime sezone i Pip NISU ovdje — to su putujuci objekti
## (SeasonName, MeadowPip) iznad polja. Kartica samo crta; SeasonStage prima
## dodir, a hit_part() kaze sta je pogodjeno.

const ST_ACTIVE := "active"
const ST_OPEN := "open"
const ST_LOCKED := "locked"
const ST_UNLOCK := "unlock"
const ST_BUY := "buy"
const ST_OWNED := "owned"
const ST_SOON := "soon"

const PART_NONE := ""
const PART_CARD := "card"
const PART_GATE := "gate"
const PART_UNLOCK := "unlock"
const PART_BUY := "buy"

## data: season_id, status, premium, roster [{id, name, missing}], coins,
## coins_need, stars, stars_need, prev_type, price, buying.
var data: Dictionary = {}
var _pressed: String = PART_NONE
var _gate := Rect2()
var _unlock := Rect2()
var _buy := Rect2()
var _chips: Array[Rect2] = []
var _owned := Rect2()
var _soon := Rect2()
var _discs: Array[Rect2] = []
var _arts: Array[FlowerArt] = []


## Crtez cvijeta u disku kao zaseban cvor — modulate daje siluetu (crno .28) i
## prigusenje (.5) i kad sezona jos nema SVG pa se crta proceduralno.
class FlowerArt extends Control:
	var type_id: String = ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		UiHomeV3.draw_flower(self, size * 0.5, type_id, size.x)


func _init() -> void:
	name = "CardContent"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = UiHomeV3.CARD_RECT.size
	for i in UiHomeV3.ROSTER_DISCS.size():
		var art := FlowerArt.new()
		art.name = "RosterArt_%d" % i
		add_child(art)
		_arts.append(art)


func configure(d: Dictionary) -> void:
	data = d
	_layout()
	queue_redraw()


func status() -> String:
	return str(data.get("status", ST_ACTIVE))


func set_pressed_part(part: String) -> void:
	if _pressed == part:
		return
	_pressed = part
	queue_redraw()


## Dio kartice pod tackom `p` (lokalne koordinate sadrzaja).
func hit_part(p: Vector2) -> String:
	if not Rect2(Vector2.ZERO, size).has_point(p):
		return PART_NONE
	match status():
		ST_OPEN:
			if _gate.has_point(p):
				return PART_GATE
		ST_UNLOCK:
			if _unlock.has_point(p):
				return PART_UNLOCK
		ST_BUY:
			if _buy.has_point(p):
				return PART_BUY
	return PART_CARD


func part_rect(part: String) -> Rect2:
	match part:
		PART_GATE:
			return _gate if status() == ST_OPEN else Rect2()
		PART_UNLOCK:
			return _unlock if status() == ST_UNLOCK else Rect2()
		PART_BUY:
			return _buy if status() == ST_BUY else Rect2()
		"owned":
			return _owned if status() == ST_OWNED else Rect2()
		"soon":
			return _soon if status() == ST_SOON else Rect2()
	return Rect2()


func disc_rects() -> Array[Rect2]:
	return _discs.duplicate()


func chip_rects() -> Array[Rect2]:
	return _chips.duplicate() if status() == ST_LOCKED else ([] as Array[Rect2])


func has_lock_badge() -> bool:
	return status() in [ST_LOCKED, ST_UNLOCK, ST_BUY]


func is_dim() -> bool:
	return status() in [ST_LOCKED, ST_SOON]


func missing_names() -> PackedStringArray:
	var out := PackedStringArray()
	for f in _roster():
		if bool(f.get("missing", false)):
			out.append(str(f.get("name", "")))
	return out


func coin_text() -> String:
	return "%d / %d" % [mini(_i("coins"), _i("coins_need")), _i("coins_need")]


func star_text() -> String:
	return "%d / %d" % [mini(_i("stars"), _i("stars_need")), _i("stars_need")]


# --- raspored ---

func _layout() -> void:
	_discs.clear()
	var roster := _roster()
	var total := 0.0
	for d in UiHomeV3.ROSTER_DISCS:
		total += float(d)
	total += UiHomeV3.ROSTER_GAP * float(UiHomeV3.ROSTER_DISCS.size() - 1)
	var x := (size.x - total) * 0.5
	for i in UiHomeV3.ROSTER_DISCS.size():
		var d := float(UiHomeV3.ROSTER_DISCS[i])
		var top := UiHomeV3.ROSTER_TOP + (0.0 if i == 1 else UiHomeV3.ROSTER_SIDE_DROP)
		_discs.append(Rect2(x, top, d, d))
		var art := _arts[i]
		art.position = Vector2(x, top)
		art.size = Vector2(d, d)
		var f: Dictionary = roster[i] if i < roster.size() else {}
		art.visible = not f.is_empty()
		art.type_id = str(f.get("id", ""))
		var miss := bool(f.get("missing", false))
		art.modulate = UiHomeV3.MISSING_ART if miss else (UiHomeV3.DIM_ART if is_dim() else Color.WHITE)
		art.queue_redraw()
		x += d + UiHomeV3.ROSTER_GAP
	var mid := UiHomeV3.STATUS_TOP + UiHomeV3.STATUS_H * 0.5
	var cx := size.x * 0.5
	_gate = Rect2(cx - UiHomeV3.OPEN_GATE * 0.5, mid - UiHomeV3.OPEN_GATE * 0.5, UiHomeV3.OPEN_GATE, UiHomeV3.OPEN_GATE)
	_chips.clear()
	var coin_w := 4.0 + 24.0 + 60.0 + 14.0 + UiHomeV3.text_w(900, 46, coin_text(), 0.0, true) + 36.0 + 4.0
	var star_w := 4.0 + 24.0 + 64.0 + 14.0 + _star3_w() + 14.0 \
		+ UiHomeV3.text_w(900, 46, star_text(), 0.0, true) + 36.0 + 4.0
	var row_w := coin_w + UiHomeV3.NEED_GAP + star_w
	var chip_top := mid - UiHomeV3.NEED_CHIP_H * 0.5
	_chips.append(Rect2(cx - row_w * 0.5, chip_top, coin_w, UiHomeV3.NEED_CHIP_H))
	_chips.append(Rect2(cx - row_w * 0.5 + coin_w + UiHomeV3.NEED_GAP, chip_top, star_w, UiHomeV3.NEED_CHIP_H))
	var unlock_w := 4.0 + 36.0 + 56.0 + 18.0 + UiHomeV3.text_w(900, 54, "Unlock") + 18.0 + 15.0 + 18.0 \
		+ 56.0 + 18.0 + UiHomeV3.text_w(900, 54, str(_i("coins_need")), 0.0, true) + 48.0 + 4.0
	_unlock = Rect2(cx - unlock_w * 0.5, mid - UiHomeV3.ACTION_H * 0.5, unlock_w, UiHomeV3.ACTION_H)
	var buy_w := 4.0 + 40.0 + 64.0 + 18.0 + UiHomeV3.text_w(900, 60, _price(), 0.0, true) + 56.0 + 4.0
	_buy = Rect2(cx - buy_w * 0.5, mid - UiHomeV3.ACTION_H * 0.5, buy_w, UiHomeV3.ACTION_H)
	var owned_w := 4.0 + 36.0 + 31.0 + 18.0 + UiHomeV3.text_w(900, 50, "Yours") + 48.0 + 4.0
	_owned = Rect2(cx - owned_w * 0.5, mid - 60.0, owned_w, 120.0)
	var soon_w := 4.0 + 52.0 + UiHomeV3.text_w(900, 50, "Coming soon") + 52.0 + 4.0
	_soon = Rect2(cx - soon_w * 0.5, mid - 60.0, soon_w, 120.0)


# --- crtanje ---

func _draw() -> void:
	if data.is_empty():
		return
	if bool(data.get("premium", false)):
		var rim := Rect2(Vector2.ZERO, size).grow(-UiHomeV3.PREMIUM_RIM_INSET)
		var sb := UiStage.box(Color.TRANSPARENT, UiHomeV3.PREMIUM_RIM_RADIUS, UiHomeV3.PREMIUM_RIM_WIDTH, UiHomeV3.GOLD)
		sb.draw_center = false
		draw_style_box(sb, rim)
	if has_lock_badge():
		var b := UiHomeV3.LOCK_BADGE
		UiHomeV3.draw_panel(self, b, UiHomeV3.CREAM, b.size.x * 0.5, 4.0)
		_icon("icon_lock", b.get_center(), UiHomeV3.LOCK_ICON)
	_draw_roster()
	match status():
		ST_OPEN:
			_draw_gate()
		ST_LOCKED:
			_draw_needs()
		ST_UNLOCK:
			_draw_unlock()
		ST_BUY:
			_draw_buy()
		ST_OWNED:
			_draw_owned()
		ST_SOON:
			_draw_soon()


func _draw_roster() -> void:
	var roster := _roster()
	var dim := is_dim()
	for i in mini(roster.size(), _discs.size()):
		var f: Dictionary = roster[i]
		var r := _discs[i]
		var miss := bool(f.get("missing", false))
		if miss:
			draw_style_box(UiStage.box(UiHomeV3.MISSING_DISC, roundi(r.size.x * 0.5)), r)
			UiHomeV3.draw_dashed_round_rect(self, r, r.size.x * 0.5, 4.0, UiHomeV3.INK)
		else:
			UiHomeV3.draw_panel(self, r, UiHomeV3.CREAM, r.size.x * 0.5, 4.0)
		if miss:
			_draw_missing_name(str(f.get("name", "")), r)


## Ime cvijeta koji fali: 38/900 ispod diska (gap 18). Duga imena igre idu u dva
## uravnotezena reda da ne predju na susjedni disk.
func _draw_missing_name(text: String, disc: Rect2) -> void:
	var f := UiStage.font(900, UiHomeV3.MISSING_NAME)
	var lines := UiStage.balance_lines(text, f, UiHomeV3.MISSING_NAME, UiHomeV3.MISSING_NAME_MAX_W)
	var top := disc.end.y + UiHomeV3.MISSING_NAME_GAP
	for line in lines:
		var w := UiStage.text_w(f, UiHomeV3.MISSING_NAME, line)
		UiHomeV3.draw_text(self, 900, UiHomeV3.MISSING_NAME, line, Vector2(disc.get_center().x - w * 0.5, top), UiHomeV3.INK_DEEP)
		top += float(UiHomeV3.MISSING_NAME)


## Otkljucana sezona u kojoj se ne igra: krem kapija 150 s peach lukom, bez teksta.
func _draw_gate() -> void:
	var g := _gate
	if _pressed == PART_GATE:
		g = Rect2(g.position + Vector2(0.0, 4.0), g.size)
	UiHomeV3.draw_panel(self, g, UiHomeV3.CREAM, g.size.x * 0.5, 4.0, UiHomeV3.INK, 8.0 if _pressed != PART_GATE else 4.0)
	var arch := UiHomeV3.GATE_ARCH
	var bottom := g.end.y - 4.0 - UiHomeV3.GATE_ARCH_BOTTOM
	var r := Rect2(g.get_center().x - arch.x * 0.5, bottom - arch.y, arch.x, arch.y)
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiHomeV3.PEACH
	sb.corner_radius_top_left = 36
	sb.corner_radius_top_right = 36
	sb.corner_detail = 16
	sb.anti_aliasing = true
	sb.border_color = UiHomeV3.INK
	sb.border_width_left = 4
	sb.border_width_top = 4
	sb.border_width_right = 4
	draw_style_box(sb, r)


func _draw_needs() -> void:
	var coin_ok := _i("coins") >= _i("coins_need")
	var star_ok := _i("stars") >= _i("stars_need")
	var c := _chips[0]
	UiHomeV3.draw_panel(self, c, UiHomeV3.MINT if coin_ok else UiHomeV3.CREAM, 60.0, 4.0)
	var x := c.position.x + 4.0 + 24.0
	var cy := c.get_center().y
	_icon("icon_coin", Vector2(x + 30.0, cy), 60.0)
	x += 60.0 + 14.0
	UiHomeV3.draw_text(self, 900, 46, coin_text(), Vector2(x, cy - 23.0), UiHomeV3.INK, 0.0, true)
	var s := _chips[1]
	UiHomeV3.draw_panel(self, s, UiHomeV3.MINT if star_ok else UiHomeV3.CREAM, 60.0, 4.0)
	x = s.position.x + 4.0 + 24.0
	UiHomeV3.draw_flower(self, Vector2(x + 32.0, cy), str(data.get("prev_type", "")), 64.0 * 0.95 / UiHomeV3.ART_FILL)
	x += 64.0 + 14.0
	_draw_star3(Vector2(x, cy - 19.0))
	x += _star3_w() + 14.0
	UiHomeV3.draw_text(self, 900, 46, star_text(), Vector2(x, cy - 23.0), UiHomeV3.INK, 0.0, true)


func _draw_unlock() -> void:
	var b := _unlock
	var down := _pressed == PART_UNLOCK
	if down:
		b = Rect2(b.position + Vector2(0.0, 4.0), b.size)
	UiHomeV3.draw_panel(self, b, UiHomeV3.GOLD, 70.0, 4.0, UiHomeV3.INK, 4.0 if down else 8.0)
	var cy := b.get_center().y
	var x := b.position.x + 4.0 + 36.0
	_icon("icon_lock", Vector2(x + 28.0, cy), 56.0)
	x += 56.0 + 18.0
	UiHomeV3.draw_text(self, 900, 54, "Unlock", Vector2(x, cy - 27.0), UiHomeV3.INK)
	x += UiHomeV3.text_w(900, 54, "Unlock") + 18.0 + 6.0
	draw_rect(Rect2(x, cy - 32.0, 3.0, 64.0), UiHomeV3.DIVIDER)
	x += 3.0 + 6.0 + 18.0
	_icon("icon_coin", Vector2(x + 28.0, cy), 56.0)
	x += 56.0 + 18.0
	UiHomeV3.draw_text(self, 900, 54, str(_i("coins_need")), Vector2(x, cy - 27.0), UiHomeV3.INK, 0.0, true)


func _draw_buy() -> void:
	var b := _buy
	var down := _pressed == PART_BUY
	if down:
		b = Rect2(b.position + Vector2(0.0, 4.0), b.size)
	var busy := bool(data.get("buying", false))
	UiHomeV3.draw_panel(self, b, UiHomeV3.GOLD, 70.0, 4.0, UiHomeV3.INK, 4.0 if down else 8.0)
	var cy := b.get_center().y
	var x := b.position.x + 4.0 + 40.0
	_icon("icon_diamond", Vector2(x + 32.0, cy), 64.0)
	x += 64.0 + 18.0
	UiHomeV3.draw_text(self, 900, 60, _price(), Vector2(x, cy - 30.0), UiHomeV3.INK, 0.0, true)
	if busy:
		draw_style_box(UiStage.box(Color(UiHomeV3.CREAM, 0.45), 70), b)


func _draw_owned() -> void:
	var b := _owned
	UiHomeV3.draw_panel(self, b, UiHomeV3.MINT, 60.0, 4.0)
	var cy := b.get_center().y
	var x := b.position.x + 4.0 + 36.0
	UiHomeV3.draw_check(self, Vector2(x, cy - 24.5), UiHomeV3.INK)
	x += 31.0 + 18.0
	UiHomeV3.draw_text(self, 900, 50, "Yours", Vector2(x, cy - 25.0), UiHomeV3.INK)


func _draw_soon() -> void:
	var b := _soon
	draw_style_box(UiStage.box(UiHomeV3.CREAM, 60), b)
	UiHomeV3.draw_dashed_round_rect(self, b, 60.0, 4.0, UiHomeV3.INK)
	UiHomeV3.draw_text(self, 900, 50, "Coming soon", Vector2(b.position.x + 4.0 + 52.0, b.get_center().y - 25.0), UiHomeV3.INK)


## "★3" 38/900 #9E6645. Nunito nema ★, pa se zvijezda crta (sirina ~0,8 em).
func _star3_w() -> float:
	return 30.0 + UiHomeV3.text_w(900, 38, "3")


func _draw_star3(top_left: Vector2) -> void:
	UiStage.draw_star(self, top_left + Vector2(15.0, 20.0), 15.5, UiHomeV3.STAR_INK)
	UiHomeV3.draw_text(self, 900, 38, "3", top_left + Vector2(30.0, 0.0), UiHomeV3.STAR_INK)


func _icon(icon_name: String, center: Vector2, side: float) -> void:
	var tex := UiAssets.get_chrome_icon(icon_name)
	if tex:
		draw_texture_rect(tex, Rect2(center - Vector2(side, side) * 0.5, Vector2(side, side)), false)


func _roster() -> Array:
	return data.get("roster", []) as Array


func _price() -> String:
	return str(data.get("price", ""))


func _i(key: String) -> int:
	return int(data.get(key, 0))
