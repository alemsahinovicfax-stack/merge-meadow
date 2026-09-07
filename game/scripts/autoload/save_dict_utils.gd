## Small save-dict parsing helpers shared by GameState's extracted domain
## classes (plan-arhitektura-refaktor.md Stage 3+). Mirrors the private
## helpers of the same shape already in game_state.gd — GameState's own
## _apply_save_dict keeps its copies untouched for now (SaveManager thin-out
## is Stage 5); this exists so newly-extracted classes don't each reinvent
## the same three loops.
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
