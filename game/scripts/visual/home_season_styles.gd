class_name HomeSeasonStyles
extends RefCounted

## StyleBoxFlat iz design_handoff_home_v2/godot/styles. Duplicate pa oboji preko SeasonColors.

const DIR := "res://themes/home_season/"

static var _cache: Dictionary = {}


static func get_style(file_name: String) -> StyleBoxFlat:
	if not _cache.has(file_name):
		var loaded := load(DIR + file_name + ".tres") as StyleBoxFlat
		_cache[file_name] = loaded
	var src := _cache[file_name] as StyleBoxFlat
	if src == null:
		return StyleBoxFlat.new()
	return src.duplicate() as StyleBoxFlat
