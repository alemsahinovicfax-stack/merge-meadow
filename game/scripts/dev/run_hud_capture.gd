extends SceneTree

## Dev: snima HUD runa (design_handoff_run_hud_v2) za poređenje s paketom: level mod s grmom,
## Endless, tutorial („Practice"), Starfall Glade sa sjemenkom u grmu, traka na 90 % (peach),
## burst grma i Frost Orchard s grmom. Save se vraća na kraju (CampSmokeUtil).
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/run_hud_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/).

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	_svp.get_texture().get_image().save_png(_out.path_join("runhud_%s.png" % shot))
	print("captured ", shot)


## Pokrene run, pusti ga 2 s, pa zamrzne (paused) i postavi napredak; `after` dodaje grm/pop.
func _shot(name: String, season: String, setup: Callable, progress: float, after: Callable) -> void:
	for c in _svp.get_children():
		c.queue_free()
	await _frames(3)
	_gs.set("active_season_id", season)
	setup.call()
	var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(40)
	await create_timer(2.0).timeout
	run.set("_state", 2)
	run.set("elapsed", float(_gs.call("get_run_duration")) * progress)
	run.set("coin_count", 23)
	run.set("seeds_by_type", {"clover": 4, "daisy": 2})
	run.call("_update_hud")
	await after.call(run)
	await _capture(name)


func _no_extra(_run: Node) -> void:
	await _frames(4)


func _idle_bush(run: Node, seam: int, kind: String) -> void:
	var bush: Node2D = run.call("_spawn_bush", seam, 980.0)
	bush.set("reward_kind", kind)
	bush.set("reward_amount", 3)
	# Reward se crta u _ready; za sjemenku zamijeni dio pa neka se ponovo izgradi.
	if kind == "seed":
		bush.get_node("Visual").queue_free()
		await _frames(1)
		bush.call("_build_visual")
	await create_timer(0.3).timeout


func _burst(run: Node) -> void:
	var player := run.get_node("Player") as Node2D
	player.call("reset_lane")
	var bush: Node2D = run.call("_spawn_bush", 1, player.position.y)
	bush.set("reward_kind", "coin")
	bush.set("reward_amount", 4)
	await _frames(4)
	player.set("lane_index", 2)
	player.call("_apply_lane", true)
	await create_timer(0.24).timeout


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	var level := func() -> void:
		_gs.set("tutorial_complete", true)
		_gs.set("run_level", 12)
		_gs.call("begin_campaign_run")
	await _shot("01_level_country_bloom", "country_bloom", level, 0.42,
		func(r: Node) -> void: await _idle_bush(r, 1, "coin"))
	await _shot("02_endless_country_bloom", "country_bloom", func() -> void:
		_gs.set("tutorial_complete", true)
		_gs.call("begin_endless_run", 2), 0.5, _no_extra)
	await _shot("03_level_starfall_glade", "starfall_glade", level, 0.68,
		func(r: Node) -> void: await _idle_bush(r, 1, "seed"))
	await _shot("04_level_low_time", "country_bloom", level, 0.9, _no_extra)
	await _shot("05_bush_burst", "country_bloom", level, 0.5, _burst)
	await _shot("06_level_frost_orchard", "frost_orchard", level, 0.3,
		func(r: Node) -> void: await _idle_bush(r, 0, "coin"))
	await _shot("07_tutorial_practice", "country_bloom", func() -> void:
		_gs.set("tutorial_complete", false)
		_gs.set("tutorial_step", 2)
		_gs.call("begin_campaign_run"), 0.4, _no_extra)
	_gs.set("tutorial_complete", true)
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
