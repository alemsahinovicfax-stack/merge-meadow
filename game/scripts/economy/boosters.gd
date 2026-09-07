## Boosters domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 3). Owned by GameState as `boosters`; GameState keeps facade methods
## (get_booster_count, use_booster, ...) that forward here, so none of the
## external GameState call sites change. `merge_hint_active` is intentionally
## NOT persisted (matches pre-extraction behavior — it was never part of
## save_player_save()'s dict, it's a runtime-only flag).
class_name Boosters
extends RefCounted

var inventory: Dictionary = {}
var merge_hint_active: bool = false

## Untyped on purpose — see cosmetics.gd for why (dynamic access to
## GameState members that aren't part of the Node API).
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func apply_from_save(data: Dictionary) -> void:
	inventory = SaveDictUtils.parse_string_int_dict(data.get("booster_inventory", {}))


func to_save_dict() -> Dictionary:
	return {"booster_inventory": inventory.duplicate()}


func count(booster_id: String) -> int:
	return maxi(0, int(inventory.get(booster_id, 0)))


func add(booster_id: String, amount: int = 1) -> void:
	if booster_id.is_empty() or amount <= 0:
		return
	inventory[booster_id] = count(booster_id) + amount
	_owner.save_player_save()


func use(booster_id: String) -> String:
	if count(booster_id) <= 0:
		return "No boosters left."
	match booster_id:
		MonetizationConfig.BOOSTER_MERGE_HINT:
			merge_hint_active = true
			_consume(booster_id)
			return "Merge Hint ready — open Merge arena."
		MonetizationConfig.BOOSTER_LOOT_BURST:
			var added := _grant_loot_burst_seeds()
			_consume(booster_id)
			return "Loot Burst: +%d seeds to bag!" % added
		_:
			return "Unknown booster."


func _consume(booster_id: String) -> void:
	var left := count(booster_id) - 1
	if left <= 0:
		inventory.erase(booster_id)
	else:
		inventory[booster_id] = left
	_owner.save_player_save()


func _grant_loot_burst_seeds() -> int:
	var added := 0
	for _i in MonetizationConfig.LOOT_BURST_SEEDS:
		var type_id: String = _owner.pick_random_run_seed_type()
		if _owner.add_seeds_to_bag(type_id, 1):
			added += 1
	_owner.save_player_save()
	return added


func consume_merge_hint() -> bool:
	if not merge_hint_active:
		return false
	merge_hint_active = false
	return true


func get_merge_hint_message(chip_data: Dictionary) -> String:
	var counts: Dictionary = {}
	for _chip_id in chip_data:
		var entry: Dictionary = chip_data[_chip_id]
		if int(entry.get("tier", 1)) != 1:
			continue
		var type_id := str(entry.get("type_id", ""))
		if type_id.is_empty():
			continue
		counts[type_id] = int(counts.get(type_id, 0)) + 1
	for type_id in counts:
		if int(counts[type_id]) >= 2:
			var display_name: String = _owner.get_seed_display_name(type_id)
			return "Hint: merge two %s seeds." % display_name
	return "Hint: pour seeds and merge matching pairs."
