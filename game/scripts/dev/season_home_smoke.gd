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


func _label_has_ellipsis(ctrl: Control) -> bool:
	if ctrl == null:
		return false
	for node in ctrl.find_children("*", "Label", true, false):
		var t := (node as Label).text
		if t.find("…") >= 0 or t.find("...") >= 0:
			return true
	return false


func _rgb_equal(a: Color, b: Color) -> bool:
	return is_equal_approx(a.r, b.r) and is_equal_approx(a.g, b.g) and is_equal_approx(a.b, b.b)


func _today() -> String:
	var d := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]


func _caption_has_arena(text: String) -> bool:
	return text.find("Arena streak") >= 0 or text.find("Arena daily") >= 0


func _assert_home_daily_gift(home: Node, gs: Node) -> String:
	gs.set("last_daily_chest_day", "")
	if home.has_method("_refresh_chest_card"):
		home.call("_refresh_chest_card")
	var caption: Label = home.get_node_or_null("%DailyCaption") as Label
	if caption == null:
		return "DailyCaption missing"
	if caption.text != "Tap to open":
		return "ready DailyCaption expected Tap to open got %s" % caption.text
	if home.has_method("is_chest_attention_active") and not bool(home.call("is_chest_attention_active")):
		return "ready daily chest should blink/shake"
	if _caption_has_arena(caption.text):
		return "ready DailyCaption must not mention arena"
	gs.set("arena_daily_day", _today())
	gs.set("arena_daily_kind", "merge_t2")
	gs.set("arena_daily_goal", 3)
	gs.set("arena_daily_progress", 3)
	gs.set("arena_daily_claimed_day", "")
	gs.set("arena_daily_streak", 7)
	if not home.has_method("_finish_chest_claim"):
		return "home missing _finish_chest_claim"
	home.call("_finish_chest_claim")
	if int(gs.get("arena_daily_streak")) != 7:
		return "claim_daily_chest must not bump arena_daily_streak"
	if caption.text != "Back tomorrow":
		return "claimed DailyCaption expected Back tomorrow got %s" % caption.text
	if home.has_method("is_chest_attention_active") and bool(home.call("is_chest_attention_active")):
		return "claimed daily chest should stop attention"
	if _caption_has_arena(caption.text):
		return "claimed DailyCaption must not mention arena"
	if home.has_method("_on_daily_chest_pressed"):
		home.call("_on_daily_chest_pressed")
	if int(gs.get("arena_daily_streak")) != 7:
		return "claimed Daily tap must not bump arena_daily_streak"
	var reward_title: Label = home.get_node_or_null("%RewardTitle") as Label
	if reward_title == null:
		return "RewardTitle missing"
	if reward_title.text.find("Come back tomorrow") < 0:
		return "claimed overlay title expected Come back tomorrow got %s" % reward_title.text
	if reward_title.text == "Arena daily!":
		return "claimed Daily overlay must not be Arena daily"
	var reward_body: Label = home.get_node_or_null("%RewardBody") as Label
	if reward_body == null:
		return "RewardBody missing"
	if reward_body.text.find("already opened today") < 0:
		return "claimed overlay body expected already opened today got %s" % reward_body.text
	if reward_body.text.findn("come back tomorrow") >= 0:
		return "claimed overlay body must not repeat come back tomorrow got %s" % reward_body.text
	var already := str(gs.call("claim_daily_chest"))
	if already.findn("come back tomorrow") >= 0:
		return "claim_daily_chest already-claimed must not say come back tomorrow got %s" % already
	if already.find("already opened today") < 0:
		return "claim_daily_chest already-claimed expected already opened today got %s" % already
	if home.has_method("_hide_reward_overlay"):
		home.call("_hide_reward_overlay")
	return ""


func _assert_open_field_hub_swipe(home: Node, swipe: Node, field: Control) -> String:
	if swipe == null or not swipe.has_method("should_block_hub_swipe_at"):
		return "SwipePager missing should_block_hub_swipe_at"
	var mid_ctrl := field
	if mid_ctrl == null or not mid_ctrl.visible:
		mid_ctrl = home.get_node_or_null("%SeasonStage") as Control
	if mid_ctrl == null:
		return "SeasonField/Stage missing for swipe check"
	var mid: Vector2 = mid_ctrl.get_global_rect().get_center()
	if bool(swipe.call("should_block_hub_swipe_at", mid)):
		return "field mid should not block hub swipe"
	var chrome: Control = home.get_node_or_null("%DailyChestCard") as Control
	if chrome == null or not chrome.visible:
		chrome = home.get_node_or_null("%PlayRow") as Control
	if chrome == null:
		return "Daily/PlayRow missing for swipe chrome check"
	var chrome_mid: Vector2 = chrome.get_global_rect().get_center()
	if not bool(swipe.call("should_block_hub_swipe_at", chrome_mid)):
		return "Daily or PlayRow should block hub swipe"
	return ""


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
	if endless_btn.visible:
		_fail("carousel EndlessPlayButton should be hidden after tutorial")
		return
	var seasons_row_home: Control = home.get_node_or_null("%SeasonsRowButton") as Control
	if seasons_row_home == null:
		_fail("SeasonsRowButton missing")
		return
	if seasons_row_home.visible:
		_fail("carousel SeasonsRowButton should be hidden")
		return
	var basket_home: Control = home.get_node_or_null("%BasketCard") as Control
	if basket_home and basket_home.visible:
		_fail("carousel BasketCard should be hidden")
		return
	var daily_err := _assert_home_daily_gift(home, gs)
	if not daily_err.is_empty():
		_fail(daily_err)
		return
	var play_btn_home: Control = home.get_node_or_null("%PlayButton") as Control
	if play_btn_home == null:
		_fail("PlayButton missing")
		return
	if not is_equal_approx(play_btn_home.custom_minimum_size.y, 96.0):
		_fail("carousel Play min height expected 96 got %s" % str(play_btn_home.custom_minimum_size))
		return
	var pip_portrait: Control = home.get_node_or_null("%PipPortrait") as Control
	if pip_portrait == null:
		_fail("PipPortrait missing")
		return
	if pip_portrait.visible:
		_fail("PipPortrait should be hidden")
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
	if stage.has_method("swap_home_band"):
		stage.call("swap_home_band", "paid", "coral_tide")
		await process_frame
		await process_frame
	if str(gs.get("home_band")) != "paid":
		_fail("LIFE-A setup: expected paid band")
		return
	if bool(gs.call("is_season_playable", "coral_tide")):
		_fail("LIFE-A: coral_tide should be unowned")
		return
	if str(home.call("home_play_action")) != "snap":
		_fail("LIFE-A unowned paid: home_play_action should be snap")
		return
	home.call("_on_play_pressed")
	await process_frame
	await process_frame
	if bool(gs.get("home_season_field_open")):
		_fail("LIFE-A paid Play should not open field")
		return
	if str(gs.get("home_band")) != "free":
		_fail("LIFE-A paid Play should snap home_band to free")
		return
	if str(gs.call("home_hero_center_id")) != "country_bloom":
		_fail("LIFE-A paid Play should snap to Bloom")
		return
	if current_scene and str(current_scene.scene_file_path).find("run_scene") >= 0:
		_fail("LIFE-A paid Play should not enter run")
		return
	gs.call("set_paid_strip_focus", "moonlit_warren")
	if stage.has_method("swap_home_band"):
		stage.call("swap_home_band", "free", "country_bloom")
		await process_frame
		await process_frame
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
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
		if browser_open and bool(browser_open.get("visible")):
			_fail("Playable center tap should open field, not Browser")
			return
		if not bool(gs.get("home_season_field_open")):
			_fail("Playable center tap should open season field")
			return
		var field_ctrl: Control = stage.get_node_or_null("%SeasonField") as Control
		var field_swipe_err := _assert_open_field_hub_swipe(home, swipe, field_ctrl)
		if not field_swipe_err.is_empty():
			_fail(field_swipe_err)
			return
		if stage.has_method("close_season_field"):
			stage.call("close_season_field")
		await process_frame

	if stage.has_method("cycle_free_strip"):
		stage.call("cycle_free_strip", 1)
	await create_timer(0.35).timeout
	if str(gs.get("focus_season_id")) != "frost_orchard":
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
	var frost_coin: TextureRect = stage.get_node_or_null("%UnlockCoinIcon") as TextureRect
	var frost_flower: Label = stage.get_node_or_null("%UnlockFlowerName") as Label
	var frost_coins: Label = stage.get_node_or_null("%UnlockGateCoins") as Label
	if frost_coin == null or frost_coin.texture == null:
		_fail("Frost unlock poster coin icon missing texture")
		return
	if frost_flower == null or frost_flower.text.findn("Harvest Pumpkin") < 0:
		_fail("Frost poster flower should be Harvest Pumpkin, got '%s'" % (frost_flower.text if frost_flower else ""))
		return
	if frost_coins == null or frost_coins.text.find("Coins") >= 0:
		_fail("Frost coins label must be n / need, got '%s'" % (frost_coins.text if frost_coins else ""))
		return
	if gate.anchor_left >= 0.5:
		_fail("UnlockGate must sit in the lower-center half, not the right corner")
		return
	if gate.anchor_top < 0.54 or gate.anchor_top >= 0.70:
		_fail("UnlockGate must sit in the lower band, got anchor_top=%s" % gate.anchor_top)
		return
	var unlock_progress: Control = stage.get_node_or_null("%UnlockProgress") as Control
	if unlock_progress == null or unlock_progress.get_node_or_null("SectionDivider") == null:
		_fail("UnlockProgress must have SectionDivider")
		return
	if frost_coin.custom_minimum_size.x > 44.0:
		_fail("Unlock coin side must be <= 44, got %s" % frost_coin.custom_minimum_size.x)
		return
	var frost_flower_visual: Control = unlock_progress.get_node_or_null("FlowerVisual") as Control
	if frost_flower_visual == null or frost_flower_visual.custom_minimum_size.x < 88.0:
		_fail(
			"Unlock flower min side must be >= 88, got %s"
			% (frost_flower_visual.custom_minimum_size.x if frost_flower_visual else 0.0)
		)
		return
	var gate_panel := gate.get_theme_stylebox("panel")
	if gate_panel is StyleBoxFlat:
		var flat := gate_panel as StyleBoxFlat
		if flat.bg_color.a > 0.01:
			_fail("UnlockGate panel must be frameless, bg alpha=%s" % flat.bg_color.a)
			return
		if flat.border_width_left > 0 or flat.border_width_top > 0 or flat.border_width_right > 0 or flat.border_width_bottom > 0:
			_fail("UnlockGate panel must have no border")
			return
	elif gate_panel != null and not (gate_panel is StyleBoxEmpty):
		_fail("UnlockGate panel must be empty or transparent flat")
		return
	if center.text.find("🔒") < 0 or center.text.find("Frost Orchard") < 0:
		_fail("locked Frost center must show lock and name, got '%s'" % center.text)
		return
	if center.vertical_alignment != VERTICAL_ALIGNMENT_CENTER:
		_fail("locked CenterTitle must stay vertically centered")
		return
	var frost_roster: Control = stage.get_node_or_null("%FreeRoster") as Control
	if frost_roster != null and frost_roster.visible:
		_fail("FreeRoster must hide on locked next-lock Frost")
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
	if str(gs.get("focus_season_id")) != "country_bloom":
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
	if _label_has_ellipsis(roster):
		_fail("Bloom roster names must not use ellipsis")
		return
	if center.vertical_alignment != VERTICAL_ALIGNMENT_CENTER:
		_fail("CenterTitle must be vertically centered")
		return
	if not is_equal_approx(center.anchor_bottom, 1.0):
		_fail("CenterTitle must fill the hero card (not top-only)")
		return
	await process_frame
	if roster.position.x < 0.0:
		_fail("FreeRoster must not clip left, position.x=%s" % roster.position.x)
		return
	var center_fill: Control = roster.get_parent() as Control
	if center_fill == null or center_fill.name != "CenterFill":
		_fail("FreeRoster parent must be CenterFill")
		return
	if roster.size.x <= 260.0:
		_fail("FreeRoster should be wider than 260px, got %s" % roster.size.x)
		return
	if roster.size.x < 0.70 * center_fill.size.x:
		_fail("FreeRoster width %s must be >= 0.70 of CenterFill %s" % [roster.size.x, center_fill.size.x])
		return
	var bloom_roster_bg := Color.BLACK
	if roster.has_method("panel_bg_color"):
		bloom_roster_bg = roster.call("panel_bg_color") as Color

	var stage_ctrl := stage as Control
	if stage_ctrl and swipe.has_method("should_block_hub_swipe_at"):
		var mid := stage_ctrl.get_global_rect().get_center()
		if not bool(swipe.call("should_block_hub_swipe_at", mid)):
			_fail("Stage rect should block hub swipe")
			return

	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {"pumpkin": 20})
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
	if str(gs.get("focus_season_id")) != "frost_orchard":
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
		if str(gs.get("focus_season_id")) != "lantern_meadow":
			_fail("next-lock preview tap should center lantern_meadow")
			return
		if sheet != null and bool(sheet.get("visible")):
			_fail("next-lock must not open Unlock sheet")
			return
		if stage.has_method("cycle_free_strip"):
			stage.call("cycle_free_strip", -1)
			await create_timer(0.35).timeout
		if str(gs.get("focus_season_id")) != "frost_orchard":
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
	if str(gs.get("focus_season_id")) != "frost_orchard":
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
		if paid_center_title.vertical_alignment != VERTICAL_ALIGNMENT_CENTER:
			_fail("PaidCenterTitle must be vertically centered")
			return
		var moon_roster: Control = stage.get_node_or_null("%PaidRoster") as Control
		if moon_roster == null or not moon_roster.visible:
			_fail("PaidRoster should show on Moonlit paid-hero")
			return
		if moon_roster.has_method("panel_bg_color"):
			var moon_bg: Color = moon_roster.call("panel_bg_color")
			if _rgb_equal(moon_bg, bloom_roster_bg):
				_fail("Moonlit roster bg RGB should differ from Bloom")
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
	if str(gs.get("focus_season_id")) != "lantern_meadow":
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
		if str(gs.get("focus_season_id")) != "lantern_meadow":
			_fail("swipe-down select must keep lantern strip focus")
			return
	gs.set("wallet_coins", 499)
	gs.set("garden_crystal_stash", {"crystal_peony": 20})
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	if bool(gs.call("can_unlock_free", "lantern_meadow")):
		_fail("lantern must stay locked with 499c")
		return
	if gate_btn == null or gate_btn.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("Unlock with 499c should IGNORE")
		return
	if str(gate_btn.get("button_variant")) != "subtle":
		_fail("Unlock with 499c should stay subtle, got %s" % str(gate_btn.get("button_variant")))
		return
	var coins_lbl: Label = stage.get_node_or_null("%UnlockGateCoins") as Label
	var seeds_lbl: Label = stage.get_node_or_null("%UnlockGateT3") as Label
	var coin_icon: TextureRect = stage.get_node_or_null("%UnlockCoinIcon") as TextureRect
	var flower_name: Label = stage.get_node_or_null("%UnlockFlowerName") as Label
	if coins_lbl == null or coins_lbl.text.find("Coins") >= 0:
		_fail("Lantern coins label must not say Coins, got '%s'" % (coins_lbl.text if coins_lbl else ""))
		return
	if coins_lbl.text.find("/ 500") < 0:
		_fail("Lantern coins bar should show / 500")
		return
	if seeds_lbl == null or seeds_lbl.text.find("/ 20") < 0:
		_fail("Lantern star-3 count should show / 20")
		return
	if seeds_lbl.text.find("★★★") >= 0:
		_fail("Lantern count label should not include stars, got '%s'" % seeds_lbl.text)
		return
	if coin_icon == null or coin_icon.texture == null:
		_fail("Unlock poster coin icon missing texture")
		return
	if flower_name == null or flower_name.text.findn("Crystal Peony") < 0:
		_fail("Lantern poster flower should be Crystal Peony, got '%s'" % (flower_name.text if flower_name else ""))
		return
	if roster != null and roster.visible:
		_fail("FreeRoster must hide on locked Lantern")
		return
	if center.text.find("🔒") < 0 or center.text.find("Lantern Meadow") < 0:
		_fail("locked Lantern center must show lock and name, got '%s'" % center.text)
		return
	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {"crystal_peony": 20})
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	if not bool(gs.call("can_unlock_free", "lantern_meadow")):
		_fail("lantern should be unlockable with 500c/20 Frost star-3")
		return
	if gate == null or not gate.visible:
		_fail("lantern center should show Unlock gate with resources")
		return
	if gate_btn == null or gate_btn.mouse_filter != Control.MOUSE_FILTER_STOP:
		_fail("ready Unlock button should STOP")
		return
	if str(gate_btn.get("button_variant")) != "gold":
		_fail("ready Unlock should be gold, got %s" % str(gate_btn.get("button_variant")))
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
	if roster == null or not roster.visible:
		_fail("FreeRoster should show after lantern unlock")
		return
	if roster.has_method("has_entry") and not bool(roster.call("has_entry", "Paper Lantern Bloom")):
		_fail("Lantern roster expected Paper Lantern Bloom")
		return
	if _label_has_ellipsis(roster):
		_fail("Lantern roster names must not use ellipsis")
		return
	if stage.has_method("cycle_free_strip"):
		stage.call("cycle_free_strip", 1)
		await create_timer(0.35).timeout
	if str(gs.get("focus_season_id")) != "amber_canopy":
		_fail("next-lock Amber should become center after lantern grant")
		return
	if str(gs.get("active_season_id")) == "amber_canopy":
		_fail("amber next-lock must not become active")
		return
	if gate == null or not gate.visible:
		_fail("amber center should show Unlock gate")
		return
	if roster != null and roster.visible:
		_fail("FreeRoster must hide on locked Amber")
		return
	if coins_lbl == null or coins_lbl.text.find("/ 500") < 0:
		_fail("Amber coins bar should show / 500")
		return
	if gate_btn == null or gate_btn.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("disabled Amber Unlock should IGNORE without 500c/20 T3")
		return
	if str(gate_btn.get("button_variant")) != "subtle":
		_fail("disabled Amber Unlock should stay subtle")
		return
	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {"midnight_lotus": 20})
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	if not bool(gs.call("can_unlock_free", "amber_canopy")):
		_fail("amber should be unlockable with 500c/20 Lantern star-3")
		return
	if gate_btn.mouse_filter != Control.MOUSE_FILTER_STOP:
		_fail("ready Amber Unlock button should STOP")
		return
	if str(gate_btn.get("button_variant")) != "gold":
		_fail("ready Amber Unlock should be gold")
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
	if roster == null or not roster.visible:
		_fail("FreeRoster should show after amber unlock")
		return
	if roster.has_method("has_entry") and not bool(roster.call("has_entry", "Golden Oak Bloom")):
		_fail("Amber roster expected Golden Oak Bloom")
		return
	if _label_has_ellipsis(roster):
		_fail("Amber roster names must not use ellipsis")
		return
	if roster.has_method("panel_bg_color"):
		var amber_bg: Color = roster.call("panel_bg_color")
		if amber_bg.is_equal_approx(bloom_roster_bg):
			_fail("Amber roster bg should differ from Bloom")
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
		if _label_has_ellipsis(paid_roster):
			_fail("Coral roster names must not use ellipsis")
			return
		if paid_roster.has_method("panel_bg_color"):
			var coral_bg: Color = paid_roster.call("panel_bg_color")
			if coral_bg.is_equal_approx(bloom_roster_bg):
				_fail("Coral roster bg should differ from Bloom")
				return
		if gate != null and gate.visible:
			_fail("paid unowned must not show coin Unlock gate")
			return

	print("season_home_smoke OK")
	quit(0)
