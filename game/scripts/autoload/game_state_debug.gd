## Dev/debug-only fixtures and playtest helpers, extracted from GameState
## (plan-arhitektura-refaktor.md Stage 7, dev-only isolation — the last
## stage). Owned by GameState as `debug`. Every entry point stays gated
## behind OS.is_debug_build() (or the DEBUG_DEV_RESOURCES constant, for the
## new-game fixture), consistent with every other debug_*/DEBUG_* guard in
## the codebase — pure code motion, no behavior change.
##
## Facade methods on GameState keep identical names — apply_debug_leftover_test_bag()/
## _try_apply_debug_leftover_test_bag() are called from live production code
## (merge_arena_controller.gd's ARENA-02 leftover playtest path) and by name
## via gs.call(...) from several dev smoke scripts, not just other debug
## tooling.
class_name GameStateDebug
extends RefCounted

# Playtest — DEBUG seeda samo kad nema save datoteke (prvi boot).
const DEBUG_DEV_RESOURCES := false
const DEBUG_WALLET_COINS := 20
const DEBUG_SEED_COUNT := 20
## ARENA-02 leftover playtest. Overwrite ignores SEED_BAG_SOFT_CAP (stays 40).
const DEBUG_LEFTOVER_TEST_BAG: Dictionary = {
	"clover": 19,
	"daisy": 22,
	"buttercup": 13,
	"tulip": 28,
	"sunflower": 18,
}
## HOME-07 P84 + HOME-09 P111 — debug skip so a free next-lock remains; can_unlock_free still works.
const DEBUG_SKIP_FREE_ID := "lantern_meadow"
const DEBUG_SKIP_AMBER_ID := "amber_canopy"

var _leftover_bag_applied: bool = false

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func unlock_all_seasons() -> void:
	if not OS.is_debug_build():
		return
	for def in SeasonCatalog.free_defs_sorted():
		if (
			_owner.is_test_locked_season(def.id)
			or def.id == DEBUG_SKIP_FREE_ID
			or def.id == DEBUG_SKIP_AMBER_ID
		):
			continue
		if not _owner.unlocked_seasons.has(def.id):
			_owner.unlocked_seasons.append(def.id)
	for def in SeasonCatalog.paid_defs():
		if _owner.is_test_locked_season(def.id):
			continue
		if not _owner.owned_paid_seasons.has(def.id):
			_owner.owned_paid_seasons.append(def.id)
	var s2 := "frost_orchard"
	if _owner.unlocked_seasons.has(s2):
		_owner.focus_season_id = s2
		_owner.active_season_id = s2
	else:
		_owner.focus_season_id = SeasonCatalog.DEFAULT_SEASON_ID
		_owner.active_season_id = SeasonCatalog.DEFAULT_SEASON_ID
	_owner._normalize_season_progress()
	_owner.save_player_save()


func grant_unlock_test_funds() -> void:
	if not OS.is_debug_build():
		return
	_owner.wallet_coins = maxi(_owner.wallet_coins, 500)
	var next_id: String = _owner.next_locked_free_id()
	if next_id.is_empty():
		_owner.save_player_save()
		return
	var def := SeasonCatalog.get_def(next_id)
	var need := 20
	if def != null:
		need = def.t3_flowers_required
	var have: int = _owner.star3_flower_count_for_unlock(next_id)
	if have < need:
		var types: Array[String] = _owner.star3_type_ids_for_season(_owner.previous_free_id_for(next_id))
		var fill_id := "pumpkin"
		if not types.is_empty():
			fill_id = types[0]
			if types.has("pumpkin"):
				fill_id = "pumpkin"
		_owner.garden_crystal_stash[fill_id] = int(_owner.garden_crystal_stash.get(fill_id, 0)) + (need - have)
	_owner.save_player_save()


func playtest_two_free() -> void:
	if not OS.is_debug_build():
		return
	_owner.unlocked_seasons.clear()
	_owner.unlocked_seasons.append(SeasonCatalog.DEFAULT_SEASON_ID)
	if not _owner.unlocked_seasons.has("frost_orchard"):
		_owner.unlocked_seasons.append("frost_orchard")
	_owner.owned_paid_seasons.clear()
	if _owner.is_season_playable("frost_orchard"):
		_owner.focus_season_id = "frost_orchard"
		_owner.active_season_id = "frost_orchard"
	else:
		_owner.focus_season_id = SeasonCatalog.DEFAULT_SEASON_ID
		_owner.active_season_id = SeasonCatalog.DEFAULT_SEASON_ID
	_owner._normalize_season_progress()
	_owner.save_player_save()


func relock_playtest_free() -> void:
	if not OS.is_debug_build():
		return
	var kept: Array[String] = []
	for sid in _owner.unlocked_seasons:
		var id := str(sid)
		if id == DEBUG_SKIP_FREE_ID or id == DEBUG_SKIP_AMBER_ID:
			continue
		if not kept.has(id):
			kept.append(id)
	if not kept.has(SeasonCatalog.DEFAULT_SEASON_ID):
		kept.insert(0, SeasonCatalog.DEFAULT_SEASON_ID)
	if not kept.has("frost_orchard"):
		kept.append("frost_orchard")
	_owner.unlocked_seasons.clear()
	for id in kept:
		_owner.unlocked_seasons.append(id)
	if _owner.is_season_playable("frost_orchard"):
		_owner.focus_season_id = "frost_orchard"
		_owner.active_season_id = "frost_orchard"
	else:
		_owner.focus_season_id = SeasonCatalog.DEFAULT_SEASON_ID
		_owner.active_season_id = SeasonCatalog.DEFAULT_SEASON_ID
	_owner._normalize_season_progress()
	_owner.save_player_save()


func fixture_s1_star3_playtest() -> void:
	if not OS.is_debug_build():
		return
	var default_id := SeasonCatalog.DEFAULT_SEASON_ID
	_owner.unlocked_seasons.clear()
	_owner.unlocked_seasons.append(default_id)
	_owner.active_season_id = default_id
	_owner.focus_season_id = default_id
	_owner.home_band = "free"
	_owner.home_season_field_open = false
	_owner.home_season_field_id = ""
	_owner._normalize_season_progress()
	_owner.wallet_coins = maxi(_owner.wallet_coins, 500)
	for type_id in _owner.star3_type_ids_for_season(default_id):
		_owner.garden_crystal_stash.erase(type_id)
	_owner.garden_crystal_stash["pumpkin"] = 19
	remap_seed_bag_to_season(default_id)
	_owner.seed_bag["pumpkin"] = 22
	_owner.save_player_save()


func remap_seed_bag_to_season(season_id: String) -> void:
	var allowed := SeedCatalog.types_for_season(season_id)
	if allowed.is_empty():
		return
	var kept: Dictionary = {}
	var overflow: Array[int] = []
	for type_id in _owner.seed_bag:
		var n := int(_owner.seed_bag[type_id])
		if n <= 0:
			continue
		if allowed.has(type_id):
			kept[type_id] = n
		else:
			overflow.append(n)
	for n in overflow:
		var dest := ""
		for tid in allowed:
			if int(kept.get(tid, 0)) <= 0:
				dest = tid
				break
		if dest.is_empty():
			dest = allowed[0]
		kept[dest] = n if int(kept.get(dest, 0)) <= 0 else int(kept.get(dest, 0)) + n
	_owner.seed_bag = kept


func apply_resources_if_new_game() -> void:
	if not DEBUG_DEV_RESOURCES:
		return
	if FileAccess.file_exists(_owner.PLAYER_SAVE_PATH):
		return
	_owner.wallet_coins = DEBUG_WALLET_COINS
	apply_leftover_test_bag()


func apply_leftover_test_bag() -> bool:
	return try_apply_leftover_test_bag(OS.is_debug_build())


func try_apply_leftover_test_bag(dev_enabled: bool) -> bool:
	if not dev_enabled:
		return false
	if _leftover_bag_applied:
		return false
	_owner.seed_bag = DEBUG_LEFTOVER_TEST_BAG.duplicate()
	_owner.seed_unlock_index = 4
	_owner.tutorial_complete = true
	_owner.tutorial_step = _owner.TutorialStep.FREE
	for type_id in DEBUG_LEFTOVER_TEST_BAG:
		_owner.discovered_blooms[str(type_id)] = true
	_leftover_bag_applied = true
	_owner.save_player_save()
	return true


## Dev/playtest — min. count po otključanom tipu (ignorira soft cap u torbi).
func ensure_dev_unlocked_seeds(count_per_type: int = 10) -> void:
	if not OS.is_debug_build():
		return
	apply_dev_unlocked_seeds(count_per_type)
	_owner.save_player_save()


func apply_dev_unlocked_seeds(count_per_type: int) -> void:
	for i in range(_owner.seed_unlock_index + 1):
		var type_id := SeedUnlockConfig.get_type_at_index(i)
		if type_id.is_empty():
			continue
		var current := int(_owner.seed_bag.get(type_id, 0))
		if current < count_per_type:
			_owner.seed_bag[type_id] = count_per_type
