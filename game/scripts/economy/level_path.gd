## Level Path domain (design_handoff_level_path). Owned by GameState as `level_path_domain`.
## Napredak je po sezoni: level 1…20 je kamen na kojem Pip stoji, 21 = put završen
## („complete": Play ponovo igra level 20, nagrade se ne daju ponovo). Nagrade na 5 / 10 /
## 15 / 20 se ne daju same — kad je level pređen, sanduk čeka tap i Claim (claim()).
##
## Save: "season_levels" {id: 1…21} i "season_level_rewards" {id: [5, 10, …]}. Stari save
## ima samo globalni "run_level": prelazi na sezonu u kojoj se igralo (active_season_id),
## ograničen na 21 — pređeni nagradni leveli tada čekaju Claim (odluka 2026-10-20).
## Težina: level N iste je težine u svakoj sezoni (RunLevelLibrary.get_level(N)).
class_name LevelPathDomain
extends RefCounted

const LEVELS := 20
const COMPLETE := LEVELS + 1
const REWARD_LEVELS: Array[int] = [5, 10, 15, 20]
## [★3 cvjetova sezone, coina]
const REWARDS := {5: [2, 200], 10: [4, 400], 15: [6, 600], 20: [10, 1000]}

const STATE_DONE := "done"
const STATE_CURRENT := "current"
const STATE_LOCKED := "locked"
const REWARD_LOCKED := "reward_locked"
const REWARD_READY := "reward_ready"
const REWARD_CLAIMED := "reward_claimed"

var levels: Dictionary = {}
var claimed: Dictionary = {}

var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func apply_from_save(data: Dictionary) -> void:
	levels.clear()
	claimed.clear()
	var raw_levels: Variant = data.get("season_levels", null)
	if raw_levels is Dictionary:
		for id in raw_levels:
			levels[str(id)] = clampi(int(raw_levels[id]), 1, COMPLETE)
	elif data.has("run_level"):
		var old := int(data.get("run_level", 1))
		var sid := str(data.get("active_season_id", SeasonCatalog.DEFAULT_SEASON_ID))
		if old > 1 and not sid.is_empty():
			levels[sid] = clampi(old, 1, COMPLETE)
	var raw_claimed: Variant = data.get("season_level_rewards", {})
	if raw_claimed is Dictionary:
		for id in raw_claimed:
			var list: Array[int] = []
			if raw_claimed[id] is Array:
				for n in raw_claimed[id]:
					var v := int(n)
					if REWARDS.has(v) and not list.has(v):
						list.append(v)
			list.sort()
			claimed[str(id)] = list


func to_save_dict() -> Dictionary:
	var out_claimed := {}
	for id in claimed:
		out_claimed[id] = (claimed[id] as Array).duplicate()
	return {"season_levels": levels.duplicate(), "season_level_rewards": out_claimed}


func reset() -> void:
	levels.clear()
	claimed.clear()


## 1…20, ili 21 kad je put završen.
func level_of(season_id: String) -> int:
	return clampi(int(levels.get(season_id, 1)), 1, COMPLETE)


## Level koji Play igra (complete → ponovo 20).
func play_level_of(season_id: String) -> int:
	return mini(level_of(season_id), LEVELS)


func is_complete(season_id: String) -> bool:
	return level_of(season_id) >= COMPLETE


func set_level(season_id: String, level: int) -> void:
	if season_id.is_empty():
		return
	levels[season_id] = clampi(level, 1, COMPLETE)


## Uspješan kampanjski run: Pip ide na sljedeći kamen. Vraća [from, to] ili [] (već complete).
func advance(season_id: String) -> Array:
	var from := level_of(season_id)
	if from >= COMPLETE:
		return []
	set_level(season_id, from + 1)
	return [from, from + 1]


func claimed_of(season_id: String) -> Array[int]:
	var out: Array[int] = []
	for n in claimed.get(season_id, []):
		out.append(int(n))
	return out


static func cp_state(n: int, level: int) -> String:
	if n < level:
		return STATE_DONE
	if n == level:
		return STATE_CURRENT
	return STATE_LOCKED


static func reward_state_for(n: int, level: int, taken: Array) -> String:
	if n >= level:
		return REWARD_LOCKED
	return REWARD_CLAIMED if taken.has(n) else REWARD_READY


func reward_state(season_id: String, n: int) -> String:
	return reward_state_for(n, level_of(season_id), claimed_of(season_id))


func ready_list(season_id: String) -> Array[int]:
	var out: Array[int] = []
	for n in REWARD_LEVELS:
		if reward_state(season_id, n) == REWARD_READY:
			out.append(n)
	return out


func has_ready(season_id: String) -> bool:
	return not ready_list(season_id).is_empty()


## Nagrada N: ★3 cvijet sezone (stash + Album) i coini. Vraća {flower, flowers, coins} ili {}.
func claim(season_id: String, n: int) -> Dictionary:
	if reward_state(season_id, n) != REWARD_READY:
		return {}
	var r: Array = REWARDS[n]
	var flower: String = _owner.star3_type_id_for_season(season_id)
	var list := claimed_of(season_id)
	list.append(n)
	list.sort()
	claimed[season_id] = list
	if not flower.is_empty():
		_owner.crystal_stash_domain.add_many(flower, int(r[0]))
		_owner.record_star3_in_album(flower)
	_owner._add_coins(int(r[1]))
	return {"flower": flower, "flowers": int(r[0]) if not flower.is_empty() else 0, "coins": int(r[1])}
