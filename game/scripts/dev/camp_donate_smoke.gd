extends SceneTree

## CAMP-01 B — Flowers spend for Sprinkler / Loot Boost.


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("camp_donate_smoke: %s" % msg)
	quit(1)


func _run() -> void:
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		_fail("camp scene load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	if camp == null or not str(camp.scene_file_path).ends_with("camp_scene.tscn"):
		_fail("wrong scene")
		return
	var gs := get_root().get_node_or_null("GameState")
	if gs == null:
		_fail("GameState missing")
		return

	_reset_upgrade_state(gs, {"clover": 2}, 0, 0)
	camp.set("_selected_crystal_type", "")
	camp.call("_refresh_ui")
	await process_frame
	var sprinkler_btn := camp.get_node("%UpgradeButton")
	if sprinkler_btn == null or bool(sprinkler_btn.get("disabled")):
		_fail("2 clover should enable Sprinkler Upgrade")
		return
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
	camp.call("_refresh_ui")
	await process_frame
	sprinkler_btn = camp.get_node("%UpgradeButton")
	if sprinkler_btn == null or not bool(sprinkler_btn.get("disabled")):
		_fail("1 clover should disable Sprinkler Upgrade")
		return
	if bool(gs.call("try_upgrade_magnet", "")):
		_fail("try_upgrade_magnet should fail with 1 flower")
		return
	if int(gs.get("magnet_level")) != 0:
		_fail("magnet should stay 0 with 1 flower")
		return
	stash = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 1:
		_fail("1 clover stash should be unchanged")
		return

	_reset_upgrade_state(gs, {"clover": 2}, 0, 0)
	camp.call("_refresh_ui")
	await process_frame
	var loot_btn := camp.get_node("%UpgradeMultiplierButton")
	if loot_btn == null or bool(loot_btn.get("disabled")):
		_fail("2 clover should enable Loot Boost Upgrade")
		return
	if not bool(gs.call("try_upgrade_multiplier", "")):
		_fail("try_upgrade_multiplier with 2 clover failed")
		return
	if int(gs.get("multiplier_level")) != 1:
		_fail("multiplier_level expected 1")
		return
	stash = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 0:
		_fail("clover stash should be 0 after loot upgrade")
		return

	_reset_upgrade_state(gs, {"clover": 1}, 0, 0)
	if bool(gs.call("try_upgrade_multiplier", "")):
		_fail("try_upgrade_multiplier should fail with 1 flower")
		return
	if int(gs.get("multiplier_level")) != 0:
		_fail("multiplier should stay 0 with 1 flower")
		return

	var max_lv := 4
	_reset_upgrade_state(gs, {"clover": 5}, max_lv, 0)
	camp.call("_refresh_ui")
	await process_frame
	sprinkler_btn = camp.get_node("%UpgradeButton")
	if sprinkler_btn == null or not bool(sprinkler_btn.get("disabled")):
		_fail("max magnet should disable Upgrade")
		return
	if bool(gs.call("try_upgrade_magnet", "")):
		_fail("try_upgrade_magnet at max should fail")
		return
	if int(gs.get("magnet_level")) != max_lv:
		_fail("max magnet level changed")
		return
	stash = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 5:
		_fail("maxed upgrade must not spend flowers")
		return

	camp.call("_refresh_ui")
	await process_frame
	var sprinkler_cap := camp.get_node("%SprinklerCaption") as Label
	var loot_cap := camp.get_node("%MultiplierCaption") as Label
	var sprinkler_text := sprinkler_cap.text if sprinkler_cap else ""
	var loot_text := loot_cap.text if loot_cap else ""
	if sprinkler_text.contains("donate in Arena") or loot_text.contains("donate in Arena"):
		_fail("caption still says donate in Arena")
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
	quit(0)


func _reset_upgrade_state(gs: Node, stash: Dictionary, magnet: int, loot: int) -> void:
	gs.set("garden_crystal_stash", stash.duplicate())
	gs.set("magnet_level", magnet)
	gs.set("multiplier_level", loot)
	gs.set("sprinkler_donations", 0)
	gs.set("multiplier_donations", 0)
