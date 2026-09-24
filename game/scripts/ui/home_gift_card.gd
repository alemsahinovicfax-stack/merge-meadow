class_name HomeGiftCard
extends Control

## DailyGiftCard 180 x 180 u Play redu (SeasonStage.dc.html): cream kartica,
## lavanda kutija 84 s cream trakama, "Gift" i roze tacka dok je poklon spreman.

var claimable: bool = false:
	set(value):
		claimable = value
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(UiStage.GIFT, UiStage.GIFT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_style_box(UiStage.box(UiStage.CREAM, 32, 3, UiStage.INK), r)
	var top := (size.y - 84.0 - 10.0 - 38.0) * 0.5
	var gift := Rect2((size.x - 84.0) * 0.5, top, 84.0, 84.0)
	draw_style_box(UiStage.box(UiStage.LAVENDER, 18), gift)
	var inner := gift.grow(-3.0)
	draw_rect(Rect2(inner.position.x + 32.0, inner.position.y, 14.0, inner.size.y), UiStage.CREAM)
	draw_rect(Rect2(inner.position.x, inner.position.y + 32.0, inner.size.x, 14.0), UiStage.CREAM)
	var edge := UiStage.box(Color.TRANSPARENT, 18, 3, UiStage.INK)
	edge.draw_center = false
	draw_style_box(edge, gift)
	var f := UiStage.font(900, 38)
	UiStage.draw_text_centered(self, f, 38, "Gift", Rect2(0.0, gift.end.y + 10.0, size.x, 38.0), UiStage.INK)
	if claimable:
		var dot := Rect2(size.x - 3.0 + 12.0 - 48.0, 3.0 - 12.0, 48.0, 48.0)
		draw_style_box(UiStage.box(UiStage.PINK, 24, 4, UiStage.PAGE_BG), dot)
