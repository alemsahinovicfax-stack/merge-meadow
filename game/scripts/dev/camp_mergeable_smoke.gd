extends SceneTree

## Camp v3 — oznaka i linija: 3 sakriveno, 4 granica, 12 cijeli stog.


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("camp_mergeable_smoke: %s" % msg)
	quit(1)


func _run() -> void:
	if UiCamp.is_mergeable(3) or not UiCamp.is_mergeable(4) or not UiCamp.is_mergeable(12):
		_fail("mergeable mark is wrong for 3/4/12")
		return
	if not UiCamp.merge_line_text(3).is_empty():
		_fail("line must hide below 4")
		return
	if UiCamp.merge_line_text(4) != "Arena takes all 4 · sell 1 and none go":
		_fail("line at 4 is wrong: %s" % UiCamp.merge_line_text(4))
		return
	if UiCamp.merge_line_text(12) != "Arena takes all 12":
		_fail("line at 12 is wrong")
		return
	print("camp_mergeable_smoke OK")
	quit(0)
