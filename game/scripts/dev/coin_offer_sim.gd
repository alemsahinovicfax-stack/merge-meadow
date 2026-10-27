extends "res://scripts/dev/economy_sim.gd"

## Coin ponude bez kupovina pravim novcem (v1 samo s reklamama, 2026-10-26). Headless, ne dira save.
##
## Nasljeđuje model igrača i put kroz 4 besplatne sezone iz economy_sim.gd (isti runovi, sjeme,
## nagrade Level Patha, nadogradnje, izgledi, dnevni poklon) i dodaje stvari koje su se prodavale
## pravim novcem, po cijenama iz MonetizationConfig.IAP_PRODUCTS (`coin_price`):
##   D1. prva kupovina — dan kad UKUPNA zarada (politika rush) prvi put dostigne cijenu: koliko dugo
##       štedi igrač kojem je ta stvar prvi cilj;
##   D2. normalna igra — rush + Merge Hint čim ga može platiti; teme i Sir Pip tek kad su sve
##       besplatne sezone otključane (dugoročni cilj): dan kupovine i koliko kasne besplatne sezone;
##   D2b. isto, ali tema / Sir Pip čim poslije kupovine ostane dovoljno coina za sljedeću besplatnu
##       sezonu (kao izgledi u rushu) — igrač koji ih želi, a ne odgađa sezone;
##   D3. Loot Burst za coine (+5 ★3 sezone koja otključava sljedeću besplatnu) — koliko ranije se
##       otključaju besplatne sezone: „pametno" (kupi samo kad coini za sezonu već postoje, fali samo
##       ★3) i „sve" (kupi čim fali ★3), za više cijena (--burst-prices).
## Svako ponavljanje kreće istim seedom za sve politike (common random numbers): razlika između
## politika nije šum nasumičnih runova.
##
## Pokretanje (APPDATA kopija kao u scripts/smoke-all.ps1):
##   godot --headless --path game -s res://scripts/dev/coin_offer_sim.gd -- --reps=10
##   opcije: --burst-prices=500,750,1000,1500,2000 --profiles=casual,average,skilled --seed=7
##           --parts=d1,d2,d2b,d3 --out=C:/put/coin.md

## Minuta igre dnevno — isti zadani dan kao dio B u economy_sim.gd (samo za ispis dana).
const DAY_LEN := 25.0
## Kriteriji (plan ADS-ONLY): Merge Hint rano, Loot Burst ne ubrzava besplatne sezone > 10 %.
const HINT_MAX_DAYS := {"casual": 3.0, "average": 2.0}
const BURST_MAX_SPEEDUP := 0.10
const BURST_MODES: Array[String] = ["smart", "all"]

var _offers: Array = []        # trajne coin ponude osim Merge Hinta [{sku, name, cost}], od najjeftinije
var _hint: Dictionary = {}     # Merge Hint {sku, name, cost}
var _burst_price: int = 0      # Loot Burst iz podataka
var _thresholds: Array[int] = []
var _policy: String = ""
var _burst_mode: String = ""
var _burst_cost: int = 0
var _seed: int = 7


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
	_load_offers()
	_seed = int(_arg("seed", "7"))
	var reps := int(_arg("reps", "10"))
	var profiles: Array[String] = []
	for p in _arg("profiles", "casual,average,skilled").split(","):
		if PROFILES.has(p):
			profiles.append(p)
	var prices: Array[int] = []
	for s in _arg("burst-prices", "500,750,1000,1500,2000").split(","):
		if int(s) > 0:
			prices.append(int(s))
	_line("# Coin ponude bez kupovina pravim novcem — simulacija (%s)" % Time.get_date_string_from_system())
	_line("")
	_line("Model igrača i put: economy_sim.gd (%s). Dan = %d min igre. %d putovanja po profilu i politici, seed %d (isti po ponavljanju za sve politike)." % [
		_profiles_text(), roundi(DAY_LEN), reps, _seed])
	_line("")
	var rush := {}
	for pname in profiles:
		rush[pname] = _runs_of(pname, "rush_ref", reps)
	var parts := _arg("parts", "d1,d2,d2b,d3").split(",")
	if parts.has("d1"):
		_part_d1(profiles, reps)
	if parts.has("d2"):
		_part_d2(profiles, reps, rush, "coins")
	if parts.has("d2b"):
		_part_d2(profiles, reps, rush, "coins_keep")
	if parts.has("d3"):
		_part_d3(profiles, reps, prices, rush)
	_offer_prices()
	var path := _arg("out", "")
	if not path.is_empty():
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f != null:
			f.store_string("\n".join(_out) + "\n")
			f.close()
			print("coin_offer_sim: wrote %s" % path)
	print("coin_offer_sim OK")
	_quit(0)


# --- podaci ---

func _load_offers() -> void:
	var gs := get_root().get_node("GameState")
	var costs := {}
	for sku in MonetizationConfig.all_skus():
		var cost := MonetizationConfig.coin_price(sku)
		if cost <= 0:
			continue
		var row := {"sku": sku, "name": MonetizationConfig.get_product_title(sku), "cost": cost}
		var season_id := MonetizationConfig.season_id_for_sku(sku)
		if sku == MonetizationConfig.SKU_BOOSTER_LOOT_BURST:
			_burst_price = cost
		elif sku == MonetizationConfig.SKU_BOOSTER_MERGE_HINT:
			_hint = row
		elif not season_id.is_empty() and bool(gs.call("is_test_locked_season", season_id)):
			continue  # Ember: cijena spremna, ali se ne prodaje dok sezona nije u igri.
		else:
			_offers.append(row)
		costs[cost] = true
	_offers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.cost) < int(b.cost))
	for c in costs:
		_thresholds.append(int(c))
	_thresholds.sort()


func _offer_key(o: Dictionary) -> String:
	return "kupljeno: %s (%d)" % [o.name, o.cost]


func _earned_key(cost: int) -> String:
	return "zarada %d" % cost


# --- politike (preko kuka economy_sim.gd) ---

func _runs_of(pname: String, policy: String, reps: int, mode: String = "", cost: int = 0) -> Array:
	_policy = policy
	_burst_mode = mode
	_burst_cost = cost
	var out: Array = []
	for r in reps:
		_rng.seed = _seed * 1000 + r
		out.append(_journey(PROFILES[pname], policy))
	_policy = ""
	return out


func _shop(st: Dictionary, policy: String) -> void:
	match policy:
		"rush_ref", "d1":
			super._shop(st, "rush")
		"coins":
			_buy_hint(st)
			super._shop(st, "rush")
			if int(st.unlocked) >= _seasons.size():
				_buy_offers(st, 0)
		"coins_keep":
			_buy_hint(st)
			super._shop(st, "rush")
			_buy_offers(st, _reserve(st))
		"burst":
			_buy_bursts(st)
			super._shop(st, "rush")
		_:
			super._shop(st, policy)


func _done(st: Dictionary) -> bool:
	match _policy:
		"rush_ref", "burst":
			return int(st.unlocked) >= _seasons.size()
		"d1":
			for c in _thresholds:
				if not (st.ms as Dictionary).has(_earned_key(c)):
					return false
			return true
		"coins", "coins_keep":
			# Kraj kad su sve besplatne sezone i sve coin ponude tu (casual inače melje L20 do MAX_RUNS).
			var want := _offers.size() + (0 if _hint.is_empty() else 1)
			return int(st.unlocked) >= _seasons.size() and _owned_count(st) >= want
	return super._done(st)


## Ukupna zarada od početka (D1): oznaka kad prvi put dostigne svaku cijenu.
func _earn(st: Dictionary, source: String, n: int) -> void:
	super._earn(st, source, n)
	st["earned"] = int(st.get("earned", 0)) + n
	for c in _thresholds:
		if int(st.earned) >= c:
			_mark(st, _earned_key(c))


func _owns(st: Dictionary, sku: String) -> bool:
	return st.has("offers") and (st.offers as Dictionary).has(sku)


func _owned_count(st: Dictionary) -> int:
	return (st.offers as Dictionary).size() if st.has("offers") else 0


func _buy(st: Dictionary, o: Dictionary) -> void:
	if not st.has("offers"):
		st["offers"] = {}
	st.wallet = int(st.wallet) - int(o.cost)
	(st.offers as Dictionary)[o.sku] = true
	_flow(st, "trošak: coin ponude", int(o.cost))
	_mark(st, _offer_key(o))


## Merge Hint čim ga može platiti (jeftin i koristan — prvi cilj igrača koji ga želi).
func _buy_hint(st: Dictionary) -> void:
	if _hint.is_empty() or _owns(st, str(_hint.sku)) or int(st.wallet) < int(_hint.cost):
		return
	_buy(st, _hint)


## Teme i Sir Pip: najjeftinija koju još nema, čim poslije kupovine ostane `keep` coina.
func _buy_offers(st: Dictionary, keep: int) -> void:
	for o in _offers:
		if _owns(st, str(o.sku)):
			continue
		if int(st.wallet) - int(o.cost) < keep:
			return
		_buy(st, o)


## Coini za sljedeću besplatnu sezonu (0 kad su sve otključane) — kao rezerva u rushu.
func _reserve(st: Dictionary) -> int:
	var nxt := int(st.unlocked)
	return int(_seasons[nxt].coins) if nxt < _seasons.size() else 0


## Loot Burst: +5 ★3 cvijeta sezone koja otključava sljedeću besplatnu (kao Boosters.loot_target).
## smart = kupi samo kad coini za tu sezonu već postoje; all = kupi čim fali ★3.
func _buy_bursts(st: Dictionary) -> void:
	var nxt := int(st.unlocked)
	if nxt >= _seasons.size():
		return
	var ns: Dictionary = _seasons[nxt]
	var top: Dictionary = _seasons[nxt - 1]
	var keep := int(ns.coins) if _burst_mode == "smart" else 0
	while int(st.stash.get(top.star3, 0)) < int(ns.t3) and int(st.wallet) - _burst_cost >= keep:
		st.wallet = int(st.wallet) - _burst_cost
		st.stash[top.star3] = int(st.stash.get(top.star3, 0)) + MonetizationConfig.LOOT_BURST_STAR3
		_flow(st, "trošak: Loot Burst", _burst_cost)
		_flow(st, "★3 cvijet: Loot Burst", MonetizationConfig.LOOT_BURST_STAR3)


# --- statistika ---

func _vals(js: Array, key: String, field: String) -> Array[float]:
	var out: Array[float] = []
	for j in js:
		var ms: Dictionary = (j as Dictionary).get("ms", {})
		out.append(float((ms[key] as Dictionary).get(field, INF)) if ms.has(key) else INF)
	return out


func _median(vals: Array[float]) -> float:
	if vals.is_empty():
		return INF
	var v := vals.duplicate()
	v.sort()
	return v[v.size() / 2]


func _day(js: Array, key: String) -> float:
	return _median(_vals(js, key, "min")) / DAY_LEN


func _runs_med(js: Array, key: String) -> float:
	return _median(_vals(js, key, "runs"))


func _reached(js: Array, key: String) -> int:
	var n := 0
	for v in _vals(js, key, "min"):
		if is_finite(v):
			n += 1
	return n


func _flow_med(js: Array, key: String) -> float:
	var vals: Array[float] = []
	for j in js:
		vals.append(float(((j as Dictionary).get("flow", {}) as Dictionary).get(key, 0)))
	return _median(vals)


func _day_cell(js: Array, key: String) -> String:
	var d := _day(js, key)
	if not is_finite(d):
		return "— (%d / %d)" % [_reached(js, key), js.size()]
	return "%.1f (%d)" % [d, roundi(_runs_med(js, key))]


func _free_keys() -> Array[String]:
	var out: Array[String] = []
	for i in range(1, _seasons.size()):
		out.append("%s otključan" % _seasons[i].id)
	return out


# --- D1 ---

func _part_d1(profiles: Array[String], reps: int) -> void:
	var js := {}
	for p in profiles:
		js[p] = _runs_of(p, "d1", reps)
	_line("## D1. Prva kupovina — dan kad zarada prvi put dostigne cijenu")
	_line("")
	_line("Politika rush (štedi za sljedeću besplatnu sezonu, kupuje nadogradnje); broji se UKUPNA zarada od prvog runa — igrač kojem je ta stvar prvi cilj ima je tog dana. Medijan dana, u zagradi runova.")
	_line("")
	var head := "| Stvar | Cijena |"
	var sep := "|---|---|"
	for p in profiles:
		head += " %s |" % p
		sep += "---|"
	_line(head)
	_line(sep)
	var rows: Array = []
	if not _hint.is_empty():
		rows.append(_hint)
	rows.append_array(_offers)
	if _burst_price > 0:
		rows.append({"sku": MonetizationConfig.SKU_BOOSTER_LOOT_BURST, "name": "Loot Burst (1×)", "cost": _burst_price})
	for o in rows:
		var row := "| %s | %d |" % [o.name, o.cost]
		for p in profiles:
			row += " %s |" % _day_cell(js[p], _earned_key(int(o.cost)))
		_line(row)
	_line("")
	if not _hint.is_empty():
		var parts: PackedStringArray = []
		for p in HINT_MAX_DAYS:
			if not js.has(p):
				continue
			var d := _day(js[p], _earned_key(int(_hint.cost)))
			parts.append("%s %.1f dana (cilj ≤ %.0f) %s" % [p, d, float(HINT_MAX_DAYS[p]), "✓" if d <= float(HINT_MAX_DAYS[p]) else "✗"])
		_line("Merge Hint (%d C): %s." % [int(_hint.cost), "; ".join(parts)])
		_line("")


# --- D2 ---

func _part_d2(profiles: Array[String], reps: int, rush: Dictionary, policy: String) -> void:
	if policy == "coins":
		_line("## D2. Normalna igra — rush + Merge Hint čim ga može platiti; teme i Sir Pip poslije besplatnih sezona")
	else:
		_line("## D2b. Rush + Merge Hint čim ga može platiti; tema / Sir Pip čim ostane dovoljno coina za sljedeću besplatnu sezonu")
	_line("")
	_line("Kašnjenje = koliko kasnije se otključa besplatna sezona nego u čistom rushu (isti seedovi).")
	_line("")
	for pname in profiles:
		var js := _runs_of(pname, policy, reps)
		_line("### %s" % pname)
		_line("")
		_line("| Milestone | Dan (runova) | rush dan | Kašnjenje |")
		_line("|---|---|---|---|")
		if not _hint.is_empty():
			_line("| %s | %s | — | — |" % [_offer_key(_hint), _day_cell(js, _offer_key(_hint))])
		for key in _free_keys():
			var d := _day(js, key)
			var r := _day(rush[pname], key)
			var late := "—"
			if is_finite(d) and is_finite(r) and r > 0.0:
				late = "%+.1f dana (%+d %%)" % [d - r, roundi(100.0 * (d - r) / r)]
			_line("| %s | %s | %s | %s |" % [key, _day_cell(js, key), "%.1f" % r if is_finite(r) else "—", late])
		for o in _offers:
			_line("| %s | %s | — | — |" % [_offer_key(o), _day_cell(js, _offer_key(o))])
		_line("")


# --- D3 ---

func _part_d3(profiles: Array[String], reps: int, prices: Array[int], rush: Dictionary) -> void:
	_line("## D3. Loot Burst za coine — koliko ranije se otključaju besplatne sezone")
	_line("")
	_line("+%d ★3 cvijeta sezone koja otključava sljedeću besplatnu. pametno = kupi samo kad coini za sezonu već postoje (fali samo ★3); sve = kupi čim fali ★3. Ubrzanje = koliko ranije od rusha (medijan dana). Kriterij: najveće ubrzanje ≤ %d %% (average i casual)." % [
		MonetizationConfig.LOOT_BURST_STAR3, roundi(BURST_MAX_SPEEDUP * 100.0)])
	_line("")
	var keys := _free_keys()
	var verdict := {}   # cijena -> {profil -> najveće ubrzanje}
	for pname in profiles:
		_line("### %s" % pname)
		_line("")
		var head := "| Cijena | Način |"
		var sep := "|---|---|"
		for k in keys:
			head += " %s |" % k.replace(" otključan", "")
			sep += "---|"
		_line(head + " Najveće ubrzanje | Burstova | Coina u Burst |")
		_line(sep + "---|---|---|")
		var base_row := "| — | rush |"
		for k in keys:
			base_row += " %s |" % _day_cell(rush[pname], k)
		_line(base_row + " — | 0 | 0 |")
		for price in prices:
			for mode in BURST_MODES:
				var js := _runs_of(pname, "burst", reps, mode, price)
				var row := "| %d | %s |" % [price, "pametno" if mode == "smart" else "sve"]
				var worst := 0.0
				for k in keys:
					var d := _day(js, k)
					var r := _day(rush[pname], k)
					var gain := (r - d) / r if is_finite(d) and is_finite(r) and r > 0.0 else 0.0
					worst = maxf(worst, gain)
					row += " %s · %+d %% |" % [_day_cell(js, k), roundi(-100.0 * gain)]
				var spent := _flow_med(js, "trošak: Loot Burst")
				row += " %d %% | %d | %d |" % [roundi(worst * 100.0), roundi(spent / float(price)), roundi(spent)]
				_line(row)
				if not verdict.has(price):
					verdict[price] = {}
				verdict[price][pname] = maxf(float((verdict[price] as Dictionary).get(pname, 0.0)), worst)
		_line("")
	var ok_price := -1
	var lines: PackedStringArray = []
	for price in prices:
		var v: Dictionary = verdict.get(price, {})
		var pass_all := true
		var parts: PackedStringArray = []
		for p in ["casual", "average"]:
			if not v.has(p):
				continue
			var w := float(v[p])
			parts.append("%s %d %%" % [p, roundi(w * 100.0)])
			if w > BURST_MAX_SPEEDUP:
				pass_all = false
		lines.append("- %d C: najveće ubrzanje %s → %s" % [price, ", ".join(parts), "✓" if pass_all else "✗"])
		if pass_all and ok_price < 0:
			ok_price = price
	_line("**Kriterij po cijeni:**")
	_line("")
	for l in lines:
		_line(l)
	_line("")
	if ok_price > 0:
		_line("Najniža cijena iz sweepa koja ispunjava kriterij: **%d C** (u podacima sada %d C)." % [ok_price, _burst_price])
	else:
		_line("Nijedna cijena iz sweepa ne ispunjava kriterij — proširi --burst-prices.")
	_line("")


func _offer_prices() -> void:
	_line("## Coin cijene u podacima (MonetizationConfig.IAP_PRODUCTS · coin_price)")
	_line("")
	for sku in MonetizationConfig.all_skus():
		_line("- %s: %d C" % [sku, MonetizationConfig.coin_price(sku)])
	_line("")
