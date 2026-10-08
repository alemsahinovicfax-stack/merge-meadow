extends SceneTree

## Camp v3 — Twin Seeds p = 8 % × nivo. 0 i 4.


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("twin_seeds_smoke: %s" % msg)
	quit(1)


func _run() -> void:
	if not is_equal_approx(UiCamp.twin_chance(0), 0.0):
		_fail("L0 must be 0")
		return
	if not is_equal_approx(UiCamp.twin_chance(4), 0.32):
		_fail("L4 must be 0.32, got %s" % str(UiCamp.twin_chance(4)))
		return
	if not is_equal_approx(UiCamp.twin_chance(2), 0.16):
		_fail("L2 must be 0.16")
		return
	var gs := get_root().get_node_or_null("GameState")
	if gs == null:
		_fail("GameState missing")
		return
	if int(gs.call("get_twin_seeds_level")) < 0:
		_fail("twin level missing")
		return
	print("twin_seeds_smoke OK")
	quit(0)
