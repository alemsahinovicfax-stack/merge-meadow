extends Node

## AudioManager (autoload) — sav zvuk igre.
##   Efekti: pool AudioStreamPlayera na busu "SFX"; po zvuku cooldown, najviše glasova, grupa
##           (tab i swipe dijele jednu), slučajan pitch i „lanac" (coini / spajanja penju ton).
##   Muzika: svaka sezona ima tri teme — nivoi "home" (hub, loot), "arena", "run"; play_level()
##           bira temu aktivne sezone i sam pretopi kad se sezona promijeni (Home, Shop, Camp…).
##           Dva playera na busu "Music", crossfade, pamti mjesto svake teme (Arena → hub
##           nastavlja gdje je stala), utiša se (duck) na velike trenutke, pauza dok traje reklama
##           i dok je aplikacija u pozadini.
## Katalog: res://data/audio/sounds.json — generišu ga scripts/audio/sfx_gen.py i music_gen.py
## (db = pomak do ciljne glasnoće, "source": "real" = pravi zvuk koji generator ne dira).
## Glasnoća i mute su na busovima (Settings → UiSettings.apply), ovdje se ne diraju.

const CATALOG_PATH := "res://data/audio/sounds.json"
const POOL_SIZE := 12
const MUSIC_FADE := 0.9
const SILENT_DB := -60.0
const RECENT_MAX := 96
## Sezona čije teme sviraju kad aktivna nema svoju (i kad GameState ne postoji — testovi).
const DEFAULT_SEASON := "country_bloom"
## Koliko se tema drži u memoriji (OGG ~150–300 KB svaka); starije se puste.
const MUSIC_CACHE := 4
## Koliko često se provjerava aktivna sezona (s) — mijenja je više mjesta, signala nema.
const SEASON_POLL := 0.25

signal played(sound_id: String)

## Za testove i debug: zadnji pušteni efekti (id), najnoviji na kraju.
var recent: Array[String] = []
var enabled: bool = true

var _sfx: Dictionary = {}
var _music: Dictionary = {}
var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _last_ms: Dictionary = {}
var _chain: Dictionary = {}
## Učitavanje u pozadini (perf 2026-10-14): sinhroni load() efekta je ~3 ms (do 10), teme ~13 ms —
## 4 efekta po frejmu na startu su dali huba +15–25 kasnih frejmova. Sad sve ide u thread, a
## efekti po jedan: red threadova je FIFO (greske-katalog #30) pa stranice huba ne čekaju iza
## 62 fajla. Efekat koji zatreba prije reda se učita odmah (~3 ms, samo prvi put).
var _sfx_queue: Array[String] = []
var _sfx_loading: String = ""
var _music_loading: Array[String] = []
var _music_players: Array[AudioStreamPlayer] = []
var _music_active: int = 0
var _music_id: String = ""
var _music_fade: float = MUSIC_FADE
## Nivo koji play_level() drži ("" = tema zadata direktno ili tišina) i sezona za koju je birana.
var _level: String = ""
var _season: String = ""
var _music_cached: Array[String] = []
var _music_base_db: float = 0.0
var _music_pos: Dictionary = {}
var _music_tween: Tween
var _duck_db: float = 0.0
var _duck_tween: Tween
var _ad_paused: bool = false
var _app_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_catalog()
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.name = "Sfx%d" % i
		p.bus = &"SFX"
		add_child(p)
		_pool.append(p)
	for i in 2:
		var m := AudioStreamPlayer.new()
		m.name = "Music%d" % i
		m.bus = &"Music"
		m.volume_db = SILENT_DB
		add_child(m)
		_music_players.append(m)
	for id in _sfx:
		for f in _sfx[id].get("files", []):
			_sfx_queue.append(str(f))
	# Prva tema: hub aktivne sezone (GameState je autoload prije ovoga, save je već učitan).
	_request_music(_music_path(track_for("home")))
	set_process(true)
	var poll := Timer.new()
	poll.name = "SeasonPoll"
	poll.wait_time = SEASON_POLL
	poll.autostart = true
	poll.timeout.connect(_on_season_poll)
	add_child(poll)
	# IAPManager je autoload poslije ovoga — veza tek kad su svi u stablu.
	call_deferred("_connect_services")


## Kupovina pravim novcem zvuči isto svuda (Shop, kartica sezone, Starter Pack); kupovina za coine
## (v1 bez IAP-a, IAPManager.buy_with_coins) zvuči kao coin kupovina u Looks.
func _connect_services() -> void:
	var iap := get_node_or_null("/root/IAPManager")
	if iap == null:
		return
	if not iap.purchase_completed.is_connected(_on_purchase_completed):
		iap.purchase_completed.connect(_on_purchase_completed)
		iap.purchase_failed.connect(_on_purchase_failed)


func _on_purchase_completed(_sku: String) -> void:
	var iap := get_node_or_null("/root/IAPManager")
	if iap != null and bool(iap.call("is_coin_purchase")):
		play("coins_spend")
		haptic(25)
		return
	play("purchase_ok")
	haptic(35)


## Odustao / nije prošlo = mekan pad; razlozi koje UI sam odbije (busy, već tvoje, fale coini —
## dugme / kartica sami sviraju „denied") su tihi.
func _on_purchase_failed(_sku: String, reason: String) -> void:
	if reason in ["busy", "already_owned", "unknown_sku", "test_locked", "expired", "unavailable", "need_coins"]:
		return
	play("purchase_fail")


func _process(_delta: float) -> void:
	for path in _music_loading.duplicate():
		if _collect(path):
			_music_loading.erase(path)
			_remember_music(path)
			if path == _music_path(_music_id):
				_start_music()
	if not _sfx_loading.is_empty():
		if not _collect(_sfx_loading):
			return
		_sfx_loading = ""
	while not _sfx_queue.is_empty() and _sfx_loading.is_empty():
		_sfx_loading = _request(_sfx_queue.pop_front())
	if _sfx_loading.is_empty() and _music_loading.is_empty():
		set_process(false)


## Traži fajl u threadu; "" = već je tu (ili ga nema) pa nema šta čekati.
func _request(path: String) -> String:
	if path.is_empty() or _streams.has(path):
		return ""
	if not ResourceLoader.exists(path) or not BackgroundLoad.request(path):
		_streams[path] = null
		return ""
	return path


func _request_music(path: String) -> void:
	if path.is_empty() or _music_loading.has(path):
		return
	if not _request(path).is_empty():
		_music_loading.append(path)
		set_process(true)


## true = fajl je gotov (u kešu, ili nije uspio); false = thread još radi.
func _collect(path: String) -> bool:
	if _streams.has(path):
		return true
	var status := ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		return false
	var res: Resource = ResourceLoader.load_threaded_get(path) if status == ResourceLoader.THREAD_LOAD_LOADED else null
	_streams[path] = res as AudioStream
	return true


func _load_catalog() -> void:
	if not FileAccess.file_exists(CATALOG_PATH):
		push_warning("AudioManager: %s missing — no sound" % CATALOG_PATH)
		return
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if raw is Dictionary:
		_sfx = (raw as Dictionary).get("sfx", {})
		_music = (raw as Dictionary).get("music", {})


func has_sound(sound_id: String) -> bool:
	return _sfx.has(sound_id)


func has_music(track_id: String) -> bool:
	return _music.has(track_id)


func sound_ids() -> Array:
	return _sfx.keys()


func music_ids() -> Array:
	return _music.keys()


## Efekat odmah. Ako je baš taj fajl u threadu (a red ispred njega može biti dug, #30), učita se
## zasebna kopija mimo keša umjesto da se čeka.
func _stream(path: String) -> AudioStream:
	if _streams.has(path):
		return _streams[path]
	if path == _sfx_loading or _music_loading.has(path):
		if _collect(path):
			return _streams[path]
		return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as AudioStream
	var s: AudioStream = load(path) as AudioStream if ResourceLoader.exists(path) else null
	_streams[path] = s
	return s


func _music_path(track_id: String) -> String:
	if track_id.is_empty() or not _music.has(track_id):
		return ""
	return str(_music[track_id].get("file", ""))


# ── efekti ────────────────────────────────────────────────────────────────────

## Pusti efekat. `step` ≥ 0 = korak lanca zadat izvana (npr. combo u Areni); −1 = lanac po vremenu
## iz kataloga (coini u runu). `pitch` i `volume_db` se množe / dodaju na katalog.
func play(sound_id: String, step: int = -1, pitch: float = 1.0, volume_db: float = 0.0) -> bool:
	if not enabled:
		return false
	var d: Dictionary = _sfx.get(sound_id, {})
	if d.is_empty():
		return false
	var now := Time.get_ticks_msec()
	var key := str(d.get("group", sound_id))
	if now - int(_last_ms.get(key, -100000)) < int(d.get("cooldown_ms", 0)):
		return false
	_last_ms[key] = now
	var files: Array = d.get("files", [])
	if files.is_empty():
		return false
	var stream := _stream(str(files[randi() % files.size()]))
	if stream == null:
		return false
	var p := _voice_for(sound_id, int(d.get("max", 2)))
	var pr: Array = d.get("pitch", [1.0, 1.0])
	var semis := _chain_semis(sound_id, d, now, step)
	p.stream = stream
	p.pitch_scale = pitch * randf_range(float(pr[0]), float(pr[1])) * pow(2.0, semis / 12.0)
	p.volume_db = float(d.get("db", 0.0)) + volume_db
	p.set_meta("sfx", sound_id)
	p.play()
	if d.has("duck"):
		var duck_def: Array = d["duck"]
		duck(float(duck_def[0]), float(duck_def[1]))
	_note(sound_id)
	return true


func _chain_semis(sound_id: String, d: Dictionary, now: int, step: int) -> float:
	var ch: Dictionary = d.get("chain", {})
	if ch.is_empty():
		return 0.0
	var max_steps := int(ch.get("max_steps", 6))
	var k: int
	if step >= 0:
		k = mini(step, max_steps)
	else:
		var st: Dictionary = _chain.get(sound_id, {"at": -100000, "k": -1})
		k = int(st["k"]) + 1 if now - int(st["at"]) <= int(ch.get("window_ms", 600)) else 0
		k = mini(k, max_steps)
		_chain[sound_id] = {"at": now, "k": k}
	return float(k * int(ch.get("step", 1)))


## Slobodan player; ako isti zvuk već svira `max` puta, uzme se najstariji od njih.
func _voice_for(sound_id: String, max_voices: int) -> AudioStreamPlayer:
	var same: Array[AudioStreamPlayer] = []
	var free: AudioStreamPlayer = null
	var oldest: AudioStreamPlayer = null
	var oldest_pos := -1.0
	for p in _pool:
		if p.playing:
			if str(p.get_meta("sfx", "")) == sound_id:
				same.append(p)
			var pos := p.get_playback_position()
			if pos > oldest_pos:
				oldest_pos = pos
				oldest = p
		elif free == null:
			free = p
	if same.size() >= maxi(1, max_voices):
		var steal := same[0]
		for p in same:
			if p.get_playback_position() > steal.get_playback_position():
				steal = p
		return steal
	if free != null:
		return free
	return oldest if oldest != null else _pool[0]


func _note(sound_id: String) -> void:
	recent.append(sound_id)
	if recent.size() > RECENT_MAX:
		recent.remove_at(0)
	played.emit(sound_id)


## Kratka vibracija uz zvuk (poštuje Settings → Vibration).
func haptic(ms: int = 30) -> void:
	UiSettings.vibrate(ms)


func stop_all_sfx() -> void:
	for p in _pool:
		p.stop()


# ── muzika ────────────────────────────────────────────────────────────────────

func current_music() -> String:
	return _music_id


func current_level() -> String:
	return _level


## Tema nivoa za sezonu (prazno = aktivna): "<sezona>_<nivo>", inače ista tema prve sezone.
func track_for(level: String, season_id: String = "") -> String:
	var season := season_id if not season_id.is_empty() else _active_season()
	var id := "%s_%s" % [season, level]
	if _music.has(id):
		return id
	id = "%s_%s" % [DEFAULT_SEASON, level]
	if _music.has(id):
		return id
	for k in _music:
		if str(_music[k].get("level", "")) == level:
			return str(k)
	return ""


## Nivo muzike (home / arena / run) — tema aktivne sezone; prati promjenu sezone.
func play_level(level: String, fade: float = MUSIC_FADE) -> void:
	_level = level
	_season = _active_season()
	_play_track(track_for(level, _season), fade)


func _active_season() -> String:
	var gs := get_node_or_null("/root/GameState")
	if gs == null:
		return DEFAULT_SEASON
	var id := str(gs.get("active_season_id"))
	return id if not id.is_empty() else DEFAULT_SEASON


func _on_season_poll() -> void:
	if _level.is_empty():
		return
	if _active_season() != _season:
		play_level(_level)


## Keš tema: najviše MUSIC_CACHE; najstarija koja ne svira se pusti (player drži svoju).
func _remember_music(path: String) -> void:
	_music_cached.erase(path)
	_music_cached.append(path)
	while _music_cached.size() > MUSIC_CACHE:
		var old: String = _music_cached.pop_front()
		_streams.erase(old)


## Tema po id-u (testovi, posebni ekrani); "" = tišina. Isključuje praćenje sezone (play_level).
func play_music(track_id: String, fade: float = MUSIC_FADE) -> void:
	_level = ""
	_play_track(track_id, fade)


## Tema s crossfadeom; "" = tišina. Ista tema = ništa. Svaka tema nastavlja gdje je stala.
## Fajl teme se učitava u threadu (~13 ms sinhrono): stara odmah počne da se gasi, nova uđe
## čim je fajl tu (obično frejm-dva kasnije).
func _play_track(track_id: String, fade: float = MUSIC_FADE) -> void:
	if track_id == _music_id:
		return
	# Mjesto pamti tema koju player stvarno svira (ne `_music_id` — nova tema možda još nije stigla).
	var old := _music_players[_music_active]
	var playing_id := str(old.get_meta("track", ""))
	if not playing_id.is_empty() and old.playing:
		_music_pos[playing_id] = old.get_playback_position()
	_music_id = track_id
	_music_fade = fade
	_request_music(_music_path(track_id))
	_start_music()


## Crossfade na `_music_id`; bez fajla (još se učitava, ili tišina) samo gasi staru.
func _start_music() -> void:
	var fade := _music_fade
	var old := _music_players[_music_active]
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = create_tween().set_parallel(true)
	if old.playing:
		_music_tween.tween_property(old, "volume_db", SILENT_DB, fade)
	var d: Dictionary = _music.get(_music_id, {})
	var path := _music_path(_music_id)
	var stream: AudioStream = _streams.get(path, null) if not path.is_empty() else null
	if stream != null:
		if stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = bool(d.get("loop", true))
		_music_active = 1 - _music_active
		var nxt := _music_players[_music_active]
		_music_base_db = float(d.get("db", 0.0))
		nxt.stream = stream
		nxt.set_meta("track", _music_id)
		nxt.volume_db = SILENT_DB
		nxt.play(float(_music_pos.get(_music_id, 0.0)))
		nxt.stream_paused = _ad_paused or _app_paused
		# Crossfade: nova raste dok stara pada; stara staje tek na kraju.
		_music_tween.tween_property(nxt, "volume_db", _music_base_db + _duck_db, fade)
	var keep := _music_players[_music_active] if stream != null else null
	_music_tween.chain().tween_callback(func() -> void:
		for p in _music_players:
			if p != keep:
				p.stop()
	)


## Muzika se utiša za `amount_db` i vrati za `hold` s (T3, kupovina, cilj runa).
func duck(amount_db: float, hold: float) -> void:
	if _duck_tween != null and _duck_tween.is_valid():
		_duck_tween.kill()
	_duck_tween = create_tween()
	_duck_tween.tween_method(_set_duck, _duck_db, amount_db, 0.06)
	_duck_tween.tween_interval(hold * 0.5)
	_duck_tween.tween_method(_set_duck, amount_db, 0.0, hold * 0.5)


func _set_duck(value: float) -> void:
	_duck_db = value
	if _music_id.is_empty():
		return
	var p := _music_players[_music_active]
	if _music_tween != null and _music_tween.is_running():
		return
	p.volume_db = _music_base_db + _duck_db


## Reklama (AdManager): muzika stoji dok traje, pa nastavi.
func set_ad_playing(on: bool) -> void:
	_ad_paused = on
	_apply_pause()


func _apply_pause() -> void:
	for p in _music_players:
		p.stream_paused = _ad_paused or _app_paused


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			_app_paused = true
			_apply_pause()
		NOTIFICATION_APPLICATION_RESUMED:
			_app_paused = false
			_apply_pause()


func is_music_paused() -> bool:
	return _ad_paused or _app_paused
