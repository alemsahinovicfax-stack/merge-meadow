extends SceneTree

## F1 — meta hub boot + lazy load svih 5 stranica (headless).
## Bug-006: assert redoslijed Shop → Journal → Home → Camp → Arena.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")


func _initialize() -> void:
	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		push_error("meta_hub_flow_smoke: load failed %d" % err)
		quit(1)
		return
	call_deferred("_step")


func _step() -> void:
	await process_frame
	await process_frame
	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		push_error("meta_hub_flow_smoke: no meta_hub node")
		quit(1)
		return
	var hub: Node = hubs[0]
	if not hub.has_method("go_to_page"):
		push_error("meta_hub_flow_smoke: hub missing go_to_page")
		quit(1)
		return
	for page in MetaHubPages.PAGE_COUNT:
		hub.go_to_page(page, false)
		for _i in 3:
			await process_frame
		var host_path := "RootVBox/SwipePager"
		var swipe := hub.get_node_or_null(host_path)
		if swipe and swipe.has_method("get_pages_host"):
			var host: Node = swipe.get_pages_host()
			var page_node := host.get_node_or_null("Page_%d" % page) if host else null
			if page_node == null:
				push_error("meta_hub_flow_smoke: Page_%d not loaded" % page)
				quit(1)
				return
			var expected_scene: String = MetaHubPages.PAGE_SCENES[page]
			var actual_path := String(page_node.scene_file_path)
			if actual_path != expected_scene:
				push_error(
					"meta_hub_flow_smoke: Page_%d expected %s got %s"
					% [page, expected_scene, actual_path]
				)
				quit(1)
				return
	var expected_labels: Array[String] = ["Shop", "Journal", "Home", "Camp", "Arena"]
	for i in expected_labels.size():
		if MetaHubPages.PAGE_LABELS[i] != expected_labels[i]:
			push_error(
				"meta_hub_flow_smoke: PAGE_LABELS[%d] expected %s got %s"
				% [i, expected_labels[i], MetaHubPages.PAGE_LABELS[i]]
			)
			quit(1)
			return
	if MetaHubPages.MAIN != 2:
		push_error("meta_hub_flow_smoke: MAIN must be center index 2")
		quit(1)
		return
	hub.go_to_page(MetaHubPages.SHOP, false)
	for _i in 20:
		await process_frame
	var swipe := hub.get_node_or_null("RootVBox/SwipePager")
	if swipe == null or not swipe.has_method("get_pages_host"):
		push_error("meta_hub_flow_smoke: shop swipe host missing")
		quit(1)
		return
	var host: Node = swipe.get_pages_host()
	var shop: Node = host.get_node_or_null("Page_%d" % MetaHubPages.SHOP) if host else null
	if shop == null:
		push_error("meta_hub_flow_smoke: shop page missing")
		quit(1)
		return
	var top_bar := shop.get_node_or_null("RootVBox/TopBar") as Control
	var resource_bar := shop.get_node_or_null("RootVBox/ResourceBar") as Control
	var top_progress := shop.get_node_or_null("RootVBox/TopProgress") as Control
	if top_bar and top_bar.visible:
		push_error("meta_hub_flow_smoke: shop TopBar should be hidden in hub")
		quit(1)
		return
	if resource_bar and resource_bar.visible:
		push_error("meta_hub_flow_smoke: shop ResourceBar should be hidden in hub")
		quit(1)
		return
	if top_progress != null and top_progress.visible:
		push_error("meta_hub_flow_smoke: shop TopProgress should be hidden or removed")
		quit(1)
		return
	var almanac := shop.get_node_or_null("RootVBox/MainScroll/MainContent/AlmanacList")
	if almanac != null:
		push_error("meta_hub_flow_smoke: AlmanacList should be removed from Shop")
		quit(1)
		return
	var cosmetics := shop.get_node_or_null(
		"RootVBox/MainScroll/MainContent/CoinShopPanel/VBox/CosmeticsList"
	)
	if cosmetics == null or cosmetics.get_child_count() != 5:
		push_error(
			"meta_hub_flow_smoke: CosmeticsList expected 5 rows got %s"
			% (str(cosmetics.get_child_count()) if cosmetics else "null")
		)
		quit(1)
		return
	var coin_icon := hub.get_node_or_null("RootVBox/TopBar/Panel/HBox/CoinChip/HBox/CoinIcon") as TextureRect
	var seed_icon := hub.get_node_or_null("RootVBox/TopBar/Panel/HBox/SeedChip/HBox/SeedIcon") as TextureRect
	var coins_label := hub.get_node_or_null("RootVBox/TopBar/Panel/HBox/CoinChip/HBox/CoinsLabel") as Label
	var seeds_label := hub.get_node_or_null("RootVBox/TopBar/Panel/HBox/SeedChip/HBox/SeedsLabel") as Label
	if coin_icon == null or coin_icon.texture == null:
		push_error("meta_hub_flow_smoke: hub CoinIcon missing texture")
		quit(1)
		return
	if seed_icon == null or seed_icon.texture == null:
		push_error("meta_hub_flow_smoke: hub SeedIcon missing texture")
		quit(1)
		return
	var gs := get_root().get_node_or_null("GameState")
	if gs == null or coins_label == null or seeds_label == null:
		push_error("meta_hub_flow_smoke: hub count labels / GameState missing")
		quit(1)
		return
	if hub.has_method("refresh_top_bar"):
		hub.call("refresh_top_bar")
	await process_frame
	var want_coins := str(int(gs.get("wallet_coins")))
	var want_seeds := str(int(gs.call("sum_seed_bag_only")))
	if coins_label.text != want_coins:
		push_error(
			"meta_hub_flow_smoke: CoinsLabel got '%s' expected '%s'"
			% [coins_label.text, want_coins]
		)
		quit(1)
		return
	if seeds_label.text != want_seeds:
		push_error(
			"meta_hub_flow_smoke: SeedsLabel got '%s' expected '%s'"
			% [seeds_label.text, want_seeds]
		)
		quit(1)
		return
	var coin_color: Color = coins_label.get_theme_color("font_color")
	if coin_color.v > 0.85:
		push_error("meta_hub_flow_smoke: CoinsLabel font too light for pastel chip")
		quit(1)
		return
	hub.go_to_page(MetaHubPages.CAMP, false)
	for _j in 8:
		await process_frame
	var camp: Node = host.get_node_or_null("Page_%d" % MetaHubPages.CAMP)
	if camp == null:
		push_error("meta_hub_flow_smoke: camp page missing")
		quit(1)
		return
	var camp_bar := camp.get_node_or_null("%ResourceBar") as Control
	if camp_bar and camp_bar.visible:
		push_error("meta_hub_flow_smoke: camp ResourceBar should be hidden in hub")
		quit(1)
		return
	if camp.get_node_or_null("%DailyChestCard") == null:
		push_error("meta_hub_flow_smoke: camp DailyChestCard missing")
		quit(1)
		return
	print("meta_hub_flow_smoke OK")
	quit(0)
