extends RefCounted

var id: int = 1
var duration_sec: float = 60.0
var scroll_speed_mult: float = 1.0
var spawn_interval: float = 1.2
var spawn_chance: float = 0.7
var obstacle_chance: float = 0.1
var pickup_seed_chance: float = 0.3


static func from_dict(data: Dictionary, script: GDScript):
	var cfg: RefCounted = script.new()
	cfg.id = maxi(1, int(data.get("id", 1)))
	cfg.duration_sec = maxf(30.0, float(data.get("duration_sec", 60.0)))
	cfg.scroll_speed_mult = maxf(0.5, float(data.get("scroll_speed_mult", 1.0)))
	cfg.spawn_interval = maxf(0.5, float(data.get("spawn_interval", 1.2)))
	cfg.spawn_chance = clampf(float(data.get("spawn_chance", 0.7)), 0.0, 1.0)
	cfg.obstacle_chance = clampf(float(data.get("obstacle_chance", 0.1)), 0.0, 1.0)
	cfg.pickup_seed_chance = clampf(float(data.get("pickup_seed_chance", 0.3)), 0.0, 1.0)
	return cfg
