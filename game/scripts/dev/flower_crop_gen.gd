extends SceneTree

## Alat: generiše scripts/visual/flower_crop_table.gd — rub vidljivog crteža (alpha > 0) svake
## teksture cvijeta. Igra je taj rub ranije tražila pri prvom crtanju (tex.get_image() = čitanje
## teksture nazad s grafičke kartice; na telefonu zastoj pri prvom sipanju / prvom T2 / T3 svake
## vrste — FIX-TEL-3 2026-11-12). Pokreni poslije SVAKE izmjene SVG-ova u assets/sprites/flowers:
##   godot --path game --rendering-driver opengl3 -s res://scripts/dev/flower_crop_gen.gd
## (s prozorom — headless nema teksture). `--check` samo poredi s postojećom tabelom.

const DIR := "res://assets/sprites/flowers/"
const OUT := "res://scripts/visual/flower_crop_table.gd"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var check := OS.get_cmdline_user_args().has("--check") or OS.get_cmdline_args().has("--check")
	var names: Array[String] = []
	for f in DirAccess.get_files_at(DIR):
		if f.ends_with(".svg"):
			names.append(f)
	names.sort()
	var lines: Array[String] = []
	var bad := 0
	for f in names:
		var tex := load(DIR + f) as Texture2D
		var img := tex.get_image() if tex != null else null
		if img == null or img.is_empty():
			push_error("flower_crop_gen: no image for %s (run WITH a window, not --headless)" % f)
			bad += 1
			continue
		var used := img.get_used_rect()
		var size := tex.get_size()
		lines.append("\t\"%s\": [%d, %d, %d, %d, %d, %d]," % [
			DIR + f, used.position.x, used.position.y, used.size.x, used.size.y, int(size.x), int(size.y)])
	if bad > 0 or lines.is_empty():
		quit(1)
		return
	var text := "class_name FlowerCropTable\nextends RefCounted\n\n"
	text += "## GENERISANO — ne mijenjaj ručno. Alat: scripts/dev/flower_crop_gen.gd (pokreni poslije\n"
	text += "## izmjene SVG-ova cvjetova). Vrijednost: [x, y, w, h vidljivog crteža, širina i visina teksture].\n"
	text += "## Red se koristi samo ako se veličina teksture poklapa; inače CampPlantDraw računa sam.\n\n"
	text += "const TABLE := {\n" + "\n".join(lines) + "\n}\n"
	if check:
		var have := FileAccess.get_file_as_string(OUT)
		if have != text:
			push_error("flower_crop_gen: table is STALE — rerun without --check")
			quit(1)
			return
		print("flower_crop_gen check OK (%d textures)" % lines.size())
		quit(0)
		return
	var out := FileAccess.open(OUT, FileAccess.WRITE)
	out.store_string(text)
	out.close()
	print("flower_crop_gen OK — %d textures -> %s" % [lines.size(), OUT])
	quit(0)
