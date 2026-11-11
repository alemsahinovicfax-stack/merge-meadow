class_name SvgSource
extends RefCounted

## Tekst SVG fajla za rasterizaciju u igri (Pip rig, recolor skinova, Nibbs).
## Export NE nosi sirovi .svg koji ima .import (u paketu je samo .ctex), pa
## FileAccess na telefonu vrati prazno — skinovi i Nibbs nisu postojali (greske-katalog #63).
## Zato svaki takav SVG ima kopiju res://data/svg_src/<ista putanja>.svgsrc (bez importera,
## u export ulazi kroz include_filter "*.svgsrc"). Kopije pravi scripts/sync-svg-src.ps1
## (zove ga android-export.ps1); svg_source_smoke pada kad kopija fali ili je zastarjela.

const MIRROR_DIR := "res://data/svg_src/"
const MIRROR_EXT := ".svgsrc"

## Test: čitaj samo kopiju, kao u exportu.
static var force_mirror: bool = false


static func mirror_path(path: String) -> String:
	return MIRROR_DIR + path.trim_prefix("res://").trim_suffix(".svg") + MIRROR_EXT


static func read(path: String) -> String:
	if not force_mirror and FileAccess.file_exists(path):
		return FileAccess.get_file_as_string(path)
	var mirror := mirror_path(path)
	if FileAccess.file_exists(mirror):
		return FileAccess.get_file_as_string(mirror)
	return ""
