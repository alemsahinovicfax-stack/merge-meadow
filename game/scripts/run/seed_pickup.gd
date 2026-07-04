extends Area2D

signal collected(type_id: String)

const TYPE_CLOVER := "clover"

var type_id: String = TYPE_CLOVER
var rarity: int = 1  # ★

var _collected: bool = false


func setup(p_type_id: String = TYPE_CLOVER, p_rarity: int = 1) -> void:
	type_id = p_type_id
	rarity = p_rarity


func collect() -> void:
	if _collected:
		return
	_collected = true
	collected.emit(type_id)
	queue_free()
