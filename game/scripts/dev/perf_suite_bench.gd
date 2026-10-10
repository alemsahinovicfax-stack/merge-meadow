extends SceneTree

## Dev: FPS i štekanje kroz cijelu igru (pravi hub 1080 × 1920 u SubViewportu, vsync isključen).
## Za svaki scenarij: prosjek, p95, p99, najgori frejm, broj frejmova > 16,7 ms i > 33 ms,
## draw pozivi i vrijeme skripti (TIME_PROCESS). Scenariji:
##   save        — cijena jednog save_player_save() (JSON + disk), Arena ga zove pri mergeu
##   hub_boot_5s — prvih 5 s na Homeu (ostale stranice se grade u pozadini)
##   hub_*       — svaka stranica u mirovanju + prvi ulaz (učitavanje / kompajliranje)
##   swipe       — animirani prelazi između stranica
##   home_open   — otvaranje i zatvaranje polja sezone
##   arena_*     — mirno polje, sipanje, spajanje (stvarni drag → merge → combo), muncher jede,
##                 usisavanje ostataka
##   run         — run s promjenom staze svakih 0,7 s (pickupi, grm, burst)
##   loot        — loot ekran posle runa
## Filter: MM_ONLY=arena,run (početak imena scenarija). MM_ROOT=1 crta u prozor igre (540 × 960,
## kao na laptopu) umjesto SubViewporta 1080 × 1920; MM_VSYNC=1 ostavlja vsync (60 Hz) — tada je
## frejm > 20 ms stvarno preskočen frejm. Kolone cpu / gpu = vrijeme renderovanja viewporta.
## Pokretanje BEZ --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/perf_suite_bench.gd
## Save se vraća na kraju (CampSmokeUtil).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const HUB_SCENE := "res://scenes/meta/meta_hub.tscn"
const RUN_SCENE := "res://scenes/run/run_scene.tscn"
const LOOT_SCENE := "res://scenes/ui/loot_screen.tscn"

var _backup := ""
var _svp: SubViewport
var _host: Node
var _vp_rid: RID
var _gs: Node
var _only: PackedStringArray = []
var _rows: Array[String] = []
var _vsync := false


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _wants(name: String) -> bool:
	if _only.is_empty():
		return true
	for o in _only:
		if name.begins_with(o):
			return true
	return false


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _secs(s: float) -> void:
	await create_timer(s).timeout


## Mjeri `seconds`; `step(t)` se zove prije svakog frejma (t = sekunde od početka).
func _sample(label: String, seconds: float, step: Callable = Callable()) -> void:
	var dts: Array[float] = []
	var start := Time.get_ticks_usec()
	var last := start
	var calls := 0.0
	var cpu := 0.0
	var gpu := 0.0
	var gpu_max := 0.0
	while Time.get_ticks_usec() - start < int(seconds * 1000000.0):
		if step.is_valid():
			step.call(float(Time.get_ticks_usec() - start) / 1000000.0)
		await process_frame
		var now := Time.get_ticks_usec()
		dts.append(float(now - last) / 1000.0)
		last = now
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		cpu += RenderingServer.viewport_get_measured_render_time_cpu(_vp_rid)
		var g := RenderingServer.viewport_get_measured_render_time_gpu(_vp_rid)
		gpu += g
		gpu_max = maxf(gpu_max, g)
	var n := dts.size()
	var sorted := dts.duplicate()
	sorted.sort()
	var total := 0.0
	var over16 := 0
	var over33 := 0
	var limit := 20.0 if _vsync else 16.7
	for d in dts:
		total += d
		if d > limit:
			over16 += 1
		if d > 33.3:
			over33 += 1
	var row := "PERF %-30s avg %5.2f  p95 %5.2f  p99 %6.2f  max %6.2f  >%dms %3d  >33ms %3d  n %4d  draw %4.0f  cpu %5.2f  gpu %5.2f/%5.2f" % [
		label, total / n, sorted[int(n * 0.95)], sorted[mini(n - 1, int(n * 0.99))], sorted[n - 1],
		int(limit), over16, over33, n, calls / n, cpu / n, gpu / n, gpu_max
	]
	print(row)
	_rows.append(row)


func _run() -> void:
	Engine.max_fps = 0
	OS.low_processor_usage_mode = false
	_vsync = OS.get_environment("MM_VSYNC") == "1"
	if not _vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var only := OS.get_environment("MM_ONLY")
	if not only.is_empty():
		_only = only.split(",")
	_gs = get_root().get_node("GameState")
	_base_state()
	if OS.get_environment("MM_ROOT") == "1":
		_host = get_root()
		_vp_rid = get_root().get_viewport_rid()
	else:
		_svp = SubViewport.new()
		_svp.size = Vector2i(1080, 1920)
		_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		get_root().add_child(_svp)
		_host = _svp
		_vp_rid = _svp.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(_vp_rid, true)
	print("perf_suite: %s, vsync %s" % ["window 540x960" if _svp == null else "SubViewport 1080x1920", str(_vsync)])
	if _wants("save"):
		_save_cost()
	if _wants("hub") or _wants("swipe") or _wants("home") or _wants("arena") or _wants("camp") \
			or _wants("journal") or _wants("shop"):
		await _hub_suite()
	if _wants("run") or _wants("loot"):
		await _run_suite()
	print("---- PERF SUMMARY ----")
	for r in _rows:
		print(r)
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _base_state() -> void:
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("tutorial_complete", true)
	_gs.set("wallet_coins", 420)
	_gs.set("seed_bag", {"clover": 24, "daisy": 20, "buttercup": 16, "tulip": 12})


func _save_cost() -> void:
	var t := 0
	var worst := 0
	for _i in 20:
		var a := Time.get_ticks_usec()
		_gs.call("save_player_save")
		var d := Time.get_ticks_usec() - a
		t += d
		worst = maxi(worst, d)
	var row := "PERF %-30s avg %5.2f ms  max %5.2f ms  (bytes %d)" % [
		"save_player_save()", t / 20000.0, worst / 1000.0,
		FileAccess.get_file_as_string("user://player_save.json").length()
	]
	print(row)
	_rows.append(row)


func _page(hub: Node, index: int) -> Node:
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	return host.get_node_or_null("Page_%d" % index)


func _arena_ctrl(hub: Node) -> Node:
	var arena := _page(hub, MetaHubPages.ARENA)
	if arena != null and arena.has_method("_on_bag_clicked"):
		return arena
	for n in arena.find_children("*", "", true, false):
		if n.has_method("_on_bag_clicked"):
			return n
	return null


func _hub_suite() -> void:
	var t0 := Time.get_ticks_usec()
	var hub := (load(HUB_SCENE) as PackedScene).instantiate()
	_host.add_child(hub)
	await _frames(2)
	var load_row := "PERF %-30s %6.1f ms (instantiate + 2 frames)" % ["hub_load", (Time.get_ticks_usec() - t0) / 1000.0]
	print(load_row)
	_rows.append(load_row)
	# Igrač gleda Home dok se Shop, Arena i cvijeće ostalih sezona grade u pozadini
	# (2026-10-10: Shop je tu bio jedan frejm od ~0,5 s).
	await _sample("hub_boot_5s", 5.0)
	var order := [MetaHubPages.MAIN, MetaHubPages.CAMP, MetaHubPages.ARENA, MetaHubPages.COLLECTION, MetaHubPages.SHOP]
	for idx in order:
		var name := str(MetaHubPages.PAGE_LABELS[idx]).to_lower()
		if not _wants("hub"):
			break
		hub.call("go_to_page", idx, false)
		await _sample("hub_%s_first_1s" % name, 1.0)
		await _sample("hub_%s_idle" % name, 3.0)
	if _wants("swipe"):
		var st := {"next": 0.0, "i": 0}
		await _sample("swipe_pages", 6.0, func(t: float) -> void:
			if t >= st["next"]:
				st["next"] = t + 0.6
				st["i"] = int(st["i"]) + 1
				hub.call("go_to_page", order[int(st["i"]) % order.size()], true))
	if _wants("home"):
		hub.call("go_to_page", MetaHubPages.MAIN, false)
		await _frames(10)
		var stage: Node = _page(hub, MetaHubPages.MAIN).get_node("%SeasonStage")
		var hs := {"next": 0.0, "open": false}
		await _sample("home_open_close", 6.0, func(t: float) -> void:
			if t >= hs["next"]:
				hs["next"] = t + 1.2
				if hs["open"]:
					stage.call("close_season_field", true)
				else:
					stage.call("open_season_field", "", true)
				hs["open"] = not hs["open"])
		stage.call("close_season_field", false)
		await _frames(20)
		var ids: Array[String] = []
		for d in SeasonCatalog.all_defs():
			ids.append(d.id)
		var ss := {"next": 0.0, "i": 0}
		await _sample("home_season_cards", 6.0, func(t: float) -> void:
			if t >= ss["next"]:
				ss["next"] = t + 0.6
				ss["i"] = int(ss["i"]) + 1
				stage.call("show_season", ids[int(ss["i"]) % ids.size()], true))
		stage.call("show_season", _gs.get("active_season_id"), false)
		await _frames(10)
		stage.call("open_season_field", "", false)
		await _frames(20)
		await _sample("home_field_idle", 4.0)
		var home := _page(hub, MetaHubPages.MAIN)
		var us := {"next": 0.0, "open": false}
		await _sample("home_upgrades_sheet", 5.0, func(t: float) -> void:
			if t >= us["next"]:
				us["next"] = t + 0.8
				home.call("_close_upgrades_sheet" if us["open"] else "_open_upgrades_sheet")
				us["open"] = not us["open"])
		home.call("_close_upgrades_sheet")
		await _frames(20)
		var ws := {"next": 0.0, "open": false}
		await _sample("home_wardrobe", 5.0, func(t: float) -> void:
			if t >= ws["next"]:
				ws["next"] = t + 1.0
				if ws["open"]:
					home.call("_close_wardrobe", true)
				else:
					home.call("_open_wardrobe")
				ws["open"] = not ws["open"])
		home.call("_close_wardrobe", false)
		stage.call("close_season_field", false)
		await _frames(10)
	if _wants("camp"):
		hub.call("go_to_page", MetaHubPages.CAMP, false)
		await _frames(20)
		var camp := _page(hub, MetaHubPages.CAMP)
		var types := ["clover", "daisy", "buttercup", "tulip"]
		var cs := {"next": 0.0, "i": 0}
		await _sample("camp_chip_taps", 5.0, func(t: float) -> void:
			if t >= cs["next"]:
				cs["next"] = t + 0.3
				cs["i"] = int(cs["i"]) + 1
				camp.call("_on_seed_chip_pressed", types[int(cs["i"]) % types.size()]))
	for page_scroll in [[MetaHubPages.COLLECTION, "journal_scroll"], [MetaHubPages.SHOP, "shop_scroll"]]:
		if not _wants(str(page_scroll[1]).split("_")[0]):
			continue
		hub.call("go_to_page", page_scroll[0], false)
		await _frames(20)
		var scroll := _first_scroll(_page(hub, page_scroll[0]))
		if scroll == null:
			continue
		await _sample(str(page_scroll[1]), 5.0, func(t: float) -> void:
			var span := maxf(1.0, scroll.get_v_scroll_bar().max_value - scroll.size.y)
			scroll.scroll_vertical = int((0.5 - 0.5 * cos(t * 1.6)) * span))
	if _wants("arena"):
		await _arena_suite(hub)
	hub.queue_free()
	await _frames(4)


func _first_scroll(page: Node) -> ScrollContainer:
	if page == null:
		return null
	for n in page.find_children("*", "ScrollContainer", true, false):
		if (n as ScrollContainer).is_visible_in_tree():
			return n
	return null


func _arena_suite(hub: Node) -> void:
	hub.call("go_to_page", MetaHubPages.ARENA, false)
	await _frames(20)
	var ctrl := _arena_ctrl(hub)
	if ctrl == null:
		push_error("perf_suite: arena controller missing")
		return
	await _sample("arena_idle_empty", 2.0)
	_gs.set("seed_bag", {"clover": 24, "daisy": 20, "buttercup": 16, "tulip": 12})
	ctrl.call("_refresh_bag")
	await _sample("arena_pour", 2.5, _once(func() -> void: ctrl.call("_on_bag_clicked")))
	await _sample("arena_field_idle", 3.0)
	var ms := {"next": 0.0}
	await _sample("arena_merges", 8.0, func(t: float) -> void:
		if t >= ms["next"]:
			ms["next"] = t + 0.35
			if not _merge_one(ctrl):
				_gs.set("seed_bag", {"clover": 24, "daisy": 20, "buttercup": 16, "tulip": 12})
				ctrl.call("_refresh_bag")
				ctrl.call("_on_bag_clicked"))
	var dr := {"chip": null}
	await _sample("arena_drag_hold", 3.0, func(t: float) -> void:
		var chips: Array = ctrl.get("_chips")
		if dr["chip"] == null and not chips.is_empty():
			dr["chip"] = chips[0]
			(dr["chip"] as Node).call("_begin_drag", Vector2(60, 60))
		var c: Control = dr["chip"]
		if c != null and is_instance_valid(c):
			c.call("set_center", Vector2(540, 800) + Vector2(cos(t * 3.0), sin(t * 2.0)) * 260.0))
	if dr["chip"] != null and is_instance_valid(dr["chip"]):
		(dr["chip"] as Node).call("_end_drag")
	var pest: Node = ctrl.get("_pest")
	if pest != null:
		await _sample("arena_muncher_eats", 5.0, _once(func() -> void: pest.call("on_seeds_poured", true)))
	await _sample("arena_leftover_vacuum", 3.0, _once(func() -> void:
		if ctrl.has_method("_resolve_stranded_t2"):
			ctrl.call("_resolve_t3_starved_types")
			ctrl.call("_resolve_stranded_t2")))


func _once(f: Callable) -> Callable:
	var st := {"done": false}
	return func(_t: float) -> void:
		if not st["done"]:
			st["done"] = true
			f.call()


## Jedan stvarni merge: drag čipa na par istog tipa i tiera, pa release (combo, T3 trenutak…).
func _merge_one(ctrl: Node) -> bool:
	var chips: Array = ctrl.get("_chips")
	var by_key := {}
	for c in chips:
		if not is_instance_valid(c) or int(c.get("tier")) >= 3:
			continue
		var key := "%s_%d" % [c.get("type_id"), int(c.get("tier"))]
		if by_key.has(key):
			var a: Node = c
			var b: Node = by_key[key]
			a.call("_begin_drag", Vector2(60, 60))
			a.call("set_center", (b.call("get_center") as Vector2) + Vector2(12, 0))
			a.call("_end_drag")
			return true
		by_key[key] = c
	return false


## Hub je već oslobođen na kraju _hub_suite; u root modu root nosi i autoloade — ne dirati.
func _run_suite() -> void:
	await _frames(3)
	_gs.set("active_season_id", "country_bloom")
	_gs.call("begin_campaign_run")
	var run := (load(RUN_SCENE) as PackedScene).instantiate()
	_host.add_child(run)
	await _frames(30)
	if _wants("run"):
		run.set("_next_bush_at", 1.0)
		var player: Node = run.get_node("Player")
		# Bez pada: prepreka ne smije prekinuti mjerenje (go_to_scene bi zamijenio root).
		var hit := Callable(run, "_on_player_hit_obstacle")
		if player.is_connected("hit_obstacle", hit):
			player.disconnect("hit_obstacle", hit)
		var rs := {"next": 0.0, "dir": 1}
		await _sample("run_play", 12.0, func(t: float) -> void:
			if t >= rs["next"]:
				rs["next"] = t + 0.7
				var lane := int(player.get("lane_index")) + int(rs["dir"])
				if lane < 0 or lane > 2:
					rs["dir"] = -int(rs["dir"])
					lane = int(player.get("lane_index")) + int(rs["dir"])
				player.set("lane_index", lane)
				player.call("_apply_lane", true))
		var ps := {"next": 0.0, "open": false}
		await _sample("run_pause_modal", 4.0, func(t: float) -> void:
			if t >= ps["next"]:
				ps["next"] = t + 0.8
				run.call("_on_keep_running" if ps["open"] else "_on_pause_pressed")
				ps["open"] = not ps["open"])
		if bool(ps["open"]):
			run.call("_on_keep_running")
	run.queue_free()
	await _frames(3)
	if _wants("run"):
		# Najteža sezona za run (zvjezdana prašina + čestice).
		_gs.set("active_season_id", "starfall_glade")
		_gs.call("begin_campaign_run")
		var run2 := (load(RUN_SCENE) as PackedScene).instantiate()
		_host.add_child(run2)
		await _frames(30)
		var p2: Node = run2.get_node("Player")
		var hit2 := Callable(run2, "_on_player_hit_obstacle")
		if p2.is_connected("hit_obstacle", hit2):
			p2.disconnect("hit_obstacle", hit2)
		await _sample("run_play_starfall", 8.0)
		run2.queue_free()
		await _frames(3)
		_gs.set("active_season_id", "country_bloom")
	if _wants("loot"):
		_gs.call("finish_run", {"clover": 6, "daisy": 3}, 24, false, 60.0)
		var loot := (load(LOOT_SCENE) as PackedScene).instantiate()
		_host.add_child(loot)
		await _sample("loot_screen", 4.0)
		loot.queue_free()
		await _frames(3)
