extends SceneTree

## Camp v3 — nivoi po sezoni i pet stanja dugmeta.


var _backup := ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("upgrades_per_season_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _run() -> void:
	var gs := get_root().get_node_or_null("GameState")
	if gs == null:
		_fail("GameState missing")
		return
	gs.call("set_active_season", "country_bloom")
	var flower := str(gs.call("star3_type_id_for_season", "country_bloom"))
	var reserve := int(gs.call("upgrade_flower_reserve", flower))
	gs.set("magnet_level", 0)
	gs.set("multiplier_level", 0)
	gs.set("wallet_coins", 0)
	gs.set("garden_crystal_stash", {})
	if str(gs.call("upgrade_button_state", "magnet")) != "short_both":
		_fail("fresh season should be short of both")
		return
	gs.set("wallet_coins", 10)
	if str(gs.call("upgrade_button_state", "magnet")) != "short_flower":
		_fail("coins without flowers should be short_flower")
		return
	gs.set("garden_crystal_stash", {flower: reserve + 2})
	gs.set("wallet_coins", 9)
	if str(gs.call("upgrade_button_state", "magnet")) != "short_coin":
		_fail("flowers without coins should be short_coin")
		return
	gs.set("wallet_coins", 10)
	if str(gs.call("upgrade_button_state", "magnet")) != "can":
		_fail("2 above the reserve and 10 coins should be can")
		return
	if not bool(gs.call("try_upgrade_magnet", "")):
		_fail("buy failed")
		return
	# Stari save ne smije donijeti tuđe nivoe u ovaj test.
	gs.set("season_upgrades", {"country_bloom": {"magnet": 1, "loot": 0, "twin": 0}})
	gs.call("debug_unlock_all_seasons")
	if int(gs.get("magnet_level")) != 0:
		_fail("a new season must start at 0, got %s" % str(gs.get("magnet_level")))
		return
	if not bool(gs.call("set_active_season", "country_bloom")):
		_fail("could not return to bloom")
		return
	if int(gs.get("magnet_level")) != 1:
		_fail("returning must restore magnet 1, got %s" % str(gs.get("magnet_level")))
		return
	gs.set("magnet_level", 4)
	if str(gs.call("upgrade_button_state", "magnet")) != "max":
		_fail("level 4 should be max")
		return
	print("upgrades_per_season_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
