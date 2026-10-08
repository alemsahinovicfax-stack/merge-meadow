extends SceneTree

## CAMP-01 B — Flowers spend for Sprinkler / Loot Boost (GameState API).
## Dugmad za upgrade zive na Home polju; Camp vise nema UpgradeCards.

var _backup: String = ""


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("camp_donate_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var gs := get_root().get_node_or_null("GameState")
	if gs == null:
		_fail("GameState missing")
		return
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		_fail("camp scene load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	if camp == null:
		_fail("camp scene missing")
		return
	if camp.get_node_or_null("%UpgradeCards") != null:
		_fail("UpgradeCards should be removed from Camp (upgrades live on Home field)")
		return

	var flower := str(gs.call("star3_type_id_for_season", str(gs.get("active_season_id"))))
	var reserve := int(gs.call("upgrade_flower_reserve", flower))
	# Iznad Kept granice treba točno 2 ★3 te sezone, plus 10 coina za prvi nivo.
	_reset_upgrade_state(gs, {flower: reserve + 2}, 0, 0, 10)
	if not bool(gs.call("try_upgrade_magnet", "")):
		_fail("magnet upgrade with %s above the reserve failed" % flower)
		return
	if int(gs.get("magnet_level")) != 1 or int(gs.get("wallet_coins")) != 0:
		_fail("magnet should reach 1 and spend 10 coins")
		return
	var stash: Dictionary = gs.get("garden_crystal_stash")
	if int(stash.get(flower, 0)) != reserve:
		_fail("upgrade must leave the Kept reserve, got %s" % str(stash.get(flower, 0)))
		return

	_reset_upgrade_state(gs, {flower: reserve + 1}, 0, 0, 10)
	if bool(gs.call("try_upgrade_magnet", "")):
		_fail("magnet must fail when only 1 flower is above the reserve")
		return

	_reset_upgrade_state(gs, {flower: reserve + 2}, 0, 0, 9)
	if bool(gs.call("try_upgrade_magnet", "")) or int(gs.get("wallet_coins")) != 9:
		_fail("magnet must fail when coins are short and must not spend")
		return

	_reset_upgrade_state(gs, {flower: reserve + 2}, 0, 0, 20)
	if not bool(gs.call("try_upgrade_multiplier", "")):
		_fail("loot upgrade failed")
		return
	if int(gs.get("multiplier_level")) != 1 or int(gs.get("wallet_coins")) != 10:
		_fail("loot should reach 1 and spend 10 of 20 coins")
		return

	var max_lv := 4
	_reset_upgrade_state(gs, {flower: reserve + 5}, max_lv, 0, 100)
	if bool(gs.call("try_upgrade_magnet", "")):
		_fail("try_upgrade_magnet at max should fail")
		return
	stash = gs.get("garden_crystal_stash")
	if int(gs.get("magnet_level")) != max_lv or int(stash.get(flower, 0)) != reserve + 5:
		_fail("maxed upgrade must not spend flowers")
		return

	print("camp_donate_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _reset_upgrade_state(gs: Node, stash: Dictionary, magnet: int, loot: int, coins: int) -> void:
	gs.set("garden_crystal_stash", stash.duplicate())
	gs.set("magnet_level", magnet)
	gs.set("multiplier_level", loot)
	gs.set("wallet_coins", coins)
