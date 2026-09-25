class_name HomeStageHint
extends Control

## TutorialHint prve sesije (SeasonStage.dc.html · scene "new"): cream prsten
## oko Play dugmeta (scale 1.06) koji pulsira i oblacic sa strelicom na (60, 1196).
## Koordinate su koordinate Home stranice (1080 x 1633).

const TITLE := "Tap Play to start your first run"
const SUB := "The card opens your meadow."
const BUBBLE_POS := Vector2(60.0, 1196.0)
const BUBBLE_MAX_W := 760.0
const PULSE_SEC := 1.4

var target := Rect2(UiStage.PLAY_ROW.position, Vector2(UiStage.PLAY_W, UiStage.PLAY_ROW.size.y))
var _t: float = 0.0


func _init() -> void:
	name = "StageHint"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process(is_visible_in_tree())


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func get_title() -> String:
	return TITLE


func _draw() -> void:
	var s := 1.06
	var ring_rect := Rect2(target.get_center() - target.size * s * 0.5, target.size * s)
	var wave := 0.5 + 0.5 * cos(_t * TAU / PULSE_SEC)
	var ring := UiStage.box(Color.TRANSPARENT, roundi(32.0 * s), roundi(10.0 * s), Color(UiStage.HINT_RING, UiStage.HINT_RING.a * lerpf(0.45, 1.0, wave)))
	ring.draw_center = false
	draw_style_box(ring, ring_rect)

	var f_title := UiStage.font(900, 44, 1.05)
	var f_sub := UiStage.font(800, 38, 1.1)
	var max_text := BUBBLE_MAX_W - 68.0 - 8.0
	var title_lines := _wrap(TITLE, f_title, 44, max_text)
	var inner_w := UiStage.text_w(f_sub, 38, SUB)
	for line in title_lines:
		inner_w = maxf(inner_w, UiStage.text_w(f_title, 44, line))
	inner_w = minf(inner_w, max_text)
	var title_h := f_title.get_height(44) * float(title_lines.size())
	var sub_h := f_sub.get_height(38)
	var bubble := Rect2(BUBBLE_POS, Vector2(inner_w + 68.0 + 8.0, 8.0 + 52.0 + title_h + 10.0 + sub_h))
	draw_style_box(UiStage.box(UiStage.CREAM, 28, 4, UiStage.INK), bubble)
	var x := bubble.position.x + 4.0 + 34.0
	var top := bubble.position.y + 4.0 + 26.0
	for line in title_lines:
		draw_string(f_title, Vector2(x, UiStage.baseline(f_title, 44, top)), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 44, UiStage.INK)
		top += f_title.get_height(44)
	top += 10.0
	draw_string(f_sub, Vector2(x, UiStage.baseline(f_sub, 38, top)), SUB, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, UiStage.INK_SOFT)
	var ax := bubble.position.x + 110.0
	var ay := bubble.end.y
	draw_colored_polygon(PackedVector2Array([
		Vector2(ax, ay), Vector2(ax + 52.0, ay), Vector2(ax + 26.0, ay + 30.0)
	]), UiStage.INK)


func _wrap(text: String, f: Font, px: int, max_w: float) -> PackedStringArray:
	var out := PackedStringArray()
	var line := ""
	for word in text.split(" "):
		var candidate := word if line.is_empty() else line + " " + word
		if not line.is_empty() and UiStage.text_w(f, px, candidate) > max_w:
			out.append(line)
			line = word
		else:
			line = candidate
	if not line.is_empty():
		out.append(line)
	return out
