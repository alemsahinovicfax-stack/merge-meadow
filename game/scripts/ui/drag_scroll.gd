extends RefCounted

## Swipe/drag skrol za ScrollContainer — Godot ga sam radi samo za touch, i samo
## kad dijete ne pojede event. Chipovi ga pojedu, pa ga prosljeđuju ovamo.

## Pomak veći od ovoga znači da je gesta swipe, ne tap.
const TAP_SLOP := 12.0


static func find_scroll(from: Node) -> ScrollContainer:
	var node := from
	while node != null:
		if node is ScrollContainer:
			return node as ScrollContainer
		node = node.get_parent()
	return null


## Vertikalni pomak gesture; 0.0 ako event nije drag s pritisnutim pointerom.
static func drag_delta(event: InputEvent) -> float:
	if event is InputEventScreenDrag:
		return (event as InputEventScreenDrag).relative.y
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			return motion.relative.y
	return 0.0


static func apply(scroll: ScrollContainer, dy: float) -> void:
	if scroll == null or is_zero_approx(dy):
		return
	scroll.scroll_vertical -= int(dy)
