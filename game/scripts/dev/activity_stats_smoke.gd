extends SceneTree

## RET-01 — skriveni ekran statistike u pravom hubu (headless):
##  1. 4 dodira na verziju ne otvaraju ništa, 5. otvara StatsPage (naslov „Your stats");
##  2. D1 / D3 ✓, D7 / D14 / D30 „Later" za log od prije 3 dana (dan 2 propušten);
##  3. traka prvih 14 dana i „Days played: 3 of 4";
##  4. Copy tekst = mm1 red sa 14 polja i nizom dana 1101-…;
##  5. X vraća Settings, drugi X zatvara.
## Save se vraća na kraju (log je samo u memoriji + kopija savea).

const HEADER_GEAR := "RootVBox/TopBar/Panel/HBox/SettingsButton"

var _backup := ""
var _fails := 0


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	_fails += 1
	push_error("activity_stats_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _seed_log(gs: Node) -> void:
	var now := int(Time.get_unix_time_from_system())
	var first := ActivityLog.local_day_key(now - 3 * 86400)
	var act: ActivityLog = gs.get("activity")
	act.apply_from_save({"activity": {
		"v": 1, "first_day": first, "since": 0,
		"days": [
			{"d": 0, "s": 2, "sec": 600, "r": 6, "lv": 4, "se": "country_bloom"},
			{"d": 1, "s": 1, "sec": 300, "r": 3, "lv": 5, "se": "country_bloom"},
			{"d": 3, "s": 1, "sec": 120, "r": 1, "lv": 6, "se": "country_bloom"},
		],
		"last_day": 3, "tot": {"s": 4, "sec": 1020, "r": 10},
		"tut_day": 0, "end_day": -1, "merge_sec": 200,
		"best": {"se": "country_bloom", "lv": 5},
	}})
	var today: String = gs.call("_today_key")
	if act.day_index(today) != 3:
		_fail("seeded log should be on day 3, got %d (first_day %s, today %s)" % [act.day_index(today), first, today])


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	_seed_log(gs)
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	get_root().add_child(hub)
	await _frames(30)
	(hub.get_node(HEADER_GEAR) as Control).emit_signal("clicked")
	await create_timer(0.6).timeout
	var screen := hub.get_node_or_null("SettingsScreen")
	if screen == null:
		_fail("gear did not open SettingsScreen")
		_finish()
		return
	var row := screen.find_child("VersionRow", true, false)
	var page := screen.find_child("StatsPage", true, false) as Control
	if row == null or page == null:
		_fail("missing VersionRow or StatsPage")
		_finish()
		return
	for _i in 4:
		row.emit_signal("tapped")
	await _frames(2)
	if page.visible:
		_fail("4 taps must not open stats")
	row.emit_signal("tapped")
	await _frames(4)
	if not page.visible:
		_fail("5 taps did not open StatsPage")
	var title := screen.find_child("Title", true, false) as Label
	if title == null or title.text != "Your stats":
		_fail("bar title should say Your stats")
	_check_cells(page)
	var played := page.find_child("StatsDaysPlayed", true, false) as Label
	if played == null or played.text != "Days played: 3 of 4":
		_fail("days played text: %s" % (played.text if played else "missing"))
	if page.find_child("StripDay_13", true, false) == null:
		_fail("strip should show 14 days")
	if page.find_child("StatsCopy", true, false) == null:
		_fail("missing Copy button")
	var text := str(screen.call("stats_copy_text"))
	var cells := text.split(",")
	if not text.begins_with("mm1,") or cells.size() != 14:
		_fail("copy text is not an mm1 row: %s" % text)
	elif cells[3] != "1101" + "-".repeat(27):
		_fail("days string %s" % cells[3])
	elif cells[4] != "4" or cells[6] != "10" or cells[11] != "200":
		_fail("totals in copy row: %s" % text)
	var close := screen.find_child("CloseButton", true, false) as Control
	close.emit_signal("clicked")
	await _frames(2)
	if page.visible or not (screen.get_node("ScrollBody") as Control).visible:
		_fail("X on stats should go back to Settings")
	close.emit_signal("clicked")
	await create_timer(0.6).timeout
	if is_instance_valid(screen) and screen.visible:
		_fail("second X did not close Settings")
	_finish()


func _check_cells(page: Control) -> void:
	var want := {"D1": "played", "D3": "played", "D7": "later", "D14": "later", "D30": "later"}
	for key in want:
		var chip := page.find_child("StatsDay_%s" % key, true, false)
		if chip == null:
			_fail("missing chip %s" % key)
		elif str(chip.get_meta("state", "")) != str(want[key]):
			_fail("%s is %s, expected %s" % [key, chip.get_meta("state", ""), want[key]])


func _finish() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if _fails == 0:
		print("activity_stats_smoke OK")
	quit(_fails)
