## Boosters domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 3). Owned by GameState as `boosters`; GameState keeps facade methods.
##
## Shop v2 (design_handoff_shop_v2, 2026-10-02):
## - Merge Hint je jednokratna kupovina (`merge_hint_owned`, snima se). Dok igrač
##   drži sjemenku u Areni, najbliža ista sjemenka dobije oznaku (MergeHintMark).
## - Loot Burst se kupuje više puta i odmah daje +5 ★3 cvjetova sezone koja je uslov
##   za sljedeću zaključanu besplatnu sezonu. Kad je sve otključano, ne prodaje se.
## - Stara zaliha iz saveova (inventory) se jednom migrira: merge_hint > 0 → owned,
##   svaki preostali loot_burst se primijeni po novom pravilu.
class_name Boosters
extends RefCounted

var inventory: Dictionary = {}
var merge_hint_owned: bool = false

## Untyped on purpose — see cosmetics.gd for why (dynamic access to
## GameState members that aren't part of the Node API).
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func apply_from_save(data: Dictionary) -> void:
	inventory = SaveDictUtils.parse_string_int_dict(data.get("booster_inventory", {}))
	merge_hint_owned = bool(data.get("merge_hint_owned", false))


func to_save_dict() -> Dictionary:
	return {"booster_inventory": inventory.duplicate(), "merge_hint_owned": merge_hint_owned}


## Poziva se kad je cijeli save učitan (Loot Burst treba sezone). Vraća true ako je
## nešto migrirano (pozivalac snima).
func migrate_legacy_inventory() -> bool:
	var changed := false
	if int(inventory.get(MonetizationConfig.BOOSTER_MERGE_HINT, 0)) > 0:
		merge_hint_owned = true
		inventory.erase(MonetizationConfig.BOOSTER_MERGE_HINT)
		changed = true
	var bursts := int(inventory.get(MonetizationConfig.BOOSTER_LOOT_BURST, 0))
	if bursts > 0:
		inventory.erase(MonetizationConfig.BOOSTER_LOOT_BURST)
		for _i in bursts:
			_grant_loot_burst(false)
		changed = true
	return changed


func count(booster_id: String) -> int:
	return maxi(0, int(inventory.get(booster_id, 0)))


func grant_merge_hint() -> void:
	merge_hint_owned = true


## Cilj Loot Bursta: {next, from, flower, have, need, add}; {} kad su sve besplatne
## sezone otključane (kartica se ne crta).
func loot_target() -> Dictionary:
	var next_id: String = _owner.next_locked_free_id()
	if next_id.is_empty():
		return {}
	var from_id: String = _owner.previous_free_id_for(next_id)
	if from_id.is_empty():
		return {}
	var flower: String = _owner.star3_type_id_for_season(from_id)
	if flower.is_empty():
		return {}
	var def: SeasonDef = _owner.get_season_def(next_id)
	return {
		"next": next_id,
		"from": from_id,
		"flower": flower,
		"have": maxi(0, int(_owner.garden_crystal_stash.get(flower, 0))),
		"need": def.t3_flowers_required if def != null else 0,
		"add": MonetizationConfig.LOOT_BURST_STAR3,
	}


func can_buy_loot_burst() -> bool:
	return not loot_target().is_empty()


## Kupljen Loot Burst: +5 ★3 cvjetova u stash. Vraća {flower, added}.
func grant_loot_burst() -> Dictionary:
	return _grant_loot_burst(true)


func _grant_loot_burst(save: bool) -> Dictionary:
	var target := loot_target()
	if target.is_empty():
		# Sve sezone otključane (npr. restore starog kupca) — ne gubi se ništa: sjeme kao prije.
		var added := 0
		for _i in MonetizationConfig.LOOT_BURST_STAR3:
			added += _owner.add_seeds_to_bag_unbounded(_owner.pick_random_run_seed_type(), 1)
		if save:
			_owner.save_player_save()
		return {"flower": "", "added": added}
	var flower: String = target["flower"]
	var stash: Dictionary = _owner.garden_crystal_stash
	stash[flower] = int(stash.get(flower, 0)) + MonetizationConfig.LOOT_BURST_STAR3
	if save:
		_owner.save_player_save()
	return {"flower": flower, "added": MonetizationConfig.LOOT_BURST_STAR3}
