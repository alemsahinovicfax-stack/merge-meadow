extends SceneTree

## design_handoff_wardrobe · § Samoprovjera — Ormar u pravoj igri (headless):
##  1. pločica Looks (876, 1265, 180) na polju, 0 presjeka s keepoutima / cvijećem / Pipom;
##  2. mjere: kartica 240 x 272, tab 120, Close 132, sheet 1326 od y 307;
##  3. svaki slot tačno 1 DefaultCard; Blossom → Close → Pip na polju u Blossomu;
##     Default → tap na scrim → Pip opet klasičan; povlačenje > 160 zatvara;
##  4. najviše 1 ShopLink po ekranu, 0 stavki iz Shopa koje igrač nema, 0 cijena;
##  5. proširenje samo podacima: 8 slotova / Pip 11 + Default; demoN 1 / 5 / 30;
##  6. katalog iz cosmetics.json: 5 id / slot / cijena kao prije;
##  7. svaki recolor ključ postoji u pip parts SVG-ima, atlas skina se rasterizuje;
##  8. Android back zatvara (i snima) ormar, ne polje; nema riječi „Save".
## Bez statičkih tipova za klase koje vide GameState (-s skripta se kompajlira prije autoloada).

const DEMO := preload("res://scripts/dev/wardrobe_demo_catalog.gd")
const PAGE := Vector2(1080.0, 1633.0)
const LEGACY := {
	"pip_blossom": ["pip_skin", 250], "pip_sky": ["pip_skin", 200],
	"meadow_sunset": ["meadow_bg", 150], "meadow_lavender": ["meadow_bg", 180],
	"journal_gold": ["journal_frame", 120],
}

var _failed: bool = false
var _backup := ""
var _gs: Node
var _home: Control
var _stage: Control
var _w: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("wardrobe_smoke: " + msg)


func _settle(frames: int = 6) -> void:
	for _i in frames:
		await process_frame


func _run() -> void:
	_check_catalog()
	_check_recolor()
	_gs = get_root().get_node_or_null("GameState")
	# Stanje ne smije zavisiti od developerovog save-a: fokus na nekupljenoj
	# premium sezoni (home_band "paid") ne otvara polje.
	_gs.set("skip_debug_season_unlock", true)
	_gs.call("reset_seasons_to_s1")
	_gs.set("tutorial_complete", true)
	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		_fail("hub load failed")
		_finish()
		return
	await _settle(14)
	var hub := get_nodes_in_group("meta_hub")[0] as Control
	hub.call("go_to_page", 2, false)
	await _settle(10)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	_home = host.get_node("Page_2") as Control
	_stage = _home.get_node("%SeasonStage") as Control
	var cos: Object = _gs.get("cosmetics")
	cos.set("owned", {"pip_blossom": true, "meadow_sunset": true, "meadow_lavender": true, "journal_gold": true})
	cos.set("equipped", {"meadow_bg": "meadow_sunset"})
	if not bool(_stage.call("open_season_field")):
		_fail("could not open the season field")
		_finish()
		return
	await create_timer(1.2).timeout
	await _settle(4)
	_w = _home.get("wardrobe_sheet") as Node
	if _w == null:
		_fail("WardrobeSheet missing on MainMenu")
		_finish()
		return
	_check_field()
	await _check_sheet_layout()
	await _check_live_flow()
	await _check_back()
	await _check_extra()
	await _check_shop_link(hub)
	_finish()


func _finish() -> void:
	CosmeticCatalog.reload()
	if _stage != null and _stage.has_method("close_season_field"):
		_stage.call("close_season_field", false)
	await _settle(2)
	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		quit(1)
		return
	print("wardrobe_smoke OK")
	quit(0)


# 6 — katalog
func _check_catalog() -> void:
	var ids := CosmeticCatalog.all_ids()
	if ids.size() != LEGACY.size():
		_fail("catalog has %d items, expected %d" % [ids.size(), LEGACY.size()])
	for id in LEGACY:
		var want: Array = LEGACY[id]
		if CosmeticCatalog.get_slot(id) != str(want[0]) or CosmeticCatalog.get_coin_cost(id) != int(want[1]):
			_fail("%s slot/cost changed: %s %d" % [id, CosmeticCatalog.get_slot(id), CosmeticCatalog.get_coin_cost(id)])
	for sid in ["pip_skin", "meadow_bg", "journal_frame"]:
		var sd := CosmeticCatalog.get_slot_def(sid)
		if sd.is_empty() or not bool(sd.get("allow_default", false)):
			_fail("slot %s missing or without Default" % sid)
		if not UiWardrobe.PREVIEW_KINDS.has(str(sd.get("preview", ""))):
			_fail("slot %s has unknown preview kind" % sid)
	if CosmeticCatalog.get_meadow_modulate("meadow_sunset") != Color(1.08, 0.94, 0.86, 1.0):
		_fail("meadow_sunset tint changed")
	if CosmeticCatalog.get_journal_title_color("journal_gold") != Color(0.8, 0.8, 0.8, 1.0):
		_fail("journal_gold title modulate changed")


# 7 — recolor na pravom artu
func _check_recolor() -> void:
	var src := ""
	var dir := DirAccess.open("res://assets/pip/parts")
	if dir == null:
		_fail("assets/pip/parts not readable")
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while not fname.is_empty():
		if fname.ends_with(".svg"):
			src += FileAccess.get_file_as_string("res://assets/pip/parts/" + fname)
		fname = dir.get_next()
	if src.is_empty():
		_fail("pip part SVGs not readable")
		return
	for it in CosmeticCatalog.items_in_slot("pip_skin"):
		var id := str(it.get("id", ""))
		var map := CosmeticCatalog.get_recolor(id)
		if map.is_empty():
			_fail("%s has no recolor" % id)
		for k in map:
			if src.findn(str(k)) < 0:
				_fail("%s recolor key %s not in pip parts" % [id, k])
		if not UiWardrobe.skin_body_ok(Color(str(map.get("#A8E6CF", "#A8E6CF")))):
			_fail("%s body too dark for the double edge" % id)
		var key := UiPip.skin_key_from_cosmetic(id)
		var atlas: Dictionary = UiPip.atlas_for(key)
		if atlas.is_empty() or atlas.get("texture") == null:
			_fail("%s atlas missing" % id)
	if UiPip.atlas_for("classic").get("texture") == null:
		_fail("classic Pip atlas missing")


# 1 — polje
func _check_field() -> void:
	var btn := _home.get("wardrobe_button") as Control
	if btn == null or not btn.is_visible_in_tree():
		_fail("WardrobeButton not visible on the field")
		return
	var r := Rect2(btn.position, btn.size)
	if r != Rect2(UiHomeField.WARDROBE_RECT):
		_fail("WardrobeButton at %s, expected %s" % [r, Rect2(UiHomeField.WARDROBE_RECT)])
	if not btn.is_in_group("block_hub_swipe"):
		_fail("WardrobeButton must block the hub swipe")
	var own := Rect2(860, 1249, 212, 212)
	for zone in UiHomeField.KEEPOUT:
		var z := Rect2(zone)
		if z != own and z.intersects(r):
			_fail("WardrobeButton hits keepout %s" % z)
	for spot in UiHomeField.MEADOW_SPOTS:
		var base := UiHomeField.spot_base(spot)
		var side := float(spot[2])
		var sr := Rect2(base.x - side * 0.5, base.y - side, side, side)
		if sr.intersects(own):
			_fail("meadow spot %s under the wardrobe keepout" % [spot])
	var zone := Rect2(UiHomeField.PIP_BASE_ZONE)
	var pip_right := zone.end.x + float(UiHomeField.PIP_SIZE) * 0.5
	if pip_right > own.position.x + 0.5:
		_fail("Pip can stand under the wardrobe (right edge %.0f)" % pip_right)


# 2 + 4 — sheet
func _check_sheet_layout() -> void:
	_w.call("open", "", false)
	await _settle(4)
	var sheet := _w.call("sheet_node") as Control
	if absf(sheet.position.y - 307.0) > 1.5 or absf(sheet.size.y - 1326.0) > 0.5:
		_fail("sheet rect %s, expected y 307 h 1326" % Rect2(sheet.position, sheet.size))
	var close_btn := _w.call("close_button") as Control
	if absf(close_btn.size.y - 132.0) > 0.5 or close_btn.position.y + close_btn.size.y > 1326.0 - 27.5:
		_fail("Close button %s" % Rect2(close_btn.position, close_btn.size))
	for slot_id in CosmeticCatalog.slot_ids():
		_w.call("select_slot", slot_id)
		await _settle(2)
		_check_screen(slot_id)
	for tab in _w.call("get_tabs"):
		if absf((tab as Control).size.y - 120.0) > 0.5:
			_fail("tab height %s" % (tab as Control).size.y)
	_w.call("close", false)
	await _settle(2)


func _check_screen(slot_id: String) -> void:
	var defaults := 0
	var links := 0
	for n in _w.call("grid_cell_nodes"):
		var c := n as Control
		if c.name == "DefaultCard":
			defaults += 1
		if c.name == "ShopLink" or c.find_child("ShopLink", true, false) != null:
			links += 1
		if c.has_method("is_default"):
			if c.size != Vector2(240, 272):
				_fail("card size %s" % c.size)
			var id := str(c.get("item_id"))
			if not id.is_empty() and CosmeticCatalog.is_shop_item(id) and not bool(_gs.call("owns_cosmetic", id)):
				_fail("%s shows a Shop item the player does not own: %s" % [slot_id, id])
			var t := str(c.get("title")).to_lower()
			for word in ["buy", "coins", "price", "$", "€", "save"]:
				if t.contains(word):
					_fail("card text '%s' contains '%s'" % [t, word])
	if defaults != 1:
		_fail("%s has %d DefaultCards" % [slot_id, defaults])
	if links > 1:
		_fail("%s has %d ShopLinks" % [slot_id, links])


# 3 — živi tok
func _check_live_flow() -> void:
	var field := _stage.get_node("%SeasonField")
	var pip := field.get_node("MeadowPip")
	var classic := PipAssets.get_texture("")
	_w.call("open", "", false)
	_w.call("select_slot", "pip_skin")
	await _settle(2)
	var card := _w.call("get_card", "pip_blossom") as Control
	if card == null:
		_fail("pip_blossom card missing")
		return
	card.call("simulate_tap")
	await _settle(2)
	if str((_w.get("pending") as Dictionary).get("pip_skin", "")) != "pip_blossom":
		_fail("tap did not pick pip_blossom")
	if str(_gs.call("get_equipped_cosmetic", "pip_skin")) != "":
		_fail("pick must not save before close")
	var stage_texts: PackedStringArray = _w.call("stage_texts")
	if stage_texts[0] != "Pip Blossom":
		_fail("stage name '%s'" % stage_texts[0])
	(_w.call("close_button") as Control).call("simulate_tap")
	if str(_gs.call("get_equipped_cosmetic", "pip_skin")) != "pip_blossom":
		_fail("Close did not apply pip_blossom")
	if PipAssets.get_texture() == classic:
		_fail("PipAssets still returns the classic texture")
	await create_timer(0.45).timeout
	if bool(_w.call("is_open")):
		_fail("sheet still open after Close")
	if not bool(pip.call("is_apply_playing")):
		_fail("ApplyMoment hop did not start")
	await create_timer(0.7).timeout

	_w.call("open", "", false)
	await _settle(2)
	var def := _w.call("get_card", "") as Control
	def.call("simulate_tap")
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	(_w.get_node("WardrobeScrim") as Control).gui_input.emit(ev)
	if str(_gs.call("get_equipped_cosmetic", "pip_skin")) != "":
		_fail("scrim tap did not apply Default")
	await create_timer(0.45).timeout

	# Povlačenje: 100 px ostaje, 200 px zatvara.
	_w.call("open", "", false)
	await _settle(2)
	_w.call("simulate_drag", 100.0)
	if not bool(_w.call("is_open")) or bool(_w.call("is_closing")):
		_fail("drag 100 px closed the sheet")
	_w.call("simulate_drag", 200.0)
	if not bool(_w.call("is_closing")) and bool(_w.call("is_open")):
		_fail("drag 200 px did not close the sheet")
	await create_timer(0.45).timeout

	# Slot koji se ne vidi na polju → toast iz slot.toast.
	_w.call("open", "", false)
	_w.call("select_slot", "meadow_bg")
	_w.call("pick", "meadow_bg", "meadow_lavender")
	_w.call("close", false)
	await _settle(2)
	var toast := _home.get_node("%FieldOverlayInner/ApplyToast") as Control
	if toast == null or not toast.visible or str(toast.get("text")) != "Runs use Lavender Meadow":
		_fail("toast missing or wrong: %s" % (str(toast.get("text")) if toast else "null"))
	var save_dict: Dictionary = (_gs.get("cosmetics") as Object).call("to_save_dict")
	if not save_dict.has("owned_cosmetics") or not save_dict.has("equipped_cosmetics"):
		_fail("save keys changed")
	if (save_dict["equipped_cosmetics"] as Dictionary).has("pip_skin"):
		_fail("Default must be stored as a missing key")


# 8 — back
func _check_back() -> void:
	_w.call("open", "", false)
	await _settle(2)
	var ev := InputEventAction.new()
	ev.action = "ui_cancel"
	ev.pressed = true
	Input.parse_input_event(ev)
	await _settle(3)
	if bool(_w.call("is_open")) and not bool(_w.call("is_closing")):
		_fail("back did not close the wardrobe")
	if not bool(_gs.get("home_season_field_open")):
		_fail("back closed the field instead of the wardrobe")
	await create_timer(0.45).timeout


# ShopLink → Shop · Looks (jedini put u Shop iz ormara); zatvaranje = snimanje.
func _check_shop_link(hub: Control) -> void:
	var cos: Object = _gs.get("cosmetics")
	cos.set("owned", {"pip_blossom": true})
	_w.call("open", "", false)
	_w.call("select_slot", "pip_skin")
	await _settle(2)
	var link: Control = null
	for n in _w.call("grid_cell_nodes"):
		if (n as Control).name == "ShopLink":
			link = n
	if link == null:
		_fail("ShopLink cell missing")
		return
	link.call("simulate_tap")
	await create_timer(1.0).timeout
	if bool(_w.call("is_open")):
		_fail("ShopLink did not close the wardrobe")
	if int(hub.call("current_page_index")) != 0:
		_fail("ShopLink did not open the Shop page (page %d)" % int(hub.call("current_page_index")))
	hub.call("go_to_page", 2, false)
	await _settle(4)


# 5 — proširenje
func _check_extra() -> void:
	var cos: Object = _gs.get("cosmetics")
	CosmeticCatalog.load_from_dict(DEMO.catalog())
	cos.set("owned", DEMO.owned())
	cos.set("equipped", {})
	cos.set("wardrobe_seen", 1)
	_w.call("open", "", false)
	_w.call("select_slot", "pip_skin")
	await _settle(3)
	var tabs: Array = _w.call("get_tabs")
	if tabs.size() != 8:
		_fail("extra: %d tabs, expected 8" % tabs.size())
	var cards: Array = _w.call("get_cards")
	if cards.size() != 12:
		_fail("extra: %d Pip cards, expected 11 + Default" % cards.size())
	var veiled := 0
	var fresh := 0
	for c in cards:
		if str(c.get("state")) == UiWardrobe.CARD_NONE:
			veiled += 1
		if bool(c.get("is_new")):
			fresh += 1
	if veiled != 1 or fresh != 1:
		_fail("extra: veiled %d / new %d, expected 1 / 1" % [veiled, fresh])
	var last := tabs[tabs.size() - 1] as Control
	var scroll := _w.call("tabs_scroll") as ScrollContainer
	if last.position.x + last.size.x <= scroll.size.x:
		_fail("extra: 8 tabs should scroll")
	_w.call("select_slot", "combo_ring")
	await _settle(3)
	var now: Array = _w.call("get_tabs")
	var act := now[now.size() - 1] as Control
	if not bool(act.get("active")):
		_fail("extra: last tab not active after select")
	if act.position.x + act.size.x > float(scroll.scroll_horizontal) + scroll.size.x + 0.5:
		_fail("extra: active tab not scrolled into view")
	_w.call("close", false)
	await _settle(2)
	for n in [1, 5, 30]:
		CosmeticCatalog.load_from_dict(DEMO.catalog_n(n))
		cos.set("owned", DEMO.owned_n(n))
		cos.set("equipped", {})
		_w.call("open", "", false)
		_w.call("select_slot", "pip_skin")
		await _settle(2)
		var got: int = (_w.call("get_cards") as Array).size() - 1
		if got != n:
			_fail("demoN %d: %d cards" % [n, got])
		_w.call("close", false)
		await _settle(2)
	CosmeticCatalog.reload()
	cos.set("owned", {})
	cos.set("equipped", {})
