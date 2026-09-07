class_name SeedCatalog
extends RefCounted

## Merge type_ids from SeasonDef.seed_type_ids — same namespace as Home roster.

const FALLBACK_DISPLAY: Dictionary = {
	"clover": "Clover",
	"daisy": "Daisy",
	"buttercup": "Buttercup",
	"tulip": "Tulip",
	"sunflower": "Sunflower",
	"pumpkin": "Pumpkin",
}

const FALLBACK_RARITY: Dictionary = {
	"clover": 1,
	"daisy": 1,
	"buttercup": 1,
	"tulip": 2,
	"sunflower": 2,
	"pumpkin": 3,
}

static var _built: bool = false
static var _type_ids: Array[String] = []
static var _season_by_type: Dictionary = {}
static var _display_by_type: Dictionary = {}
static var _rarity_by_type: Dictionary = {}


static func all_type_ids() -> Array[String]:
	_ensure_built()
	return _type_ids.duplicate()


static func types_for_season(season_id: String) -> Array[String]:
	_ensure_built()
	var def: SeasonDef = SeasonCatalog.get_def(season_id)
	if def == null:
		return []
	return def.seed_type_ids.duplicate()


static func season_id_for(type_id: String) -> String:
	_ensure_built()
	return str(_season_by_type.get(type_id, ""))


static func display_name(type_id: String) -> String:
	_ensure_built()
	if type_id.is_empty():
		return ""
	var named := str(_display_by_type.get(type_id, ""))
	if not named.is_empty():
		return named
	return str(FALLBACK_DISPLAY.get(type_id, type_id.capitalize()))


static func rarity(type_id: String) -> int:
	_ensure_built()
	if _rarity_by_type.has(type_id):
		return clampi(int(_rarity_by_type[type_id]), 1, 3)
	return clampi(int(FALLBACK_RARITY.get(type_id, 1)), 1, 3)


static func _ensure_built() -> void:
	if _built:
		return
	_built = true
	_type_ids.clear()
	_season_by_type.clear()
	_display_by_type.clear()
	_rarity_by_type.clear()
	for def in SeasonCatalog.all_defs():
		if def == null:
			continue
		var roster_by_id: Dictionary = {}
		for row in def.roster:
			if not row is Dictionary:
				continue
			var rid := str(row.get("id", "")).strip_edges()
			if rid.is_empty():
				continue
			roster_by_id[rid] = row
		for type_id in def.seed_type_ids:
			if type_id.is_empty() or _season_by_type.has(type_id):
				continue
			_type_ids.append(type_id)
			_season_by_type[type_id] = def.id
			if roster_by_id.has(type_id):
				var roster_row: Dictionary = roster_by_id[type_id]
				var shown := str(roster_row.get("display_name", "")).strip_edges()
				if not shown.is_empty():
					_display_by_type[type_id] = shown
				_rarity_by_type[type_id] = clampi(int(roster_row.get("rarity", 1)), 1, 3)
