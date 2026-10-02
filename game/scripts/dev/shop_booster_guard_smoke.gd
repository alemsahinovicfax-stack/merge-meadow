extends SceneTree

## Shop v2 · nove ponude (stub IAP): Merge Hint je jednokratan („Yours", ne prodaje se
## ponovo), Loot Burst daje +5 ★3 cvjetova sezone koja otključava sljedeću besplatnu i
## nestaje kad je sve otključano („All set here"), Starter Pack daje 100 coina + Pip
## Blossom + 5 × 10 sjemenki bez Merge Hinta i poslije 7 dana je istekao (veo, ne kupuje se).
## Stara zaliha boostera se migrira (merge_hint > 0 → owned).

var _backup := ""


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("shop_booster_guard_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _buy(sku: String) -> void:
	var iap := get_root().get_node("IAPManager")
	iap.call("purchase", sku)
	await create_timer(1.2).timeout


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var gs := _gs()
	var iap := get_root().get_node_or_null("IAPManager")
	if gs == null or iap == null:
		_fail("GameState / IAPManager missing")
		return
	iap.call("reset_purchases_for_dev")
	gs.set("merge_hint_owned", false)
	gs.call("reset_seasons_to_s1")
	gs.set("garden_crystal_stash", {})
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		_fail("shop load failed %d" % err)
		return
	await _frames(20)
	var shop := current_scene as Control

	# Migracija stare zalihe.
	var boosters: Object = gs.get("boosters")
	boosters.set("inventory", {"merge_hint": 2})
	boosters.call("migrate_legacy_inventory")
	if not bool(gs.get("merge_hint_owned")) or not (boosters.get("inventory") as Dictionary).is_empty():
		_fail("legacy merge_hint stock should become owned")
		return
	gs.set("merge_hint_owned", false)

	# Merge Hint: jednokratno.
	shop.call("refresh_shop")
	var hint: Node = shop.call("get_booster_card", "merge_hint")
	if str(hint.call("get_state")) != "money.buy":
		_fail("Merge Hint should be for sale, got %s" % str(hint.call("get_state")))
		return
	await _buy("booster_merge_hint")
	await _frames(3)
	if not bool(gs.get("merge_hint_owned")) or str(hint.call("get_state")) != "owned":
		_fail("Merge Hint should be owned after purchase")
		return
	if not bool(iap.call("owns_product", "booster_merge_hint")):
		_fail("Merge Hint should be a non-consumable")
		return

	# Loot Burst: +5 ★3 za sljedeću besplatnu sezonu.
	var target: Dictionary = gs.call("get_loot_burst_target")
	if target.is_empty() or str(target["next"]) != "frost_orchard" or str(target["flower"]) != "pumpkin":
		_fail("Loot Burst target should be 5 × pumpkin for Frost Orchard, got %s" % str(target))
		return
	await _buy("booster_loot_burst")
	await _buy("booster_loot_burst")
	var stash: Dictionary = gs.get("garden_crystal_stash")
	if int(stash.get("pumpkin", 0)) != 10:
		_fail("two Loot Bursts should give 10 pumpkins, got %d" % int(stash.get("pumpkin", 0)))
		return
	var loot: Control = shop.call("get_booster_card", "loot_burst")
	if not loot.visible or bool(shop.call("is_all_set_visible")):
		_fail("Loot Burst should still be on sale")
		return
	# Sve besplatne otključane → nema Loot Bursta, „All set here".
	var unlocked: Array = gs.get("unlocked_seasons")
	for id in ["frost_orchard", "lantern_meadow", "amber_canopy"]:
		if not unlocked.has(id):
			unlocked.append(id)
	shop.call("refresh_shop")
	await _frames(3)
	if bool(gs.call("can_buy_loot_burst")) or loot.visible:
		_fail("Loot Burst should disappear when every free season is unlocked")
		return
	if not bool(shop.call("is_all_set_visible")):
		_fail("Boosters should end with All set here")
		return

	# Starter Pack: sadržaj.
	gs.set("wallet_coins", 0)
	gs.set("seed_bag", {})
	var cosmetics: Object = gs.get("cosmetics")
	cosmetics.set("owned", {})
	cosmetics.set("equipped", {})
	gs.set("first_launch_unix", int(Time.get_unix_time_from_system()))
	shop.call("refresh_shop")
	var starter: Node = shop.call("get_support_card", "starter_pack")
	if str(starter.call("get_starter_state")) != "available":
		_fail("Starter Pack should be available on day one")
		return
	await _buy("starter_pack")
	if int(gs.get("wallet_coins")) != 100:
		_fail("Starter Pack should give 100 coins, got %d" % int(gs.get("wallet_coins")))
		return
	if not bool(gs.call("owns_cosmetic", "pip_blossom")):
		_fail("Starter Pack should give Pip Blossom")
		return
	var bag: Dictionary = gs.get("seed_bag")
	for t in ["clover", "daisy", "buttercup", "tulip", "sunflower"]:
		if int(bag.get(t, 0)) != 10:
			_fail("Starter Pack should give 10 %s, bag %s" % [t, str(bag)])
			return
	if str(starter.call("get_state")) != "owned":
		_fail("bought Starter Pack should be Claimed")
		return

	# Istek: 7 dana bez kupovine → veo, purchase odbijen.
	iap.call("reset_purchases_for_dev")
	gs.set("first_launch_unix", int(Time.get_unix_time_from_system()) - 8 * 86400)
	shop.call("refresh_shop")
	await _frames(3)
	if str(starter.call("get_starter_state")) != "expired" or not bool(starter.call("is_expired_veil_visible")):
		_fail("Starter Pack should be expired after 7 days")
		return
	var coins_before := int(gs.get("wallet_coins"))
	await _buy("starter_pack")
	if bool(gs.get("starter_pack_owned")) or int(gs.get("wallet_coins")) != coins_before:
		_fail("an expired Starter Pack must not be bought")
		return
	iap.call("reset_purchases_for_dev")
	CampSmokeUtil.restore_save(self, _backup)
	print("shop_booster_guard_smoke OK")
	quit(0)
