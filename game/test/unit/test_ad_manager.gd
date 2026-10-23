## LAUNCH-PREP C — AdMob tok s lažnim backendom: nagrada samo kad je odgledano,
## blago ograničenje interstitiala, ID-evi na jednom mjestu.
extends "res://test/unit/game_state_test_base.gd"

const AD_SCRIPT := preload("res://scripts/monetization/ad_manager.gd")
const CONFIG := preload("res://scripts/monetization/monetization_config.gd")


## Isti API kao admob_backend.gd; test sam zove callbackove (kao da je reklama prikazana).
class FakeAdsBackend:
	extends RefCounted

	var rewarded_ready: bool = true
	var rewarded_load_ok: bool = true
	var interstitial_ready: bool = false
	var loads: Array[String] = []
	var on_earned: Callable
	var on_closed: Callable
	var on_failed: Callable
	var interstitial_closed: Callable

	func can_request_ads() -> bool:
		return true

	func has_rewarded() -> bool:
		return rewarded_ready

	func load_rewarded(unit_id: String, on_done: Callable) -> void:
		loads.append("rewarded:" + unit_id)
		rewarded_ready = rewarded_load_ok
		on_done.call(rewarded_load_ok)

	func show_rewarded(earned: Callable, closed: Callable, failed: Callable) -> void:
		rewarded_ready = false
		on_earned = earned
		on_closed = closed
		on_failed = failed

	func has_interstitial() -> bool:
		return interstitial_ready

	func load_interstitial(unit_id: String, _on_done: Callable) -> void:
		loads.append("interstitial:" + unit_id)

	func show_interstitial(closed: Callable) -> void:
		interstitial_ready = false
		interstitial_closed = closed

	func privacy_options_required() -> bool:
		return false

	func show_privacy_options(_closed: Callable) -> void:
		pass

	func reset_consent() -> void:
		pass


var _ads: Node
var _fake: FakeAdsBackend
var _events: Array[String] = []
var _ads_removed_before: bool
var _tutorial_before: bool
var _first_session_before: bool


func before_each() -> void:
	super.before_each()
	_ads = get_node("/root/AdManager")
	_ads_removed_before = _gs.ads_removed
	_tutorial_before = _gs.tutorial_complete
	_first_session_before = _ads._first_session
	_events.clear()
	_fake = FakeAdsBackend.new()
	_ads.attach_ads_backend(_fake)
	_ads._can_request_ads = true
	_ads._force_android = true
	_ads.rewarded_completed.connect(_on_done)
	_ads.rewarded_failed.connect(_on_fail)


func after_each() -> void:
	_ads.rewarded_completed.disconnect(_on_done)
	_ads.rewarded_failed.disconnect(_on_fail)
	_ads._ads = null
	_ads.backend = AD_SCRIPT.Backend.STUB
	_ads.backend_name = "stub"
	_ads._can_request_ads = false
	_ads._force_android = false
	_ads._busy = false
	_ads._pending_placement = ""
	_ads._reward_serial += 1
	_ads._first_session = _first_session_before
	_ads.pacer = AD_SCRIPT.InterstitialPacer.new(Time.get_ticks_msec())
	_gs.ads_removed = _ads_removed_before
	_gs.tutorial_complete = _tutorial_before
	super.after_each()
	_gs.load_player_save()


func _on_done(placement: String) -> void:
	_events.append("done:" + placement)


func _on_fail(placement: String, reason: String) -> void:
	_events.append("fail:%s:%s" % [placement, reason])


func test_reward_route_with_plugin_never_stubs() -> void:
	assert_eq(AD_SCRIPT.reward_route(true, true, true), "admob", "debug APK with plugin uses real ads")
	assert_eq(AD_SCRIPT.reward_route(true, false, true), "admob")
	assert_eq(AD_SCRIPT.reward_route(true, false, false), "fail")
	assert_eq(AD_SCRIPT.reward_route(false, true, false), "stub")


func test_rewarded_grants_only_after_watching() -> void:
	_ads.request_rewarded(CONFIG.PLACEMENT_DOUBLE_LOOT)
	assert_true(_fake.on_closed.is_valid(), "ad was shown")
	assert_false(_ads.can_request_rewarded(), "busy while the ad plays")
	_fake.on_earned.call()
	_fake.on_closed.call()
	assert_eq(_events, ["done:double_loot"])
	assert_true(_ads.can_request_rewarded())


func test_rewarded_closed_early_gives_nothing() -> void:
	_ads.request_rewarded(CONFIG.PLACEMENT_REVIVE)
	_fake.on_closed.call()
	assert_eq(_events.size(), 0, "waits a moment for a late reward callback")
	await wait_seconds(AD_SCRIPT.REWARD_GRACE_SEC + 0.2)
	assert_eq(_events, ["fail:revive:not_earned"])


func test_rewarded_loads_when_missing_and_reports_no_fill() -> void:
	_fake.rewarded_ready = false
	_fake.rewarded_load_ok = false
	_ads.request_rewarded(CONFIG.PLACEMENT_DOUBLE_LOOT)
	assert_true(_fake.loads.has("rewarded:" + CONFIG.ADMOB_TEST_REWARDED_ANDROID), "debug build loads the test unit")
	assert_eq(_events, ["fail:double_loot:no_fill"])
	assert_false(_ads._busy)


func test_no_consent_means_no_ad_and_no_reward() -> void:
	_ads._can_request_ads = false
	assert_false(_ads.can_request_rewarded(), "loot screen hides ad buttons")
	_ads.request_rewarded(CONFIG.PLACEMENT_DOUBLE_LOOT)
	assert_eq(_events, ["fail:double_loot:no_consent"])


func test_pacer_rules() -> void:
	var p := AD_SCRIPT.InterstitialPacer.new(0)
	var gap: int = AD_SCRIPT.InterstitialPacer.MIN_GAP_MSEC
	for _i in AD_SCRIPT.InterstitialPacer.EVERY_N_RETRIES:
		p.note_retry()
	assert_true(p.is_due(gap, true, false, false), "3rd retry after 3 min")
	assert_false(p.is_due(gap, false, false, false), "never before the tutorial is done")
	assert_false(p.is_due(gap, true, true, false), "never in the session the tutorial ended")
	assert_false(p.is_due(gap, true, false, true), "Remove Ads turns them off")
	assert_false(p.is_due(gap - 1, true, false, false), "not sooner than 3 min")
	p.mark_shown(gap)
	p.note_retry()
	p.note_retry()
	assert_false(p.is_due(gap * 3, true, false, false), "only every 3rd retry")
	p.note_retry()
	assert_false(p.is_due(gap * 2 - 1, true, false, false), "3 min gap after the last one")
	assert_true(p.is_due(gap * 2, true, false, false))


func test_interstitial_turn_orders_ad_when_not_loaded() -> void:
	_gs.tutorial_complete = true
	_gs.ads_removed = false
	_ads._first_session = false
	_ads.pacer = AD_SCRIPT.InterstitialPacer.new(Time.get_ticks_msec() - AD_SCRIPT.InterstitialPacer.MIN_GAP_MSEC)
	assert_false(_ads.take_interstitial_turn(CONFIG.PLACEMENT_LOOT_RETRY))
	assert_false(_ads.take_interstitial_turn(CONFIG.PLACEMENT_LOOT_RETRY))
	assert_false(_ads.take_interstitial_turn(CONFIG.PLACEMENT_LOOT_RETRY), "due, but nothing loaded yet")
	assert_true(_fake.loads.has("interstitial:" + CONFIG.ADMOB_TEST_INTERSTITIAL_ANDROID))
	_fake.interstitial_ready = true
	assert_true(_ads.take_interstitial_turn(CONFIG.PLACEMENT_LOOT_RETRY), "next retry shows it")
	var finished := [false]
	_ads.show_interstitial(CONFIG.PLACEMENT_LOOT_RETRY, func() -> void: finished[0] = true)
	_fake.interstitial_closed.call()
	assert_true(finished[0], "retry continues after the ad")
	assert_false(_ads.take_interstitial_turn(CONFIG.PLACEMENT_LOOT_RETRY), "counter starts over")


func test_remove_ads_skips_interstitial_but_keeps_rewarded() -> void:
	_gs.ads_removed = true
	_gs.tutorial_complete = true
	_ads._first_session = false
	assert_false(_ads.take_interstitial_turn(CONFIG.PLACEMENT_LOOT_RETRY))
	assert_true(_ads.can_request_rewarded(), "rewarded stays optional after Remove Ads (Pillar 2)")


func test_ad_ids_live_in_one_place() -> void:
	assert_eq(CONFIG.pick_ad_unit("", "test", true), "test", "empty prod id falls back to test")
	assert_eq(CONFIG.pick_ad_unit("prod", "test", false), "test", "debug build never shows real ads")
	assert_eq(CONFIG.pick_ad_unit("prod", "test", true), "prod")
	# Plugin briše postavku kad je jednaka njegovom defaultu (Googleov test App ID) i tada u
	# manifest upiše default — isto čitamo i ovdje.
	var manifest_id := str(ProjectSettings.get_setting("admob/general/android/app_id", CONFIG.ADMOB_TEST_APP_ID_ANDROID))
	var expected: String = CONFIG.ADMOB_APP_ID_ANDROID_PROD if not CONFIG.ADMOB_APP_ID_ANDROID_PROD.is_empty() \
		else CONFIG.ADMOB_TEST_APP_ID_ANDROID
	assert_eq(manifest_id, expected, "project.godot app_id must match MonetizationConfig")
