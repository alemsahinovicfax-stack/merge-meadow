extends RefCounted

## Jedan red iz data/run_levels/levels.json (level 1–20) ili Endless stepenica (RunLevelLibrary).
## Polja bez vrijednosti u JSON-u ostaju na starom ponašanju (ramp 5 % / 15 s, bez parova,
## sjeme ravnomjerno).

var id: int = 1
var duration_sec: float = 60.0
var scroll_speed_mult: float = 1.0
## Brzina raste ×(1 + speed_ramp) svakih RunBalance.RAMP_EVERY s unutar runa (Endless: 0 —
## brzina skače po stepenicama).
var speed_ramp: float = 0.05
var spawn_interval: float = 1.2
var spawn_chance: float = 0.7
var obstacle_chance: float = 0.1
## Udio prepreka koje zatvore DVIJE staze odjednom (uvijek ostaje jedna slobodna).
var pair_chance: float = 0.0
var pickup_seed_chance: float = 0.3
## Težina tipa sjemena po rijetkosti: ★1 = 1, ★2 = rare2_mult, ★3 = rare3_mult (RunBalance).
var rare2_mult: float = 1.0
var rare3_mult: float = 1.0
## Prepreke idu svojim tokom (ciklus 1b): redova u s = spawn_chance × obstacle_chance /
## spawn_interval × obstacle_rate_mult. 1 = stari način (prepreka umjesto pickupa na ticku).
var obstacle_rate_mult: float = 1.0


static func from_dict(data: Dictionary, script: GDScript):
	var cfg: RefCounted = script.new()
	cfg.id = maxi(1, int(data.get("id", 1)))
	cfg.duration_sec = maxf(30.0, float(data.get("duration_sec", 60.0)))
	cfg.scroll_speed_mult = maxf(0.5, float(data.get("scroll_speed_mult", 1.0)))
	cfg.speed_ramp = clampf(float(data.get("speed_ramp", 0.05)), 0.0, 0.2)
	cfg.spawn_interval = maxf(0.5, float(data.get("spawn_interval", 1.2)))
	cfg.spawn_chance = clampf(float(data.get("spawn_chance", 0.7)), 0.0, 1.0)
	cfg.obstacle_chance = clampf(float(data.get("obstacle_chance", 0.1)), 0.0, 1.0)
	cfg.pair_chance = clampf(float(data.get("pair_chance", 0.0)), 0.0, 1.0)
	cfg.pickup_seed_chance = clampf(float(data.get("pickup_seed_chance", 0.3)), 0.0, 1.0)
	cfg.rare2_mult = maxf(0.0, float(data.get("rare2_mult", 1.0)))
	cfg.rare3_mult = maxf(0.0, float(data.get("rare3_mult", 1.0)))
	return cfg
