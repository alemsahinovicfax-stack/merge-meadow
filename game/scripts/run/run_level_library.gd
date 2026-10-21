extends Node

## Run leveli 1–20 (Level Path svake sezone; level N iste je težine u svakoj sezoni) i Endless
## rampa — sve iz data/run_levels/levels.json (balans ciklus 1, 2026-10-21).
##
## Endless nema kraja: kreće lagano i svakih ENDLESS_TIER_SEC s („Pace") postaje teži — brže,
## gušće, više prepreka i parova — dok Pip ne udari ili igrač ne izađe. Vrijednosti stepenice se
## interpoliraju između ključeva iz JSON-a; poslije zadnjeg ključa raste samo brzina.

const LEVELS_PATH := "res://data/run_levels/levels.json"
const MAX_RUN_LEVEL := 20
const ENDLESS_TIER_SEC := 20.0
const _RunLevelConfig := preload("res://scripts/run/run_level_config.gd")
## Polja koja se interpoliraju između Endless ključeva.
const _ENDLESS_FIELDS: Array[String] = [
	"scroll_speed_mult", "spawn_interval", "spawn_chance", "obstacle_chance",
	"pair_chance", "pickup_seed_chance", "rare2_mult", "rare3_mult",
]

var _by_id: Dictionary = {}
var _endless_keys: Array[Dictionary] = []
var _endless_after_speed: float = 0.0
var _endless_max: Dictionary = {}
var _loaded: bool = false


func get_level(level_id: int):
	_ensure_loaded()
	var id := clampi(level_id, 1, MAX_RUN_LEVEL)
	if _by_id.has(id):
		return _by_id[id]
	return _default_config(id)


## Stepenica Endlessa u kojoj je run poslije `elapsed` s (0, 1, 2…).
func endless_tier(elapsed: float) -> int:
	return maxi(0, int(floor(elapsed / ENDLESS_TIER_SEC)))


## Config Endlessa za stepenicu u kojoj je `elapsed` (drži se do sljedeće stepenice).
func get_endless_config_at(elapsed: float):
	_ensure_loaded()
	var tier := endless_tier(elapsed)
	var t := float(tier) * ENDLESS_TIER_SEC
	var cfg = _RunLevelConfig.new()
	cfg.id = tier + 1
	cfg.duration_sec = INF
	cfg.speed_ramp = 0.0
	if _endless_keys.is_empty():
		var base = get_level(1)
		for f in _ENDLESS_FIELDS:
			cfg.set(f, base.get(f))
		return cfg
	var last: Dictionary = _endless_keys[_endless_keys.size() - 1]
	if t >= float(last.t):
		for f in _ENDLESS_FIELDS:
			cfg.set(f, float(last.get(f, cfg.get(f))))
		var extra_tiers := floorf((t - float(last.t)) / ENDLESS_TIER_SEC)
		cfg.scroll_speed_mult = float(last.scroll_speed_mult) + _endless_after_speed * extra_tiers
	else:
		var i := 0
		while i + 1 < _endless_keys.size() and float(_endless_keys[i + 1].t) <= t:
			i += 1
		var a: Dictionary = _endless_keys[i]
		var b: Dictionary = _endless_keys[mini(i + 1, _endless_keys.size() - 1)]
		var span := float(b.t) - float(a.t)
		var k := 0.0 if span <= 0.0 else (t - float(a.t)) / span
		for f in _ENDLESS_FIELDS:
			var va := float(a.get(f, cfg.get(f)))
			cfg.set(f, va + (float(b.get(f, va)) - va) * k)
	for f in _endless_max:
		cfg.set(f, minf(float(cfg.get(f)), float(_endless_max[f])))
	return cfg


func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_by_id.clear()
	_endless_keys.clear()
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
	if levels is Array:
		for entry in levels:
			if entry is Dictionary:
				var cfg = _RunLevelConfig.from_dict(entry, _RunLevelConfig)
				_by_id[cfg.id] = cfg
	var endless: Variant = parsed.get("endless", {})
	if endless is Dictionary:
		var keys: Variant = endless.get("keys", [])
		if keys is Array:
			for k in keys:
				if k is Dictionary:
					_endless_keys.append(k)
		_endless_keys.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.t) < float(b.t))
		_endless_after_speed = maxf(0.0, float(endless.get("after_last_speed_per_tier", 0.0)))
		var mx: Variant = endless.get("max", {})
		if mx is Dictionary:
			_endless_max = mx


func _default_config(level_id: int):
	var cfg = _RunLevelConfig.new()
	cfg.id = level_id
	cfg.duration_sec = 60.0
	cfg.spawn_interval = 1.2
	cfg.spawn_chance = 0.7
	cfg.obstacle_chance = 0.1
	cfg.pickup_seed_chance = 0.3
	return cfg
