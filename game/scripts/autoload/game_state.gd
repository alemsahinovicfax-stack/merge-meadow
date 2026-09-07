extends Node

const SCENE_MAIN := "res://scenes/main_menu.tscn"
const SCENE_META_HUB := "res://scenes/meta/meta_hub.tscn"
const SCENE_RUN := "res://scenes/run/run_scene.tscn"
const SCENE_LOOT := "res://scenes/ui/loot_screen.tscn"
const SCENE_CAMP := "res://scenes/camp/camp_scene.tscn"
const SCENE_MERGE_ARENA := "res://scenes/camp/merge_arena.tscn"
const SCENE_SHOP := "res://scenes/ui/shop_screen.tscn"
const SCENE_COLLECTION := "res://scenes/ui/collection_journal.tscn"

const ARENA_MAX_CHIPS := 40
const ARENA_SNAP_DISTANCE := 100.0
const ARENA_MAGNET_RADIUS := 130.0
const ARENA_COMBO_COINS := 2
const ARENA_COMBO_COIN_DAILY_CAP := 10
const BLOOM_INBOX_MAX := 12

const ARENA_PEST_SPEED := 85.0
const ARENA_PEST_EAT_RADIUS := 36.0
const ARENA_PEST_EAT_DURATION := 0.5
const ARENA_PEST_T3_FREEZE := 2.0
const ARENA_PEST_WAKE_DELAY := 0.3
const ARENA_PEST_TARGET_REEVAL := 0.25

const CAMP_BED_COUNT := 9
const CAMP_BED_BONUS := 3
const GREENHOUSE_SLOT_COUNT := 2
const SEED_BAG_SOFT_CAP := 40
const DAILY_CHEST_COINS := 8
const DAILY_CHEST_SEEDS := 3
const MAX_MERGE_TIER := 3
const MAGNET_MAX_LEVEL := 4
const MAGNET_COST_T2 := 2
const MULTIPLIER_MAX_LEVEL := 4
const MULTIPLIER_COST_T3 := 2
const UPGRADE_FLOWER_COST := 2
const MULTIPLIER_VALUES: Array[float] = [1.0, 1.25, 1.5, 1.75, 2.0]
const MYTHIC_RARITY := 3

const EXCHANGE_SEED_COUNT := 3
## Coins per seed traded, keyed by rarity ★1–3 (Bug-031).
const SEED_EXCHANGE_COINS_BY_RARITY := {1: 1, 2: 2, 3: 4}
## Coins per crystal/flower traded, keyed by rarity ★1–3.
const CRYSTAL_EXCHANGE_COINS_BY_RARITY := {1: 5, 2: 10, 3: 20}

const SEED_TYPE_CLOVER := "clover"

const SEED_DISPLAY_NAMES: Dictionary = {
	SEED_TYPE_CLOVER: "Clover",
	"daisy": "Daisy",
	"buttercup": "Buttercup",
	"tulip": "Tulip",
	"sunflower": "Sunflower",
	"pumpkin": "Pumpkin",
}

# Default spawn rarity (★ count). Mythic (3) → staklenik.
const SEED_RARITY: Dictionary = {
	SEED_TYPE_CLOVER: 1,
	"daisy": 1,
	"buttercup": 1,
	"tulip": 2,
	"sunflower": 2,
	"pumpkin": 3,
}

const MAGNET_BASE_RADIUS := 40.0
const MAGNET_RADIUS_PER_LEVEL := 48.0

const LOADOUT_SLOT_COUNT := 1
const LOADOUT_SPAWN_BONUS := 0.05

const COMPANION_PIP := "pip"
const COMPANION_MOCHI := "mochi"
const MOCHI_UNLOCK_CAMP_LEVEL := 2

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

const TUTORIAL_RUN1_DURATION := 45.0
const TUTORIAL_RUN2_DURATION := 60.0
const POST_TUTORIAL_RUN_DURATION := 60.0

enum TutorialStep { RUN1, CAMP1, RUN2, CAMP_MERGE, FREE }

enum EndlessDifficulty { EASY, NORMAL, HARD }

const ENDLESS_DIFFICULTY_LABELS: Dictionary = {
	EndlessDifficulty.EASY: "Easy",
	EndlessDifficulty.NORMAL: "Normal",
	EndlessDifficulty.HARD: "Hard",
}

const TUTORIAL_FLAGS_PATH := "user://tutorial_flags.json"
const PLAYER_SAVE_PATH := "user://player_save.json"
const SAVE_VERSION := 12
const RETIRED_SEED_TYPE_IDS: Array[String] = ["watermelon"]
## HOME-06 P80 / HOME-09 P105 — last paid stays locked for IAP playtest.
const TEST_LOCK_LAST_SEASONS := true
const TEST_LOCK_PAID_ID := "ember_fen"
## HOME-07 P84 + HOME-09 P111 — debug skip so a free next-lock remains; can_unlock_free still works.
const DEBUG_SKIP_FREE_ID := "lantern_meadow"
const DEBUG_SKIP_AMBER_ID := "amber_canopy"

var last_seed_bag: Dictionary = {}
var last_run_coins: int = 0
var last_raw_coins: int = 0
var last_loot: int = 0
var wallet_coins: int = 0
var wallet_diamonds: int = 0
var last_failed: bool = false
var last_raw_seed_total: int = 0
var loot_doubled: bool = false
var revive_used_this_run: bool = false

var seed_bag: Dictionary = {}
var _debug_leftover_bag_applied: bool = false

var resume_pending: bool = false
var carry_seed_bag: Dictionary = {}
var carry_coins: int = 0
var carry_elapsed: float = 0.0
var carry_orbs: int = 0
var carry_seeds: int = 0

# null = prazno; inače { type_id, tier }
var garden_beds: Array = []
var greenhouse_beds: Array = []
var garden_crystal_stash: Dictionary = {}
var owned_cosmetics: Dictionary = {}
var equipped_cosmetics: Dictionary = {}
var booster_inventory: Dictionary = {}
var merge_hint_booster_active: bool = false

var magnet_level: int = 0
var sprinkler_donations: int = 0
var multiplier_level: int = 0
var multiplier_donations: int = 0
var discovered_blooms: Dictionary = {}
var tutorial_step: int = TutorialStep.RUN1
var tutorial_complete: bool = false
var ads_removed: bool = false
var starter_pack_owned: bool = false
var run_level: int = 1
var endless_runs_completed: int = 0
var endless_difficulty: int = EndlessDifficulty.NORMAL
var run_is_endless: bool = false

# Jedan slot: type_id iz baga → +LOADOUT_SPAWN_BONUS šanse za sjeme u runu.
var loadout_type_id: String = ""

# Najviši indeks u SeedUnlockConfig.CHAIN koji je otključen (0 = samo Clover).
var seed_unlock_index: int = 0
var lifetime_seeds_collected: Dictionary = {}
var collection_kept_tiers: Dictionary = {}
var last_daily_chest_day: String = ""
var combo_coin_day: String = ""
var combo_coins_granted_today: int = 0
var arena_daily_day: String = ""
var arena_daily_kind: String = ""
var arena_daily_progress: int = 0
var arena_daily_goal: int = 1
var arena_daily_claimed_day: String = ""
var arena_daily_streak: int = 0
var active_companion_id: String = COMPANION_PIP
var mochi_unlock_seen: bool = false
var collection_journal_pending: Dictionary = {}
var bloom_inbox: Array = []
var _arena_chip_counter: int = 1
var _arena_pour_locked_types: Dictionary = {}

var meta_hub_active: bool = false
var meta_hub_pending_page: int = MetaHubPages.MAIN
var arena_pest_tutorial_shown: bool = false
var active_season_id: String = SeasonCatalog.DEFAULT_SEASON_ID
var strip_focus_id: String = SeasonCatalog.DEFAULT_SEASON_ID
var home_band: String = "free"
var home_season_field_open: bool = false
var home_season_field_id: String = ""
var paid_strip_focus_id: String = ""
var unlocked_seasons: Array[String] = [SeasonCatalog.DEFAULT_SEASON_ID]
var owned_paid_seasons: Array[String] = []
var skip_debug_season_unlock: bool = false


func _ready() -> void:
	# Desktop dev: miš mora ostati miš (emulacija toucha lomi BaseButton.signale).
	Input.emulate_touch_from_mouse = false
	if not load_player_save():
		reset_garden_beds()
		reset_greenhouse_beds()
		_try_migrate_tutorial_flags_only()
		_apply_debug_resources_if_new_game()
		_normalize_season_progress()
	else:
		apply_debug_leftover_test_bag()


func load_player_save() -> bool:
	if not FileAccess.file_exists(PLAYER_SAVE_PATH):
		return false
	var file := FileAccess.open(PLAYER_SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	return _apply_save_dict(parsed)


func save_player_save() -> void:
	var data := {
		"version": SAVE_VERSION,
		"tutorial_complete": tutorial_complete,
		"tutorial_step": tutorial_step,
		"wallet_coins": wallet_coins,
		"wallet_diamonds": wallet_diamonds,
		"seed_bag": seed_bag.duplicate(),
		"magnet_level": magnet_level,
		"sprinkler_donations": sprinkler_donations,
		"multiplier_level": multiplier_level,
		"multiplier_donations": multiplier_donations,
		"loadout_type_id": loadout_type_id,
		"discovered_blooms": discovered_blooms.duplicate(),
		"garden_beds": _serialize_beds(garden_beds),
		"greenhouse_beds": _serialize_beds(greenhouse_beds),
		"garden_crystal_stash": garden_crystal_stash.duplicate(),
		"owned_cosmetics": owned_cosmetics.duplicate(),
		"equipped_cosmetics": equipped_cosmetics.duplicate(),
		"booster_inventory": booster_inventory.duplicate(),
		"ads_removed": ads_removed,
		"starter_pack_owned": starter_pack_owned,
		"run_level": run_level,
		"endless_runs_completed": endless_runs_completed,
		"endless_difficulty": endless_difficulty,
		"seed_unlock_index": seed_unlock_index,
		"lifetime_seeds_collected": lifetime_seeds_collected.duplicate(),
		"collection_kept_tiers": collection_kept_tiers.duplicate(),
		"last_daily_chest_day": last_daily_chest_day,
		"combo_coin_day": combo_coin_day,
		"combo_coins_granted_today": combo_coins_granted_today,
		"arena_daily_day": arena_daily_day,
		"arena_daily_kind": arena_daily_kind,
		"arena_daily_progress": arena_daily_progress,
		"arena_daily_goal": arena_daily_goal,
		"arena_daily_claimed_day": arena_daily_claimed_day,
		"arena_daily_streak": arena_daily_streak,
		"active_companion_id": active_companion_id,
		"mochi_unlock_seen": mochi_unlock_seen,
		"collection_journal_pending": collection_journal_pending.duplicate(),
		"bloom_inbox": bloom_inbox.duplicate(true),
		"arena_pest_tutorial_shown": arena_pest_tutorial_shown,
		"active_season_id": active_season_id,
		"strip_focus_id": strip_focus_id,
		"home_band": home_band,
		"paid_strip_focus_id": paid_strip_focus_id,
		"unlocked_seasons": unlocked_seasons.duplicate(),
		"owned_paid_seasons": owned_paid_seasons.duplicate(),
	}
	var file := FileAccess.open(PLAYER_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GameState: could not write %s" % PLAYER_SAVE_PATH)
		return
	file.store_string(JSON.stringify(data))


func t3_flower_count() -> int:
	return get_garden_crystal_total()


func star3_type_ids_for_season(season_id: String) -> Array[String]:
	var out: Array[String] = []
	var def := SeasonCatalog.get_def(season_id)
	if def == null:
		return out
	for type_id in def.seed_type_ids:
		if type_id.is_empty():
			continue
		if get_seed_rarity(type_id) < 3:
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
	return maxi(0, int(garden_crystal_stash.get(type_id, 0)))


func previous_free_id_for(season_id: String) -> String:
	return SeasonCatalog.previous_free_id(SeasonCatalog.get_def(season_id))


func star3_flower_count_for_unlock(season_id: String) -> int:
	var prev := previous_free_id_for(season_id)
	if prev.is_empty():
		return 0
	return star3_flower_count_for_season(prev)


func _spend_star3_flowers_for_unlock(season_id: String, amount: int) -> void:
	if amount <= 0:
		return
	var prev := previous_free_id_for(season_id)
	var left := amount
	for type_id in star3_type_ids_for_season(prev):
		if left <= 0:
			break
		var have := maxi(0, int(garden_crystal_stash.get(type_id, 0)))
		if have <= 0:
			continue
		var take := mini(have, left)
		var remain := have - take
		if remain <= 0:
			garden_crystal_stash.erase(type_id)
		else:
			garden_crystal_stash[type_id] = remain
		left -= take


func get_season_def(season_id: String) -> SeasonDef:
	return SeasonCatalog.get_def(season_id)


func is_season_unlocked_free(season_id: String) -> bool:
	return unlocked_seasons.has(season_id)


func is_test_locked_season(season_id: String) -> bool:
	if not TEST_LOCK_LAST_SEASONS or season_id.is_empty():
		return false
	return season_id == TEST_LOCK_PAID_ID


func is_season_playable(season_id: String) -> bool:
	if is_test_locked_season(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	if def == null:
		return false
	if def.is_free():
		return unlocked_seasons.has(season_id)
	return owned_paid_seasons.has(season_id)


func is_free_selectable(season_id: String) -> bool:
	if is_season_playable(season_id):
		return true
	if is_test_locked_season(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_free():
		return false
	return season_id == next_locked_free_id()


func can_unlock_free(season_id: String) -> bool:
	if is_test_locked_season(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_free():
		return false
	if unlocked_seasons.has(season_id):
		return false
	var prev_id := SeasonCatalog.previous_free_id(def)
	if not prev_id.is_empty() and not unlocked_seasons.has(prev_id):
		return false
	if wallet_coins < def.coins_cost:
		return false
	if star3_flower_count_for_unlock(season_id) < def.t3_flowers_required:
		return false
	return true


func unlock_free(season_id: String) -> bool:
	if not can_unlock_free(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	_try_spend_coins(def.coins_cost)
	_spend_star3_flowers_for_unlock(season_id, def.t3_flowers_required)
	unlocked_seasons.append(season_id)
	active_season_id = season_id
	strip_focus_id = season_id
	save_player_save()
	return true


func set_active_season(season_id: String, sync_strip: bool = true) -> bool:
	if not is_season_playable(season_id):
		return false
	active_season_id = season_id
	if sync_strip:
		var def := SeasonCatalog.get_def(season_id)
		if def != null and def.is_free():
			strip_focus_id = season_id
		elif def != null and def.is_paid():
			paid_strip_focus_id = season_id
	save_player_save()
	return true


func grant_paid_season(season_id: String) -> bool:
	if is_test_locked_season(season_id):
		return false
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_paid():
		return false
	if not owned_paid_seasons.has(season_id):
		owned_paid_seasons.append(season_id)
	active_season_id = season_id
	paid_strip_focus_id = season_id
	save_player_save()
	return true


func list_playable_season_ids() -> Array[String]:
	var out: Array[String] = []
	for def in SeasonCatalog.free_defs_sorted():
		if is_season_playable(def.id):
			out.append(def.id)
	for def in SeasonCatalog.paid_defs():
		if is_season_playable(def.id):
			out.append(def.id)
	return out


func next_locked_free_id() -> String:
	for def in SeasonCatalog.free_defs_sorted():
		if not unlocked_seasons.has(def.id):
			return def.id
	return ""


func reset_seasons_to_s1() -> void:
	active_season_id = SeasonCatalog.DEFAULT_SEASON_ID
	strip_focus_id = SeasonCatalog.DEFAULT_SEASON_ID
	home_band = "free"
	home_season_field_open = false
	home_season_field_id = ""
	paid_strip_focus_id = ""
	unlocked_seasons.clear()
	unlocked_seasons.append(SeasonCatalog.DEFAULT_SEASON_ID)
	owned_paid_seasons.clear()
	_normalize_season_progress()


func clear_owned_paid_seasons() -> void:
	owned_paid_seasons.clear()
	_normalize_season_progress()


func _normalize_season_progress() -> void:
	var default_id := SeasonCatalog.DEFAULT_SEASON_ID
	if not unlocked_seasons.has(default_id):
		unlocked_seasons.insert(0, default_id)
	var cleaned_free: Array[String] = []
	for sid in unlocked_seasons:
		var def := SeasonCatalog.get_def(sid)
		if def != null and def.is_free() and not cleaned_free.has(sid):
			cleaned_free.append(sid)
	if cleaned_free.is_empty():
		cleaned_free.append(default_id)
	unlocked_seasons = cleaned_free
	var cleaned_paid: Array[String] = []
	for sid in owned_paid_seasons:
		var def := SeasonCatalog.get_def(sid)
		if def != null and def.is_paid() and not cleaned_paid.has(sid):
			cleaned_paid.append(sid)
	owned_paid_seasons = cleaned_paid
	if not is_season_playable(active_season_id):
		active_season_id = default_id
	var strip_def := SeasonCatalog.get_def(strip_focus_id)
	if strip_def == null or not strip_def.is_free() or not is_free_selectable(strip_focus_id):
		strip_focus_id = _highest_unlocked_free_id()
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
			if is_season_playable(def.id):
				best = def.id
		if not best.is_empty():
			return best
	return _highest_unlocked_free_id()


func _highest_unlocked_free_id() -> String:
	var best := SeasonCatalog.DEFAULT_SEASON_ID
	var best_order := -1
	for def in SeasonCatalog.free_defs_sorted():
		if is_season_playable(def.id) and def.order >= best_order:
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
	return strip_focus_id


func can_open_home_season_field() -> bool:
	return is_season_playable(home_hero_center_id())


func open_home_season_field() -> bool:
	if not can_open_home_season_field():
		return false
	var id := home_hero_center_id()
	home_season_field_open = true
	home_season_field_id = id
	set_active_season(id)
	return true


func close_home_season_field() -> void:
	home_season_field_open = false
	home_season_field_id = ""


func set_home_band(band: String) -> void:
	home_band = "paid" if band == "paid" else "free"
	save_player_save()


func set_paid_strip_focus(season_id: String) -> bool:
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_paid():
		return false
	paid_strip_focus_id = season_id
	save_player_save()
	return true


func set_free_strip_focus(season_id: String) -> bool:
	var def := SeasonCatalog.get_def(season_id)
	if def == null or not def.is_free():
		return false
	if not is_free_selectable(season_id):
		return false
	strip_focus_id = season_id
	save_player_save()
	return true


func strip_center_id() -> String:
	return strip_focus_id


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
	return not is_season_playable(right_id)


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
	if is_season_playable(next_id):
		return set_active_season(next_id)
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
	if is_season_playable(next_id):
		return set_active_season(next_id)
	save_player_save()
	return true


func debug_unlock_all_seasons() -> void:
	if not OS.is_debug_build():
		return
	for def in SeasonCatalog.free_defs_sorted():
		if (
			is_test_locked_season(def.id)
			or def.id == DEBUG_SKIP_FREE_ID
			or def.id == DEBUG_SKIP_AMBER_ID
		):
			continue
		if not unlocked_seasons.has(def.id):
			unlocked_seasons.append(def.id)
	for def in SeasonCatalog.paid_defs():
		if is_test_locked_season(def.id):
			continue
		if not owned_paid_seasons.has(def.id):
			owned_paid_seasons.append(def.id)
	var s2 := "frost_orchard"
	if unlocked_seasons.has(s2):
		strip_focus_id = s2
		active_season_id = s2
	else:
		strip_focus_id = SeasonCatalog.DEFAULT_SEASON_ID
		active_season_id = SeasonCatalog.DEFAULT_SEASON_ID
	_normalize_season_progress()
	save_player_save()


func debug_grant_unlock_test_funds() -> void:
	if not OS.is_debug_build():
		return
	wallet_coins = maxi(wallet_coins, 500)
	var next_id := next_locked_free_id()
	if next_id.is_empty():
		save_player_save()
		return
	var def := SeasonCatalog.get_def(next_id)
	var need := 20
	if def != null:
		need = def.t3_flowers_required
	var have := star3_flower_count_for_unlock(next_id)
	if have < need:
		var types := star3_type_ids_for_season(previous_free_id_for(next_id))
		var fill_id := "pumpkin"
		if not types.is_empty():
			fill_id = types[0]
			if types.has("pumpkin"):
				fill_id = "pumpkin"
		garden_crystal_stash[fill_id] = int(garden_crystal_stash.get(fill_id, 0)) + (need - have)
	save_player_save()


func debug_playtest_two_free() -> void:
	if not OS.is_debug_build():
		return
	unlocked_seasons.clear()
	unlocked_seasons.append(SeasonCatalog.DEFAULT_SEASON_ID)
	if not unlocked_seasons.has("frost_orchard"):
		unlocked_seasons.append("frost_orchard")
	owned_paid_seasons.clear()
	if is_season_playable("frost_orchard"):
		strip_focus_id = "frost_orchard"
		active_season_id = "frost_orchard"
	else:
		strip_focus_id = SeasonCatalog.DEFAULT_SEASON_ID
		active_season_id = SeasonCatalog.DEFAULT_SEASON_ID
	_normalize_season_progress()
	save_player_save()


func debug_relock_playtest_free() -> void:
	if not OS.is_debug_build():
		return
	var kept: Array[String] = []
	for sid in unlocked_seasons:
		var id := str(sid)
		if id == DEBUG_SKIP_FREE_ID or id == DEBUG_SKIP_AMBER_ID:
			continue
		if not kept.has(id):
			kept.append(id)
	if not kept.has(SeasonCatalog.DEFAULT_SEASON_ID):
		kept.insert(0, SeasonCatalog.DEFAULT_SEASON_ID)
	if not kept.has("frost_orchard"):
		kept.append("frost_orchard")
	unlocked_seasons.clear()
	for id in kept:
		unlocked_seasons.append(id)
	if is_season_playable("frost_orchard"):
		strip_focus_id = "frost_orchard"
		active_season_id = "frost_orchard"
	else:
		strip_focus_id = SeasonCatalog.DEFAULT_SEASON_ID
		active_season_id = SeasonCatalog.DEFAULT_SEASON_ID
	_normalize_season_progress()
	save_player_save()


func debug_fixture_s1_star3_playtest() -> void:
	if not OS.is_debug_build():
		return
	var default_id := SeasonCatalog.DEFAULT_SEASON_ID
	unlocked_seasons.clear()
	unlocked_seasons.append(default_id)
	active_season_id = default_id
	strip_focus_id = default_id
	home_band = "free"
	home_season_field_open = false
	home_season_field_id = ""
	_normalize_season_progress()
	wallet_coins = maxi(wallet_coins, 500)
	for type_id in star3_type_ids_for_season(default_id):
		garden_crystal_stash.erase(type_id)
	garden_crystal_stash["pumpkin"] = 19
	_remap_seed_bag_to_season(default_id)
	seed_bag["pumpkin"] = 22
	save_player_save()


func _remap_seed_bag_to_season(season_id: String) -> void:
	var allowed := SeedCatalog.types_for_season(season_id)
	if allowed.is_empty():
		return
	var kept: Dictionary = {}
	var overflow: Array[int] = []
	for type_id in seed_bag:
		var n := int(seed_bag[type_id])
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
	seed_bag = kept


func _strip_focus_index() -> int:
	var i := 0
	for def in SeasonCatalog.free_defs_sorted():
		if def.id == strip_focus_id:
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


func _apply_save_dict(data: Dictionary) -> bool:
	var version := int(data.get("version", 0))
	if version < 1:
		return false
	tutorial_complete = bool(data.get("tutorial_complete", false))
	tutorial_step = int(data.get("tutorial_step", TutorialStep.RUN1))
	if tutorial_complete:
		tutorial_step = TutorialStep.FREE
	wallet_coins = maxi(0, int(data.get("wallet_coins", 0)))
	# SAVE_VERSION 8 — older saves default to 0 diamonds.
	wallet_diamonds = maxi(0, int(data.get("wallet_diamonds", 0)))
	seed_bag = _parse_string_int_dict(data.get("seed_bag", {}))
	magnet_level = clampi(int(data.get("magnet_level", 0)), 0, MAGNET_MAX_LEVEL)
	sprinkler_donations = maxi(0, int(data.get("sprinkler_donations", 0)))
	multiplier_level = clampi(int(data.get("multiplier_level", 0)), 0, MULTIPLIER_MAX_LEVEL)
	multiplier_donations = maxi(0, int(data.get("multiplier_donations", 0)))
	loadout_type_id = str(data.get("loadout_type_id", ""))
	discovered_blooms = _parse_string_bool_dict(data.get("discovered_blooms", {}))
	garden_beds = _deserialize_beds(data.get("garden_beds", []), CAMP_BED_COUNT)
	greenhouse_beds = _deserialize_beds(data.get("greenhouse_beds", []), GREENHOUSE_SLOT_COUNT)
	garden_crystal_stash = _parse_string_int_dict(data.get("garden_crystal_stash", {}))
	owned_cosmetics = _parse_string_bool_dict(data.get("owned_cosmetics", {}))
	equipped_cosmetics = _parse_string_string_dict(data.get("equipped_cosmetics", {}))
	booster_inventory = _parse_string_int_dict(data.get("booster_inventory", {}))
	ads_removed = bool(data.get("ads_removed", false))
	starter_pack_owned = bool(data.get("starter_pack_owned", false))
	run_level = clampi(int(data.get("run_level", 1)), 1, RunLevelLibrary.MAX_RUN_LEVEL)
	endless_runs_completed = maxi(0, int(data.get("endless_runs_completed", 0)))
	endless_difficulty = clampi(
		int(data.get("endless_difficulty", EndlessDifficulty.NORMAL)),
		EndlessDifficulty.EASY,
		EndlessDifficulty.HARD,
	)
	seed_unlock_index = clampi(int(data.get("seed_unlock_index", 0)), 0, SeedUnlockConfig.chain_size() - 1)
	lifetime_seeds_collected = _parse_string_int_dict(data.get("lifetime_seeds_collected", {}))
	_drop_retired_seed_keys()
	collection_kept_tiers = _parse_string_int_dict(data.get("collection_kept_tiers", {}))
	last_daily_chest_day = str(data.get("last_daily_chest_day", ""))
	combo_coin_day = str(data.get("combo_coin_day", ""))
	combo_coins_granted_today = maxi(0, int(data.get("combo_coins_granted_today", 0)))
	arena_daily_day = str(data.get("arena_daily_day", ""))
	arena_daily_kind = str(data.get("arena_daily_kind", ""))
	arena_daily_progress = maxi(0, int(data.get("arena_daily_progress", 0)))
	arena_daily_goal = maxi(1, int(data.get("arena_daily_goal", 1)))
	arena_daily_claimed_day = str(data.get("arena_daily_claimed_day", ""))
	arena_daily_streak = maxi(0, int(data.get("arena_daily_streak", 0)))
	active_companion_id = str(data.get("active_companion_id", COMPANION_PIP))
	mochi_unlock_seen = bool(data.get("mochi_unlock_seen", false))
	collection_journal_pending = _parse_string_int_dict(data.get("collection_journal_pending", {}))
	if not is_companion_unlocked(active_companion_id):
		active_companion_id = COMPANION_PIP
	bloom_inbox = _deserialize_bloom_inbox(data.get("bloom_inbox", []))
	arena_pest_tutorial_shown = bool(data.get("arena_pest_tutorial_shown", false))
	unlocked_seasons = _parse_string_array(data.get("unlocked_seasons", []))
	owned_paid_seasons = _parse_string_array(data.get("owned_paid_seasons", []))
	active_season_id = str(data.get("active_season_id", SeasonCatalog.DEFAULT_SEASON_ID))
	strip_focus_id = str(data.get("strip_focus_id", SeasonCatalog.DEFAULT_SEASON_ID))
	home_band = str(data.get("home_band", "free"))
	paid_strip_focus_id = str(data.get("paid_strip_focus_id", ""))
	_normalize_season_progress()
	if int(data.get("version", 0)) < SAVE_VERSION:
		_migrate_legacy_beds_to_inbox()
	_clear_legacy_beds()
	_refresh_seed_unlock_from_lifetime()
	_ensure_garden_bed_capacity()
	if not is_seed_type_unlocked(loadout_type_id):
		loadout_type_id = ""
	return true


func _serialize_beds(beds: Array) -> Array:
	var out: Array = []
	for bed in beds:
		if bed == null:
			out.append(null)
		else:
			out.append({
				"type_id": str(bed.get("type_id", "")),
				"tier": int(bed.get("tier", 0)),
			})
	return out


func _deserialize_beds(data: Variant, expected: int) -> Array:
	var beds: Array = []
	var src: Array = data if data is Array else []
	for i in expected:
		if i < src.size() and src[i] is Dictionary:
			var d: Dictionary = src[i]
			var type_id := str(d.get("type_id", ""))
			var tier := int(d.get("tier", 0))
			if type_id.is_empty() or tier <= 0:
				beds.append(null)
			else:
				beds.append({"type_id": type_id, "tier": tier})
		else:
			beds.append(null)
	return beds


func _drop_retired_seed_keys() -> void:
	for bag in [seed_bag, last_seed_bag, garden_crystal_stash, lifetime_seeds_collected]:
		for tid in RETIRED_SEED_TYPE_IDS:
			if bag.has(tid):
				bag.erase(tid)
	if RETIRED_SEED_TYPE_IDS.has(loadout_type_id):
		loadout_type_id = ""


func _parse_string_int_dict(data: Variant) -> Dictionary:
	var out: Dictionary = {}
	if not data is Dictionary:
		return out
	for key in data:
		var count := int(data[key])
		if count > 0:
			out[str(key)] = count
	return out


func _parse_string_bool_dict(data: Variant) -> Dictionary:
	var out: Dictionary = {}
	if not data is Dictionary:
		return out
	for key in data:
		if bool(data[key]):
			out[str(key)] = true
	return out


func _parse_string_array(data: Variant) -> Array[String]:
	var out: Array[String] = []
	if not data is Array:
		return out
	for item in data:
		var value := str(item).strip_edges()
		if not value.is_empty() and not out.has(value):
			out.append(value)
	return out


func _parse_string_string_dict(data: Variant) -> Dictionary:
	var out: Dictionary = {}
	if not data is Dictionary:
		return out
	for key in data:
		var value := str(data[key])
		if not value.is_empty():
			out[str(key)] = value
	return out


func _try_migrate_tutorial_flags_only() -> void:
	if not FileAccess.file_exists(TUTORIAL_FLAGS_PATH):
		return
	var file := FileAccess.open(TUTORIAL_FLAGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		tutorial_complete = bool(parsed.get("tutorial_complete", false))
		if tutorial_complete:
			tutorial_step = TutorialStep.FREE


func _apply_debug_resources_if_new_game() -> void:
	if not DEBUG_DEV_RESOURCES:
		return
	if FileAccess.file_exists(PLAYER_SAVE_PATH):
		return
	wallet_coins = DEBUG_WALLET_COINS
	apply_debug_leftover_test_bag()


func apply_debug_leftover_test_bag() -> bool:
	return _try_apply_debug_leftover_test_bag(DEBUG_DEV_RESOURCES)


func _try_apply_debug_leftover_test_bag(dev_enabled: bool) -> bool:
	if not dev_enabled:
		return false
	if _debug_leftover_bag_applied:
		return false
	seed_bag = DEBUG_LEFTOVER_TEST_BAG.duplicate()
	seed_unlock_index = 4
	tutorial_complete = true
	tutorial_step = TutorialStep.FREE
	for type_id in DEBUG_LEFTOVER_TEST_BAG:
		discovered_blooms[str(type_id)] = true
	_debug_leftover_bag_applied = true
	save_player_save()
	return true


## Dev/playtest — min. count po otključanom tipu (ignorira soft cap u torbi).
func ensure_dev_unlocked_seeds(count_per_type: int = 10) -> void:
	if not DEBUG_DEV_RESOURCES:
		return
	_apply_debug_unlocked_seeds(count_per_type)
	save_player_save()


func _apply_debug_unlocked_seeds(count_per_type: int) -> void:
	for i in range(seed_unlock_index + 1):
		var type_id := SeedUnlockConfig.get_type_at_index(i)
		if type_id.is_empty():
			continue
		var current := int(seed_bag.get(type_id, 0))
		if current < count_per_type:
			seed_bag[type_id] = count_per_type


func mark_tutorial_complete() -> void:
	if tutorial_complete:
		return
	tutorial_complete = true
	tutorial_step = TutorialStep.FREE
	save_player_save()


func reset_garden_beds() -> void:
	garden_beds.clear()
	for _i in CAMP_BED_COUNT:
		garden_beds.append(null)


func reset_greenhouse_beds() -> void:
	greenhouse_beds.clear()
	for _i in GREENHOUSE_SLOT_COUNT:
		greenhouse_beds.append(null)


func go_to_scene(path: String) -> void:
	SceneRouter.change_to(path)


func go_to_meta_hub(page: int = MetaHubPages.MAIN) -> void:
	meta_hub_pending_page = clampi(page, 0, MetaHubPages.PAGE_COUNT - 1)
	go_to_scene(SCENE_META_HUB)


func go_to_meta_page(page: int) -> void:
	page = clampi(page, 0, MetaHubPages.PAGE_COUNT - 1)
	if meta_hub_active:
		var tree := Engine.get_main_loop() as SceneTree
		if tree:
			for hub in tree.get_nodes_in_group("meta_hub"):
				if hub.has_method("go_to_page"):
					hub.go_to_page(page)
					return
	meta_hub_pending_page = page
	go_to_scene(SCENE_META_HUB)


func go_to_meta_home() -> void:
	go_to_meta_page(MetaHubPages.MAIN)


func set_meta_hub_embedded(page_root: Control, embedded: bool) -> void:
	if page_root == null:
		return
	page_root.set_meta("meta_hub_embedded", embedded)


func is_meta_hub_embedded(node: Node) -> bool:
	if node == null:
		return false
	var current: Node = node
	while current:
		if current is Control and bool(current.get_meta("meta_hub_embedded", false)):
			return true
		current = current.get_parent()
	return meta_hub_active


func mark_arena_pest_tutorial_shown() -> void:
	if arena_pest_tutorial_shown:
		return
	arena_pest_tutorial_shown = true
	save_player_save()


func should_show_arena_pest_tutorial() -> bool:
	return not arena_pest_tutorial_shown


func go_to_camp() -> void:
	deposit_loot_to_camp()
	if should_offer_merge_arena():
		go_to_merge_arena()
	else:
		go_to_camp_hub()


func go_to_camp_hub() -> void:
	go_to_meta_page(MetaHubPages.CAMP)


func go_to_merge_arena() -> void:
	go_to_meta_page(MetaHubPages.ARENA)


func go_to_collection_journal() -> void:
	go_to_meta_page(MetaHubPages.COLLECTION)


func should_offer_merge_arena() -> bool:
	return sum_seed_bag(seed_bag) > 0


func should_prompt_merge_tutorial() -> bool:
	return not tutorial_complete and tutorial_step == TutorialStep.CAMP1


func get_loadout_type() -> String:
	return loadout_type_id


func format_loadout_label() -> String:
	if loadout_type_id.is_empty():
		return "Basket: empty (tap to equip)"
	var name: String = get_seed_display_name(loadout_type_id)
	var stars := "★".repeat(get_seed_rarity(loadout_type_id))
	return "Basket: %s %s  (+%.0f%% spawn)" % [name, stars, LOADOUT_SPAWN_BONUS * 100.0]


## Set run spawn bias. Unlocked; Home basket may include ★3 (theme spawn bias, Fair F2P).
func set_loadout(type_id: String) -> bool:
	if type_id.is_empty():
		return false
	if not is_seed_type_unlocked(type_id):
		return false
	loadout_type_id = type_id
	save_player_save()
	return true


func set_loadout_from_bag(type_id: String) -> bool:
	return set_loadout(type_id)


func clear_loadout() -> void:
	loadout_type_id = ""
	save_player_save()


func get_unlocked_loadout_types() -> Array[String]:
	var out: Array[String] = []
	for type_id in get_unlocked_run_spawn_types():
		if is_mythic_seed(type_id):
			continue
		out.append(type_id)
	out.sort_custom(func(a: String, b: String) -> bool:
		var na: String = get_seed_display_name(a)
		var nb: String = get_seed_display_name(b)
		return na < nb
	)
	return out


func get_unlocked_loadout_types_for_season(season_id: String) -> Array[String]:
	var out: Array[String] = []
	for type_id in SeedCatalog.types_for_season(season_id):
		if is_seed_type_unlocked(type_id):
			out.append(type_id)
	return out


func toggle_loadout_from_bag() -> String:
	return cycle_loadout_from_bag()


func cycle_loadout_from_bag() -> String:
	if not loadout_enabled():
		return "Basket unlocks after your first merge."
	var types := get_sorted_bag_types(false)
	if types.is_empty():
		clear_loadout()
		save_player_save()
		return "No garden seeds — run first!"
	var next_index := 0
	if not loadout_type_id.is_empty():
		var idx := types.find(loadout_type_id)
		if idx >= 0:
			next_index = (idx + 1) % types.size()
	var next_type: String = types[next_index]
	if set_loadout_from_bag(next_type):
		var name: String = get_seed_display_name(next_type)
		save_player_save()
		return "Basket: %s — more in next run (tap to change)" % name
	return "Could not set basket."


func get_sorted_bag_types(for_greenhouse: bool = false) -> Array[String]:
	var out: Array[String] = []
	for type_id in seed_bag:
		var count := int(seed_bag[type_id])
		if count <= 0:
			continue
		if is_mythic_seed(str(type_id)) == for_greenhouse:
			out.append(str(type_id))
	out.sort_custom(func(a: String, b: String) -> bool:
		var na: String = get_seed_display_name(a)
		var nb: String = get_seed_display_name(b)
		return na < nb
	)
	return out


func resolve_plant_type(for_greenhouse: bool, preferred: String = "") -> String:
	if not preferred.is_empty() and int(seed_bag.get(preferred, 0)) > 0:
		if is_mythic_seed(preferred) == for_greenhouse:
			return preferred
	var pair_type := _pick_pair_completion_type(for_greenhouse)
	if not pair_type.is_empty():
		return pair_type
	var loadout := get_loadout_type()
	if not loadout.is_empty() and int(seed_bag.get(loadout, 0)) > 0:
		if is_mythic_seed(loadout) == for_greenhouse:
			return loadout
	var sorted := get_sorted_bag_types(for_greenhouse)
	if sorted.is_empty():
		return ""
	return sorted[0]


func ensure_loot_in_camp_bag() -> void:
	if sum_seed_bag(last_seed_bag) > 0:
		deposit_loot_to_camp()


func get_seed_display_name(type_id: String) -> String:
	var named := SeedCatalog.display_name(type_id)
	if not named.is_empty():
		return named
	return str(SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize()))


func get_seed_rarity(type_id: String) -> int:
	return SeedCatalog.rarity(type_id)


func is_seed_type_unlocked(type_id: String) -> bool:
	if type_id.is_empty():
		return false
	var idx := SeedUnlockConfig.get_index(type_id)
	if idx >= 0:
		return idx <= seed_unlock_index
	var season_id := SeedCatalog.season_id_for(type_id)
	if season_id.is_empty():
		return false
	return is_season_playable(season_id)


func get_lifetime_seeds_collected(type_id: String) -> int:
	return maxi(0, int(lifetime_seeds_collected.get(type_id, 0)))


func record_seed_pickup_lifetime(type_id: String, count: int = 1) -> void:
	if type_id.is_empty() or count <= 0:
		return
	lifetime_seeds_collected[type_id] = get_lifetime_seeds_collected(type_id) + count
	_refresh_seed_unlock_from_lifetime()


func _refresh_seed_unlock_from_lifetime() -> void:
	var advanced := true
	while advanced:
		advanced = false
		if seed_unlock_index >= SeedUnlockConfig.chain_size() - 1:
			break
		var current_type := SeedUnlockConfig.get_type_at_index(seed_unlock_index)
		var need := SeedUnlockConfig.lifetime_required_to_unlock_next(seed_unlock_index)
		if get_lifetime_seeds_collected(current_type) >= need:
			seed_unlock_index += 1
			advanced = true


func get_unlocked_run_spawn_types() -> Array[String]:
	var out: Array[String] = []
	for i in seed_unlock_index + 1:
		var type_id := SeedUnlockConfig.get_type_at_index(i)
		if not type_id.is_empty():
			out.append(type_id)
	return out


func get_active_season_spawn_types() -> Array[String]:
	var out: Array[String] = []
	var def: SeasonDef = get_season_def(active_season_id)
	var source: Array[String] = []
	if def != null:
		source = def.seed_type_ids
	else:
		source = get_unlocked_run_spawn_types()
	for type_id in source:
		if is_seed_type_unlocked(type_id):
			out.append(type_id)
	if out.is_empty():
		out.append(SEED_TYPE_CLOVER)
	return out


func is_loadout_in_active_season_pool() -> bool:
	var loadout := get_loadout_type()
	if loadout.is_empty():
		return false
	return get_active_season_spawn_types().has(loadout)


func pick_random_run_seed_type() -> String:
	var pool := get_active_season_spawn_types()
	if is_loadout_in_active_season_pool():
		return get_loadout_type()
	if pool.is_empty():
		return SEED_TYPE_CLOVER
	return pool[randi() % pool.size()]


func has_pending_seed_unlock() -> bool:
	return seed_unlock_index < SeedUnlockConfig.chain_size() - 1


func get_next_seed_unlock_preview() -> Dictionary:
	if not has_pending_seed_unlock():
		return {}
	var next_index := seed_unlock_index + 1
	var prev_type := SeedUnlockConfig.get_type_at_index(seed_unlock_index)
	var next_type := SeedUnlockConfig.get_type_at_index(next_index)
	var need := SeedUnlockConfig.lifetime_required_to_unlock_next(seed_unlock_index)
	var have := get_lifetime_seeds_collected(prev_type)
	return {
		"prev_type": prev_type,
		"next_type": next_type,
		"lifetime_have": have,
		"lifetime_need": need,
		"coin_cost": SeedUnlockConfig.coin_cost_to_unlock_index(next_index),
	}


func format_seed_almanac_progress() -> String:
	if not has_pending_seed_unlock():
		return "Seed Almanac: all meadow seeds unlocked!"
	var preview := get_next_seed_unlock_preview()
	var prev_name: String = get_seed_display_name(str(preview.get("prev_type", "")))
	var next_name: String = get_seed_display_name(str(preview.get("next_type", "")))
	return "Unlock %s: collect %d/%d %s in runs (lifetime)." % [
		next_name,
		int(preview.get("lifetime_have", 0)),
		int(preview.get("lifetime_need", 0)),
		prev_name,
	]


func get_seed_almanac_tier(type_id: String) -> int:
	if not is_seed_type_unlocked(type_id):
		return 0
	var kept := int(collection_kept_tiers.get(type_id, 0))
	var life := get_lifetime_seeds_collected(type_id)
	if kept >= 3 or life >= SeedUnlockConfig.ALMANAC_TIER3_LIFETIME:
		return 3
	if kept >= 2 or life >= SeedUnlockConfig.ALMANAC_TIER2_LIFETIME:
		return 2
	return 1


func get_seed_almanac_tier_progress(type_id: String) -> Dictionary:
	var tier := get_seed_almanac_tier(type_id)
	if tier <= 0:
		return {}
	var life := get_lifetime_seeds_collected(type_id)
	if tier >= 3:
		return {"complete": true, "have": life, "need": life, "next_tier": 0}
	if tier == 1:
		return {
			"have": life,
			"need": SeedUnlockConfig.ALMANAC_TIER2_LIFETIME,
			"next_tier": 2,
			"caption": "Seeds collected toward Tier 2 bloom",
		}
	return {
		"have": life,
		"need": SeedUnlockConfig.ALMANAC_TIER3_LIFETIME,
		"next_tier": 3,
		"caption": "Seeds collected toward Tier 3 crystal",
	}


func get_almanac_top_progress() -> Dictionary:
	if has_pending_seed_unlock():
		var preview := get_next_seed_unlock_preview()
		var next_name: String = get_seed_display_name(str(preview.get("next_type", "")))
		var prev_name: String = get_seed_display_name(str(preview.get("prev_type", "")))
		return {
			"title": "Unlock %s — Tier 1" % next_name,
			"have": int(preview.get("lifetime_have", 0)),
			"need": int(preview.get("lifetime_need", 1)),
			"caption": "Collect %s in runs (lifetime)" % prev_name,
			"show_coin": true,
			"coin_cost": int(preview.get("coin_cost", 0)),
			"complete": false,
		}
	for i in seed_unlock_index + 1:
		var type_id := SeedUnlockConfig.get_type_at_index(i)
		if type_id.is_empty():
			continue
		var prog := get_seed_almanac_tier_progress(type_id)
		if prog.is_empty() or bool(prog.get("complete", false)):
			continue
		var display_name: String = get_seed_display_name(type_id)
		return {
			"title": "%s → Tier %d" % [display_name, int(prog.get("next_tier", 2))],
			"have": int(prog.get("have", 0)),
			"need": int(prog.get("need", 1)),
			"caption": str(prog.get("caption", "")),
			"show_coin": false,
			"coin_cost": 0,
			"complete": false,
		}
	return {"complete": true, "title": "All seeds mastered!", "have": 1, "need": 1, "caption": ""}


func get_almanac_chain_ui_data() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for i in SeedUnlockConfig.chain_size():
		var type_id := SeedUnlockConfig.get_type_at_index(i)
		if type_id.is_empty():
			continue
		var display_name: String = get_seed_display_name(type_id)
		var stars := "★".repeat(get_seed_rarity(type_id))
		var spawn_unlocked := is_seed_type_unlocked(type_id)
		var almanac_tier := get_seed_almanac_tier(type_id)
		var entry: Dictionary = {
			"type_id": type_id,
			"name": display_name,
			"stars": stars,
			"index": i,
			"spawn_unlocked": spawn_unlocked,
			"almanac_tier": almanac_tier,
		}
		if spawn_unlocked:
			entry["tier_progress"] = get_seed_almanac_tier_progress(type_id)
			entry["coin_cost"] = 0
			entry["can_coin_unlock"] = false
		else:
			var prev_type := SeedUnlockConfig.get_type_at_index(i - 1)
			var prev_name: String = get_seed_display_name(prev_type)
			entry["tier_progress"] = {
				"have": get_lifetime_seeds_collected(prev_type),
				"need": SeedUnlockConfig.lifetime_required_to_unlock_next(i - 1),
				"next_tier": 1,
				"caption": "Collect %s to unlock Tier 1 spawn" % prev_name,
				"prev_name": prev_name,
			}
			entry["coin_cost"] = SeedUnlockConfig.coin_cost_to_unlock_index(i)
			entry["can_coin_unlock"] = i == seed_unlock_index + 1
		rows.append(entry)
	return rows


func format_shop_resources_line() -> String:
	var seeds := sum_seed_bag(seed_bag)
	return "%d coins  ·  %d / %d seeds in bag" % [wallet_coins, seeds, SEED_BAG_SOFT_CAP]


func get_diamonds() -> int:
	return wallet_diamonds


func add_diamonds(amount: int) -> void:
	if amount <= 0:
		return
	wallet_diamonds += amount
	save_player_save()


## Economy indirection (plan-arhitektura-refaktor.md Stage 1). Every domain that
## grants/spends coins should go through these two instead of touching
## wallet_coins directly — keeps the coupling in one place ahead of the
## eventual Economy class extraction (Stage 3+).
func _add_coins(amount: int) -> void:
	if amount <= 0:
		return
	wallet_coins += amount


func _try_spend_coins(amount: int) -> bool:
	if amount <= 0:
		return true
	if wallet_coins < amount:
		return false
	wallet_coins -= amount
	return true


func try_coin_unlock_next_seed() -> String:
	if not has_pending_seed_unlock():
		return "All seeds already unlocked."
	var next_index := seed_unlock_index + 1
	var cost := SeedUnlockConfig.coin_cost_to_unlock_index(next_index)
	if not _try_spend_coins(cost):
		return "Need %d coins (you have %d)." % [cost, wallet_coins]
	var next_type := SeedUnlockConfig.get_type_at_index(next_index)
	var next_name: String = get_seed_display_name(next_type)
	seed_unlock_index = next_index
	save_player_save()
	return "%s unlocked early — look for it in your next run!" % next_name


func is_mythic_seed(type_id: String) -> bool:
	return get_seed_rarity(type_id) >= MYTHIC_RARITY


func sum_seed_bag(bag: Dictionary) -> int:
	var total := 0
	for count in bag.values():
		total += int(count)
	return total


func format_seed_bag_label() -> String:
	var total := sum_seed_bag(seed_bag)
	if seed_bag.is_empty():
		return "Seeds in bag: none (0/%d)" % SEED_BAG_SOFT_CAP
	var parts: PackedStringArray = []
	for type_id in seed_bag:
		var count := int(seed_bag[type_id])
		if count <= 0:
			continue
		var name: String = get_seed_display_name(type_id)
		var stars := "★".repeat(get_seed_rarity(type_id))
		parts.append("%d %s %s" % [count, name, stars])
	return "Seeds in bag (%d/%d): " % [total, SEED_BAG_SOFT_CAP] + ", ".join(parts)


func get_seed_bag_entries() -> Array[Dictionary]:
	## Sorted inventory rows for Garden UI: rarity ASC (★ → ★★★), then display name.
	var out: Array[Dictionary] = []
	for type_id in seed_bag:
		var count := int(seed_bag[type_id])
		if count <= 0:
			continue
		var tid := str(type_id)
		out.append({
			"type_id": tid,
			"count": count,
			"display_name": get_seed_display_name(tid),
			"rarity": get_seed_rarity(tid),
		})
	out.sort_custom(_compare_seed_bag_entry_asc)
	return out


func get_garden_crystal_entries() -> Array[Dictionary]:
	## Sorted crystal stash rows for CrystalCard UI.
	var out: Array[Dictionary] = []
	for type_id in garden_crystal_stash:
		var count := int(garden_crystal_stash[type_id])
		if count <= 0:
			continue
		var tid := str(type_id)
		out.append({
			"type_id": tid,
			"count": count,
			"display_name": get_seed_display_name(tid),
			"rarity": get_seed_rarity(tid),
		})
	out.sort_custom(_compare_seed_bag_entry_asc)
	return out


func _compare_seed_bag_entry_asc(a: Dictionary, b: Dictionary) -> bool:
	var ra := int(a.get("rarity", 0))
	var rb := int(b.get("rarity", 0))
	if ra != rb:
		return ra < rb
	var na := str(a.get("display_name", ""))
	var nb := str(b.get("display_name", ""))
	return na.naturalnocasecmp_to(nb) < 0


func _compare_seed_bag_entry_display(a: Dictionary, b: Dictionary) -> bool:
	var ra := int(a.get("rarity", 0))
	var rb := int(b.get("rarity", 0))
	if ra != rb:
		return ra > rb
	var na := str(a.get("display_name", ""))
	var nb := str(b.get("display_name", ""))
	return na.naturalnocasecmp_to(nb) < 0


func format_collection_label() -> String:
	if collection_kept_tiers.is_empty() and discovered_blooms.is_empty():
		return "Collection: none yet"
	var parts: PackedStringArray = []
	for type_id in collection_kept_tiers:
		var tier := int(collection_kept_tiers[type_id])
		if tier <= 0:
			continue
		var name: String = get_seed_display_name(type_id)
		parts.append("%s T%d" % [name, tier])
	for type_id in discovered_blooms:
		if collection_kept_tiers.has(type_id):
			continue
		var name: String = get_seed_display_name(type_id)
		parts.append(name)
	if parts.is_empty():
		return "Collection: none yet"
	return "Collection: " + ", ".join(parts)


func _mark_collection_journal_new(type_id: String, tier: int) -> void:
	if type_id.is_empty():
		return
	var journal_tier := maxi(1, tier)
	var prev := int(collection_journal_pending.get(type_id, 0))
	collection_journal_pending[type_id] = maxi(prev, journal_tier)


func has_collection_journal_news() -> bool:
	return not collection_journal_pending.is_empty()


func count_collection_journal_news() -> int:
	return collection_journal_pending.size()


func mark_collection_journal_viewed() -> void:
	if collection_journal_pending.is_empty():
		return
	collection_journal_pending.clear()
	save_player_save()


func get_collection_journal_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for type_id in SeedCatalog.all_type_ids():
		if type_id.is_empty():
			continue
		var spawn_unlocked := is_seed_type_unlocked(type_id)
		var discovered := bool(discovered_blooms.get(type_id, false))
		var kept_tier := int(collection_kept_tiers.get(type_id, 0))
		var display_tier := kept_tier
		if display_tier <= 0 and discovered:
			display_tier = 1
		var in_chain := SeedUnlockConfig.get_index(type_id) >= 0
		var spotted := discovered or kept_tier >= 2
		if in_chain:
			spotted = spotted or spawn_unlocked
		var state := "locked"
		if kept_tier >= 3:
			state = "album_t3"
		elif kept_tier >= 2:
			state = "album_t2"
		elif spotted:
			state = "seen"
		out.append({
			"type_id": type_id,
			"display_name": get_seed_display_name(type_id),
			"rarity": get_seed_rarity(type_id),
			"spawn_unlocked": spawn_unlocked,
			"discovered": discovered,
			"kept_tier": kept_tier,
			"display_tier": display_tier,
			"state": state,
			"is_new": collection_journal_pending.has(type_id),
			"new_tier": int(collection_journal_pending.get(type_id, 0)),
		})
	return out


func format_collection_journal_summary() -> String:
	var entries := get_collection_journal_entries()
	var kept := 0
	var seen := 0
	for entry in entries:
		if str(entry.get("state", "")).begins_with("album"):
			kept += 1
		elif str(entry.get("state", "")) != "locked":
			seen += 1
	return "Album: %d blooms kept · %d spotted" % [kept, seen]


func _halve_seed_bag(bag: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for type_id in bag:
		var n := int(bag[type_id])
		if n > 0:
			# ceil: 1 sjeme na failu ne nestane u 0 (round(0.5)==0 na desktopu).
			out[type_id] = int(ceil(n * 0.5))
	return out


func finish_run(seeds_by_type: Dictionary, raw_coins: int, failed: bool, elapsed: float) -> void:
	var mult := get_loot_multiplier()
	var scaled_coins := int(round(float(raw_coins) * mult))
	var scaled_seeds: Dictionary = {}
	for type_id in seeds_by_type:
		var count := int(seeds_by_type[type_id])
		if count > 0:
			scaled_seeds[type_id] = int(round(float(count) * mult))
	last_raw_seed_total = sum_seed_bag(seeds_by_type)
	last_raw_coins = raw_coins
	last_failed = failed
	loot_doubled = false
	carry_seed_bag = scaled_seeds.duplicate()
	carry_coins = scaled_coins
	carry_seeds = sum_seed_bag(scaled_seeds)
	carry_orbs = carry_seeds
	carry_elapsed = elapsed
	if failed:
		last_seed_bag = _halve_seed_bag(scaled_seeds)
		last_run_coins = int(round(float(scaled_coins) * 0.5))
	else:
		last_seed_bag = scaled_seeds.duplicate()
		last_run_coins = scaled_coins
	last_loot = sum_seed_bag(last_seed_bag)
	_add_coins(last_run_coins)
	_advance_tutorial_after_run()
	if not last_failed and tutorial_complete:
		if run_is_endless:
			endless_runs_completed += 1
		elif run_level < RunLevelLibrary.MAX_RUN_LEVEL:
			run_level += 1
	save_player_save()


func is_endless_mode() -> bool:
	return run_is_endless


func get_endless_difficulty_label() -> String:
	return ENDLESS_DIFFICULTY_LABELS.get(endless_difficulty, "Normal")


func uses_run_level_config() -> bool:
	return tutorial_complete


func get_active_run_level_config():
	if is_endless_mode():
		return RunLevelLibrary.get_endless_config_for_difficulty(endless_difficulty)
	return RunLevelLibrary.get_level(run_level)


func get_run_duration() -> float:
	if uses_run_level_config():
		return get_active_run_level_config().duration_sec
	if tutorial_complete:
		return POST_TUTORIAL_RUN_DURATION
	match tutorial_step:
		TutorialStep.RUN1:
			return TUTORIAL_RUN1_DURATION
		TutorialStep.RUN2:
			return TUTORIAL_RUN2_DURATION
		_:
			return POST_TUTORIAL_RUN_DURATION


func obstacles_enabled_for_run() -> bool:
	if tutorial_complete:
		return true
	return tutorial_step >= TutorialStep.RUN2


func is_tutorial_run1() -> bool:
	return not tutorial_complete and tutorial_step == TutorialStep.RUN1


func is_tutorial_run2() -> bool:
	return not tutorial_complete and tutorial_step == TutorialStep.RUN2


func loadout_enabled() -> bool:
	return tutorial_complete


func show_rewarded_loot_buttons() -> bool:
	return tutorial_complete


func should_highlight_first_bed() -> bool:
	return should_prompt_merge_tutorial()


func notify_camp_play() -> void:
	if tutorial_complete:
		return
	if tutorial_step == TutorialStep.CAMP1:
		tutorial_step = TutorialStep.RUN2
		save_player_save()


func _advance_tutorial_after_run() -> void:
	if tutorial_complete:
		return
	match tutorial_step:
		TutorialStep.RUN1:
			tutorial_step = TutorialStep.CAMP1
		TutorialStep.RUN2:
			tutorial_step = TutorialStep.CAMP_MERGE
	save_player_save()


func _notify_merge_completed() -> void:
	if tutorial_complete:
		return
	# Prvi T2 merge završava tutorial (ne samo u CAMP_MERGE — debug bag može ranije).
	mark_tutorial_complete()


func format_loot_label() -> String:
	var lines: PackedStringArray = []
	if last_run_coins > 0:
		lines.append("+%d Coins" % last_run_coins)
	for type_id in last_seed_bag:
		var count := int(last_seed_bag[type_id])
		if count <= 0:
			continue
		var display_name: String = get_seed_display_name(type_id)
		lines.append("+%d %s" % [count, display_name])
	if lines.is_empty():
		return "+0"
	return "\n".join(lines)


func format_loot_outcome_detail() -> String:
	if last_failed:
		var parts: PackedStringArray = []
		if last_raw_coins > 0:
			parts.append("%d → %d coins" % [last_raw_coins, last_run_coins])
		if last_raw_seed_total > 0:
			parts.append("%d → %d seeds" % [last_raw_seed_total, last_loot])
		if parts.is_empty():
			return "Obstacle hit — you keep half of what you pick up."
		return "Obstacle hit — kept 50%%: " + ", ".join(parts) + "."
	if last_run_coins > 0 or last_loot > 0:
		return "Full rewards — Pip reached the finish!"
	return "Run complete. Head to camp or try again!"


func has_pending_loot() -> bool:
	return last_run_coins > 0 or last_loot > 0


func begin_campaign_run() -> void:
	run_is_endless = false
	begin_fresh_run()


func begin_endless_run(difficulty: int) -> void:
	endless_difficulty = clampi(difficulty, EndlessDifficulty.EASY, EndlessDifficulty.HARD)
	run_is_endless = true
	begin_fresh_run()
	save_player_save()


func begin_fresh_run() -> void:
	revive_used_this_run = false
	resume_pending = false
	carry_seed_bag = {}
	carry_coins = 0
	carry_elapsed = 0.0
	carry_seeds = 0
	carry_orbs = 0


func double_loot_placeholder() -> bool:
	# ×2 samo loot ovog runa (last_*), ne retroaktivno na stariji wallet osim bonusa za ovaj run.
	if loot_doubled:
		return false
	if not has_pending_loot():
		return false
	for type_id in last_seed_bag:
		last_seed_bag[type_id] = int(last_seed_bag[type_id]) * 2
	last_loot = sum_seed_bag(last_seed_bag)
	if last_run_coins > 0:
		_add_coins(last_run_coins)
		last_run_coins *= 2
	loot_doubled = true
	save_player_save()
	return true


func request_revive() -> bool:
	if not last_failed or revive_used_this_run or loot_doubled:
		return false
	revive_used_this_run = true
	resume_pending = true
	go_to_scene(SCENE_RUN)
	return true


func add_seeds_to_bag(type_id: String, count: int) -> int:
	if count <= 0 or type_id.is_empty():
		return 0
	var room := seed_bag_remaining_capacity()
	if room <= 0:
		return 0
	var to_add := mini(count, room)
	seed_bag[type_id] = int(seed_bag.get(type_id, 0)) + to_add
	return to_add


## Arena vacuum: return chips even when the bag is already over SEED_BAG_SOFT_CAP (debug grant).
func add_seeds_to_bag_unbounded(type_id: String, count: int) -> int:
	if count <= 0 or type_id.is_empty():
		return 0
	seed_bag[type_id] = int(seed_bag.get(type_id, 0)) + count
	return count


func seed_bag_remaining_capacity() -> int:
	return maxi(0, SEED_BAG_SOFT_CAP - sum_seed_bag(seed_bag))


func take_seeds_from_bag(type_id: String, count: int) -> bool:
	var have := int(seed_bag.get(type_id, 0))
	if have < count:
		return false
	have -= count
	if have <= 0:
		seed_bag.erase(type_id)
	else:
		seed_bag[type_id] = have
	return true


func take_seed_from_bag(type_id: String) -> bool:
	return take_seeds_from_bag(type_id, 1)


func deposit_loot_to_camp() -> int:
	var deposited := 0
	for type_id in last_seed_bag.keys():
		var count := int(last_seed_bag.get(type_id, 0))
		if count > 0:
			deposited += add_seeds_to_bag(type_id, count)
		last_seed_bag.erase(type_id)
	last_loot = sum_seed_bag(last_seed_bag)
	save_player_save()
	return deposited


func get_garden_bed_capacity() -> int:
	var bonus := CAMP_BED_BONUS if magnet_level >= MAGNET_MAX_LEVEL else 0
	return CAMP_BED_COUNT + bonus


func bonus_garden_beds_unlocked() -> bool:
	return magnet_level >= MAGNET_MAX_LEVEL


func _ensure_garden_bed_capacity() -> void:
	var cap := get_garden_bed_capacity()
	while garden_beds.size() < cap:
		garden_beds.append(null)
	while garden_beds.size() > cap:
		garden_beds.pop_back()


func _today_key() -> String:
	var d := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]


func try_grant_arena_combo_coins() -> int:
	var today := _today_key()
	if combo_coin_day != today:
		combo_coin_day = today
		combo_coins_granted_today = 0
	var remaining := ARENA_COMBO_COIN_DAILY_CAP - combo_coins_granted_today
	if remaining <= 0:
		return 0
	var grant := mini(ARENA_COMBO_COINS, remaining)
	_add_coins(grant)
	combo_coins_granted_today += grant
	save_player_save()
	return grant


func can_claim_daily_chest() -> bool:
	return tutorial_complete and last_daily_chest_day != _today_key()


func claim_daily_chest() -> String:
	if not tutorial_complete:
		return "Finish the tutorial first."
	if not can_claim_daily_chest():
		return "Daily chest already opened today."
	var pool := get_unlocked_run_spawn_types()
	if pool.is_empty():
		pool = [SEED_TYPE_CLOVER]
	var type_id: String = pool[randi() % pool.size()]
	var added := add_seeds_to_bag(type_id, DAILY_CHEST_SEEDS)
	_add_coins(DAILY_CHEST_COINS)
	last_daily_chest_day = _today_key()
	save_player_save()
	var name: String = get_seed_display_name(type_id)
	if added < DAILY_CHEST_SEEDS:
		return (
			"Daily chest: +%d coins, +%d %s (bag almost full!)."
			% [DAILY_CHEST_COINS, added, name]
		)
	return "Daily chest: +%d coins and +%d %s seeds!" % [DAILY_CHEST_COINS, added, name]


const ARENA_DAILY_KINDS: PackedStringArray = ["merge_t2", "make_t3", "combo_5"]


func _arena_daily_kind_for_day(day: String) -> String:
	if day.is_empty():
		return ARENA_DAILY_KINDS[0]
	var idx := absi(day.hash()) % ARENA_DAILY_KINDS.size()
	return ARENA_DAILY_KINDS[idx]


func _arena_daily_goal_for_kind(kind: String) -> int:
	if kind == "merge_t2":
		return 3
	return 1


func ensure_arena_daily_task() -> void:
	var today := _today_key()
	if arena_daily_day == today and not arena_daily_kind.is_empty():
		arena_daily_goal = _arena_daily_goal_for_kind(arena_daily_kind)
		arena_daily_progress = mini(arena_daily_progress, arena_daily_goal)
		return
	arena_daily_day = today
	arena_daily_kind = _arena_daily_kind_for_day(today)
	arena_daily_goal = _arena_daily_goal_for_kind(arena_daily_kind)
	arena_daily_progress = 0
	save_player_save()


func note_arena_daily_event(kind: String) -> void:
	ensure_arena_daily_task()
	if kind != arena_daily_kind:
		return
	if arena_daily_progress >= arena_daily_goal:
		return
	arena_daily_progress += 1
	save_player_save()


func can_claim_arena_daily() -> bool:
	ensure_arena_daily_task()
	return (
		arena_daily_progress >= arena_daily_goal
		and arena_daily_claimed_day != _today_key()
	)


func claim_arena_daily() -> String:
	if not can_claim_arena_daily():
		return "Arena daily already claimed today."
	arena_daily_claimed_day = _today_key()
	arena_daily_streak += 1
	save_player_save()
	return "Arena streak %d" % arena_daily_streak


func get_arena_daily_hud_text() -> String:
	ensure_arena_daily_task()
	var n := mini(arena_daily_progress, arena_daily_goal)
	if arena_daily_kind == "merge_t2":
		return "Merge T2 %d/%d" % [n, arena_daily_goal]
	if arena_daily_kind == "make_t3":
		return "T3 %d/%d" % [n, arena_daily_goal]
	return "Combo 5 %d/%d" % [n, arena_daily_goal]


func get_arena_daily_home_line() -> String:
	ensure_arena_daily_task()
	if arena_daily_claimed_day == _today_key():
		return "Arena streak %d" % arena_daily_streak
	if arena_daily_progress >= arena_daily_goal:
		return "Arena daily — tap for badge"
	return "Arena %d/%d" % [mini(arena_daily_progress, arena_daily_goal), arena_daily_goal]


func auto_plant_from_bag() -> int:
	return 0


func _pick_pair_completion_type(in_greenhouse: bool) -> String:
	var on_beds := _bed_t1_counts(in_greenhouse)
	for type_id in on_beds:
		if int(on_beds[type_id]) % 2 == 1:
			if int(seed_bag.get(type_id, 0)) > 0:
				return str(type_id)
	return ""


func keep_all_blooms_on_beds() -> int:
	return keep_all_bloom_inbox()


func count_blooms_on_beds(min_tier: int = 2) -> int:
	return count_bloom_inbox(min_tier)


func _first_empty_bed_index(in_greenhouse: bool) -> int:
	var beds := _bed_array(in_greenhouse)
	for i in beds.size():
		if beds[i] == null:
			return i
	return -1


func _bed_t1_counts(in_greenhouse: bool) -> Dictionary:
	var counts: Dictionary = {}
	for bed in _bed_array(in_greenhouse):
		if bed == null:
			continue
		if int(bed.get("tier", 0)) != 1:
			continue
		var type_id := str(bed.get("type_id", ""))
		counts[type_id] = int(counts.get(type_id, 0)) + 1
	return counts


func keep_bloom_from_bed(bed_index: int, in_greenhouse: bool = false) -> bool:
	var beds := _bed_array(in_greenhouse)
	if bed_index < 0 or bed_index >= beds.size():
		return false
	var bed: Variant = beds[bed_index]
	if bed == null:
		return false
	var tier := int(bed.get("tier", 0))
	if tier < 2:
		return false
	var type_id: String = str(bed.get("type_id", ""))
	var prev := int(collection_kept_tiers.get(type_id, 0))
	collection_kept_tiers[type_id] = maxi(prev, tier)
	discovered_blooms[type_id] = true
	_mark_collection_journal_new(type_id, tier)
	beds[bed_index] = null
	save_player_save()
	return true


func _bed_array(in_greenhouse: bool) -> Array:
	return greenhouse_beds if in_greenhouse else garden_beds


func _bed_capacity(in_greenhouse: bool) -> int:
	if in_greenhouse:
		return GREENHOUSE_SLOT_COUNT
	return get_garden_bed_capacity()


func bed_is_empty(index: int, in_greenhouse: bool = false) -> bool:
	return _bed_array(in_greenhouse)[index] == null


func get_bed_type(index: int, in_greenhouse: bool = false) -> String:
	if _bed_array(in_greenhouse)[index] == null:
		return ""
	return str(_bed_array(in_greenhouse)[index].get("type_id", ""))


func get_bed_tier(index: int, in_greenhouse: bool = false) -> int:
	if _bed_array(in_greenhouse)[index] == null:
		return 0
	return int(_bed_array(in_greenhouse)[index].get("tier", 0))


func plant_seed_in_bed(bed_index: int, type_id: String, in_greenhouse: bool = false) -> bool:
	var beds := _bed_array(in_greenhouse)
	if bed_index < 0 or bed_index >= beds.size():
		return false
	if beds[bed_index] != null:
		return false
	var mythic := is_mythic_seed(type_id)
	if in_greenhouse and not mythic:
		return false
	if not in_greenhouse and mythic:
		return false
	if not take_seed_from_bag(type_id):
		return false
	beds[bed_index] = {"type_id": type_id, "tier": 1}
	save_player_save()
	return true


func try_merge_beds(index_a: int, index_b: int, in_greenhouse: bool = false) -> bool:
	if index_a == index_b:
		return false
	var beds := _bed_array(in_greenhouse)
	var bed_a: Variant = beds[index_a]
	var bed_b: Variant = beds[index_b]
	if bed_a == null or bed_b == null:
		return false
	if str(bed_a.get("type_id", "")) != str(bed_b.get("type_id", "")):
		return false
	if int(bed_a.get("tier", 0)) != int(bed_b.get("tier", 0)):
		return false
	var tier := int(bed_a.get("tier", 0))
	if tier <= 0 or tier >= MAX_MERGE_TIER:
		return false
	var type_id: String = str(bed_a.get("type_id", ""))
	beds[index_b] = {"type_id": type_id, "tier": tier + 1}
	beds[index_a] = null
	if tier + 1 >= 2:
		discovered_blooms[type_id] = true
		_mark_collection_journal_new(type_id, 1)
		_notify_merge_completed()
	save_player_save()
	return true


func count_flowers_tier(tier: int, in_greenhouse: bool = false) -> int:
	var total := 0
	for bed in _bed_array(in_greenhouse):
		if bed != null and int(bed.get("tier", 0)) == tier:
			total += 1
	return total


func count_all_flowers_tier(tier: int) -> int:
	return count_flowers_tier(tier, false) + count_flowers_tier(tier, true)


func empty_garden_beds() -> int:
	var total := 0
	for i in get_garden_bed_capacity():
		if i < garden_beds.size() and garden_beds[i] == null:
			total += 1
	return total


func first_seed_type_in_bag(for_greenhouse: bool = false) -> String:
	for type_id in seed_bag:
		if int(seed_bag[type_id]) <= 0:
			continue
		if is_mythic_seed(type_id) == for_greenhouse:
			return str(type_id)
	return ""


func first_exchangeable_type_in_bag() -> String:
	var entries := get_seed_bag_entries()
	if entries.is_empty():
		return ""
	return str(entries[0].get("type_id", ""))


func seed_exchange_take_count(bag_count: int) -> int:
	if bag_count <= 0:
		return 0
	if bag_count >= EXCHANGE_SEED_COUNT:
		return EXCHANGE_SEED_COUNT
	return bag_count


func seed_exchange_coins_per_seed(type_id: String) -> int:
	return int(SEED_EXCHANGE_COINS_BY_RARITY.get(get_seed_rarity(type_id), 1))


func seed_exchange_coins_for_take(take: int, type_id: String) -> int:
	if take <= 0:
		return 0
	return take * seed_exchange_coins_per_seed(type_id)


func crystal_exchange_coins_for_type(type_id: String) -> int:
	return int(CRYSTAL_EXCHANGE_COINS_BY_RARITY.get(get_seed_rarity(type_id), 5))


func exchange_seeds_from_bag(type_id: String) -> bool:
	var bag_count := int(seed_bag.get(type_id, 0))
	var take := seed_exchange_take_count(bag_count)
	if take <= 0:
		return false
	var coins := seed_exchange_coins_for_take(take, type_id)
	if not take_seeds_from_bag(type_id, take):
		return false
	_add_coins(coins)
	save_player_save()
	return true


func donate_bloom_from_bed(bed_index: int, in_greenhouse: bool = false) -> bool:
	var beds := _bed_array(in_greenhouse)
	if bed_index < 0 or bed_index >= beds.size():
		return false
	var bed: Variant = beds[bed_index]
	if bed == null or int(bed.get("tier", 0)) != 2:
		return false
	if magnet_level >= MAGNET_MAX_LEVEL:
		return false
	if sprinkler_donations >= MAGNET_COST_T2:
		return false
	beds[bed_index] = null
	sprinkler_donations += 1
	save_player_save()
	return true


func pick_upgrade_flower_type(preferred: String = "") -> String:
	if int(garden_crystal_stash.get(preferred, 0)) >= UPGRADE_FLOWER_COST:
		return preferred
	var candidates: Array[Dictionary] = []
	for type_id in garden_crystal_stash:
		var count := int(garden_crystal_stash[type_id])
		if count < UPGRADE_FLOWER_COST:
			continue
		candidates.append({
			"type_id": str(type_id),
			"rarity": get_seed_rarity(str(type_id)),
			"count": count,
			"chain": SeedUnlockConfig.get_index(str(type_id)),
		})
	if candidates.is_empty():
		return ""
	candidates.sort_custom(_compare_upgrade_flower_pick)
	return str(candidates[0].get("type_id", ""))


func _compare_upgrade_flower_pick(a: Dictionary, b: Dictionary) -> bool:
	var rarity_a := int(a.get("rarity", 1))
	var rarity_b := int(b.get("rarity", 1))
	if rarity_a != rarity_b:
		return rarity_a < rarity_b
	var count_a := int(a.get("count", 0))
	var count_b := int(b.get("count", 0))
	if count_a != count_b:
		return count_a > count_b
	return int(a.get("chain", 99)) < int(b.get("chain", 99))


func can_spend_flowers_for_upgrade(preferred: String = "") -> bool:
	return not pick_upgrade_flower_type(preferred).is_empty()


func spend_flowers_for_upgrade(preferred: String = "") -> bool:
	var type_id := pick_upgrade_flower_type(preferred)
	if type_id.is_empty():
		return false
	var have := int(garden_crystal_stash.get(type_id, 0))
	if have < UPGRADE_FLOWER_COST:
		return false
	var left := have - UPGRADE_FLOWER_COST
	if left <= 0:
		garden_crystal_stash.erase(type_id)
	else:
		garden_crystal_stash[type_id] = left
	save_player_save()
	return true


func try_upgrade_magnet(preferred: String = "") -> bool:
	if magnet_level >= MAGNET_MAX_LEVEL:
		return false
	if not spend_flowers_for_upgrade(preferred):
		return false
	magnet_level += 1
	_ensure_garden_bed_capacity()
	save_player_save()
	return true


func get_loot_multiplier() -> float:
	return get_loot_multiplier_for_level(multiplier_level)


func get_loot_multiplier_for_level(level: int) -> float:
	var idx := clampi(level, 0, MULTIPLIER_VALUES.size() - 1)
	return MULTIPLIER_VALUES[idx]


func format_loot_multiplier_label() -> String:
	var mult := get_loot_multiplier()
	if mult <= 1.0:
		return "Loot Boost Lv 0 / %d (×1.0)" % MULTIPLIER_MAX_LEVEL
	return "Loot Boost Lv %d / %d (x%.2f)" % [multiplier_level, MULTIPLIER_MAX_LEVEL, mult]


func donate_crystal_from_bed(bed_index: int, in_greenhouse: bool = false) -> bool:
	var beds := _bed_array(in_greenhouse)
	if bed_index < 0 or bed_index >= beds.size():
		return false
	var bed: Variant = beds[bed_index]
	if bed == null or int(bed.get("tier", 0)) != MAX_MERGE_TIER:
		return false
	if multiplier_level >= MULTIPLIER_MAX_LEVEL:
		return false
	if multiplier_donations >= MULTIPLIER_COST_T3:
		return false
	beds[bed_index] = null
	multiplier_donations += 1
	save_player_save()
	return true


func try_upgrade_multiplier(preferred: String = "") -> bool:
	if multiplier_level >= MULTIPLIER_MAX_LEVEL:
		return false
	if not spend_flowers_for_upgrade(preferred):
		return false
	multiplier_level += 1
	save_player_save()
	return true


func get_magnet_radius_for_level(level: int) -> float:
	return MAGNET_BASE_RADIUS + float(level) * MAGNET_RADIUS_PER_LEVEL


func get_magnet_radius() -> float:
	return get_magnet_radius_for_level(magnet_level)


func get_camp_progress_level() -> int:
	return magnet_level + multiplier_level


func is_companion_unlocked(companion_id: String) -> bool:
	if companion_id == COMPANION_PIP:
		return true
	if companion_id == COMPANION_MOCHI:
		return get_camp_progress_level() >= MOCHI_UNLOCK_CAMP_LEVEL
	return false


func get_active_companion_id() -> String:
	if is_companion_unlocked(active_companion_id):
		return active_companion_id
	return COMPANION_PIP


func get_companion_display_name(companion_id: String = "") -> String:
	var id := companion_id if not companion_id.is_empty() else get_active_companion_id()
	return _companion_name(id)


func _companion_name(companion_id: String) -> String:
	match companion_id:
		COMPANION_PIP:
			return "Pip"
		COMPANION_MOCHI:
			return "Mochi"
		_:
			return companion_id.capitalize()


func format_mochi_unlock_hint() -> String:
	if is_companion_unlocked(COMPANION_MOCHI):
		return "Mochi unlocked — tap to run as cat!"
	var need := MOCHI_UNLOCK_CAMP_LEVEL - get_camp_progress_level()
	return "Mochi unlocks at camp level %d (%d upgrade%s to go)." % [
		MOCHI_UNLOCK_CAMP_LEVEL,
		maxi(0, need),
		"" if need == 1 else "s",
	]


func try_set_active_companion(companion_id: String) -> String:
	if not is_companion_unlocked(companion_id):
		return format_mochi_unlock_hint()
	if active_companion_id == companion_id:
		return "%s is already your runner." % _companion_name(companion_id)
	active_companion_id = companion_id
	save_player_save()
	return "%s will join your next run!" % _companion_name(companion_id)


func poll_mochi_unlock_toast() -> String:
	if mochi_unlock_seen:
		return ""
	if not is_companion_unlocked(COMPANION_MOCHI):
		return ""
	mochi_unlock_seen = true
	save_player_save()
	return "Mochi joined the meadow! Pick a companion below."


func _clear_legacy_beds() -> void:
	garden_beds.clear()
	greenhouse_beds.clear()


func _migrate_legacy_beds_to_inbox() -> void:
	for in_greenhouse in [false, true]:
		for bed in _bed_array(in_greenhouse):
			if bed == null:
				continue
			var tier := int(bed.get("tier", 0))
			if tier >= 2:
				push_bloom_inbox(str(bed.get("type_id", "")), tier)


func _deserialize_bloom_inbox(raw: Variant) -> Array:
	var out: Array = []
	if raw is Array:
		for item in raw:
			if item is Dictionary:
				out.append(item.duplicate())
	return out


func get_bloom_inbox_entries() -> Array:
	return bloom_inbox.duplicate(true)


func count_bloom_inbox(min_tier: int = 2) -> int:
	var total := 0
	for item in bloom_inbox:
		if int(item.get("tier", 0)) >= min_tier:
			total += 1
	return total


func push_bloom_inbox(type_id: String, tier: int) -> bool:
	if type_id.is_empty() or tier < 2:
		return false
	if bloom_inbox.size() >= BLOOM_INBOX_MAX:
		return false
	bloom_inbox.append({"type_id": type_id, "tier": tier})
	discovered_blooms[type_id] = true
	_mark_collection_journal_new(type_id, 1)
	save_player_save()
	return true


func donate_bloom(type_id: String, tier: int) -> bool:
	if type_id.is_empty() or tier < 2:
		return false
	if tier == 2:
		if magnet_level >= MAGNET_MAX_LEVEL:
			return false
		if sprinkler_donations >= MAGNET_COST_T2:
			return false
		sprinkler_donations += 1
	elif tier >= MAX_MERGE_TIER:
		if multiplier_level >= MULTIPLIER_MAX_LEVEL:
			return false
		if multiplier_donations >= MULTIPLIER_COST_T3:
			return false
		multiplier_donations += 1
	else:
		return false
	save_player_save()
	return true


func can_keep_bloom_upgrade(type_id: String, tier: int) -> bool:
	if type_id.is_empty() or tier < 2:
		return false
	return tier > int(collection_kept_tiers.get(type_id, 0))


func keep_bloom(type_id: String, tier: int) -> bool:
	if not can_keep_bloom_upgrade(type_id, tier):
		return false
	collection_kept_tiers[type_id] = tier
	discovered_blooms[type_id] = true
	_mark_collection_journal_new(type_id, tier)
	save_player_save()
	return true


func basket_bloom_type(type_id: String) -> bool:
	if type_id.is_empty() or is_mythic_seed(type_id):
		return false
	loadout_type_id = type_id
	save_player_save()
	return true


func keep_all_bloom_inbox() -> int:
	var kept := 0
	for i in range(bloom_inbox.size() - 1, -1, -1):
		if keep_bloom_inbox(i):
			kept += 1
	return kept


func keep_bloom_inbox(index: int) -> bool:
	if index < 0 or index >= bloom_inbox.size():
		return false
	var item: Dictionary = bloom_inbox[index]
	var type_id := str(item.get("type_id", ""))
	var tier := int(item.get("tier", 0))
	if not keep_bloom(type_id, tier):
		return false
	bloom_inbox.remove_at(index)
	return true


func donate_bloom_inbox(index: int) -> bool:
	if index < 0 or index >= bloom_inbox.size():
		return false
	var item: Dictionary = bloom_inbox[index]
	var type_id := str(item.get("type_id", ""))
	var tier := int(item.get("tier", 0))
	if not donate_bloom(type_id, tier):
		return false
	bloom_inbox.remove_at(index)
	return true


func basket_bloom_inbox(index: int) -> bool:
	if index < 0 or index >= bloom_inbox.size():
		return false
	var type_id := str(bloom_inbox[index].get("type_id", ""))
	if not basket_bloom_type(type_id):
		return false
	bloom_inbox.remove_at(index)
	return true


func flush_bloom_inbox_to_album() -> int:
	var kept := 0
	for i in range(bloom_inbox.size() - 1, -1, -1):
		if keep_bloom_inbox(i):
			kept += 1
	return kept


func is_arena_pour_locked(type_id: String) -> bool:
	if type_id.is_empty() or not _arena_pour_locked_types.has(type_id):
		return false
	# S31 — lock does not block a real T3 set sitting in the bag.
	if int(seed_bag.get(type_id, 0)) >= 4:
		return false
	return true


func lock_arena_pour_type(type_id: String) -> void:
	if type_id.is_empty():
		return
	if int(seed_bag.get(type_id, 0)) >= 4:
		_arena_pour_locked_types.erase(type_id)
		return
	_arena_pour_locked_types[type_id] = true


func unlock_arena_pour_type(type_id: String) -> void:
	if type_id.is_empty():
		return
	_arena_pour_locked_types.erase(type_id)


func clear_arena_pour_locks() -> void:
	_arena_pour_locked_types.clear()


func pull_seeds_to_arena(max_count: int, _field_type_counts: Dictionary = {}) -> Array:
	var out: Array = []
	max_count = maxi(0, max_count)
	if max_count <= 0:
		return out
	var queue := _build_arena_pour_queue()
	var pulled := 0
	for type_id in queue:
		if pulled >= max_count:
			break
		if not take_seed_from_bag(type_id):
			continue
		var chip_id := _arena_chip_counter
		_arena_chip_counter += 1
		out.append({"chip_id": chip_id, "type_id": type_id, "tier": 1})
		pulled += 1
	if pulled > 0:
		save_player_save()
	return out


func _compare_seed_pour_priority(a: String, b: String) -> bool:
	var ra := get_seed_rarity(a)
	var rb := get_seed_rarity(b)
	if ra != rb:
		return ra < rb
	return SeedUnlockConfig.get_index(a) < SeedUnlockConfig.get_index(b)


func get_bag_types_by_pour_priority() -> Array[String]:
	var out: Array[String] = []
	for type_id in seed_bag:
		if int(seed_bag.get(type_id, 0)) > 0:
			out.append(str(type_id))
	out.sort_custom(_compare_seed_pour_priority)
	return out


func _append_pourable_to_queue(queue: Array[String], type_id: String) -> int:
	var n := int(seed_bag.get(type_id, 0))
	if n < 4:
		return 0
	if is_arena_pour_locked(type_id):
		return 0
	for _i in n:
		queue.append(type_id)
	return n


func _build_arena_pour_queue(_field_type_counts: Dictionary = {}) -> Array[String]:
	var queue: Array[String] = []
	for type_id in SeedCatalog.all_type_ids():
		_append_pourable_to_queue(queue, type_id)
	return queue


func stash_garden_crystal(type_id: String) -> void:
	if type_id.is_empty():
		return
	discovered_blooms[type_id] = true
	# Arena T3 auto-stashes — unlock Album T3 (player cannot Keep the chip).
	var prev_kept := int(collection_kept_tiers.get(type_id, 0))
	collection_kept_tiers[type_id] = maxi(prev_kept, MAX_MERGE_TIER)
	_mark_collection_journal_new(type_id, MAX_MERGE_TIER)
	garden_crystal_stash[type_id] = int(garden_crystal_stash.get(type_id, 0)) + 1
	save_player_save()


func get_garden_crystal_total() -> int:
	return sum_seed_bag(garden_crystal_stash)


func format_garden_crystal_stash_label() -> String:
	var total := get_garden_crystal_total()
	if total <= 0:
		return "Garden stash: empty (T3 crystals from merge go here)"
	var types: Array[String] = []
	for type_id in garden_crystal_stash:
		if int(garden_crystal_stash.get(type_id, 0)) > 0:
			types.append(str(type_id))
	types.sort_custom(_compare_seed_pour_priority)
	var parts: PackedStringArray = []
	for type_id in types:
		var count := int(garden_crystal_stash.get(type_id, 0))
		var name: String = get_seed_display_name(type_id)
		parts.append("%s×%d" % [name, count])
	return "Garden stash: %s (%d total)" % [", ".join(parts), total]


func first_garden_crystal_type() -> String:
	var types: Array[String] = []
	for type_id in garden_crystal_stash:
		if int(garden_crystal_stash.get(type_id, 0)) > 0:
			types.append(str(type_id))
	if types.is_empty():
		return ""
	types.sort_custom(_compare_seed_pour_priority)
	return types[0]


func exchange_garden_crystal(type_id: String = "") -> bool:
	if type_id.is_empty():
		type_id = first_garden_crystal_type()
	if type_id.is_empty():
		return false
	var have := int(garden_crystal_stash.get(type_id, 0))
	if have <= 0:
		return false
	if have <= 1:
		garden_crystal_stash.erase(type_id)
	else:
		garden_crystal_stash[type_id] = have - 1
	_add_coins(crystal_exchange_coins_for_type(type_id))
	save_player_save()
	return true


func sum_seed_bag_only() -> int:
	return sum_seed_bag(seed_bag)


func get_bag_preview_types(limit: int = 3) -> Array[String]:
	var priority := get_bag_types_by_pour_priority()
	if priority.is_empty():
		return []
	var out: Array[String] = []
	for type_id in priority:
		out.append(type_id)
		if out.size() >= limit:
			break
	return out


func spawn_arena_chips_from_bag() -> Array:
	# Legacy — koristi pull_seeds_to_arena iz kontrolera.
	return pull_seeds_to_arena(ARENA_MAX_CHIPS)


func try_merge_arena_chips(chip_a: int, chip_b: int, chip_data: Dictionary) -> Dictionary:
	if chip_a == chip_b:
		return {"ok": false, "msg": "Same chip."}
	if not chip_data.has(chip_a) or not chip_data.has(chip_b):
		return {"ok": false, "msg": "Missing chip."}
	var a: Dictionary = chip_data[chip_a]
	var b: Dictionary = chip_data[chip_b]
	if str(a.get("type_id", "")) != str(b.get("type_id", "")):
		return {"ok": false, "msg": "Different types."}
	var tier := int(a.get("tier", 1))
	if tier != int(b.get("tier", 1)) or tier >= MAX_MERGE_TIER:
		return {"ok": false, "msg": "Cannot merge these tiers."}
	var type_id: String = str(a.get("type_id", ""))
	var new_tier := tier + 1
	_notify_merge_completed()
	if new_tier >= MAX_MERGE_TIER:
		var center: Vector2 = (a.get("pos", Vector2.ZERO) + b.get("pos", Vector2.ZERO)) * 0.5
		chip_data.erase(chip_b)
		chip_data[chip_a] = {"chip_id": chip_a, "type_id": type_id, "tier": new_tier, "pos": center}
		discovered_blooms[type_id] = true
		_mark_collection_journal_new(type_id, new_tier)
		return {"ok": true, "to_inbox": false, "new_tier": new_tier, "crystal": true}
	var center: Vector2 = (a.get("pos", Vector2.ZERO) + b.get("pos", Vector2.ZERO)) * 0.5
	chip_data.erase(chip_b)
	chip_data[chip_a] = {"chip_id": chip_a, "type_id": type_id, "tier": new_tier, "pos": center}
	return {"ok": true, "to_inbox": false, "new_tier": new_tier}


## Resolve one arena leftover chip. Never silently drops T2+ (Bug-016).
## Returns: bagged | crystal | recycled | skipped
func resolve_arena_leftover_bloom(type_id: String, tier: int) -> String:
	if type_id.is_empty():
		return "skipped"
	if tier <= 1:
		add_seeds_to_bag(type_id, 1)
		return "bagged"
	if tier >= MAX_MERGE_TIER:
		stash_garden_crystal(type_id)
		return "crystal"
	# FLOW-A — leftover T2 → 2× T1. Arena does not donate/keep.
	if add_seeds_to_bag(type_id, 2) > 0:
		return "recycled"
	_add_coins(2)
	return "recycled"


func commit_arena_chips_to_bag(chip_data: Dictionary) -> Dictionary:
	var summary := {"bagged": 0, "crystal": 0, "kept": 0, "donated": 0, "recycled": 0}
	for _chip_id in chip_data:
		var entry: Dictionary = chip_data[_chip_id]
		var tier := int(entry.get("tier", 1))
		var type_id := str(entry.get("type_id", ""))
		if type_id.is_empty():
			continue
		var result := resolve_arena_leftover_bloom(type_id, tier)
		if summary.has(result):
			summary[result] = int(summary[result]) + 1
	chip_data.clear()
	save_player_save()
	return summary


func owns_cosmetic(cosmetic_id: String) -> bool:
	return bool(owned_cosmetics.get(cosmetic_id, false))


func is_cosmetic_equipped(cosmetic_id: String) -> bool:
	if not owns_cosmetic(cosmetic_id):
		return false
	var slot := CosmeticCatalog.get_slot(cosmetic_id)
	return str(equipped_cosmetics.get(slot, "")) == cosmetic_id


func get_equipped_cosmetic(slot: String) -> String:
	var item_id := str(equipped_cosmetics.get(slot, ""))
	if item_id.is_empty() or not owns_cosmetic(item_id):
		return ""
	return item_id


func buy_cosmetic_with_coins(cosmetic_id: String) -> String:
	if cosmetic_id.is_empty() or CosmeticCatalog.get_item(cosmetic_id).is_empty():
		return "Unknown item."
	if owns_cosmetic(cosmetic_id):
		equip_cosmetic(cosmetic_id)
		return "%s equipped." % CosmeticCatalog.get_title(cosmetic_id)
	var cost := CosmeticCatalog.get_coin_cost(cosmetic_id)
	if not _try_spend_coins(cost):
		return "Need %d coins." % cost
	owned_cosmetics[cosmetic_id] = true
	equip_cosmetic(cosmetic_id)
	save_player_save()
	return "Purchased %s!" % CosmeticCatalog.get_title(cosmetic_id)


func equip_cosmetic(cosmetic_id: String) -> bool:
	if not owns_cosmetic(cosmetic_id):
		return false
	var slot := CosmeticCatalog.get_slot(cosmetic_id)
	if slot.is_empty():
		return false
	equipped_cosmetics[slot] = cosmetic_id
	save_player_save()
	return true


func get_cosmetic_shop_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item_id in CosmeticCatalog.all_ids():
		out.append({"id": item_id})
	return out


func get_booster_count(booster_id: String) -> int:
	return maxi(0, int(booster_inventory.get(booster_id, 0)))


func add_booster(booster_id: String, count: int = 1) -> void:
	if booster_id.is_empty() or count <= 0:
		return
	booster_inventory[booster_id] = get_booster_count(booster_id) + count
	save_player_save()


func use_booster(booster_id: String) -> String:
	if get_booster_count(booster_id) <= 0:
		return "No boosters left."
	match booster_id:
		MonetizationConfig.BOOSTER_MERGE_HINT:
			merge_hint_booster_active = true
			_consume_booster(booster_id)
			return "Merge Hint ready — open Merge arena."
		MonetizationConfig.BOOSTER_LOOT_BURST:
			var added := _grant_loot_burst_seeds()
			_consume_booster(booster_id)
			return "Loot Burst: +%d seeds to bag!" % added
		_:
			return "Unknown booster."


func _consume_booster(booster_id: String) -> void:
	var left := get_booster_count(booster_id) - 1
	if left <= 0:
		booster_inventory.erase(booster_id)
	else:
		booster_inventory[booster_id] = left
	save_player_save()


func _grant_loot_burst_seeds() -> int:
	var added := 0
	for _i in MonetizationConfig.LOOT_BURST_SEEDS:
		var type_id := pick_random_run_seed_type()
		if add_seeds_to_bag(type_id, 1):
			added += 1
	save_player_save()
	return added


func consume_merge_hint_booster() -> bool:
	if not merge_hint_booster_active:
		return false
	merge_hint_booster_active = false
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
			var name: String = get_seed_display_name(type_id)
			return "Hint: merge two %s seeds." % name
	return "Hint: pour seeds and merge matching pairs."
