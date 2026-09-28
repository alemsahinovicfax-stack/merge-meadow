class_name HomeV3Marks
extends Control

## Crteži bez dodira na Home stranici (koordinate stranice 1080 x 1633):
## KIND_DOTS  — SeasonDots, samo indikator (24 / 64 x 24, gap 22, peach = sezona
##              u kojoj se igra, rub 3 ink);
## KIND_EDGE  — CardEdge, rub kartice iznad polja (4 → 0, radius 48 → 0);
## KIND_NAME  — SeasonName, JEDAN objekat: 80 px na kartici → 56 px SeasonLabel;
## KIND_PIP   — MeadowPip, JEDAN objekat: 230 na kartici → 190 na livadi;
## KIND_TOAST — tamni toast 600 x 100 na y 1250.

const KIND_DOTS := "dots"
const KIND_EDGE := "edge"
const KIND_NAME := "name"
const KIND_PIP := "pip"
const KIND_TOAST := "toast"

@export var kind: String = KIND_DOTS
## dots: [{w, fill, ring}] · edge: rect, border, radius · name: text, top, px,
## tracking, offset_x · pip: rect, shadow [l, b, w, h] · toast: text.
var dots: Array = []
var rect := Rect2()
var border: float = 0.0
var radius: float = 0.0
var text: String = ""
var top: float = 0.0
var px: float = 80.0
var tracking: float = 0.0
var offset_x: float = 0.0
var shadow: Array = UiHomeV3.PIP_SHADOW_CARD


func _init(k: String = KIND_DOTS) -> void:
	kind = k
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = UiHomeV3.PAGE


func _draw() -> void:
	match kind:
		KIND_DOTS:
			_draw_dots()
		KIND_EDGE:
			if border > 0.05 and rect.size.x > 1.0:
				var sb := UiStage.box(Color.TRANSPARENT, roundi(radius), maxi(1, roundi(border)), UiHomeV3.INK)
				sb.draw_center = false
				if border < 0.5:
					sb.border_color = Color(UiHomeV3.INK, border * 2.0)
				draw_style_box(sb, rect)
		KIND_NAME:
			if not text.is_empty():
				var w := UiHomeV3.text_w(900, px, text, tracking)
				UiHomeV3.draw_text(self, 900, px, text, Vector2(UiHomeV3.PAGE.x * 0.5 - w * 0.5 + offset_x, top), UiHomeV3.INK_DEEP, tracking)
		KIND_PIP:
			if rect.size.x > 1.0:
				UiHomeV3.draw_pip(self, rect, shadow)
		KIND_TOAST:
			if not text.is_empty():
				var w := maxf(UiHomeV3.TOAST_RECT.size.x, UiHomeV3.text_w(900, UiHomeV3.TOAST_LABEL, text) + 80.0)
				var r := Rect2(UiHomeV3.PAGE.x * 0.5 - w * 0.5, UiHomeV3.TOAST_RECT.position.y, w, UiHomeV3.TOAST_RECT.size.y)
				draw_style_box(UiStage.box(UiHomeV3.TOAST_BG, 28), r)
				var tw := UiHomeV3.text_w(900, UiHomeV3.TOAST_LABEL, text)
				UiHomeV3.draw_text(self, 900, UiHomeV3.TOAST_LABEL, text, Vector2(r.get_center().x - tw * 0.5, r.get_center().y - UiHomeV3.TOAST_LABEL * 0.5), UiHomeV3.CREAM)


func _draw_dots() -> void:
	if dots.is_empty():
		return
	var total := 0.0
	for d in dots:
		total += float((d as Dictionary).get("w", UiHomeV3.DOT_W))
	total += UiHomeV3.DOT_GAP * float(dots.size() - 1)
	var x := UiHomeV3.PAGE.x * 0.5 - total * 0.5
	for d in dots:
		var dd := d as Dictionary
		var w := float(dd.get("w", UiHomeV3.DOT_W))
		var r := Rect2(x, UiHomeV3.DOTS_TOP, w, UiHomeV3.DOT_H)
		var ring := bool(dd.get("ring", false))
		draw_style_box(UiStage.box(dd.get("fill", UiHomeV3.DOT_IDLE), 12, 3 if ring else 0, UiHomeV3.INK), r)
		x += w + UiHomeV3.DOT_GAP
