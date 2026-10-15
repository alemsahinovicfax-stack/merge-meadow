extends SceneTree

## Zvuk (AudioManager + data/audio/sounds.json):
##   1. katalog: svaki efekat i tema imaju fajl koji se učita; ukupna veličina u budžetu; svaki
##      efekat se negdje u kodu pušta; svi se učitaju u pozadinskom threadu bez play();
##   2. svaki efekat se pusti; cooldown, grupa „nav" (tab preduhitri swipe), najviše glasova,
##      lanac tona (combo / coini penju ton);
##   3. muzika: tema, crossfade, ista tema = ništa, nastavak gdje je stala, duck, pauza za reklamu;
##      svaka sezona ima home / arena / run temu, play_level prati promjenu aktivne sezone;
##   4. kuke u igri: tap dugmeta, Pip sfx događaj, sipanje + slijetanje u Areni, led munchera,
##      Settings toggle, coin kupovina u Shopu, start runa (run_go + tema run).

## Izvorni fajlovi (WAV efekti ~2,7 MB + 24 sezonske teme OGG ~4,5 MB); u paketu je manje (QOA).
const AUDIO_BUDGET_KB := 8192
const SEASONS := ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
	"moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]
const LEVELS := ["home", "arena", "run"]

var _backup := ""
var _failed := false
var _am: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	if _failed:
		return
	_failed = true
	push_error("audio_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _played(sound_id: String) -> bool:
	return (_am.get("recent") as Array).has(sound_id)


func _clear_recent() -> void:
	(_am.get("recent") as Array).clear()


func _finish() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		quit(1)
		return
	print("audio_smoke OK")
	quit(0)


func _run() -> void:
	_am = root.get_node_or_null("AudioManager")
	if _am == null:
		_fail("AudioManager autoload missing")
		_finish()
		return
	if AudioServer.get_bus_index("Music") < 0 or AudioServer.get_bus_index("SFX") < 0:
		_fail("Music / SFX buses missing")
	_check_catalog()
	_check_call_sites()
	await _check_background_load()
	_check_sfx_rules()
	await _check_music()
	await _check_season_music()
	await _check_hooks()
	# Muzika koja svira u trenutku quit() ostane u AudioServeru (čisti je tek sljedeći frejm,
	# kog nema) → „resources still in use" pri izlasku. Utišaj i pusti ga da počisti.
	_am.call("play_music", "", 0.02)
	_am.call("stop_all_sfx")
	await create_timer(0.3).timeout
	_finish()


func _check_catalog() -> void:
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio/sounds.json"))
	if not raw is Dictionary:
		_fail("sounds.json unreadable")
		return
	var sfx: Dictionary = raw.get("sfx", {})
	var music: Dictionary = raw.get("music", {})
	if sfx.size() < 50:
		_fail("catalog too small: %d sfx" % sfx.size())
	for season in SEASONS:
		for level in LEVELS:
			if not music.has("%s_%s" % [season, level]):
				_fail("music %s_%s missing" % [season, level])
	var bytes := 0
	for id in sfx:
		var d: Dictionary = sfx[id]
		for f in d.get("files", []):
			if not ResourceLoader.exists(str(f)) or not (load(str(f)) is AudioStream):
				_fail("sfx %s file %s does not load" % [id, f])
			var fa := FileAccess.open(str(f), FileAccess.READ)
			if fa != null:
				bytes += fa.get_length()
		if float(d.get("db", 0.0)) > 0.5:
			_fail("sfx %s db %.1f would clip" % [id, float(d["db"])])
	for id in music:
		var f := str(music[id].get("file", ""))
		var s: Variant = load(f) if ResourceLoader.exists(f) else null
		if not s is AudioStreamOggVorbis:
			_fail("music %s does not load as OGG" % id)
		var fa := FileAccess.open(f, FileAccess.READ)
		if fa != null:
			bytes += fa.get_length()
	if bytes / 1024 > AUDIO_BUDGET_KB:
		_fail("audio is %d KB, budget %d KB" % [bytes / 1024, AUDIO_BUDGET_KB])
	print("audio_smoke: %d sfx, %d music, %d KB" % [sfx.size(), music.size(), bytes / 1024])
	# Pip događaji iz animations.json moraju imati zvuk.
	var anims: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/pip/animations.json"))
	for a in (anims as Dictionary).get("list", []):
		for ev in (a as Dictionary).get("events", []):
			var n := str(ev.get("name", ""))
			if n.begins_with("sfx:") and not sfx.has("pip_" + n.substr(4)):
				_fail("Pip event %s has no pip_%s sound" % [n, n.substr(4)])


## Svaki efekat iz kataloga se negdje pušta (ime kao string u kodu); pip_* idu kroz Pip
## događaje (provjereno gore), pa se ovdje preskaču.
func _check_call_sites() -> void:
	var code := ""
	for path in _gd_files("res://scripts"):
		if not path.begins_with("res://scripts/dev/"):
			code += FileAccess.get_file_as_string(path)
	for id in _am.call("sound_ids"):
		var sid := str(id)
		if not sid.begins_with("pip_") and not code.contains("\"%s\"" % sid):
			_fail("sound %s is in the catalog but nothing plays it" % sid)


func _gd_files(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	for f in dir.get_files():
		if f.ends_with(".gd"):
			out.append(dir_path.path_join(f))
	for d in dir.get_directories():
		out.append_array(_gd_files(dir_path.path_join(d)))
	return out


## Efekti se učitaju u threadu (po jedan, greske-katalog #30) bez ijednog poziva play();
## početna tema (home aktivne sezone) je tražena već u _ready.
func _check_background_load() -> void:
	var streams: Dictionary = _am.get("_streams")
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 8000:
		if str(_am.get("_sfx_loading")).is_empty() and (_am.get("_sfx_queue") as Array).is_empty() \
				and (_am.get("_music_loading") as Array).is_empty():
			break
		await process_frame
	var missing := 0
	for id in _am.call("sound_ids"):
		for f in (_am.get("_sfx") as Dictionary)[id].get("files", []):
			if not streams.get(str(f), null) is AudioStream:
				missing += 1
	if missing > 0:
		_fail("%d sfx files not preloaded in the background after %d ms" % [missing, Time.get_ticks_msec() - t0])
	var boot_id := str(_am.call("track_for", "home"))
	var boot_music := str((_am.get("_music") as Dictionary).get(boot_id, {}).get("file", ""))
	if not streams.get(boot_music, null) is AudioStream:
		_fail("boot theme (%s) should be loaded in the background" % boot_id)
	print("audio_smoke: background load %d ms" % (Time.get_ticks_msec() - t0))


func _check_sfx_rules() -> void:
	for id in _am.call("sound_ids"):
		_am.call("stop_all_sfx")
		_am.get("_last_ms").clear()
		if not bool(_am.call("play", str(id))):
			_fail("sfx %s did not play" % id)
	_am.call("stop_all_sfx")
	_am.get("_last_ms").clear()
	# cooldown
	_am.call("play", "ui_denied")
	if bool(_am.call("play", "ui_denied")):
		_fail("cooldown ignored (ui_denied twice in a row)")
	# grupa nav: tab pa swipe u istom trenutku = samo tab
	_am.get("_last_ms").clear()
	_am.call("play", "ui_tab")
	if bool(_am.call("play", "ui_swipe")):
		_fail("nav group: swipe should be swallowed right after a tab")
	# glasovi: seed_land max 3
	_am.get("_last_ms").clear()
	_am.call("stop_all_sfx")
	for _i in 6:
		_am.get("_last_ms").clear()
		_am.call("play", "seed_land")
	var voices := 0
	for p in _am.get("_pool"):
		if (p as AudioStreamPlayer).playing and str(p.get_meta("sfx", "")) == "seed_land":
			voices += 1
	if voices > 3:
		_fail("seed_land uses %d voices, max 3" % voices)
	# lanac: combo korak 4 = viši ton od koraka 0
	_am.call("stop_all_sfx")
	_am.get("_last_ms").clear()
	_am.call("play", "merge", 0)
	var low := _pitch_of("merge")
	_am.call("stop_all_sfx")
	_am.get("_last_ms").clear()
	_am.call("play", "merge", 4)
	var high := _pitch_of("merge")
	if high <= low * 1.15:
		_fail("combo chain should raise merge pitch (%.2f → %.2f)" % [low, high])
	_am.call("stop_all_sfx")


func _pitch_of(sound_id: String) -> float:
	for p in _am.get("_pool"):
		if (p as AudioStreamPlayer).playing and str(p.get_meta("sfx", "")) == sound_id:
			return (p as AudioStreamPlayer).pitch_scale
	return 0.0


const HOME := "country_bloom_home"
const ARENA := "country_bloom_arena"


func _check_music() -> void:
	_am.call("play_music", HOME, 0.05)
	await create_timer(0.2).timeout
	if str(_am.call("current_music")) != HOME:
		_fail("music should be the home theme")
	var players: Array = _am.get("_music_players")
	var on := 0
	for p in players:
		if (p as AudioStreamPlayer).playing:
			on += 1
	if on != 1:
		_fail("exactly one music player should play after the fade (%d)" % on)
	_am.call("play_music", HOME, 0.05)
	_am.call("play_music", ARENA, 0.05)
	await create_timer(0.25).timeout
	if str(_am.call("current_music")) != ARENA:
		_fail("music should crossfade to the arena theme")
	_am.call("duck", -8.0, 0.3)
	await create_timer(0.08).timeout
	if float(_am.get("_duck_db")) > -4.0:
		_fail("duck should lower the music")
	await create_timer(0.4).timeout
	if float(_am.get("_duck_db")) < -0.5:
		_fail("duck should come back")
	_am.call("set_ad_playing", true)
	if not bool(_am.call("is_music_paused")):
		_fail("music should pause for an ad")
	_am.call("set_ad_playing", false)
	if bool(_am.call("is_music_paused")):
		_fail("music should resume after the ad")
	_am.call("play_music", "", 0.05)
	await create_timer(0.2).timeout
	for p in players:
		if (p as AudioStreamPlayer).playing:
			_fail("silence should stop both music players")
			break
	# Brzo tamo-nazad dok nova tema još nije stigla iz threada: mjesto hub teme ne smije
	# postati mjesto Arene (pamti ga tema koju player stvarno svira).
	_am.call("play_music", HOME, 0.05)
	await create_timer(0.4).timeout
	var music_pos: Dictionary = _am.get("_music_pos")
	var arena_pos_before := float(music_pos.get(ARENA, -1.0))
	var arena_file := str((_am.get("_music") as Dictionary)[ARENA]["file"])
	(_am.get("_streams") as Dictionary).erase(arena_file)
	_am.call("play_music", ARENA, 0.05)
	_am.call("play_music", HOME, 0.05)
	if not is_equal_approx(float(music_pos.get(ARENA, -1.0)), arena_pos_before):
		_fail("quick arena → meadow before arena loaded: arena position %.2f taken from meadow (was %.2f)"
				% [float(music_pos.get(ARENA, -1.0)), arena_pos_before])
	await create_timer(0.3).timeout
	if str(_am.call("current_music")) != HOME:
		_fail("music should be the home theme after the quick switch back")
	_am.call("play_music", "", 0.05)
	await create_timer(0.2).timeout


## Nivoi: play_level bira temu aktivne sezone i pretopi kad se sezona promijeni (bez novog poziva).
func _check_season_music() -> void:
	var gs := root.get_node("GameState")
	var keep := str(gs.get("active_season_id"))
	gs.set("active_season_id", "frost_orchard")
	_am.call("play_level", "home", 0.05)
	if str(_am.call("current_music")) != "frost_orchard_home":
		_fail("play_level(home) on Frost should play frost_orchard_home (%s)" % _am.call("current_music"))
	gs.set("active_season_id", "ember_fen")
	await create_timer(0.6).timeout
	if str(_am.call("current_music")) != "ember_fen_home":
		_fail("season change should crossfade to ember_fen_home (%s)" % _am.call("current_music"))
	_am.call("play_level", "arena", 0.05)
	if str(_am.call("current_music")) != "ember_fen_arena":
		_fail("play_level(arena) should play ember_fen_arena")
	if str(_am.call("track_for", "run", "no_such_season")) != "country_bloom_run":
		_fail("unknown season should fall back to country_bloom_run")
	# play_music (direktno / tišina) isključuje praćenje sezone
	_am.call("play_music", "", 0.05)
	gs.set("active_season_id", "coral_tide")
	await create_timer(0.6).timeout
	if not str(_am.call("current_music")).is_empty():
		_fail("silence must stay silent after a season change")
	# keš tema ostaje ograničen
	for season in SEASONS:
		gs.set("active_season_id", season)
		_am.call("play_level", "run", 0.02)
		await create_timer(0.12).timeout
	var cached := 0
	for k in (_am.get("_music") as Dictionary):
		var f := str((_am.get("_music") as Dictionary)[k]["file"])
		if (_am.get("_streams") as Dictionary).has(f):
			cached += 1
	var cache_max := int((_am.get_script() as GDScript).get_script_constant_map()["MUSIC_CACHE"])
	if cached > cache_max + 1:
		_fail("music cache keeps %d themes (max %d)" % [cached, cache_max])
	_am.call("play_music", "", 0.05)
	gs.set("active_season_id", keep)
	await create_timer(0.2).timeout


func _check_hooks() -> void:
	var gs := root.get_node("GameState")
	gs.set("tutorial_complete", true)
	gs.call("mark_arena_pest_tutorial_shown")
	# tap dugmeta
	_clear_recent()
	var btn: Control = (load("res://scripts/ui/hub_pressable.gd") as GDScript).new()
	root.add_child(btn)
	btn.call("_emit_clicked")
	if not _played("ui_tap"):
		_fail("HubPressable click should play ui_tap")
	btn.queue_free()
	# Pip sfx događaj (animations.json) → pip_sneeze
	_clear_recent()
	var pip: Node2D = (load("res://scripts/visual/ui_pip.gd") as GDScript).new()
	pip.set("follow_equipped", false)
	root.add_child(pip)
	pip.call("emit_event", "sfx:sneeze", null)
	if not _played("pip_sneeze"):
		_fail("Pip sfx:sneeze should play pip_sneeze")
	pip.set("still", true)
	_clear_recent()
	_am.get("_last_ms").clear()
	pip.call("emit_event", "sfx:sneeze", null)
	if _played("pip_sneeze"):
		_fail("a posed (still) Pip must stay silent")
	pip.queue_free()
	# Arena: sipanje + slijetanje + led munchera
	gs.set("seed_bag", {"clover": 16, "daisy": 12, "buttercup": 10, "tulip": 12})
	var arena: Node = (load("res://scenes/camp/merge_arena.tscn") as PackedScene).instantiate()
	root.add_child(arena)
	await _frames(12)
	_clear_recent()
	arena.call("_on_bag_clicked")
	await create_timer(1.2).timeout
	if not _played("pour") or not _played("seed_land"):
		_fail("pour should play pour + seed_land (%s)" % str(_am.get("recent")))
	if str(_am.call("current_music")).is_empty():
		pass
	var pest: Node = arena.get_node("RootVBox/Playfield/MuncherPest")
	for _i in 60:
		if pest.call("get_rig") != null:
			break
		await process_frame
	_clear_recent()
	pest.call("on_t3_created")
	await _frames(2)
	if not _played("muncher_freeze"):
		_fail("T3 should play muncher_freeze")
	arena.queue_free()
	await _frames(3)
	# Settings toggle
	var settings: Control = (load("res://scenes/ui/settings_screen.tscn") as PackedScene).instantiate()
	root.add_child(settings)
	await _frames(4)
	var cfg_backup := FileAccess.get_file_as_string("user://settings.cfg") if FileAccess.file_exists("user://settings.cfg") else ""
	_clear_recent()
	settings.call("_on_toggle", "reduce_motion")
	settings.call("_on_toggle", "reduce_motion")
	if not _played("ui_toggle_on") or not _played("ui_toggle_off"):
		_fail("settings toggle should click on / off (%s)" % str(_am.get("recent")))
	settings.queue_free()
	if cfg_backup.is_empty():
		DirAccess.remove_absolute("user://settings.cfg")
	else:
		FileAccess.open("user://settings.cfg", FileAccess.WRITE).store_string(cfg_backup)
	await _frames(2)
	# Shop: coin kupovina
	gs.set("wallet_coins", 500)
	(gs.get("cosmetics") as Object).set("owned", {})
	var shop: Control = (load("res://scenes/ui/shop_screen.tscn") as PackedScene).instantiate()
	root.add_child(shop)
	await _frames(20)
	_clear_recent()
	shop.call("_on_cosmetic_buy_confirmed", "meadow_sunset")
	if not _played("coins_spend"):
		_fail("coin purchase should play coins_spend")
	shop.queue_free()
	await _frames(3)
	# Run: start + tema
	gs.set("active_season_id", "country_bloom")
	gs.call("begin_campaign_run")
	_clear_recent()
	var run: Node = (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	root.add_child(run)
	await create_timer(0.6).timeout
	if not _played("run_go") or str(_am.call("current_music")) != "country_bloom_run":
		_fail("run should play run_go and the run theme (%s / %s)" % [str(_am.get("recent")), _am.call("current_music")])
	run.queue_free()
	await _frames(3)
