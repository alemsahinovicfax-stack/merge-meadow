class_name ShopBuyButton
extends HubPressable

## Shop v2 · BuyButton (design_handoff_shop_v2 § Stanja dugmeta): jedno dugme po kartici koje
## nosi cijenu i kupuje. h 120, min 280, radius 60, rub 4 ink; raste sa sadržajem.
##   coins.buy · coins.confirm · coins.short · money.buy · money.busy · money.dim · play · owned
## Pritisak: y +4, sjena 8 → 4. Promjena stanja: scale 1 → 1,06 → 1 (0,22 s). coins.short:
## drhtaj (−12 / 12 / −8 / 8 / 0, 0,32 s). money.busy: tri tačke — jedini loop u Shopu.

signal short_tapped

const COIN_ICON := 60.0
const PAD_COIN := Vector2(30, 40)   # lijevo, desno
const PAD_MONEY := 44.0
const GAP := 14.0
const CHECK_W := 30.0
const DOT := 20.0

var state: String = UiShopV2.MONEY_BUY
var price: String = ""
var owned_label: String = "Yours"

var _coin_tex: Texture2D
var _press_k: float = 0.0
var _shake_x: float = 0.0
var _pop_tween: Tween
var _shake_tween: Tween
var _dot_t: float = 0.0


func _ready() -> void:
	super()
	_coin_tex = UiAssets.get_chrome_icon("icon_coin")
	custom_minimum_size = Vector2(UiShopV2.BUTTON_MIN_W, UiShopV2.BUTTON_H + UiShopV2.SHADOW_BUTTON_Y)
	set_process(false)


## Postavi stanje; `pop` = kratki skok skale kad se stanje stvarno promijeni.
func configure(p_state: String, p_price: String, p_owned_label: String = "Yours", pop: bool = true) -> void:
	var changed := p_state != state
	state = p_state
	price = p_price
	owned_label = p_owned_label
	disabled = not is_tappable()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if is_tappable() else Control.CURSOR_ARROW
	_fit()
	set_process(state == UiShopV2.MONEY_BUSY)
	if changed and pop and is_inside_tree():
		_pop()
	queue_redraw()


## Da li tap nešto radi (coins.short reaguje drhtajem, pa je i on dodirljiv).
func is_tappable() -> bool:
	return state in [UiShopV2.COINS_BUY, UiShopV2.COINS_CONFIRM, UiShopV2.COINS_SHORT_STATE,
		UiShopV2.MONEY_BUY, UiShopV2.PLAY_STATE]


func shake() -> void:
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween()
	var step := UiShopV2.T_SHAKE / 5.0
	for x in [-12.0, 12.0, -8.0, 8.0, 0.0]:
		_shake_tween.tween_method(_set_shake, _shake_x, x, step)


func _set_shake(x: float) -> void:
	_shake_x = x
	queue_redraw()


func _on_gui_input(event: InputEvent) -> void:
	if state == UiShopV2.COINS_SHORT_STATE:
		var tapped := false
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			tapped = mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed
		elif event is InputEventScreenTouch:
			tapped = (event as InputEventScreenTouch).pressed
		if tapped:
			shake()
			short_tapped.emit()
			accept_event()
		return
	super(event)


func _apply_state() -> void:
	_press_k = 1.0 if is_pressing() else 0.0
	queue_redraw()


func _process(delta: float) -> void:
	_dot_t = fmod(_dot_t + delta, UiShopV2.T_BUSY_DOT)
	queue_redraw()


func _pop() -> void:
	if _pop_tween != null and _pop_tween.is_valid():
		_pop_tween.kill()
	pivot_offset = Vector2(size.x * 0.5, UiShopV2.BUTTON_H * 0.5)
	_pop_tween = create_tween()
	_pop_tween.tween_property(self, "scale", Vector2.ONE * 1.06, UiShopV2.T_POP * 0.4).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)
	_pop_tween.tween_property(self, "scale", Vector2.ONE, UiShopV2.T_POP * 0.6).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)


func _price_px() -> int:
	return UiShopV2.price_font_px(price)


func _fit() -> void:
	var w := 0.0
	match state:
		UiShopV2.COINS_BUY, UiShopV2.COINS_SHORT_STATE:
			w = PAD_COIN.x + COIN_ICON + GAP + UiHomeV3.text_w(900, 52, price, 0.0, true) + PAD_COIN.y
		UiShopV2.COINS_CONFIRM:
			w = 34.0 + CHECK_W + GAP + COIN_ICON + GAP + UiHomeV3.text_w(900, 52, price, 0.0, true) + PAD_COIN.y
		UiShopV2.MONEY_BUY, UiShopV2.MONEY_DIM:
			w = PAD_MONEY * 2.0 + UiHomeV3.text_w(900, _price_px(), price, 0.0, true)
		UiShopV2.MONEY_BUSY:
			w = PAD_MONEY * 2.0 + DOT * 3.0 + GAP * 2.0
		UiShopV2.PLAY_STATE:
			w = 40.0 + 44.0 + GAP + UiHomeV3.text_w(900, 52, UiShopV2.S_PLAY) + 44.0
		_:
			w = 36.0 + CHECK_W + GAP + UiHomeV3.text_w(900, 48, owned_label) + 40.0
	custom_minimum_size = Vector2(maxf(UiShopV2.BUTTON_MIN_W, ceilf(w)), UiShopV2.BUTTON_H + UiShopV2.SHADOW_BUTTON_Y)
	update_minimum_size()


func _draw() -> void:
	var w := custom_minimum_size.x
	var flat := state in [UiShopV2.COINS_SHORT_STATE, UiShopV2.MONEY_DIM, UiShopV2.OWNED_STATE, UiShopV2.MONEY_BUSY]
	var down := 8.0 if state == UiShopV2.MONEY_BUSY else _press_k * 4.0
	var rect := Rect2(Vector2(_shake_x, down), Vector2(w, UiShopV2.BUTTON_H))
	if not flat:
		draw_style_box(
			UiShopV2.box(UiShopV2.SHADOW_BUTTON, UiShopV2.RADIUS_BUTTON),
			Rect2(Vector2(_shake_x, UiShopV2.SHADOW_BUTTON_Y), rect.size)
		)
	draw_style_box(UiShopV2.button_style(state), rect)
	var ink := UiShopV2.button_ink(state)
	var cy := rect.position.y + UiShopV2.BUTTON_H * 0.5
	match state:
		UiShopV2.COINS_BUY, UiShopV2.COINS_SHORT_STATE:
			var x := rect.position.x + PAD_COIN.x
			_coin(Vector2(x, cy), 1.0 if state == UiShopV2.COINS_BUY else 0.55)
			UiHomeV3.draw_text(self, 900, 52, price, Vector2(x + COIN_ICON + GAP, cy - 26.0), ink, 0.0, true)
		UiShopV2.COINS_CONFIRM:
			var x := rect.position.x + 34.0
			_check(Vector2(x + CHECK_W * 0.5, cy), UiShopV2.COINS)
			x += CHECK_W + GAP
			_coin(Vector2(x, cy), 1.0)
			UiHomeV3.draw_text(self, 900, 52, price, Vector2(x + COIN_ICON + GAP, cy - 26.0), ink, 0.0, true)
		UiShopV2.MONEY_BUY, UiShopV2.MONEY_DIM:
			var px := _price_px()
			var tw := UiHomeV3.text_w(900, px, price, 0.0, true)
			UiHomeV3.draw_text(self, 900, px, price, Vector2(rect.position.x + (w - tw) * 0.5, cy - px * 0.5), ink, 0.0, true)
		UiShopV2.MONEY_BUSY:
			var span := DOT * 3.0 + GAP * 2.0
			var x0 := rect.position.x + (w - span) * 0.5 + DOT * 0.5
			for i in 3:
				var phase := fmod(_dot_t / UiShopV2.T_BUSY_DOT - float(i) * 0.15 / UiShopV2.T_BUSY_DOT + 1.0, 1.0)
				var a := 0.3 + 0.7 * (0.5 - 0.5 * cos(phase * TAU))
				draw_circle(Vector2(x0 + float(i) * (DOT + GAP), cy), DOT * 0.5, Color(UiShopV2.INK, a))
		UiShopV2.PLAY_STATE:
			var label := UiShopV2.S_PLAY
			var tw := 44.0 + GAP + UiHomeV3.text_w(900, 52, label)
			var x := rect.position.x + (w - tw) * 0.5
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, cy - 22.0), Vector2(x + 38.0, cy), Vector2(x, cy + 22.0)
			]), ink)
			UiHomeV3.draw_text(self, 900, 52, label, Vector2(x + 44.0 + GAP, cy - 26.0), ink)
		_:
			var tw := CHECK_W + GAP + UiHomeV3.text_w(900, 48, owned_label)
			var x := rect.position.x + (w - tw) * 0.5
			_check(Vector2(x + CHECK_W * 0.5, cy), ink)
			UiHomeV3.draw_text(self, 900, 48, owned_label, Vector2(x + CHECK_W + GAP, cy - 24.0), ink)


func _coin(left_center: Vector2, alpha: float) -> void:
	if _coin_tex == null:
		draw_circle(left_center + Vector2(COIN_ICON * 0.5, 0.0), COIN_ICON * 0.5, Color(UiShopV2.COINS, alpha))
		return
	draw_texture_rect(
		_coin_tex, Rect2(left_center - Vector2(0.0, COIN_ICON * 0.5), Vector2(COIN_ICON, COIN_ICON)), false,
		Color(1, 1, 1, alpha)
	)


func _check(c: Vector2, col: Color) -> void:
	var pts := PackedVector2Array([c + Vector2(-13, 1), c + Vector2(-4, 10), c + Vector2(13, -9)])
	draw_polyline(pts, col, 7.0, true)
	draw_circle(pts[0], 3.5, col)
	draw_circle(pts[1], 3.5, col)
	draw_circle(pts[2], 3.5, col)
