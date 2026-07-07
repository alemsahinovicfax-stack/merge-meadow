extends Node

## Run leveli 1–10: JSON. 11–100: curve (nivoi/_index.md).

const LEVELS_PATH := "res://data/run_levels/levels_1_10.json"
const MAX_RUN_LEVEL := 100
const ENDLESS_SPAWN_MULT := 0.9
const ENDLESS_DIFFICULTY_LEVELS: Dictionary = {
	0: 20,  # Easy — rana sredina krivulje
	1: 50,  # Normal — mid-game
	2: 85,  # Hard — kasna igra
}
const _RunLevelConfig := preload("res://scripts/run/run_level_config.gd")

var _by_id: Dictionary = {}
var _loaded: bool = false


func get_level(level_id: int):
	_ensure_loaded()
	var id := clampi(level_id, 1, MAX_RUN_LEVEL)
	if _by_id.has(id):
		return _by_id[id]
	if id > 10:
		return _generate_curve_level(id)
	if _by_id.is_empty():
		return _default_config(id)
	var max_defined: int = _max_defined_id()
	return _by_id.get(max_defined, _default_config(id))


func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_by_id.clear()
	if not FileAccess.file_exists(LEVELS_PATH):
		push_warning("RunLevelLibrary: missing %s" % LEVELS_PATH)
		return
	var file := FileAccess.open(LEVELS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	var levels: Variant = parsed.get("levels", [])
	if not levels is Array:
		return
	for entry in levels:
		if entry is Dictionary:
			var cfg = _RunLevelConfig.from_dict(entry, _RunLevelConfig)
			_by_id[cfg.id] = cfg


func _generate_curve_level(id: int):
	# Curve pass 2 — oštrija rampa: brži scroll, gušći spawn, više prepreka.
	var cfg = _RunLevelConfig.new()
	cfg.id = id
	cfg.pickup_seed_chance = 0.30

	if id <= 40:
		var t := float(id - 11) / 29.0
		cfg.duration_sec = _lerp(58.0, 72.0, t)
		cfg.scroll_speed_mult = _lerp(1.05, 1.18, t)
		cfg.obstacle_chance = _lerp(0.17, 0.30, t)
		cfg.spawn_interval = _lerp(1.08, 0.88, t)
		cfg.spawn_chance = _lerp(0.71, 0.76, t)
	elif id <= 70:
		var t := float(id - 41) / 29.0
		cfg.duration_sec = _lerp(72.0, 88.0, t)
		cfg.scroll_speed_mult = _lerp(1.18, 1.32, t)
		cfg.obstacle_chance = _lerp(0.30, 0.42, t)
		cfg.spawn_interval = _lerp(0.88, 0.72, t)
		cfg.spawn_chance = _lerp(0.76, 0.74, t)
	else:
		var t := float(id - 71) / 29.0
		cfg.duration_sec = _lerp(88.0, 90.0, t)
		cfg.scroll_speed_mult = _lerp(1.32, 1.50, t)
		cfg.obstacle_chance = _lerp(0.42, 0.52, t)
		cfg.spawn_interval = _lerp(0.72, 0.58, t)
		cfg.spawn_chance = _lerp(0.74, 0.72, t)

	return cfg


func get_endless_config_for_difficulty(difficulty: int):
	var level_id: int = int(ENDLESS_DIFFICULTY_LEVELS.get(difficulty, 50))
	return get_endless_config(level_id)


func get_endless_config(source_level: int):
	var base = get_level(clampi(source_level, 1, MAX_RUN_LEVEL))
	var cfg = _RunLevelConfig.new()
	cfg.id = base.id
	cfg.duration_sec = base.duration_sec
	cfg.scroll_speed_mult = base.scroll_speed_mult
	cfg.spawn_interval = base.spawn_interval
	cfg.spawn_chance = clampf(base.spawn_chance * ENDLESS_SPAWN_MULT, 0.0, 1.0)
	cfg.obstacle_chance = base.obstacle_chance
	cfg.pickup_seed_chance = base.pickup_seed_chance
	return cfg


func _lerp(a: float, b: float, t: float) -> float:
	return a + (b - a) * clampf(t, 0.0, 1.0)


func _max_defined_id() -> int:
	var max_id := 1
	for key in _by_id:
		max_id = maxi(max_id, int(key))
	return max_id


func _default_config(level_id: int):
	var cfg = _RunLevelConfig.new()
	cfg.id = level_id
	cfg.duration_sec = 60.0
	cfg.spawn_interval = 1.2
	cfg.spawn_chance = 0.7
	cfg.obstacle_chance = 0.1
	cfg.pickup_seed_chance = 0.3
	return cfg
