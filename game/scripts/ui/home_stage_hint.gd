class_name HomeStageHint
extends Control

## H1 · TutorialHint prve sesije (design_handoff_popups): oblačić „Tap Play to start" pokazuje na
## Play, a prsten oko Play je jedini loop na Homeu. Koordinate su koordinate stranice.

const TITLE := "Tap Play to start"

var target: Rect2 = UiHomeV3.PLAY_CARD.rect
var _t: float = 0.0
var _bubble: CoachBubble


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


## H1 · (design_handoff_popups) oblačić sistema s repom dolje na Play (lijevo od Pipa) i ink prsten
## 6 px oko Play koji se širi 1 → 1,16 i gasi (1,2 s) — jedini loop na Homeu, staje na Play.
func _ensure_bubble() -> void:
	if _bubble != null:
		return
	_bubble = CoachBubble.new()
	_bubble.name = "CoachBubble"
	add_child(_bubble)
	_bubble.setup([{"text": TITLE, "lead": true, "px": 44}], "down")
	_place_bubble()


func _place_bubble() -> void:
	if _bubble == null:
		return
	var tip := Vector2(target.position.x + target.size.x * 0.48, target.position.y - 4.0)
	_bubble.point_at(tip, 0.85, Rect2(24, 0, 1032, 1633))


func _draw() -> void:
	_ensure_bubble()
	var k := fmod(_t, UiPopups.ANIM.ring) / UiPopups.ANIM.ring
	var grow := clampf(k / 0.6, 0.0, 1.0)
	var sc := lerpf(1.0, 1.16, grow)
	var alpha := lerpf(0.7, 0.0, grow)
	var r := Rect2(target.get_center() - target.size * sc * 0.5, target.size * sc)
	var ring := UiStage.box(Color.TRANSPARENT, roundi(70.0 * sc), roundi(6.0 * sc), Color(UiPopups.OUTLINE, alpha))
	ring.draw_center = false
	draw_style_box(ring, r)
