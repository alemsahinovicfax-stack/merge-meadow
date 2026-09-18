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

	_reset_upgrade_state(gs, {"clover": 2}, 0, 0)
	if not bool(gs.call("try_upgrade_magnet", "")):
		_fail("try_upgrade_magnet with 2 clover failed")
		return
	if int(gs.get("magnet_level")) != 1:
		_fail("magnet_level expected 1 got %s" % str(gs.get("magnet_level")))
		return
	var stash: Dictionary = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 0:
		_fail("clover stash should be 0 after magnet upgrade")
		return

	_reset_upgrade_state(gs, {"clover": 1}, 0, 0)
	if bool(gs.call("try_upgrade_magnet", "")):
		_fail("try_upgrade_magnet should fail with 1 flower")
		return
	stash = gs.get("garden_crystal_stash")
	if int(gs.get("magnet_level")) != 0 or int(stash.get("clover", 0)) != 1:
		_fail("failed magnet upgrade must not change level or stash")
		return

	_reset_upgrade_state(gs, {"clover": 2}, 0, 0)
	if not bool(gs.call("try_upgrade_multiplier", "")):
		_fail("try_upgrade_multiplier with 2 clover failed")
		return
	stash = gs.get("garden_crystal_stash")
	if int(gs.get("multiplier_level")) != 1 or int(stash.get("clover", 0)) != 0:
		_fail("loot upgrade should reach 1 and spend 2 clover")
		return

	_reset_upgrade_state(gs, {"clover": 1}, 0, 0)
	if bool(gs.call("try_upgrade_multiplier", "")) or int(gs.get("multiplier_level")) != 0:
		_fail("try_upgrade_multiplier should fail with 1 flower")
		return

	var max_lv := 4
	_reset_upgrade_state(gs, {"clover": 5}, max_lv, 0)
	if bool(gs.call("try_upgrade_magnet", "")):
		_fail("try_upgrade_magnet at max should fail")
		return
	stash = gs.get("garden_crystal_stash")
	if int(gs.get("magnet_level")) != max_lv or int(stash.get("clover", 0)) != 5:
		_fail("maxed upgrade must not spend flowers")
		return

	_reset_upgrade_state(gs, {"clover": 3, "daisy": 2}, 0, 0)
	if str(gs.call("pick_upgrade_flower_type", "")) != "clover":
		_fail("C11 no-select should pick clover (higher count)")
		return
	if str(gs.call("pick_upgrade_flower_type", "daisy")) != "daisy":
		_fail("C11 preferred daisy should pick daisy")
		return
	if not bool(gs.call("try_upgrade_magnet", "daisy")):
		_fail("C11 spend daisy failed")
		return
	stash = gs.get("garden_crystal_stash")
	if int(stash.get("daisy", 0)) != 0 or int(stash.get("clover", 0)) != 3:
		_fail("C11 should spend daisy and keep clover 3")
		return

	print("camp_donate_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _reset_upgrade_state(gs: Node, stash: Dictionary, magnet: int, loot: int) -> void:
	gs.set("garden_crystal_stash", stash.duplicate())
	gs.set("magnet_level", magnet)
	gs.set("multiplier_level", loot)
