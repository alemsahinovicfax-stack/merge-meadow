class_name UiShopButtons
extends RefCounted

## Dugmad za pravi novac u Shopu (design_handoff_shop · components.BuyButton).
## Jedna kupovina u isto vrijeme: aktivno dugme pulsira "Waiting for store…",
## ostala padaju na 50 % i ne primaju dodir.

const PULSE_META := "shop_busy_tween"


static func apply_money(
	btn: CampButton, mode: String, label: String, sub: String, on_mood: bool = false
) -> void:
	if btn == null:
		return
	match mode:
		UiShop.BUY_BUSY:
			btn.set_text("Waiting for store…", "finish in the store window")
			var kind := "busy_on_mood" if on_mood else "disabled"
			btn.set_styles(UiShop.button_style(kind))
			btn.set_ink(UiShop.button_ink(kind))
			btn.disabled = true
			btn.modulate.a = 1.0
			_start_pulse(btn)
		UiShop.BUY_DIM:
			_stop_pulse(btn)
			btn.set_text(label, "one purchase at a time")
			btn.set_styles(UiShop.button_style("money"))
			btn.set_ink(UiShop.INK)
			btn.disabled = true
			btn.modulate.a = UiShop.DIM_ALPHA
		_:
			_stop_pulse(btn)
			btn.set_text(label, sub)
			btn.set_styles(UiShop.button_style("money"), UiShop.button_style("money", true))
			btn.set_ink(UiShop.INK)
			btn.disabled = false
			btn.modulate.a = 1.0


## Dugme koje ponavlja neuspjelu kupovinu ("Try again").
static func apply_retry(btn: CampButton, on_mood: bool = false) -> void:
	apply_money(btn, UiShop.BUY_IDLE, "Try again", "", on_mood)


static func _start_pulse(btn: CampButton) -> void:
	_stop_pulse(btn)
	if not btn.is_inside_tree():
		return
	var tween := btn.create_tween()
	tween.set_loops()
	tween.tween_property(btn, "modulate:a", UiShop.BUSY_ALPHA.x, UiShop.T_BUSY_PULSE * 0.5)
	tween.tween_property(btn, "modulate:a", UiShop.BUSY_ALPHA.y, UiShop.T_BUSY_PULSE * 0.5)
	btn.set_meta(PULSE_META, tween)


static func _stop_pulse(btn: CampButton) -> void:
	if not btn.has_meta(PULSE_META):
		return
	var tween := btn.get_meta(PULSE_META) as Tween
	if tween != null and tween.is_valid():
		tween.kill()
	btn.remove_meta(PULSE_META)
	btn.modulate.a = 1.0
