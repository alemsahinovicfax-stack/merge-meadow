extends SceneTree

## design_handoff_home_field_v2: livada je cijela stranica, a chrome pluta preko nje.
## Ovaj smoke cuva sest stvari: livada 1080 x 1633, svaka kontrola na svom mjestu i
## unutar stranice, kontrole blokiraju hub swipe (livada i info ne), nijedno mjesto
## ni Pip nisu pod keepoutom, oba sheeta se otvaraju i zatvaraju, i na ekranu je
## najvise JEDAN loop (prsten oko prazne korpe).

const UI_FIELD := preload("res://scripts/visual/ui_home_field.gd")
const PAGE := Vector2(1080.0, 1633.0)
const TOL := 1.5

var _failed: bool = false


func _initialize() -> void:
	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		push_error("home_field_overlay_smoke: hub load failed %d" % err)
		quit(1)
		return
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("home_field_overlay_smoke: " + msg)


func _settle(frames: int = 6) -> void:
	for _i in frames:
		await process_frame


func _run() -> void:
	for _i in 14:
		await process_frame
	var gs := get_root().get_node_or_null("GameState")
	var hubs := get_nodes_in_group("meta_hub")
	if gs == null or hubs.is_empty():
		_fail("GameState / meta_hub missing")
		quit(1)
		return
	var hub := hubs[0] as Control
	hub.call("go_to_page", 2, false)
	await _settle(10)
	var swipe := hub.get_node_or_null("RootVBox/SwipePager")
	var host: Node = swipe.call("get_pages_host") if swipe and swipe.has_method("get_pages_host") else null
	var home := (host.get_node_or_null("Page_2") if host else null) as Control
	if home == null:
		_fail("MainMenu page missing")
		quit(1)
		return
	var stage := home.get_node_or_null("%SeasonStage") as Control
	if stage == null or not bool(stage.call("open_season_field")):
		_fail("could not open the season field")
		quit(1)
		return
	# Chrome uplovljava 0,22 s + stagger — provjera mora sacekati kraj tweena.
	await create_timer(1.2).timeout
	await _settle(4)

	_check_page(home, stage)
	_check_controls(home)
	_check_keepout(home, stage)
	await _check_sheets(home)
	_check_single_loop(home)

	if stage.has_method("close_season_field"):
		stage.call("close_season_field")
	await _settle(4)
	if _failed:
		quit(1)
		return
	print("home_field_overlay_smoke OK")
	quit(0)


## Livada uzima cijelu stranicu, bez okvira.
func _check_page(home: Control, stage: Control) -> void:
	var page := home.get_global_rect()
	if absf(page.size.x - PAGE.x) > TOL or absf(page.size.y - PAGE.y) > TOL:
		_fail("page expected %s got %s" % [str(PAGE), str(page.size)])
		return
	var field := stage.get_node_or_null("%SeasonField") as Control
	if field == null or not field.visible:
		_fail("SeasonField should be visible")
		return
	var fr := field.get_global_rect()
	if absf(fr.size.x - PAGE.x) > TOL or absf(fr.size.y - PAGE.y) > TOL:
		_fail("meadow expected the whole page, got %s" % str(fr.size))
	if absf(fr.position.y - page.position.y) > TOL:
		_fail("meadow should start at the top of the page")


## Svaka kontrola stoji na mjestu iz handoffa i ne izlazi iz stranice.
func _check_controls(home: Control) -> void:
	var page := home.get_global_rect()
	var want := {
		"%GiftChest": UI_FIELD.GIFT_RECT,
		"%BasketButton": UI_FIELD.BASKET_RECT,
		"%UpgradesButton": UI_FIELD.UPGRADES_RECT,
	}
	for path in want.keys():
		var ctrl := home.get_node_or_null(path) as Control
		if ctrl == null or not ctrl.is_visible_in_tree():
			_fail("%s should be visible in the field" % path)
			continue
		var rect := ctrl.get_global_rect()
		rect.position -= page.position
		var target := Rect2(want[path])
		if not rect.position.is_equal_approx(target.position) \
				or absf(rect.size.x - target.size.x) > TOL \
				or absf(rect.size.y - target.size.y) > TOL:
			_fail("%s expected %s got %s" % [path, str(target), str(rect)])
		if rect.size.y < 120.0:
			_fail("%s touch height %s < 120" % [path, str(rect.size.y)])
		if not page.grow(TOL).encloses(ctrl.get_global_rect()):
			_fail("%s spills off the page" % path)

	# Ime sezone i cip su info — swipe mora proci, pa NISU u block_hub_swipe.
	for path in ["%SeasonLabel", "%GrownChip"]:
		var info := home.get_node_or_null(path) as Control
		if info == null or not info.is_visible_in_tree():
			_fail("%s should be visible in the field" % path)
			continue
		if info.is_in_group("block_hub_swipe"):
			_fail("%s must let the hub swipe through" % path)
	# Kontrole blokiraju swipe.
	for path in ["%GiftChest", "%BasketButton", "%UpgradesButton", "%BottomRow"]:
		var ctrl2 := home.get_node_or_null(path) as Control
		if ctrl2 and not ctrl2.is_in_group("block_hub_swipe"):
			_fail("%s should block the hub swipe" % path)


## Nijedno mjesto i Pip ne smiju pod plutajuci chrome.
func _check_keepout(home: Control, stage: Control) -> void:
	var page := home.get_global_rect().position
	var field := stage.get_node_or_null("%SeasonField") as Control
	if field == null:
		return
	var spots := 0
	for child in field.get_children():
		var ctrl := child as Control
		if ctrl == null:
			continue
		if not (str(ctrl.name).begins_with("MeadowSpot_") or str(ctrl.name).begins_with("MeadowSoil_")):
			continue
		spots += 1
		var rect := ctrl.get_global_rect()
		rect.position -= page
		if UI_FIELD.hits_keepout(rect):
			_fail("%s sits under a keepout zone (%s)" % [ctrl.name, str(rect)])
	if spots != UI_FIELD.MEADOW_SPOTS.size():
		_fail("expected %d spots, got %d" % [UI_FIELD.MEADOW_SPOTS.size(), spots])
	var pip := field.get_node_or_null("MeadowPip") as Control
	if pip and pip.visible:
		var pr := pip.get_global_rect()
		pr.position -= page
		if UI_FIELD.hits_keepout(pr):
			_fail("Pip sits under a keepout zone (%s)" % str(pr))
		if absf(pip.size.x - float(UI_FIELD.PIP_SIZE)) > TOL:
			_fail("Pip expected %d px got %s" % [UI_FIELD.PIP_SIZE, str(pip.size)])


## Oba sheeta koriste isti obrazac: otvore se, pokriju ekran, zatvore se.
func _check_sheets(home: Control) -> void:
	var basket_sheet := home.get_node_or_null("%BasketPickerOverlay") as Control
	var upgrades_sheet := home.get_node_or_null("%UpgradesOverlay") as Control
	if basket_sheet == null or upgrades_sheet == null:
		_fail("sheets missing")
		return
	if basket_sheet.visible or upgrades_sheet.visible:
		_fail("sheets should start closed")
	home.call("_open_upgrades_sheet")
	await _settle(4)
	if not upgrades_sheet.visible:
		_fail("UpgradesOverlay should open")
	var panel := home.get_node_or_null("%UpgradesPanel") as Control
	if panel and absf(panel.size.y - float(UI_FIELD.SHEET_UPGRADES_H)) > TOL:
		_fail("UpgradesPanel expected %d got %s" % [UI_FIELD.SHEET_UPGRADES_H, str(panel.size.y)])
	for path in ["%MagnetButton", "%LootBoostButton"]:
		var btn := home.get_node_or_null(path) as Control
		if btn == null or not btn.is_visible_in_tree():
			_fail("%s should live in the upgrades sheet" % path)
	home.call("_close_upgrades_sheet")
	await _settle(2)
	if upgrades_sheet.visible:
		_fail("UpgradesOverlay should close")
	home.call("_open_basket_picker")
	await _settle(4)
	if not basket_sheet.visible:
		_fail("BasketPickerOverlay should open")
	var picker := home.get_node_or_null("%PickerPanel") as Control
	if picker and absf(picker.size.y - float(UI_FIELD.SHEET_BASKET_H)) > TOL:
		_fail("PickerPanel expected %d got %s" % [UI_FIELD.SHEET_BASKET_H, str(picker.size.y)])
	home.call("_close_basket_picker")
	await _settle(2)
	if basket_sheet.visible:
		_fail("BasketPickerOverlay should close")


## Jedini loop na ekranu je prsten oko prazne korpe (29 loopova = 10 fps na emulatoru).
func _check_single_loop(home: Control) -> void:
	var basket := home.get_node_or_null("%BasketButton")
	if basket == null:
		return
	var empty := str(basket.call("get_state")) == "empty"
	var running := bool(basket.call("is_attention_running"))
	if empty and not running:
		_fail("empty basket should pulse")
	if not empty and running:
		_fail("only the empty basket may loop")
