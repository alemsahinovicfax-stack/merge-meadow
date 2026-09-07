## Seed-bag inventory domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 4.3). Owned by GameState as `seed_bag_domain`; the `seed_bag` GameState
## property (getter/setter, see game_state.gd) delegates to `bag` here.
##
## A property shim (not a plain facade method) is required for `seed_bag`
## specifically because ~50 sites across Garden-bed, Arena pour, Run-finish,
## and Exchange logic in GameState itself — plus camp_controller.gd,
## merge_arena_controller.gd, shop_screen.gd, and 19 dev smoke scripts — read
## or write `GameState.seed_bag` as a raw Dictionary, not through a function.
## Those call sites are correctly OTHER domains' business logic operating on
## seed-bag data (e.g. Arena decides what to pull from the bag) — they aren't
## moving here, only the bag's own storage + mutation/query API is.
class_name SeedBagDomain
extends RefCounted

var bag: Dictionary = {}

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func add(type_id: String, count: int) -> int:
	if count <= 0 or type_id.is_empty():
		return 0
	var room := remaining_capacity()
	if room <= 0:
		return 0
	var to_add := mini(count, room)
	bag[type_id] = int(bag.get(type_id, 0)) + to_add
	return to_add


## Arena vacuum: return chips even when the bag is already over SEED_BAG_SOFT_CAP (debug grant).
func add_unbounded(type_id: String, count: int) -> int:
	if count <= 0 or type_id.is_empty():
		return 0
	bag[type_id] = int(bag.get(type_id, 0)) + count
	return count


func remaining_capacity() -> int:
	return maxi(0, int(_owner.SEED_BAG_SOFT_CAP) - _owner.sum_seed_bag(bag))


func take(type_id: String, count: int) -> bool:
	var have := int(bag.get(type_id, 0))
	if have < count:
		return false
	have -= count
	if have <= 0:
		bag.erase(type_id)
	else:
		bag[type_id] = have
	return true


func take_one(type_id: String) -> bool:
	return take(type_id, 1)


func sum() -> int:
	return _owner.sum_seed_bag(bag)


func format_label() -> String:
	var total := sum()
	if bag.is_empty():
		return "Seeds in bag: none (0/%d)" % _owner.SEED_BAG_SOFT_CAP
	var parts: PackedStringArray = []
	for type_id in bag:
		var count := int(bag[type_id])
		if count <= 0:
			continue
		var display_name: String = _owner.get_seed_display_name(type_id)
		var stars := "★".repeat(_owner.get_seed_rarity(type_id))
		parts.append("%d %s %s" % [count, display_name, stars])
	return "Seeds in bag (%d/%d): " % [total, _owner.SEED_BAG_SOFT_CAP] + ", ".join(parts)


func entries() -> Array[Dictionary]:
	## Sorted inventory rows for Garden UI: rarity ASC (★ → ★★★), then display name.
	var out: Array[Dictionary] = []
	for type_id in bag:
		var count := int(bag[type_id])
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
