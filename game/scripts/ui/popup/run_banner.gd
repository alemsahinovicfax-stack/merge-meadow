class_name RunBanner
extends Control

## R4 · banner kraja runa (design_handoff_popups): ModalPlate h 180 (radius 90, rub 5, tvrda sjena 12
## tamna) s tekstom 104/900 centriran na y 640. „Time!" (mint) + chip „Nothing lost" (krem pilula 88,
## mint disk 60 s korpom); „Ouch!" (roze) kod pada, bez dugmeta. Drži ~1 s pa ide R5.

const HOLD_SEC := 1.0
## „Ouch!" je kraći (≤ 1 s ukupno od udarca do R5).
const HOLD_OUCH_SEC := 0.55
const PLATE_PAD := 85.0
const CHIP_H := 88.0
const CHIP_GAP := 24.0
const CHIP_DISC := 60.0

var time_up: bool = true

var _tween: Tween


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(p_time_up: bool) -> RunBanner:
	time_up = p_time_up
	queue_redraw()
	return self


func hold_sec() -> float:
	return HOLD_SEC if time_up else HOLD_OUCH_SEC


func get_text() -> String:
	return UiPopups.S_TIME if time_up else UiPopups.S_OUCH


func pop_in() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	pivot_offset = Vector2(size.x * 0.5, UiPopups.BANNER_H * 0.5)
	scale = Vector2.ONE * 0.9
	modulate.a = 0.0
	if not is_inside_tree():
		scale = Vector2.ONE
		modulate.a = 1.0
		return
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "scale", Vector2.ONE, UiPopups.ANIM.modal_in).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", 1.0, UiPopups.ANIM.modal_in)


func _draw() -> void:
	var text := get_text()
	var h := float(UiPopups.BANNER_H)
	var w := UiPopups.text_w(900, UiPopups.BANNER_TITLE, text) + PLATE_PAD * 2.0
	var r := Rect2((size.x - w) * 0.5, 0.0, w, h)
	var sb := UiPopups._hard_shadow(
		UiPopups._box(UiPopups.MINT if time_up else UiPopups.PINK, int(h / 2.0), UiPopups.BANNER_BORDER),
		UiPopups.BANNER_SHADOW, UiPopups.RUN_DROP
	)
	draw_style_box(sb, r)
	UiPopups.draw_text_centered(self, 900, UiPopups.BANNER_TITLE, text, r, UiPopups.OUTLINE)
	if not time_up:
		return
	var label := UiPopups.S_NOTHING_LOST
	var cw := 18.0 + CHIP_DISC + 14.0 + UiPopups.text_w(900, 44, label) + 34.0
	var c := Rect2((size.x - cw) * 0.5, h + CHIP_GAP, cw, CHIP_H)
	draw_style_box(UiPopups._box(UiPopups.WARM_WHITE, int(CHIP_H / 2.0), 4), c)
	var dc := Vector2(c.position.x + 18.0 + CHIP_DISC * 0.5, c.get_center().y)
	draw_style_box(UiPopups._box(UiPopups.MINT, int(CHIP_DISC / 2.0), 3), Rect2(dc - Vector2(CHIP_DISC, CHIP_DISC) * 0.5, Vector2(CHIP_DISC, CHIP_DISC)))
	UiPopups.draw_icon(self, UiPopups.icon("icon_basket"), dc, 38.0)
	UiPopups.draw_text(self, 900, 44, label, Vector2(dc.x + CHIP_DISC * 0.5 + 14.0, c.get_center().y - 22.0), UiPopups.OUTLINE)
