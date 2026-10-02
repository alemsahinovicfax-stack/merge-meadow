class_name CoachBubble
extends Control

## Pop-up sistem · Oblačić (design_handoff_popups § Sistem): krem, rub 4, radius 32, padding 34 / 26,
## max 760, tvrda sjena 8 (na runu tamnija). Redovi: disk ikone 72 (+ ikona 46 ili crtež sjemena)
## i tekst 44/800; vodeći red bez diska 48/900. Rep 52 × 32 (ink) + 36 × 24 (krem) u 4 smjera ili
## bez repa. Ne blokira unos (mouse_filter IGNORE). Ulaz 0,85 → 1 iz vrha repa (180 ms).

const ROW_GAP := 16.0
const DISC := 72.0
const DISC_ICON := 46.0
const DISC_ART := 94.0
const TEXT_GAP := 18.0
const LINE_K := 1.2
const LEAD_PX := 48.0

## Redovi: {text, lead?, icon?: Texture2D, art?: type_id, tier?: int, disc?: Color}
var rows: Array = []
## up | down | left | right | none
var dir: String = "down"
## Mjesto repa duž ivice (lokalne px); < 0 = sredina.
var tail_at: float = -1.0
var on_run: bool = false
var max_w: float = UiPopups.COACH_MAX_W

var _layout_rows: Array = []
var _tween: Tween


func _init() -> void:
	name = "CoachBubble"
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(p_rows: Array, p_dir: String = "down", p_on_run: bool = false) -> CoachBubble:
	rows = p_rows
	dir = p_dir
	on_run = p_on_run
	_measure()
	queue_redraw()
	return self


## Postavi oblačić tako da vrh repa dodiruje `tip` (koordinate roditelja); `along` = gdje je rep
## duž ivice (0..1). Rezultat se drži unutar `bounds`.
func point_at(tip: Vector2, along: float = 0.5, bounds: Rect2 = Rect2()) -> void:
	var t := float(UiPopups.COACH_TAIL.y)
	var pos := Vector2.ZERO
	match dir:
		"down":
			pos = Vector2(tip.x - size.x * along, tip.y - t - size.y)
		"up":
			pos = Vector2(tip.x - size.x * along, tip.y + t)
		"left":
			pos = Vector2(tip.x + t, tip.y - size.y * along)
		"right":
			pos = Vector2(tip.x - t - size.x, tip.y - size.y * along)
		_:
			pos = tip - size * 0.5
	if bounds.size.x > 1.0:
		pos.x = clampf(pos.x, bounds.position.x, bounds.end.x - size.x)
		pos.y = clampf(pos.y, bounds.position.y, bounds.end.y - size.y)
	position = pos.round()
	var local := tip - position
	var r := UiPopups.COACH_RADIUS + UiPopups.COACH_TAIL.x * 0.5
	if dir in ["up", "down"]:
		tail_at = clampf(local.x, r, size.x - r)
	else:
		tail_at = clampf(local.y, r, size.y - r)
	queue_redraw()


func tail_tip() -> Vector2:
	var t := float(UiPopups.COACH_TAIL.y)
	var a := _tail_anchor()
	match dir:
		"down": return a + Vector2(0, t)
		"up": return a - Vector2(0, t)
		"left": return a - Vector2(t, 0)
		"right": return a + Vector2(t, 0)
	return size * 0.5


func pop_in() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	visible = true
	if not is_inside_tree():
		return
	_tween = UiPopups.tween_coach_in(self, tail_tip())


func pop_out() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not is_inside_tree() or not visible:
		visible = false
		return
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, UiPopups.ANIM.coach_out)
	_tween.tween_callback(func() -> void:
		visible = false
		modulate.a = 1.0
	)


func text() -> String:
	var parts: PackedStringArray = []
	for r in rows:
		parts.append(str((r as Dictionary).get("text", "")))
	return " / ".join(parts)


func _measure() -> void:
	var pad := Vector2(UiPopups.COACH_PAD)
	_layout_rows.clear()
	var inner_max := max_w - pad.x * 2.0
	var w := 0.0
	var h := 0.0
	for r: Dictionary in rows:
		var lead := bool(r.get("lead", false))
		var has_disc := not lead and (r.has("icon") or r.has("art"))
		var px := float(r.get("px", LEAD_PX if lead else float(UiPopups.COACH_TEXT)))
		var weight := 900 if lead else 800
		var text_max := inner_max - (DISC + TEXT_GAP if has_disc else 0.0)
		var lines := UiPopups.wrap_lines(weight, px, str(r.get("text", "")), text_max)
		var tw := 0.0
		for line in lines:
			tw = maxf(tw, UiPopups.text_w(weight, px, line))
		var th := px * LINE_K * lines.size()
		var rh := maxf(th, DISC if has_disc else 0.0)
		var rw := tw + (DISC + TEXT_GAP if has_disc else 0.0)
		_layout_rows.append({"lines": lines, "px": px, "weight": weight, "disc": has_disc, "h": rh, "th": th, "r": r})
		w = maxf(w, rw)
		h += rh
	h += ROW_GAP * maxf(0.0, rows.size() - 1)
	size = Vector2(ceilf(w + pad.x * 2.0), ceilf(h + pad.y * 2.0))
	custom_minimum_size = size


func _tail_anchor() -> Vector2:
	var at := tail_at
	match dir:
		"down":
			return Vector2(at if at >= 0.0 else size.x * 0.5, size.y)
		"up":
			return Vector2(at if at >= 0.0 else size.x * 0.5, 0.0)
		"left":
			return Vector2(0.0, at if at >= 0.0 else size.y * 0.5)
		"right":
			return Vector2(size.x, at if at >= 0.0 else size.y * 0.5)
	return size * 0.5


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if dir != "none":
		var a := _tail_anchor()
		var outer := UiPopups.coach_tail_points(dir, true)
		var drop := UiPopups.RUN_DROP if on_run else UiPopups.DROP
		var shifted := PackedVector2Array()
		for p in outer:
			shifted.append(a + p + Vector2(0, 8))
		draw_colored_polygon(shifted, drop)
	draw_style_box(UiPopups.coach_bubble(on_run), rect)
	if dir != "none":
		var a2 := _tail_anchor()
		var o := PackedVector2Array()
		for p in UiPopups.coach_tail_points(dir, true):
			o.append(a2 + p)
		draw_colored_polygon(o, UiPopups.OUTLINE)
		var i := PackedVector2Array()
		for p in UiPopups.coach_tail_points(dir, false):
			i.append(a2 + p)
		draw_colored_polygon(i, UiPopups.WARM_WHITE)
	var pad := Vector2(UiPopups.COACH_PAD)
	var y := pad.y
	for lr: Dictionary in _layout_rows:
		var x := pad.x
		var rh := float(lr.h)
		var r: Dictionary = lr.r
		if bool(lr.disc):
			var dc := Vector2(x + DISC * 0.5, y + rh * 0.5)
			draw_style_box(UiPopups.coach_icon_disc(r.get("disc", UiPopups.ACTIVE_RIM)), Rect2(dc - Vector2(DISC, DISC) * 0.5, Vector2(DISC, DISC)))
			if r.has("icon"):
				UiPopups.draw_icon(self, r.icon, dc, DISC_ICON)
			else:
				UiPopups.draw_flower(self, dc, str(r.art), int(r.get("tier", 1)), DISC_ART)
			x += DISC + TEXT_GAP
		var px := float(lr.px)
		var ty := y + (rh - float(lr.th)) * 0.5
		for line in lr.lines:
			UiPopups.draw_text(self, int(lr.weight), px, line, Vector2(x, ty + px * (LINE_K - 1.0) * 0.5), UiPopups.OUTLINE)
			ty += px * LINE_K
		y += rh + ROW_GAP
