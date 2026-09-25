extends SceneTree

## design_handoff_camp_v2 — struktura scene, hub chrome i vertikalni budzet 1633 px:
## kartica sezone 276, razmak 20, sekcija UVIJEK 1289 (1585 bez kartice) bez obzira
## na broj tipova. Provjerava i da su Merge precica i StackGap obrisani.

const HUB_PAGE := Vector2(1080.0, 1633.0)
const TOL := 1.5
const TWENTY := [
	"clover", "daisy", "buttercup", "tulip", "sunflower", "pumpkin",
	"frost_snowdrop", "ice_crocus", "silver_aconite", "winter_camellia", "hoarfrost_rose", "crystal_peony",
	"dusk_firefly_grass", "paper_lantern_bloom", "evening_primrose", "foxfire_lily", "glow_wisteria",
	"midnight_lotus", "copper_leaf", "maple_aster",
]

var _backup: String = ""


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("camp_layout_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		_fail("camp scene load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	var gs := get_root().get_node_or_null("GameState")
	if camp == null or gs == null or not str(camp.scene_file_path).ends_with("camp_scene.tscn"):
		_fail("wrong scene / GameState missing")
		return

	var required: Array[String] = [
		"CampPage", "ContentStack", "SeasonLinkCard", "StashSection", "StashTabs",
		"SeedsTab", "FlowersTab", "StashScroll", "SeedBagGrid", "CrystalGrid",
		"EmptyState", "EmptyCta", "ExchangeBar", "ExchangeButton", "ReservedWarning", "TradeFeedback",
		"SeasonLinkTitle", "SeasonLinkCoins", "SeasonLinkT3", "SeasonLinkUnlock",
		"HomeButton", "SettingsButton", "CollectionButton", "ResourceBar", "MergeButton", "PlayButton",
	]
	for node_name in required:
		if camp.get_node_or_null("%" + node_name) == null:
			_fail("missing %%%s" % node_name)
			return
	var removed: Array[String] = [
		"GardenCard", "CrystalCard", "CrystalExchangeButton", "UpgradeCards", "StatusToast",
		"GardenCliff", "BagLabel", "CrystalTotalLabel", "CrystalCliff", "CompanionTitle", "PipSlot",
		# v2: rupa u sredini, Merge precica, podnaslovi i captioni.
		"StackGap", "MergeShortcut", "SeasonEyebrow", "HomeHint", "SeasonCoinCap",
		"SeasonLinkFlowerName", "EmptyBody", "SelectedValue",
	]
	for node_name in removed:
		if camp.get_node_or_null("%" + node_name) != null:
			_fail("%%%s should be removed" % node_name)
			return

	var home := camp.get_node("%HomeButton") as Control
	if not home.visible:
		_fail("Home should be visible standalone")
		return
	camp.call("set_meta_hub_mode", true)
	for chrome in ["HeaderPanel", "HomeButton", "SettingsButton", "CollectionButton", "ResourceBar", "FooterBar"]:
		if (camp.get_node("%" + chrome) as Control).visible:
			_fail("%s still visible after set_meta_hub_mode" % chrome)
			return
	camp.set_anchors_preset(Control.PRESET_TOP_LEFT)
	camp.size = HUB_PAGE

	# 1) 6 tipova sjemena, Frost Orchard sljedeca sezona (hero vidljiv).
	gs.call("reset_seasons_to_s1")
	gs.set("seed_bag", {"clover": 4, "daisy": 3, "buttercup": 2, "tulip": 2, "sunflower": 1, "pumpkin": 1})
	gs.set("garden_crystal_stash", {"clover": 3, "daisy": 2, "tulip": 1, "pumpkin": 20})
	camp.call("refresh_for_meta_hub")
	await _settle()
	var seeds_tab := camp.get_node("%SeedsTab")
	var flowers_tab := camp.get_node("%FlowersTab")
	if str(seeds_tab.call("get_title")) != "Seeds" or str(flowers_tab.call("get_title")) != "Flowers":
		_fail("tabs must read Seeds / Flowers")
		return
	if str(seeds_tab.call("get_count_text")) != "6" or str(flowers_tab.call("get_count_text")) != "4":
		_fail("tabs must count types (6 / 4)")
		return
	var tab_w := (seeds_tab as Control).size.x
	if absf(tab_w - 489.0) > TOL:
		_fail("tab width expected 489 (two tabs, no Merge) got %s" % str(tab_w))
		return
	var chip := (camp.get_node("%SeedBagGrid") as GridContainer).get_child(0) as Control
	if absf(chip.size.x - 489.0) > TOL or absf(chip.size.y - 176.0) > TOL:
		_fail("chip expected 489 × 176 got %s" % str(chip.size))
		return
	var e := _expect_section(camp, true, "six seeds")
	if not e.is_empty():
		_fail(e)
		return
	var button := camp.get_node("%ExchangeButton") as Control
	if absf(button.size.x - 300.0) > TOL or button.size.y < 120.0 - TOL:
		_fail("Trade button must be 300 x 120, got %s" % str(button.size))
		return

	# 2) 20 tipova: sekcija ista, lista skrola.
	var twenty := {}
	for type_id in TWENTY:
		twenty[type_id] = 1
	gs.set("seed_bag", twenty)
	camp.call("refresh_for_meta_hub")
	await _settle()
	if str(seeds_tab.call("get_count_text")) != "20":
		_fail("Seeds tab must count 20 types")
		return
	e = _expect_section(camp, true, "twenty seeds")
	if not e.is_empty():
		_fail(e)
		return
	var lists := camp.get_node("%StashLists") as Control
	if lists.size.y <= (camp.get_node("%StashScroll") as Control).size.y:
		_fail("20 types must overflow the list window (scroll)")
		return

	# 3) Flowers: rezervisan pumpkin (i dalje 176) + stop drzanja (bar 224).
	camp.call("_on_tab_pressed", "flowers")
	camp.call("_on_crystal_chip_pressed", "pumpkin")
	await _settle()
	var bar := camp.get_node("%ExchangeBar")
	if str(bar.call("get_state")) != "holdstop":
		_fail("pumpkin at 20/20 must be holdstop, got %s" % str(bar.call("get_state")))
		return
	if not (camp.get_node("%ReservedWarning") as Control).visible:
		_fail("holdstop must show ReservedWarning")
		return
	e = _expect_section(camp, true, "reserved + holdstop")
	if not e.is_empty():
		_fail(e)
		return

	# 4) Prazna vreca: sekcija ista visina, Trade bar ostaje.
	camp.call("_on_tab_pressed", "seeds")
	gs.set("seed_bag", {})
	camp.call("refresh_for_meta_hub")
	await _settle()
	if not (camp.get_node("%EmptyState") as Control).visible:
		_fail("empty bag must show EmptyState")
		return
	if str(camp.get_node("%EmptyCta").call("get_title")) != "Play a run ↗":
		_fail("empty bag CTA must read 'Play a run ↗'")
		return
	e = _expect_section(camp, true, "empty bag")
	if not e.is_empty():
		_fail(e)
		return

	# 5) Sve besplatne sezone otkljucane: nema hero kartice, sekcija na vrhu.
	var unlocked: Array = gs.get("unlocked_seasons")
	for id in ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy"]:
		if not unlocked.has(id):
			unlocked.append(id)
	gs.set("unlocked_seasons", unlocked)
	gs.set("seed_bag", {"clover": 4, "daisy": 3})
	camp.call("refresh_for_meta_hub")
	await _settle()
	var card := camp.get_node("%SeasonLinkCard") as Control
	if card.visible:
		_fail("no next season must hide the hero card")
		return
	var section := camp.get_node("%StashSection") as Control
	if absf(section.global_position.y - (camp.global_position.y + 24.0)) > TOL:
		_fail("section must move to the top without hero, y=%s" % str(section.global_position.y))
		return
	if absf(section.size.y - 1585.0) > TOL:
		_fail("section without hero must be 1585, got %s" % str(section.size.y))
		return

	print("camp_layout_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _settle() -> void:
	for _i in 6:
		await process_frame


## v2: sekcija je uvijek 1289 s karticom sezone — nista ne ovisi o broju tipova.
func _expect_section(camp: Control, hero: bool, what: String) -> String:
	var page_top := camp.global_position.y
	var page_bottom := page_top + HUB_PAGE.y
	var section := camp.get_node("%StashSection") as Control
	var bar := camp.get_node("%ExchangeBar") as Control
	var card := camp.get_node("%SeasonLinkCard") as Control
	if absf(section.size.y - 1289.0) > TOL:
		return "%s: section expected 1289 got %s" % [what, str(section.size.y)]
	if section.get_global_rect().end.y > page_bottom - 24.0 + TOL:
		return "%s: section overflows the page (bottom %s)" % [what, str(section.get_global_rect().end.y - page_top)]
	if bar.get_global_rect().end.y > section.get_global_rect().end.y - 18.0 + TOL:
		return "%s: Trade bar is cut" % what
	if hero:
		if not card.visible or absf(card.size.y - 276.0) > TOL:
			return "%s: hero must be 276 px" % what
		if absf(card.global_position.y - (page_top + 24.0)) > TOL:
			return "%s: hero must sit at y 24" % what
		if absf(section.get_global_rect().end.y - (page_bottom - 24.0)) > TOL:
			return "%s: section must sit on the bottom padding" % what
		# Sekcija je prikovana uz karticu: tacno 20 px razmaka, nikad rupa.
		if absf(section.global_position.y - (card.get_global_rect().end.y + 20.0)) > TOL:
			return "%s: gap hero → section must be exactly 20" % what
	return ""
