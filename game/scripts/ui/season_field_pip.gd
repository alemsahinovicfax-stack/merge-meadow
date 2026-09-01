extends Control

## HOME-14 LIFE-D — decorative Pip on SeasonField. IGNORE; FSM lives on SeasonField.

const PIP_SIDE := 72.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(PIP_SIDE, PIP_SIDE)
	size = custom_minimum_size
	z_index = 20


func _draw() -> void:
	var side := minf(size.x, size.y)
	if side < 8.0:
		return
	PipDraw.draw_pip(self, size * 0.5, side / 56.0)
