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
## Koliko je ★3 svakog tipa IKAD uzgojeno (Arena T3, Loot Burst). Ne pada kad se cvijet proda
## u Campu ili potroši na otključavanje sezone — Home polje sezone raste po ovome (2026-10-16:
## polje je čitalo stash, pa se poslije prodaje ništa nije vidjelo, ni novi T3 iz Arene).
var grown: Dictionary = {}

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func apply_from_save(data: Dictionary) -> void:
	stash = SaveDictUtils.parse_string_int_dict(data.get("garden_crystal_stash", {}))
	grown = SaveDictUtils.parse_string_int_dict(data.get("star3_grown", {}))


func to_save_dict() -> Dictionary:
	return {"garden_crystal_stash": stash.duplicate(), "star3_grown": grown.duplicate()}


## Stari save (prije 2026-10-16) nema `star3_grown`: najmanje ono što je sada u stashu, a za
## svaki ★3 koji je Album zapisao (kept tier 3) bar 1 — pa već uzgojeno cvijeće ne nestane.
func seed_grown_from_history(kept_tiers: Dictionary, max_tier: int) -> void:
	for type_id in stash:
		grown[type_id] = maxi(int(grown.get(type_id, 0)), int(stash[type_id]))
	for type_id in kept_tiers:
		if int(kept_tiers[type_id]) >= max_tier:
			grown[type_id] = maxi(int(grown.get(type_id, 0)), 1)


## Za polje: veće od „ikad uzgojeno" i „sada u stashu" (dev / testovi pišu stash direktno).
func grown_count(type_id: String) -> int:
	return maxi(int(grown.get(type_id, 0)), int(stash.get(type_id, 0)))


func add(type_id: String) -> void:
	add_many(type_id, 1)


func add_many(type_id: String, count: int) -> void:
	if type_id.is_empty() or count <= 0:
		return
	stash[type_id] = int(stash.get(type_id, 0)) + count
	grown[type_id] = int(grown.get(type_id, 0)) + count


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
