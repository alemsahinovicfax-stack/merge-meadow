extends SceneTree

## design_handoff_run_pickups (dio B): Camp link kartica plaćene sezone.
##  1. sve 4 plaćene sezone imaju recept „camp" (≤ 12 slojeva, 1032 × 318) i ink iz paketa;
##  2. kartica plaćene sezone crta recept (has_kit), tekst u boji inka, red PREMIUM + „N new
##     flowers" + 6 okvira cvjetova (★1 × 3, ★2 × 2, ★3), bez coina i ★3 napretka;
##  3. stanja: price (cijena na dugmetu) → buying (tri tačke, naslov sakriven) → failed (pilula
##     „Purchase cancelled", nazad na price);
##  4. ništa iz recepta ne izlazi izvan kartice (SeasonBackdrop crta unutar ruba).
## Stanja 3. su Play tok (€) — iap_override = 1, jer mora raditi kad se kupovine vrate; v1 coin
## stanja (price / confirm / short, „Need N more coins") provjerava coin_offers_smoke.
## Pokretanje: godot --headless --path game -s scripts/dev/camp_paid_card_smoke.gd

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const PAID := ["moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]
const INK := {
	"moonlit_warren": "#FFF8F0", "coral_tide": "#3D3D33",
	"starfall_glade": "#FFF8F0", "ember_fen": "#FFF8F0",
}

var _backup: String = ""
var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("camp_paid_card_smoke: %s" % msg)


func _quit() -> void:
	MonetizationConfig.iap_override = -1
	CampSmokeUtil.restore_save(self, _backup)
	quit(1 if _failed else 0)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	MonetizationConfig.iap_override = 1
	var gs := get_root().get_node("GameState")
	for id in PAID:
		var recipe := UiSeasons.recipe(id, "camp")
		if recipe.is_empty():
			_fail("%s has no camp recipe" % id)
			continue
		if (recipe.get("layers", []) as Array).size() > 12:
			_fail("%s camp recipe has %d layers (budget 12)" % [id, (recipe["layers"] as Array).size()])
		if int(recipe.get("w", 0)) != 1032 or int(recipe.get("h", 0)) != 318:
			_fail("%s camp recipe must be 1032 × 318" % id)
		if str(recipe.get("ink", "")) != INK[id]:
			_fail("%s ink should be %s, got %s" % [id, INK[id], recipe.get("ink", "")])
	gs.set("skip_debug_season_unlock", true)
	gs.set("tutorial_complete", true)
	gs.call("reset_seasons_to_s1")
	var unlocked: Array = gs.get("unlocked_seasons")
	for def in SeasonCatalog.free_defs_sorted():
		if not unlocked.has(def.id):
			unlocked.append(def.id)
	gs.set("unlocked_seasons", unlocked)
	gs.call("clear_owned_paid_seasons")
	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub load failed")
		_quit()
		return
	await _frames(20)
	var hub: Node = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await _frames(12)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var camp: Node = host.get_node("Page_%d" % MetaHubPages.CAMP)
	var card: Control = camp.get_node("%SeasonLinkCard")
	var shown := 0
	for target in PAID:
		gs.call("clear_owned_paid_seasons")
		for other in PAID:
			if other == target:
				break
			gs.call("grant_paid_season", other)
		camp.call("refresh_for_meta_hub")
		await _frames(4)
		if str(gs.call("next_unowned_paid_id")) != target:
			continue  # test-zaključana (npr. Ember Fen SOON) — kartica je ne nudi
		shown += 1
		await _check_card(card, camp, target)
	if shown == 0:
		_fail("no paid season was offered on the card")
	if not _failed:
		print("camp_paid_card_smoke OK (%d paid cards checked)" % shown)
	_quit()


func _check_card(card: Control, camp: Node, id: String) -> void:
	if not card.visible or not bool(card.call("is_paid")) or str(card.call("get_season_id")) != id:
		_fail("card should offer %s" % id)
		return
	if not bool(card.call("has_kit")):
		_fail("%s card should draw its camp recipe" % id)
	var ink: Color = card.call("get_ink")
	if not ink.is_equal_approx(Color(INK[id])):
		_fail("%s card ink %s, want %s" % [id, ink.to_html(false), INK[id]])
	var title := camp.get_node("%SeasonLinkTitle") as Label
	if not title.get_theme_color("font_color").is_equal_approx(Color(INK[id])):
		_fail("%s title should use the season ink" % id)
	var offer := card.find_child("SeasonOffer", true, false) as Control
	if offer == null or not offer.is_visible_in_tree():
		_fail("%s paid offer row missing" % id)
		return
	var progress := camp.get_node("%CoinProgress").get_parent() as Control
	if progress.visible:
		_fail("%s paid card must hide the free progress row" % id)
	var tag := offer.find_child("PremiumTag", true, false) as Control
	if tag == null or not tag.is_visible_in_tree():
		_fail("%s PREMIUM tag missing" % id)
	var tiles: Array = card.call("get_paid_tiles")
	var vis := 0
	for t in tiles:
		if (t as Control).visible:
			vis += 1
	var def: SeasonDef = get_root().get_node("GameState").call("get_season_def", id)
	if vis != mini(6, def.seed_type_ids.size()):
		_fail("%s should show %d flower tiles, got %d" % [id, def.seed_type_ids.size(), vis])
	var r_prev := 0
	for t in tiles:
		var r := int(t.get("_rarity"))
		if r < r_prev:
			_fail("%s tiles must go ★1 → ★3" % id)
		r_prev = r
	# Ništa ne izlazi iz kartice (GL Compat ne reže, katalog #24).
	var rect := card.get_global_rect()
	if not rect.encloses(offer.get_global_rect().grow(-0.5)):
		_fail("%s offer row spills outside the card (%s vs %s)" % [id, offer.get_global_rect(), rect])
	# Stanja: price → buying → failed → price.
	var btn: Node = camp.get_node("%SeasonLinkUnlock")
	var price := str(get_root().get_node("IAPManager").call("get_price_label", def.iap_product_id))
	if str(btn.call("get_title")) != price or str(card.call("get_paid_button_state")) != "price":
		_fail("%s button should read price %s" % [id, price])
	card.set("_buying", true)
	card.call("_show_paid", def)
	var dots := btn.find_child("BuyingDots", true, false) as Control
	if str(card.call("get_paid_button_state")) != "buying" or dots == null or not dots.visible:
		_fail("%s buying state should show the three dots" % id)
	if (btn.call("get_title_label") as Label).visible:
		_fail("%s buying state should hide the price text" % id)
	card.call("_on_purchase_failed", def.iap_product_id, "cancelled")
	if not bool(card.call("is_cancel_toast_visible")):
		_fail("%s failed purchase should show 'Purchase cancelled'" % id)
	if str(card.call("get_paid_button_state")) != "price" or dots.visible:
		_fail("%s failed purchase should go back to price" % id)
	await process_frame
