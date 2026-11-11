extends SceneTree

## Dev mjerenje (FIX-TEL 2026-11): koliko CPU vremena košta ulazak na svaku stranicu huba.
## Mjeri sinhroni dio prelaza (go_to_page → refresh stranice) i najduži frejm u sljedećih
## 40 frejmova, za 1., 2. i 3. ulazak; na kraju razbija Home i hub refresh po funkcijama.
## Headless = bez crtanja; telefon je ~4–8× sporiji od laptopa, pa je cilj ovdje < 4 ms po ulasku.
##   godot --headless --path game -s res://scripts/dev/hub_switch_bench.gd

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const NAMES := ["shop", "journal", "home", "camp", "arena"]
const HOME_PARTS := [
	"_refresh_tutorial_hint", "refresh_play_chip", "_refresh_basket_card", "_refresh_field_upgrades",
	"_refresh_endless_button", "_refresh_seasons_row_button", "sync_field_backdrop", "_refresh_chest_card",
]
const HUB_PARTS := ["refresh_top_bar", "_refresh_tab_badges"]

var _backup := ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _time(node: Node, method: String, n: int = 5) -> float:
	if node == null or not node.has_method(method):
		return -1.0
	var best := INF
	for _i in n:
		var t0 := Time.get_ticks_usec()
		node.call(method)
		best = minf(best, float(Time.get_ticks_usec() - t0) / 1000.0)
	return best


func _run() -> void:
	var gs: Node = root.get_node("GameState")
	gs.set("tutorial_complete", true)
	change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	await create_timer(4.0).timeout
	var hub: Node = current_scene
	var order := [MetaHubPages.COLLECTION, MetaHubPages.MAIN, MetaHubPages.CAMP, MetaHubPages.MAIN,
		MetaHubPages.COLLECTION, MetaHubPages.SHOP, MetaHubPages.COLLECTION, MetaHubPages.MAIN,
		MetaHubPages.CAMP, MetaHubPages.ARENA, MetaHubPages.CAMP, MetaHubPages.MAIN]
	var visit := {}
	for page in order:
		var t0 := Time.get_ticks_usec()
		hub.call("go_to_page", page, false)
		var sync_ms := float(Time.get_ticks_usec() - t0) / 1000.0
		var worst := 0.0
		for _i in 40:
			var f0 := Time.get_ticks_usec()
			await process_frame
			worst = maxf(worst, float(Time.get_ticks_usec() - f0) / 1000.0)
		visit[page] = int(visit.get(page, 0)) + 1
		print("bench %-8s visit %d  switch %6.2f ms  worst frame after %6.2f ms" % [NAMES[page], visit[page], sync_ms, worst])
		await create_timer(1.3).timeout

	var home: Node = hub.find_child("Page_%d" % MetaHubPages.MAIN, true, false)
	for m in HOME_PARTS:
		print("part home.%-28s %6.2f ms" % [m, _time(home, m)])
	var stage: Node = home.get_node_or_null("%SeasonStage") if home else null
	print("part stage.%-27s %6.2f ms" % ["refresh", _time(stage, "refresh")])
	for m in HUB_PARTS:
		print("part hub.%-29s %6.2f ms" % [m, _time(hub, m)])
	for i in [MetaHubPages.COLLECTION, MetaHubPages.CAMP, MetaHubPages.SHOP, MetaHubPages.ARENA]:
		var pg: Node = hub.find_child("Page_%d" % i, true, false)
		print("part %-8s refresh_for_meta_hub     %6.2f ms" % [NAMES[i], _time(pg, "refresh_for_meta_hub", 3)])
	print("hub_switch_bench DONE")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
