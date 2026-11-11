extends SceneTree

## SVG tekst u exportu (FIX-TEL 2026-11, greske-katalog #63): telefon nije imao skinove,
## novog Pipa ni Nibbsa jer export ne nosi sirovi .svg. Test čita SAMO kopije .svgsrc
## (SvgSource.force_mirror), kao na telefonu:
##  1. svaka kopija postoji i jednaka je sirovom SVG-u (kad je sirovi tu — iz projekta);
##  2. atlas svakog Pip skina ima regione; atlas Nibbsa ima regione;
##  3. pip_idle + poze imaju tekst; svaki skin s recolorom daje teksturu.
## Radi i iz exportovanog paketa (scripts/phone-like-run.ps1 -Smoke svg_source_smoke).
##   godot --headless --path game -s res://scripts/dev/svg_source_smoke.gd

const RAW_DIRS := ["res://assets/pip", "res://assets/muncher"]
const RAW_FILES := [
	"res://assets/sprites/pip_idle.svg",
	"res://assets/sprites/pip_sniff.svg",
	"res://assets/sprites/pip_sleep.svg",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var raws: Array = RAW_FILES.duplicate()
	for d in RAW_DIRS:
		_collect(d, raws)
	var compared := 0
	for path in raws:
		if not FileAccess.file_exists(path):
			continue
		var mirror: String = SvgSource.mirror_path(path)
		if not FileAccess.file_exists(mirror):
			return _fail("no .svgsrc copy for %s — run scripts/sync-svg-src.ps1" % path)
		if FileAccess.get_file_as_string(mirror) != FileAccess.get_file_as_string(path):
			return _fail("stale .svgsrc copy for %s — run scripts/sync-svg-src.ps1" % path)
		compared += 1

	SvgSource.force_mirror = true
	for path in RAW_FILES:
		if SvgSource.read(path).is_empty():
			return _fail("no SVG text for %s" % path)

	UiPip.data()
	var skins: Dictionary = UiPip._skins
	if skins.is_empty():
		return _fail("pip skins.json is empty")
	for key in skins:
		UiPip.request_atlas(str(key))
		var guard := 0
		while not UiPip.atlas_ready(str(key)) and guard < 2000:
			await process_frame
			guard += 1
		if not UiPip.atlas_has_regions(str(key)):
			return _fail("pip atlas for skin '%s' has no regions" % key)

	var m_atlas: Dictionary = MuncherRig.atlas()
	if (m_atlas.get("regions", {}) as Dictionary).is_empty():
		return _fail("muncher atlas has no regions")

	if PipAssets.svg_source().is_empty():
		return _fail("pip_idle SVG text missing")
	var recolored := 0
	for id in CosmeticCatalog.all_ids():
		if CosmeticCatalog.get_recolor(id).is_empty():
			continue
		if PipAssets.texture_for_recolor(CosmeticCatalog.get_recolor(id)) == null:
			return _fail("skin '%s' recolor gives no texture" % id)
		recolored += 1

	print("svg_source_smoke: copies checked %d, pip skins %d, recolors %d" % [compared, skins.size(), recolored])
	print("svg_source_smoke OK")
	quit(0)


func _collect(dir_path: String, out: Array) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	for sub in dir.get_directories():
		_collect(dir_path + "/" + sub, out)
	for f in dir.get_files():
		if f.ends_with(".svg"):
			out.append(dir_path + "/" + f)


func _fail(msg: String) -> void:
	push_error("svg_source_smoke FAIL: " + msg)
	print("svg_source_smoke FAIL: " + msg)
	quit(1)
