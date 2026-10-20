class_name LevelPathRewardPopup
extends Control

## Popup nagrade puta (design_handoff_level_path · RewardPopup): GiftModal sistema popupa —
## zlatna pločica „Level N reward!", otvoren sanduk na ravnim zrakama, iznad njega lebdi ★3
## cvijet sezone; ime cvijeta, 2 RewardChipa i Claim. Na Claim modal nestane (0,16 s), a 3
## cvijeta i 4 coina (nagrada 20: 5 + 5 i 6 konfeta) lete kvadratnom Bézier krivom do
## FlowerChipa i CoinChipa u headeru. Svaki dolazak doda svoj dio iznosa i trzne chip.
## Budžet: 16 sprite-ova / 1,0 s (nagrada 20: 24 / 1,18 s). Scrim pokriva samo stranicu,
## pa se let u header vidi.

signal claimed(n: int)
signal finished(n: int)

const HERO_H := 360.0
const HERO_H_BIG := 430.0
const BURST := 320.0
const BURST_DEG_S := 14.0
const CHEST_K := 1.12
const CHEST_K_BIG := 1.42
const FLOWER := 128.0
const FLOWER_BIG := 150.0
const FLOAT_PX := 8.0
const FLY_SEC := 0.36
const FLY_SEC_BIG := 0.4
const STAGGER := 0.05
const STAGGER_BIG := 0.04
const CTRL_UP := 120.0
const CTRL_UP_BIG := 180.0
const FLY_END_SCALE := 0.7
const FLYER := 72.0
const PUNCH_SEC := 0.12
const STAR_INK := Color("7a4a28")
## Mete leta u koordinatama artboarda (header) kad hub ne postoji (testovi).
const FALLBACK_TARGETS := {"coin": Vector2(66, 70), "flower": Vector2(690, 70)}

var season_id: String = ""
var n: int = 0
var big: bool = false
var flower_type: String = ""

var modal: PopupModal
var _hero: _Hero
var _tray: RewardTray
var _button: PopupButton
var _line: _Line
var _fly_layer: Control
var _busy: bool = false
var _flying: int = 0
var _got: Dictionary = {}
var _shown := {"coins": 0, "flowers": 0}


func _init() -> void:
	name = "LevelRewardPopup"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal = PopupModal.new()
	modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal.z_index = 40
	add_child(modal)
	modal.setup("", "reward")
	_button = PopupButton.new()
	_button.name = "ClaimButton"
	_button.clicked.connect(claim)
	_fly_layer = Control.new()
	_fly_layer.name = "RewardFly"
	_fly_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fly_layer.z_as_relative = false
	_fly_layer.z_index = 120
	add_child(_fly_layer)


func is_busy() -> bool:
	return _busy


func is_open() -> bool:
	return modal.visible


func open_for(p_season_id: String, p_n: int) -> void:
	if _busy:
		return
	season_id = p_season_id
	n = p_n
	big = p_n == LevelPathDomain.LEVELS
	flower_type = GameState.star3_type_id_for_season(season_id)
	_busy = true
	var r: Array = LevelPathDomain.REWARDS[n]
	modal.set_title(LevelPathKit.S_TITLE % n, "reward")
	if _button.get_parent() != null:
		_button.get_parent().remove_child(_button)
	modal.clear_content()
	_hero = _Hero.new()
	_hero.setup(flower_type, big)
	modal.content.add_child(PopupModal.centered(_hero))
	_line = _Line.new()
	_line.text = GameState.get_seed_display_name(flower_type) if not flower_type.is_empty() else ""
	modal.content.add_child(PopupModal.centered(_line))
	var chips: Array = []
	if not flower_type.is_empty():
		chips.append(RewardChip.new().setup("flower", flower_type, int(r[0])))
	chips.append(RewardChip.new().setup("coin", "", int(r[1])))
	_tray = RewardTray.new().setup(880.0, chips)
	_tray.name = "RewardTray"
	modal.content.add_child(PopupModal.centered(_tray))
	_button.configure("primary", LevelPathKit.S_CLAIM)
	modal.content.add_child(_button)
	modal.open(true)
	_tray.reveal()
	if big:
		_hero.confetti()


func title_text() -> String:
	return modal.title


## Claim (dugme i smoke testovi): nagrada se upiše odmah, brojači u headeru rastu po dolasku.
func claim() -> void:
	if not modal.visible or _flying > 0 or not _got.is_empty():
		return
	var coins_before := int(GameState.wallet_coins)
	var flowers_before := int(GameState.get_garden_crystal_total())
	var got := GameState.claim_level_reward(season_id, n)
	if got.is_empty():
		modal.close(true)
		_busy = false
		return
	_got = got
	Sfx.play("gift")
	Sfx.haptic(30)
	_shown = {"coins": coins_before, "flowers": flowers_before}
	_hub_call("preview_top_counts", [coins_before, flowers_before])
	claimed.emit(n)
	var starts := _chip_starts()
	modal.close(true)
	var t := create_tween()
	t.tween_interval(UiPopups.ANIM.modal_out)
	t.tween_callback(_launch.bind(starts))


func _chip_starts() -> Dictionary:
	var mid := Vector2(LevelPathKit.W * 0.5, 900.0)
	var out := {"flower": mid, "coin": mid}
	if _tray == null:
		return out
	var inv := _fly_layer.get_global_transform_with_canvas().affine_inverse()
	for chip in _tray.chips:
		var art := Vector2(RewardChip.PAD_L + UiPopups.CHIP_ART * 0.5, UiPopups.CHIP_H * 0.5)
		out["coin" if chip.kind == "coin" else "flower"] = inv * (chip.get_global_transform_with_canvas() * art)
	return out


func _launch(starts: Dictionary) -> void:
	var fl_n := 5 if big else 3
	var co_n := 5 if big else 4
	var flowers := int(_got.get("flowers", 0))
	var coins := int(_got.get("coins", 0))
	var order: Array = []
	var fi := 0
	var ci := 0
	while fi < (fl_n if flowers > 0 else 0) or ci < co_n:
		if fi < fl_n and flowers > 0:
			order.append(["flower", _part(flowers, fl_n, fi)])
			fi += 1
		if ci < co_n:
			order.append(["coin", _part(coins, co_n, ci)])
			ci += 1
	var sec := FLY_SEC_BIG if big else FLY_SEC
	var stagger := STAGGER_BIG if big else STAGGER
	var up := CTRL_UP_BIG if big else CTRL_UP
	if order.is_empty():
		_finish()
		return
	for i in order.size():
		var kind := str(order[i][0])
		var amount := int(order[i][1])
		var from: Vector2 = starts[kind]
		var to := _target(kind)
		var f := _Flyer.new()
		f.kind = kind
		f.type_id = flower_type
		f.size = Vector2.ONE * FLYER
		f.pivot_offset = f.size * 0.5
		f.position = from - f.size * 0.5
		f.visible = false
		_fly_layer.add_child(f)
		_flying += 1
		var ctrl := (from + to) * 0.5 - Vector2(0.0, up)
		var t := f.create_tween()
		t.tween_interval(stagger * float(i))
		t.tween_callback(f.show)
		t.tween_method(func(u: float) -> void:
			var e := _io2(u)
			var p := from.lerp(ctrl, e).lerp(ctrl.lerp(to, e), e)
			f.position = p - f.size * 0.5
			f.scale = Vector2.ONE * lerpf(1.0, FLY_END_SCALE, e)
		, 0.0, 1.0, sec)
		t.tween_callback(_arrive.bind(f, kind, amount))


static func _part(total: int, count: int, i: int) -> int:
	var base := total / count
	return base + (total - base * count if i == count - 1 else 0)


func _arrive(f: Control, kind: String, amount: int) -> void:
	f.queue_free()
	_flying -= 1
	if kind == "coin":
		_shown["coins"] = int(_shown["coins"]) + amount
		Sfx.play("coin")
	else:
		_shown["flowers"] = int(_shown["flowers"]) + amount
		Sfx.play("crystal_fly")
	_hub_call("preview_top_counts", [int(_shown["coins"]), int(_shown["flowers"])])
	_hub_call("bump_top_chip", [kind])
	if _flying <= 0:
		_finish()


func _finish() -> void:
	_hub_call("refresh_top_bar", [])
	_got = {}
	_busy = false
	finished.emit(n)


## Centar chipa u headeru (koordinate sloja leta).
func _target(kind: String) -> Vector2:
	var hub := _hub()
	if hub != null and hub.has_method("top_chip_center"):
		var g: Variant = hub.call("top_chip_center", kind)
		if g is Vector2:
			return _fly_layer.get_global_transform_with_canvas().affine_inverse() * (g as Vector2)
	var art: Vector2 = FALLBACK_TARGETS[kind]
	return _fly_layer.get_global_transform_with_canvas().affine_inverse() * art


func _hub() -> Node:
	if not is_inside_tree():
		return null
	var hubs := get_tree().get_nodes_in_group("meta_hub")
	return hubs[0] if not hubs.is_empty() else null


func _hub_call(method: String, args: Array) -> void:
	var hub := _hub()
	if hub != null and hub.has_method(method):
		hub.callv(method, args)


static func _io2(t: float) -> float:
	return 2.0 * t * t if t < 0.5 else 1.0 - pow(-2.0 * t + 2.0, 2.0) * 0.5


## Junak: ravne zrake (rotacija 14°/s), otvoren sanduk, ★3 cvijet lebdi ±8 px; nagrada 20 =
## veći sanduk + 6 konfeta iz sanduka.
class _Hero extends Control:
	var flower_type: String = ""
	var big: bool = false
	var burst: TextureRect
	var chest: TextureRect
	var flower: _FlowerArt
	var _t: float = 0.0
	var _flower_y: float = 0.0

	func setup(p_type: String, p_big: bool) -> void:
		flower_type = p_type
		big = p_big
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var h := LevelPathRewardPopup.HERO_H_BIG if big else LevelPathRewardPopup.HERO_H
		custom_minimum_size = Vector2(888.0, h)
		size = custom_minimum_size
		var bs := LevelPathRewardPopup.BURST * (1.12 if big else 1.0)
		burst = LevelPathView._tex_rect("Burst")
		burst.texture = LevelPathKit.fx_tex("reward_burst")
		burst.size = Vector2.ONE * bs
		burst.position = Vector2(444.0 - bs * 0.5, h * 0.56 - bs * 0.5)
		burst.pivot_offset = burst.size * 0.5
		add_child(burst)
		var k := LevelPathRewardPopup.CHEST_K_BIG if big else LevelPathRewardPopup.CHEST_K
		chest = LevelPathView._tex_rect("Chest")
		chest.texture = LevelPathKit.chest_tex("open", big)
		chest.size = LevelPathKit.CHEST_BOX * k
		chest.position = Vector2(444.0 - chest.size.x * 0.5, h - chest.size.y - 4.0)
		add_child(chest)
		flower = _FlowerArt.new()
		flower.type_id = flower_type
		var fs := LevelPathRewardPopup.FLOWER_BIG if big else LevelPathRewardPopup.FLOWER
		flower.size = Vector2.ONE * fs
		_flower_y = chest.position.y + 6.0 * k - fs
		flower.position = Vector2(444.0 - fs * 0.5, _flower_y)
		add_child(flower)

	func _process(delta: float) -> void:
		if not is_visible_in_tree():
			return
		_t += delta
		burst.rotation = deg_to_rad(LevelPathRewardPopup.BURST_DEG_S) * _t
		flower.position.y = _flower_y + LevelPathRewardPopup.FLOAT_PX * sin(_t * TAU / 2.0)

	## 6 konfeta iz sanduka (peach / mint / lav), luk gore i pad, 0,9 s.
	func confetti() -> void:
		if UiPip.reduce_motion():
			return
		var ids := ["confetti_peach", "confetti_mint", "confetti_lav"]
		var origin := chest.position + Vector2(chest.size.x * 0.5, chest.size.y * 0.3)
		for i in 6:
			var c := Sprite2D.new()
			c.texture = LevelPathKit.fx_tex(ids[i % 3])
			c.position = origin
			add_child(c)
			var dir := Vector2(cos(deg_to_rad(-150.0 + 24.0 * i)), sin(deg_to_rad(-150.0 + 24.0 * i)))
			var t := c.create_tween().set_parallel()
			t.tween_property(c, "position", origin + dir * 220.0 + Vector2(0.0, 60.0), 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.tween_property(c, "rotation", deg_to_rad(240.0 * (1.0 if i % 2 == 0 else -1.0)), 0.9)
			t.tween_property(c, "modulate:a", 0.0, 0.3).set_delay(0.6)
			t.chain().tween_callback(c.queue_free)


class _FlowerArt extends Control:
	var type_id: String = ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		UiPopups.draw_flower(self, size * 0.5, type_id, 3, size.x)


## Ime cvijeta + „★3".
class _Line extends Control:
	var text: String = ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(888.0, 52.0)

	func _draw() -> void:
		var star := "★3"
		var w1 := UiPopups.text_w(900, 48, text)
		var w2 := UiPopups.text_w(900, 44, star)
		var x := (size.x - w1 - 14.0 - w2) * 0.5
		UiPopups.draw_text(self, 900, 48, text, Vector2(x, 2.0), UiPopups.OUTLINE)
		UiPopups.draw_text(self, 900, 44, star, Vector2(x + w1 + 14.0, 4.0), LevelPathRewardPopup.STAR_INK)


class _Flyer extends Control:
	var kind: String = "coin"
	var type_id: String = ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if kind == "coin":
			UiPopups.draw_icon(self, UiPopups.icon("icon_coin"), size * 0.5, size.x * 0.8)
		else:
			UiPopups.draw_flower(self, size * 0.5, type_id, 3, size.x)
