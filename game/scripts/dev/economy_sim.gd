extends SceneTree

## Ekonomija — balans simulator (ciklus 1, 2026-10-21). Headless, ne dira save.
##
## Čita PRAVE podatke igre (nivoi i Endless iz RunLevelLibrary, sezone, cijene nadogradnji i
## izgleda, nagrade Level Patha, Twin / Loot Boost / magnet, grm, dnevni poklon) i simulira:
##   A. svaki level 1–20 i Endless za tri profila igrača (casual / average / skilled);
##   B. put igrača kroz 4 besplatne sezone, tri politike trošenja (rush = štedi za sljedeću
##      sezonu, boost = kupuje nadogradnje čim može, looks = prvo izgled iz Shopa) → tabela
##      milestonea (runovi, minute, dani);
##   C. isti put (politika boost) za više minuta igre dnevno → kalendarski dani do L20 svake sezone,
##      svih sezona, svih nadogradnji i izgleda; plus zid: leveli gdje casual prolazi < 10 % i koliko
##      casual putovanja stigne do L20 po sezoni (dodano 2026-10-26, RET-01).
## Radi i na starim pravilima (ravnomjeran izbor sjemena, Endless s tajmerom) — tako se dobije
## „prije / poslije" na istom modelu.
##
## Model igrača (skupljanje pickupa, rizik po prepreci) je PRETPOSTAVKA. Kalibrira se iz
## user://balance_log.csv (RunTelemetry, debug build) zastavicom --calibrate.
##
## Pokretanje:
##   godot --headless --path game -s res://scripts/dev/economy_sim.gd -- --out=C:/put/sim.md
##   opcije: --reps=20 (putovanja po profilu) --runs=500 (runova po levelu) --seed=7
##           --parts=a,a2,b,c (koji dijelovi) --day-min=25 (minuta igre dnevno u B)
##           --day-mins=10,15,25,40 (minute dnevno u C)
##           --calibrate [--log=C:/put/balance_log.csv]
##   Brojke B ostaju iste za isti seed samo kad se pokreću i A i A2 (dijele isti RNG redom).

const BASE_SPEED := 400.0
const RAMP_EVERY := 15.0
## y -80 → Pip (0,82 × 1920): koliko px pickup / prepreka putuje do Pipa.
const TRAVEL_PX := 1654.0
const LANE_PITCH := 270.0
const PICKUP_R := 22.0
## Prepreka u dvije staze traži tačniji potez od jedne.
const PAIR_HAZARD := 1.8
## Tok prepreka (ciklus 1b, kao RunController): najmanji razmak redova u px / s, jitter 0,6–1,4.
const MIN_ROW_GAP_PX := 300.0
const MIN_ROW_GAP_SEC := 0.35
## Svaka prepreka u zadnje 2 s povećava rizik sljedeće (gužva na ekranu).
const CLUTTER := 0.35
const CLUTTER_SEC := 2.0
const ENDLESS_CAP_SEC := 1800.0
## Poslije runa ~20 s na Loot / putu; ~0,5 s po sjemenki u Areni.
const RUN_OVERHEAD_SEC := 20.0
const MERGE_SEC_PER_SEED := 0.5
const MAX_RUNS := 2500
## Zid: level gdje casual prolazi rjeđe od ovoga.
const WALL_PASS := 0.10

const PROFILES := {
	"casual": {"collect": 0.55, "hazard": 0.010},
	"average": {"collect": 0.70, "hazard": 0.005},
	"skilled": {"collect": 0.85, "hazard": 0.0025},
}
const POLICIES: Array[String] = ["rush", "boost", "looks"]
const TRACKS: Array[String] = ["loot", "twin", "magnet"]

var _rng := RandomNumberGenerator.new()
var _rll: Node
var _gs_c: Dictionary
var _camp_c: Dictionary
var _run_c: Dictionary
var _lp_c: Dictionary
var _arena_c: Dictionary
var _chain_c: Dictionary
var _rc_c: Dictionary
var _endless_ramp: bool = false
var _endless_full_loot: bool = false
var _seasons: Array = []   # [{id, coins, t3, types[], rar[], star3}]
var _looks: Array = []     # [{id, cost}]
var _backup: String = ""
var _out: PackedStringArray = []
## Minuta igre dnevno (1–2 sesije): --day-min za B; dio C ga mijenja kroz --day-mins.
var _day_min: float = 25.0
## Dio C: kad su sve nadogradnje max, igrač se vraća na nepređene levele nižih sezona.
var _finish_paths: bool = false
var _a_stats: Dictionary = {}   # {profil: {level: {rate, attempts, to_clear}}}
var _b_js: Dictionary = {}      # {"profil·politika": [putovanje]}
var _c_js: Dictionary = {}      # {profil: [[putovanje] po _c_dms]}
var _c_dms: Array[float] = []


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_main")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _arg(name: String, fallback: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a == "--" + name:
			return "1"
		if a.begins_with("--%s=" % name):
			return a.substr(name.length() + 3)
	return fallback


func _main() -> void:
	await process_frame
	_rll = get_root().get_node("RunLevelLibrary")
	_gs_c = (load("res://scripts/autoload/game_state.gd") as Script).get_script_constant_map()
	_camp_c = (load("res://scripts/visual/ui_camp.gd") as Script).get_script_constant_map()
	_run_c = (load("res://scripts/visual/ui_run.gd") as Script).get_script_constant_map()
	_lp_c = (load("res://scripts/economy/level_path.gd") as Script).get_script_constant_map()
	_arena_c = (load("res://scripts/economy/arena.gd") as Script).get_script_constant_map()
	_chain_c = (load("res://scripts/progression/seed_unlock_config.gd") as Script).get_script_constant_map()
	_rc_c = (load("res://scripts/run/run_controller.gd") as Script).get_script_constant_map()
	_endless_ramp = _rll.has_method("get_endless_config_at")
	_endless_full_loot = bool(_gs_c.get("ENDLESS_KEEPS_FULL_LOOT", false))
	_load_seasons()
	_load_looks()
	_rng.seed = int(_arg("seed", "7"))
	_day_min = float(_arg("day-min", "25"))
	if _arg("calibrate", "") == "1":
		_calibrate()
	var runs := int(_arg("runs", "500"))
	var reps := int(_arg("reps", "20"))
	var parts := _arg("parts", "a,a2,b,c").split(",")
	_line("# Ekonomija — simulacija (%s)" % Time.get_date_string_from_system())
	_line("")
	_line("Pravila: Endless %s, plijen u Endlessu %s, sjeme %s. Model: %s." % [
		"rampa po stepenicama" if _endless_ramp else "s tajmerom (stari)",
		"ostaje cijeli" if _endless_full_loot else "pola na padu (stari)",
		"po rijetkosti" if _has_weights() else "ravnomjerno (stari)",
		_profiles_text(),
	])
	_line("")
	if parts.has("a"):
		_part_a(runs)
	if parts.has("a2"):
		_part_a2(runs)
	if parts.has("b"):
		_part_b(reps)
	if parts.has("c"):
		_part_c(reps)
		_wall(runs)
	_prices()
	var path := _arg("out", "")
	if not path.is_empty():
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f != null:
			f.store_string("\n".join(_out) + "\n")
			f.close()
			print("economy_sim: wrote %s" % path)
	print("economy_sim OK")
	_quit(0)


func _line(s: String) -> void:
	_out.append(s)
	print(s)


func _profiles_text() -> String:
	var parts: PackedStringArray = []
	for p in PROFILES:
		parts.append("%s skuplja %d %%, rizik %.2f %% po prepreci" % [
			p, roundi(float(PROFILES[p].collect) * 100.0), float(PROFILES[p].hazard) * 100.0])
	return "; ".join(parts)


# --- podaci igre ---

func _load_seasons() -> void:
	for def in SeasonCatalog.free_defs_sorted():
		var rar: Array[int] = []
		var star3 := ""
		for t in def.seed_type_ids:
			var r := SeedCatalog.rarity(t)
			rar.append(r)
			if r >= 3 and star3.is_empty():
				star3 = t
		_seasons.append({
			"id": def.id, "coins": def.coins_cost, "t3": def.t3_flowers_required,
			"types": def.seed_type_ids.duplicate(), "rar": rar, "star3": star3,
		})


func _load_looks() -> void:
	for id in CosmeticCatalog.all_ids():
		if CosmeticCatalog.is_shop_item(id) and CosmeticCatalog.get_coin_cost(id) > 0:
			_looks.append({"id": id, "cost": CosmeticCatalog.get_coin_cost(id)})
	_looks.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.cost) < int(b.cost))


func _has_weights() -> bool:
	var cfg: Object = _rll.call("get_level", 1)
	return cfg.get("rare3_mult") != null


func _cf(cfg: Object, key: String, fallback: float) -> float:
	var v: Variant = cfg.get(key)
	return fallback if v == null else float(v)


func _up_coin(level: int) -> int:
	var arr: Array = _camp_c.get("UP_COIN_COST", [10, 20, 40, 60])
	return int(arr[clampi(level, 0, arr.size() - 1)])


func _up_flower(level: int) -> int:
	if _camp_c.has("UP_FLOWER_COSTS"):
		var arr: Array = _camp_c["UP_FLOWER_COSTS"]
		return int(arr[clampi(level, 0, arr.size() - 1)])
	return int(_camp_c.get("UP_FLOWER_COST", 2))


func _up_levels() -> int:
	return int(_camp_c.get("UP_LEVELS", 4))


func _loot_mult(level: int) -> float:
	var arr: Array = _gs_c.get("MULTIPLIER_VALUES", [1.0])
	return float(arr[clampi(level, 0, arr.size() - 1)])


func _magnet_r(level: int) -> float:
	return float(_gs_c.get("MAGNET_BASE_RADIUS", 40.0)) + float(_gs_c.get("MAGNET_RADIUS_PER_LEVEL", 48.0)) * level


func _endless_unlock_level() -> int:
	return int(_lp_c.get("ENDLESS_UNLOCK_LEVEL", 0))


# --- jedan run ---

func _cfg_level(n: int) -> Object:
	return _rll.call("get_level", n)


func _cfg_endless(t: float) -> Object:
	if _endless_ramp:
		return _rll.call("get_endless_config_at", t)
	return _rll.call("get_endless_config_for_difficulty", 2)


func _speed(cfg: Object, t: float) -> float:
	var ramp := _cf(cfg, "speed_ramp", float(_rc_c.get("RAMP_STEP", 0.05)))
	return BASE_SPEED * float(cfg.scroll_speed_mult) * pow(1.0 + ramp, floorf(t / RAMP_EVERY))


func _collect_p(prof: Dictionary, v: float, obstacle_chance: float, magnet: int) -> float:
	var p: float = float(prof.collect) * pow(BASE_SPEED / v, 0.35) * (1.0 - 0.5 * obstacle_chance)
	if _magnet_r(magnet) + PICKUP_R >= LANE_PITCH:
		p += (1.0 - p) * 0.65
	else:
		p += (1.0 - p) * 0.03 * magnet
	return clampf(p, 0.0, 0.98)


func _pick(pool: Array, rar: Array, cfg: Object) -> String:
	var r2 := _cf(cfg, "rare2_mult", 1.0)
	var r3 := _cf(cfg, "rare3_mult", 1.0)
	var total := 0.0
	for r in rar:
		total += 1.0 if int(r) <= 1 else (r2 if int(r) == 2 else r3)
	var roll := _rng.randf() * total
	for i in pool.size():
		var r := int(rar[i])
		roll -= 1.0 if r <= 1 else (r2 if r == 2 else r3)
		if roll < 0.0:
			return str(pool[i])
	return str(pool[pool.size() - 1])


## Vraća {elapsed, failed, coins, seeds {type: n}, obstacles}. Plijen je SIROV (bez Loot Boosta).
func _sim_run(prof: Dictionary, level: int, endless: bool, up: Dictionary, pool: Array, rar: Array) -> Dictionary:
	var cfg: Object = _cfg_endless(0.0) if endless else _cfg_level(level)
	var duration := ENDLESS_CAP_SEC if endless and _endless_ramp else float(cfg.duration_sec)
	var tier_sec := 0.0
	if endless and _endless_ramp:
		tier_sec = float((_rll.get_script() as Script).get_script_constant_map().get("ENDLESS_TIER_SEC", 20.0))
	var tier := 0
	var t := 0.0
	var next_bush := float(_run_c.get("BUSH_FIRST_AFTER", 6.0))
	var recent: Array[float] = []
	var coins := 0
	var seeds := {}
	var obstacles := 0
	var failed := false
	var end_t := duration
	var twin_p := float(_camp_c.get("TWIN_STEP", 0.08)) * int(up.get("twin", 0))
	var magnet := int(up.get("magnet", 0))
	var stream := _cf(cfg, "obstacle_rate_mult", 1.0) > 1.0
	var next_obs := _row_gap(cfg, _speed(cfg, 0.0)) if stream else INF
	while true:
		if tier_sec > 0.0 and int(t / tier_sec) != tier:
			tier = int(t / tier_sec)
			cfg = _cfg_endless(t)
		t += float(cfg.spawn_interval)
		var v := _speed(cfg, t)
		var arrive := t + TRAVEL_PX / v
		if arrive >= duration:
			break
		# Tok prepreka: redovi između ovog i prošlog ticka.
		while stream and next_obs <= t:
			var ov := _speed(cfg, next_obs)
			var o_arrive := next_obs + TRAVEL_PX / ov
			next_obs += _row_gap(cfg, ov)
			if o_arrive >= duration:
				continue
			var opair := _rng.randf() < _cf(cfg, "pair_chance", 0.0)
			while not recent.is_empty() and recent[0] < o_arrive - CLUTTER_SEC:
				recent.pop_front()
			var oh: float = float(prof.hazard) * pow(ov / BASE_SPEED, 2.0) * (PAIR_HAZARD if opair else 1.0) \
				* (1.0 + CLUTTER * recent.size())
			recent.append(o_arrive)
			obstacles += 2 if opair else 1
			if _rng.randf() < oh:
				failed = true
				end_t = o_arrive
				break
		if failed:
			break
		while next_bush <= t:
			var b_arrive := next_bush + TRAVEL_PX / v
			next_bush += _rng.randf_range(float(_run_c.get("BUSH_GAP_MIN", 8.0)), float(_run_c.get("BUSH_GAP_MAX", 12.0)))
			if b_arrive >= duration or _rng.randf() >= float(prof.collect) * 0.85:
				continue
			var reward: Dictionary = UiRun.roll_bush_reward(_rng.randf(), _rng.randf())
			if str(reward.kind) == "coin":
				coins += int(reward.amount)
			else:
				var bt := _pick(pool, rar, cfg)
				seeds[bt] = int(seeds.get(bt, 0)) + int(reward.amount)
		if _rng.randf() > float(cfg.spawn_chance):
			continue
		if stream:
			if _rng.randf() < float(cfg.obstacle_chance):
				continue
		elif _rng.randf() < float(cfg.obstacle_chance):
			var pair := _rng.randf() < _cf(cfg, "pair_chance", 0.0)
			while not recent.is_empty() and recent[0] < arrive - CLUTTER_SEC:
				recent.pop_front()
			var h: float = float(prof.hazard) * pow(v / BASE_SPEED, 2.0) * (PAIR_HAZARD if pair else 1.0) \
				* (1.0 + CLUTTER * recent.size())
			recent.append(arrive)
			obstacles += 2 if pair else 1
			if _rng.randf() < h:
				failed = true
				end_t = arrive
				break
			continue
		var p := _collect_p(prof, v, float(cfg.obstacle_chance), magnet)
		if _rng.randf() < float(cfg.pickup_seed_chance):
			if _rng.randf() < p:
				var st := _pick(pool, rar, cfg)
				seeds[st] = int(seeds.get(st, 0)) + (2 if _rng.randf() < twin_p else 1)
		elif _rng.randf() < p:
			coins += 1
	return {"elapsed": end_t, "failed": failed, "coins": coins, "seeds": seeds, "obstacles": obstacles}


func _row_gap(cfg: Object, v: float) -> float:
	var rate := float(cfg.spawn_chance) * float(cfg.obstacle_chance) / maxf(float(cfg.spawn_interval), 0.1) \
		* _cf(cfg, "obstacle_rate_mult", 1.0)
	var base := 1.0 / maxf(rate, 0.01)
	return maxf(base * _rng.randf_range(0.6, 1.4), maxf(MIN_ROW_GAP_SEC, MIN_ROW_GAP_PX / maxf(v, 1.0)))


## Plijen poslije Loot Boosta i pada (isto kao GameState.finish_run).
func _final_loot(res: Dictionary, endless: bool, loot_lvl: int) -> Dictionary:
	var m := _loot_mult(loot_lvl)
	var coins: int = maxi(int(res.coins), roundi(float(res.coins) * m))
	var seeds := {}
	var half: bool = bool(res.failed) and not (endless and _endless_full_loot)
	for k in res.seeds:
		var n: int = maxi(int(res.seeds[k]), roundi(float(res.seeds[k]) * m))
		seeds[k] = ceili(n * 0.5) if half else n
	if half:
		coins = ceili(coins * 0.5)
	return {"coins": coins, "seeds": seeds}


# --- A: leveli ---

func _part_a(runs: int) -> void:
	var s1: Dictionary = _seasons[1] if _seasons.size() > 1 else _seasons[0]
	_line("## A. Leveli 1–20 i Endless (sezona sa svih 6 tipova, bez nadogradnji)")
	_line("")
	for pname in PROFILES:
		var prof: Dictionary = PROFILES[pname]
		_line("### Profil: %s" % pname)
		_line("")
		_line("| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |")
		_line("|---|---|---|---|---|---|---|---|---|---|---|---|")
		_a_stats[pname] = {}
		for n in range(1, 21):
			var stats := {}
			_line(_level_row(str(n), prof, n, false, runs, s1, stats))
			_a_stats[pname][n] = stats
		_line(_level_row("Endless", prof, 0, true, runs, s1, {}))
		_line("")


## `stats` dobije {rate, attempts, to_clear} za zid.
func _level_row(label: String, prof: Dictionary, n: int, endless: bool, runs: int, season: Dictionary,
		stats: Dictionary) -> String:
	var fin := 0
	var t_sum := 0.0
	var c_fin := 0.0
	var s_fin := 0.0
	var c_all := 0.0
	var s_all := 0.0
	var r2 := 0.0
	var r3 := 0.0
	var obs := 0.0
	var times: Array[float] = []
	for i in runs:
		var res := _sim_run(prof, n, endless, {}, season.types, season.rar)
		var loot := _final_loot(res, endless, 0)
		var sc := 0
		for k in loot.seeds:
			var c := int(loot.seeds[k])
			sc += c
			var r := SeedCatalog.rarity(str(k))
			if r == 2:
				r2 += c
			elif r >= 3:
				r3 += c
		t_sum += float(res.elapsed)
		times.append(float(res.elapsed))
		c_all += int(loot.coins)
		s_all += sc
		obs += int(res.obstacles)
		if not bool(res.failed):
			fin += 1
			c_fin += int(loot.coins)
			s_fin += sc
	var mins := t_sum / 60.0
	var rate := float(fin) / runs
	var dur := "%d" % roundi(float(_cfg_level(n).duration_sec)) if not endless else "—"
	if endless:
		times.sort()
		dur = "med %d · p90 %d" % [roundi(times[times.size() / 2]), roundi(times[int(times.size() * 0.9)])]
	var per_fin_c := (c_fin / fin) if fin > 0 else 0.0
	var per_fin_s := (s_fin / fin) if fin > 0 else 0.0
	if endless:
		per_fin_c = c_all / runs
		per_fin_s = s_all / runs
	var attempts := (1.0 / rate) if rate > 0.0 else INF
	var to_clear := (t_sum / runs + RUN_OVERHEAD_SEC) * attempts / 60.0
	stats["rate"] = rate
	stats["attempts"] = attempts
	stats["to_clear"] = to_clear
	return "| %s | %s | %s | %.0f | %.1f | %.0f | %.1f | %.1f | %.1f | %.1f | %s | %s |" % [
		label, dur, "—" if endless else "%d" % roundi(rate * 100.0), per_fin_c, per_fin_s,
		100.0 * r2 / maxf(1.0, s_all), 100.0 * r3 / maxf(1.0, s_all),
		c_all / mins, s_all / mins, obs / mins,
		"—" if endless else "%.2f" % attempts, "—" if endless else "%.1f" % to_clear,
	]


## A2: šta svaka nadogradnja (max nivo) donosi na levelu 20 i u Endlessu — profil average.
func _part_a2(runs: int) -> void:
	var s: Dictionary = _seasons[1] if _seasons.size() > 1 else _seasons[0]
	var prof: Dictionary = PROFILES.average
	var max_lv := _up_levels()
	var sets := [
		["bez nadogradnji", {}],
		["Magnet max", {"magnet": max_lv}],
		["Twin Seeds max", {"twin": max_lv}],
		["Loot Boost max", {"loot": max_lv}],
		["sve tri max", {"magnet": max_lv, "twin": max_lv, "loot": max_lv}],
	]
	_line("## A2. Vrijednost nadogradnji (average, level 20 i Endless)")
	_line("")
	_line("| Nadogradnje | L20 coina / min | L20 sjem. / min | Endless coina / min | Endless sjem. / min |")
	_line("|---|---|---|---|---|")
	for row in sets:
		var cells: PackedStringArray = [str(row[0])]
		for endless in [false, true]:
			var coins := 0.0
			var seeds := 0.0
			var sec := 0.0
			for i in runs:
				var res := _sim_run(prof, 20, endless, row[1], s.types, s.rar)
				var loot := _final_loot(res, endless, int((row[1] as Dictionary).get("loot", 0)))
				coins += int(loot.coins)
				for k in loot.seeds:
					seeds += int(loot.seeds[k])
				sec += float(res.elapsed)
			cells.append("%.1f" % (coins / sec * 60.0))
			cells.append("%.1f" % (seeds / sec * 60.0))
		_line("| " + " | ".join(cells) + " |")
	_line("")


# --- B: put igrača ---

func _part_b(reps: int) -> void:
	_line("## B. Put igrača kroz 4 besplatne sezone (medijan · p10–p90, %d putovanja)" % reps)
	_line("")
	_line("Dan = %d min igre. rush štedi za sljedeću sezonu; boost kupuje nadogradnje čim može; looks prvo kupuje izgled iz Shopa (pa sezonu, pa nadogradnje)." % roundi(_day_min))
	_line("")
	for pname in PROFILES:
		for policy in POLICIES:
			var all: Array = []
			var flows: Array = []
			var js: Array = []
			for r in reps:
				var j := _journey(PROFILES[pname], policy)
				all.append(j.ms)
				flows.append(j.flow)
				js.append(j)
			_b_js["%s·%s" % [pname, policy]] = js
			_line("### %s · %s" % [pname, policy])
			_line("")
			_line("| Milestone | Dan | Min igre | Runova | Dostiglo |")
			_line("|---|---|---|---|---|")
			for key in _milestone_order():
				var mins: Array[float] = []
				var runs_a: Array[float] = []
				for ms in all:
					if (ms as Dictionary).has(key):
						mins.append(float(ms[key].min))
						runs_a.append(float(ms[key].runs))
				if mins.is_empty():
					_line("| %s | — | — | — | 0 / %d |" % [key, reps])
					continue
				mins.sort()
				runs_a.sort()
				var med := mins[mins.size() / 2]
				_line("| %s | %.1f | %d (%d–%d) | %d | %d / %d |" % [
					key, med / _day_min, roundi(med), roundi(mins[int(mins.size() * 0.1)]),
					roundi(mins[mini(mins.size() - 1, int(mins.size() * 0.9))]),
					roundi(runs_a[runs_a.size() / 2]), mins.size(), reps,
				])
			_line("")
			_line(_flow_text(flows))
			_line("")


func _milestone_order() -> Array[String]:
	var out: Array[String] = []
	for i in _seasons.size():
		var sid := str(_seasons[i].id)
		if i > 0:
			out.append("%s otključan" % sid)
		if i == 0:
			out.append("%s ★3 sjeme u igri" % sid)
		for lv in [5, 10, 15, 20]:
			out.append("%s level %d pređen" % [sid, lv])
		out.append("%s Endless otključan" % sid)
		out.append("%s prva nadogradnja" % sid)
		out.append("%s nadogradnje max" % sid)
	for l in _looks:
		out.append("izgled %s (%d)" % [l.id, l.cost])
	out.append("sve besplatne sezone pređene")
	out.append("sve besplatne nadogradnje max")
	out.append("svi izgledi za coine")
	return out


func _flow_text(flows: Array) -> String:
	var sums := {}
	for f in flows:
		for k in f:
			sums[k] = float(sums.get(k, 0.0)) + float(f[k])
	var n := float(maxi(1, flows.size()))
	var keys := sums.keys()
	keys.sort()
	var parts: PackedStringArray = []
	for k in keys:
		parts.append("%s %d" % [k, roundi(float(sums[k]) / n)])
	return "Tok (prosjek po putovanju, do kraja): " + " · ".join(parts)


func _journey(prof: Dictionary, policy: String) -> Dictionary:
	var st := {
		"wallet": 0, "bag": {}, "stash": {}, "levels": {}, "claimed": {}, "up": {},
		"unlocked": 1, "looks": {}, "life": {}, "chain": 0, "sec": 0.0, "runs": 0,
		"day": 0, "ms": {}, "flow": {},
	}
	for s in _seasons:
		st.levels[s.id] = 1
		st.claimed[s.id] = []
		st.up[s.id] = {"loot": 0, "twin": 0, "magnet": 0}
	while int(st.runs) < MAX_RUNS:
		var si := _pick_play_season(st)
		var s: Dictionary = _seasons[si]
		var lv := int(st.levels[s.id])
		# Put završen → grind u Endlessu (otključan je na putu, prije 20).
		var endless := lv > 20
		var pool := _pool(st, si)
		var res := _sim_run(prof, mini(lv, 20), endless, st.up[s.id], pool[0], pool[1])
		var loot := _final_loot(res, endless, int(st.up[s.id].loot))
		st.runs = int(st.runs) + 1
		st.sec = float(st.sec) + float(res.elapsed) + RUN_OVERHEAD_SEC
		_earn(st, "coin: run", int(loot.coins))
		var seeds_n := 0
		for k in loot.seeds:
			st.bag[k] = int(st.bag.get(k, 0)) + int(loot.seeds[k])
			seeds_n += int(loot.seeds[k])
			_flow(st, "sjeme ★%d" % SeedCatalog.rarity(str(k)), int(loot.seeds[k]))
		for k in res.seeds:
			if si == 0:
				st.life[k] = int(st.life.get(k, 0)) + int(res.seeds[k])
		_advance_chain(st)
		if not bool(res.failed) and not endless and lv <= 20:
			st.levels[s.id] = lv + 1
			if lv in [5, 10, 15, 20]:
				_mark(st, "%s level %d pređen" % [s.id, lv])
			if lv == 20 and _all_paths_done(st):
				_mark(st, "sve besplatne sezone pređene")
			if lv == _endless_unlock_level() or (_endless_unlock_level() == 0 and lv == 1):
				_mark(st, "%s Endless otključan" % s.id)
		_daily(st)
		_merge_and_sell(st, seeds_n)
		_claim(st)
		_shop(st, policy)
		if _done(st):
			break
	return {"ms": st.ms, "flow": st.flow, "levels": st.levels, "min": float(st.sec) / 60.0, "done": _done(st)}


## Najviša otključana sezona dok put ili sljedeća sezona čekaju; poslije toga sezona s najviše
## preostalih nadogradnji (treba njen ★3), pa najviša (coini). Uz _finish_paths, kad su sve
## nadogradnje max, prvo najniža sezona s nepređenim putem.
func _pick_play_season(st: Dictionary) -> int:
	var top := int(st.unlocked) - 1
	if int(st.levels[_seasons[top].id]) <= 20 or int(st.unlocked) < _seasons.size():
		return top
	var best := top
	var best_left := 0
	for i in int(st.unlocked):
		var left := 0
		for tr in TRACKS:
			left += _up_levels() - int(st.up[_seasons[i].id][tr])
		if left > best_left:
			best_left = left
			best = i
	if best_left == 0 and _finish_paths:
		for i in int(st.unlocked):
			if int(st.levels[_seasons[i].id]) <= 20:
				return i
	return best


func _pool(st: Dictionary, si: int) -> Array:
	var s: Dictionary = _seasons[si]
	if si != 0:
		return [s.types, s.rar]
	var chain: Array = _chain_c.get("CHAIN", [])
	var types: Array = []
	var rar: Array = []
	for i in mini(int(st.chain) + 1, chain.size()):
		types.append(chain[i])
		rar.append(SeedCatalog.rarity(str(chain[i])))
	return [types, rar]


func _advance_chain(st: Dictionary) -> void:
	var chain: Array = _chain_c.get("CHAIN", [])
	var need: Array = _chain_c.get("LIFETIME_TO_UNLOCK_NEXT", [])
	while int(st.chain) < chain.size() - 1:
		var cur := str(chain[int(st.chain)])
		if int(st.life.get(cur, 0)) < int(need[int(st.chain)]):
			break
		st.chain = int(st.chain) + 1
		if int(st.chain) == chain.size() - 1:
			_mark(st, "%s ★3 sjeme u igri" % _seasons[0].id)


func _daily(st: Dictionary) -> void:
	var day := int(float(st.sec) / 60.0 / _day_min)
	while int(st.day) < day:
		st.day = int(st.day) + 1
		_earn(st, "coin: dnevni poklon", int(_gs_c.get("DAILY_CHEST_COINS", 8)))
		_earn(st, "coin: arena combo", roundi(float(_arena_c.get("COMBO_COIN_DAILY_CAP", 10)) * 0.5))
		var chain: Array = _chain_c.get("CHAIN", [])
		var t := str(chain[_rng.randi() % (int(st.chain) + 1)])
		st.bag[t] = int(st.bag.get(t, 0)) + int(_gs_c.get("DAILY_CHEST_SEEDS", 3))


func _merge_and_sell(st: Dictionary, seeds_n: int) -> void:
	st.sec = float(st.sec) + MERGE_SEC_PER_SEED * seeds_n
	var star3s := {}
	for s in _seasons:
		star3s[s.star3] = s
	for k in st.bag.keys():
		var groups := int(st.bag[k]) / 4
		if groups <= 0:
			continue
		st.bag[k] = int(st.bag[k]) - groups * 4
		st.stash[k] = int(st.stash.get(k, 0)) + groups
		if star3s.has(k):
			_flow(st, "★3 cvijet: merge", groups)
	var ex: Dictionary = _gs_c.get("CRYSTAL_EXCHANGE_COINS_BY_RARITY", {1: 5, 2: 10, 3: 20})
	for k in st.stash.keys():
		var have := int(st.stash[k])
		if have <= 1:
			continue
		var r := SeedCatalog.rarity(str(k))
		if star3s.has(k) and not _star3_surplus(st, star3s[k]):
			continue
		st.stash[k] = 1
		_earn(st, "coin: prodaja cvijeća", (have - 1) * int(ex.get(r, 5)))


## ★3 cvijeće sezone je višak kad su njene nadogradnje max i sljedeća sezona otključana.
func _star3_surplus(st: Dictionary, s: Dictionary) -> bool:
	var i := _seasons.find(s)
	if i + 1 >= int(st.unlocked) and i + 1 < _seasons.size():
		return false
	for tr in TRACKS:
		if int(st.up[s.id][tr]) < _up_levels():
			return false
	return true


func _claim(st: Dictionary) -> void:
	var rewards: Dictionary = _lp_c.get("REWARDS", {})
	for i in int(st.unlocked):
		var s: Dictionary = _seasons[i]
		for n in rewards:
			if int(st.levels[s.id]) > int(n) and not (st.claimed[s.id] as Array).has(int(n)):
				(st.claimed[s.id] as Array).append(int(n))
				var r: Array = rewards[n]
				st.stash[s.star3] = int(st.stash.get(s.star3, 0)) + int(r[0])
				_flow(st, "★3 cvijet: Level Path", int(r[0]))
				_earn(st, "coin: Level Path", int(r[1]))


func _shop(st: Dictionary, policy: String) -> void:
	var bought := true
	while bought:
		bought = false
		if policy == "looks" and _buy_look(st, 0):
			bought = true
			continue
		var nxt := int(st.unlocked)
		var res_c := 0
		var res_f := 0
		var top: Dictionary = _seasons[nxt - 1]
		if nxt < _seasons.size():
			var ns: Dictionary = _seasons[nxt]
			if int(st.wallet) >= int(ns.coins) and int(st.stash.get(top.star3, 0)) >= int(ns.t3):
				st.wallet = int(st.wallet) - int(ns.coins)
				st.stash[top.star3] = int(st.stash.get(top.star3, 0)) - int(ns.t3)
				_flow(st, "trošak: sezone", int(ns.coins))
				st.unlocked = nxt + 1
				_mark(st, "%s otključan" % ns.id)
				bought = true
				continue
			res_c = int(ns.coins)
			res_f = int(ns.t3)
		for i in range(int(st.unlocked) - 1, -1, -1):
			var s: Dictionary = _seasons[i]
			var tr := _cheapest_track(st, s.id)
			if tr.is_empty():
				continue
			var lvl := int(st.up[s.id][tr])
			var cc := _up_coin(lvl)
			var cf := _up_flower(lvl)
			var keep_c := res_c if policy == "rush" else 0
			var keep_f := res_f if policy == "rush" and i == nxt - 1 else 0
			if int(st.wallet) - cc >= keep_c and int(st.stash.get(s.star3, 0)) - cf >= keep_f:
				st.wallet = int(st.wallet) - cc
				st.stash[s.star3] = int(st.stash.get(s.star3, 0)) - cf
				st.up[s.id][tr] = lvl + 1
				_flow(st, "trošak: nadogradnje", cc)
				_flow(st, "★3 cvijet: u nadogradnje", cf)
				_mark(st, "%s prva nadogradnja" % s.id)
				if _cheapest_track(st, s.id).is_empty():
					_mark(st, "%s nadogradnje max" % s.id)
					if _all_upgrades_max(st):
						_mark(st, "sve besplatne nadogradnje max")
				bought = true
				break
		if bought:
			continue
		bought = _buy_look(st, res_c)


## Najjeftiniji izgled koji još nema, ako poslije kupovine ostane `keep` coina.
func _buy_look(st: Dictionary, keep: int) -> bool:
	for l in _looks:
		if st.looks.has(l.id):
			continue
		if int(st.wallet) - int(l.cost) < keep:
			return false
		st.wallet = int(st.wallet) - int(l.cost)
		st.looks[l.id] = true
		_flow(st, "trošak: izgledi", int(l.cost))
		_mark(st, "izgled %s (%d)" % [l.id, l.cost])
		if st.looks.size() == _looks.size():
			_mark(st, "svi izgledi za coine")
		return true
	return false


func _cheapest_track(st: Dictionary, sid: String) -> String:
	var best := ""
	var best_lvl := 999
	for tr in TRACKS:
		var lvl := int(st.up[sid][tr])
		if lvl < _up_levels() and lvl < best_lvl:
			best_lvl = lvl
			best = tr
	return best


func _all_upgrades_max(st: Dictionary) -> bool:
	for s in _seasons:
		if not _cheapest_track(st, s.id).is_empty():
			return false
	return true


func _all_paths_done(st: Dictionary) -> bool:
	for s in _seasons:
		if int(st.levels[s.id]) <= 20:
			return false
	return true


func _done(st: Dictionary) -> bool:
	return _all_paths_done(st) and _all_upgrades_max(st) and st.looks.size() == _looks.size()


func _mark(st: Dictionary, key: String) -> void:
	if not st.ms.has(key):
		st.ms[key] = {"runs": int(st.runs), "min": float(st.sec) / 60.0}


func _earn(st: Dictionary, source: String, n: int) -> void:
	st.wallet = int(st.wallet) + n
	_flow(st, source, n)


func _flow(st: Dictionary, key: String, n: int) -> void:
	st.flow[key] = int(st.flow.get(key, 0)) + n


# --- C: kalendarski dani po minutama igre dnevno ---

func _part_c(reps: int) -> void:
	_c_dms.clear()
	for s in _arg("day-mins", "10,15,25,40").split(","):
		_c_dms.append(float(s))
	var b_day_min := _day_min
	_finish_paths = true
	for pname in PROFILES:
		var cols: Array = []
		for dm in _c_dms:
			_day_min = dm
			var js: Array = []
			for r in reps:
				js.append(_journey(PROFILES[pname], "boost"))
			cols.append(js)
		_c_js[pname] = cols
	_finish_paths = false
	_day_min = b_day_min
	var head := ""
	var sep := ""
	for dm in _c_dms:
		head += " %s min/dan |" % _num(dm)
		sep += "---|"
	_line("## C. Koliko kalendarskih dana traje besplatni sadržaj (boost, medijan, %d putovanja)" % reps)
	_line("")
	_line("Put kao u B (politika boost) za svaku vrijednost minuta igre dnevno; svaka ima svoja putovanja jer dnevni poklon i arena combo idu po danu. Razlika od B: kad su sve nadogradnje max, igrač se vraća na nepređene levele nižih sezona (u B igra Endless najviše sezone). Granica: %d runova po putovanju; medijan je preko svih putovanja (nedostignuto = beskonačno), „— (x / %d)\" = medijan nije dostignut, x putovanja je stiglo." % [MAX_RUNS, reps])
	_line("")
	_line("### Sažetak (dani)")
	_line("")
	_line("| Profil | Mjera |" + head)
	_line("|---|---|" + sep)
	for pname in PROFILES:
		for key in ["sve besplatne sezone pređene", "kraj besplatnog sadržaja"]:
			var cells: PackedStringArray = []
			for k in _c_dms.size():
				cells.append(_c_cell(_c_mins(_c_js[pname][k], key), _c_dms[k], false))
			_line("| %s | %s | %s |" % [pname, key, " | ".join(cells)])
	_line("")
	for pname in PROFILES:
		_line("### %s · boost (dan · min igre)" % pname)
		_line("")
		_line("| Milestone |" + head)
		_line("|---|" + sep)
		for key in _c_keys():
			var cells: PackedStringArray = []
			for k in _c_dms.size():
				cells.append(_c_cell(_c_mins(_c_js[pname][k], key), _c_dms[k], true))
			_line("| %s | %s |" % [key, " | ".join(cells)])
		var capped: PackedStringArray = []
		for k in _c_dms.size():
			capped.append(_cap_cell(_c_js[pname][k], _c_dms[k]))
		_line("| u granici (%d runova) | %s |" % [MAX_RUNS, " | ".join(capped)])
		_line("")


func _c_keys() -> Array[String]:
	var out: Array[String] = []
	for i in _seasons.size():
		if i > 0:
			out.append("%s otključan" % _seasons[i].id)
		out.append("%s level 20 pređen" % _seasons[i].id)
	out.append("sve besplatne sezone pređene")
	out.append("sve besplatne nadogradnje max")
	out.append("svi izgledi za coine")
	out.append("kraj besplatnog sadržaja")
	return out


## Minute igre do milestonea po putovanju; INF kad ga putovanje nije dostiglo.
func _c_mins(js: Array, key: String) -> Array[float]:
	var out: Array[float] = []
	for j in js:
		if key == "kraj besplatnog sadržaja":
			out.append(float(j.min) if bool(j.done) else INF)
		elif (j.ms as Dictionary).has(key):
			out.append(float(j.ms[key].min))
		else:
			out.append(INF)
	return out


func _c_cell(mins: Array[float], dm: float, with_min: bool) -> String:
	var got := 0
	for m in mins:
		if not is_inf(m):
			got += 1
	mins.sort()
	var med := mins[mins.size() / 2]
	var tail := "" if got == mins.size() else " (%d / %d)" % [got, mins.size()]
	if is_inf(med):
		return "—" + tail
	if with_min:
		return "%.1f · %d%s" % [med / dm, roundi(med), tail]
	return "%.1f%s" % [med / dm, tail]


## Koliko putovanja udari u MAX_RUNS i kad (medijan min igre ≈ dana).
func _cap_cell(js: Array, dm: float) -> String:
	var mins: Array[float] = []
	for j in js:
		if not bool(j.done):
			mins.append(float(j.min))
	if mins.is_empty():
		return "0 / %d" % js.size()
	mins.sort()
	var med := mins[mins.size() / 2]
	return "%d / %d · %d min ≈ %.0f d" % [mins.size(), js.size(), roundi(med), med / dm]


# --- zid 16–20 (casual) ---

func _wall(runs: int) -> void:
	var src := "dio A"
	if _a_stats.is_empty():
		src = "poseban prolaz, %d runova po levelu" % runs
		var s1: Dictionary = _seasons[1] if _seasons.size() > 1 else _seasons[0]
		for pname in PROFILES:
			_a_stats[pname] = {}
			for n in range(1, 21):
				var stats := {}
				_level_row(str(n), PROFILES[pname], n, false, runs, s1, stats)
				_a_stats[pname][n] = stats
	_line("## C2. Zid za casual igrača")
	_line("")
	_line("Leveli gdje casual prolazi < %d %% (%s: sezona sa svih 6 tipova, bez nadogradnji; nadogradnje u modelu ne smanjuju rizik prepreka, pa ovo važi za svaku sezonu)." % [roundi(WALL_PASS * 100.0), src])
	_line("")
	_line("| Level | casual prolaz % | casual pokušaja | casual min do prolaza | average prolaz % | skilled prolaz % |")
	_line("|---|---|---|---|---|---|")
	var sum_att := 0.0
	var sum_min := 0.0
	for n in range(1, 21):
		var c: Dictionary = _a_stats.casual[n]
		if float(c.rate) >= WALL_PASS:
			continue
		sum_att += float(c.attempts)
		sum_min += float(c.to_clear)
		_line("| %d | %.1f | %s | %s | %.0f | %.0f |" % [
			n, float(c.rate) * 100.0, _fin("%.0f", float(c.attempts)), _fin("%.0f", float(c.to_clear)),
			float(_a_stats.average[n].rate) * 100.0, float(_a_stats.skilled[n].rate) * 100.0,
		])
	_line("| ukupno | — | %s | %s | — | — |" % [_fin("%.0f", sum_att), _fin("%.0f", sum_min)])
	_line("")
	var per_dm: PackedStringArray = []
	for dm in _c_dms:
		per_dm.append("%s min/dan → %s d po sezoni, %s d za %d sezone" % [
			_num(dm), _fin("%.0f", sum_min / dm), _fin("%.0f", sum_min * _seasons.size() / dm), _seasons.size()])
	_line("Samo zid (očekivane minute pokušaja, bez ostatka puta): " + "; ".join(per_dm) + ".")
	_line("")
	var cols: Array = []
	for policy in POLICIES:
		var key := "casual·%s" % policy
		if _b_js.has(key):
			cols.append(["B %s · %s min" % [policy, _num(_day_min)], _b_js[key]])
	if _c_js.has("casual"):
		for k in _c_dms.size():
			cols.append(["C boost · %s min" % _num(_c_dms[k]), _c_js.casual[k]])
	if cols.is_empty():
		return
	_line("Casual putovanja koja pređu L20 (x / putovanja; „ostali\" = raspon levela na kojem su ostala kad je putovanje stalo):")
	_line("")
	var head := "| Sezona |"
	var sep := "|---|"
	for c in cols:
		head += " %s |" % c[0]
		sep += "---|"
	_line(head)
	_line(sep)
	for s in _seasons:
		var cells: PackedStringArray = []
		for c in cols:
			cells.append(_reach_cell(c[1], s.id))
		_line("| %s | %s |" % [s.id, " | ".join(cells)])
	var all_cells: PackedStringArray = []
	for c in cols:
		var got := 0
		for j in c[1]:
			if (j.ms as Dictionary).has("sve besplatne sezone pređene"):
				got += 1
		all_cells.append("%d / %d" % [got, (c[1] as Array).size()])
	_line("| sve 4 sezone | %s |" % " | ".join(all_cells))
	_line("")


func _reach_cell(js: Array, sid: String) -> String:
	var got := 0
	var lo := 99
	var hi := 0
	for j in js:
		var lv := int(j.levels[sid])
		if lv > 20:
			got += 1
		else:
			lo = mini(lo, lv)
			hi = maxi(hi, lv)
	if got == js.size():
		return "%d / %d" % [got, js.size()]
	var left := "L%d" % lo if lo == hi else "L%d–%d" % [lo, hi]
	return "%d / %d (ostali %s)" % [got, js.size(), left]


func _fin(fmt: String, v: float) -> String:
	return "∞" if is_inf(v) else fmt % v


func _num(v: float) -> String:
	return "%d" % roundi(v) if is_equal_approx(v, roundf(v)) else "%.1f" % v


# --- cijene (pregled) ---

func _prices() -> void:
	_line("## Cijene u igri (iz podataka)")
	_line("")
	var parts: PackedStringArray = []
	for s in _seasons:
		if int(s.coins) > 0:
			parts.append("%s %d C + %d ★3" % [s.id, s.coins, s.t3])
	_line("- Sezone: " + ", ".join(parts))
	var up: PackedStringArray = []
	for lv in _up_levels():
		up.append("%d C + %d ★3" % [_up_coin(lv), _up_flower(lv)])
	_line("- Nadogradnja po nivou (svaka od 3 staze, po sezoni): " + " → ".join(up))
	var lk: PackedStringArray = []
	for l in _looks:
		lk.append("%s %d" % [l.id, l.cost])
	_line("- Izgledi za coine: " + ", ".join(lk))
	var mr: PackedStringArray = []
	for l in _up_levels() + 1:
		mr.append("%d" % roundi(_magnet_r(l)))
	_line("- Magnet radijus po nivou: " + ", ".join(mr))
	var rw: Dictionary = _lp_c.get("REWARDS", {})
	var rp: PackedStringArray = []
	for n in rw:
		rp.append("%d: %d ★3 + %d C" % [n, rw[n][0], rw[n][1]])
	_line("- Level Path nagrade: " + ", ".join(rp))
	_line("- Dnevni poklon: %d C + %d sjemena" % [int(_gs_c.get("DAILY_CHEST_COINS", 8)), int(_gs_c.get("DAILY_CHEST_SEEDS", 3))])


# --- kalibracija iz telemetrije ---

## --log=PUT čita log sa telefona (adb exec-out run-as com.mergemeadow.game cat files/balance_log.csv).
func _calibrate() -> void:
	var path := _arg("log", "user://balance_log.csv")
	if not FileAccess.file_exists(path):
		print("economy_sim: nema %s — odigraj par runova u debug buildu" % path)
		return
	var f := FileAccess.open(path, FileAccess.READ)
	var head := f.get_csv_line()
	var idx := {}
	for i in head.size():
		idx[head[i]] = i
	var picked := 0.0
	var missed := 0.0
	var passed := 0.0
	var hits := 0.0
	var speed_w := 0.0
	var rows := 0
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() < head.size():
			continue
		rows += 1
		picked += float(row[idx.pickups_collected])
		missed += float(row[idx.pickups_missed])
		passed += float(row[idx.obstacles_passed])
		hits += 1.0 if row[idx.end] == "hit" else 0.0
		speed_w += float(row[idx.avg_speed]) * float(row[idx.obstacles_passed])
	if rows == 0:
		return
	var avg_v := speed_w / maxf(1.0, passed)
	var hz := hits / maxf(1.0, passed + hits)
	_line("## Kalibracija (%d runova iz telemetrije)" % rows)
	_line("")
	_line("- Skupljeno pickupa: %.0f %% (%d / %d)" % [100.0 * picked / maxf(1.0, picked + missed), picked, picked + missed])
	_line("- Rizik po prepreci: %.2f %% pri prosječnoj brzini %d px/s → na 400 px/s ≈ %.2f %%" % [
		100.0 * hz, roundi(avg_v), 100.0 * hz / pow(maxf(avg_v, 1.0) / BASE_SPEED, 2.0)])
	_line("")
