extends SceneTree

## Dev: snima svaki pop-up u igri (modali, sheetovi, oblačići, toastovi, leteće poruke)
## u SubViewport 1080 x 1920 — referenca za popups-cd-brief. Save se vraća na kraju.
## Pokretanje BEZ --headless:
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


func _home_shots() -> void:
	# Prvi start: hint oko Play i hint na polju.
	_gs.set("tutorial_complete", false)
	var hub: Node = await _new_hub()
	var menu: Node = _page(hub, MetaHubPages.MAIN)
	menu.call("_refresh_tutorial_hint")
	await _frames(20)
	await _capture("01_home_first_run_hint")
	var stage: Node = menu.get_node("%SeasonStage")
	stage.call("open_season_field", _gs.get("active_season_id"), false)
	await _frames(20)
	menu.call("_refresh_tutorial_hint")
	await _frames(6)
	await _capture("02_field_basket_locked_hint")
	_gs.set("tutorial_complete", true)
	hub = await _new_hub()
	menu = _page(hub, MetaHubPages.MAIN)
	stage = menu.get_node("%SeasonStage")
	stage.call("open_season_field", _gs.get("active_season_id"), false)
	await _frames(20)
	# Poklon: dobijen danas, pa „Come back tomorrow".
	var msg: String = _gs.call("claim_daily_chest")
	menu.call("_show_reward_overlay", "Daily gift!", msg)
	await _frames(6)
	await _capture("03_gift_claimed")
	menu.call("_show_reward_overlay", "Come back tomorrow", "Daily chest already opened today.")
	await _frames(6)
	await _capture("04_gift_come_back")
	menu.call("_hide_reward_overlay")
	menu.call("_open_basket_picker")
	await _frames(10)
	await _capture("05_basket_picker")
	menu.call("_close_basket_picker")
	menu.call("_open_upgrades_sheet")
	await _frames(10)
	await _capture("06_upgrades_sheet")
	menu.call("_close_upgrades_sheet")
	menu.call("_open_wardrobe")
	await _frames(40)
	await _capture("07_wardrobe_sheet_reference")
	menu.call("_close_wardrobe", false)
	await _frames(10)
	var toast: Node = menu.get_node_or_null("%FieldOverlayInner/ApplyToast")
	if toast:
		toast.call("show_text", "Runs use Sunset Meadow")
		await _frames(12)
		await _capture("08_wardrobe_apply_toast")
	# Home kartica: „Unlocked" toast i settings toast u headeru.
	hub = await _new_hub()
	menu = _page(hub, MetaHubPages.MAIN)
	stage = menu.get_node("%SeasonStage")
	stage.call("_show_toast", "Unlocked")
	await _frames(8)
	await _capture("09_home_unlocked_toast")
	hub.call("_show_settings_toast")
	await _frames(14)
	await _capture("10_settings_toast")
	# Shop: potrošnja coina (pop ispod coin chipa) i Shop toast.
	hub.call("go_to_page", MetaHubPages.SHOP, false)
	await _frames(20)
	hub.call("show_coin_spend_pop", 150)
	var shop: Node = _page(hub, MetaHubPages.SHOP)
	var shop_toast := shop.find_child("Toast", true, false)
	if shop_toast and shop_toast.has_method("show_text"):
		shop_toast.call("show_text", "Moonlit Warren is yours")
	await _frames(10)
	await _capture("11_shop_coin_pop_and_toast")
	# Camp: „+N" prodaje.
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await _frames(30)
	var camp: Node = _page(hub, MetaHubPages.CAMP)
	var bar := camp.find_child("TradeBar", true, false) if camp else null
	if bar == null and camp:
		for n in camp.find_children("*", "", true, false):
			if n.has_method("add_gain"):
				bar = n
				break
	if bar:
		bar.call("add_gain", 12)
		await _frames(12)
		await _capture("12_camp_trade_gain")


func _arena_shots() -> void:
	_gs.set("tutorial_complete", true)
	var hub: Node = await _new_hub()
	hub.call("go_to_page", MetaHubPages.ARENA, false)
	await _frames(30)
	var arena: Node = _page(hub, MetaHubPages.ARENA)
	# Tutorial oblačić (prazno polje, merge tutorial još nije gotov).
	var cue: Object = arena.get("_cue")
	cue.call("set_tutorial_visible", true)
	await _frames(8)
	await _capture("13_arena_tutorial_cue")
	cue.call("set_tutorial_visible", false)
	_gs.set("seed_bag", {"clover": 8, "daisy": 4})
	arena.call("_on_bag_clicked")
	await _frames(40)
	cue.call("show_message", "Muncher's awake — a T3 freezes it 2s.")
	await _frames(10)
	await _capture("14_arena_muncher_cue_and_nav_lock")
	arena.call("_clear_field_chips")
	await _frames(30)
	cue.call("_kill_message_tween")
	(cue.get("cue") as Control).visible = false
	# Ostatak u korpi: nijedan tip nema 4 → tap na korpu otvara „You need more seeds!".
	_gs.set("seed_bag", {"clover": 3, "daisy": 2, "buttercup": 1, "tulip": 3, "sunflower": 1})
	arena.call("_on_bag_clicked")
	await _frames(10)
	await _capture("15_arena_need_more_seeds")
	arena.call("_hide_need_more_overlay")
	hub.call("show_coin_earn_pop", 2)
	await _frames(8)
	await _capture("16_arena_coin_earn_pop")


func _run_shots() -> void:
	for c in _svp.get_children():
		c.queue_free()
	await _frames(2)
	_gs.set("tutorial_complete", true)
	var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(40)
	run.call("_show_tutorial", "Coins for the shop!")
	var feed: Node = run.get("pickup_feed")
	if feed:
		feed.call("push_seed", "daisy", Vector2(540, 1300))
	await _frames(6)
	await _capture("17_run_tutorial_cue_and_pickup")
	run.call("_hide_tutorial")
	run.call("_on_pause_pressed")
	await _frames(8)
	await _capture("18_run_pause")
	(run.get("pause_overlay") as Control).visible = false
	(run.get("finish_banner") as Control).visible = true
	await _frames(6)
	await _capture("19_run_finish_banner")
	run.queue_free()
	await _frames(4)


func _loot_shots() -> void:
	_gs.set("tutorial_complete", true)
	_gs.set("revive_used_this_run", false)
	_gs.set("loot_doubled", false)
	_gs.call("finish_run", {"clover": 6, "daisy": 3}, 18, true, 41.0)
	_svp.add_child((load("res://scenes/ui/loot_screen.tscn") as PackedScene).instantiate())
	await _frames(20)
	await _capture("20_loot_run_failed")
	for c in _svp.get_children():
		c.queue_free()
	await _frames(2)
	_gs.set("loot_doubled", false)
	_gs.call("finish_run", {"clover": 8, "daisy": 5, "buttercup": 2}, 34, false, 60.0)
	_svp.add_child((load("res://scenes/ui/loot_screen.tscn") as PackedScene).instantiate())
	await _frames(20)
	await _capture("21_loot_run_complete")
