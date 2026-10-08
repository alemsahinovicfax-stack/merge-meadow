extends SceneTree

## Dev: snima svaki pop-up u igri (design_handoff_popups) u SubViewport 1080 x 1920 — imena
## fajlova su `<ID>_<stanje>` kao u PopupsScreen.dc.html, pa se direktno porede s dizajnom.
## Save se vraća na kraju. Pokretanje BEZ --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/popups_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	await create_timer(sec).timeout


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	_svp.get_texture().get_image().save_png(_out.path_join("%s.png" % shot))
	print("captured ", shot)


func _page(hub: Node, index: int) -> Node:
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	return host.get_node_or_null("Page_%d" % index)


func _base_state() -> void:
	_gs.set("tutorial_complete", true)
	_gs.set("wallet_coins", 220)
	_gs.set("seed_bag", {"clover": 14, "daisy": 9, "buttercup": 5})
	_gs.set("garden_crystal_stash", {"clover": 3, "daisy": 1})
	_gs.set("loadout_type_id", "daisy")


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_base_state()
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	await _home_shots()
	await _hub_shots()
	await _arena_shots()
	await _run_shots()
	await _loot_shots()
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _new_hub() -> Node:
	for c in _svp.get_children():
		c.queue_free()
	await _frames(2)
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(30)
	return hub


func _open_field(menu: Node) -> void:
	menu.get_node("%SeasonStage").call("open_season_field", _gs.get("active_season_id"), false)
	await _frames(20)


func _home_shots() -> void:
	# H1 / H2 — prvi start.
	_gs.set("tutorial_complete", false)
	var hub: Node = await _new_hub()
	var menu: Node = _page(hub, MetaHubPages.MAIN)
	menu.call("_refresh_tutorial_hint")
	await _wait(0.5)
	await _capture("H1_default")
	await _open_field(menu)
	menu.call("_refresh_tutorial_hint")
	await _frames(6)
	await _capture("H2_default")
	_gs.set("tutorial_complete", true)
	hub = await _new_hub()
	menu = _page(hub, MetaHubPages.MAIN)
	await _open_field(menu)
	# H3 — poklon.
	menu.call("show_gift_claimed", 8, "daisy", 3)
	await _wait(0.6)
	await _capture("H3_claimed")
	menu.call("show_gift_claimed", 8, "daisy", 1)
	await _wait(0.6)
	await _capture("H3_near_full")
	menu.call("show_gift_tomorrow")
	await _wait(0.4)
	await _capture("H3_tomorrow")
	menu.call("_hide_reward_overlay")
	# H4 — korpa (izabrana Field Daisy, dio zaključan).
	menu.call("_open_basket_picker")
	await _wait(0.45)
	await _capture("H4_one")
	menu.call("_close_basket_picker")
	# H5 — nadogradnje: obje mogu, pa trenutak kupovine.
	_gs.set("garden_crystal_stash", {"clover": 4})
	menu.call("_open_upgrades_sheet")
	await _wait(0.45)
	await _capture("H5_both")
	menu.call("_on_field_magnet_pressed")
	await _frames(4)
	await _capture("H5_buy")
	await _wait(0.5)
	await _capture("H5_short")
	menu.call("_close_upgrades_sheet")
	# H6 / H7 — Ormar u tokenima sistema, toast poslije.
	menu.call("_open_wardrobe")
	await _wait(0.6)
	await _capture("H6_default")
	menu.call("_close_wardrobe", false)
	await _frames(10)
	var toast: Node = menu.get_node_or_null("%FieldOverlayInner/ApplyToast")
	if toast:
		toast.call("show_text", "Runs use Sunset Meadow", UiWardrobe.icon("res://assets/ui/wardrobe/slot_meadow.svg"))
		await _wait(0.3)
		await _capture("H7_default")
	# H8 — „Unlocked" / „Yours" na kartici sezone.
	hub = await _new_hub()
	menu = _page(hub, MetaHubPages.MAIN)
	var stage: Node = menu.get_node("%SeasonStage")
	stage.call("_show_toast", "Unlocked")
	await _frames(8)
	await _capture("H8_unlocked")
	stage.call("_show_toast", "Yours")
	await _frames(8)
	await _capture("H8_yours")


func _hub_shots() -> void:
	var hub: Node = await _new_hub()
	hub.call("_show_settings_toast")
	await _wait(0.3)
	await _capture("X1_default")
	hub.call("go_to_page", MetaHubPages.SHOP, false)
	await _frames(20)
	hub.call("show_coin_spend_pop", 150)
	var shop: Node = _page(hub, MetaHubPages.SHOP)
	var shop_toast := shop.find_child("Toast", true, false)
	if shop_toast and shop_toast.has_method("show_text"):
		shop_toast.call("show_text", "Moonlit Warren is yours")
	await _wait(0.25)
	await _capture("S1_default")
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await _frames(30)
	var camp: Node = _page(hub, MetaHubPages.CAMP)
	for n in camp.find_children("*", "", true, false):
		if n.has_method("add_gain"):
			n.call("add_gain", 12)
			await _wait(0.3)
			await _capture("C1_hold")
			n.call("release_gain")
			await _wait(0.2)
			await _capture("C1_fly")
			break


func _arena_shots() -> void:
	_gs.set("tutorial_complete", true)
	var hub: Node = await _new_hub()
	hub.call("go_to_page", MetaHubPages.ARENA, false)
	await _frames(30)
	var arena: Node = _page(hub, MetaHubPages.ARENA)
	var cue: Object = arena.get("_cue")
	cue.call("set_tutorial_visible", true)
	await _wait(0.3)
	await _capture("A1_default")
	cue.call("set_tutorial_visible", false)
	_gs.set("seed_bag", {"clover": 46, "daisy": 4})
	arena.call("_on_bag_clicked")
	await _frames(40)
	cue.call("show_message", "Muncher's awake — a T3 freezes it 2s.")
	await _wait(0.3)
	await _capture("A2_default")
	hub.call("show_coin_earn_pop", 2)
	await _wait(0.1)
	await _capture("A4_default")
	arena.call("_clear_field_chips")
	await _frames(30)
	cue.call("_restore_tutorial")
	cue.call("set_tutorial_visible", false)
	_gs.set("seed_bag", {"clover": 3, "daisy": 2, "buttercup": 1, "tulip": 2, "sunflower": 2})
	arena.call("_on_bag_clicked")
	await _wait(0.4)
	await _capture("A3_five")
	arena.call("_hide_need_more_overlay")
	_gs.set("seed_bag", {"buttercup": 1})
	arena.call("_on_bag_clicked")
	await _wait(0.4)
	await _capture("A3_one")


func _run_shots() -> void:
	for c in _svp.get_children():
		c.queue_free()
	await _frames(2)
	_gs.set("tutorial_complete", true)
	var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(40)
	run.set("coin_count", 12)
	run.set("seeds_by_type", {"clover": 5})
	run.call("_update_hud")
	run.call("_show_tutorial", "Coins for the shop!")
	await _wait(0.3)
	await _capture("R1_default")
	run.call("_hide_tutorial")
	var feed: Node = run.get("pickup_feed")
	feed.call("push_seed", "daisy", Vector2(540, 1300))
	feed.call("push_seed", "clover", Vector2(540, 1300))
	await _wait(0.2)
	await _capture("R2_two")
	await _wait(1.6)
	_gs.set("last_run_snapshot", ImageTexture.create_from_image(_svp.get_texture().get_image()))
	run.call("_on_pause_pressed")
	await _wait(0.35)
	await _capture("R3_default")
	run.get("pause_overlay").call("close", false)
	run.call("_show_banner", true)
	await _wait(0.3)
	await _capture("R4_time")
	run.call("_show_banner", false)
	await _wait(0.3)
	await _capture("R4_ouch")
	run.queue_free()
	await _frames(4)


func _loot(seeds: Dictionary, coins: int, failed: bool, tutorial: bool = true) -> Node:
	for c in _svp.get_children():
		c.queue_free()
	await _frames(2)
	_gs.set("tutorial_complete", tutorial)
	_gs.set("revive_used_this_run", false)
	_gs.call("finish_run", seeds, coins, failed, 41.0)
	var loot := (load("res://scenes/ui/loot_screen.tscn") as PackedScene).instantiate()
	_svp.add_child(loot)
	await _wait(0.6)
	return loot


func _loot_shots() -> void:
	var loot: Node = await _loot({"clover": 6, "daisy": 4}, 18, true)
	await _capture("R5_fail")
	loot.set("double_state", "loading")
	loot.call("_apply_buttons")
	await _frames(4)
	await _capture("R5_loading")
	loot.set("double_state", "none")
	loot.set("revive_state", "none")
	loot.call("_apply_buttons")
	await _frames(4)
	await _capture("R5_fail_noads")
	loot = await _loot({"clover": 6, "daisy": 4}, 18, true, false)
	await _capture("R5_fail_tutorial")
	loot = await _loot({"clover": 5, "daisy": 3, "tulip": 2}, 24, false)
	await _capture("R5_complete")
	_gs.call("double_loot_placeholder")
	loot.set("double_state", "done")
	loot.call("_build")
	await _wait(0.4)
	await _capture("R5_doubled")
	loot = await _loot({"clover": 5, "daisy": 3, "tulip": 2, "buttercup": 2, "sunflower": 1, "pumpkin": 1}, 31, false)
	await _capture("R5_many")
	loot.set("retry_loading", true)
	loot.call("_apply_buttons")
	await _frames(4)
	await _capture("R5_retry_loading")
	_gs.set("tutorial_complete", true)
