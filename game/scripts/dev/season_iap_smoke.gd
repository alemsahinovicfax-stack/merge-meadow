extends SceneTree

## SEZ-E — stub season IAP grant + own + dev reset (does not change free unlock math).

const SAVE_PATH := "user://player_save.json"
const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const S1 := "country_bloom"
const S2 := "frost_orchard"
const SKU := "season_pack_moonlit_warren"
const PAID := "moonlit_warren"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _iap() -> Node:
	return get_root().get_node_or_null("IAPManager")


func _fail(msg: String) -> void:
	push_error("season_iap_smoke: %s" % msg)
	quit(1)


func _run() -> void:
	var gs := _gs()
	var iap := _iap()
	if gs == null:
		_fail("GameState missing")
		return
	if iap == null:
		_fail("IAPManager missing")
		return
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	gs.set("wallet_coins", 0)
	gs.set("garden_crystal_stash", {})
	gs.call("reset_seasons_to_s1")
	if bool(gs.call("is_season_playable", S2)):
		_fail("S2 should not be playable before paid buy")
		return
	if bool(gs.call("is_season_playable", PAID)):
		_fail("paid should not be playable before purchase")
		return

	var completed := {"sku": ""}
	var failed := {"reason": ""}
	iap.purchase_completed.connect(func(sku: String) -> void:
		completed["sku"] = sku
	)
	iap.purchase_failed.connect(func(_sku: String, reason: String) -> void:
		failed["reason"] = reason
	)
	iap.call("purchase", SKU)
	var elapsed := 0.0
	while elapsed < 2.5 and str(completed["sku"]).is_empty() and str(failed["reason"]).is_empty():
		await process_frame
		elapsed += 1.0 / 60.0
	if not str(failed["reason"]).is_empty():
		_fail("purchase failed: %s" % failed["reason"])
		return
	if str(completed["sku"]) != SKU:
		_fail("purchase_completed sku mismatch")
		return
	if not bool(gs.call("is_season_playable", PAID)):
		_fail("moonlit_warren should be playable after stub buy")
		return
	if str(gs.get("active_season_id")) != PAID:
		_fail("active should auto-switch to moonlit_warren")
		return
	if bool(gs.call("is_season_playable", S2)):
		_fail("S2 must stay locked after paid buy")
		return
	if not bool(iap.call("owns_product", SKU)):
		_fail("owns_product should be true after grant")
		return

	completed["sku"] = ""
	failed["reason"] = ""
	iap.call("purchase", SKU)
	if str(failed["reason"]) != "already_owned":
		_fail("second purchase expected already_owned, got '%s'" % failed["reason"])
		return
	if bool(gs.call("is_season_playable", S2)):
		_fail("S2 must stay locked after already_owned")
		return

	iap.call("reset_purchases_for_dev")
	if bool(gs.call("is_season_playable", PAID)):
		_fail("paid should be empty after dev reset")
		return
	if str(gs.get("active_season_id")) != S1:
		_fail("active should return to S1 after clearing paid")
		return
	if bool(iap.call("owns_product", SKU)):
		_fail("owns_product should be false after dev reset")
		return
	if bool(gs.call("is_season_playable", S2)):
		_fail("S2 must stay locked after dev reset")
		return
	if not CONFIG.is_season_sku(SKU) or CONFIG.season_id_for_sku(SKU) != PAID:
		_fail("season sku helper mismatch")
		return

	print("season_iap_smoke OK")
	quit(0)
