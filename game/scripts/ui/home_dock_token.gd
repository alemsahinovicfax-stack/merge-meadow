class_name HomeDockToken
extends Control

## SeasonToken 120 x 120 u docku (SeasonStage.dc.html · tok()). Broj za
## otvorenu free sezonu, lokot za lock, dijamant za premium, "Soon", ✓ za
## kupljen paket; ▶ tacka = aktivna, podignut + cream crtica = fokus.

const S_OPEN := "open"
const S_NEXT := "next"
const S_FAR := "far"
const S_PAID := "paid"
const S_SOON := "soon"

const IDLE_EDGE := Color(1.0, 0.973, 0.941, 0.35)
const LIFT := 6.0
const SHAKE_X := 8.0
const SHAKE_ROT := 0.05235988  # 3 stepena
const OUTLINE_HOLD := 0.6

var season_id: String = ""
var kind: String = "free"
var status: String = S_OPEN
var number: int = 1
var active: bool = false
var focused: bool = false
var progress: float = 0.0
var base_position := Vector2.ZERO
var _outline: bool = false
var _lift_tween: Tween
var _shake_tween: Tween


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(UiStage.TOKEN, UiStage.TOKEN)
	custom_minimum_size = size
	pivot_offset = size * 0.5


func configure(p_kind: String, p_status: String, p_number: int, p_active: bool, p_focused: bool, p_progress: float, animated: bool) -> void:
	var was_focused := focused
	kind = p_kind
	status = p_status
	number = p_number
	active = p_active
	focused = p_focused
	progress = clampf(p_progress, 0.0, 1.0)
	if was_focused != focused or not animated:
		_lift_to(-LIFT if focused else 0.0, animated and was_focused != focused)
	queue_redraw()


func place(pos: Vector2) -> void:
	base_position = pos
	position = Vector2(pos.x, pos.y + (-LIFT if focused else 0.0))


func is_lifted() -> bool:
	return position.y < base_position.y - 0.5


func is_shaking() -> bool:
	return _outline


## 180 ms shake + crveni obrub (tap na daleki lock).
func shake() -> void:
	if _shake_tween:
		_shake_tween.kill()
	position.x = base_position.x
	rotation = 0.0
	_outline = true
	queue_redraw()
	if not is_inside_tree():
		_outline = false
		return
	var step := UiStage.T_SHAKE / 4.0
	_shake_tween = create_tween()
	_shake_tween.tween_property(self, "position:x", base_position.x + SHAKE_X, step)
	_shake_tween.parallel().tween_property(self, "rotation", SHAKE_ROT, step)
	_shake_tween.tween_property(self, "position:x", base_position.x - SHAKE_X * 0.75, step)
	_shake_tween.parallel().tween_property(self, "rotation", -SHAKE_ROT * 0.66, step)
	_shake_tween.tween_property(self, "position:x", base_position.x + SHAKE_X * 0.5, step)
	_shake_tween.parallel().tween_property(self, "rotation", SHAKE_ROT * 0.33, step)
	_shake_tween.tween_property(self, "position:x", base_position.x, step)
	_shake_tween.parallel().tween_property(self, "rotation", 0.0, step)
	_shake_tween.tween_interval(OUTLINE_HOLD)
	_shake_tween.tween_callback(func() -> void:
		_outline = false
		queue_redraw()
	)


func fill_color() -> Color:
	var mood := SeasonColors.mood_of(season_id)
	match status:
		S_FAR:
			return SeasonColors.far_token(mood)
		S_NEXT:
			return SeasonColors.locked_fill(mood)
		S_SOON:
			return SeasonColors.soon_fill(mood)
	return mood


func border_width() -> int:
	if active:
		return 6
	if focused:
		return 5
	return 3


func _lift_to(y_off: float, animated: bool) -> void:
	if _lift_tween:
		_lift_tween.kill()
		_lift_tween = null
	var target := base_position.y + y_off
	if not animated or not is_inside_tree():
		position.y = target
		return
	_lift_tween = create_tween()
	_lift_tween.tween_property(self, "position:y", target, UiStage.T_LIFT).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var fill := fill_color()
	var b := border_width()
	var edge := UiStage.over(fill, IDLE_EDGE)
	if active:
		edge = UiStage.RIM
	elif focused:
		edge = UiStage.CREAM
	var body := Rect2(Vector2.ZERO, size)
	if _outline:
		var ring := UiStage.box(Color.TRANSPARENT, 35, 5, UiStage.BLOCKED)
		ring.draw_center = false
		draw_style_box(ring, body.grow(9.0))
	draw_style_box(UiStage.box(fill, 26, b, edge), body)
	var center := body.get_center()
	match status:
		S_OPEN:
			if kind == "paid":
				UiStage.draw_check(self, Rect2(center - Vector2(18, 15), Vector2(36, 31)), 6.5, UiStage.CREAM)
			else:
				var f := UiStage.font(900, 52)
				UiStage.draw_text_centered(self, f, 52, str(number), body, SeasonColors.ink(fill))
		S_NEXT, S_FAR:
			_draw_disc(center, UiAssets.get_chrome_icon("icon_lock"))
		S_PAID:
			_draw_disc(center, UiAssets.get_chrome_icon("icon_diamond"))
		S_SOON:
			var fs := UiStage.font(900, 38)
			UiStage.draw_text_centered(self, fs, 38, "Soon", body, UiStage.CREAM)
	if status == S_NEXT:
		var bar := Rect2(float(b) + 10.0, size.y - float(b) - 10.0 - 12.0, size.x - float(b) * 2.0 - 20.0, 12.0)
		draw_style_box(UiStage.box(UiStage.TOKEN_TRACK, 6), bar)
		var w := bar.size.x * progress
		if w >= 1.0:
			var fill_bar := UiStage.box(UiStage.COIN, 6)
			draw_style_box(fill_bar, Rect2(bar.position, Vector2(maxf(w, 12.0), bar.size.y)))
	if active:
		var dot := Rect2(size.x - float(b) + 14.0 - 48.0, float(b) - 14.0, 48.0, 48.0)
		draw_style_box(UiStage.box(UiStage.PEACH, 24, 4, UiStage.CHROME), dot)
		var c := dot.get_center() + Vector2(1.5, 0.0)
		UiStage.draw_play(self, Rect2(c.x - 7.0, c.y - 8.5, 15.0, 17.0), UiStage.INK)
	if focused:
		var fb := Rect2(float(b) + 30.0, size.y - float(b) + 14.0, size.x - float(b) * 2.0 - 60.0, 8.0)
		draw_style_box(UiStage.box(UiStage.CREAM, 4), fb)


func _draw_disc(center: Vector2, icon: Texture2D) -> void:
	draw_style_box(UiStage.box(UiStage.CREAM, 32), Rect2(center - Vector2(32, 32), Vector2(64, 64)))
	if icon:
		draw_texture_rect(icon, Rect2(center - Vector2(20, 20), Vector2(40, 40)), false)
