## Small save-dict parsing helpers shared by GameState's extracted domain
## classes (plan-arhitektura-refaktor.md Stage 3+). GameState's own
## _apply_save_dict/save_player_save became a pure per-domain dispatcher in
## Stage 5 — every extracted domain's apply_from_save()/to_save_dict() goes
## through these instead of reinventing the same loops. GameState keeps its
## own parse_string_int_dict/parse_string_bool_dict copies for fields that
## are still GameState-core (discovered_blooms, lifetime_seeds_collected, …).
class_name SaveDictUtils
extends RefCounted


static func parse_string_int_dict(data: Variant) -> Dictionary:
	var out: Dictionary = {}
	if not data is Dictionary:
		return out
	for key in data:
		var count := int(data[key])
		if count > 0:
			out[str(key)] = count
	return out


static func parse_string_bool_dict(data: Variant) -> Dictionary:
	var out: Dictionary = {}
	if not data is Dictionary:
		return out
	for key in data:
		if bool(data[key]):
			out[str(key)] = true
	return out


static func parse_string_string_dict(data: Variant) -> Dictionary:
	var out: Dictionary = {}
	if not data is Dictionary:
		return out
	for key in data:
		var value := str(data[key])
		if not value.is_empty():
			out[str(key)] = value
	return out


static func parse_string_array(data: Variant) -> Array[String]:
	var out: Array[String] = []
	if not data is Array:
		return out
	for item in data:
		var value := str(item).strip_edges()
		if not value.is_empty() and not out.has(value):
			out.append(value)
	return out
