extends SceneTree

## Bug-017 — cosmetic buy deducts coins and marks owned.


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		push_error("shop_cosmetic_buy_smoke: shop load failed %d" % err)
		quit(1)
		return
	for _i in 20:
		await process_frame
	var shop := current_scene as Control
	var gs := _gs()
	if shop == null or gs == null:
		push_error("shop_cosmetic_buy_smoke: shop/GameState missing")
		quit(1)
		return
	gs.set("wallet_coins", 300)
	gs.set("owned_cosmetics", {})
	gs.set("equipped_cosmetics", {})
	if shop.has_method("_refresh_ui"):
		shop.call("_refresh_ui")
	for _j in 4:
		await process_frame
	if shop.has_method("_on_cosmetic_buy"):
		shop.call("_on_cosmetic_buy", "meadow_sunset")
	for _k in 4:
		await process_frame
	var cost := 150
	if int(gs.get("wallet_coins")) != 300 - cost:
		push_error(
			"shop_cosmetic_buy_smoke: wallet expected %d got %s"
			% [300 - cost, str(gs.get("wallet_coins"))]
		)
		quit(1)
		return
	var owned: Dictionary = gs.get("owned_cosmetics")
	if not bool(owned.get("meadow_sunset", false)):
		push_error("shop_cosmetic_buy_smoke: meadow_sunset should be owned")
		quit(1)
		return
	if gs.has_method("is_cosmetic_equipped") and not bool(gs.call("is_cosmetic_equipped", "meadow_sunset")):
		push_error("shop_cosmetic_buy_smoke: meadow_sunset should be equipped")
		quit(1)
		return
	print("shop_cosmetic_buy_smoke OK")
	quit(0)
