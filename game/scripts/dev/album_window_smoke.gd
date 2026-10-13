extends SceneTree

## design_handoff_settings_fixes · A — prozor Albuma u pravom hubu (headless):
##  1. zlatni i obični okvir: četiri poklopca + rupa = cijela stranica (bez rupa i preklopa);
##  2. poklopci neprozirni, iznad liste (z), obrub iznad poklopaca, zaglavlje iznad svega;
##  3. ListScroll = rupa iz UiJ.list_window; nijedan red nije širi od prozora (−2 × 12);
##  4. skrol do kraja: grabber ostaje u prozoru.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const UI_JOURNAL := "res://scripts/visual/ui_journal.gd"

var UiJ: Script

var _backup := ""
var _fails := 0


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	_fails += 1
	push_error("album_window_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _run() -> void:
	UiJ = load(UI_JOURNAL)
	_backup = CampSmokeUtil.backup_save()
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	var cos: Object = gs.get("cosmetics")
	cos.set("owned", {"journal_gold": true})
	cos.set("equipped", {"journal_frame": "journal_gold"})
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	get_root().add_child(hub)
	await _frames(30)
	hub.call("go_to_page", MetaHubPages.COLLECTION, false)
	await create_timer(1.5).timeout
	var journal := hub.get_node("RootVBox/SwipePager").call("get_pages_host").get_node("Page_%d" % MetaHubPages.COLLECTION) as Control
	for golden in [true, false]:
		if not golden:
			gs.call("unequip_cosmetic", "journal_frame")
			await _frames(10)
		_check(journal, golden)
		var scroll := journal.get_node("%ListScroll") as ScrollContainer
		scroll.scroll_vertical = 100000
		await _frames(8)
		var grab := journal.get_node("%Grabber") as Control
		var hole := Rect2(scroll.position, scroll.size)
		if grab.visible and not hole.encloses(Rect2(grab.position, grab.size)):
			_fail("%s: grabber %s outside window %s" % [_kind(golden), Rect2(grab.position, grab.size), hole])
	CampSmokeUtil.restore_save(self, _backup)
	if _fails == 0:
		print("album_window_smoke OK")
	quit(_fails)


func _kind(golden: bool) -> String:
	return "golden" if golden else "plain"


func _check(journal: Control, golden: bool) -> void:
	var win: Dictionary = UiJ.list_window(golden, journal.size.y)
	var scroll := journal.get_node("%ListScroll") as ScrollContainer
	var hole := Rect2(scroll.position, scroll.size)
	if not hole.is_equal_approx(win["scroll"]):
		_fail("%s: ListScroll %s, expected %s" % [_kind(golden), hole, win["scroll"]])
	var area := hole.get_area()
	var rects: Array[Rect2] = [hole]
	for cap_name in ["CapTop", "CapBottom", "CapLeft", "CapRight"]:
		var cap := journal.get_node("%" + cap_name) as ColorRect
		var r := Rect2(cap.position, cap.size)
		area += r.get_area()
		rects.append(r)
		if cap.color.a < 0.999:
			_fail("%s: %s is not opaque" % [_kind(golden), cap_name])
		if cap.z_index <= scroll.z_index:
			_fail("%s: %s must sit above the list" % [_kind(golden), cap_name])
	var page := Vector2(1080, journal.size.y)
	if not is_equal_approx(area, page.x * page.y):
		_fail("%s: caps + window = %.0f px², page %.0f px²" % [_kind(golden), area, page.x * page.y])
	for i in rects.size():
		for j in range(i + 1, rects.size()):
			var o := rects[i].intersection(rects[j])
			if o.get_area() > 0.5:
				_fail("%s: rects %d and %d overlap by %.0f px²" % [_kind(golden), i, j, o.get_area()])
	var rim := journal.get_node("%WindowRim") as Control
	if rim.z_index <= (journal.get_node("%CapTop") as Control).z_index:
		_fail("%s: rim must sit above the caps" % _kind(golden))
	if (journal.get_node("%RootVBox") as Control).z_index <= rim.z_index:
		_fail("%s: page head must sit above the rim" % _kind(golden))
	var max_w: float = hole.size.x - 2.0 * float(UiJ.WIN_LIST_PAD_X) + 0.5
	var rows := 0
	for row in journal.find_children("*", "", true, false):
		if row is Control and (row as Control).has_method("set_slot_size"):
			rows += 1
			if (row as Control).size.x > max_w:
				_fail("%s: row %.0f px wider than the window (%.0f)" % [_kind(golden), (row as Control).size.x, max_w])
				break
	if rows == 0:
		_fail("%s: no rows built" % _kind(golden))
