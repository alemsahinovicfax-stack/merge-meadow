extends SceneTree

## Shop v2 (design_handoff_shop_v2): četiri taba = četiri ScrollContainera, Seasons prvi i
## podrazumijevani, tab pamti skrol, pergament umjesto zelene, jedno dugme po prodajnoj
## kartici, pravi portreti (6, >= 148), Looks iz cosmetics.json, nema izbačenog teksta.

const REMOVED := [
	"6 flowers for your Album", "same runs, same rewards", "yours to keep", "one-time",
	"wear one", "Journal page", "looks only", "earn in runs", "You have", "to your stock",
	"Bag is full", "for good, on this account", "once per account", "Buy & wear", "Use one",
]

var _backup := ""


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("shop_open_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		_fail("shop failed %d" % err)
		return
	await _frames(20)
	var shop := current_scene as Control
	if shop == null:
		_fail("current_scene missing")
		return

	var bg := shop.get_node_or_null("Bg") as ColorRect
	if bg == null or not bg.color.is_equal_approx(Color("#FBEDD7")):
		_fail("page background should be parchment #FBEDD7")
		return
	var bar: Control = shop.call("get_tab_bar")
	var tabs: Array = bar.call("get_tabs")
	var labels: Array[String] = []
	for t in tabs:
		labels.append(str(t.get("label")))
	if labels != ["Seasons", "Looks", "Boosters", "Support"]:
		_fail("tabs %s" % str(labels))
		return
	for t in tabs:
		if (t as Control).size.y < 120.0:
			_fail("tab touch height < 120")
			return
	if str(shop.call("active_tab")) != "seasons":
		_fail("shop should open on Seasons")
		return
	for tab in ["seasons", "looks", "boosters", "support"]:
		var page := shop.call("page_node", tab) as ScrollContainer
		if page == null:
			_fail("missing tab page %s" % tab)
			return
		if page.visible != (tab == "seasons"):
			_fail("only Seasons page should be visible at start (%s)" % tab)
			return

	# Seasons: 4 kartice, 6 pravih portreta >= 148, jedno dugme ili Coming soon.
	var cards := shop.find_children("SeasonCard_*", "", true, false)
	if cards.size() != 4:
		_fail("expected 4 season cards, got %d" % cards.size())
		return
	for card in cards:
		if int(card.call("portrait_count")) != 6:
			_fail("%s should have 6 portraits" % card.name)
			return
		if float(card.call("min_portrait_d")) < 148.0:
			_fail("%s portraits should be >= 148" % card.name)
			return
		var buttons := (card as Node).find_children("BuyButton", "", true, false)
		if buttons.size() != 1:
			_fail("%s should have exactly one buy button" % card.name)
			return

	# Looks iz kataloga: slotovi i 5 stavki.
	shop.call("select_tab", "looks", false)
	await _frames(4)
	for slot_id in ["pip_skin", "meadow_bg", "journal_frame"]:
		if shop.find_child("LooksSlot_%s" % slot_id, true, false) == null:
			_fail("missing Looks slot %s" % slot_id)
			return
	if shop.find_children("CosmeticCard_*", "", true, false).size() != 5:
		_fail("expected 5 cosmetic cards")
		return
	if shop.find_child("WardrobeLink", true, false) == null:
		_fail("Looks should end with the Wardrobe link")
		return

	# Tab pamti skrol dok si u Shopu; ulaz iz huba vraća Seasons od vrha.
	var looks := shop.call("page_node", "looks") as ScrollContainer
	looks.scroll_vertical = 400
	shop.call("select_tab", "support", false)
	await _frames(3)
	shop.call("select_tab", "looks", false)
	await _frames(3)
	if looks.scroll_vertical < 300:
		_fail("Looks should keep its scroll while in the Shop")
		return
	shop.call("refresh_for_meta_hub")
	await _frames(3)
	if str(shop.call("active_tab")) != "seasons" or looks.scroll_vertical != 0:
		_fail("entering the Shop should reset to Seasons from the top")
		return
	# Ormar · More in Shop → Looks na slotu.
	shop.call("show_cosmetic_slot", "journal_frame")
	await _frames(3)
	if str(shop.call("active_tab")) != "looks":
		_fail("More in Shop should open Looks")
		return

	# Nijedan izbačeni tekst.
	var text := _all_text(shop)
	for phrase in REMOVED:
		if text.findn(phrase) >= 0:
			_fail("removed copy still present: %s" % phrase)
			return
	CampSmokeUtil.restore_save(self, _backup)
	print("shop_open_smoke OK")
	quit(0)


## Tekst koji kartice crtaju ili nose (imena, dugmad, status, podnaslovi) + Labeli.
func _all_text(root: Node) -> String:
	var out := ""
	for n in root.find_children("*", "", true, false):
		if n is Label:
			out += (n as Label).text + "\n"
		for prop in ["price", "owned_label", "text", "title", "label", "status_text"]:
			if prop in n:
				out += str(n.get(prop)) + "\n"
	for c in root.find_children("SeasonCard_*", "", true, false):
		out += str(c.call("get_name_text")) + "\n"
	return out
