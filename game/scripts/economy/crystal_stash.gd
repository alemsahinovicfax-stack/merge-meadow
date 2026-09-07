## Garden crystal stash domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 4.5). Owned by GameState as `crystal_stash_domain`; the
## `garden_crystal_stash` GameState property (getter/setter, see game_state.gd)
## delegates to `stash` here.
##
## A property shim (not a plain facade method) is required for
## `garden_crystal_stash` specifically because camp_controller.gd reads/checks
## `GameState.garden_crystal_stash` as a raw Dictionary in several places
## (crystal-select UI, exchange availability) — same pattern as seed_bag
## (see seed_bag_domain.gd). Those call sites are correctly camp UI logic
## reading crystal-stash data, not moving here.
##
## Star3-unlock spend (Seasons), upgrade-flower spend (Upgrades), and the
## debug/dev fixtures also read/write garden_crystal_stash directly — those
## stay on GameState too, same reasoning as seed_bag's Arena/Exchange callers.
class_name CrystalStashDomain
extends RefCounted

var stash: Dictionary = {}

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func add(type_id: String) -> void:
	if type_id.is_empty():
		return
	stash[type_id] = int(stash.get(type_id, 0)) + 1


func take_one(type_id: String) -> bool:
	var have := int(stash.get(type_id, 0))
	if have <= 0:
		return false
	if have <= 1:
		stash.erase(type_id)
	else:
		stash[type_id] = have - 1
	return true


func total() -> int:
	return _owner.sum_seed_bag(stash)


func first_type() -> String:
	var types: Array[String] = []
	for type_id in stash:
		if int(stash.get(type_id, 0)) > 0:
			types.append(str(type_id))
	if types.is_empty():
		return ""
	types.sort_custom(_owner._compare_seed_pour_priority)
	return types[0]


func format_label() -> String:
	var total_count := total()
	if total_count <= 0:
		return "Garden stash: empty (T3 crystals from merge go here)"
	var types: Array[String] = []
	for type_id in stash:
		if int(stash.get(type_id, 0)) > 0:
			types.append(str(type_id))
	types.sort_custom(_owner._compare_seed_pour_priority)
	var parts: PackedStringArray = []
	for type_id in types:
		var count := int(stash.get(type_id, 0))
		var display_name: String = _owner.get_seed_display_name(type_id)
		parts.append("%s×%d" % [display_name, count])
	return "Garden stash: %s (%d total)" % [", ".join(parts), total_count]


func entries() -> Array[Dictionary]:
	## Sorted inventory rows for CrystalCard UI: rarity ASC, then display name.
	var out: Array[Dictionary] = []
	for type_id in stash:
		var count := int(stash[type_id])
		if count <= 0:
			continue
		var tid := str(type_id)
		out.append({
			"type_id": tid,
			"count": count,
			"display_name": _owner.get_seed_display_name(tid),
			"rarity": _owner.get_seed_rarity(tid),
		})
	out.sort_custom(_owner._compare_seed_bag_entry_asc)
	return out
