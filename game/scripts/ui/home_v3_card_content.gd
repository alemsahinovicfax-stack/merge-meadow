class_name HomeV3CardContent
extends Control

## CardContent (HomeScreen.dc.html): premium rub, svih sest cvjetova sezone u
## diskovima (dva reda po tri) i jedan status po stanju. Ime sezone i Pip NISU
## ovdje — to su putujuci objekti (SeasonName, MeadowPip) iznad polja. Kartica
## samo crta; SeasonStage prima dodir, a hit_part() kaze sta je pogodjeno.
##
## Runda 3: zakljucana besplatna sezona (locked i unlock) ima veo preko svakog
## diska i jedan katanac na bloku — cvijece se ne prepoznaje dok se sezona ne
## otkljuci. Tap na Unlock dize veo disk po disk (play_reveal).
##
## Teme (design_handoff_ads_only · home_season_tabs.json): rub „Special" #C2E2FA (8, ink obrub 3),
## dugme cijene = UiCoinPrice L (buy / short / confirm + traka 3 s / buying + prsten / „✓ Yours",
## € u IAP režimu) i iznad njega mirna pilula štednje „4,200 / 10,000" (B3; ne u IAP režimu).

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

const DISC_BORDER := 4.0
## B3 pilula štednje (home_season_tabs.json savings_pill_b3).
const SAVINGS_H := 72.0
const SAVINGS_FONT := 38.0
const SAVINGS_ICON := 44
const SAVINGS_GAP := 16.0

## data: season_id, status, premium, roster [{id, name, missing}], coins,
## coins_need, stars, stars_need, prev_type, price, buying; v1 bez kupovina pravim novcem još
## coin_price (> 0 = tema za coine, `price` je tada broj) i confirm (prvi tap, čeka drugi).
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
var _slot_used: Array[bool] = []
## Neprozirnost vela po disku (0 = cvijet se vidi, 1 = skriven).
var _veil := PackedFloat32Array()
var _veil_node: RosterVeil
## Napredak podizanja vela u sekundama; < 0 = nema reveala u toku.
var _reveal_t: float = -1.0
var _reveal_tween: Tween
## Pilula štednje iznad coin cijene teme (B3).
var _savings := Rect2()
## Traka potvrde 1 → 0 (T_CONFIRM_TIMEOUT) i prsten kupovine 0 → 1; < 0 = nema.
var _bar_k: float = 0.0
var _bar_tween: Tween
var _ring_k: float = -1.0
var _buying_anim: bool = false
var _buy_tween: Tween


## Crtez cvijeta u disku kao zaseban cvor — modulate daje siluetu (crno .28) i
## prigusenje (.5) i kad sezona jos nema SVG pa se crta proceduralno.
class FlowerArt extends Control:
	var type_id: String = ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		UiHomeV3.draw_flower(self, size * 0.5, type_id, size.x)


## Veo i katanac se crtaju IZNAD crteza. Djeca se crtaju poslije roditelja, pa
## ovaj cvor mora biti zadnji — inace bi cvijet ostao preko vela.
class RosterVeil extends Control:
	const BORDER := 4.0

	var alphas := PackedFloat32Array()
	var lock_on := false

	func _init() -> void:
		name = "RosterVeil"
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = UiHomeV3.CARD_RECT.size

	func _draw() -> void:
		for i in mini(alphas.size(), UiHomeV3.ROSTER6.size()):
			if alphas[i] <= 0.001:
				continue
			var inner: Rect2 = (UiHomeV3.ROSTER6[i] as Rect2).grow(-BORDER)
			draw_circle(
				inner.get_center(), inner.size.x * 0.5,
				Color(UiHomeV3.LOCK_VEIL, alphas[i]), true, -1.0, true
			)
		if not lock_on:
			return
		var b := UiHomeV3.ROSTER_LOCK
		UiHomeV3.draw_panel(self, b, UiHomeV3.CREAM, b.size.x * 0.5, 4.0, UiHomeV3.INK, 6.0, UiHomeV3.ARROW_SHADOW)
		var tex := UiAssets.get_chrome_icon("icon_lock")
		if tex:
			var side := UiHomeV3.ROSTER_LOCK_ICON
			draw_texture_rect(tex, Rect2(b.get_center() - Vector2(side, side) * 0.5, Vector2(side, side)), false)


func _init() -> void:
	name = "CardContent"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = UiHomeV3.CARD_RECT.size
	for i in UiHomeV3.ROSTER6.size():
		var art := FlowerArt.new()
		art.name = "RosterArt_%d" % i
		add_child(art)
		_arts.append(art)
		_slot_used.append(false)
		_veil.append(0.0)
	_veil_node = RosterVeil.new()
	add_child(_veil_node)


func configure(d: Dictionary) -> void:
	var old := data
	data = d
	var same := str(old.get("season_id", "")) == str(d.get("season_id", ""))
	var was_confirm := same and bool(old.get("confirm", false))
	if bool(d.get("confirm", false)) != was_confirm:
		_start_bar(bool(d.get("confirm", false)))
	elif not same:
		_start_bar(false)
	if same and str(old.get("status", "")) == ST_BUY and status() == ST_OWNED:
		_play_buying()
	elif not same:
		_stop_buying()
	_stop_reveal()
	_layout()
	_apply_veil()
	queue_redraw()


## Tap na Unlock: veo se dize disk po disk (300 ms, +40 ms po disku). Zove se
## POSLIJE configure() sa svjezim podacima, kad sezona vise nije zakljucana.
func play_reveal() -> void:
	_stop_reveal()
	_reveal_t = 0.0
	_apply_veil()
	queue_redraw()
	var total := UiHomeV3.REVEAL_SEC + float(UiHomeV3.ROSTER6.size() - 1) * UiHomeV3.REVEAL_STAGGER
	_reveal_tween = create_tween()
	_reveal_tween.tween_method(_set_reveal_t, 0.0, total, total)
	_reveal_tween.tween_callback(_stop_reveal)


func is_revealing() -> bool:
	return _reveal_t >= 0.0


## Neprozirnost vela po disku — za testove i za crtanje imena.
func veil_alphas() -> PackedFloat32Array:
	return _veil.duplicate()


func _set_reveal_t(t: float) -> void:
	_reveal_t = t
	_apply_veil()
	queue_redraw()


func _stop_reveal() -> void:
	if _reveal_tween:
		_reveal_tween.kill()
		_reveal_tween = null
	if _reveal_t < 0.0:
		return
	_reveal_t = -1.0
	_apply_veil()
	queue_redraw()


## Veo je pun na zakljucanoj sezoni; tokom reveala pada disk po disk.
func _apply_veil() -> void:
	var veiled := status() in [ST_LOCKED, ST_UNLOCK]
	for i in UiHomeV3.ROSTER6.size():
		var a := 0.0
		if veiled:
			a = 1.0
		elif _reveal_t >= 0.0:
			var k := (_reveal_t - float(i) * UiHomeV3.REVEAL_STAGGER) / UiHomeV3.REVEAL_SEC
			a = 1.0 - clampf(k, 0.0, 1.0)
		_veil[i] = a
		_arts[i].visible = _slot_used[i] and a < 0.999
	if _veil_node:
		_veil_node.alphas = _veil
		_veil_node.lock_on = status() == ST_LOCKED
		_veil_node.queue_redraw()


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


## Jedan katanac na bloku cvijeca — samo na zakljucanoj sezoni. U unlock stanju
## katanac nosi dugme Unlock, pa kartica nikad nema dva (runda 3).
func has_roster_lock() -> bool:
	return status() == ST_LOCKED


func is_dim() -> bool:
	return status() == ST_SOON


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


## Traka potvrde: puna na prvi tap, skupi se za T_CONFIRM_TIMEOUT.
func _start_bar(on: bool) -> void:
	if _bar_tween != null and _bar_tween.is_valid():
		_bar_tween.kill()
	_bar_k = 1.0 if on else 0.0
	if on and is_inside_tree():
		_bar_tween = create_tween()
		_bar_tween.tween_method(_set_bar, 1.0, 0.0, UiShopV2.T_CONFIRM_TIMEOUT)


func _set_bar(k: float) -> void:
	_bar_k = k
	queue_redraw()


## Kupljeno: 0,6 s mint „✓ Yours" + prsten 0,42 s, pa obično „✓ Yours".
func _play_buying() -> void:
	_stop_buying()
	if not is_inside_tree():
		return
	_buying_anim = true
	_ring_k = 0.0
	_buy_tween = create_tween()
	_buy_tween.tween_method(_set_ring, 0.0, 1.0, UiCoinPrice.T_RING).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_buy_tween.tween_interval(UiCoinPrice.T_BUYING - UiCoinPrice.T_RING)
	_buy_tween.tween_callback(_stop_buying)


func _stop_buying() -> void:
	if _buy_tween != null and _buy_tween.is_valid():
		_buy_tween.kill()
	_buying_anim = false
	_ring_k = -1.0
	queue_redraw()


func _set_ring(k: float) -> void:
	_ring_k = k
	queue_redraw()


func is_buying_anim() -> bool:
	return _buying_anim


## Pilula štednje se vidi samo kod teme za coine koja još nije kupljena.
func has_savings() -> bool:
	return status() == ST_BUY and _i("coin_price") > 0


func savings_text() -> String:
	var price := _i("coin_price")
	return "%s / %s" % [UiChrome.format_count(mini(_i("coins"), price)), UiChrome.format_count(price)]


# --- raspored ---

func _layout() -> void:
	_discs.clear()
	var roster := _roster()
	for i in UiHomeV3.ROSTER6.size():
		var r: Rect2 = UiHomeV3.ROSTER6[i]
		_discs.append(r)
		var f: Dictionary = roster[i] if i < roster.size() else {}
		_slot_used[i] = not f.is_empty()
		var art := _arts[i]
		art.position = r.position
		art.size = r.size
		art.type_id = str(f.get("id", ""))
		var miss := bool(f.get("missing", false))
		art.modulate = UiHomeV3.MISSING_ART if miss else (UiHomeV3.DIM_ART if is_dim() else Color.WHITE)
		art.queue_redraw()
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
	# Cijena teme = UiCoinPrice L (360 x 132) u svim stanjima; s pilulom štednje (72) iznad,
	# razmak 16, blok je centriran na status.
	var face := UiCoinPrice.button_size(UiCoinPrice.L)
	var block := face.y + UiCoinPrice.SHADOW_Y
	if has_savings():
		var pill_w := 4.0 + 24.0 + float(SAVINGS_ICON) + 12.0 \
			+ UiHomeV3.text_w(900, SAVINGS_FONT, savings_text(), 0.0, true) + 28.0 + 4.0
		var top := mid - (SAVINGS_H + SAVINGS_GAP + block) * 0.5
		_savings = Rect2(cx - pill_w * 0.5, top, pill_w, SAVINGS_H)
		_buy = Rect2(Vector2(cx - face.x * 0.5, top + SAVINGS_H + SAVINGS_GAP), face)
	else:
		_savings = Rect2()
		_buy = Rect2(Vector2(cx - face.x * 0.5, mid - block * 0.5), face)
	_owned = Rect2(Vector2(cx - face.x * 0.5, mid - block * 0.5), face)
	var soon_w := 4.0 + 52.0 + UiHomeV3.text_w(900, 50, "Coming soon") + 52.0 + 4.0
	_soon = Rect2(cx - soon_w * 0.5, mid - 60.0, soon_w, 120.0)


# --- crtanje ---

func _draw() -> void:
	if data.is_empty():
		return
	if bool(data.get("premium", false)):
		# Rub „Special": ink obrub 3 oko plave trake 8 (StyleBoxFlat border, bez maske).
		var rim := Rect2(Vector2.ZERO, size).grow(-UiHomeV3.PREMIUM_RIM_INSET)
		var w := UiHomeV3.PREMIUM_RIM_WIDTH
		var outline := UiStage.box(Color.TRANSPARENT, UiHomeV3.PREMIUM_RIM_RADIUS + 3, w + 6, UiHomeV3.INK)
		outline.draw_center = false
		draw_style_box(outline, rim.grow(3.0))
		var sb := UiStage.box(Color.TRANSPARENT, UiHomeV3.PREMIUM_RIM_RADIUS, w, SpecialTag.FILL)
		sb.draw_center = false
		draw_style_box(sb, rim)
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


## Ime nosi SVAKI cvijet koji se vidi, i nadjen i onaj koji fali — igrac zna
## sta u sezoni raste, ne samo sta mu jos nedostaje. (Paket crta ime samo ispod
## cvijeta koji fali; ovo je namjerno odstupanje, vidi izvjestaj.)
## Pod velom nema ni imena ni isprekidanog diska — zakljucana sezona se ne odaje.
func _draw_roster() -> void:
	var roster := _roster()
	for i in mini(roster.size(), _discs.size()):
		var f: Dictionary = roster[i]
		var r := _discs[i]
		var shown := _veil[i] <= 0.001
		if bool(f.get("missing", false)) and shown:
			draw_style_box(UiStage.box(UiHomeV3.MISSING_DISC, roundi(r.size.x * 0.5)), r)
			UiHomeV3.draw_dashed_round_rect(self, r, r.size.x * 0.5, DISC_BORDER, UiHomeV3.INK)
		else:
			UiHomeV3.draw_panel(self, r, UiHomeV3.CREAM, r.size.x * 0.5, DISC_BORDER)
		if shown:
			_draw_name(str(f.get("name", "")), r)


## Ime cvijeta: 34/900 ispod diska (gap 12). Duga imena idu u dva uravnotezena
## reda do 220 px, da ne predju na susjedno ime.
func _draw_name(text: String, disc: Rect2) -> void:
	var lines := _name_lines(text)
	var boxes := _name_boxes(text, disc)
	for i in mini(lines.size(), boxes.size()):
		UiHomeV3.draw_text(self, 900, UiHomeV3.MISSING_NAME, lines[i], boxes[i].position, data.get("ink_field", UiHomeV3.INK_DEEP))


func _name_lines(text: String) -> PackedStringArray:
	return UiStage.balance_lines(
		text, UiStage.font(900, UiHomeV3.MISSING_NAME), UiHomeV3.MISSING_NAME, UiHomeV3.MISSING_NAME_MAX_W
	)


## Okviri redova imena ispod diska — isti racun kojim se crtaju.
func _name_boxes(text: String, disc: Rect2) -> Array[Rect2]:
	var f := UiStage.font(900, UiHomeV3.MISSING_NAME)
	var out: Array[Rect2] = []
	var top := disc.end.y + UiHomeV3.MISSING_NAME_GAP
	for line in _name_lines(text):
		var w := UiStage.text_w(f, UiHomeV3.MISSING_NAME, line)
		out.append(Rect2(disc.get_center().x - w * 0.5, top, w, float(UiHomeV3.MISSING_NAME)))
		top += float(UiHomeV3.MISSING_NAME)
	return out


## Redovi imena koji se sada crtaju. `include_hidden` daje okvire i za imena
## pod velom — to je najgori slucaj rasporeda, sest imena odjednom, i nad njim
## se provjerava preklapanje.
func name_boxes(include_hidden: bool = false) -> Array[Rect2]:
	var out: Array[Rect2] = []
	var roster := _roster()
	for i in mini(roster.size(), _discs.size()):
		if not include_hidden and _veil[i] > 0.001:
			continue
		out.append_array(_name_boxes(str((roster[i] as Dictionary).get("name", "")), _discs[i]))
	return out


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


## Lice dugmeta cijene teme u UiCoinPrice rječniku.
func buy_face() -> String:
	if _i("coin_price") <= 0:
		return UiCoinPrice.EUR
	if bool(data.get("confirm", false)):
		return UiCoinPrice.CONFIRM
	return UiCoinPrice.BUY if _i("coins") >= _i("coin_price") else UiCoinPrice.SHORT


## Tema za coine (v1): coin cijena L — zlatna kad ima dovoljno, krem i spuštena kad fali, tamna
## sa SVG kvačicom i trakom 3 s na prvi tap; iznad mirna pilula štednje. IAP: € lice.
func _draw_buy() -> void:
	if has_savings():
		var enough := _i("coins") >= _i("coin_price")
		UiHomeV3.draw_panel(self, _savings, UiHomeV3.MINT if enough else UiHomeV3.CREAM, SAVINGS_H * 0.5, 4.0)
		var cy := _savings.get_center().y
		var x := _savings.position.x + 4.0 + 24.0
		_icon("icon_coin", Vector2(x + SAVINGS_ICON * 0.5, cy), float(SAVINGS_ICON))
		x += float(SAVINGS_ICON) + 12.0
		UiHomeV3.draw_text(self, 900, SAVINGS_FONT, savings_text(), Vector2(x, cy - SAVINGS_FONT * 0.5), UiHomeV3.INK, 0.0, true)
	var face := buy_face()
	var label := UiCoinPrice.price_text(_i("coin_price")) if face != UiCoinPrice.EUR else _price()
	var press := 1.0 if _pressed == PART_BUY and face != UiCoinPrice.SHORT else 0.0
	UiCoinPrice.draw(self, _buy.position, UiCoinPrice.L, face, label, press, _bar_k)
	if face == UiCoinPrice.EUR and bool(data.get("buying", false)):
		draw_style_box(UiStage.box(Color(UiHomeV3.CREAM, 0.45), roundi(_buy.size.y * 0.5)), _buy)


## Kupljena tema: „✓ Yours" (veliko Play dugme je ispod kartice); 0,6 s poslije kupovine mint
## lice s prstenom.
func _draw_owned() -> void:
	var face := UiCoinPrice.BUYING if _buying_anim else UiCoinPrice.OWNED
	UiCoinPrice.draw(self, _owned.position, UiCoinPrice.L, face, UiShopV2.S_YOURS, 0.0, 0.0, _ring_k)


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


func _icon(icon_name: String, center: Vector2, side: float, alpha: float = 1.0) -> void:
	var tex := UiAssets.get_chrome_icon(icon_name)
	if tex:
		draw_texture_rect(tex, Rect2(center - Vector2(side, side) * 0.5, Vector2(side, side)), false, Color(1, 1, 1, alpha))


func _roster() -> Array:
	return data.get("roster", []) as Array


func _price() -> String:
	return str(data.get("price", ""))


func _i(key: String) -> int:
	return int(data.get(key, 0))
