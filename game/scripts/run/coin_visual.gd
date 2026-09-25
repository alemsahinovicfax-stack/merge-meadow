extends Sprite2D

## Novčić u runu — ikona icon_coin.svg na 96 px, ista koja stoji u headeru, Campu
## i Shopu (design_handoff_hub_chrome_v2). Kolizija ostaje r 18 na roditelju.
## Crta se ručno da sjena ostane ISPOD novčića; Sprite2D.texture bi je prekrio.

var _phase: float = 0.0
var _tex: Texture2D = null


func _ready() -> void:
	texture = null
	centered = true
	_tex = UiAssets.get_chrome_icon("icon_coin")
	_phase = randf() * TAU
	queue_redraw()


func _process(delta: float) -> void:
	_phase += delta * 2.6
	position.y = sin(_phase) * 5.0


func _draw() -> void:
	_draw_shadow()
	var side := float(UiRun.COIN_SIZE)
	if _tex == null:
		# Fallback dok import ne prođe (greske-katalog #6).
		draw_circle(Vector2.ZERO, side * 0.5, UiRun.COIN_FILL)
		draw_arc(Vector2.ZERO, side * 0.5 - 2.0, 0.0, TAU, 40, UiRun.COIN_EDGE, 5.0, true)
		return
	draw_texture_rect(_tex, Rect2(Vector2(-side, -side) * 0.5, Vector2(side, side)), false)


func _draw_shadow() -> void:
	var size := UiRun.PICKUP_SHADOW_SIZE
	var center := Vector2(0.0, float(UiRun.PICKUP_SHADOW_OFFSET))
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * float(i) / 18.0
		pts.append(center + Vector2(cos(a) * size.x * 0.5, sin(a) * size.y * 0.5))
	draw_colored_polygon(pts, UiRun.PICKUP_SHADOW)
