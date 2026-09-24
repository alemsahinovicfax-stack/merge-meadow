extends SceneTree

## Shop redizajn (design_handoff_shop): cetiri sekcije u jednom skrolu, sticky
## chipovi, kartice sezona s rosterom i fair note na dnu.

var _backup := ""


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("shop_open_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		_fail("shop failed %d" % err)
		return
	await _frames(20)
	var shop := current_scene as Control
	if shop == null:
		_fail("current_scene missing")
		return

	var bg := shop.get_node_or_null("Bg") as ColorRect
	if bg == null or bg.color != Color("#2E4733"):
		_fail("page background should be #2E4733")
		return

	var chips: Array = shop.call("get_jump_chips")
	if chips.size() != 4:
		_fail("expected 4 jump chips, got %d" % chips.size())
		return
	var labels: Array[String] = []
	for chip in chips:
		labels.append(str(chip.call("get_label_text")))
	if labels != ["Looks", "Seasons", "Boosters", "Support"]:
		_fail("jump chips %s" % str(labels))
		return
	if str(shop.call("active_section")) != "looks":
		_fail("shop should open on Looks")
		return

	for slot_id in ["pip_skin", "meadow_bg", "journal_frame"]:
		if shop.find_child("CosmeticSlot_%s" % slot_id, true, false) == null:
			_fail("missing cosmetic slot %s" % slot_id)
			return
	var cosmetic_count := 0
	for child in shop.find_children("Cosmetic_*", "", true, false):
		cosmetic_count += 1
	if cosmetic_count != 5:
		_fail("expected 5 cosmetic cards, got %d" % cosmetic_count)
		return

	var seasons := shop.call("section_node", "seasons") as Control
	if seasons == null:
		_fail("seasons section missing")
		return
	var packs := 0
	for child in seasons.get_children():
		if child.has_method("get_state"):
			packs += 1
			if child.get("sku") == null or str(child.get("sku")).is_empty():
				_fail("pack card without sku")
				return
			if int(child.call("roster_slot_count")) < 6:
				_fail("season card should show 6 roster slots")
				return
	if packs != 4:
		_fail("expected 4 season cards, got %d" % packs)
		return

	var ember: Node = shop.call("get_season_card", "season_pack_ember_fen")
	if ember == null or str(ember.call("get_state")) != "soon":
		_fail("Ember Fen should be coming soon")
		return
	if not str(ember.call("get_price_text")).is_empty():
		_fail("coming soon card must not show a price")
		return
	if str(ember.call("get_tag_text")) != "COMING SOON":
		_fail("coming soon tag missing")
		return

	if not str(shop.call("get_fair_note_text")).begins_with("Everything here is optional"):
		_fail("fair note missing")
		return
	if bool(shop.call("is_restore_visible")):
		_fail("restore should be hidden in stub mode")
		return

	CampSmokeUtil.restore_save(self, _backup)
	print("shop_open_smoke OK")
	quit(0)
