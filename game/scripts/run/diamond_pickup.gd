extends Area2D

signal collected

var _collected: bool = false


func collect() -> void:
	if _collected:
		return
	_collected = true
	collected.emit()
	queue_free()
