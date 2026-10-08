extends SceneTree

## Camp v3 — zbroj za vrata arene.


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("arena_gate_sum_smoke: %s" % msg)
	quit(1)


func _run() -> void:
	var cases := [
		[[13, 3, 40], 53, true],
		[[49], 49, false],
		[[12, 12, 12, 12], 48, false],
		[[50], 50, true],
	]
	for row in cases:
		var counts: Array = row[0]
		var n := UiCamp.gate_count(counts)
		var open := UiCamp.gate_open(counts)
		if n != int(row[1]) or open != bool(row[2]):
			_fail("gate %s expected %s/%s got %d/%s" % [str(counts), str(row[1]), str(row[2]), n, str(open)])
			return
	var gs := get_root().get_node_or_null("GameState")
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("seed_bag", {"clover": 13, "daisy": 3, "buttercup": 40})
	if int(gs.call("mergeable_seed_count")) != 53 or not bool(gs.call("arena_gate_open")):
		_fail("13+3+40 should be 53 and open")
		return
	print("arena_gate_sum_smoke OK")
	quit(0)
