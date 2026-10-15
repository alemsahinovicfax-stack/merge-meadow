extends SceneTree

## Nibbs (design_handoff_muncher_premium_pip · A) u pravoj Areni — pravila ista, klipovi po stanju:
##   rig + krtičnjak, 16 klipova, z ispod oblačića tutoriala; spava u rupi (usna preko njega);
##   buđenje „!" + baner „Muncher's awake!" + m_awake samo prvi put u sesiji; pogled lova po
##   smjeru (bočno / ← zrcaljeno / naprijed / nazad); sjemenka pobjegla = m_escaped preko lova;
##   T3 = led 2 s, zadnjih 0,25 s pucanje; prazno polje = m_doze → m_sleep_spot.

const CLIPS := [
	"m_sleep_nest", "m_sleep_spot", "m_wake_nest", "m_wake_spot", "m_awake", "m_hunt_front",
	"m_hunt_side", "m_hunt_back", "m_eat_front", "m_eat_side", "m_freeze", "m_frozen", "m_thaw",
	"m_doze", "m_escaped_front", "m_escaped_side",
]

var _backup := ""
var _failed := false
var _arena: Node
var _pest: Node


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	if _failed:
		return
	_failed = true
	push_error("muncher_rig_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	await create_timer(sec).timeout


func _clip() -> String:
	return str(_pest.call("get_clip"))


func _finish() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		quit(1)
		return
	print("muncher_rig_smoke OK")
	quit(0)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	gs.call("mark_arena_pest_tutorial_shown")
	gs.set("seed_bag", {})
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK:
		_fail("arena load failed %d" % err)
		_finish()
		return
	await _frames(12)
	_arena = current_scene
	_pest = _arena.get_node("RootVBox/Playfield/MuncherPest")
	for _i in 120:
		if _pest.call("get_rig") != null:
			break
		await process_frame
	var rig: Node = _pest.call("get_rig")
	if rig == null:
		_fail("muncher rig never built (atlas)")
		_finish()
		return
	_check_data(rig)
	_pest.call("reset_to_nest")
	await _frames(2)
	if _clip() != "m_sleep_nest" or not bool(_pest.call("is_nest_front_over")) or str(_pest.call("get_view")) != "front":
		_fail("asleep: expected m_sleep_nest under the nest lip, got %s" % _clip())

	# Buđenje (prvo u sesiji): „!" + baner, pa m_awake prije lova.
	var chips := await _spawn(4)
	_pest.call("on_seeds_poured", true)
	await _frames(2)
	if _clip() != "m_wake_nest" or not bool(_pest.call("is_banner_showing")):
		_fail("first wake: expected m_wake_nest + banner, got %s / %s" % [_clip(), _pest.call("is_banner_showing")])
	await _wait(0.45)
	if _clip() != "m_awake" or str(_pest.call("get_pose_key")) != "wake":
		_fail("first wake: expected the m_awake moment, got %s" % _clip())
	await _wait(1.5)
	if not (_clip().begins_with("m_hunt_") or _clip().begins_with("m_eat_")):
		_fail("after m_awake he should hunt, got %s" % _clip())
	if bool(_pest.call("is_nest_front_over")):
		_fail("nest lip must go under him once he leaves the hole")

	await _check_views(rig, chips)
	await _check_escaped(rig)
	await _check_freeze()
	await _check_sleep_and_rewake()
	_finish()


func _check_data(rig: Node) -> void:
	for id in CLIPS:
		if not bool(MuncherRig.has_anim(id)):
			_fail("clip %s missing" % id)
	var tex: Texture2D = MuncherRig.atlas()["texture"]
	if tex.get_width() > 1024 or tex.get_height() > 1024:
		_fail("muncher atlas over 1024: %dx%d" % [tex.get_width(), tex.get_height()])
	var lo := 99
	var hi := -99
	for v in ["front", "side", "back"]:
		for n in (rig.get_node(v) as Node).find_children("*", "Node2D", true, false):
			if n is Sprite2D:
				continue
			lo = mini(lo, (n as Node2D).z_index)
			hi = maxi(hi, (n as Node2D).z_index)
	var pz := int(_pest.get("z_index"))
	if lo < -4 or hi > 9 or pz + hi >= 56:
		_fail("muncher z must stay under the arena cue (56): pest %d parts %d..%d" % [pz, lo, hi])


func _spawn(n: int) -> Array:
	var list := []
	for i in n:
		list.append({"chip_id": 9700 + i, "type_id": "clover", "tier": 1})
	_arena.call("_spawn_poured_chips", list)
	await _wait(0.9)
	return _arena.get("_chips")


func _place(chip: Node, center: Vector2) -> void:
	var c := chip as Control
	c.position = center - c.size * 0.5


## Pogled po smjeru prema cilju (|dx| ≥ 0,8·|dy| → bočno, ← zrcaljeno; inače naprijed / nazad).
func _check_views(rig: Node, chips: Array) -> void:
	var live: Array = []
	for c in chips:
		if is_instance_valid(c):
			live.append(c)
	if live.size() < 2:
		_fail("views: not enough chips left")
		return
	var center := Vector2(540, 800)
	for c in live:
		_place(c, center + Vector2(0, 600))
	var target: Node = live[0]
	_pest.set("_state", 2)  # ArenaPest.State.HUNTING
	_pest.set("_pest_center", center)
	_pest.set("_target_chip", target)
	_place(target, center + Vector2(-380, 0))
	await _wait(0.5)
	if _clip() != "m_hunt_side" or not bool(rig.get("flip")):
		_fail("target on the left: expected m_hunt_side mirrored, got %s flip %s" % [_clip(), rig.get("flip")])
	_place(target, Vector2(float(_pest.get("_pest_center").x), float(_pest.get("_pest_center").y) + 420.0))
	await _wait(0.5)
	if _clip() != "m_hunt_front":
		_fail("target below: expected m_hunt_front, got %s" % _clip())
	_place(target, Vector2(float(_pest.get("_pest_center").x), float(_pest.get("_pest_center").y) - 420.0))
	await _wait(0.5)
	if _clip() != "m_hunt_back":
		_fail("target above: expected m_hunt_back, got %s" % _clip())


## Cilj nestane usred lova (spojen / u korpu): „hmph" preko lova, lov ide dalje.
func _check_escaped(rig: Node) -> void:
	var target: Node = _pest.get("_target_chip")
	if target == null or not is_instance_valid(target):
		_fail("escaped: no target to merge away")
		return
	_arena.call("_remove_chip", target)
	await _frames(3)
	var over: AnimationPlayer = rig.get("overlay")
	if over == null or not over.is_playing() or not str(over.current_animation).begins_with("m_escaped_"):
		_fail("target merged away: expected m_escaped overlay")
	if str(_pest.call("get_pose_key")) != "hunt":
		_fail("he should keep hunting after the hmph")


## Led 2 s: m_freeze → m_frozen, zadnjih 0,25 s m_thaw, pa lov.
func _check_freeze() -> void:
	_pest.call("on_t3_created")
	await _frames(1)
	if _clip() != "m_freeze":
		_fail("T3: expected m_freeze, got %s" % _clip())
	await _wait(0.4)
	if _clip() != "m_frozen":
		_fail("T3: expected m_frozen, got %s" % _clip())
	await _wait(1.45)
	if _clip() != "m_thaw" or str(_pest.call("get_pose_key")) != "frozen":
		_fail("T3: last 0.25 s should be m_thaw while still frozen, got %s" % _clip())
	await _wait(0.35)
	if str(_pest.call("get_pose_key")) == "frozen":
		_fail("T3: freeze must end at 2 s")


## Prazno polje: m_doze → m_sleep_spot; drugo buđenje u sesiji je bez banera i bez m_awake.
func _check_sleep_and_rewake() -> void:
	for c in (_arena.get("_chips") as Array).duplicate():
		_arena.call("_remove_chip", c)
	_pest.call("on_field_chip_count_changed", 0)
	await _frames(2)
	if _clip() != "m_doze":
		_fail("empty field: expected m_doze, got %s" % _clip())
	await _wait(1.1)
	if _clip() != "m_sleep_spot":
		_fail("empty field: expected m_sleep_spot, got %s" % _clip())
	await _spawn(2)
	_pest.call("on_seeds_poured", true)
	await _frames(2)
	if _clip() != "m_wake_spot" or bool(_pest.call("is_banner_showing")):
		_fail("second wake: expected m_wake_spot without banner, got %s" % _clip())
	await _wait(0.45)
	if _clip() == "m_awake":
		_fail("second wake must not replay m_awake")
	# Nova sesija (reset u gnijezdo) → baner opet; tutorial ga može sakriti.
	_pest.call("reset_to_nest")
	_pest.call("on_seeds_poured", true)
	await _frames(2)
	if not bool(_pest.call("is_banner_showing")):
		_fail("new session: banner should show again")
	_pest.call("hide_awake_banner")
	if bool(_pest.call("is_banner_showing")):
		_fail("hide_awake_banner should hide it")
