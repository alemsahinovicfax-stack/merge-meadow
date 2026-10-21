extends SceneTree

## Ispravke 2026-10-16 (playtest lista):
##  1. Settings je iznad svega u Areni (z), a zupčanik je zaključan dok traje runda.
##  2. Gnijezdo munchera je u sredini polja; muncher uvijek ide na sjemenku koja mu je SADA
##     najbliža (ne „zaključa" prvu metu).
##  3. Camp: rezervisano ★3 (alert) je uvijek zadnje u listi cvijeća.
##  4. Home polje raste po ikad uzgojenom ★3 (prodaja / otključavanje ga ne vene); stari save
##     dobija brojač iz Albuma; „0 / 13 grown" čipa više nema.
##  5. Vreća prima sav plijen runa (bez limita 40).
##  6. Shop: štand s tabovima je iznad svih slojeva kartica.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")

var _backup := ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("fixes_1016_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _page(hub: Node, index: int) -> Node:
	var swipe: Node = hub.get_node_or_null("RootVBox/SwipePager")
	var host: Node = swipe.call("get_pages_host") if swipe and swipe.has_method("get_pages_host") else null
	return host.get_node_or_null("Page_%d" % index) if host else null


## Najviši efektivni z u podstablu (relativni z se sabira niz roditelje; top_level kreće iznova).
func _max_z(n: Node, base: int = 0, include_hidden: bool = false) -> int:
	var z := base
	var here := base
	if n is CanvasItem:
		var ci := n as CanvasItem
		if not ci.visible and not include_hidden:
			return -100000
		here = ci.z_index if (not ci.z_as_relative or ci.top_level) else base + ci.z_index
		z = here
	for c in n.get_children():
		z = maxi(z, _max_z(c, here, include_hidden))
	return z


func _is_chip(n: Node) -> bool:
	return "pulse_highlight" in n and "type_id" in n and not n.is_queued_for_deletion()


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub load failed")
		return
	for _i in 14:
		await process_frame
	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		_fail("no meta_hub")
		return
	var hub: Node = hubs[0]

	# ── 1. Arena: sesija → zupčanik zaključan; Settings iznad svih slojeva Arene ──────────
	gs.set("seed_bag", {"clover": 40, "daisy": 12})  # vrata Arene traže 50
	hub.call("go_to_page", MetaHubPages.ARENA, false)
	for _j in 10:
		await process_frame
	var arena := _page(hub, MetaHubPages.ARENA)
	if arena == null:
		_fail("arena page missing")
		return
	arena.call("set_arena_page_active", true)
	arena.call("_on_bag_clicked")
	for _k in 10:
		await process_frame
	if not bool(hub.call("is_nav_locked")):
		_fail("pour should lock hub nav")
		return
	var gear := hub.get_node_or_null("RootVBox/TopBar/Panel/HBox/SettingsButton")
	if gear == null or not bool(gear.get("disabled")):
		_fail("Settings gear must be disabled during an Arena round")
		return
	hub.call("_on_settings_pressed")
	await process_frame
	if bool(hub.call("is_settings_open")):
		_fail("Settings must not open during an Arena round")
		return
	var arena_z := _max_z(arena)
	var settings_z := int((load("res://scripts/ui/settings_screen.gd") as GDScript).get_script_constant_map()["Z"])
	print("fixes_1016_smoke: arena max z %d, settings z %d" % [arena_z, settings_z])
	if settings_z <= arena_z:
		_fail("Settings z %d must be above every Arena layer (max %d)" % [settings_z, arena_z])
		return
	# Prazan (zaključan) ili ne, z Settingsa važi i za letenje coina (top_level 100).
	if settings_z <= 100:
		_fail("Settings z must stay above top-level fliers (100)")
		return

	# ── 2. Gnijezdo u sredini; meta = trenutno najbliža ────────────────────────────────────
	var pest: Control = arena.get("_pest")
	var playfield: Control = arena.get("playfield")
	var nest: Vector2 = pest.get("_nest_center")
	var want := playfield.size * 0.5
	if absf(nest.x - want.x) > 1.0 or absf(nest.y - roundf(want.y)) > 1.0:
		_fail("nest should be at the field center %s, got %s" % [want, nest])
		return
	var chips: Array = []
	for child in playfield.get_children():
		if _is_chip(child):
			chips.append(child)
	if chips.size() < 3:
		_fail("need 3+ chips on the field, got %d" % chips.size())
		return
	# Muncher stoji na (300, 300); meta = najudaljenija, pa se pomjeri do bliže → mora preći.
	pest.set("_pest_center", Vector2(300, 300))
	var far: Control = chips[0]
	var near: Control = chips[1]
	for c in chips:
		c.call("set_center", Vector2(900, 1300))
	far.call("set_center", Vector2(980, 1500))
	pest.set("_target_chip", far)
	near.call("set_center", Vector2(340, 330))
	pest.call("_pick_target", false)
	if pest.get("_target_chip") != near:
		_fail("muncher must retarget to the nearest seed (kept the far one)")
		return
	# Gotovo jednako blizu: ne treperi (prednost trenutne mete 24 px).
	var other: Control = chips[2]
	other.call("set_center", Vector2(300, 345))  # 45 od munchera; near je ~50
	pest.call("_pick_target", false)
	if pest.get("_target_chip") != near:
		_fail("muncher should keep its target when another is only marginally closer")
		return
	other.call("set_center", Vector2(305, 312))  # ~13 — jasno bliža
	pest.call("_pick_target", false)
	if pest.get("_target_chip") != other:
		_fail("muncher should switch when a seed is clearly closer")
		return
	# Pusti polje (muncher pojede sve) da se nav otključa.
	var guard := 0
	while guard < 80:
		var left: Array = []
		for child in playfield.get_children():
			if _is_chip(child):
				left.append(child)
		if left.is_empty():
			break
		arena.call("_pest_eat_chip", left[0])
		guard += 1
		await process_frame
	await create_timer(1.2).timeout
	if bool(hub.call("is_nav_locked")) or bool(gear.get("disabled")):
		_fail("gear should unlock when the round ends")
		return

	# ── 3. Camp: rezervisani ★3 zadnji ────────────────────────────────────────────────────
	gs.call("reset_seasons_to_s1")
	var reserve_type := str(gs.call("star3_type_id_for_season", "country_bloom"))
	gs.set("garden_crystal_stash", {reserve_type: 4, "clover": 2, "daisy": 3, "tulip": 1})
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	for _c in 8:
		await process_frame
	var camp := _page(hub, MetaHubPages.CAMP)
	camp.call("refresh_for_meta_hub")
	for _c2 in 4:
		await process_frame
	var grid: GridContainer = camp.get("crystal_grid")
	if grid == null or grid.get_child_count() != 4:
		_fail("crystal grid should list 4 flowers")
		return
	var last: Node = grid.get_child(grid.get_child_count() - 1)
	if str(last.call("get_type_id")) != reserve_type or not bool(last.call("is_reserved")):
		_fail("reserved ★3 (%s) must be the last flower, got %s" % [reserve_type, last.call("get_type_id")])
		return
	if bool(grid.get_child(0).call("is_reserved")):
		_fail("first flower must not be the reserved one")
		return

	# ── 4. Polje: ikad uzgojeno, ne stash ─────────────────────────────────────────────────
	var def: SeasonDef = gs.call("get_season_def", "country_bloom")
	var roster: Array = def.seed_type_ids
	gs.set("garden_crystal_stash", {})
	var dom: Object = gs.get("crystal_stash_domain")
	var grown: Dictionary = {}
	for t in roster:
		grown[t] = 1
	dom.set("grown", grown)
	for t in roster:
		if int(gs.call("star3_grown_count", t)) != 1:
			_fail("star3_grown_count should read the grown counter")
			return
	# Arena T3 diže i stash i uzgojeno; prodaja skida samo stash.
	gs.call("stash_garden_crystal", roster[0])
	if int(gs.call("star3_grown_count", roster[0])) != 2:
		_fail("Arena T3 must count as grown")
		return
	gs.set("garden_crystal_stash", {})
	if int(gs.call("star3_grown_count", roster[0])) != 2:
		_fail("selling / spending must not shrink the grown count")
		return
	# Stari save bez star3_grown: iz Albuma (kept tier 3) bar 1.
	var old_save := {"garden_crystal_stash": {"tulip": 3}, "collection_kept_tiers": {"daisy": 3, "clover": 2}}
	dom.call("apply_from_save", old_save)
	dom.call("seed_grown_from_history", old_save["collection_kept_tiers"], int(gs.get("MAX_MERGE_TIER")))
	var g2: Dictionary = dom.get("grown")
	if int(g2.get("tulip", 0)) != 3 or int(g2.get("daisy", 0)) != 1 or g2.has("clover"):
		_fail("migration should seed grown from stash and Album ★3: %s" % str(g2))
		return
	dom.set("grown", grown)
	gs.set("garden_crystal_stash", {})
	# Home polje otvoreno → mjesta s pragom 1 izrasla iako je stash prazan.
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	for _h in 8:
		await process_frame
	var home := _page(hub, MetaHubPages.MAIN)
	var stage: Node = home.get_node_or_null("%SeasonStage")
	if not bool(stage.call("open_season_field", "country_bloom")):
		_fail("could not open the Country Bloom field")
		return
	for _w in 60:
		await create_timer(0.02).timeout
		if not bool(stage.call("is_field_transitioning")):
			break
	for _w2 in 4:
		await process_frame
	var field: Node = stage.get_node_or_null("%SeasonField")
	# Svih 6 tipova uzgojeno bar jednom → svih 13 mjesta (prag 1 na svakom mjestu, playtest:
	# „spojim sve u Areni, a polje nije puno" — ranije pragovi 1 / 5 / 10 → 6 od 13).
	var spot_count := int(field.call("get_meadow_spot_count"))
	if spot_count != 13 or int(field.call("get_meadow_grown_count")) != spot_count:
		_fail("every type grown once should fill all %d spots (stash empty), got %d" % [spot_count, int(field.call("get_meadow_grown_count"))])
		return
	if home.get_node_or_null("%GrownChip") != null:
		_fail("'0 / 13 grown' chip must be gone")
		return
	# Prag 1 i svih 6 tipova na polju — u svakoj sezoni i u zadanom rasporedu.
	var layouts: Dictionary = {"default": UiHomeField.MEADOW_SPOTS}
	for sdef in SeasonCatalog.all_defs():
		layouts[sdef.id] = UiSeasons.spots(sdef.id)
	for lid in layouts:
		var sp: Array = layouts[lid]
		var idx_seen: Dictionary = {}
		for spec in sp:
			if int(spec[4]) != 1:
				_fail("%s: every meadow spot should need 1 grown ★3, got %s" % [lid, str(spec)])
				return
			idx_seen[int(spec[3])] = true
		if sp.size() != 13 or idx_seen.size() != 6:
			_fail("%s: 13 spots covering all 6 roster types expected (%d spots, %d types)" % [lid, sp.size(), idx_seen.size()])
			return
	# Jedan tip neuzgojen → fale tačno njegova mjesta (rijetki ima 3: srednje, prednje, veliko).
	for missing_i in [0, 5]:
		var g_missing := grown.duplicate()
		g_missing.erase(roster[missing_i])
		dom.set("grown", g_missing)
		field.call("refresh_growth")
		await process_frame
		var own_spots := 0
		for spec in UiSeasons.spots("country_bloom"):
			if clampi(int(spec[3]), 0, roster.size() - 1) == missing_i:
				own_spots += 1
		if int(field.call("get_meadow_grown_count")) != 13 - own_spots:
			_fail("without %s the field should show %d, got %d" % [roster[missing_i], 13 - own_spots, int(field.call("get_meadow_grown_count"))])
			return
	dom.set("grown", grown)
	field.call("refresh_growth")
	await process_frame

	# ── 4b. Nadogradnje: 20 / 20 ★3 čuvanih za sljedeću sezonu se smiju potrošiti ─────────
	# (playtest: Frost, 20 Crystal Peony — Lantern traži tačno 20 — dugme je bilo „nema cvijeća").
	var unlocked2: Array = gs.get("unlocked_seasons")
	if not unlocked2.has("frost_orchard"):
		unlocked2.append("frost_orchard")
	gs.set("unlocked_seasons", unlocked2)
	var frost_flower := str(gs.call("star3_type_id_for_season", "frost_orchard"))
	stage.call("close_season_field")
	for _cf in 40:
		await create_timer(0.02).timeout
		if not bool(stage.call("is_field_transitioning")):
			break
	if not bool(stage.call("open_season_field", "frost_orchard")):
		_fail("could not open the Frost field")
		return
	for _wf in 60:
		await create_timer(0.02).timeout
		if not bool(stage.call("is_field_transitioning")):
			break
	# Playtest save (Frost): svih 6 tipova ★3, ali hoarfrost 3 i silver 4 — ranije 11 / 13.
	var frost_field: Node = stage.get_node_or_null("%SeasonField")
	var g_frost := grown.duplicate()
	g_frost.merge({"winter_camellia": 11, "frost_snowdrop": 9, "ice_crocus": 8, "hoarfrost_rose": 3, "silver_aconite": 4, "crystal_peony": 73})
	dom.set("grown", g_frost)
	frost_field.call("refresh_growth")
	await process_frame
	if int(frost_field.call("get_meadow_grown_count")) != 13:
		_fail("playtest Frost save should fill 13 / 13, got %d" % int(frost_field.call("get_meadow_grown_count")))
		return
	dom.set("grown", grown)
	var need := int(gs.call("upgrade_flower_reserve", frost_flower))
	if need < 2:
		_fail("Frost ★3 should be kept for the next season (reserve %d)" % need)
		return
	gs.set("garden_crystal_stash", {frost_flower: need})
	gs.set("wallet_coins", 500)
	# Nivoi nadogradnji su po sezoni i ostaju u saveu — pravi save može imati Frost na max,
	# pa nijedna kupovina nije „can" i napomene nema (greske-katalog #45).
	(gs.get("season_upgrades") as Dictionary).erase("frost_orchard")
	home.call("_open_upgrades_sheet")
	for _u in 4:
		await process_frame
	for track in ["magnet", "loot", "twin"]:
		var st := str(gs.call("upgrade_button_state", track, "frost_orchard"))
		if st != "can" and st != "max":
			_fail("Frost %s should be buyable with %d kept flowers and 500 coins, got %s" % [track, need, st])
			return
	var note := str(home.call("get_upgrade_kept_note"))
	if note.find("Lantern") < 0:
		_fail("upgrades sheet should say the purchase uses flowers saved for Lantern, got '%s' (sheet %s, next %s, uses_kept %s, states %s)" % [
			note, gs.call("upgrade_sheet_season_id"), gs.call("next_locked_free_id"),
			gs.call("upgrade_uses_kept_flowers", "frost_orchard"),
			[gs.call("upgrade_button_state", "magnet", "frost_orchard"), gs.call("upgrade_button_state", "loot", "frost_orchard"), gs.call("upgrade_button_state", "twin", "frost_orchard")]])
		return
	var twin_before := int(gs.call("get_upgrade_level", "twin", "frost_orchard"))
	if not bool(gs.call("try_upgrade_twin")):
		_fail("Twin upgrade should go through")
		return
	var left := int((gs.get("garden_crystal_stash") as Dictionary).get(frost_flower, 0))
	if left != need - 2 or int(gs.call("get_upgrade_level", "twin", "frost_orchard")) != twin_before + 1:
		_fail("upgrade should spend 2 ★3 (left %d) and raise Twin" % left)
		return
	home.call("_close_upgrades_sheet")

	# ── 5. Vreća prima sav plijen ─────────────────────────────────────────────────────────
	gs.set("seed_bag", {"daisy": 38})
	gs.call("finish_run", {"clover": 12, "tulip": 8}, 30, false, 40.0)
	var expect := 38 + int(gs.call("sum_seed_bag", gs.get("last_seed_bag")))
	gs.call("deposit_loot_to_camp")
	var bag_total := int(gs.call("sum_seed_bag", gs.get("seed_bag")))
	if bag_total != expect or bag_total <= 40:
		_fail("bag should take the whole loot: expected %d, got %d" % [expect, bag_total])
		return

	# ── 6. Shop: štand iznad kartica ──────────────────────────────────────────────────────
	hub.call("go_to_page", MetaHubPages.SHOP, false)
	for _s in 30:
		await process_frame
	var shop := _page(hub, MetaHubPages.SHOP)
	var shop_root: Node = shop.get_node_or_null("ShopScreen") if shop.get_node_or_null("ShopScreen") else shop
	var bar: Node = shop_root.find_child("ShopTabBar", true, false)
	if bar == null:
		_fail("ShopTabBar missing")
		return
	shop_root.call("_finish_build") if shop_root.has_method("_finish_build") else null
	for _s2 in 6:
		await process_frame
	# Kraj Boosters taba („All set") crta Pipa u nošenom skinu (HOST_LIFT 4 + dijelovi) — upravo
	# taj skin je izlazio preko štanda. Atlas skina se pravi u pozadini: sačekaj da Pip postoji.
	shop_root.call("select_tab", "boosters", false)
	for _p in 60:
		await create_timer(0.05).timeout
		if (shop_root.call("page_node", "boosters") as Node).find_child("AllSetPip", true, false) != null:
			break
	for tab in ["seasons", "looks", "boosters", "support"]:
		var page: Node = shop_root.call("page_node", tab)
		# I skriveni dijelovi (kraj „All set" s Pipom se vidi tek kad je sve kupljeno).
		var content_z := _max_z(page, 0, true) if page else 0
		print("fixes_1016_smoke: shop %s max z %d, tab bar z %d" % [tab, content_z, (bar as CanvasItem).z_index])
		if int((bar as CanvasItem).z_index) <= content_z:
			_fail("Shop tab bar z %d must be above %s content (max %d)" % [(bar as CanvasItem).z_index, tab, content_z])
			return

	print("fixes_1016_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
