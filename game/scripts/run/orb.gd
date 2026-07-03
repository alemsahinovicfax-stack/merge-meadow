extends Area2D

signal collected


func collect() -> void:
	collected.emit()
	queue_free()
