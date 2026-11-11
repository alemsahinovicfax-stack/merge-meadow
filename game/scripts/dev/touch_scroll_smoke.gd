extends SceneTree

## Dodir prstom (FIX-TEL 2026-11): stvari koje rade mišem, a na telefonu ne.
## Šalje PRAVE InputEventScreenTouch / ScreenDrag kroz viewport (ne zove signale):
##  1. Shop · Looks: tap na dugme (pritisak + puštanje bez pomaka) stiže do dugmeta;
##  2. povlačenje koje POČNE na dugmetu za kupovinu skrola listu i ne kupuje;
##  3. isto s prozora skina (kartica);
##  4. tap poslije skrolanja i dalje radi;
##  5. Arena: sjeme (chip) prati prst pri ScreenDrag — ne skače u gornji lijevi ugao.
##   godot --headless --path game -s res://scripts/dev/touch_scroll_smoke.gd

var _backup := ""
var _clicks := 0


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _touch(pos: Vector2, pressed: bool) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.position = pos
	ev.pressed = pressed
	root.push_input(ev, true)


func _drag(from: Vector2, to: Vector2, steps: int = 8) -> void:
	var prev := from
	for i in range(1, steps + 1):
		var p := from.lerp(to, float(i) / float(steps))
		var ev := InputEventScreenDrag.new()
		ev.index = 0
		ev.position = p
		ev.relative = p - prev
		ev.velocity = (p - prev) * 60.0
		root.push_input(ev, true)
		prev = p
		await process_frame


func _swipe(from: Vector2, dy: float) -> void:
	_touch(from, true)
	await process_frame
	await _drag(from, from + Vector2(0.0, dy))
	_touch(from + Vector2(0.0, dy), false)
	# Inercija: lista se još kreće poslije puštanja — sačekaj da stane prije sljedećeg koraka
	# (vrijeme, ne frejmovi: headless frejm traje djelić milisekunde).
	await create_timer(1.5).timeout


func _run() -> void:
	var gs: Node = root.get_node("GameState")
	gs.set("tutorial_complete", true)
	gs.set("wallet_coins", 0)
	change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	await _frames(30)
	var shop: Node = current_scene
	shop.call("select_tab", "looks", false)
	await _frames(20)
	var page: ScrollContainer = shop.call("page_node", "looks")
	if page == null or not page.visible:
		return _fail("Looks page is not visible")
	var max_scroll := int(page.get_v_scroll_bar().max_value - page.get_v_scroll_bar().page)
	if max_scroll < 300:
		return _fail("Looks page is too short to scroll (%d)" % max_scroll)

	var buttons: Array = []
	_find(page, "ShopBuyButton", buttons)
	var view := page.get_global_rect()
	var btn: Control = null
	for b in buttons:
		var r: Rect2 = (b as Control).get_global_rect()
		if (b as Control).is_visible_in_tree() and view.encloses(r) and r.position.y > view.position.y + 500.0:
			btn = b
			break
	if btn == null:
		return _fail("no buy button in view on Looks (found %d)" % buttons.size())
	btn.connect("clicked", func() -> void: _clicks += 1)
	if btn.has_signal("short_tapped"):
		btn.connect("short_tapped", func() -> void: _clicks += 1)

	# 1. tap bez pomaka stiže do dugmeta (prije i poslije skrola)
	page.scroll_vertical = 0
	await _frames(2)
	_clicks = 0
	var tap := btn.get_global_rect().get_center()
	_touch(tap, true)
	await _frames(2)
	_touch(tap, false)
	await _frames(3)
	if _clicks != 1:
		return _fail("tap on a buy button gave %d clicks, expected 1" % _clicks)

	# 0. kontrola: povlačenje s praznog ruba stranice mora skrolati (inače test ne valja)
	page.scroll_vertical = 0
	await _frames(2)
	await _swipe(Vector2(view.position.x + 6.0, view.position.y + 900.0), -400.0)
	if page.scroll_vertical < 200:
		return _fail("control: drag on the empty page edge did not scroll (scroll %d)" % page.scroll_vertical)

	_clicks = 0
	# 2. povlačenje s dugmeta
	page.scroll_vertical = 0
	await _frames(2)
	var start := btn.get_global_rect().get_center()
	await _swipe(start, -400.0)
	if page.scroll_vertical < 200:
		return _fail("drag that starts on a buy button did not scroll (scroll %d)" % page.scroll_vertical)
	if _clicks != 0:
		return _fail("drag on a buy button also tapped it")

	# 3. povlačenje s kartice (prozor skina, lijevo od dugmeta)
	page.scroll_vertical = 0
	await _frames(2)
	var card_point := Vector2(view.position.x + 160.0, btn.get_global_rect().get_center().y - 60.0)
	await _swipe(card_point, -400.0)
	if page.scroll_vertical < 200:
		return _fail("drag that starts on a skin card did not scroll (scroll %d)" % page.scroll_vertical)

	# 5. tap poslije skrol gesti mora raditi
	page.scroll_vertical = 0
	await _frames(2)
	_clicks = 0
	tap = btn.get_global_rect().get_center()
	_touch(tap, true)
	await _frames(2)
	_touch(tap, false)
	await _frames(3)
	if _clicks != 1:
		return _fail("tap after scrolling gave %d clicks, expected 1" % _clicks)

	# 6. Arena: chip prati prst (ScreenDrag), ne skače u gornji lijevi ugao.
	var host := Control.new()
	host.size = Vector2(1080, 1920)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.z_index = 100
	root.add_child(host)
	shop.visible = false
	var chip = load("res://scripts/camp/arena_seed_chip.gd").new()
	host.add_child(chip)
	chip.call("setup", 1, "clover", Vector2(540, 1200), 1)
	await _frames(4)
	var c0: Vector2 = chip.call("get_center")
	_touch(c0, true)
	await _frames(2)
	await _drag(c0, c0 + Vector2(200, 150))
	var c1: Vector2 = chip.call("get_center")
	_touch(c0 + Vector2(200, 150), false)
	await _frames(2)
	if c1.distance_to(c0 + Vector2(200, 150)) > 40.0:
		return _fail("arena chip did not follow the finger: %s → %s (expected near %s)" % [c0, c1, c0 + Vector2(200, 150)])

	print("touch_scroll_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _find(node: Node, cls: String, out: Array) -> void:
	for c in node.get_children():
		var s: Script = c.get_script()
		if s != null and s.get_global_name() == cls:
			out.append(c)
		_find(c, cls, out)


func _fail(msg: String) -> void:
	push_error("touch_scroll_smoke FAIL: " + msg)
	print("touch_scroll_smoke FAIL: " + msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)
