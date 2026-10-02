class_name ShopFlowerPortrait
extends Control

## Shop v2 · FlowerPortrait: krem disk s ink rubom 4 i pravim crtežom cvijeta — isto kao
## Home kartica sezone (UiHomeV3.draw_flower → CampPlantDraw.draw_cropped_plant, tier 3;
## bez SVG-a proceduralni cvijet u boji sezone). Prečnik 148, ★3 172 (Loot Burst 204).

var type_id: String = ""
var diameter: float = UiShopV2.PORTRAIT_D


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(p_type: String, d: float) -> void:
	type_id = p_type
	diameter = d
	custom_minimum_size = Vector2(d, d)
	size = custom_minimum_size
	queue_redraw()


func _draw() -> void:
	var c := Vector2(diameter, diameter) * 0.5
	draw_circle(c, diameter * 0.5, UiShopV2.INK)
	draw_circle(c, diameter * 0.5 - UiShopV2.BORDER, UiShopV2.DISC)
	if not type_id.is_empty():
		CampPlantDraw.draw_cropped_plant(self, c, type_id, 3, diameter * UiShopV2.PORTRAIT_ART)
