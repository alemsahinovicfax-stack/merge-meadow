class_name HomePlayDisc
extends Control

## Ikona Play dugmeta na biranju sezone: cream krug 112 (rub 3) i ▶ 38 x 48
## pomaknut 5 px udesno (margin-left 10 u SeasonStage.dc.html).


func _init() -> void:
	name = "PlayDisc"
	custom_minimum_size = Vector2(112, 112)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, custom_minimum_size)
	r.position.y = (size.y - r.size.y) * 0.5
	draw_style_box(UiStage.box(UiStage.CREAM, 56, 3, UiStage.INK), r)
	var c := r.get_center()
	UiStage.draw_play(self, Rect2(c.x + 5.0 - 19.0, c.y - 24.0, 38.0, 48.0), UiStage.INK)
