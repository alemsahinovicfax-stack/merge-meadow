extends SceneTree

## Dev mjerenje (FIX-TEL-2 2026-11-12): koliko košta JEDAN trejd u Campu (držanje = 10 u sekundi)
## i šta se u njemu troši. Headless = bez crtanja i rasporeda na ekranu; telefon je ~4–8× sporiji
## od laptopa, pa je cilj < 0,5 ms po trejdu ovdje.
##   godot --headless --path game -s res://scripts/dev/camp_trade_bench.gd

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const PARTS := [
	"_refresh_wallet_labels", "_refresh_chip_selection", "_refresh_stash_view", "_refresh_trade_bar",
	"_apply_stash_layout", "_refresh_live_chrome", "_notify_hub_chrome",
]

var _backup := ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _time(node: Object, method: String, n: int = 20) -> float:
	if node == null or not node.has_method(method):
		return -1.0
	var t0 := Time.get_ticks_usec()
	for _i in n:
		node.call(method)
	return float(Time.get_ticks_usec() - t0) / 1000.0 / float(n)


func _run() -> void:
	var gs: Node = root.get_node("GameState")
	gs.set("tutorial_complete", true)
	gs.set("reduce_motion", false)
	var bag := {}
	for type_id in SeedCatalog.types_for_season(str(gs.get("active_season_id"))):
		bag[type_id] = 60
	for type_id in ["clover", "daisy", "buttercup", "tulip", "sunflower"]:
		bag[type_id] = 60
	gs.set("seed_bag", bag)
	change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	await create_timer(4.0).timeout
	var hub: Node = current_scene
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await create_timer(1.5).timeout
	var camp: Node = hub.find_child("Page_%d" % MetaHubPages.CAMP, true, false)
	if camp == null or not camp.has_method("_on_exchange_pressed"):
		push_error("camp_trade_bench: Camp page not found")
		quit(1)
		return
	var button: Object = camp.get("exchange_button")
	# 60 trejdova kao držanje: 10 u sekundi, 6 frejmova između. Mjeri sam poziv i najduži frejm.
	var worst_call := 0.0
	var sum_call := 0.0
	var worst_frame := 0.0
	var n := 60
	for i in n:
		button.set("last_click_was_repeat", i > 0)
		var t0 := Time.get_ticks_usec()
		camp.call("_on_exchange_pressed")
		var ms := float(Time.get_ticks_usec() - t0) / 1000.0
		sum_call += ms
		if ms > 1.5:
			print("slow trade #%d  %.2f ms" % [i, ms])
		worst_call = maxf(worst_call, ms)
		for _f in 6:
			var f0 := Time.get_ticks_usec()
			await process_frame
			worst_frame = maxf(worst_frame, float(Time.get_ticks_usec() - f0) / 1000.0)
	print("bench trade  avg %.3f ms  worst %.3f ms  worst frame between %.3f ms  (%d trades)" % [sum_call / float(n), worst_call, worst_frame, n])
	camp.call("_on_trade_press_ended")
	await create_timer(0.6).timeout
	for m in PARTS:
		print("part camp.%-26s %7.3f ms" % [m, _time(camp, m)])
	var bar: Object = camp.get("exchange_bar")
	print("part bar.%-27s %7.3f ms" % ["_fly_coin", _time(bar, "_fly_coin", 10)])
	var card: Object = camp.get("season_link_card")
	print("part card.%-26s %7.3f ms" % ["refresh", _time(card, "refresh")])
	print("part hub.%-27s %7.3f ms" % ["refresh_top_bar", _time(hub, "refresh_top_bar")])
	print("part hub.%-27s %7.3f ms" % ["_refresh_tab_badges", _time(hub, "_refresh_tab_badges")])
	var t0 := Time.get_ticks_usec()
	for _i in 20:
		camp.call("_trade_step")
	print("part camp.%-26s %7.3f ms" % ["_trade_step", float(Time.get_ticks_usec() - t0) / 20000.0])
	t0 = Time.get_ticks_usec()
	for _i in 20:
		camp.call("_sync_chip_counts", camp.get("seed_bag_grid"), gs.get("seed_bag"))
	print("part camp.%-26s %7.3f ms" % ["_sync_chip_counts", float(Time.get_ticks_usec() - t0) / 20000.0])
	t0 = Time.get_ticks_usec()
	for _i in 20:
		camp.call("_refresh_trade_light")
	print("part camp.%-26s %7.3f ms" % ["_refresh_trade_light", float(Time.get_ticks_usec() - t0) / 20000.0])
	t0 = Time.get_ticks_usec()
	for _i in 20:
		bar.call("add_gain", 1)
	print("part bar.%-27s %7.3f ms" % ["add_gain", float(Time.get_ticks_usec() - t0) / 20000.0])
	t0 = Time.get_ticks_usec()
	for i in 20:
		bar.call("on_hold_tick", i, 40)
	print("part bar.%-27s %7.3f ms" % ["on_hold_tick", float(Time.get_ticks_usec() - t0) / 20000.0])
	t0 = Time.get_ticks_usec()
	for _i in 20:
		Sfx.play("coin")
	print("part %-31s %7.3f ms" % ["Sfx.play(coin)", float(Time.get_ticks_usec() - t0) / 20000.0])
	t0 = Time.get_ticks_usec()
	for _i in 5:
		gs.call("save_player_save")
	print("part %-31s %7.3f ms" % ["GameState.save_player_save", float(Time.get_ticks_usec() - t0) / 5000.0])
	print("camp_trade_bench DONE")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
