class_name RewardChip
extends Control

## Pop-up sistem · RewardChip (design_handoff_popups § Sistem): nagrada kao crtež + broj.
## Bijela pilula h 132, rub 3 ink. Lijevo coin 84 ili disk 92 (RIM) s crtežom sjemena / cvijeta
## iz igre; desno broj 56/900. Varijanta „pola": stari broj 40/800 precrtan ispred novog.
## Varijanta „×2": zlatni tag na gornjem desnom uglu.

const PAD_L := 17.0
const PAD_R := 28.0
const GAP := 16.0
const WAS_GAP := 12.0
const COIN := 84.0
const ART_BOX := 112.0
const TAG := Vector2(76, 46)
const TAG_TEXT := 34.0

## coin | seed (tier 1) | flower (tier 3)
var kind: String = "coin"
var type_id: String = ""
var count: int = 0
## Broj prije prepolovljenja (pad / pauza); -1 = nema.
var was: int = -1
var doubled: bool = false
var sign_plus: bool = true


func setup(p_kind: String, p_type: String, p_count: int, p_was: int = -1, p_doubled: bool = false, p_plus: bool = true) -> RewardChip:
	kind = p_kind
	type_id = p_type
	count = p_count
	was = p_was
	doubled = p_doubled
	sign_plus = p_plus
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(chip_width(), UiPopups.CHIP_H)
	queue_redraw()
	return self


func count_text() -> String:
	return ("+%d" % count) if sign_plus else str(count)


func chip_width() -> float:
	var w := PAD_L + UiPopups.CHIP_ART + GAP
	if was >= 0:
		w += UiPopups.text_w(800, UiPopups.CHIP_WAS, str(was)) + WAS_GAP
	w += UiPopups.text_w(900, UiPopups.CHIP_NUMBER, count_text()) + PAD_R
	return ceilf(w)


func _draw() -> void:
	var h := float(UiPopups.CHIP_H)
	draw_style_box(UiPopups.reward_chip(), Rect2(Vector2.ZERO, Vector2(size.x, h)))
	var cy := h * 0.5
	var art_c := Vector2(PAD_L + UiPopups.CHIP_ART * 0.5, cy)
	if kind == "coin":
		UiPopups.draw_icon(self, UiPopups.icon("icon_coin"), art_c, COIN)
	else:
		var d := float(UiPopups.CHIP_ART)
		draw_style_box(UiPopups.chip_art_disc(), Rect2(art_c - Vector2(d, d) * 0.5, Vector2(d, d)))
		UiPopups.draw_flower(self, art_c, type_id, 3 if kind == "flower" else 1, ART_BOX)
	var x := PAD_L + UiPopups.CHIP_ART + GAP
	if was >= 0:
		var t := str(was)
		var ww := UiPopups.text_w(800, UiPopups.CHIP_WAS, t)
		UiPopups.draw_text(self, 800, UiPopups.CHIP_WAS, t, Vector2(x, cy - UiPopups.CHIP_WAS * 0.5), UiPopups.INK_SOFT)
		draw_line(Vector2(x - 2.0, cy + 1.0), Vector2(x + ww + 2.0, cy + 1.0), UiPopups.INK_SOFT, 4.0)
		x += ww + WAS_GAP
	UiPopups.draw_text(self, 900, UiPopups.CHIP_NUMBER, count_text(), Vector2(x, cy - UiPopups.CHIP_NUMBER * 0.5), UiPopups.OUTLINE)
	if doubled:
		var r := Rect2(Vector2(size.x - TAG.x + 14.0, -TAG.y * 0.45), TAG)
		draw_style_box(UiPopups.double_tag(), r)
		UiPopups.draw_text_centered(self, 900, TAG_TEXT, "×2", r, UiPopups.OUTLINE)
