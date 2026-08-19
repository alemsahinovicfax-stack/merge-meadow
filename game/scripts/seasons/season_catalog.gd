class_name SeasonCatalog
extends RefCounted

## Lazy JSON catalog. Public season API lives on GameState.

const PATH := "res://data/seasons/seasons.json"
const DEFAULT_SEASON_ID := "country_bloom"

static var _loaded: bool = false
static var _by_id: Dictionary = {}
static var _all: Array[SeasonDef] = []


static func get_def(season_id: String) -> SeasonDef:
	_ensure_loaded()
	return _by_id.get(season_id, null) as SeasonDef


static func all_defs() -> Array[SeasonDef]:
	_ensure_loaded()
	return _all.duplicate()


static func free_defs_sorted() -> Array[SeasonDef]:
	_ensure_loaded()
	var free_list: Array[SeasonDef] = []
	for def in _all:
		if def.is_free():
			free_list.append(def)
	free_list.sort_custom(func(a: SeasonDef, b: SeasonDef) -> bool:
		return a.order < b.order
	)
	return free_list


static func paid_defs() -> Array[SeasonDef]:
	_ensure_loaded()
	var paid_list: Array[SeasonDef] = []
	for def in _all:
		if def.is_paid():
			paid_list.append(def)
	return paid_list


static func previous_free_id(def: SeasonDef) -> String:
	if def == null or not def.is_free() or def.order <= 1:
		return ""
	var target_order := def.order - 1
	for other in free_defs_sorted():
		if other.order == target_order:
			return other.id
	return ""


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_by_id.clear()
	_all.clear()
	if not FileAccess.file_exists(PATH):
		push_warning("SeasonCatalog: missing %s" % PATH)
		return
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	var seasons: Variant = parsed.get("seasons", [])
	if not seasons is Array:
		return
	for entry in seasons:
		if not entry is Dictionary:
			continue
		var def := SeasonDef.from_dict(entry)
		if def.id.is_empty() or _by_id.has(def.id):
			continue
		_all.append(def)
		_by_id[def.id] = def
