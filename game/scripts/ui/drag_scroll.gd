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
## Emulirani miš (telefon) se preskače — isti pomak već stiže kao ScreenDrag.
static func drag_delta(event: InputEvent) -> float:
	if event is InputEventScreenDrag:
		return (event as InputEventScreenDrag).relative.y
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if motion.device == InputEvent.DEVICE_ID_EMULATION:
			return 0.0
		if motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			return motion.relative.y
	return 0.0


## Dugme unutar skrola (FIX-TEL): dodir NE smije stati na dugmetu, inače lista skrola samo
## između kartica. Dugme je zato MOUSE_FILTER_PASS, dodir ne prihvata (ScrollContainer ga
## dobije i skrola sam, s inercijom), a tap okida tek na puštanje ako je pomak <= TAP_SLOP.
static func in_scroll(control: Control) -> bool:
	return find_scroll(control.get_parent()) != null


## Djeca skrola koja samo crtaju ne smiju pojesti dodir (Control je po defaultu STOP).
static func let_touch_through(node: Node) -> void:
	for child in node.get_children():
		if child is ScrollContainer:
			continue
		var c := child as Control
		if c != null and c.mouse_filter == Control.MOUSE_FILTER_STOP:
			c.mouse_filter = Control.MOUSE_FILTER_PASS
		let_touch_through(child)


static func apply(scroll: ScrollContainer, dy: float) -> void:
	if scroll == null or is_zero_approx(dy):
		return
	scroll.scroll_vertical -= int(dy)
