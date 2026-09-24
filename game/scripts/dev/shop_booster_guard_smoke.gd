extends SceneTree

## design_handoff_shop: Use dugme boostera. Bez zalihe ga nema, aktivan Merge Hint
## vodi u Arenu umjesto drugog trosenja, a pun bag blokira Loot Burst.

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


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		_fail("shop load failed %d" % err)
		return
	await _frames(20)
	var shop := current_scene as Control
	var gs := _gs()
	if shop == null or gs == null:
		_fail("shop/GameState missing")
		return
	var boosters: Object = gs.get("boosters")
	boosters.set("inventory", {})
	boosters.set("merge_hint_active", false)
	gs.set("seed_bag", {})
	shop.call("refresh_shop")
	await _frames(3)

	var hint: Node = shop.call("get_booster_card", "merge_hint")
	var burst: Node = shop.call("get_booster_card", "loot_burst")
	if hint == null or burst == null:
		_fail("booster cards missing")
		return
	if str(hint.call("get_use_mode")) != "none":
		_fail("empty stock should hide Use, got %s" % str(hint.call("get_use_mode")))
		return
	if str(hint.call("get_count_text")) != "0":
		_fail("count text %s" % str(hint.call("get_count_text")))
		return

	boosters.set("inventory", {"merge_hint": 2, "loot_burst": 1})
	shop.call("refresh_shop")
	await _frames(3)
	if str(hint.call("get_use_mode")) != "use" or not bool(hint.call("is_use_enabled")):
		_fail("Use should be live with stock")
		return
	if str(hint.call("get_use_text")) != "Use one":
		_fail("use label %s" % str(hint.call("get_use_text")))
		return

	hint.emit_signal("use_pressed", "merge_hint")
	await _frames(3)
	if not bool(boosters.get("merge_hint_active")):
		_fail("merge hint should be armed after Use")
		return
	if int(gs.call("get_booster_count", "merge_hint")) != 1:
		_fail("Use should spend one Merge Hint")
		return
	if str(hint.call("get_use_mode")) != "armed":
		_fail("armed hint should offer the Arena, got %s" % str(hint.call("get_use_mode")))
		return
	if str(hint.call("get_use_text")) != "Go to Arena ↗":
		_fail("armed label %s" % str(hint.call("get_use_text")))
		return

	var cap := int(gs.get("SEED_BAG_SOFT_CAP")) if gs.get("SEED_BAG_SOFT_CAP") != null else 40
	gs.set("seed_bag", {"clover": cap})
	shop.call("refresh_shop")
	await _frames(3)
	if str(burst.call("get_use_mode")) != "full":
		_fail("full bag should block Loot Burst, got %s" % str(burst.call("get_use_mode")))
		return
	if bool(burst.call("is_use_enabled")):
		_fail("blocked Use must not be pressable")
		return
	if str(burst.call("get_use_text")) != "Bag is full":
		_fail("full label %s" % str(burst.call("get_use_text")))
		return

	CampSmokeUtil.restore_save(self, _backup)
	print("shop_booster_guard_smoke OK")
	quit(0)
