## Merge Arena domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 4.7). Owned by GameState as `arena_domain`. Combo-coin daily grant,
## the Arena daily task, pour locks, and the pour-queue/merge/leftover-resolve
## logic that used to live scattered across game_state.gd (~1905, ~1946-2018,
## ~2257-2458).
##
## ARENA_MAX_CHIPS/ARENA_SNAP_DISTANCE/ARENA_MAGNET_RADIUS/ARENA_PEST_* stay
## on GameState — merge_arena_controller.gd and arena_pest.gd read them as
## `GameState.ARENA_*` directly, same reasoning as crystal_stash.gd leaving
## external-facing constants on the owner.
##
## `_compare_seed_pour_priority`/`get_bag_types_by_pour_priority`/
## `get_bag_preview_types` also stay on GameState — shared pour-priority
## utility used by crystal_stash.gd too, not Arena-exclusive.
class_name ArenaDomain
extends RefCounted

const COMBO_COINS := 2
const COMBO_COIN_DAILY_CAP := 10
const DAILY_KINDS: PackedStringArray = ["merge_t2", "make_t3", "combo_5"]

var combo_coin_day: String = ""
var combo_coins_granted_today: int = 0

var daily_day: String = ""
var daily_kind: String = ""
var daily_progress: int = 0
var daily_goal: int = 1
var daily_claimed_day: String = ""
var daily_streak: int = 0

var _chip_counter: int = 1
var _pour_locked_types: Dictionary = {}

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func apply_from_save(data: Dictionary) -> void:
	combo_coin_day = str(data.get("combo_coin_day", ""))
	combo_coins_granted_today = maxi(0, int(data.get("combo_coins_granted_today", 0)))
	daily_day = str(data.get("arena_daily_day", ""))
	daily_kind = str(data.get("arena_daily_kind", ""))
	daily_progress = maxi(0, int(data.get("arena_daily_progress", 0)))
	daily_goal = maxi(1, int(data.get("arena_daily_goal", 1)))
	daily_claimed_day = str(data.get("arena_daily_claimed_day", ""))
	daily_streak = maxi(0, int(data.get("arena_daily_streak", 0)))


func to_save_dict() -> Dictionary:
	return {
		"combo_coin_day": combo_coin_day,
		"combo_coins_granted_today": combo_coins_granted_today,
		"arena_daily_day": daily_day,
		"arena_daily_kind": daily_kind,
		"arena_daily_progress": daily_progress,
		"arena_daily_goal": daily_goal,
		"arena_daily_claimed_day": daily_claimed_day,
		"arena_daily_streak": daily_streak,
	}


func grant_combo_coins() -> int:
	var today: String = _owner._today_key()
	if combo_coin_day != today:
		combo_coin_day = today
		combo_coins_granted_today = 0
	var remaining := COMBO_COIN_DAILY_CAP - combo_coins_granted_today
	if remaining <= 0:
		return 0
	var grant := mini(COMBO_COINS, remaining)
	_owner._add_coins(grant)
	combo_coins_granted_today += grant
	_owner.save_player_save()
	return grant


func _daily_kind_for_day(day: String) -> String:
	if day.is_empty():
		return DAILY_KINDS[0]
	var idx := absi(day.hash()) % DAILY_KINDS.size()
	return DAILY_KINDS[idx]


func _daily_goal_for_kind(kind: String) -> int:
	if kind == "merge_t2":
		return 3
	return 1


func ensure_daily_task() -> void:
	var today: String = _owner._today_key()
	if daily_day == today and not daily_kind.is_empty():
		daily_goal = _daily_goal_for_kind(daily_kind)
		daily_progress = mini(daily_progress, daily_goal)
		return
	daily_day = today
	daily_kind = _daily_kind_for_day(today)
	daily_goal = _daily_goal_for_kind(daily_kind)
	daily_progress = 0
	_owner.save_player_save()


func note_daily_event(kind: String) -> void:
	ensure_daily_task()
	if kind != daily_kind:
		return
	if daily_progress >= daily_goal:
		return
	daily_progress += 1
	_owner.save_player_save()


func can_claim_daily() -> bool:
	ensure_daily_task()
	return (
		daily_progress >= daily_goal
		and daily_claimed_day != _owner._today_key()
	)


func claim_daily() -> String:
	if not can_claim_daily():
		return "Arena daily already claimed today."
	daily_claimed_day = _owner._today_key()
	daily_streak += 1
	_owner.save_player_save()
	return "Arena streak %d" % daily_streak


func get_daily_hud_text() -> String:
	ensure_daily_task()
	var n := mini(daily_progress, daily_goal)
	if daily_kind == "merge_t2":
		return "Merge T2 %d/%d" % [n, daily_goal]
	if daily_kind == "make_t3":
		return "T3 %d/%d" % [n, daily_goal]
	return "Combo 5 %d/%d" % [n, daily_goal]


func get_daily_home_line() -> String:
	ensure_daily_task()
	if daily_claimed_day == _owner._today_key():
		return "Arena streak %d" % daily_streak
	if daily_progress >= daily_goal:
		return "Arena daily — tap for badge"
	return "Arena %d/%d" % [mini(daily_progress, daily_goal), daily_goal]


func is_pour_locked(type_id: String) -> bool:
	if type_id.is_empty() or not _pour_locked_types.has(type_id):
		return false
	# S31 — lock does not block a real T3 set sitting in the bag.
	if int(_owner.seed_bag.get(type_id, 0)) >= 4:
		return false
	return true


func lock_pour_type(type_id: String) -> void:
	if type_id.is_empty():
		return
	if int(_owner.seed_bag.get(type_id, 0)) >= 4:
		_pour_locked_types.erase(type_id)
		return
	_pour_locked_types[type_id] = true


func unlock_pour_type(type_id: String) -> void:
	if type_id.is_empty():
		return
	_pour_locked_types.erase(type_id)


func clear_pour_locks() -> void:
	_pour_locked_types.clear()


func pull_seeds(max_count: int, _field_type_counts: Dictionary = {}) -> Array:
	var out: Array = []
	max_count = maxi(0, max_count)
	if max_count <= 0:
		return out
	var queue := _build_pour_queue()
	var pulled := 0
	for type_id in queue:
		if pulled >= max_count:
			break
		if not _owner.take_seed_from_bag(type_id):
			continue
		var chip_id := _chip_counter
		_chip_counter += 1
		out.append({"chip_id": chip_id, "type_id": type_id, "tier": 1})
		pulled += 1
	if pulled > 0:
		_owner.save_player_save()
	return out


func _append_pourable_to_queue(queue: Array[String], type_id: String) -> int:
	var n := int(_owner.seed_bag.get(type_id, 0))
	if n < 4:
		return 0
	if is_pour_locked(type_id):
		return 0
	for _i in n:
		queue.append(type_id)
	return n


func _build_pour_queue(_field_type_counts: Dictionary = {}) -> Array[String]:
	var queue: Array[String] = []
	for type_id in SeedCatalog.all_type_ids():
		_append_pourable_to_queue(queue, type_id)
	return queue


func try_merge_chips(chip_a: int, chip_b: int, chip_data: Dictionary) -> Dictionary:
	if chip_a == chip_b:
		return {"ok": false, "msg": "Same chip."}
	if not chip_data.has(chip_a) or not chip_data.has(chip_b):
		return {"ok": false, "msg": "Missing chip."}
	var a: Dictionary = chip_data[chip_a]
	var b: Dictionary = chip_data[chip_b]
	if str(a.get("type_id", "")) != str(b.get("type_id", "")):
		return {"ok": false, "msg": "Different types."}
	var tier := int(a.get("tier", 1))
	if tier != int(b.get("tier", 1)) or tier >= int(_owner.MAX_MERGE_TIER):
		return {"ok": false, "msg": "Cannot merge these tiers."}
	var type_id: String = str(a.get("type_id", ""))
	var new_tier := tier + 1
	_owner.tutorial.notify_merge_completed()
	if new_tier >= int(_owner.MAX_MERGE_TIER):
		var center: Vector2 = (a.get("pos", Vector2.ZERO) + b.get("pos", Vector2.ZERO)) * 0.5
		chip_data.erase(chip_b)
		chip_data[chip_a] = {"chip_id": chip_a, "type_id": type_id, "tier": new_tier, "pos": center}
		_owner.discovered_blooms[type_id] = true
		_owner._mark_collection_journal_new(type_id, new_tier)
		return {"ok": true, "to_inbox": false, "new_tier": new_tier, "crystal": true}
	var center: Vector2 = (a.get("pos", Vector2.ZERO) + b.get("pos", Vector2.ZERO)) * 0.5
	chip_data.erase(chip_b)
	chip_data[chip_a] = {"chip_id": chip_a, "type_id": type_id, "tier": new_tier, "pos": center}
	return {"ok": true, "to_inbox": false, "new_tier": new_tier}


## Resolve one arena leftover chip. Never silently drops T2+ (Bug-016).
## Returns: bagged | crystal | recycled | skipped
func resolve_leftover_bloom(type_id: String, tier: int) -> String:
	if type_id.is_empty():
		return "skipped"
	if tier <= 1:
		_owner.add_seeds_to_bag(type_id, 1)
		return "bagged"
	if tier >= int(_owner.MAX_MERGE_TIER):
		_owner.stash_garden_crystal(type_id)
		return "crystal"
	# FLOW-A — leftover T2 → 2× T1. Arena does not donate/keep.
	if _owner.add_seeds_to_bag(type_id, 2) > 0:
		return "recycled"
	_owner._add_coins(2)
	return "recycled"


func commit_chips_to_bag(chip_data: Dictionary) -> Dictionary:
	var summary := {"bagged": 0, "crystal": 0, "kept": 0, "donated": 0, "recycled": 0}
	for _chip_id in chip_data:
		var entry: Dictionary = chip_data[_chip_id]
		var tier := int(entry.get("tier", 1))
		var type_id := str(entry.get("type_id", ""))
		if type_id.is_empty():
			continue
		var result := resolve_leftover_bloom(type_id, tier)
		if summary.has(result):
			summary[result] = int(summary[result]) + 1
	chip_data.clear()
	_owner.save_player_save()
	return summary
