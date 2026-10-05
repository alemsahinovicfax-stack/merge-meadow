class_name SeasonBackdropView
extends Control

## Čvor koji crta mrežu SeasonBackdrop u svom rectu (polje sezone: 1080 x 1633).
## Crta se samo kad se promijeni veličina ili scena — nema petlje.

var scene: Dictionary = {}:
	set(value):
		scene = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	SeasonBackdrop.draw(self, scene, Rect2(Vector2.ZERO, size))
