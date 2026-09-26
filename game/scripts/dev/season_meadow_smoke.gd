extends SceneTree

const UI_FIELD := preload("res://scripts/visual/ui_home_field.gd")

## HOME-12–15 + HOME-21 meadow — SeasonField preko cijele stranice (1080 x 1633),
## plutajuci FieldOverlay, donji red Seasons · Play · Endless, cvijece i Pip van
## keepout zona, Pip FSM, T3 match.


const SAVE_PATH := "user://player_save.json"
const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const BLOOM_PASTEL := Color(0.90, 0.95, 0.86, 1.0)
## Home pozadina = Camp #2E4733 (design_handoff_home, 2026-09-21).
const HOME_DARK := Color(0.180392, 0.278431, 0.2, 1.0)


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


var _backup := ""


func _fail(msg: String) -> void:
	push_error("season_meadow_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _count_named(n: Node, node_name: String) -> int:
	var count := 0
	for child in n.get_children():
		if str(child.name) == node_name:
			count += 1
	return count


func _field_flowers(field: Node) -> Array:
	var out: Array = []
	if field == null:
		return out
	for child in field.get_children():
		if child.is_in_group("meadow_flower"):
			out.append(child)
	return out


func _flower_types(flowers: Array) -> Dictionary:
	var types: Dictionary = {}
	for flower in flowers:
		types[str(flower.get("type_id"))] = true
	return types


func _has_arena_chip(n: Node) -> bool:
	for child in n.get_children():
		var script: Script = child.get_script()
		if script != null and str(script.resource_path).ends_with("arena_seed_chip.gd"):
			return true
		if _has_arena_chip(child):
			return true
	return false


func _picker_labels(home: Node) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	if home != null and home.has_method("_rebuild_picker_list"):
		home.call("_rebuild_picker_list")
	var list: Node = home.get_node_or_null("%PickerList") if home else null
	if list == null:
		return out
	for child in list.get_children():
		out.append(str(child.get("label_text")))
	return out


func _find_picker_icon(n: Node) -> Control:
	if n.name == "PlantIcon":
		return n as Control
	for child in n.get_children():
		var found := _find_picker_icon(child)
		if found:
			return found
	return null


func _has_scroll_clip_ancestor(n: Node) -> bool:
	var walk := n.get_parent()
	while walk:
		if walk is ScrollContainer:
			return true
		walk = walk.get_parent()
	return false


func _assert_picker_fits_panel(home: Node) -> String:
	var list: Node = home.get_node_or_null("%PickerList")
	var panel := home.get_node_or_null("%PickerPanel") as Control
	if list == null:
		return "PickerList missing"
	if panel == null:
		return "PickerPanel missing"
	if _has_scroll_clip_ancestor(list):
		return "PickerList must not sit under a ScrollContainer"
	var outer := panel.get_global_rect().grow(1.0)
	for child in list.get_children():
		var row := child as Control
		if row == null:
			continue
		if not outer.encloses(row.get_global_rect()):
			return "flower row not inside PickerPanel: %s" % str(row.get("label_text"))
		var icon := _find_picker_icon(row)
		if icon != null and not outer.encloses(icon.get_global_rect()):
			return "T3 icon not inside PickerPanel: %s" % str(row.get("label_text"))
	return ""


func _assert_pip_alive(field: Node, pip: Control, label: String) -> String:
	if pip == null:
		return "%s MeadowPip missing" % label
	if not pip.visible:
		return "%s MeadowPip should be visible" % label
	if pip.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return "%s MeadowPip must IGNORE" % label
	var alive := false
	if field.has_method("is_pip_alive"):
		alive = bool(field.call("is_pip_alive"))
	if field.has_method("is_pip_wandering") and bool(field.call("is_pip_wandering")):
		alive = true
	if not alive:
		return "%s MeadowPip should be alive or wandering" % label
	return ""


## v2: Seasons 236 x 124 · Play 432 x 140 (centar x 540) · Endless 236 x 124.
func _assert_play_row_equal(home: Node) -> String:
	var seasons_n: Control = home.get_node_or_null("%SeasonsRowButton") as Control
	var play_n: Control = home.get_node_or_null("%FieldPlayButton") as Control
	var endless_n: Control = home.get_node_or_null("%EndlessPlayButton") as Control
	if seasons_n == null or play_n == null or endless_n == null:
		return "BottomRow children missing"
	var want: Array = [UI_FIELD.SEASONS_BTN, UI_FIELD.PLAY_BTN, UI_FIELD.ENDLESS_BTN]
	var got: Array[Control] = [seasons_n, play_n, endless_n]
	for i in got.size():
		var ctrl: Control = got[i]
		var rect := Rect2(want[i])
		if absf(ctrl.size.x - rect.size.x) > 1.5 or absf(ctrl.size.y - rect.size.y) > 1.5:
			return "%s expected %s got %s" % [ctrl.name, str(rect.size), str(ctrl.size)]
		if ctrl.size.y < 120.0:
			return "%s touch height %s < 120" % [ctrl.name, str(ctrl.size.y)]
	var page_x: float = (home as Control).get_global_rect().position.x
	var play_center: float = play_n.get_global_rect().get_center().x - page_x
	if absf(play_center - 540.0) > 1.5:
		return "Play should stay centred on x 540, got %.1f" % play_center
	return ""


func _assert_flowers(field: Node, pool: Array, label: String) -> String:
	var spots := 0
	if field.has_method("get_meadow_spot_count"):
		spots = int(field.call("get_meadow_spot_count"))
	if spots != 13:
		return "%s spot count %d expected 13" % [label, spots]
	var flowers: Array = _field_flowers(field)
	var pool_set: Dictionary = {}
	for type_id in pool:
		pool_set[str(type_id)] = true
	for flower in flowers:
		if (flower as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
			return "%s flower must IGNORE" % label
		var type_id := str(flower.get("type_id"))
		if not pool_set.has(type_id):
			return "%s flower type %s not in pool" % [label, type_id]
		if int(flower.get("plant_tier")) != 3:
			return "%s flower plant_tier expected 3 got %s" % [label, str(flower.get("plant_tier"))]
	if _has_arena_chip(field):
		return "%s must not instance ArenaSeedChip" % label
	if field.has_method("meadow_safe_rect"):
		return "%s meadow_safe_rect should be removed" % label
	return ""


## v2: chrome pluta preko livade, pa se cvijece mjeri prema KEEPOUT zonama stranice.
func _assert_flowers_clear_chrome(home: Node, field: Node, label: String) -> String:
	if home == null or field == null:
		return "%s chrome check missing nodes" % label
	var page: Vector2 = (home as Control).get_global_rect().position
	for flower in _field_flowers(field):
		var fr: Rect2 = (flower as Control).get_global_rect()
		fr.position -= page
		if UI_FIELD.hits_keepout(fr):
			return "%s flower %s sits under a keepout zone (%s)" % [label, flower.name, str(fr)]
	var pip: Control = field.get_node_or_null("MeadowPip") as Control
	if pip and pip.visible:
		var pr: Rect2 = pip.get_global_rect()
		pr.position -= page
		if UI_FIELD.hits_keepout(pr):
			return "%s Pip sits under a keepout zone (%s)" % [label, str(pr)]
	return ""


func _assert_field_upgrades_open(home: Node, label: String) -> String:
	if home == null:
		return "%s field upgrades missing home" % label
	var entry: Control = home.get_node_or_null("%UpgradesButton") as Control
	if entry == null or not entry.visible:
		return "%s UpgradesButton should be visible in the field" % label
	var sheet: Control = home.get_node_or_null("%UpgradesOverlay") as Control
	var magnet: Control = home.get_node_or_null("%MagnetButton") as Control
	var loot: Control = home.get_node_or_null("%LootBoostButton") as Control
	var magnet_title: Label = home.get_node_or_null("%MagnetTitle") as Label
	var loot_title: Label = home.get_node_or_null("%LootBoostTitle") as Label
	if sheet == null or not sheet.visible:
		return "%s UpgradesOverlay should open on tap" % label
	if magnet == null or not magnet.is_visible_in_tree():
		return "%s MagnetButton should be visible" % label
	if loot == null or not loot.is_visible_in_tree():
		return "%s LootBoostButton should be visible" % label
	if loot.global_position.y <= magnet.global_position.y:
		return "%s Loot Boost should sit below Magnet" % label
	var mag_t := magnet_title.text if magnet_title else ""
	var loot_t := loot_title.text if loot_title else ""
	if mag_t.find("Magnet") < 0:
		return "%s title should contain Magnet got '%s'" % [label, mag_t]
	if loot_t.find("Loot Boost") < 0:
		return "%s title should contain Loot Boost got '%s'" % [label, loot_t]
	var blob := "%s %s %s %s" % [
		mag_t,
		loot_t,
		str(magnet.get("label_text")),
		str(loot.get("label_text")),
	]
	if blob.find("Sprinkler") >= 0:
		return "%s upgrade chrome must not say Sprinkler" % label
	if blob.find("Need") < 0 and blob.find("Upgrade") < 0 and blob.find("Maxed") < 0:
		return "%s upgrade button should show Upgrade/Need/Maxed" % label
	return ""


func _assert_field_upgrades_hidden(home: Node, label: String) -> String:
	if home == null:
		return "%s field upgrades missing home" % label
	var entry: Control = home.get_node_or_null("%UpgradesButton") as Control
	if entry and entry.visible:
		return "%s UpgradesButton should be hidden outside the field" % label
	var sheet: Control = home.get_node_or_null("%UpgradesOverlay") as Control
	if sheet and sheet.visible:
		return "%s UpgradesOverlay should be closed" % label
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
	# v2: u polju swipe blokiraju plutajuce kontrole (Gift, korpa, donji red).
	var chrome: Control = home.get_node_or_null("%GiftChest") as Control
	if chrome == null or not chrome.is_visible_in_tree():
		chrome = home.get_node_or_null("%BottomRow") as Control
	if chrome == null or not chrome.is_visible_in_tree():
		chrome = home.get_node_or_null("%PlayRow") as Control
	if chrome == null:
		return "Gift/BottomRow missing for swipe chrome check"
	var chrome_mid: Vector2 = chrome.get_global_rect().get_center()
	if not bool(swipe.call("should_block_hub_swipe_at", chrome_mid)):
		return "%s should block hub swipe" % chrome.name
	return ""


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.set("tutorial_complete", true)
	var stash: Dictionary = {}
	for season_id in ["country_bloom", "frost_orchard"]:
		var def: SeasonDef = gs.call("get_season_def", season_id)
		if def == null:
			continue
		for type_id in def.seed_type_ids:
			stash[str(type_id)] = 5
	gs.set("garden_crystal_stash", stash)

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
	var host: Node = swipe.call("get_pages_host") if swipe.has_method("get_pages_host") else null
	var home: Node = host.get_node_or_null("Page_%d" % MetaHubPages.MAIN) if host else null
	if home == null:
		_fail("Home page missing")
		return
	var stage: Node = home.get_node_or_null("%SeasonStage")
	if stage == null:
		_fail("SeasonStage missing")
		return

	var band: Control = stage.get_node_or_null("%SelectLayer") as Control
	var field: Control = stage.get_node_or_null("%SeasonField") as Control
	var seasons: Node = stage.get_node_or_null("%SeasonsButton")
	if band == null or field == null:
		_fail("SelectLayer or SeasonField missing")
		return
	if bool(gs.get("home_season_field_open")):
		_fail("default field should be closed")
		return
	if not band.visible:
		_fail("default SelectLayer should be visible")
		return
	if field.visible:
		_fail("default SeasonField should be hidden")
		return
	if _count_named(stage, "SeasonField") != 1:
		_fail("expected exactly 1 SeasonField child, got %d" % _count_named(stage, "SeasonField"))
		return
	if seasons == null:
		_fail("SeasonsButton missing")
		return
	if not bool(gs.call("can_open_home_season_field")):
		_fail("Bloom center should can_open")
		return
	# Odluka 2026-09-21: Play na biranju sezone odmah pokrece run.
	if str(home.call("home_play_action")) != "run":
		_fail("trail Bloom: home_play_action should be run")
		return
	var play_row: Node = home.get_node_or_null("%PlayRow")
	var overlay: Control = home.get_node_or_null("%FieldOverlay") as Control
	if overlay == null:
		_fail("FieldOverlay missing")
		return
	if overlay.visible:
		_fail("carousel FieldOverlay should be hidden")
		return
	# v1 cvorovi koje je v2 obrisao.
	for gone in ["%BasketCard", "%FieldTopRow", "%HomeTopStack", "%FieldUpgradeStack", "%SeasonNameChip"]:
		if home.get_node_or_null(gone) != null:
			_fail("%s should be gone in field v2" % gone)
			return
	var basket: Control = home.get_node_or_null("%BasketButton") as Control
	if basket == null:
		_fail("BasketButton missing")
		return
	if basket.get_parent() != overlay:
		_fail("BasketButton parent should be FieldOverlay")
		return
	var bottom: Control = home.get_node_or_null("%BottomRow") as Control
	if bottom == null or bottom.get_parent() != overlay:
		_fail("BottomRow should sit in FieldOverlay")
		return
	var seasons_row: Control = home.get_node_or_null("%SeasonsRowButton") as Control
	if seasons_row == null:
		_fail("SeasonsRowButton missing")
		return
	if seasons_row.visible:
		_fail("carousel SeasonsRowButton should be hidden")
		return
	if seasons_row.get_parent() != bottom:
		_fail("SeasonsRowButton parent should be BottomRow")
		return
	var endless_btn: Control = home.get_node_or_null("%EndlessPlayButton") as Control
	if endless_btn == null:
		_fail("EndlessPlayButton missing")
		return
	if endless_btn.visible:
		_fail("carousel EndlessPlayButton should be hidden")
		return
	if endless_btn.get_parent() != bottom:
		_fail("EndlessPlayButton parent should be BottomRow")
		return
	var play_btn_carousel: Control = home.get_node_or_null("%PlayButton") as Control
	if play_btn_carousel == null:
		_fail("PlayButton missing")
		return
	# Biranje sezone: Play 180 + "run in {active}"; Seasons/Endless su skriveni.
	if play_btn_carousel.custom_minimum_size.y < 176.0:
		_fail("select Play min height expected 180 got %s" % str(play_btn_carousel.custom_minimum_size))
		return
	var name_label: Control = home.get_node_or_null("%SeasonLabel") as Control
	if name_label and name_label.is_visible_in_tree():
		_fail("carousel SeasonLabel should be hidden")
		return
	var carousel_up_err := _assert_field_upgrades_hidden(home, "carousel")
	if not carousel_up_err.is_empty():
		_fail(carousel_up_err)
		return

	# Polje se otvara tapom na otvorenu aktivnu karticu (ne vise preko Playa).
	stage.call("tap_card", "country_bloom")
	await process_frame
	await process_frame
	for _tw in 12:
		if stage.has_method("is_field_transitioning") and bool(stage.call("is_field_transitioning")):
			await process_frame
		else:
			break
	if not bool(gs.get("home_season_field_open")):
		_fail("tap on active Bloom card should open field")
		return
	if str(gs.get("home_season_field_id")) != "country_bloom":
		_fail("field_id expected country_bloom got %s" % str(gs.get("home_season_field_id")))
		return
	if str(home.call("home_play_action")) != "run":
		_fail("Bloom open: home_play_action should be run")
		return
	if band.visible:
		_fail("SelectLayer should hide when field open")
		return
	if not field.visible:
		_fail("SeasonField should show when open")
		return
	if _count_named(stage, "SeasonField") != 1:
		_fail("still exactly 1 SeasonField after open")
		return
	if seasons == null:
		_fail("SeasonsButton missing after open")
		return
	if (seasons as Control).visible:
		_fail("Bloom open: SeasonsButton should be hidden")
		return
	if str(seasons.get("label_text")).findn("Seasons") >= 0:
		_fail("SeasonsButton label should be empty")
		return
	if name_label == null:
		_fail("SeasonLabel missing")
		return
	if not name_label.is_visible_in_tree():
		_fail("Bloom open: SeasonLabel should be visible")
		return
	var bloom_chip := str((name_label as Label).text)
	if bloom_chip.find("Country Bloom") < 0:
		_fail("Bloom label expected Country Bloom got '%s'" % bloom_chip)
		return
	await process_frame
	await process_frame
	home.call("_open_upgrades_sheet")
	for _u in 4:
		await process_frame
	var bloom_up_err := _assert_field_upgrades_open(home, "Bloom open")
	if not bloom_up_err.is_empty():
		_fail(bloom_up_err)
		return
	home.call("_close_upgrades_sheet")
	await process_frame
	var swipe_err := _assert_open_field_hub_swipe(home, swipe, field)
	if not swipe_err.is_empty():
		_fail("Bloom open: %s" % swipe_err)
		return
	if hub.has_method("go_to_page"):
		hub.call("go_to_page", MetaHubPages.CAMP, false)
	for _camp_i in 12:
		await process_frame
	if not bool(gs.get("home_season_field_open")):
		_fail("CAMP hop should keep home_season_field_open")
		return
	if str(gs.get("home_season_field_id")) != "country_bloom":
		_fail("CAMP hop should keep field_id country_bloom")
		return
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	for _main_i in 12:
		await process_frame
	if not bool(gs.get("home_season_field_open")):
		_fail("return MAIN should keep home_season_field_open")
		return
	if str(gs.get("home_season_field_id")) != "country_bloom":
		_fail("return MAIN should keep field_id country_bloom")
		return
	if field == null or not field.visible:
		_fail("return MAIN should still show SeasonField")
		return
	var bloom_def: SeasonDef = gs.call("get_season_def", "country_bloom")
	var bloom_pool: Array = bloom_def.seed_type_ids if bloom_def else []
	var bloom_flower_err := _assert_flowers(field, bloom_pool, "Bloom")
	if not bloom_flower_err.is_empty():
		_fail(bloom_flower_err)
		return
	if not home.has_method("_on_basket_type_picked"):
		_fail("missing _on_basket_type_picked")
		return
	home.call("_on_basket_type_picked", "clover")
	await process_frame
	# v2: BasketVisual je dijete plocice korpe, gradi ga FieldBasketButton.
	var basket_vis: Node = basket.find_child("BasketVisual", true, false)
	if basket_vis == null:
		_fail("BasketVisual missing")
		return
	var vis_script: Script = basket_vis.get_script()
	if vis_script == null or not str(vis_script.resource_path).ends_with("home_basket_visual.gd"):
		_fail("BasketVisual must keep home_basket_visual.gd T3 path")
		return
	var bloom_chrome_err := _assert_flowers_clear_chrome(home, field, "Bloom")
	if not bloom_chrome_err.is_empty():
		_fail(bloom_chrome_err)
		return
	var bloom_types := _flower_types(_field_flowers(field))
	var pip: Control = stage.get_node_or_null("%MeadowPip") as Control
	if pip == null:
		_fail("MeadowPip missing")
		return
	if _count_named(field, "MeadowPip") != 1:
		_fail("expected exactly 1 MeadowPip, got %d" % _count_named(field, "MeadowPip"))
		return
	var bloom_pip_err := _assert_pip_alive(field, pip, "Bloom open")
	if not bloom_pip_err.is_empty():
		_fail(bloom_pip_err)
		return
	var bloom_pip_id := pip.get_instance_id()
	var backdrop: ColorRect = home.get_node_or_null("%FieldBackdrop") as ColorRect
	var home_bg: ColorRect = home.get_node_or_null("Background") as ColorRect
	var daily: Control = home.get_node_or_null("%DailyChestCard") as Control
	if not daily is HomeGiftCard:
		_fail("DailyChestCard must be the v2 Gift card")
		return
	var play_btn: Control = home.get_node_or_null("%FieldPlayButton") as Control
	if backdrop == null:
		_fail("FieldBackdrop missing")
		return
	if not backdrop.visible:
		_fail("Bloom open: FieldBackdrop should be visible")
		return
	if not backdrop.color.is_equal_approx(HOME_DARK):
		_fail("Bloom FieldBackdrop should stay page dark #2E4733")
		return
	if backdrop.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("FieldBackdrop must IGNORE")
		return
	# v2: SeasonStage je cijela stranica, pa backdrop mora biti bar toliki.
	if backdrop.size.y < (stage as Control).size.y - 1.5:
		_fail("FieldBackdrop should cover the whole page")
		return
	# Daily gift je u Play redu biranja sezone; u polju je skriven.
	if daily and daily.is_visible_in_tree():
		_fail("Bloom open: Daily gift belongs to the season picker, not the field")
		return
	if daily and daily.is_visible_in_tree() and not backdrop.get_global_rect().has_point(daily.global_position + daily.size * 0.5):
		_fail("FieldBackdrop should cover Daily")
		return
	if play_btn and not backdrop.get_global_rect().has_point(play_btn.global_position + play_btn.size * 0.5):
		_fail("FieldBackdrop should cover Play")
		return
	if home_bg == null or not home_bg.color.is_equal_approx(HOME_DARK):
		_fail("Home Background should stay dark green")
		return
	if not basket.is_visible_in_tree():
		_fail("Bloom open: BasketButton should be visible")
		return
	var gift_tile: Control = home.get_node_or_null("%GiftChest") as Control
	if gift_tile == null or not gift_tile.is_visible_in_tree():
		_fail("Bloom open: GiftChest should be visible in the field")
		return
	# Gift i korpa dijele kolonu i mjeru (180), korpa je odmah ispod.
	if absf(gift_tile.size.x - basket.size.x) > 1.5 or absf(gift_tile.size.y - basket.size.y) > 1.5:
		_fail("Gift and Basket must share the tile size, got %s / %s" % [
			str(gift_tile.size), str(basket.size)
		])
		return
	if absf(basket.global_position.x - gift_tile.global_position.x) > 1.5:
		_fail("Basket should sit directly under Gift")
		return
	if basket.get_global_rect().position.y + 0.5 < gift_tile.get_global_rect().end.y:
		_fail("Bloom open: Basket should sit below Gift")
		return
	if absf(basket.size.y - float(UI_FIELD.TILE)) > 1.5:
		_fail("Bloom open: Basket tile expected 180 got %s" % str(basket.size))
		return
	if basket.size.y < 170.0:
		_fail("Bloom open: Basket height expected ~180 got %s" % str(basket.size))
		return
	var basket_btn: Control = home.get_node_or_null("%BasketButton") as Control
	if basket_btn == null:
		_fail("Bloom open: BasketButton missing")
		return
	if not seasons_row.visible:
		_fail("Bloom open: SeasonsRowButton should be visible")
		return
	if not endless_btn.visible:
		_fail("Bloom open: EndlessPlayButton should be visible")
		return
	if play_btn and endless_btn.global_position.x <= play_btn.global_position.x:
		_fail("Bloom open: EndlessPlayButton should sit right of Play")
		return
	var bloom_row_err := _assert_play_row_equal(home)
	if not bloom_row_err.is_empty():
		_fail("Bloom open: %s" % bloom_row_err)
		return
	if str(gs.get("active_season_id")) != "country_bloom":
		_fail("Bloom open: active_season_id expected country_bloom")
		return
	var bloom_spawn: Array = gs.call("get_active_season_spawn_types")
	if bloom_spawn.has("frost_snowdrop"):
		_fail("Bloom spawn types must not include frost_snowdrop")
		return
	for type_id in bloom_spawn:
		if not bloom_pool.has(type_id):
			_fail("Bloom spawn type %s not in Bloom seed_type_ids" % str(type_id))
			return
	var bloom_picker: Array = gs.call("get_unlocked_loadout_types_for_season", "country_bloom")
	if bloom_picker.has("frost_snowdrop"):
		_fail("Bloom picker types must not include frost_snowdrop")
		return
	for label in _picker_labels(home):
		if str(label).findn("frost") >= 0 or str(label).findn("snowdrop") >= 0:
			_fail("Bloom picker row must not list frost-only seed: %s" % label)
			return
	if home.has_method("_open_basket_picker"):
		home.call("_open_basket_picker")
	await process_frame
	await process_frame
	var bloom_fit := _assert_picker_fits_panel(home)
	if not bloom_fit.is_empty():
		_fail("Bloom open: %s" % bloom_fit)
		return
	if home.has_method("_close_basket_picker"):
		home.call("_close_basket_picker")
	await process_frame

	if not bool(gs.get("home_season_field_open")):
		_fail("field should stay open")
		return
	if seasons_row.has_signal("clicked"):
		seasons_row.emit_signal("clicked")
	elif stage.has_method("close_season_field"):
		stage.call("close_season_field")
	await process_frame
	if not _field_flowers(field).is_empty():
		_fail("close should clear meadow flowers")
		return
	if field.has_method("is_pip_wandering") and bool(field.call("is_pip_wandering")):
		_fail("close should stop Pip wander")
		return
	if field.has_method("is_pip_alive") and bool(field.call("is_pip_alive")):
		_fail("close should stop Pip FSM")
		return
	if pip.visible and field.visible:
		_fail("close should hide MeadowPip")
		return
	if bool(gs.get("home_season_field_open")):
		_fail("close should clear flag")
		return
	if not band.visible:
		_fail("SelectLayer should show after close")
		return
	if field.visible:
		_fail("SeasonField should hide after close")
		return
	if backdrop.visible:
		_fail("close should hide FieldBackdrop")
		return
	if home_bg == null or not home_bg.color.is_equal_approx(UiStage.PAGE_BG):
		_fail("close: Home Background should be the season-select #243329")
		return
	if basket.is_visible_in_tree():
		_fail("close should hide the Basket tile")
		return
	if seasons_row.visible:
		_fail("close should hide SeasonsRowButton")
		return
	if endless_btn.visible:
		_fail("close should hide EndlessPlayButton")
		return
	if name_label.is_visible_in_tree():
		_fail("close should hide SeasonLabel")
		return
	var close_up_err := _assert_field_upgrades_hidden(home, "close")
	if not close_up_err.is_empty():
		_fail(close_up_err)
		return
	gs.set("loadout_type_id", "clover")

	var unlocked: Array = gs.get("unlocked_seasons")
	if not unlocked.has("frost_orchard"):
		unlocked.append("frost_orchard")
	gs.set("focus_season_id", "frost_orchard")
	gs.set("home_band", "free")
	if not bool(gs.call("can_open_home_season_field")):
		_fail("playable Frost should can_open")
		return
	if not bool(stage.call("open_season_field")):
		_fail("open Frost field failed")
		return
	for _ftw in 12:
		if stage.has_method("is_field_transitioning") and bool(stage.call("is_field_transitioning")):
			await process_frame
		else:
			break
	await process_frame
	await process_frame
	if str(gs.get("home_season_field_id")) != "frost_orchard":
		_fail("field_id expected frost_orchard got %s" % str(gs.get("home_season_field_id")))
		return
	var ground_color := Color.WHITE
	if field.has_method("get_ground_color"):
		ground_color = field.call("get_ground_color")
	else:
		var ground: ColorRect = stage.get_node_or_null("%MeadowGround") as ColorRect
		if ground == null:
			_fail("MeadowGround missing")
			return
		ground_color = ground.color
	if ground_color.is_equal_approx(BLOOM_PASTEL) or ground_color.is_equal_approx(Color.WHITE):
		_fail("Frost MeadowGround tint should differ from Bloom")
		return
	if not backdrop.visible:
		_fail("Frost open: FieldBackdrop should be visible")
		return
	if not backdrop.color.is_equal_approx(HOME_DARK):
		_fail("Frost FieldBackdrop should stay page dark #2E4733")
		return
	var frost_def: SeasonDef = gs.call("get_season_def", "frost_orchard")
	var frost_pool: Array = frost_def.seed_type_ids if frost_def else []
	var frost_flower_err := _assert_flowers(field, frost_pool, "Frost")
	if not frost_flower_err.is_empty():
		_fail(frost_flower_err)
		return
	home.call("_open_upgrades_sheet")
	for _u2 in 4:
		await process_frame
	var frost_up_err := _assert_field_upgrades_open(home, "Frost open")
	if not frost_up_err.is_empty():
		_fail(frost_up_err)
		return
	home.call("_close_upgrades_sheet")
	await process_frame
	var frost_chrome_err := _assert_flowers_clear_chrome(home, field, "Frost")
	if not frost_chrome_err.is_empty():
		_fail(frost_chrome_err)
		return
	var frost_types := _flower_types(_field_flowers(field))
	if frost_types == bloom_types:
		_fail("Frost flower types should differ from Bloom")
		return
	if _count_named(stage, "SeasonField") != 1:
		_fail("still exactly 1 SeasonField after Frost open")
		return
	var frost_pip: Control = stage.get_node_or_null("%MeadowPip") as Control
	if frost_pip == null or frost_pip.get_instance_id() != bloom_pip_id:
		_fail("Frost should reuse the same MeadowPip node")
		return
	if _count_named(field, "MeadowPip") != 1:
		_fail("Frost: expected 1 MeadowPip")
		return
	var frost_pip_err := _assert_pip_alive(field, frost_pip, "Frost open")
	if not frost_pip_err.is_empty():
		_fail(frost_pip_err)
		return
	if str(gs.get("loadout_type_id")) != "":
		_fail("Frost open should clear clover loadout")
		return
	if not basket.is_visible_in_tree():
		_fail("Frost open: Basket tile should be visible")
		return
	if not seasons_row.visible:
		_fail("Frost open: SeasonsRowButton should be visible")
		return
	if not endless_btn.visible:
		_fail("Frost open: EndlessPlayButton should be visible")
		return
	var frost_row_err := _assert_play_row_equal(home)
	if not frost_row_err.is_empty():
		_fail("Frost open: %s" % frost_row_err)
		return
	if str(gs.get("active_season_id")) != "frost_orchard":
		_fail("Frost open: active_season_id expected frost_orchard")
		return
	var frost_spawn: Array = gs.call("get_active_season_spawn_types")
	if not frost_spawn.has("frost_snowdrop"):
		_fail("Frost spawn types should include frost_snowdrop")
		return
	if frost_spawn.has("clover"):
		_fail("Frost spawn types must not include clover")
		return
	for type_id in frost_spawn:
		if not frost_pool.has(type_id):
			_fail("Frost spawn type %s not in Frost seed_type_ids" % str(type_id))
			return
	var frost_picker: Array = gs.call("get_unlocked_loadout_types_for_season", "frost_orchard")
	if not frost_picker.has("frost_snowdrop"):
		_fail("Frost picker types should include frost_snowdrop")
		return
	if frost_picker.has("clover"):
		_fail("Frost picker types must not include clover")
		return
	for type_id in frost_picker:
		if not frost_pool.has(type_id):
			_fail("Frost picker type %s not in Frost seed_type_ids" % str(type_id))
			return
	var frost_labels := _picker_labels(home)
	var frost_joined := " ".join(frost_labels)
	if frost_joined.findn("snowdrop") < 0:
		_fail("Frost picker should list Frost Snowdrop")
		return
	if frost_joined.findn("clover") >= 0:
		_fail("Frost picker must not list clover")
		return
	if name_label == null or not name_label.is_visible_in_tree():
		_fail("Frost open: SeasonLabel should be visible")
		return
	var frost_chip := str((name_label as Label).text)
	if frost_chip.find("Frost Orchard") < 0:
		_fail("Frost chip expected Frost Orchard got '%s'" % frost_chip)
		return
	if frost_chip == bloom_chip:
		_fail("Frost chip text should differ from Bloom")
		return

	stage.call("close_season_field")
	await process_frame
	if field.has_method("is_pip_wandering") and bool(field.call("is_pip_wandering")):
		_fail("Frost close should stop Pip wander")
		return
	if field.has_method("is_pip_alive") and bool(field.call("is_pip_alive")):
		_fail("Frost close should stop Pip FSM")
		return
	if frost_pip.visible and field.visible:
		_fail("Frost close should hide MeadowPip")
		return
	if basket.is_visible_in_tree():
		_fail("Frost close should hide the Basket tile")
		return
	if endless_btn.visible:
		_fail("Frost close should hide EndlessPlayButton")
		return
	if name_label.is_visible_in_tree():
		_fail("Frost close should hide SeasonLabel")
		return
	var frost_close_up_err := _assert_field_upgrades_hidden(home, "Frost close")
	if not frost_close_up_err.is_empty():
		_fail(frost_close_up_err)
		return
	gs.call("reset_seasons_to_s1")
	gs.set("focus_season_id", "lantern_meadow")
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	await process_frame
	# v2: daleki lock ne smije zadrzati fokus — clamp ide na aktivnu (Bloom).
	if str(gs.get("focus_season_id")) == "lantern_meadow":
		_fail("far lock lantern should lose focus after refresh")
		return
	if str(gs.get("focus_season_id")) != "country_bloom":
		_fail("after lantern clamp, focus should be active Bloom got %s" % str(gs.get("focus_season_id")))
		return
	if bool(stage.call("open_season_field", "lantern_meadow")):
		_fail("open locked lantern field should return false")
		return
	if bool(gs.get("home_season_field_open")):
		_fail("locked lantern open must not set flag")
		return
	if not bool(gs.call("set_free_strip_focus", "frost_orchard")):
		_fail("next-lock frost should take focus")
		return
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	if bool(gs.call("can_open_home_season_field")):
		_fail("next-lock frost should not can_open")
		return
	if bool(gs.call("open_home_season_field")):
		_fail("open next-lock frost should return false")
		return
	if bool(gs.get("home_season_field_open")):
		_fail("locked open must not set flag")
		return
	# Play ne ovisi o fokusu: i s fokusom na sljedecem locku pokrece aktivnu (run).
	if str(home.call("home_play_action")) != "run":
		_fail("locked focus: home_play_action should still be run")
		return
	if str(home.call("get_play_chip_text")) != "Country Bloom":
		_fail("locked focus: Play chip should name the active season")
		return
	stage.call("tap_card", "coral_tide")
	await process_frame
	await process_frame
	if bool(gs.get("home_season_field_open")):
		_fail("unowned premium tap must not open the field")
		return
	if str(gs.get("active_season_id")) != "country_bloom":
		_fail("unowned premium preview must not change the active season")
		return
	if str(home.call("get_play_chip_text")) != "Country Bloom":
		_fail("unowned premium preview: Play chip stays on Bloom")
		return

	CampSmokeUtil.restore_save(self, _backup)
	print("season_meadow_smoke OK")
	quit(0)
