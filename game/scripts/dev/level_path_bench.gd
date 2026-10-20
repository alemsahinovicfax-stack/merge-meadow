extends SceneTree

## Dev: cijena Level Patha (design_handoff_level_path) u pravom hubu 1080 × 1920, vsync
## isključen. Osnovica je polje sezone (ekran koji je Play otvarao do sada).
## Scenariji (MM_ONLY filtrira po početku imena):
##   lp_field      — polje sezone otvoreno (osnovica: livada, cvijeće, Pip, ambijent)
##   lp_path       — put otvoren, Pip idle, 1 reward_ready sanduk
##   lp_ready4     — put završen bez uzetih nagrada: 4 reward_ready (poskok + 12 iskri)
##   lp_scroll     — skrol kroz cijeli put tamo-amo (1,6 ekrana / s)
##   lp_hop        — skok Pipa svakih 1,2 s (prašina, prsten, pop)
##   lp_popup      — popup nagrade + Claim + let 3 + 4 u bar, u krug
##   lp_popup20    — nagrada 20: 5 + 5 letača + 6 konfeta, u krug
##   lp_trans      — prelaz polje ↔ put u krug
## Sezone: MM_SEASONS (zarezom), inače country_bloom, moonlit_warren, starfall_glade.
## Pokretanje BEZ --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/level_path_bench.gd

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const DEFAULT_SEASONS := ["country_bloom", "moonlit_warren", "starfall_glade"]
const SEC := 4.0

var _backup := ""
var _svp: SubViewport
var _vp_rid: RID
var _gs: Node
var _hub: Node
var _home: Node
var _stage: Node
var _only: PackedStringArray = []
var _rows: Array[String] = []


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _wants(label: String) -> bool:
	if _only.is_empty():
		return true
	for o in _only:
		if label.begins_with(o):
			return true
	return false


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(sec * 1000.0):
		await process_frame


func _sample(label: String, seconds: float, step: Callable = Callable()) -> void:
	var dts: Array[float] = []
	var start := Time.get_ticks_usec()
	var last := start
	var calls := 0.0
	var prims := 0.0
	var cpu := 0.0
	var proc := 0.0
	while Time.get_ticks_usec() - start < int(seconds * 1000000.0):
		if step.is_valid():
			step.call(float(Time.get_ticks_usec() - start) / 1000000.0)
		await process_frame
		var now := Time.get_ticks_usec()
		dts.append(float(now - last) / 1000.0)
		last = now
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		prims += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
		cpu += RenderingServer.viewport_get_measured_render_time_cpu(_vp_rid)
		proc += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var n := dts.size()
	var sorted := dts.duplicate()
	sorted.sort()
	var total := 0.0
	var over16 := 0
	for d in dts:
		total += d
		if d > 16.7:
			over16 += 1
	var row := "PERF %-28s avg %5.2f  p95 %5.2f  p99 %6.2f  max %6.2f  >16ms %3d  n %4d  draw %5.1f  prim %7.0f  script %5.2f  cpu %5.2f" % [
		label, total / n, sorted[int(n * 0.95)], sorted[mini(n - 1, int(n * 0.99))], sorted[n - 1],
		over16, n, calls / n, prims / n, proc / n, cpu / n
	]
	print(row)
	_rows.append(row)


func _run() -> void:
	Engine.max_fps = 0
	OS.low_processor_usage_mode = false
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var only := OS.get_environment("MM_ONLY")
	if not only.is_empty():
		_only = only.split(",")
	var seasons: Array = DEFAULT_SEASONS
	if OS.get_environment("MM_SEASONS") != "":
		seasons = Array(OS.get_environment("MM_SEASONS").split(","))
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("tutorial_complete", true)
	_gs.call("reset_seasons_to_s1")
	var unlocked: Array = _gs.get("unlocked_seasons")
	for id in ["frost_orchard", "lantern_meadow", "amber_canopy"]:
		if not unlocked.has(id):
			unlocked.append(id)
	var owned: Array = _gs.get("owned_paid_seasons")
	for id in ["moonlit_warren", "coral_tide", "starfall_glade"]:
		if not owned.has(id):
			owned.append(id)
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	_vp_rid = _svp.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(_vp_rid, true)
	_hub = (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(_hub)
	await _frames(30)
	_hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	var host: Node = _hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	_home = host.get_node("Page_%d" % MetaHubPages.MAIN)
	_stage = _home.get_node("%SeasonStage")
	for season in seasons:
		await _suite(str(season))
	print("---- PERF SUMMARY ----")
	for r in _rows:
		print(r)
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _domain() -> LevelPathDomain:
	return _gs.get("level_path_domain") as LevelPathDomain


func _open_field(id: String) -> void:
	if bool(_stage.call("is_level_path_open")):
		_stage.call("close_level_path", false)
	_stage.call("close_season_field", false)
	await _frames(3)
	_gs.call("set_active_season", id)
	_stage.call("show_season", id, false)
	await _frames(3)
	_stage.call("open_season_field", id, false)
	await _frames(10)


func _open_path(id: String, level: int, claimed: Array) -> Object:
	_domain().set_level(id, level)
	var list: Array[int] = []
	for n in claimed:
		list.append(int(n))
	_domain().claimed[id] = list
	await _open_field(id)
	_stage.call("open_level_path", false)
	await _frames(20)
	return _stage.get("level_path")


func _suite(id: String) -> void:
	_gs.set("level_path_hop", {})
	if _wants("lp_field"):
		await _open_field(id)
		await _wait(1.0)
		await _sample("lp_field %s" % id, SEC)
	if _wants("lp_path"):
		var p = await _open_path(id, 7, [])
		await _wait(1.0)
		await _sample("lp_path %s" % id, SEC)
	if _wants("lp_ready4"):
		var p = await _open_path(id, 21, [])
		p.set_scroll(LevelPathKit.SCROLL_MAX * 0.5)
		await _wait(1.0)
		await _sample("lp_ready4 %s" % id, SEC)
	if _wants("lp_scroll"):
		var p = await _open_path(id, 7, [5])
		await _sample("lp_scroll %s" % id, SEC, func(t: float) -> void:
			p.set_scroll(LevelPathKit.SCROLL_MAX * (0.5 - 0.5 * cos(t * 1.6 * 1920.0 / LevelPathKit.SCROLL_MAX * PI)))
		)
	if _wants("lp_hop"):
		var p = await _open_path(id, 3, [])
		var state := {"next": 0.0, "lv": 3}
		await _sample("lp_hop %s" % id, SEC, func(t: float) -> void:
			if t >= float(state["next"]) and not p.is_busy():
				var lv := int(state["lv"])
				if lv >= 9:
					lv = 3
					p.show_season(id, lv)
				_domain().set_level(id, lv + 1)
				p.play_hop(lv, lv + 1)
				state["lv"] = lv + 1
				state["next"] = t + 1.2
		)
	if _wants("lp_popup"):
		await _popup_loop(id, 5, "lp_popup %s" % id)
	if _wants("lp_popup20"):
		await _popup_loop(id, 20, "lp_popup20 %s" % id)
	if _wants("lp_trans"):
		await _open_path(id, 7, [5])
		_stage.call("close_level_path", false)
		await _frames(5)
		await _sample("lp_trans %s" % id, SEC, func(_t: float) -> void:
			if bool(_stage.call("is_busy")):
				return
			if bool(_stage.call("is_level_path_open")):
				_stage.call("close_level_path")
			else:
				_stage.call("open_level_path")
		)


func _popup_loop(id: String, n: int, label: String) -> void:
	var p = await _open_path(id, 21, [])
	var popup = p.get_popup()
	var state := {"phase": 0, "at": 0.0}
	await _sample(label, SEC, func(t: float) -> void:
		if popup.is_busy():
			if popup.is_open() and int(state["phase"]) == 1 and t >= float(state["at"]):
				popup.claim()
				state["phase"] = 2
			return
		var list: Array[int] = []
		_domain().claimed[id] = list
		p.show_season(id, 21)
		p.tap_reward(n)
		state["phase"] = 1
		state["at"] = t + 0.35
	)
