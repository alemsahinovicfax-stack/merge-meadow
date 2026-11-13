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

	var season := str(gs.get("active_season_id"))
	var flower := str(gs.call("star3_type_id_for_season", season))
	var reserve := int(gs.call("upgrade_flower_reserve", flower))
	# Cijena prvog nivoa (UiCamp, od 2026-11-12): f T3 cvjetova PRVOG ★2 te sezone + c coina.
	# ★3 (zlatni) plaća tek level 3 i 4, pa samo oni mogu zagristi u Kept rezervu.
	var pay := str(gs.call("upgrade_flower_type", season, 0))
	var f := UiCamp.upgrade_flower_cost(0)
	var c := UiCamp.upgrade_coin_cost(0)
	if pay == flower or int(gs.call("get_seed_rarity", pay)) != 2:
		_fail("level 1 should be paid in the season's first ★2 flower, got %s" % pay)
		return
	_reset_upgrade_state(gs, {pay: f, flower: reserve}, 0, 0, c)
	if bool(gs.call("upgrade_uses_kept_flowers", season)):
		_fail("a level paid in ★2 flowers must not report it uses kept ★3 flowers")
		return
	if not bool(gs.call("try_upgrade_magnet", "")):
		_fail("magnet upgrade with %d %s failed" % [f, pay])
		return
	if int(gs.get("magnet_level")) != 1 or int(gs.get("wallet_coins")) != 0:
		_fail("magnet should reach 1 and spend %d coins" % c)
		return
	var stash: Dictionary = gs.get("garden_crystal_stash")
	if int(stash.get(flower, 0)) != reserve or int(stash.get(pay, 0)) != 0:
		_fail("level 1 must spend %d %s and leave the Kept ★3 alone, got %s" % [f, pay, str(stash)])
		return

	_reset_upgrade_state(gs, {pay: f - 1, flower: reserve + 50}, 0, 0, c)
	if bool(gs.call("try_upgrade_magnet", "")):
		_fail("magnet must fail with only %d %s (★3 flowers do not pay level 1)" % [f - 1, pay])
		return
	# Od 2026-10-16 nadogradnja smije zagristi u Kept rezervu (javlja se na sheetu). To su
	# leveli koji se plaćaju ★3 cvijetom — level 3 (indeks 2).
	var f3 := UiCamp.upgrade_flower_cost(2)
	var c3 := UiCamp.upgrade_coin_cost(2)
	_reset_upgrade_state(gs, {flower: maxi(reserve, f3)}, 2, 0, c3)
	if reserve >= f3 and not bool(gs.call("upgrade_uses_kept_flowers", season)):
		_fail("buying level 3 with exactly the reserve should report it uses kept flowers")
		return
	if not bool(gs.call("try_upgrade_magnet", "")):
		_fail("level 3 must be buyable with flowers that are only kept for the next season")
		return

	_reset_upgrade_state(gs, {pay: f}, 0, 0, c - 1)
	if bool(gs.call("try_upgrade_magnet", "")) or int(gs.get("wallet_coins")) != c - 1:
		_fail("magnet must fail when coins are short and must not spend")
		return

	_reset_upgrade_state(gs, {pay: f}, 0, 0, 2 * c)
	if not bool(gs.call("try_upgrade_multiplier", "")):
		_fail("loot upgrade failed")
		return
	if int(gs.get("multiplier_level")) != 1 or int(gs.get("wallet_coins")) != c:
		_fail("loot should reach 1 and spend %d of %d coins" % [c, 2 * c])
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
