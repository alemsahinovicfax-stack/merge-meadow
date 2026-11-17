extends SceneTree

## FIX-TEL-4 (2026-11-14, na zahtjev):
##   · 25 levela po sezoni; 21–25 teži od 20 i jedan od drugog; nijedan level duži od 120 s
##   · sanduci 5 / 10 / 15 / 20 / 25: 10 × prvi ★2, 15 i 20 × drugi ★2, 5 i 10 × ★3; coini
##     200 / 400 / 600 / 1000 / 2000
##   · pragovi Journey sezona 40 / 45 / 50
##   · Endless: korak težine po Paceu × 1,1; spawn 20 % češći
##   · stari save s „put završen" (21) nastavlja od levela 21
##   · Boost dugme: boja tiera cvijeta, veliki portret

const FLOWERS := {
	"country_bloom": ["tulip", "sunflower", "pumpkin"],
	"frost_orchard": ["winter_camellia", "hoarfrost_rose", "crystal_peony"],
	"ember_fen": ["flame_iris", "smoke_lotus", "fenfire_crown"],
}
const REWARDS := {5: [10, 200, 0], 10: [15, 400, 1], 15: [20, 600, 1], 20: [5, 1000, 2], 25: [10, 2000, 2]}
const UNLOCK := {"frost_orchard": 40, "lantern_meadow": 45, "amber_canopy": 50}

var _backup := ""
var _failed := false


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("levels25_smoke: %s" % msg)


func _run() -> void:
	var gs: Node = root.get_node("GameState")
	var lib: Node = root.get_node("RunLevelLibrary")
	await process_frame

	# --- leveli ---
	if int(lib.get("MAX_RUN_LEVEL")) != 25 or LevelPathDomain.LEVELS != 25 or LevelPathDomain.COMPLETE != 26:
		_fail("there should be 25 levels")
	var prev = null
	for n in range(1, 26):
		var cfg = lib.call("get_level", n)
		if int(cfg.id) != n:
			_fail("level %d is missing from levels.json" % n)
		if float(cfg.duration_sec) > 120.0:
			_fail("level %d lasts %.0f s, cap is 120" % [n, cfg.duration_sec])
		if n >= 20 and float(cfg.duration_sec) != 120.0:
			_fail("level %d should last exactly 120 s" % n)
		if prev != null:
			if not (cfg.scroll_speed_mult > prev.scroll_speed_mult and cfg.obstacle_chance > prev.obstacle_chance
					and cfg.pair_chance > prev.pair_chance and cfg.spawn_interval < prev.spawn_interval
					and cfg.speed_ramp >= prev.speed_ramp):
				_fail("level %d is not harder than level %d" % [n, n - 1])
			if n < 20 and float(cfg.duration_sec) < float(prev.duration_sec):
				_fail("level %d is shorter than level %d" % [n, n - 1])
		prev = cfg
	# Korak 21–25 = korak 16–20 (proporcija težine se nastavlja).
	var a = lib.call("get_level", 15)
	var b = lib.call("get_level", 20)
	var c = lib.call("get_level", 25)
	for f in ["scroll_speed_mult", "obstacle_chance", "pair_chance"]:
		var d1 := float(b.get(f)) - float(a.get(f))
		var d2 := float(c.get(f)) - float(b.get(f))
		if absf(d1 - d2) > 0.002:
			_fail("%s: step 21–25 (%.4f) should match step 16–20 (%.4f)" % [f, d2, d1])
	if lib.call("get_level", 99).id != 25:
		_fail("levels above 25 should clamp to 25")
	if UiLevels.band_of(21) != 5 or UiLevels.band_of(25) != 5 or UiLevels.band_of(20) != 4:
		_fail("levels 21–25 should be band 5")
	for rel in ["bands/tag_5.svg", "bands/tag_5_peak.svg", "bands/flag_5.svg"]:
		if UiLevels.tex(rel) == null:
			_fail("missing band art %s" % rel)

	# --- raspored puta ---
	if LevelPathKit.cp_count() != 25:
		_fail("path should have 25 stones, has %d" % LevelPathKit.cp_count())
	for n in [5, 10, 15, 20, 25]:
		var ch := LevelPathKit.chest(n)
		if ch.is_empty():
			_fail("no chest at level %d" % n)
		elif bool(ch["big"]) != (n == 25):
			_fail("only the level 25 chest is the big one (level %d)" % n)
	for n in range(1, 26):
		var p := LevelPathKit.cp(n)
		if p.y < 300.0 or p.y > LevelPathKit.H - 300.0 or p.x < 200.0 or p.x > 880.0:
			_fail("stone %d is off the path area: %s" % [n, p])
		if n > 1 and LevelPathKit.cp(n - 1).y - p.y < 150.0:
			_fail("stone %d is too close to stone %d" % [n, n - 1])
		if LevelPathKit.route()[LevelPathKit.cp_index(n)].distance_to(p) > 2.0:
			_fail("route does not pass through stone %d" % n)
	if LevelPathKit.flag_bottom().distance_to(LevelPathKit.cp(25)) > 320.0:
		_fail("goal flag should stand by stone 25")

	# --- sanduci ---
	if LevelPathDomain.REWARD_LEVELS != [5, 10, 15, 20, 25]:
		_fail("reward levels should be 5 / 10 / 15 / 20 / 25")
	for n in REWARDS:
		var r: Array = LevelPathDomain.REWARDS.get(n, [])
		if r != REWARDS[n]:
			_fail("reward %d should be %s, is %s" % [n, REWARDS[n], r])
	var d: LevelPathDomain = gs.get("level_path_domain")
	for sid in FLOWERS:
		for n in REWARDS:
			var want := str(FLOWERS[sid][int(REWARDS[n][2])])
			if d.reward_flower(sid, n) != want:
				_fail("%s chest %d should give %s, gives %s" % [sid, n, want, d.reward_flower(sid, n)])
	d.reset()
	d.set_level("country_bloom", 26)
	var stash: Dictionary = gs.get("garden_crystal_stash")
	stash.clear()
	gs.set("wallet_coins", 0)
	var coins := 0
	for n in [5, 10, 15, 20, 25]:
		var got: Dictionary = gs.call("claim_level_reward", "country_bloom", n)
		if int(got.get("flowers", 0)) != int(REWARDS[n][0]) or int(got.get("coins", 0)) != int(REWARDS[n][1]):
			_fail("claim %d returned %s" % [n, got])
		coins += int(REWARDS[n][1])
	if int(gs.get("wallet_coins")) != coins:
		_fail("coins after all chests should be %d, are %d" % [coins, gs.get("wallet_coins")])
	if int(stash.get("tulip", 0)) != 10 or int(stash.get("sunflower", 0)) != 35 or int(stash.get("pumpkin", 0)) != 15:
		_fail("flowers after all chests should be tulip 10, sunflower 35, pumpkin 15: %s" % stash)
	if not (gs.call("claim_level_reward", "country_bloom", 25) as Dictionary).is_empty():
		_fail("chest 25 must not be claimable twice")

	# --- stari save: „put završen" (21) nastavlja od 21, uzeti sanduci ostaju ---
	d.apply_from_save({"season_levels": {"frost_orchard": 21}, "season_level_rewards": {"frost_orchard": [5, 10, 15, 20]}})
	if d.level_of("frost_orchard") != 21 or d.is_complete("frost_orchard") or d.play_level_of("frost_orchard") != 21:
		_fail("old finished path should continue at level 21")
	if d.has_ready("frost_orchard"):
		_fail("old save should not get the first four chests again")
	if d.reward_state("frost_orchard", 25) != LevelPathDomain.REWARD_LOCKED:
		_fail("chest 25 should wait for level 25")

	# --- pragovi sezona ---
	for sid in UNLOCK:
		var def: SeasonDef = gs.call("get_season_def", sid)
		if def == null or int(def.t3_flowers_required) != int(UNLOCK[sid]):
			_fail("%s should need %d flowers" % [sid, UNLOCK[sid]])
	for sid in ["moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]:
		var pdef: SeasonDef = gs.call("get_season_def", sid)
		if pdef != null and int(pdef.t3_flowers_required) != 0:
			_fail("%s (Themes) must not need flowers" % sid)

	# --- Endless ---
	# Pace 3 je sada tamo gdje je stara tabela bila na 3 × 22 s (+ 60 s pomaka) = 126 s:
	# ključevi 120 → 180: brzina 1,35 → 1,55.
	var e3 = lib.call("get_endless_config_at", 30.0)
	var want_speed := 1.35 + (1.55 - 1.35) * (126.0 - 120.0) / 60.0
	if absf(float(e3.scroll_speed_mult) - want_speed) > 0.001:
		_fail("Endless Pace 3 speed should be %.4f, is %.4f" % [want_speed, e3.scroll_speed_mult])
	var e0 = lib.call("get_endless_config_at", 0.0)
	if absf(float(e0.spawn_interval) - 1.1 / 1.2) > 0.001:
		_fail("Endless spawn interval at start should be %.4f, is %.4f" % [1.1 / 1.2, e0.spawn_interval])
	if absf(float(e0.scroll_speed_mult) - 1.15) > 0.001:
		_fail("Endless start speed must not change (1.15), is %.4f" % e0.scroll_speed_mult)
	# Svaki prebačaj diže brzinu 10 % više nego prije (do zadnjeg ključa): stari korak 0,05 / Pace
	# između 60 i 120 s tabele → 0,055.
	var e1 = lib.call("get_endless_config_at", 10.0)
	if absf((float(e1.scroll_speed_mult) - float(e0.scroll_speed_mult)) - 0.2 * 22.0 / 60.0) > 0.001:
		_fail("first Pace step should add %.4f speed, adds %.4f" % [0.2 * 22.0 / 60.0, float(e1.scroll_speed_mult) - float(e0.scroll_speed_mult)])
	var far_a = lib.call("get_endless_config_at", 400.0)
	var far_b = lib.call("get_endless_config_at", 410.0)
	if absf((float(far_b.scroll_speed_mult) - float(far_a.scroll_speed_mult)) - 0.044) > 0.001:
		_fail("after the last key each Pace should add 0.044 speed")

	# --- Boost dugme ---
	# load(): skripta dugmeta zavisi od autoloada, pa je -s skripta ne smije vezati pri parsiranju.
	var btn_script: GDScript = load("res://scripts/ui/popup/popup_button.gd")
	var btn: Control = btn_script.new()
	root.add_child(btn)
	btn.call("configure", "primary", "×5")
	btn.call("set_art", "tulip", 3, 64.0)
	btn.set("coin_text", "100")
	if not (btn.call("tone_colors") as Array).is_empty():
		_fail("a plain button must not have a tier tone")
	btn.set("tone", "epic")
	btn.set("stacked", true)
	var epic: Array = btn.call("tone_colors")
	btn.set("tone", "gold")
	var gold: Array = btn.call("tone_colors")
	if epic.is_empty() or gold.is_empty() or epic[0] == gold[0]:
		_fail("epic and gold Boost buttons need their own colours")
	if float(btn_script.get_script_constant_map().get("PORTRAIT_ART", 0.0)) < 90.0:
		_fail("Boost flower portrait should be at least 90 px (was 64)")
	if float(btn.call("content_width")) > 340.0 - 24.0:
		_fail("stacked Boost content (%.0f px) does not fit the 340 px button" % float(btn.call("content_width")))
	btn.call("configure", "done", "Max")
	if bool(btn.get("stacked")) or not str(btn.get("tone")).is_empty():
		_fail("configure() should reset the Boost look")
	btn.queue_free()

	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		print("levels25_smoke FAILED")
		quit(1)
		return
	print("levels25_smoke OK")
	quit(0)
