extends Control

## HOME-14 LIFE-D — decorative Pip on SeasonField. IGNORE; FSM lives on SeasonField.
## Home v3: isti crtez (pip_idle.svg) i senka kao putujuci Pip s kartice, pa je
## predaja na kraju prelaza bez skoka.

const PIP_SIDE := 190.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(PIP_SIDE, PIP_SIDE)
	size = custom_minimum_size
	z_index = 20


func _draw() -> void:
	var side := minf(size.x, size.y)
	if side < 8.0:
		return
	UiHomeV3.draw_pip(self, Rect2(Vector2.ZERO, Vector2(side, side)), UiHomeV3.PIP_SHADOW_FIELD)
