extends SceneTree

## Dev: snima današnjeg Pipa izbliza za pip-cd-brief (pip-ref/): tri skina (Classic, Blossom,
## Sky) × tri poze (idle, sniff, sleep) na 2× i red veličina u kojima se Pip danas vidi
## (kartica 230, polje 190, Arena 150, run 112, HUD 88, test siluete 64).
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/pip_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/).

const SKINS: Array[String] = ["", "pip_blossom", "pip_sky"]
const SKIN_NAMES: Array[String] = ["Classic Pip (default)", "Pip Blossom 250", "Pip Sky 200"]
const POSES: Array[String] = ["walk", "sniff", "sleep"]
const SIZES: Array[float] = [230.0, 190.0, 150.0, 112.0, 88.0, 64.0]
const SIZE_NAMES: Array[String] = ["kartica 230", "polje 190", "Arena 150", "run 112", "HUD 88", "64"]
const BG := Color("#FFF8F0")
const INK := Color("#2D3436")

var _out := ""


class _Sheet:
	extends Control

	var mode: String = "poses"

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#FFF8F0"), true)
		var font := ThemeDB.fallback_font
		if mode == "poses":
			for s in 3:
				var y := 40.0 + s * 420.0
				draw_string(font, Vector2(40, y + 30), SKIN_NAMES[s], HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#2D3436"))
				for p in 3:
					var tex := PipAssets.get_pose_texture(POSES[p], SKINS[s]) if POSES[p] != "walk" \
						else PipAssets.get_texture(SKINS[s])
					if tex != null:
						draw_texture_rect(tex, Rect2(Vector2(40 + p * 340, y + 50), Vector2(320, 320)), false)
					draw_string(font, Vector2(40 + p * 340, y + 395), POSES[p], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#2D3436"))
		else:
			var x := 30.0
			for i in SIZES.size():
				var side := SIZES[i]
				var tex := PipAssets.get_texture("")
				if tex != null:
					draw_texture_rect(tex, Rect2(Vector2(x, 260 - side), Vector2(side, side)), false)
					# Silueta: isti crtež u crnoj boji.
					draw_texture_rect(tex, Rect2(Vector2(x, 560 - side), Vector2(side, side)), false, Color(0, 0, 0, 1))
				draw_string(font, Vector2(x, 300), SIZE_NAMES[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#2D3436"))
				x += side + 24.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	for mode in ["poses", "sizes"]:
		var svp := SubViewport.new()
		svp.size = Vector2i(1080, 1300) if mode == "poses" else Vector2i(1080, 620)
		svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		get_root().add_child(svp)
		var sheet := _Sheet.new()
		sheet.mode = mode
		sheet.size = Vector2(svp.size)
		svp.add_child(sheet)
		for _i in 6:
			await process_frame
		await RenderingServer.frame_post_draw
		svp.get_texture().get_image().save_png(_out.path_join("pip_%s.png" % mode))
		print("captured pip_", mode)
		svp.queue_free()
		await process_frame
	quit(0)
