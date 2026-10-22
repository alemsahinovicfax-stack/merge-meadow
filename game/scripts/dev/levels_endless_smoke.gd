extends SceneTree

## design_handoff_leveli_endless — leveli koji rastu + Endless (2026-10-22):
##  1. pojasevi: band = ceil(level / 5), kraj pojasa 5/10/15/20, boja toplote Endlessa; sve
##     teksture paketa postoje (pločice, zastavice, parovi × 8, ciljevi × 8, sanduk, Endless, fx);
##  2. cilj: preostali put sa stepenicama brzine = vrijeme pojave iz level_finish.json (±0,02 s) za
##     svih 20 levela; u runu se cilj pojavi kad se spawn zatvori (y ≈ −80) i traka stigne do Pipa
##     tačno kad istekne vrijeme; prolaz: polovine 78°, ≤ 16 sprite-ova, konfete nestanu;
##  3. par: susjedne staze = jedan široki sprite (desni par zrcaljen), lijevo + desno = dva bočna;
##  4. nalet na svaku stepenicu brzine (≤ 5 linija, ≤ 0,5 s), svijet i Pip se vrate;
##  5. najava levela (L6 „Jog · 1:16", replay „Replay"), ≤ 1,2 s, ne blokira unos;
##  6. Endless: pilula „Pace N" i nalet na novu stepenicu, rekord jednom po runu, čip „New best!";
##     pauza „If you quit · all yours" + korpa u mint disku; level pauza ostaje ½;
##  7. kraj Endlessa (R5): „New best!" / „Endless", vrijeme, Pace, „Was" / „Best", „All yours";
##  8. Level Path: pločice pojasa na kamenovima, 4 zastavice ne diraju sanduke ni kamenje (8 sezona),
##     spreman sanduk mijenja frejm closed → peek, pločica sadržaja, tap ispod sanduka = popup;
##  9. Endless dugme: zaključano „N / 15", otključavanje jednom po sezoni (skok 15 → 16).
## Pokretanje: godot --headless --path game -s res://scripts/dev/levels_endless_smoke.gd

const SEASONS: Array[String] = [
	"country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
	"moonlit_warren", "coral_tide", "starfall_glade", "ember_fen",
]
const DT := 1.0 / 60.0

var _backup := ""
var _failed := false
var _gs: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("levels_endless_smoke: " + msg)


func _finish() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("levels_endless_smoke OK")
	quit(1 if _failed else 0)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(sec * 1000.0):
		await process_frame


func _run() -> void:
	await _frames(2)
	_gs = get_root().get_node("GameState")
	_gs.set("tutorial_complete", true)
	_gs.set("skip_debug_season_unlock", true)
	# Settings igrača mogu imati Reduce motion — animacije se provjeravaju s njim isključenim.
	_gs.set("reduce_motion", false)
	_check_bands_and_assets()
	_check_gate_math()
	await _check_level_run()
	await _check_endless_run()
	await _check_endless_loot()
	await _check_path()
	await _check_endless_button()
	_finish()


# --- 1 ---

func _check_bands_and_assets() -> void:
	var want := {1: 1, 5: 1, 6: 2, 10: 2, 11: 3, 15: 3, 16: 4, 20: 4}
	for lv in want:
		if UiLevels.band_of(lv) != int(want[lv]):
			_fail("level %d should be band %d" % [lv, int(want[lv])])
	for lv in range(1, 21):
		if UiLevels.is_peak(lv) != (lv % 5 == 0) or UiLevels.tag_tex(lv) == null:
			_fail("level %d tag / peak wrong" % lv)
	var heat := {0: 1, 2: 1, 3: 2, 5: 2, 6: 3, 8: 3, 9: 4, 30: 4}
	for t in heat:
		if UiLevels.pace_band(t) != int(heat[t]):
			_fail("Endless tier %d should use band %d color" % [t, int(heat[t])])
	for b in range(1, 5):
		if UiLevels.flag_tex(b) == null:
			_fail("missing band flag %d" % b)
	for id in SEASONS:
		for wide in [true, false]:
			var t := UiLevels.pair_tex(id, wide)
			var want_size := UiLevels.PAIR_WIDE if wide else UiLevels.PAIR_SIDE
			if t == null or t.get_size() != want_size:
				_fail("%s pair %s missing or not %s (viewBox fix)" % [id, "wide" if wide else "side", str(want_size)])
		for part in ["post", "arch"]:
			if UiLevels.gate_tex(id, part) == null:
				_fail("%s missing finish %s" % [id, part])
	for rel in ["finish/tape.svg", "finish/tape_half.svg", "chest/ready_closed.svg", "chest/ready_peek.svg",
			"chest/big_ready_closed.svg", "chest/big_ready_peek.svg", "chest/shadow.svg", "endless/lock_body.svg",
			"endless/lock_shackle.svg", "endless/rings.svg", "endless/trophy.svg", "endless/stamp_best.svg",
			"fx/burst_ring.svg", "fx/gust_streak.svg", "fx/pace_up.svg"]:
		if UiLevels.tex(rel) == null:
			_fail("missing %s" % rel)


# --- 2 · matematika cilja (bez scene) ---

## Vrijeme pojave: kad preostali put padne na 1654 px (binarna pretraga po levels.json).
func _gate_lead(lv: int) -> float:
	var cfg = get_root().get_node("RunLevelLibrary").call("get_level", lv)
	var base := 400.0 * float(cfg.scroll_speed_mult)
	var ramp := float(cfg.speed_ramp)
	var dur := float(cfg.duration_sec)
	var lo := 0.0
	var hi := dur
	for _i in 48:
		var m := (lo + hi) * 0.5
		if _remain(base, ramp, dur, m) > 1654.0:
			lo = m
		else:
			hi = m
	return dur - hi


func _remain(base: float, ramp: float, dur: float, t: float) -> float:
	var d := 0.0
	var x := t
	while x < dur - 1e-9:
		var step := int(x / 15.0)
		var nx := minf(dur, float(step + 1) * 15.0)
		d += base * pow(1.0 + ramp, step) * (nx - x)
		x = nx
	return d


## CD tabela gate_lead_s (level_finish.json) je računata za brojeve ciklusa 1; od ciklusa 1b (težina +5 levela) se
## provjerava da cilj stiže 2–4,5 s prije kraja i da je preostali put tada tačno 1654 px.
func _check_gate_math() -> void:
	for lv in range(1, 21):
		var lead := _gate_lead(lv)
		var cfg = get_root().get_node("RunLevelLibrary").call("get_level", lv)
		var rem := _remain(400.0 * float(cfg.scroll_speed_mult), float(cfg.speed_ramp), float(cfg.duration_sec), float(cfg.duration_sec) - lead)
		if lead < 2.0 or lead > 4.5 or absf(rem - 1654.0) > 1.0:
			_fail("level %d gate lead %.3f s (remaining %.1f px)" % [lv, lead, rem])


# --- 2–5 · run u levelu ---

func _check_level_run() -> void:
	_gs.call("set_active_season", "frost_orchard")
	_gs.set("run_level", 6)
	_gs.call("begin_campaign_run")
	if change_scene_to_file("res://scenes/run/run_scene.tscn") != OK:
		_fail("run scene failed to load")
		return
	await _frames(12)
	var run := current_scene
	if run == null or not run.has_method("remaining_distance"):
		_fail("run scene missing remaining_distance")
		return
	# 5 · najava: L6 = Jog, 76 s.
	var intro = run.get("level_intro")
	if intro == null or not intro.is_playing() or intro.plate_text() != "Level 6" or intro.sub_text() != "Jog · 1:16":
		_fail("intro should play 'Level 6' / 'Jog · 1:16', got %s / %s" % [
			intro.plate_text() if intro != null else "-", intro.sub_text() if intro != null else "-"])
	if intro != null and intro.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("intro must not block swipes")
	await _wait(1.35)
	if intro != null and (intro.visible or intro.is_playing()):
		_fail("intro should be gone after 1.2 s")
	var chip := run.get_node("HUD/TopHud/LevelChip") as Control
	if not chip.scale.is_equal_approx(Vector2.ONE):
		_fail("LevelChip bump should settle back to 1")
	intro.play(20, true, 120.0, chip)
	if intro.sub_text() != "Replay · 2:00":
		_fail("replay intro should say 'Replay · 2:00', got %s" % intro.sub_text())
	intro.stop()
	run.set("_state", 2)

	# 3 · parovi.
	var lanes: Array = run.get("lane_x_positions")
	var made := []
	for pair in [[0, 1], [1, 2], [2, 0]]:
		var a: Node = run.call("_spawn_obstacle_at_lane", pair[0])
		var b: Node = run.call("_spawn_obstacle_at_lane", pair[1])
		run.call("_decorate_pair", a, pair[0], b, pair[1])
		made.append([a, b])
	var w01: Array = made[0]
	if str(w01[0].pair_kind) != "wide" or str(w01[1].pair_kind) != "hidden" or bool(w01[0].pair_flip) \
			or absf(float(w01[0].pair_dx) - (float(lanes[1]) - float(lanes[0])) * 0.5) > 0.5:
		_fail("left+mid pair should be one wide sprite drawn by the left obstacle")
	var w12: Array = made[1]
	if str(w12[0].pair_kind) != "wide" or not bool(w12[0].pair_flip) or str(w12[1].pair_kind) != "hidden":
		_fail("mid+right pair should be the mirrored wide sprite")
	var s02: Array = made[2]
	var left: Node = s02[1]
	var right: Node = s02[0]
	if str(left.pair_kind) != "side" or bool(left.pair_flip) or str(right.pair_kind) != "side" or not bool(right.pair_flip):
		_fail("left+right pair should be two side pieces facing the middle")
	for row in made:
		for o in row:
			var shape := (o as Node).get_node("CollisionShape2D") as CollisionShape2D
			if (shape.shape as RectangleShape2D).size != Vector2(64, 64):
				_fail("pair collision must stay 64 × 64 per lane")
	run.call("_clear_world_entities")
	await _frames(1)

	# 4 · nalet na stepenicu brzine (15 s).
	var gust = run.get("gust_fx")
	var world := run.get_node("World") as Node2D
	var pv := run.get_node("Player/PipVisual") as Node2D
	var played: int = gust.played
	run.set("elapsed", 14.99)
	run.set("_gust_step", 0)
	run.set("_state", 0)
	var max_live := 0
	var jolt := 0.0
	for _i in 4:
		run.call("_process", DT)
	for _i in 30:
		gust.call("_process", DT)
		max_live = maxi(max_live, gust.live_sprites())
		jolt = maxf(jolt, world.position.y)
	run.set("_state", 2)
	if gust.played != played + 1 or max_live < 1 or max_live > 5 or jolt < 1.0 or jolt > 10.5:
		_fail("gust at 15 s: played %d→%d, %d streaks, jolt %.1f" % [played, gust.played, max_live, jolt])
	if gust.is_playing() or absf(world.position.y) > 0.01 or not pv.scale.is_equal_approx(Vector2.ONE):
		_fail("gust should end within 0.5 s and reset world / Pip")

	# 2 · cilj u runu: od zatvaranja spawna do kraja (ručni frejmovi od 1/60 s).
	run.call("_clear_world_entities")
	await _frames(1)
	run.set("finish_gate", null)
	run.set("_gate_tried", false)
	var dur := float(_gs.call("get_run_duration"))
	var player := run.get_node("Player") as Node2D
	run.set("elapsed", dur - 4.5)
	run.set("_gust_step", 99)
	run.set("_state", 0)
	var gate = null
	var spawn_y := 0.0
	var guard := 0
	while int(run.get("_state")) == 0 and guard < 600:
		guard += 1
		run.call("_process", DT)
		if gate == null and run.get("finish_gate") != null:
			gate = run.get("finish_gate")
			spawn_y = gate.position.y
			if gate.live_sprites() != 4:
				_fail("riding gate should draw 4 sprites, got %d" % gate.live_sprites())
			var t_left := dur - float(run.get("elapsed"))
			if absf(t_left - _gate_lead(6)) > 0.05:
				_fail("L6 gate appeared %.2f s before the end, math says %.2f" % [t_left, _gate_lead(6)])
		if gate != null:
			var last_y: float = gate.position.y
			if float(run.get("elapsed")) >= dur:
				break
			if last_y > player.position.y + 1.0:
				_fail("gate passed Pip before the time ran out")
				break
	run.call("_update_hud")
	var lbl := run.get_node("HUD/TopHud/LevelChip/Row/ModeLabel") as Label
	if lbl.text != "Level 6":
		_fail("chip should keep 'Level 6' through the finish (finish_run already moved the path), got %s" % lbl.text)
	if gate == null:
		_fail("finish gate never appeared")
	else:
		if absf(spawn_y - (-80.0)) > 12.0:
			_fail("gate should appear at the spawn line, got y %.1f" % spawn_y)
		var speed := float(run.get("scroll_speed"))
		if absf(gate.position.y - player.position.y) > speed * DT + 2.0:
			_fail("tape should reach Pip at the end: gate %.1f vs Pip %.1f" % [gate.position.y, player.position.y])
		if bool(run.call("_spawn_reaches_pip")):
			_fail("nothing may spawn while the gate rides in")
	# Prolaz kroz cilj (dio _play_finish_beat).
	await _wait(1.3)
	if gate != null and is_instance_valid(gate):
		if not gate.is_broken():
			_fail("finish should break the tape")
		var halves := []
		for c in gate.get_children():
			if (c as Sprite2D).texture == UiLevels.tex("finish/tape_half.svg"):
				halves.append(c)
		if halves.size() != 2 or absf(absf((halves[0] as Sprite2D).rotation_degrees) - 78.0) > 1.0:
			_fail("tape halves should swing to 78°")
		if gate.live_sprites() > 16:
			_fail("finish pass over budget: %d sprites" % gate.live_sprites())
	# Cilj koji vozi kroz prave frejmove (1,2 s) mora i dalje puknuti na prolazu.
	_gs.call("begin_campaign_run")
	change_scene_to_file("res://scenes/run/run_scene.tscn")
	await _frames(12)
	run = current_scene
	run.set("_state", 2)
	var g2 = load("res://scripts/run/run_finish_gate.gd").new()
	g2.setup("frost_orchard", 1.0)
	run.get_node("World").add_child(g2)
	await _wait(1.2)
	if g2.is_broken():
		_fail("riding gate must not run its finish animation on its own")
	g2.pass_through(run.get_node("HUD/FlyLayer"), Vector2(540, 1574))
	await _wait(0.6)
	var rot := 0.0
	for c in g2.get_children():
		if (c as Sprite2D).texture == UiLevels.tex("finish/tape_half.svg"):
			rot = maxf(rot, absf((c as Sprite2D).rotation_degrees))
	if rot < 60.0:
		_fail("gate that rode for 1.2 s should still break on the pass (half at %.0f°)" % rot)
	# Pauza u levelu: ½ ostaje.
	_gs.call("begin_campaign_run")
	change_scene_to_file("res://scenes/run/run_scene.tscn")
	await _frames(12)
	run = current_scene
	run.set("coin_count", 6)
	run.call("_fill_pause")
	var tray = run.get("pause_overlay").find_child("RewardTray", true, false)
	var quit_btn = run.get("quit_button")
	if tray == null or tray.stamp_full or tray.stamp_text != "If you quit" or quit_btn.icon_disc.a > 0.0:
		_fail("level pause keeps the half stamp and the plain ½ icon")


# --- 6 · Endless run ---

func _check_endless_run() -> void:
	var lp = _gs.get("level_path_domain")
	lp.set_level("frost_orchard", 16)
	lp.endless_best["frost_orchard"] = 30.0
	_gs.call("begin_endless_run")
	change_scene_to_file("res://scenes/run/run_scene.tscn")
	await _frames(12)
	var run := current_scene
	run.set("_state", 2)
	var intro = run.get("level_intro")
	if intro.is_playing():
		_fail("Endless must not play the level intro")
	# Godot sam uključi _process kad čvor uđe u stablo: kroz 2 s pravih frejmova ništa ne smije
	# krenuti samo (najava u Endlessu, nalet, trzaj svijeta).
	var world0 := run.get_node("World") as Node2D
	var seen_intro := false
	var jolt0 := 0.0
	var t_end := Time.get_ticks_msec() + 2000
	while Time.get_ticks_msec() < t_end:
		await process_frame
		seen_intro = seen_intro or (intro.visible and intro.modulate.a > 0.01)
		jolt0 = maxf(jolt0, absf(world0.position.y))
	if seen_intro or jolt0 > 0.01:
		_fail("idle effects started on their own (intro %s, world jolt %.1f)" % [str(seen_intro), jolt0])
	var fx = run.get("endless_fx")
	var ec = run.get("endless_chip")
	var gust = run.get("gust_fx")
	var g0: int = gust.played
	run.set("elapsed", 19.99)
	run.set("_state", 0)
	for _i in 3:
		run.call("_process", DT)
	run.set("_state", 2)
	if fx.pace_played != 1 or not fx.is_pace_visible() or fx.pill_text() != "Pace 1" or gust.played != g0 + 1:
		_fail("new tier should show 'Pace 1' and a gust (pace %d, gust %d)" % [fx.pace_played, gust.played - g0])
	if ec.pace_text() != "Pace 1" or ec.best_text() != "Best 0:30":
		_fail("chip should read Pace 1 / Best 0:30, got %s / %s" % [ec.pace_text(), ec.best_text()])
	await _wait(1.1)
	if fx.is_pace_visible():
		_fail("Pace pill should be gone after 0.92 s")
	run.set("elapsed", 30.5)
	run.set("_state", 0)
	run.call("_process", DT)
	run.call("_process", DT)
	run.set("_state", 2)
	if fx.best_played != 1 or ec.best_text() != UiLevels.S_NEW_BEST or not bool(run.call("is_new_best_live")):
		_fail("passing the season best should play the record once and swap the chip row")
	var live: int = fx.live_sprites()
	if live > 12:
		_fail("record fx over budget: %d" % live)
	run.set("elapsed", 40.0)
	run.set("_state", 0)
	run.call("_process", DT)
	run.set("_state", 2)
	if fx.best_played != 1:
		_fail("record should play only once per run")
	var chip := run.get_node("HUD/TopHud/LevelChip") as Control
	if chip.size.x > UiRun.LEVEL_CHIP_MAX_W + 0.5 or absf(chip.size.y - UiRun.TOP_HUD_H) > 0.5:
		_fail("Endless chip %.0f × %.0f must stay ≤ 464 × 128" % [chip.size.x, chip.size.y])
	# B7 · pauza.
	run.set("coin_count", 6)
	run.call("_fill_pause")
	var tray = run.get("pause_overlay").find_child("RewardTray", true, false)
	var head: Node = run.get("pause_overlay").find_child("EndlessPauseHeader", true, false)
	var quit_btn = run.get("quit_button")
	if tray == null or not tray.stamp_full or tray.stamp_text != UiLevels.S_QUIT_ALL_YOURS:
		_fail("Endless pause tray should be 'If you quit · all yours' (mint)")
	if head == null or str(head.get("clock_text")) != "0:40":
		_fail("Endless pause header should show the clock")
	if quit_btn.icon_disc != UiLevels.MINT or str(quit_btn.icon_tex.resource_path).find("icon_basket") < 0:
		_fail("Quit to camp should carry the basket in a mint disc in Endless")
	await _wait(1.0)
	if fx.live_sprites() != 0:
		_fail("Endless fx should be idle after the moments, %d live" % fx.live_sprites())


# --- 7 · R5 Endless ---

func _check_endless_loot() -> void:
	_gs.set("run_is_endless", true)
	_gs.call("set_active_season", "frost_orchard")
	var lp = _gs.get("level_path_domain")
	lp.endless_best["frost_orchard"] = 265.0
	_gs.call("finish_run", {"clover": 3}, 40, true, 420.0, 0)
	if not bool(_gs.get("last_endless_new_best")) or absf(float(_gs.get("last_endless_prev_best")) - 265.0) > 0.01:
		_fail("7:00 over 4:25 should be a new best with the old one kept for 'Was'")
	change_scene_to_file("res://scenes/ui/loot_screen.tscn")
	await _frames(10)
	var loot := current_scene
	var score: Dictionary = loot.call("get_endless_score")
	if str(loot.call("get_title")) != "New best!" or str(score.get("time", "")) != "7:00" \
			or str(score.get("pace", "")) != "Pace 21" or str(score.get("best", "")) != "Was 4:25" or not bool(score.get("stamp", false)):
		_fail("R5 new best → %s %s" % [str(loot.call("get_title")), str(score)])
	var tray = loot.get("tray")
	if tray == null or not tray.stamp_full or tray.stamp_text != UiLevels.S_ALL_YOURS:
		_fail("Endless tray must be full with 'All yours'")
	for chip in tray.chips:
		if chip.was >= 0:
			_fail("Endless loot must not be struck through")
	var retry = loot.get("retry_button")
	if retry.kind != "primary":
		_fail("Retry should be primary at the end of Endless")
	# Bez rekorda: „Endless" + „Best 7:00".
	_gs.set("run_is_endless", true)
	_gs.call("finish_run", {}, 5, true, 61.0, 0)
	change_scene_to_file("res://scenes/ui/loot_screen.tscn")
	await _frames(10)
	loot = current_scene
	score = loot.call("get_endless_score")
	if str(loot.call("get_title")) != "Endless" or str(score.get("best", "")) != "Best 7:00" or bool(score.get("stamp", true)):
		_fail("R5 without a record → %s %s" % [str(loot.call("get_title")), str(score)])
	# Revive nastavlja isti run: pad na 5:00 (rekord 4:25 → upisano 5:00), revive, pad na 5:05 →
	# „New best!" i „Was 4:25" (ne „Was 5:00"); u runu poslije revive rekord sa starta je 4:25.
	lp.endless_best["frost_orchard"] = 265.0
	_gs.call("begin_endless_run")
	_gs.call("finish_run", {}, 3, true, 300.0, 0)
	if not bool(_gs.call("_apply_revive_clawback")):
		_fail("revive should be available after the first Endless fall")
	change_scene_to_file("res://scenes/run/run_scene.tscn")
	await _frames(12)
	if absf(float(current_scene.get("_best_at_start")) - 265.0) > 0.01 or not bool(current_scene.call("is_new_best_live")):
		_fail("after revive the run should compare with 4:25 and keep 'New best!' (got %.0f)" % float(current_scene.get("_best_at_start")))
	current_scene.set("_state", 2)
	_gs.call("finish_run", {}, 3, true, 305.0, 0)
	if not bool(_gs.get("last_endless_new_best")) or absf(float(_gs.get("last_endless_prev_best")) - 265.0) > 0.01 			or absf(float(lp.endless_best_of("frost_orchard")) - 305.0) > 0.01:
		_fail("revived Endless: new best over 4:25 with 'Was 4:25', record 5:05")
	_gs.set("run_is_endless", false)


# --- 8 · Level Path ---

func _check_path() -> void:
	change_scene_to_file("res://scenes/run/run_scene.tscn")
	await _frames(4)
	var lp = _gs.get("level_path_domain")
	var view = load("res://scripts/ui/level_path_view.gd").new()
	get_root().add_child(view)
	await _frames(2)
	for id in SEASONS:
		lp.set_level(id, 12)
		view.show_season(id)
		var flags: Array = view.band_flag_rects()
		if flags.size() != 4:
			_fail("%s should have 4 band flags" % id)
		for i in flags.size():
			var r: Rect2 = flags[i]
			if r.position.x < 0.0 or r.end.x > LevelPathKit.W:
				_fail("%s flag %d off the path page" % [id, i + 1])
			for n in [5, 10, 15, 20]:
				var cr := Rect2(view.chest_node(n).position, view.chest_node(n).size)
				if r.grow(-20.0).intersects(cr):
					_fail("%s band flag %d covers chest %d" % [id, i + 1, n])
	# Spreman sanduk 10 (Pip na 12): closed → peek → closed u ciklusu; pločica sadržaja; dodir ispod.
	lp.claimed.erase("country_bloom")
	view.show_season("country_bloom")
	view.set_process(false)
	if view.chest_state(10) != "reward_ready" or view.chest_frame(10) != "closed":
		_fail("chest 10 should be ready on the closed frame")
	var frames := {}
	for i in 120:
		view.call("_process", DT)
		frames[view.chest_frame(10)] = true
	if not frames.has("peek") or not frames.has("closed"):
		_fail("ready chest should peek once per cycle, saw %s" % str(frames.keys()))
	var ch: Control = view.chest_node(10)
	var shadow := ch.get_node("ChestShadow") as CanvasItem
	if not shadow.visible:
		_fail("ready chest needs its separate shadow")
	if view.chest_frame(5) != "" and view.chest_state(5) != "reward_ready":
		_fail("only ready chests use the new frames")
	# Reduce motion: sanduk zatvoren i miran, iskre stoje vidljive.
	_gs.set("reduce_motion", true)
	lp.claimed.erase("amber_canopy")
	lp.set_level("amber_canopy", 12)
	view.show_season("amber_canopy")
	view.call("_process", DT)
	var rm: Control = view.chest_node(10)
	var art := rm.get_node("ChestArt") as Control
	var spark := rm.get_node("Spark0") as Control
	if view.chest_frame(10) != "closed" or absf(art.rotation) > 0.0001 or not spark.visible or absf(spark.modulate.a - 1.0) > 0.01:
		_fail("reduce motion: closed still chest with static sparks")
	_gs.set("reduce_motion", false)
	view.queue_free()
	await _frames(2)


# --- 9 · Endless dugme ---

func _check_endless_button() -> void:
	var lp = _gs.get("level_path_domain")
	lp.reset()
	lp.set_level("lantern_meadow", 9)
	if int(_gs.call("endless_progress", "lantern_meadow")) != 8:
		_fail("Pip on 9 = 8 / 15 passed")
	var host := Control.new()
	host.size = Vector2(236, 124)
	get_root().add_child(host)
	var face = load("res://scripts/ui/endless_button_face.gd").new()
	host.add_child(face)
	face.size = host.size
	face.apply(false, 8, 0.0)
	if face.progress_text() != "8 / 15" or face.best_text() != "":
		_fail("locked face should read 8 / 15 with no record")
	var early := [0]
	face.unlock_bubble_due.connect(func() -> void: early[0] += 1)
	await _wait(1.6)
	if face.unlocked or early[0] != 0 or face.is_animating():
		_fail("locked face must stay locked after loading (unlocked %s, bubbles %d)" % [str(face.unlocked), early[0]])
	face.play_locked_tap(host)
	await _wait(0.45)
	if face.is_animating() or absf(host.position.x) > 0.01:
		_fail("locked tap shake should settle in 0.3 s")
	face.apply(true, 15, 192.0)
	if face.best_text() != "3:12":
		_fail("open face should show the season record 3:12, got '%s'" % face.best_text())
	# Otključavanje: skok 15 → 16 na putu, jednom po sezoni.
	lp.set_level("lantern_meadow", 16)
	var view = load("res://scripts/ui/level_path_view.gd").new()
	get_root().add_child(view)
	await _frames(2)
	view.show_season("lantern_meadow", 15)
	var got: Array = []
	view.endless_unlocked.connect(func(id: String) -> void: got.append(id))
	view.play_hop(15, 16)
	await _wait(1.6)
	if got != ["lantern_meadow"]:
		_fail("hop 15 → 16 should announce the Endless unlock once, got %s" % str(got))
	view.show_season("lantern_meadow", 15)
	view.play_hop(15, 16)
	await _wait(1.6)
	if got.size() != 1:
		_fail("the unlock moment must play only once per season")
	var bubbles := early
	face.play_unlock(host)
	await _wait(1.6)
	if not face.unlocked or face.is_animating() or bubbles[0] != 1 or absf(host.position.x) > 0.01:
		_fail("unlock animation should end open with one bubble (unlocked %s, bubbles %d)" % [str(face.unlocked), bubbles[0]])
	view.queue_free()
	host.queue_free()
	await _frames(2)
