class_name FloatPop
extends Control

## Pop-up sistem · Leteća poruka (design_handoff_popups § Sistem): broj 64/900 s ink obrubom 10
## uz coin 58 (ili sjeme u disku 50) i opciono ime 44/900 krem. Zarada je zlatna: iskoči 0,6 → 1
## (120 ms), odleti do brojača (420 ms) i brojač kratko poskoči 1,08. Potrošnja je roze: pada
## 60 px i nestaje (600 ms). mouse_filter IGNORE.

const ICON := 58.0
const SEED_DISC := 50.0
const GAP := 8.0
const NAME_GAP := 14.0

var text: String = ""
var spend: bool = false
var icon: Texture2D = null
var seed_type: String = ""
var seed_name: String = ""
var px: float = UiPopups.POP_SIZE


func _init() -> void:
	name = "FloatPop"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 50


func setup(p_text: String, p_spend: bool = false, p_icon: Texture2D = null, p_px: float = UiPopups.POP_SIZE) -> FloatPop:
	text = p_text
	spend = p_spend
	icon = p_icon
	px = p_px
	size = Vector2(width(), px)
	pivot_offset = size * 0.5
	queue_redraw()
	return self


func with_seed(type_id: String, display_name: String = "") -> FloatPop:
	seed_type = type_id
	seed_name = display_name
	icon = null
	size = Vector2(width(), px)
	pivot_offset = size * 0.5
	queue_redraw()
	return self


func width() -> float:
	var w := UiPopups.text_w(900, px, text) + UiPopups.POP_STROKE
	if icon != null:
		w += ICON + GAP
	elif not seed_type.is_empty():
		w += SEED_DISC + GAP
	if not seed_name.is_empty():
		w += NAME_GAP + UiPopups.text_w(900, 44, seed_name)
	return ceilf(w)


func _draw() -> void:
	var cy := size.y * 0.5
	var x := 0.0
	if icon != null:
		UiPopups.draw_icon(self, icon, Vector2(x + ICON * 0.5, cy), ICON)
		x += ICON + GAP
	elif not seed_type.is_empty():
		var c := Vector2(x + SEED_DISC * 0.5, cy)
		draw_circle(c, SEED_DISC * 0.5, UiPopups.OUTLINE)
		draw_circle(c, SEED_DISC * 0.5 - 4.0, UiPopups.ACTIVE_RIM)
		UiPopups.draw_flower(self, c, seed_type, 1, SEED_DISC * 1.5)
		x += SEED_DISC + GAP
	UiPopups.draw_text_outlined(self, 900, px, text, Vector2(x + UiPopups.POP_STROKE * 0.5, cy - px * 0.5), UiPopups.pop_color(spend))
	if not seed_name.is_empty():
		x += UiPopups.text_w(900, px, text) + UiPopups.POP_STROKE + NAME_GAP
		UiPopups.draw_text_outlined(self, 900, 44, seed_name, Vector2(x, cy - 22.0), UiPopups.WARM_WHITE, 8.0)


## Zarada: iskoči na `from` (centar, koordinate roditelja) pa odleti do `target`; `bump` = Control
## brojača koji kratko poskoči kad poruka stigne.
static func earn(parent: Node, from: Vector2, p_text: String, p_icon: Texture2D, target: Vector2, bump: Control = null, p_px: float = UiPopups.POP_SIZE) -> FloatPop:
	var pop := FloatPop.new().setup(p_text, false, p_icon, p_px)
	parent.add_child(pop)
	pop.position = from - pop.size * 0.5
	pop.scale = Vector2.ONE * 0.6
	var t := pop.create_tween()
	t.tween_property(pop, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(pop, "position", target - pop.size * 0.5, UiPopups.ANIM.pop_rise).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(pop, "scale", Vector2.ONE * 0.85, UiPopups.ANIM.pop_rise)
	t.tween_callback(func() -> void:
		if bump != null and is_instance_valid(bump):
			FloatPop.bump_control(bump)
	)
	t.tween_property(pop, "modulate:a", 0.0, 0.12)
	t.tween_callback(pop.queue_free)
	return pop


## Poruka koja stoji pa izblijedi na mjestu (+N iznad Trade dok se drži, ime sjemena u runu).
static func hold(parent: Node, center: Vector2, p_text: String, p_icon: Texture2D, sec: float, p_px: float = UiPopups.POP_SIZE) -> FloatPop:
	var pop := FloatPop.new().setup(p_text, false, p_icon, p_px)
	parent.add_child(pop)
	pop.position = center - pop.size * 0.5
	pop.scale = Vector2.ONE * 0.6
	var t := pop.create_tween()
	t.tween_property(pop, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_interval(sec)
	t.tween_property(pop, "modulate:a", 0.0, UiPopups.ANIM.toast_out)
	t.tween_callback(pop.queue_free)
	return pop


## Potrošnja: pojavi se ispod brojača i padne 60 px uz nestajanje (600 ms).
static func spend_at(parent: Node, center: Vector2, p_text: String, p_icon: Texture2D) -> FloatPop:
	var pop := FloatPop.new().setup(p_text, true, p_icon)
	parent.add_child(pop)
	pop.position = center - pop.size * 0.5
	var t := pop.create_tween().set_parallel()
	t.tween_property(pop, "position:y", pop.position.y + 60.0, UiPopups.ANIM.pop_spend).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(pop, "modulate:a", 0.0, UiPopups.ANIM.pop_spend).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.chain().tween_callback(pop.queue_free)
	return pop


static func bump_control(c: Control) -> void:
	c.pivot_offset = c.size * 0.5
	var t := c.create_tween()
	t.tween_property(c, "scale", Vector2.ONE * 1.08, 0.09)
	t.tween_property(c, "scale", Vector2.ONE, 0.12)
