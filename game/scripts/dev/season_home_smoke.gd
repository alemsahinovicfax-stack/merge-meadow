extends SceneTree

## HOME-B / HOME-02 — 3-slot free strip; hit-through cards; P11 sheet; paid grant does not steal center.

const SAVE_PATH := "user://player_save.json"
const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("season_home_smoke: %s" % msg)
	quit(1)


func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("wallet_coins", 0)
	gs.set("garden_crystal_stash", {})
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.set("tutorial_complete", true)

	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		_fail("hub load failed %d" % err)
		return
	for _i in 16:
		await process_frame

	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		_fail("no meta_hub")
		return
	var hub: Node = hubs[0]
	if hub.has_method("go_to_page"):
		hub.call("go_to_page", MetaHubPages.MAIN, false)
	for _j in 12:
		await process_frame

	var swipe := hub.get_node_or_null("RootVBox/SwipePager")
	if swipe == null:
		_fail("SwipePager missing")
		return
	if int(swipe.get("current_page")) != MetaHubPages.MAIN:
		_fail("expected Home page")
		return

	var host: Node = swipe.call("get_pages_host") if swipe.has_method("get_pages_host") else null
	var home: Node = host.get_node_or_null("Page_%d" % MetaHubPages.MAIN) if host else null
	if home == null:
		_fail("Home page missing")
		return
	if home.get_node_or_null("%HomeTitle") != null:
		_fail("HomeTitle should be removed")
		return
	if home.get_node_or_null("%EasyButton") != null or home.get_node_or_null("HomeColumn/EndlessSection/DifficultyRow") != null:
		_fail("Difficulty row should be removed")
		return
	if home.get_node_or_null("%PlayButton") == null:
		_fail("PlayButton missing")
		return
	var endless_btn: Control = home.get_node_or_null("%EndlessPlayButton") as Control
	if endless_btn == null:
		_fail("EndlessPlayButton missing")
		return
	if not endless_btn.visible:
		_fail("EndlessPlayButton should show after tutorial")
		return
	var stage: Node = home.get_node_or_null("%SeasonStage")
	if stage == null:
		_fail("SeasonStage missing")
		return
	if stage is Control and (stage as Control).mouse_filter != Control.MOUSE_FILTER_STOP:
		_fail("SeasonStage must STOP so it receives strip input")
		return
	var motion: Control = stage.get_node_or_null("%StripMotion") as Control
	if motion == null or motion.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("StripMotion must IGNORE")
		return
	var row_n: Control = motion.get_node_or_null("Row") as Control
	if row_n == null or row_n.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("Row must IGNORE so cards do not eat swipe")
		return
	for slot_name in ["%LeftSlot", "%CenterSlot", "%RightSlot"]:
		var slot_n: Control = stage.get_node_or_null(slot_name) as Control
		if slot_n == null or slot_n.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			_fail("%s must IGNORE" % slot_name)
			return
	var paid_band: Control = stage.get_node_or_null("%PaidBand") as Control
	var free_band: Control = stage.get_node_or_null("%FreeBand") as Control
	if paid_band == null or not paid_band.visible or paid_band.size.y <= 0.0:
		_fail("PaidBand must be visible with height")
		return
	if free_band == null or not free_band.visible or free_band.size.y <= 0.0:
		_fail("FreeBand must be visible with height")
		return
	var stage_ctrl_early := stage as Control
	if stage_ctrl_early == null or stage_ctrl_early.size.y <= 260.0:
		_fail("SeasonStage should be taller than single-strip")
		return
	if str(gs.get("home_band")) != "free":
		_fail("new game home_band should be free")
		return
	var paid_row: Control = stage.get_node_or_null("%PaidRow") as Control
	if paid_row == null or paid_row.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("PaidRow must IGNORE")
		return
	for paid_slot_name in ["%PaidLeftSlot", "%PaidCenterSlot", "%PaidRightSlot"]:
		var paid_slot_n: Control = stage.get_node_or_null(paid_slot_name) as Control
		if paid_slot_n == null or paid_slot_n.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			_fail("%s must IGNORE" % paid_slot_name)
			return
	var paid_left: Control = stage.get_node_or_null("%PaidLeftSlot") as Control
	if paid_left == null or paid_left.visible:
		_fail("Paid left slot should be hidden on new game")
		return
	var paid_center_title: Label = stage.get_node_or_null("%PaidCenterTitle") as Label
	if paid_center_title == null or paid_center_title.text.find("Moonlit") < 0:
		_fail("Paid center expected Moonlit got '%s'" % (paid_center_title.text if paid_center_title else "null"))
		return
	if paid_center_title.text.find("🔒") < 0 and paid_center_title.text.find("€") < 0:
		_fail("Unowned paid center should show lock or price")
		return
	var paid_right_title: Label = stage.get_node_or_null("%PaidRightTitle") as Label
	if paid_right_title == null or paid_right_title.text.find("Coral") < 0:
		_fail("Paid right expected Coral got '%s'" % (paid_right_title.text if paid_right_title else "null"))
		return
	if gs.call("get_season_def", "amber_canopy") == null:
		_fail("amber_canopy missing from catalog")
		return
	if gs.call("get_season_def", "starfall_glade") == null or gs.call("get_season_def", "ember_fen") == null:
		_fail("new paid seasons missing from catalog")
		return
	var center: Label = stage.get_node_or_null("%CenterTitle") as Label
	if center == null or center.text.find("Country Bloom") < 0:
		_fail("Center expected Country Bloom got '%s'" % (center.text if center else "null"))
		return
	var left_slot: Control = stage.get_node_or_null("%LeftSlot") as Control
	if left_slot == null or left_slot.visible:
		_fail("Left slot should be hidden on new game")
		return
	var right: Label = stage.get_node_or_null("%RightTitle") as Label
	if right == null or right.text.find("Frost Orchard") < 0:
		_fail("Right expected Frost Orchard got '%s'" % (right.text if right else "null"))
		return
	if right.text.find("🔒") < 0:
		_fail("Right slot should be locked on new game")
		return

	var center_slot: Control = stage.get_node_or_null("%CenterSlot") as Control
	var paid_center_slot: Control = stage.get_node_or_null("%PaidCenterSlot") as Control
	var right_slot: Control = stage.get_node_or_null("%RightSlot") as Control
	if center_slot and stage.has_method("_handle_tap"):
		var to_local: Transform2D = (stage as Control).get_global_transform().affine_inverse()
		var tap_at: Vector2 = to_local * center_slot.get_global_rect().get_center()
		stage.call("_handle_tap", tap_at)
		await process_frame
		var browser_open: Node = stage.get_node_or_null("%SeasonBrowser")
		if browser_open == null or not bool(browser_open.get("visible")):
			_fail("Center tap should open Browser")
			return
		if browser_open.has_method("close"):
			browser_open.call("close")
		await process_frame

	if stage.has_method("cycle_free_strip"):
		stage.call("cycle_free_strip", 1)
	await create_timer(0.35).timeout
	if str(gs.get("strip_focus_id")) != "frost_orchard":
		_fail("next-lock swipe should center Frost Orchard")
		return
	if str(gs.get("active_season_id")) != "country_bloom":
		_fail("next-lock cycle must not set_active")
		return
	if not bool(gs.call("is_free_selectable", "frost_orchard")):
		_fail("Frost should be free-selectable as next-lock")
		return
	var gate: Control = stage.get_node_or_null("%UnlockGate") as Control
	if gate == null or not gate.visible:
		_fail("next-lock center should show Unlock gate")
		return
	if gate.get_parent() == stage:
		_fail("UnlockGate must not be a Stage overlay")
		return
	var gate_walk: Node = gate
	var gate_in_center := false
	while gate_walk:
		if gate_walk.name == "CenterSlot":
			gate_in_center = true
			break
		gate_walk = gate_walk.get_parent()
	if not gate_in_center:
		_fail("UnlockGate must live inside CenterSlot")
		return
	if gate.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("UnlockGate must IGNORE so swipe passes")
		return
	var gate_btn: Control = stage.get_node_or_null("%UnlockGateButton") as Control
	if gate_btn == null or gate_btn.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("disabled Unlock button should IGNORE")
		return
	stage.call("cycle_free_strip", -1)
	await create_timer(0.35).timeout
	if str(gs.get("strip_focus_id")) != "country_bloom":
		_fail("cycle back should restore Country Bloom")
		return
	if int(swipe.get("current_page")) != MetaHubPages.MAIN:
		_fail("hub page changed after cycle_free_strip")
		return
	if stage.get_node_or_null("%SeasonRoster") != null:
		_fail("Stage overlay SeasonRoster must be removed")
		return
	var roster: Control = stage.get_node_or_null("%FreeRoster") as Control
	if roster == null or roster.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("FreeRoster must IGNORE")
		return
	var roster_walk: Node = roster
	var roster_in_center := false
	while roster_walk:
		if roster_walk.name == "CenterSlot":
			roster_in_center = true
			break
		roster_walk = roster_walk.get_parent()
	if not roster_in_center:
		_fail("FreeRoster must live inside CenterSlot")
		return
	if not roster.visible:
		_fail("FreeRoster should show on free-hero Bloom")
		return
	if roster.has_method("rarity3_display") and str(roster.call("rarity3_display")) != "Harvest Pumpkin":
		_fail("Bloom roster ★★★ expected Harvest Pumpkin")
		return

	var stage_ctrl := stage as Control
	if stage_ctrl and swipe.has_method("should_block_hub_swipe_at"):
		var mid := stage_ctrl.get_global_rect().get_center()
		if not bool(swipe.call("should_block_hub_swipe_at", mid)):
			_fail("Stage rect should block hub swipe")
			return

	gs.set("wallet_coins", 80)
	gs.set("garden_crystal_stash", {"clover": 5})
	if not stage.has_method("open_unlock_sheet"):
		_fail("open_unlock_sheet missing")
		return
	stage.call("open_unlock_sheet", "frost_orchard")
	await process_frame
	var sheet: Node = stage.get_node_or_null("%SeasonUnlockSheet")
	if sheet == null or not bool(sheet.get("visible")):
		_fail("Unlock sheet should be visible")
		return
	var browser: Node = stage.get_node_or_null("%SeasonBrowser")
	if browser and bool(browser.get("visible")):
		_fail("P11: Browser must stay closed on teaser/sheet open")
		return
	if sheet.has_method("_on_unlock_pressed"):
		sheet.call("_on_unlock_pressed")
	for _k in 8:
		await process_frame
	if stage.has_method("cycle_free_strip"):
		stage.call("cycle_free_strip", -1)
		await create_timer(0.35).timeout
		stage.call("cycle_free_strip", 1)
		await create_timer(0.35).timeout
	if str(gs.get("paid_strip_focus_id")) != "moonlit_warren":
		_fail("cycle_free must not change paid_strip_focus_id")
		return
	if str(gs.get("active_season_id")) != "frost_orchard":
		_fail("unlock did not auto-switch active")
		return
	if str(gs.get("strip_focus_id")) != "frost_orchard":
		_fail("unlock did not move strip focus to S2")
		return
	if center.text.find("Frost Orchard") < 0:
		_fail("Center after unlock expected Frost Orchard got '%s'" % center.text)
		return
	var left: Label = stage.get_node_or_null("%LeftTitle") as Label
	if left_slot == null or not left_slot.visible:
		_fail("Left slot should show S1 after unlock")
		return
	if left == null or left.text.find("Country Bloom") < 0:
		_fail("Left expected Country Bloom got '%s'" % (left.text if left else "null"))
		return
	if left.text.find("🔒") >= 0:
		_fail("Left unlocked S1 must not be locked")
		return
	if right.text.find("Lantern Meadow") < 0:
		_fail("Right after S2 expected Lantern Meadow got '%s'" % right.text)
		return
	if right.text.find("🔒") < 0:
		_fail("S3 should stay locked")
		return

	if stage.has_method("swap_home_band"):
		stage.call("swap_home_band", "paid", "coral_tide")
		await create_timer(0.35).timeout
	else:
		_fail("swap_home_band missing")
		return
	if str(gs.get("home_band")) != "paid":
		_fail("swap_home_band should set home_band paid")
		return
	if paid_center_title.text.find("Coral") < 0:
		_fail("Paid center after swap expected Coral got '%s'" % paid_center_title.text)
		return
	if str(gs.get("active_season_id")) != "frost_orchard":
		_fail("unowned Coral swap must not set_active")
		return
	var browser_after_swap: Node = stage.get_node_or_null("%SeasonBrowser")
	if browser_after_swap and bool(browser_after_swap.get("visible")):
		_fail("swap_home_band must not open Browser")
		return
	if stage.has_method("cycle_free_strip"):
		stage.call("cycle_free_strip", -1)
		await create_timer(0.35).timeout
		if str(gs.get("paid_strip_focus_id")) != "coral_tide":
			_fail("cycle_free while paid-hero must not change paid_strip_focus")
			return
		stage.call("cycle_free_strip", 1)
		await create_timer(0.35).timeout
	if paid_center_slot and stage.has_method("_handle_tap"):
		var to_hero: Transform2D = (stage as Control).get_global_transform().affine_inverse()
		var hero_tap: Vector2 = to_hero * paid_center_slot.get_global_rect().get_center()
		stage.call("_handle_tap", hero_tap)
		await process_frame
		if browser_after_swap == null or not bool(browser_after_swap.get("visible")):
			_fail("Hero paid center tap should open Browser")
			return
		if browser_after_swap.has_method("close"):
			browser_after_swap.call("close")
		await process_frame
	if right_slot and stage.has_method("_handle_tap"):
		var to_lock: Transform2D = (stage as Control).get_global_transform().affine_inverse()
		var lock_tap: Vector2 = to_lock * right_slot.get_global_rect().get_center()
		stage.call("_handle_tap", lock_tap)
		await create_timer(0.35).timeout
		if str(gs.get("home_band")) != "free":
			_fail("locked free preview tap should swap to free-hero")
			return
		if str(gs.get("strip_focus_id")) != "lantern_meadow":
			_fail("next-lock preview tap should center lantern_meadow")
			return
		if sheet != null and bool(sheet.get("visible")):
			_fail("next-lock must not open Unlock sheet")
			return
		if stage.has_method("cycle_free_strip"):
			stage.call("cycle_free_strip", -1)
			await create_timer(0.35).timeout
		if str(gs.get("strip_focus_id")) != "frost_orchard":
			_fail("cycle back from lantern should restore frost")
			return
	if int(swipe.get("current_page")) != MetaHubPages.MAIN:
		_fail("hub page changed after paid swap")
		return

	if not bool(gs.call("grant_paid_season", "moonlit_warren")):
		_fail("grant_paid_season moonlit failed")
		return
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	if str(gs.get("active_season_id")) != "moonlit_warren":
		_fail("paid grant should set active")
		return
	if str(gs.get("strip_focus_id")) != "frost_orchard":
		_fail("paid grant must not change strip_focus")
		return
	if str(gs.get("home_band")) != "free":
		_fail("paid grant must not change home_band")
		return
	if center.text.find("Frost Orchard") < 0:
		_fail("Center must stay Frost after paid grant got '%s'" % center.text)
		return
	if center.text.find("Moonlit") >= 0:
		_fail("Paid must not appear on free Home strip")
		return
	if paid_center_title.text.find("Moonlit") < 0:
		_fail("Paid band center should stay Moonlit after grant")
		return
	if paid_center_title.text.find("🔒") >= 0 or paid_center_title.text.find("€") >= 0:
		_fail("Owned Moonlit should not show lock/price")
		return
	if paid_right_title.text.find("Coral") < 0:
		_fail("Coral should remain on paid right")
		return
	if paid_right_title.text.find("🔒") < 0 and paid_right_title.text.find("€") < 0:
		_fail("Unowned Coral should stay locked/priced")
		return
	if home.has_method("_refresh_menu"):
		home.call("_refresh_menu")
	await process_frame
	var badge: Label = home.get_node_or_null("%PlayThemeBadge") as Label
	if badge != null and badge.visible:
		_fail("PlayThemeBadge should stay hidden")
		return
	if bool(gs.call("is_season_playable", "amber_canopy")):
		_fail("amber_canopy should not be playable")
		return
	if bool(gs.call("grant_paid_season", "ember_fen")):
		_fail("ember_fen grant should fail while test-locked")
		return
	if int(swipe.get("current_page")) != MetaHubPages.MAIN:
		_fail("hub page changed after unlock")
		return

	if stage.has_method("_on_browser_selected"):
		stage.call("_on_browser_selected", "moonlit_warren")
		await create_timer(0.35).timeout
		if str(gs.get("home_band")) != "paid":
			_fail("Browser select paid should swap home_band")
			return
		if str(gs.get("paid_strip_focus_id")) != "moonlit_warren":
			_fail("Browser select should center paid season")
			return
		if paid_center_title.text.find("Moonlit") < 0:
			_fail("Browser select should show Moonlit as paid hero center")
			return
		stage.call("swap_home_band", "free", "frost_orchard")
		await create_timer(0.35).timeout
		if str(gs.get("home_band")) != "free":
			_fail("restore free-hero before preview tap")
			return

	if paid_center_slot and stage.has_method("_handle_tap"):
		var to_paid: Transform2D = (stage as Control).get_global_transform().affine_inverse()
		var paid_tap: Vector2 = to_paid * paid_center_slot.get_global_rect().get_center()
		stage.call("_handle_tap", paid_tap)
		await create_timer(0.35).timeout
		if str(gs.get("home_band")) != "paid":
			_fail("tap paid preview should swap home_band to paid")
			return
		var browser_preview: Node = stage.get_node_or_null("%SeasonBrowser")
		if browser_preview and bool(browser_preview.get("visible")):
			_fail("Preview center tap must not open Browser")
			return
		if center_slot and stage.has_method("_handle_tap"):
			var free_tap: Vector2 = to_paid * center_slot.get_global_rect().get_center()
			stage.call("_handle_tap", free_tap)
			await create_timer(0.35).timeout
		if str(gs.get("home_band")) != "free":
			_fail("tap free preview should swap home_band back to free")
			return

	gs.call("debug_unlock_all_seasons")
	if bool(gs.call("is_season_playable", "amber_canopy")):
		_fail("debug_unlock_all must skip amber_canopy")
		return
	if bool(gs.call("is_season_playable", "ember_fen")):
		_fail("debug_unlock_all must skip ember_fen")
		return
	if bool(gs.call("is_season_playable", "lantern_meadow")):
		_fail("debug_unlock_all must skip lantern_meadow")
		return
	if not bool(gs.call("is_free_selectable", "lantern_meadow")):
		_fail("lantern_meadow should stay selectable after debug skip")
		return
	if bool(gs.call("grant_paid_season", "ember_fen")):
		_fail("ember_fen grant should still fail after debug")
		return
	if stage.has_method("cycle_free_strip"):
		stage.call("cycle_free_strip", 1)
		await create_timer(0.35).timeout
	if str(gs.get("strip_focus_id")) != "lantern_meadow":
		_fail("cycle onto lantern should work after debug skip")
		return
	if str(gs.get("active_season_id")) == "lantern_meadow":
		_fail("lantern next-lock must not become active")
		return
	if stage.has_method("_select_focused_or_last_playable"):
		stage.call("_select_focused_or_last_playable")
		await process_frame
		if str(gs.get("active_season_id")) != "frost_orchard":
			_fail("swipe-down on lantern should select last playable frost")
			return
		if str(gs.get("strip_focus_id")) != "lantern_meadow":
			_fail("swipe-down select must keep lantern strip focus")
			return
	gs.set("wallet_coins", 150)
	gs.set("garden_crystal_stash", {"clover": 8})
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	if not bool(gs.call("can_unlock_free", "lantern_meadow")):
		_fail("lantern should be unlockable with 150c/8 T3")
		return
	if gate == null or not gate.visible:
		_fail("lantern center should show Unlock gate with resources")
		return
	if gate_btn == null or gate_btn.mouse_filter != Control.MOUSE_FILTER_STOP:
		_fail("ready Unlock button should STOP")
		return
	if gate.has_method("_on_unlock_clicked"):
		gate.call("_on_unlock_clicked")
	await process_frame
	if not bool(gs.call("is_season_playable", "lantern_meadow")):
		_fail("inline Unlock should grant lantern_meadow")
		return
	if str(gs.get("active_season_id")) != "lantern_meadow":
		_fail("inline Unlock should set active lantern")
		return
	if gate.visible:
		_fail("Unlock gate should hide after lantern grant")
		return
	if stage.has_method("cycle_free_strip"):
		stage.call("cycle_free_strip", 1)
		await create_timer(0.35).timeout
	if str(gs.get("strip_focus_id")) != "amber_canopy":
		_fail("next-lock Amber should become center after lantern grant")
		return
	if str(gs.get("active_season_id")) == "amber_canopy":
		_fail("amber next-lock must not become active")
		return
	if gate == null or not gate.visible:
		_fail("amber center should show Unlock gate")
		return
	if gate_btn == null or gate_btn.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("disabled Amber Unlock should IGNORE without 220c/12 T3")
		return
	gs.set("wallet_coins", 220)
	gs.set("garden_crystal_stash", {"clover": 12})
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	if not bool(gs.call("can_unlock_free", "amber_canopy")):
		_fail("amber should be unlockable with 220c/12 T3")
		return
	if gate_btn.mouse_filter != Control.MOUSE_FILTER_STOP:
		_fail("ready Amber Unlock button should STOP")
		return
	if gate.has_method("_on_unlock_clicked"):
		gate.call("_on_unlock_clicked")
	await process_frame
	if not bool(gs.call("is_season_playable", "amber_canopy")):
		_fail("inline Unlock should grant amber_canopy")
		return
	if str(gs.get("active_season_id")) != "amber_canopy":
		_fail("inline Unlock should set active amber")
		return
	if gate.visible:
		_fail("Unlock gate should hide after amber grant")
		return
	if stage.has_method("cycle_paid_strip"):
		stage.call("swap_home_band", "paid", "coral_tide")
		await create_timer(0.35).timeout
		var paid_roster: Control = stage.get_node_or_null("%PaidRoster") as Control
		if paid_roster == null or not paid_roster.visible:
			_fail("PaidRoster should show on Coral paid-hero")
			return
		var paid_walk: Node = paid_roster
		var roster_in_paid := false
		while paid_walk:
			if paid_walk.name == "PaidCenterSlot":
				roster_in_paid = true
				break
			paid_walk = paid_walk.get_parent()
		if not roster_in_paid:
			_fail("PaidRoster must live inside PaidCenterSlot")
			return
		if roster != null and roster.visible:
			_fail("FreeRoster must hide while paid-hero")
			return
		if paid_roster.has_method("rarity3_display") and str(paid_roster.call("rarity3_display")) != "Reef Crown":
			_fail("Coral unowned roster ★★★ expected Reef Crown")
			return
		if gate != null and gate.visible:
			_fail("paid unowned must not show coin Unlock gate")
			return

	print("season_home_smoke OK")
	quit(0)
