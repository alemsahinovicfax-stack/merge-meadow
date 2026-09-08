## Season progression domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 4.8). Owned by GameState as `seasons_domain`. Free/paid unlock state,
## star3-flower unlock cost, and home/strip navigation (which season is
## focused/active on the free and paid strips) — the biggest blast radius in
## the refactor (season_stage.gd alone makes 71 GameState.* calls).
##
## debug_unlock_all_seasons()/debug_grant_unlock_test_funds()/
## debug_playtest_two_free()/debug_relock_playtest_free()/
## debug_fixture_s1_star3_playtest()/_remap_seed_bag_to_season() stay on
## GameState — Stage 7 (dev-only isolation) moves those, not this stage; they
## keep working unchanged here since they read/write the season fields via
## GameState's existing property names and call the facade methods below.
##
## get_unlocked_loadout_types_for_season()/get_active_season_spawn_types()/
## is_loadout_in_active_season_pool() also stay on GameState — seed-unlock/
## spawn-pool utility that reads season state, not season-progression state
## itself (same reasoning as crystal_stash.gd leaving pour-priority sort on
## the owner).
##
## Stage 6 naming note: `focus_season_id` was `strip_focus_id` — renamed so
## "Season" stays the one content-noun (plan-arhitektura-refaktor.md Stage 6).
## The save-dict key stays `"strip_focus_id"` in apply_from_save()/
## to_save_dict() on purpose, so existing player saves keep loading.
## `paid_strip_focus_id` is untouched — Stage 6 only names this one field.
class_name SeasonsDomain
extends RefCounted

const TEST_LOCK_LAST_SEASONS := true
const TEST_LOCK_PAID_ID := "ember_fen"

var active_id: String = SeasonCatalog.DEFAULT_SEASON_ID
var focus_season_id: String = SeasonCatalog.DEFAULT_SEASON_ID
var home_band: String = "free"
var paid_strip_focus_id: String = ""
var unlocked: Array[String] = [SeasonCatalog.DEFAULT_SEASON_ID]
var owned_paid: Array[String] = []

var field_open: bool = false
var field_id: String = ""

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func apply_from_save(data: Dictionary) -> void:
	unlocked = SaveDictUtils.parse_string_array(data.get("unlocked_seasons", []))
	owned_paid = SaveDictUtils.parse_string_array(data.get("owned_paid_seasons", []))
	active_id = str(data.get("active_season_id", SeasonCatalog.DEFAULT_SEASON_ID))
	focus_season_id = str(data.get("strip_focus_id", SeasonCatalog.DEFAULT_SEASON_ID))
	home_band = str(data.get("home_band", "free"))
	paid_strip_focus_id = str(data.get("paid_strip_focus_id", ""))


func to_save_dict() -> Dictionary:
	return {
		"active_season_id": active_id,
		"strip_focus_id": focus_season_id,
		"home_band": home_band,
		"paid_strip_focus_id": paid_strip_focus_id,
		"unlocked_seasons": unlocked.duplicate(),
		"owned_paid_seasons": owned_paid.duplicate(),
	}


func star3_type_ids_for_season(season_id: String) -> Array[String]:
	var out: Array[String] = []
	var def := SeasonCatalog.get_def(season_id)
	if def == null:
		return out
	for type_id in def.seed_type_ids:
		if type_id.is_empty():
			continue
		if _owner.get_seed_rarity(type_id) < 3:
			continue
		if not out.has(type_id):
			out.append(type_id)
	return out


func star3_type_id_for_season(season_id: String) -> String:
	var ids := star3_type_ids_for_season(season_id)
	if ids.size() != 1:
		push_error(
			"star3_type_id_for_season(%s) expected 1 rarity-3, got %d"
			% [season_id, ids.size()]
		)
		return str(ids[0]) if not ids.is_empty() else ""
	return ids[0]


func star3_flower_count_for_season(season_id: String) -> int:
	var type_id := star3_type_id_for_season(season_id)
	if type_id.is_empty():
		return 0
	return maxi(0, int(_owner.garden_crystal_stash.get(type_id, 0)))


func previous_free_id_for(season_id: String) -> String:
	return SeasonCatalog.previous_free_id(SeasonCatalog.get_def(season_id))


func star3_flower_count_for_unlock(season_id: String) -> int:
	var prev := previous_free_id_for(season_id)
	if prev.is_empty():
		return 0
	return star3_flower_count_for_season(prev)


func spend_star3_flowers_for_unlock(season_id: String, amount: int) -> void:
	if amount <= 0:
		return
	var prev := previous_free_id_for(season_id)
	var left := amount
	for type_id in star3_type_ids_for_season(prev):
		if left <= 0:
			break
		var have := maxi(0, int(_owner.garden_crystal_stash.get(type_id, 0)))
		if have <= 0:
			continue
		var take := mini(have, left)
		var remain := have - take
		if remain <= 0:
			_owner.garden_crystal_stash.erase(type_id)
		else:
			_owner.garden_crystal_stash[type_id] = remain
		left -= take


func get_def(season_id: String) -> SeasonDef:
	return SeasonCatalog.get_def(season_id)


func is_unlocked_free(season_id: String) -> bool:
	return unlocked.has(season_id)


func is_test_locked(season_id: String) -> bool:
	if not TEST_LOCK_LAST_SEASONS or season_id.is_empty():
		return false
	return season_id == TEST_LOCK_PAID_ID


func is_playable(season_id: String) -> bool:
	if is_test_locked(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	if def == null:
		return false
	if def.is_free():
		return unlocked.has(season_id)
	return owned_paid.has(season_id)


func is_free_selectable(season_id: String) -> bool:
	if is_playable(season_id):
		return true
	if is_test_locked(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_free():
		return false
	return season_id == next_locked_free_id()


func can_unlock_free(season_id: String) -> bool:
	if is_test_locked(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_free():
		return false
	if unlocked.has(season_id):
		return false
	var prev_id := SeasonCatalog.previous_free_id(def)
	if not prev_id.is_empty() and not unlocked.has(prev_id):
		return false
	if _owner.wallet_coins < def.coins_cost:
		return false
	if star3_flower_count_for_unlock(season_id) < def.t3_flowers_required:
		return false
	return true


func unlock_free(season_id: String) -> bool:
	if not can_unlock_free(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	_owner._try_spend_coins(def.coins_cost)
	spend_star3_flowers_for_unlock(season_id, def.t3_flowers_required)
	unlocked.append(season_id)
	active_id = season_id
	focus_season_id = season_id
	_owner.save_player_save()
	return true


func set_active(season_id: String, sync_strip: bool = true) -> bool:
	if not is_playable(season_id):
		return false
	active_id = season_id
	if sync_strip:
		var def := SeasonCatalog.get_def(season_id)
		if def != null and def.is_free():
			focus_season_id = season_id
		elif def != null and def.is_paid():
			paid_strip_focus_id = season_id
	_owner.save_player_save()
	return true


func grant_paid(season_id: String) -> bool:
	if is_test_locked(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_paid():
		return false
	if not owned_paid.has(season_id):
		owned_paid.append(season_id)
	active_id = season_id
	paid_strip_focus_id = season_id
	_owner.save_player_save()
	return true


func list_playable_ids() -> Array[String]:
	var out: Array[String] = []
	for def in SeasonCatalog.free_defs_sorted():
		if is_playable(def.id):
			out.append(def.id)
	for def in SeasonCatalog.paid_defs():
		if is_playable(def.id):
			out.append(def.id)
	return out


func next_locked_free_id() -> String:
	for def in SeasonCatalog.free_defs_sorted():
		if not unlocked.has(def.id):
			return def.id
	return ""


func reset_to_s1() -> void:
	active_id = SeasonCatalog.DEFAULT_SEASON_ID
	focus_season_id = SeasonCatalog.DEFAULT_SEASON_ID
	home_band = "free"
	field_open = false
	field_id = ""
	paid_strip_focus_id = ""
	unlocked.clear()
	unlocked.append(SeasonCatalog.DEFAULT_SEASON_ID)
	owned_paid.clear()
	normalize_progress()


func clear_owned_paid() -> void:
	owned_paid.clear()
	normalize_progress()


func normalize_progress() -> void:
	var default_id := SeasonCatalog.DEFAULT_SEASON_ID
	if not unlocked.has(default_id):
		unlocked.insert(0, default_id)
	var cleaned_free: Array[String] = []
	for sid in unlocked:
		var def := SeasonCatalog.get_def(sid)
		if def != null and def.is_free() and not cleaned_free.has(sid):
			cleaned_free.append(sid)
	if cleaned_free.is_empty():
		cleaned_free.append(default_id)
	unlocked = cleaned_free
	var cleaned_paid: Array[String] = []
	for sid in owned_paid:
		var def := SeasonCatalog.get_def(sid)
		if def != null and def.is_paid() and not cleaned_paid.has(sid):
			cleaned_paid.append(sid)
	owned_paid = cleaned_paid
	if not is_playable(active_id):
		active_id = default_id
	var strip_def := SeasonCatalog.get_def(focus_season_id)
	if strip_def == null or not strip_def.is_free() or not is_free_selectable(focus_season_id):
		focus_season_id = _highest_unlocked_free_id()
	if home_band != "free" and home_band != "paid":
		home_band = "free"
	var paid_ok := false
	for paid_def in SeasonCatalog.paid_defs():
		if paid_def.id == paid_strip_focus_id:
			paid_ok = true
			break
	if not paid_ok:
		paid_strip_focus_id = _first_paid_id()


func highest_unlocked_free_id() -> String:
	return _highest_unlocked_free_id()


func last_playable_for_home_select() -> String:
	if home_band == "paid":
		var best := ""
		for def in SeasonCatalog.paid_defs():
			if is_playable(def.id):
				best = def.id
		if not best.is_empty():
			return best
	return _highest_unlocked_free_id()


func _highest_unlocked_free_id() -> String:
	var best := SeasonCatalog.DEFAULT_SEASON_ID
	var best_order := -1
	for def in SeasonCatalog.free_defs_sorted():
		if is_playable(def.id) and def.order >= best_order:
			best = def.id
			best_order = def.order
	return best


func _first_paid_id() -> String:
	var paid_list := SeasonCatalog.paid_defs()
	if paid_list.is_empty():
		return ""
	return paid_list[0].id


func home_hero_center_id() -> String:
	if home_band == "paid":
		return paid_strip_focus_id
	return focus_season_id


func can_open_home_season_field() -> bool:
	return is_playable(home_hero_center_id())


func open_home_season_field() -> bool:
	if not can_open_home_season_field():
		return false
	var id := home_hero_center_id()
	field_open = true
	field_id = id
	set_active(id)
	return true


func close_home_season_field() -> void:
	field_open = false
	field_id = ""


func set_home_band(band: String) -> void:
	home_band = "paid" if band == "paid" else "free"
	_owner.save_player_save()


func set_paid_strip_focus(season_id: String) -> bool:
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_paid():
		return false
	paid_strip_focus_id = season_id
	_owner.save_player_save()
	return true


func set_free_strip_focus(season_id: String) -> bool:
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_free():
		return false
	if not is_free_selectable(season_id):
		return false
	focus_season_id = season_id
	_owner.save_player_save()
	return true


func strip_center_id() -> String:
	return focus_season_id


func strip_left_id() -> String:
	var idx := _strip_focus_index()
	if idx <= 0:
		return ""
	return SeasonCatalog.free_defs_sorted()[idx - 1].id


func strip_right_id() -> String:
	var free_list := SeasonCatalog.free_defs_sorted()
	var idx := _strip_focus_index()
	if idx < 0 or idx >= free_list.size() - 1:
		return ""
	return free_list[idx + 1].id


func is_strip_right_locked() -> bool:
	var right_id := strip_right_id()
	if right_id.is_empty():
		return false
	return not is_playable(right_id)


func cycle_free_strip(dir: int) -> bool:
	if dir == 0:
		return false
	var free_list := SeasonCatalog.free_defs_sorted()
	var idx := _strip_focus_index()
	if idx < 0:
		return false
	var next_idx := idx + dir
	if next_idx < 0 or next_idx >= free_list.size():
		return false
	var next_id := free_list[next_idx].id
	if not is_free_selectable(next_id):
		return false
	if is_playable(next_id):
		return set_active(next_id)
	return set_free_strip_focus(next_id)


func paid_center_id() -> String:
	return paid_strip_focus_id


func paid_left_id() -> String:
	var idx := _paid_focus_index()
	if idx <= 0:
		return ""
	return SeasonCatalog.paid_defs()[idx - 1].id


func paid_right_id() -> String:
	var paid_list := SeasonCatalog.paid_defs()
	var idx := _paid_focus_index()
	if idx < 0 or idx >= paid_list.size() - 1:
		return ""
	return paid_list[idx + 1].id


func cycle_paid_strip(dir: int) -> bool:
	if dir == 0:
		return false
	var paid_list := SeasonCatalog.paid_defs()
	var idx := _paid_focus_index()
	if idx < 0:
		return false
	var next_idx := idx + dir
	if next_idx < 0 or next_idx >= paid_list.size():
		return false
	var next_id := paid_list[next_idx].id
	paid_strip_focus_id = next_id
	if is_playable(next_id):
		return set_active(next_id)
	_owner.save_player_save()
	return true


func _strip_focus_index() -> int:
	var i := 0
	for def in SeasonCatalog.free_defs_sorted():
		if def.id == focus_season_id:
			return i
		i += 1
	return 0


func _paid_focus_index() -> int:
	var i := 0
	for def in SeasonCatalog.paid_defs():
		if def.id == paid_strip_focus_id:
			return i
		i += 1
	return 0
