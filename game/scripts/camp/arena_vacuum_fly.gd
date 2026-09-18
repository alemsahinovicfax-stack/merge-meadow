class_name ArenaVacuumFly
extends Control

## Samo vizual, nije ArenaSeedChip: ostatak koji leti nazad u vrecu (T1/T2)
## ili T3 kristal koji leti u StashCounter.

var type_id: String = ""
var tier: int = 1

var _mythic: bool = false


func setup(seed_type: String, seed_tier: int, center: Vector2) -> void:
	type_id = seed_type
	tier = seed_tier
	_mythic = GameState.is_mythic_seed(seed_type)
	name = "VacuumFly"
	var side := UiArena.FLOWER_SIZE_T3 if seed_tier >= 3 else ArenaSeedChip.CHIP_RADIUS * 2.0
	custom_minimum_size = Vector2(side, side)
	size = custom_minimum_size
	pivot_offset = size * 0.5
	position = center - size * 0.5
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 60
	queue_redraw()


func _draw() -> void:
	ArenaChipDraw.draw_chip(self, size * 0.5, type_id, tier, _mythic)
