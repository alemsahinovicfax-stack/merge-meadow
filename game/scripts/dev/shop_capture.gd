extends SceneTree

## Dev: renderuje hub u SubViewport 1080 x 1920 i snima Shop v2 — svaki tab od vrha, pa
## korak po korak (1200 px) do dna. Referenca za poređenje s design_handoff_shop_v2.
## Pokretanje BEZ --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/shop_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const TABS: Array[String] = ["seasons", "looks", "boosters", "support"]

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node
var _n := 0


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	_n += 1
	_svp.get_texture().get_image().save_png(_out.path_join("shop_%02d_%s.png" % [_n, shot]))
	print("captured ", shot)


## Tipično stanje igrača: dio kozmetike kupljen, jedan booster, coini za neke stavke.
func _base_state() -> void:
	_gs.set("tutorial_complete", true)
	_gs.set("wallet_coins", 220)
	var cos: Cosmetics = _gs.get("cosmetics")
	cos.owned = {"meadow_sunset": true}
	cos.equipped = {"meadow_bg": "meadow_sunset"}
	var boosters: Boosters = _gs.get("boosters")
	boosters.inventory = {"loot_burst": 1}


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_base_state()
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(30)
	hub.call("go_to_page", MetaHubPages.SHOP, false)
	await _frames(20)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var shop := host.get_node("Page_%d" % MetaHubPages.SHOP)
	shop.call("refresh_shop")
	await _frames(10)
	for tab in TABS:
		shop.call("select_tab", tab, false)
		var scroll := shop.call("page_node", tab) as ScrollContainer
		scroll.scroll_vertical = 0
		await _frames(6)
		await _capture("%s_top" % tab)
		var max_v := int(scroll.get_v_scroll_bar().max_value - scroll.size.y)
		var y := 0
		var k := 1
		while y < max_v:
			y = mini(y + 1200, max_v)
			scroll.scroll_vertical = y
			await _frames(4)
			await _capture("%s_%02d" % [tab, k])
			k += 1
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
