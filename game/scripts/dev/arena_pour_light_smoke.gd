extends SceneTree

## FIX-TEL-3 (2026-11-12) — „kad tapnem vreću dok sjemenke lete, baš šteka". Čuva tri izmjene:
##  · sjemenka pri sipanju nastaje kao JEDAN čvor; crtež (Art) stiže kad dođe njen red u letu,
##    pa do kraja leta sve sjemenke imaju crtež;
##  · tijelo korpe se NE crta ponovo kad sipanje promijeni samo broj (gomila je ista);
##  · tap na vreću dok je polje puno ne dira ni korpu ni sjemenke;
##  · vacuum ostatka ne snima save odmah (odgođeno, u pozadini na telefonu).

var _backup := ""
var _failed := false
var _body_draws := 0


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("arena_pour_light_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _chips(arena: Node) -> Array:
	return arena.get("_chips")


func _with_art(arena: Node) -> int:
	var n := 0
	for c in _chips(arena):
		if bool(c.call("has_art")):
			n += 1
	return n


func _run() -> void:
	var gs: Node = root.get_node("GameState")
	gs.set("tutorial_complete", true)
	gs.set("reduce_motion", false)
	gs.set("seed_bag", {"clover": 60, "daisy": 60, "buttercup": 60, "tulip": 40})
	if change_scene_to_file("res://scenes/camp/merge_arena.tscn") != OK:
		_fail("arena did not load")
		_finish()
		return
	await _frames(20)
	var arena := current_scene
	var bag: Control = arena.get("_seed_bag")
	var body: Control = bag.get("_body")
	body.draw.connect(func() -> void: _body_draws += 1)
	await _frames(4)
	_body_draws = 0
	# Korpa se klati (ima sjemena), a tijelo se pri tome NE crta: klaćenje ide preko Node2D
	# stožera (Control.rotation bi crtao cijelu korpu u svakom frejmu — katalog #74).
	await _frames(40)
	if _body_draws != 0:
		_fail("a wiggling basket must not redraw its body (%d draws in 40 frames)" % _body_draws)
	if bag.get_node_or_null("BodyPivot") == null or not (bag.get_node("BodyPivot") is Node2D):
		_fail("the basket body should hang on a Node2D pivot")
	# Muncher miruje u ovom testu: pojedene sjemenke bi oslobodile mjesto usred mjerenja.
	# (Kontroler ga pomjera sam, kroz _pest.tick — zato mu se u testu oduzima referenca.)
	arena.set("_pest", null)

	# 1 · sipanje 30: jedan čvor po sjemenci na početku, crtež stiže u letu.
	arena.call("_on_bag_clicked")
	var n := _chips(arena).size()
	if n != 30:
		_fail("first tap should pour 30 chips, got %d" % n)
	if _with_art(arena) != 0:
		_fail("chips should start without their Art node (built in flight), %d already have it" % _with_art(arena))
	for c in _chips(arena):
		if (c as Node).get_child_count() != 0:
			_fail("a freshly poured chip should be a single node, has %d children" % (c as Node).get_child_count())
			break
	await create_timer(0.5).timeout
	var mid := _with_art(arena)
	if mid <= 0 or mid >= 30:
		_fail("art should arrive one by one during the flight (0.5 s in: %d of 30)" % mid)
	# 2 · tap usred leta, polje puno: ništa se ne mijenja.
	var draws_before := _body_draws
	for _t in 5:
		arena.call("_on_bag_clicked")
		await _frames(2)
	if _chips(arena).size() != 30:
		_fail("taps on a full field must not pour")
	await create_timer(1.6).timeout
	if _with_art(arena) != 30:
		_fail("every chip should have its Art after the flight, %d of 30" % _with_art(arena))
	for c in _chips(arena):
		var art := (c as Node).get_node_or_null("Art") as Control
		if art == null or not art.visible or art.position.length() > 0.5:
			_fail("a landed chip must show its art at rest")
			break
	# 3 · korpa: sipanje je promijenilo samo broj (220 → 190, gomila ostaje 12) — tijelo se ne crta.
	if _body_draws != draws_before or _body_draws > 0:
		_fail("basket body was redrawn %d times by a pour that changed only the count" % _body_draws)
	var expect_left := 220 - int(arena.call("get_session_poured"))
	if int(bag.call("get_seed_count")) != mini(expect_left, int(arena.call("round_cap_left"))):
		_fail("bag counter should follow the pour, got %d (bag %d)" % [int(bag.call("get_seed_count")), expect_left])

	# 4 · dosipanje usred leta (igrač je spojio par): novi stižu, korpa se i dalje ne crta.
	var chips := _chips(arena)
	for _k in 4:
		arena.call("_remove_chip", chips[0])
	arena.call("_on_bag_clicked")
	if _chips(arena).size() != 30:
		_fail("a tap with room on the field should top it up to 30, got %d" % _chips(arena).size())
	await create_timer(1.0).timeout
	if _with_art(arena) != 30:
		_fail("topped-up chips should get their art too")
	if _body_draws > 0:
		_fail("basket body redrawn by a top-up (%d)" % _body_draws)

	# 5 · prsten nastaje tek kad zatreba.
	var chip: Node = _chips(arena)[0]
	if chip.get_node_or_null("Ring") != null:
		_fail("the ring layer should not exist until it is needed")
	chip.set("pulse_highlight", true)
	if chip.get_node_or_null("Ring") == null:
		_fail("a pulsing chip needs its ring layer")
	chip.set("pulse_highlight", false)

	# 6 · gomila koja se stvarno promijeni i dalje se crta (prazna korpa).
	arena.call("_clear_field_chips")
	arena.set("_session_open", false)
	gs.set("seed_bag", {})
	_body_draws = 0
	arena.call("_refresh_bag")
	await _frames(3)
	if _body_draws <= 0:
		_fail("an emptied basket must redraw its pile")
	_finish()


func _finish() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("arena_pour_light_smoke OK")
	quit(1 if _failed else 0)
