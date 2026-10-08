extends SceneTree

## C1 revive ne plaća coine dvaput, C2 korpa nije 100 % jednog tipa (+5 % spawn ostaje),
## C4 pauza pokazuje isti kept/was kao finish_run, C6 Loot Burst restore je jednom po tokenu.

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const UnlockCfg := preload("res://scripts/progression/seed_unlock_config.gd")

var _backup := ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("loot_logic_smoke: %s" % msg)
	_quit(1)


func _saved_wallet() -> int:
	if not FileAccess.file_exists(CampSmokeUtil.SAVE_PATH):
		return -1
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CampSmokeUtil.SAVE_PATH))
	if not parsed is Dictionary:
		return -1
	return int((parsed as Dictionary).get("wallet_coins", -1))


func _stash_count(gs: Node, flower: String) -> int:
	var stash: Dictionary = gs.get("garden_crystal_stash")
	return int(stash.get(flower, 0))


func _chip(run: Node, kind: String, type_id: String) -> Object:
	var overlay: Node = run.get("pause_overlay")
	if overlay == null:
		return null
	var tray := overlay.find_child("RewardTray", true, false)
	if tray == null:
		return null
	var chips: Array = tray.get("chips")
	for chip in chips:
		if str(chip.get("kind")) == kind and str(chip.get("type_id")) == type_id:
			return chip
	return null


func _prep_revive(gs: Node) -> void:
	gs.set("multiplier_level", 0)
	gs.set("revive_used_this_run", false)
	gs.set("loot_doubled", false)


func _run() -> void:
	var gs := _gs()
	var iap := get_root().get_node_or_null("IAPManager")
	if gs == null or iap == null:
		_fail("GameState / IAPManager missing")
		return
	if int(gs.get("SAVE_VERSION")) != 12:
		_fail("SAVE_VERSION must stay 12")
		return

	# --- C1: 10 raw, ×1 ---
	_prep_revive(gs)
	gs.set("wallet_coins", 100)
	gs.set("seed_bag", {})
	gs.call("finish_run", {"clover": 4}, 10, true, 1.0)
	if int(gs.get("wallet_coins")) != 105 or int(gs.get("last_run_coins")) != 5:
		_fail("fail should keep 5 of 10, wallet %s last %s" % [str(gs.get("wallet_coins")), str(gs.get("last_run_coins"))])
		return
	if int(gs.get("carry_coins")) != 10:
		_fail("fail must keep full carry 10, got %s" % str(gs.get("carry_coins")))
		return
	var bag: Dictionary = gs.get("seed_bag")
	var last_bag: Dictionary = gs.get("last_seed_bag")
	var carry_bag: Dictionary = gs.get("carry_seed_bag")
	if int(bag.get("clover", 0)) != 0 or int(last_bag.get("clover", 0)) != 2 or int(carry_bag.get("clover", 0)) != 4:
		_fail("fail seeds stay pending (bag 0, kept 2, carry 4), got bag %s last %s carry %s" % [str(bag), str(last_bag), str(carry_bag)])
		return
	if not bool(gs.call("request_revive")):
		_fail("revive after fail should succeed")
		return
	if int(gs.get("wallet_coins")) != 100 or _saved_wallet() != 100:
		_fail("revive must claw back the fail credit (memory %s save %s)" % [str(gs.get("wallet_coins")), str(_saved_wallet())])
		return
	if int(gs.get("carry_coins")) != 10:
		_fail("revive must not zero carry_coins, got %s" % str(gs.get("carry_coins")))
		return
	bag = gs.get("seed_bag")
	last_bag = gs.get("last_seed_bag")
	carry_bag = gs.get("carry_seed_bag")
	if int(bag.get("clover", 0)) != 0 or int(last_bag.get("clover", 0)) != 2 or int(carry_bag.get("clover", 0)) != 4:
		_fail("revive must not deposit or clear seeds")
		return
	# Kraj bez novih coina: resume bi opet predala istih 10 (i ista 4 sjemena).
	gs.call("finish_run", {"clover": 4}, 10, false, 1.0)
	if int(gs.get("wallet_coins")) != 110:
		_fail("fail+revive+finish wallet should be 110 (+10), got %s" % str(gs.get("wallet_coins")))
		return
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 0:
		_fail("success finish must not deposit seeds, bag %s" % str(bag))
		return

	# Fail, revive, fail again: only the second 50 %.
	_prep_revive(gs)
	gs.set("wallet_coins", 100)
	gs.call("finish_run", {}, 10, true, 1.0)
	if not bool(gs.call("request_revive")):
		_fail("second revive should succeed")
		return
	gs.call("finish_run", {}, 10, true, 1.0)
	if int(gs.get("wallet_coins")) != 105:
		_fail("fail+revive+fail wallet should be 105 (+5), got %s" % str(gs.get("wallet_coins")))
		return

	# Fail + double, no revive: kept amount is added a second time.
	_prep_revive(gs)
	gs.set("wallet_coins", 100)
	gs.call("finish_run", {}, 10, true, 1.0)
	if not bool(gs.call("double_loot_placeholder")):
		_fail("double after fail should succeed")
		return
	if int(gs.get("wallet_coins")) != 110 or int(gs.get("last_run_coins")) != 10:
		_fail("double should pay the kept 5 again (wallet %s last %s)" % [str(gs.get("wallet_coins")), str(gs.get("last_run_coins"))])
		return
	gs.set("revive_used_this_run", false)
	if bool(gs.call("request_revive")) or int(gs.get("wallet_coins")) != 110:
		_fail("revive after double must stay blocked and not claw back")
		return

	# Clawback cannot drive the wallet negative.
	_prep_revive(gs)
	gs.set("wallet_coins", 0)
	gs.call("finish_run", {}, 10, true, 1.0)
	gs.set("wallet_coins", 1)
	if not bool(gs.call("request_revive")):
		_fail("revive should still succeed when the wallet is short")
		return
	if int(gs.get("wallet_coins")) != 0 or int(gs.get("carry_coins")) != 10:
		_fail("short wallet clamps to 0 and keeps carry, got wallet %s carry %s" % [str(gs.get("wallet_coins")), str(gs.get("carry_coins"))])
		return

	# Scene change from revive must not resume into a live run during the rest of the test.
	gs.set("resume_pending", false)
	gs.set("last_seed_bag", {})
	gs.set("last_loot", 0)

	# --- C6 ---
	gs.call("reset_seasons_to_s1")
	gs.set("garden_crystal_stash", {})
	var tokens: Array = gs.get("granted_purchase_tokens")
	tokens.clear()
	var target: Dictionary = gs.call("get_loot_burst_target")
	if target.is_empty():
		_fail("loot burst needs a locked free season")
		return
	var flower := str(target.get("flower", ""))
	var add := int(target.get("add", 0))
	if flower.is_empty() or add != CONFIG.LOOT_BURST_STAR3:
		_fail("loot burst target unexpected %s" % str(target))
		return
	var burst_sku := str(CONFIG.SKU_BOOSTER_LOOT_BURST)
	iap.call("_process_purchase", _acknowledged(burst_sku, "tok-a"), false)
	if _stash_count(gs, flower) != add:
		_fail("first restore token should grant %d, got %d" % [add, _stash_count(gs, flower)])
		return
	iap.call("_process_purchase", _acknowledged(burst_sku, "tok-a"), false)
	if _stash_count(gs, flower) != add:
		_fail("same token on restore must not grant again, got %d" % _stash_count(gs, flower))
		return
	iap.call("_process_purchase", _acknowledged(burst_sku, ""), false)
	if _stash_count(gs, flower) != add:
		_fail("empty token on restore must not grant, got %d" % _stash_count(gs, flower))
		return
	iap.call("_process_purchase", _acknowledged(burst_sku, ""), true)
	if _stash_count(gs, flower) != add * 2:
		_fail("user purchase with empty token should still grant, got %d" % _stash_count(gs, flower))
		return
	tokens = gs.get("granted_purchase_tokens")
	if tokens.has(""):
		_fail("empty token must not be recorded")
		return
	iap.call("_process_purchase", _acknowledged(burst_sku, "tok-b"), true)
	if _stash_count(gs, flower) != add * 3:
		_fail("a different token should grant once more, got %d" % _stash_count(gs, flower))
		return
	iap.call("_process_purchase", _acknowledged(burst_sku, "tok-b"), false)
	if _stash_count(gs, flower) != add * 3:
		_fail("tok-b restore must not grant again, got %d" % _stash_count(gs, flower))
		return
	tokens = gs.get("granted_purchase_tokens")
	if not tokens.has("tok-a") or not tokens.has("tok-b"):
		_fail("both purchase tokens should be recorded, got %s" % str(tokens))
		return

	gs.set("ads_removed", false)
	iap.call("_process_purchase", _acknowledged(str(CONFIG.SKU_REMOVE_ADS), "ad-1"), false)
	if not bool(gs.get("ads_removed")):
		_fail("remove-ads restore should still grant")
		return
	gs.set("starter_pack_owned", false)
	gs.set("wallet_coins", 20)
	iap.call("_process_purchase", _acknowledged(str(CONFIG.SKU_STARTER_PACK), "st-1"), false)
	if not bool(gs.get("starter_pack_owned")) or int(gs.get("wallet_coins")) != 120:
		_fail("starter restore should grant once, wallet %s" % str(gs.get("wallet_coins")))
		return
	iap.call("_process_purchase", _acknowledged(str(CONFIG.SKU_STARTER_PACK), "st-1"), false)
	if int(gs.get("wallet_coins")) != 120:
		_fail("starter restore must stay idempotent, wallet %s" % str(gs.get("wallet_coins")))
		return

	var saved: Variant = JSON.parse_string(FileAccess.get_file_as_string(CampSmokeUtil.SAVE_PATH))
	if not saved is Dictionary or not (saved as Dictionary).has("granted_purchase_tokens"):
		_fail("save should persist granted_purchase_tokens")
		return
	var saved_tokens: Array = (saved as Dictionary).get("granted_purchase_tokens", [])
	if not saved_tokens.has("tok-a") or not saved_tokens.has("tok-b"):
		_fail("saved tokens missing, got %s" % str(saved_tokens))
		return
	tokens = gs.get("granted_purchase_tokens")
	tokens.clear()
	if not bool(gs.call("load_player_save")):
		_fail("save with tokens should load")
		return
	tokens = gs.get("granted_purchase_tokens")
	if not tokens.has("tok-a") or not tokens.has("tok-b"):
		_fail("load should restore purchase tokens, got %s" % str(tokens))
		return
	(saved as Dictionary).erase("granted_purchase_tokens")
	var file := FileAccess.open(CampSmokeUtil.SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_fail("could not rewrite save without the token key")
		return
	file.store_string(JSON.stringify(saved))
	file.close()
	if not bool(gs.call("load_player_save")):
		_fail("save without granted_purchase_tokens must still load")
		return
	tokens = gs.get("granted_purchase_tokens")
	if not tokens.is_empty():
		_fail("missing token key should default empty, got %s" % str(tokens))
		return
	if int(gs.get("wallet_coins")) != 120:
		_fail("old save without the key should still apply wallet, got %s" % str(gs.get("wallet_coins")))
		return

	# --- C2 draws (pool > 1, loadout set, not all that type) ---
	gs.call("reset_seasons_to_s1")
	gs.set("seed_unlock_index", UnlockCfg.chain_size() - 1)
	gs.set("loadout_type_id", "")
	var pool: Array = gs.call("get_active_season_spawn_types")
	if pool.size() < 2:
		_fail("season pool needs more than one type, got %s" % str(pool))
		return
	var loadout := str(pool[0])
	gs.set("loadout_type_id", loadout)
	if not bool(gs.call("is_loadout_in_active_season_pool")):
		_fail("loadout %s should sit in the active pool" % loadout)
		return
	var saw_other := false
	for _i in 48:
		var picked := str(gs.call("pick_random_run_seed_type"))
		if not pool.has(picked):
			_fail("draw %s outside pool %s" % [picked, str(pool)])
			return
		if picked != loadout:
			saw_other = true
	if not saw_other:
		_fail("loadout %s was every draw; basket must not force one type" % loadout)
		return

	var err := change_scene_to_file("res://scenes/run/run_scene.tscn")
	if err != OK:
		_fail("run scene load failed %d" % err)
		return
	var run: Node = null
	for _j in 40:
		await process_frame
		run = current_scene
		if run != null and bool(run.get("_world_ready")):
			run.set("_state", 2)
			break
	if run == null or not bool(run.get("_world_ready")) or not run.has_method("_effective_seed_spawn_chance"):
		_fail("run scene did not become ready")
		return
	run.set("_state", 2)

	gs.set("loadout_type_id", "")
	var chance_off := float(run.call("_effective_seed_spawn_chance"))
	gs.set("loadout_type_id", loadout)
	var chance_on := float(run.call("_effective_seed_spawn_chance"))
	if not is_equal_approx(float(gs.get("LOADOUT_SPAWN_BONUS")), 0.05):
		_fail("LOADOUT_SPAWN_BONUS should stay 0.05")
		return
	if chance_off >= 0.85 or not is_equal_approx(chance_on, chance_off + 0.05):
		_fail("spawn chance should gain +0.05 with a basket in the pool (off %s on %s)" % [str(chance_off), str(chance_on)])
		return
	gs.set("loadout_type_id", "frost_snowdrop")
	var chance_out := float(run.call("_effective_seed_spawn_chance"))
	if not is_equal_approx(chance_out, chance_off):
		_fail("loadout outside the pool must not change spawn chance (off %s out %s)" % [str(chance_off), str(chance_out)])
		return
	gs.set("loadout_type_id", loadout)

	# --- C4: pause chips match finish_run kept / was ---
	if not _pause_matches(gs, run, 0, 5, 10, 2, 3, 1, 1):
		return
	if not _pause_matches(gs, run, 2, 8, 15, 3, 5, 1, 2):
		return

	print("loot_logic_smoke OK")
	_quit(0)


func _acknowledged(sku: String, token: String) -> Dictionary:
	return {
		"purchase_state": 1,
		"product_ids": [sku],
		"is_acknowledged": true,
		"purchase_token": token,
	}


func _pause_matches(
	gs: Node,
	run: Node,
	level: int,
	coin_kept: int,
	coin_was: int,
	clover_kept: int,
	clover_was: int,
	daisy_kept: int,
	daisy_was: int,
) -> bool:
	gs.set("multiplier_level", level)
	gs.set("wallet_coins", 0)
	gs.call("finish_run", {"clover": 3, "daisy": 1}, 10, true, 1.0)
	if int(gs.get("last_run_coins")) != coin_kept or int(gs.get("carry_coins")) != coin_was:
		_fail("finish_run coins at level %d expected kept %d was %d, got %s / %s" % [
			level, coin_kept, coin_was, str(gs.get("last_run_coins")), str(gs.get("carry_coins")),
		])
		return false
	var kept_seeds: Dictionary = gs.get("last_seed_bag")
	var full_seeds: Dictionary = gs.get("carry_seed_bag")
	if int(kept_seeds.get("clover", 0)) != clover_kept or int(full_seeds.get("clover", 0)) != clover_was:
		_fail("finish_run clover at level %d expected %d/%d, got %s / %s" % [
			level, clover_kept, clover_was, str(kept_seeds), str(full_seeds),
		])
		return false
	if int(kept_seeds.get("daisy", 0)) != daisy_kept or int(full_seeds.get("daisy", 0)) != daisy_was:
		_fail("finish_run daisy at level %d expected %d/%d, got %s / %s" % [
			level, daisy_kept, daisy_was, str(kept_seeds), str(full_seeds),
		])
		return false
	run.set("coin_count", 10)
	run.set("seeds_by_type", {"clover": 3, "daisy": 1})
	run.call("_fill_pause")
	var coin := _chip(run, "coin", "")
	var clover := _chip(run, "seed", "clover")
	var daisy := _chip(run, "seed", "daisy")
	if coin == null or clover == null or daisy == null:
		_fail("pause chips missing")
		return false
	if int(coin.get("count")) != coin_kept or int(coin.get("was")) != coin_was:
		_fail("pause coins expected %d (was %d), got %s / %s" % [coin_kept, coin_was, str(coin.get("count")), str(coin.get("was"))])
		return false
	if int(clover.get("count")) != clover_kept or int(clover.get("was")) != clover_was:
		_fail("pause clover expected %d (was %d), got %s / %s" % [clover_kept, clover_was, str(clover.get("count")), str(clover.get("was"))])
		return false
	if int(daisy.get("count")) != daisy_kept or int(daisy.get("was")) != daisy_was:
		_fail("pause daisy expected %d (was %d), got %s / %s" % [daisy_kept, daisy_was, str(daisy.get("count")), str(daisy.get("was"))])
		return false
	if bool(coin.get("doubled")) or bool(coin.get("sign_plus")):
		_fail("pause coin chip should be the half variant (no plus, not doubled)")
		return false
	return true
