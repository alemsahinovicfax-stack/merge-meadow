extends Area2D

signal collected(at: Vector2)

var _collected: bool = false


func collect() -> void:
	if _collected:
		return
	_collected = true
	collected.emit(global_position)
	queue_free()
