class_name RunTelemetry
extends RefCounted

## Lokalni zapis runova za balans (ciklus 1, 2026-10-21) — samo debug build (editor, debug APK),
## nikad headless testovi ni release. Jedan red po runu u user://balance_log.csv: šta je izašlo
## na stazu, šta je Pip uzeo / promašio, koliko je prepreka prošao, brzina, kraj (finish / hit /
## quit) i plijen. Ništa ne ide sa uređaja.
##
## Služi za kalibraciju modela igrača u scripts/dev/economy_sim.gd (--calibrate): stvarni udio
## skupljenih pickupa i rizik po prepreci umjesto pretpostavki.

const PATH := "user://balance_log.csv"
const FIELDS: Array[String] = [
	"unix", "season", "mode", "level", "tier_max", "target_sec", "elapsed", "end",
	"magnet", "loot", "twin",
	"coins_spawned", "coins_collected", "seeds_spawned", "seeds_collected",
	"pickups_collected", "pickups_missed",
	"obstacles_spawned", "obstacle_rows", "pairs", "obstacles_passed",
	"bushes_spawned", "bushes_collected", "avg_speed", "max_speed",
	"loot_coins", "loot_seeds", "r1", "r2", "r3",
]


static func enabled() -> bool:
	return OS.is_debug_build() and DisplayServer.get_name() != "headless"


## Prazan rječnik kad je zapis isključen (release, testovi) — brojači tada ne rade ništa.
static func new_counters() -> Dictionary:
	if not enabled():
		return {}
	return {"on": true, "dist": 0.0, "time": 0.0, "max_speed": 0.0, "tier_max": 0}


static func count(c: Dictionary, key: String, n: int = 1) -> void:
	if c.has("on"):
		c[key] = int(c.get(key, 0)) + n


static func note_max(c: Dictionary, key: String, value: int) -> void:
	if c.has("on"):
		c[key] = maxi(int(c.get(key, 0)), value)


static func note_speed(c: Dictionary, speed: float, delta: float) -> void:
	if not c.has("on"):
		return
	c["dist"] = float(c.get("dist", 0.0)) + speed * delta
	c["time"] = float(c.get("time", 0.0)) + delta
	c["max_speed"] = maxf(float(c.get("max_speed", 0.0)), speed)


## Čvor je izašao ispod ekrana neuzet (pickup = promašaj) ili pređen (prepreka).
static func note_left_screen(c: Dictionary, node: Node) -> void:
	if not c.has("on"):
		return
	if node.is_in_group("pickup"):
		count(c, "pickups_missed")
	elif node.is_in_group("obstacle"):
		count(c, "obstacles_passed")


static func log_run(c: Dictionary, row: Dictionary) -> void:
	if not c.has("on"):
		return
	var t := float(c.get("time", 0.0))
	var full := row.duplicate()
	for k in c:
		if not full.has(k):
			full[k] = c[k]
	full["unix"] = int(Time.get_unix_time_from_system())
	full["pickups_collected"] = int(c.get("coins_collected", 0)) + int(c.get("seeds_collected", 0))
	full["avg_speed"] = roundi(float(c.get("dist", 0.0)) / t) if t > 0.0 else 0
	full["max_speed"] = roundi(float(c.get("max_speed", 0.0)))
	var f := FileAccess.open(PATH, FileAccess.READ_WRITE)
	if f == null:
		f = FileAccess.open(PATH, FileAccess.WRITE)
		if f == null:
			return
		f.store_csv_line(PackedStringArray(FIELDS))
	f.seek_end()
	var line: PackedStringArray = []
	for k in FIELDS:
		var v: Variant = full.get(k, 0)
		line.append(String.num(v, 1) if v is float else str(v))
	f.store_csv_line(line)
	f.close()
