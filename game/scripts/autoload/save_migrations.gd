## Structural save migrations, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 5, SaveManager thin-out). Owned by GameState as `save_migrations`;
## called from _apply_save_dict() at the same points these ran inline before
## the extraction — pure code motion, no behavior change. Both methods
## operate on already-parsed GameState fields (not the raw save dict), same
## as before the move.
class_name SaveMigrations
extends RefCounted

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


## Drops any leftover key for a retired seed type_id from every bag-shaped
## dict that might still carry one, and clears loadout if it pointed at one.
func drop_retired_seed_keys() -> void:
	for bag in [
		_owner.seed_bag,
		_owner.last_seed_bag,
		_owner.garden_crystal_stash,
		_owner.lifetime_seeds_collected,
	]:
		for tid in _owner.RETIRED_SEED_TYPE_IDS:
			if bag.has(tid):
				bag.erase(tid)
	if _owner.RETIRED_SEED_TYPE_IDS.has(_owner.loadout_type_id):
		_owner.loadout_type_id = ""


## Pre-Bloom-Inbox saves (SAVE_VERSION < 12) parked T2+ merges in
## garden_beds/greenhouse_beds. One-time on load: sweep any bed still
## holding a T2+ merge into the inbox so it isn't silently dropped.
func migrate_legacy_beds_to_inbox() -> void:
	for in_greenhouse in [false, true]:
		for bed in _owner._bed_array(in_greenhouse):
			if bed == null:
				continue
			var tier := int(bed.get("tier", 0))
			if tier >= 2:
				_owner.push_bloom_inbox(str(bed.get("type_id", "")), tier)
