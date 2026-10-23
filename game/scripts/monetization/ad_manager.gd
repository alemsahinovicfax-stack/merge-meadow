extends Node

## Reklame — stub na desktopu / u editoru; Poing AdMob (admob_backend.gd) + UMP pristanak na Androidu.
## Rewarded (×2 loot, revive) bira igrač i ostaje i poslije Remove Ads (Pillar 2).
## Interstitial (Retry na loot ekranu) je blago ograničen — InterstitialPacer.

signal rewarded_completed(placement: String)
signal rewarded_failed(placement: String, reason: String)
## UMP + MobileAds gotovi (samo Android s pluginom). can_request = smiju se tražiti reklame.
signal ads_ready_changed(can_request: bool)

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const ADMOB_PLUGIN_CFG := "res://addons/admob/plugin.cfg"
const ADMOB_BACKEND_SCRIPT := "res://scripts/monetization/admob_backend.gd"
## Debug build: dev prekidač „UMP as EEA" (Settings → Developer) da se forma vidi i izvan EU.
const DEBUG_CFG_PATH := "user://ads_debug.cfg"
const REWARDED_LOAD_TIMEOUT_SEC := 8.0
const PRELOAD_RETRY_SEC := 30.0
## Nagrada ponekad stigne tik poslije „dismissed" — kratko sačekaj prije „nije odgledano".
const REWARD_GRACE_SEC := 0.5

enum Backend { STUB, ADMOB_PLUGIN }


## admob = Android s pluginom (prava reklama ili nema nagrade). fail = Android release bez
## plugina. stub = editor, Windows, debug APK bez plugina — 1,2 s „reklame" i nagrada.
static func reward_route(on_android: bool, debug_or_editor: bool, has_admob_plugin: bool = false) -> String:
	if on_android and has_admob_plugin:
		return "admob"
	if on_android and not debug_or_editor:
		return "fail"
	return "stub"


## Blago ograničenje interstitiala (odluka 2026-10-23): nikad prije završenog tutorijala ni u
## sesiji u kojoj je tutorijal završen, najviše jedna na 3 Retry-ja, najmanje 3 min razmaka
## (i od starta igre). Brojači žive samo u memoriji — novo pokretanje kreće ispočetka.
class InterstitialPacer:
	extends RefCounted

	const EVERY_N_RETRIES := 3
	const MIN_GAP_MSEC := 180000

	var retries: int = 0
	var last_shown_msec: int = 0

	func _init(session_start_msec: int = 0) -> void:
		last_shown_msec = session_start_msec

	func note_retry() -> void:
		retries += 1

	func is_due(now_msec: int, tutorial_done: bool, first_session: bool, ads_removed: bool) -> bool:
		if ads_removed or not tutorial_done or first_session:
			return false
		return retries >= EVERY_N_RETRIES and now_msec - last_shown_msec >= MIN_GAP_MSEC

	func mark_shown(now_msec: int) -> void:
		retries = 0
		last_shown_msec = now_msec


var backend: Backend = Backend.STUB
var backend_name: String = "stub"
var pacer := InterstitialPacer.new(Time.get_ticks_msec())
var _busy: bool = false
var _pending_placement: String = ""
var _ads: Object = null
var _can_request_ads: bool = false
var _first_session: bool = true
var _reward_earned: bool = false
var _reward_serial: int = 0
var _force_android: bool = false


func _ready() -> void:
	# GameState je autoload prije nas — save je već učitan.
	_first_session = not GameState.tutorial_complete
	if _try_init_admob_plugin():
		backend = Backend.ADMOB_PLUGIN
		backend_name = "admob_plugin"
		if not OS.is_debug_build() and CONFIG.ADMOB_REWARDED_ANDROID_PROD.is_empty():
			push_warning("AdManager: release build uses Google TEST ad units — fill PRODUCTION IDS in monetization_config.gd")
		_ads.call("start", _debug_eea_enabled(), _on_ads_started)
	else:
		backend = Backend.STUB
		backend_name = "stub"


func is_stub_mode() -> bool:
	return backend == Backend.STUB


## Seam za GUT: lažni backend s istim metodama kao admob_backend.gd.
func attach_ads_backend(ads: Object) -> void:
	_ads = ads
	backend = Backend.ADMOB_PLUGIN
	backend_name = "admob_plugin"


func _try_init_admob_plugin() -> bool:
	if OS.get_name() != "Android":
		return false
	# Poing klase su GDScript class_name — ClassDB ih ne vidi; plugin prepoznajemo po plugin.cfg.
	if not FileAccess.file_exists(ADMOB_PLUGIN_CFG) or not ResourceLoader.exists(ADMOB_BACKEND_SCRIPT):
		return false
	var script: Script = load(ADMOB_BACKEND_SCRIPT)
	if script == null:
		return false
	_ads = script.new()
	return _ads != null


func _on_ads_started(can_request: bool) -> void:
	_can_request_ads = can_request
	if can_request:
		_preload_rewarded()
		_preload_interstitial()
	ads_ready_changed.emit(can_request)


## Reklama unaprijed, da je spremna kad igrač tapne (na sporom telefonu load traje i 10+ s).
## Neuspjeh (mreža, no fill) → novi pokušaj za PRELOAD_RETRY_SEC.
func _preload_rewarded() -> void:
	if _ads != null and _can_request_ads:
		_ads.call("load_rewarded", CONFIG.rewarded_unit_id(), func(ok: bool) -> void:
			if not ok:
				_retry_later(_preload_rewarded)
		)


func _preload_interstitial() -> void:
	if _ads != null and _can_request_ads and not GameState.ads_removed:
		_ads.call("load_interstitial", CONFIG.interstitial_unit_id(), func(ok: bool) -> void:
			if not ok:
				_retry_later(_preload_interstitial)
		)


func _retry_later(fn: Callable) -> void:
	if is_inside_tree():
		get_tree().create_timer(PRELOAD_RETRY_SEC).timeout.connect(fn, CONNECT_ONE_SHOT)


# --- Rewarded ---

func can_request_rewarded() -> bool:
	if _busy:
		return false
	if backend == Backend.ADMOB_PLUGIN:
		return _can_request_ads
	return true


func request_rewarded(placement: String) -> void:
	if _busy:
		rewarded_failed.emit(placement, "busy")
		return
	if placement != CONFIG.PLACEMENT_DOUBLE_LOOT and placement != CONFIG.PLACEMENT_REVIVE:
		rewarded_failed.emit(placement, "invalid_placement")
		return
	_busy = true
	_pending_placement = placement
	# Muzika stoji dok reklama svira (i stub: 1,2 s „reklame").
	Sfx.set_ad_playing(true)
	var route := reward_route(
		OS.get_name() == "Android" or _force_android,
		OS.is_debug_build() or OS.has_feature("editor"),
		backend == Backend.ADMOB_PLUGIN
	)
	match route:
		"admob":
			_request_admob_rewarded(placement)
		"stub":
			_request_stub_rewarded(placement)
		_:
			_fail_rewarded(placement, "not_wired")


func _request_stub_rewarded(placement: String) -> void:
	var timer := get_tree().create_timer(1.2)
	timer.timeout.connect(func() -> void:
		_finish_rewarded(placement)
	, CONNECT_ONE_SHOT)


func _request_admob_rewarded(placement: String) -> void:
	if not _can_request_ads:
		_fail_rewarded(placement, "no_consent")
		return
	if bool(_ads.call("has_rewarded")):
		_show_admob_rewarded(placement)
		return
	_reward_serial += 1
	var serial := _reward_serial
	get_tree().create_timer(REWARDED_LOAD_TIMEOUT_SEC).timeout.connect(func() -> void:
		if _busy and serial == _reward_serial and _pending_placement == placement:
			_reward_serial += 1
			_fail_rewarded(placement, "no_fill")
	, CONNECT_ONE_SHOT)
	_ads.call("load_rewarded", CONFIG.rewarded_unit_id(), func(ok: bool) -> void:
		if not _busy or serial != _reward_serial:
			return
		if ok:
			_show_admob_rewarded(placement)
		else:
			_reward_serial += 1
			_fail_rewarded(placement, "no_fill")
	)


func _show_admob_rewarded(placement: String) -> void:
	_reward_serial += 1
	var serial := _reward_serial
	_reward_earned = false
	_ads.call(
		"show_rewarded",
		func() -> void: _reward_earned = true,
		func() -> void: _on_rewarded_closed(placement, serial),
		func() -> void:
			if serial == _reward_serial:
				_fail_rewarded(placement, "show_failed")
				_preload_rewarded()
	)


func _on_rewarded_closed(placement: String, serial: int) -> void:
	if serial != _reward_serial:
		return
	if _reward_earned:
		_finish_rewarded(placement)
		_preload_rewarded()
		return
	get_tree().create_timer(REWARD_GRACE_SEC).timeout.connect(func() -> void:
		if serial != _reward_serial or not _busy:
			return
		if _reward_earned:
			_finish_rewarded(placement)
		else:
			_fail_rewarded(placement, "not_earned")
		_preload_rewarded()
	, CONNECT_ONE_SHOT)


func _finish_rewarded(placement: String) -> void:
	_reward_serial += 1
	_busy = false
	_pending_placement = ""
	Sfx.set_ad_playing(false)
	rewarded_completed.emit(placement)


func _fail_rewarded(placement: String, reason: String) -> void:
	if backend == Backend.ADMOB_PLUGIN:
		push_warning("AdManager: rewarded %s failed — %s" % [placement, reason])
	_busy = false
	_pending_placement = ""
	Sfx.set_ad_playing(false)
	rewarded_failed.emit(placement, reason)


# --- Interstitial ---

## Smije li ovaj build uopšte pokazati interstitial (Remove Ads ga gasi). Ne broji Retry.
func can_show_interstitial(_placement: String) -> bool:
	return not GameState.ads_removed


## Poziva se jednom po Retry-ju: broji priliku i kaže treba li reklama SADA (pacer + učitana).
## false = Retry ide odmah. Ako je red, a reklama još nije učitana, samo je naruči za sljedeći put.
func take_interstitial_turn(placement: String) -> bool:
	if not can_show_interstitial(placement):
		return false
	pacer.note_retry()
	if not pacer.is_due(Time.get_ticks_msec(), GameState.tutorial_complete, _first_session, GameState.ads_removed):
		return false
	if backend == Backend.ADMOB_PLUGIN:
		if not _can_request_ads:
			return false
		if not bool(_ads.call("has_interstitial")):
			_preload_interstitial()
			return false
	return true


func show_interstitial(placement: String, on_finished: Callable = Callable()) -> void:
	if not can_show_interstitial(placement):
		if on_finished.is_valid():
			on_finished.call()
		return
	pacer.mark_shown(Time.get_ticks_msec())
	Sfx.set_ad_playing(true)
	var done := func() -> void:
		Sfx.set_ad_playing(false)
		if on_finished.is_valid():
			on_finished.call()
	match backend:
		Backend.ADMOB_PLUGIN:
			_ads.call("show_interstitial", func() -> void:
				done.call()
				_preload_interstitial()
			)
		_:
			get_tree().create_timer(0.35).timeout.connect(done, CONNECT_ONE_SHOT)


# --- Privatnost (Settings → Privacy choices) ---

## UMP forma ako je igrač u regiji gdje Google to traži (EEA / UK / CH); inače politika privatnosti.
func show_privacy_options() -> void:
	if _ads != null and bool(_ads.call("privacy_options_required")):
		_ads.call("show_privacy_options", func() -> void:
			_can_request_ads = bool(_ads.call("can_request_ads"))
		)
		return
	OS.shell_open(UiSettings.PRIVACY_URL)


func is_debug_eea_enabled() -> bool:
	return _debug_eea_enabled()


## Dev: forma pristanka kao u EU (važi od sljedećeg pokretanja). Samo debug build.
func set_debug_eea(on: bool) -> void:
	if not OS.is_debug_build():
		return
	var cfg := ConfigFile.new()
	cfg.set_value("ump", "debug_eea", on)
	cfg.save(DEBUG_CFG_PATH)


## Dev: zaboravi pristanak — forma se pokaže na sljedećem pokretanju.
func reset_consent_for_dev() -> void:
	if _ads != null:
		_ads.call("reset_consent")


func _debug_eea_enabled() -> bool:
	if not OS.is_debug_build():
		return false
	var cfg := ConfigFile.new()
	if cfg.load(DEBUG_CFG_PATH) != OK:
		return false
	return bool(cfg.get_value("ump", "debug_eea", false))
