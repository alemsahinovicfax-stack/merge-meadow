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

const ARENA_PEST_SPEED := 85.0
const ARENA_PEST_EAT_RADIUS := 36.0
const ARENA_PEST_EAT_DURATION := 0.5
const ARENA_PEST_T3_FREEZE := 2.0
const ARENA_PEST_WAKE_DELAY := 0.3
const ARENA_PEST_TARGET_REEVAL := 0.25

const CAMP_BED_COUNT := 9
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

const EXCHANGE_SEED_COUNT := 1
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

## Property (not a plain var) — see seed_bag_domain.gd's header for why:
## ~50 sites in this file plus several external scripts read/write
## GameState.seed_bag directly as a raw Dictionary. The getter returns the
## actual backing Dictionary (not a copy) so in-place mutations like
## `seed_bag[type_id] = x` keep working exactly as before.
var seed_bag: Dictionary:
	get: return seed_bag_domain.bag
	set(value): seed_bag_domain.bag = value
## Property (not a plain var) — arena_leftover_d_smoke.gd and
## game/tools/grant_test_seeds.gd both reset this by name via
## gs.set("_debug_leftover_bag_applied", false) to force a fresh apply.
var _debug_leftover_bag_applied: bool:
	get: return debug._leftover_bag_applied
	set(value): debug._leftover_bag_applied = value
var resume_pending: bool = false
var carry_seed_bag: Dictionary = {}
var carry_coins: int = 0
var carry_elapsed: float = 0.0
var carry_orbs: int = 0
var carry_seeds: int = 0

# null = prazno; inače { type_id, tier }
var garden_beds: Array = []
var greenhouse_beds: Array = []

## Property (not a plain var) — see crystal_stash.gd's header for why:
## camp_controller.gd reads/writes GameState.garden_crystal_stash directly as
## a raw Dictionary. The getter returns the actual backing Dictionary (not a
## copy) so in-place mutations keep working as before — same pattern as
## seed_bag.
var garden_crystal_stash: Dictionary:
	get: return crystal_stash_domain.stash
	set(value): crystal_stash_domain.stash = value

## Extracted domains (plan-arhitektura-refaktor.md Stage 3+). Instantiated in
## _ready(). Facade methods below (owns_cosmetic, use_booster, ...) forward to
## these — external call sites are unchanged.
var cosmetics: Cosmetics
var boosters: Boosters
var companions: Companions
var tutorial: Tutorial
var seed_bag_domain: SeedBagDomain
var crystal_stash_domain: CrystalStashDomain
var bloom_inbox_domain: BloomInboxDomain
var arena_domain: ArenaDomain
var seasons_domain: SeasonsDomain
var save_migrations: SaveMigrations
var debug: GameStateDebug

## Kept as a var (not moved into Boosters) because merge_arena_controller.gd
## reads it directly as GameState.merge_hint_booster_active in two places;
## this getter/setter keeps that working while boosters.merge_hint_active
## stays the single source of truth.
var merge_hint_booster_active: bool:
	get: return boosters.merge_hint_active
	set(value): boosters.merge_hint_active = value

var magnet_level: int = 0
var multiplier_level: int = 0
var discovered_blooms: Dictionary = {}

## Kept as properties (not plain facade methods) because main_menu.gd and
## loot_screen.gd read GameState.tutorial_complete/tutorial_step as raw
## fields, and several functions below (get_run_duration, loadout_enabled,
## ...) do the same internally — the shim lets `tutorial` own the real
## storage without touching every one of those read sites.
var tutorial_complete: bool:
	get: return tutorial.complete
	set(value): tutorial.complete = value
var tutorial_step: int:
	get: return tutorial.step
	set(value): tutorial.step = value

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
var collection_journal_pending: Dictionary = {}

## Properties (not plain vars) — see crystal_stash.gd's header for why: the
## save dict (to_save_dict/apply_from_save) reads/writes these by the same
## names as before Stage 4.7, now shimmed to arena_domain's fields.
var combo_coin_day: String:
	get: return arena_domain.combo_coin_day
	set(value): arena_domain.combo_coin_day = value
var combo_coins_granted_today: int:
	get: return arena_domain.combo_coins_granted_today
	set(value): arena_domain.combo_coins_granted_today = value
var arena_daily_day: String:
	get: return arena_domain.daily_day
	set(value): arena_domain.daily_day = value
var arena_daily_kind: String:
	get: return arena_domain.daily_kind
	set(value): arena_domain.daily_kind = value
var arena_daily_progress: int:
	get: return arena_domain.daily_progress
	set(value): arena_domain.daily_progress = value
var arena_daily_goal: int:
	get: return arena_domain.daily_goal
	set(value): arena_domain.daily_goal = value
var arena_daily_claimed_day: String:
	get: return arena_domain.daily_claimed_day
	set(value): arena_domain.daily_claimed_day = value
var arena_daily_streak: int:
	get: return arena_domain.daily_streak
	set(value): arena_domain.daily_streak = value

## Property (not a plain var) — see bloom_inbox.gd's header for why. Nothing
## external reads this raw today, but the shim keeps the same pattern as
## seed_bag/garden_crystal_stash and lets tests poke the real backing Array.
var bloom_inbox: Array:
	get: return bloom_inbox_domain.inbox
	set(value): bloom_inbox_domain.inbox = value

var meta_hub_active: bool = false
var meta_hub_pending_page: int = MetaHubPages.MAIN
## Properties (not plain vars) — see crystal_stash.gd's header for why: the
## save dict and several UI files (main_menu.gd, season_stage.gd) read/write
## these by the same names as before Stage 4.8, now shimmed to
## seasons_domain's fields.
var active_season_id: String:
	get: return seasons_domain.active_id
	set(value): seasons_domain.active_id = value
var focus_season_id: String:
	get: return seasons_domain.focus_season_id
	set(value): seasons_domain.focus_season_id = value
var home_band: String:
	get: return seasons_domain.home_band
	set(value): seasons_domain.home_band = value
var home_season_field_open: bool:
	get: return seasons_domain.field_open
	set(value): seasons_domain.field_open = value
var home_season_field_id: String:
	get: return seasons_domain.field_id
	set(value): seasons_domain.field_id = value
var paid_strip_focus_id: String:
	get: return seasons_domain.paid_strip_focus_id
	set(value): seasons_domain.paid_strip_focus_id = value
var unlocked_seasons: Array[String]:
	get: return seasons_domain.unlocked
	set(value): seasons_domain.unlocked = value
var owned_paid_seasons: Array[String]:
	get: return seasons_domain.owned_paid
	set(value): seasons_domain.owned_paid = value
var skip_debug_season_unlock: bool = false


func _ready() -> void:
	cosmetics = Cosmetics.new(self)
	boosters = Boosters.new(self)
	companions = Companions.new(self)
	tutorial = Tutorial.new(self)
	seed_bag_domain = SeedBagDomain.new(self)
	crystal_stash_domain = CrystalStashDomain.new(self)
	bloom_inbox_domain = BloomInboxDomain.new(self)
	arena_domain = ArenaDomain.new(self)
	seasons_domain = SeasonsDomain.new(self)
	save_migrations = SaveMigrations.new(self)
	debug = GameStateDebug.new(self)
	# Desktop dev: miš mora ostati miš (emulacija toucha lomi BaseButton.signale).
	Input.emulate_touch_from_mouse = false
	if not load_player_save():
		reset_garden_beds()
		reset_greenhouse_beds()
		tutorial.migrate_legacy_flags()
		debug.apply_resources_if_new_game()
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
		"wallet_coins": wallet_coins,
		"wallet_diamonds": wallet_diamonds,
		"magnet_level": magnet_level,
		"multiplier_level": multiplier_level,
		"loadout_type_id": loadout_type_id,
		"discovered_blooms": discovered_blooms.duplicate(),
		"garden_beds": _serialize_beds(garden_beds),
		"greenhouse_beds": _serialize_beds(greenhouse_beds),
		"ads_removed": ads_removed,
		"starter_pack_owned": starter_pack_owned,
		"run_level": run_level,
		"endless_runs_completed": endless_runs_completed,
		"endless_difficulty": endless_difficulty,
		"seed_unlock_index": seed_unlock_index,
		"lifetime_seeds_collected": lifetime_seeds_collected.duplicate(),
		"collection_kept_tiers": collection_kept_tiers.duplicate(),
		"last_daily_chest_day": last_daily_chest_day,
		"collection_journal_pending": collection_journal_pending.duplicate(),
	}
	data.merge(cosmetics.to_save_dict())
	data.merge(boosters.to_save_dict())
	data.merge(companions.to_save_dict())
	data.merge(tutorial.to_save_dict())
	data.merge(seed_bag_domain.to_save_dict())
	data.merge(crystal_stash_domain.to_save_dict())
	data.merge(bloom_inbox_domain.to_save_dict())
	data.merge(arena_domain.to_save_dict())
	data.merge(seasons_domain.to_save_dict())
	var file := FileAccess.open(PLAYER_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GameState: could not write %s" % PLAYER_SAVE_PATH)
		return
	file.store_string(JSON.stringify(data))


func t3_flower_count() -> int:
	return get_garden_crystal_total()


## Facade forwards to SeasonsDomain (Stage 4.8) — names/signatures kept
## identical to before extraction so external call sites (season_stage.gd
## alone makes 71 GameState.* calls) and the debug_*/Stage-7 functions below
## don't change.
func star3_type_ids_for_season(season_id: String) -> Array[String]:
	return seasons_domain.star3_type_ids_for_season(season_id)


func star3_type_id_for_season(season_id: String) -> String:
	return seasons_domain.star3_type_id_for_season(season_id)


func star3_flower_count_for_season(season_id: String) -> int:
	return seasons_domain.star3_flower_count_for_season(season_id)


func previous_free_id_for(season_id: String) -> String:
	return seasons_domain.previous_free_id_for(season_id)


func star3_flower_count_for_unlock(season_id: String) -> int:
	return seasons_domain.star3_flower_count_for_unlock(season_id)


func get_season_def(season_id: String) -> SeasonDef:
	return seasons_domain.get_def(season_id)


func is_season_unlocked_free(season_id: String) -> bool:
	return seasons_domain.is_unlocked_free(season_id)


func is_test_locked_season(season_id: String) -> bool:
	return seasons_domain.is_test_locked(season_id)


func is_season_playable(season_id: String) -> bool:
	return seasons_domain.is_playable(season_id)


func is_free_selectable(season_id: String) -> bool:
	return seasons_domain.is_free_selectable(season_id)


func can_unlock_free(season_id: String) -> bool:
	return seasons_domain.can_unlock_free(season_id)


func unlock_free(season_id: String) -> bool:
	return seasons_domain.unlock_free(season_id)


func set_active_season(season_id: String, sync_strip: bool = true) -> bool:
	return seasons_domain.set_active(season_id, sync_strip)


func grant_paid_season(season_id: String) -> bool:
	return seasons_domain.grant_paid(season_id)


func list_playable_season_ids() -> Array[String]:
	return seasons_domain.list_playable_ids()


func next_locked_free_id() -> String:
	return seasons_domain.next_locked_free_id()


func reset_seasons_to_s1() -> void:
	seasons_domain.reset_to_s1()


func clear_owned_paid_seasons() -> void:
	seasons_domain.clear_owned_paid()


func _normalize_season_progress() -> void:
	seasons_domain.normalize_progress()


func highest_unlocked_free_id() -> String:
	return seasons_domain.highest_unlocked_free_id()


func last_playable_for_home_select() -> String:
	return seasons_domain.last_playable_for_home_select()


func home_hero_center_id() -> String:
	return seasons_domain.home_hero_center_id()


func can_open_home_season_field() -> bool:
	return seasons_domain.can_open_home_season_field()


func open_home_season_field() -> bool:
	return seasons_domain.open_home_season_field()


func close_home_season_field() -> void:
	seasons_domain.close_home_season_field()


func set_home_band(band: String) -> void:
	seasons_domain.set_home_band(band)


func set_paid_strip_focus(season_id: String) -> bool:
	return seasons_domain.set_paid_strip_focus(season_id)


func set_free_strip_focus(season_id: String) -> bool:
	return seasons_domain.set_free_strip_focus(season_id)


func strip_center_id() -> String:
	return seasons_domain.strip_center_id()


func strip_left_id() -> String:
	return seasons_domain.strip_left_id()


func strip_right_id() -> String:
	return seasons_domain.strip_right_id()


func is_strip_right_locked() -> bool:
	return seasons_domain.is_strip_right_locked()


func cycle_free_strip(dir: int) -> bool:
	return seasons_domain.cycle_free_strip(dir)


func paid_center_id() -> String:
	return seasons_domain.paid_center_id()


func paid_left_id() -> String:
	return seasons_domain.paid_left_id()


func paid_right_id() -> String:
	return seasons_domain.paid_right_id()


func cycle_paid_strip(dir: int) -> bool:
	return seasons_domain.cycle_paid_strip(dir)


## Facade forwards to GameStateDebug (Stage 7) — names/signatures kept
## identical, since apply_debug_leftover_test_bag()/
## _try_apply_debug_leftover_test_bag() are called from live production
## code (merge_arena_controller.gd) and by name via gs.call(...) from
## several dev smoke scripts, not just other debug tooling.
func debug_unlock_all_seasons() -> void:
	debug.unlock_all_seasons()


func debug_grant_unlock_test_funds() -> void:
	debug.grant_unlock_test_funds()


func debug_playtest_two_free() -> void:
	debug.playtest_two_free()


func debug_relock_playtest_free() -> void:
	debug.relock_playtest_free()


func debug_fixture_s1_star3_playtest() -> void:
	debug.fixture_s1_star3_playtest()


func _apply_save_dict(data: Dictionary) -> bool:
	var version := int(data.get("version", 0))
	if version < 1:
		return false
	tutorial.apply_from_save(data)
	wallet_coins = maxi(0, int(data.get("wallet_coins", 0)))
	# SAVE_VERSION 8 — older saves default to 0 diamonds.
	wallet_diamonds = maxi(0, int(data.get("wallet_diamonds", 0)))
	seed_bag_domain.apply_from_save(data)
	magnet_level = clampi(int(data.get("magnet_level", 0)), 0, MAGNET_MAX_LEVEL)
	multiplier_level = clampi(int(data.get("multiplier_level", 0)), 0, MULTIPLIER_MAX_LEVEL)
	loadout_type_id = str(data.get("loadout_type_id", ""))
	discovered_blooms = _parse_string_bool_dict(data.get("discovered_blooms", {}))
	garden_beds = _deserialize_beds(data.get("garden_beds", []), CAMP_BED_COUNT)
	greenhouse_beds = _deserialize_beds(data.get("greenhouse_beds", []), GREENHOUSE_SLOT_COUNT)
	crystal_stash_domain.apply_from_save(data)
	cosmetics.apply_from_save(data)
	boosters.apply_from_save(data)
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
	save_migrations.drop_retired_seed_keys()
	collection_kept_tiers = _parse_string_int_dict(data.get("collection_kept_tiers", {}))
	last_daily_chest_day = str(data.get("last_daily_chest_day", ""))
	arena_domain.apply_from_save(data)
	companions.apply_from_save(data)
	collection_journal_pending = _parse_string_int_dict(data.get("collection_journal_pending", {}))
	bloom_inbox_domain.apply_from_save(data)
	seasons_domain.apply_from_save(data)
	_normalize_season_progress()
	if int(data.get("version", 0)) < SAVE_VERSION:
		save_migrations.migrate_legacy_beds_to_inbox()
	_clear_legacy_beds()
	_refresh_seed_unlock_from_lifetime()
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


func apply_debug_leftover_test_bag() -> bool:
	return debug.apply_leftover_test_bag()


func _try_apply_debug_leftover_test_bag(dev_enabled: bool) -> bool:
	return debug.try_apply_leftover_test_bag(dev_enabled)


## Dev/playtest — min. count po otključanom tipu (ignorira soft cap u torbi).
func ensure_dev_unlocked_seeds(count_per_type: int = 10) -> void:
	debug.ensure_dev_unlocked_seeds(count_per_type)


## Facade forwards to Tutorial (Stage 4.2) — names/signatures unchanged.
func mark_tutorial_complete() -> void:
	tutorial.mark_complete()


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
	tutorial.mark_arena_pest_shown()


func should_show_arena_pest_tutorial() -> bool:
	return tutorial.should_show_arena_pest()


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
	return tutorial.should_prompt_merge()


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
	return seed_bag_domain.format_label()


func get_seed_bag_entries() -> Array[Dictionary]:
	return seed_bag_domain.entries()


func get_garden_crystal_entries() -> Array[Dictionary]:
	return crystal_stash_domain.entries()


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
	tutorial.advance_after_run()
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
	return tutorial.is_run1()


func is_tutorial_run2() -> bool:
	return tutorial.is_run2()


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


## Facade forwards to SeedBagDomain (Stage 4.3) — names/signatures unchanged.
func add_seeds_to_bag(type_id: String, count: int) -> int:
	return seed_bag_domain.add(type_id, count)


func add_seeds_to_bag_unbounded(type_id: String, count: int) -> int:
	return seed_bag_domain.add_unbounded(type_id, count)


func seed_bag_remaining_capacity() -> int:
	return seed_bag_domain.remaining_capacity()


func take_seeds_from_bag(type_id: String, count: int) -> bool:
	return seed_bag_domain.take(type_id, count)


func take_seed_from_bag(type_id: String) -> bool:
	return seed_bag_domain.take_one(type_id)


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


func _today_key() -> String:
	var d := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]


func try_grant_arena_combo_coins() -> int:
	return arena_domain.grant_combo_coins()


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


func ensure_arena_daily_task() -> void:
	arena_domain.ensure_daily_task()


func note_arena_daily_event(kind: String) -> void:
	arena_domain.note_daily_event(kind)


func can_claim_arena_daily() -> bool:
	return arena_domain.can_claim_daily()


func claim_arena_daily() -> String:
	return arena_domain.claim_daily()


func get_arena_daily_hud_text() -> String:
	return arena_domain.get_daily_hud_text()


func get_arena_daily_home_line() -> String:
	return arena_domain.get_daily_home_line()


## _bed_array/garden_beds/greenhouse_beds survive only to support
## save_migrations.migrate_legacy_beds_to_inbox() — the bed-merge gameplay these once
## backed was superseded by the Arena chip-merge system
## (merge_arena_controller.gd) and had zero live callers left (plan-arhitektura-refaktor.md
## Stage 4.4, confirmed 2026-09-07: no controller/UI referenced plant_seed_in_bed,
## try_merge_beds, keep_bloom_from_bed, or any bed-index accessor).
func _bed_array(in_greenhouse: bool) -> Array:
	return greenhouse_beds if in_greenhouse else garden_beds


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


func exchange_seeds_from_bag(type_id: String, save: bool = true) -> bool:
	var bag_count := int(seed_bag.get(type_id, 0))
	var take := seed_exchange_take_count(bag_count)
	if take <= 0:
		return false
	var coins := seed_exchange_coins_for_take(take, type_id)
	if not take_seeds_from_bag(type_id, take):
		return false
	_add_coins(coins)
	if save:
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


## Facade forwards to Companions (Stage 4.1) — names/signatures unchanged.
func is_companion_unlocked(companion_id: String) -> bool:
	return companions.is_unlocked(companion_id)


func get_active_companion_id() -> String:
	return companions.get_active_id()


func get_companion_display_name(companion_id: String = "") -> String:
	return companions.display_name(companion_id)


func format_mochi_unlock_hint() -> String:
	return companions.format_mochi_unlock_hint()


func try_set_active_companion(companion_id: String) -> String:
	return companions.try_set_active(companion_id)


func poll_mochi_unlock_toast() -> String:
	return companions.poll_mochi_unlock_toast()


func _clear_legacy_beds() -> void:
	garden_beds.clear()
	greenhouse_beds.clear()


func count_bloom_inbox(min_tier: int = 2) -> int:
	return bloom_inbox_domain.count(min_tier)


func push_bloom_inbox(type_id: String, tier: int) -> bool:
	if not bloom_inbox_domain.push(type_id, tier):
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


func keep_bloom_inbox(index: int) -> bool:
	return bloom_inbox_domain.keep_at(index)


func flush_bloom_inbox_to_album() -> int:
	return bloom_inbox_domain.flush_to_album()


func is_arena_pour_locked(type_id: String) -> bool:
	return arena_domain.is_pour_locked(type_id)


func lock_arena_pour_type(type_id: String) -> void:
	arena_domain.lock_pour_type(type_id)


func unlock_arena_pour_type(type_id: String) -> void:
	arena_domain.unlock_pour_type(type_id)


func clear_arena_pour_locks() -> void:
	arena_domain.clear_pour_locks()


func pull_seeds_to_arena(max_count: int, _field_type_counts: Dictionary = {}) -> Array:
	return arena_domain.pull_seeds(max_count, _field_type_counts)


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


func stash_garden_crystal(type_id: String) -> void:
	if type_id.is_empty():
		return
	discovered_blooms[type_id] = true
	# Arena T3 auto-stashes — unlock Album T3 (player cannot Keep the chip).
	var prev_kept := int(collection_kept_tiers.get(type_id, 0))
	collection_kept_tiers[type_id] = maxi(prev_kept, MAX_MERGE_TIER)
	_mark_collection_journal_new(type_id, MAX_MERGE_TIER)
	crystal_stash_domain.add(type_id)
	save_player_save()


func get_garden_crystal_total() -> int:
	return crystal_stash_domain.total()


func format_garden_crystal_stash_label() -> String:
	return crystal_stash_domain.format_label()


func first_garden_crystal_type() -> String:
	return crystal_stash_domain.first_type()


func exchange_garden_crystal(type_id: String = "", save: bool = true) -> bool:
	if type_id.is_empty():
		type_id = first_garden_crystal_type()
	if type_id.is_empty():
		return false
	if not crystal_stash_domain.take_one(type_id):
		return false
	_add_coins(crystal_exchange_coins_for_type(type_id))
	if save:
		save_player_save()
	return true


func sum_seed_bag_only() -> int:
	return seed_bag_domain.sum()


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
	return arena_domain.try_merge_chips(chip_a, chip_b, chip_data)


## Resolve one arena leftover chip. Never silently drops T2+ (Bug-016).
## Returns: bagged | crystal | recycled | skipped
func resolve_arena_leftover_bloom(type_id: String, tier: int) -> String:
	return arena_domain.resolve_leftover_bloom(type_id, tier)


func commit_arena_chips_to_bag(chip_data: Dictionary) -> Dictionary:
	return arena_domain.commit_chips_to_bag(chip_data)


## Facade forwards to Cosmetics/Boosters (Stage 3) — names/signatures kept
## identical to before extraction so external call sites don't change.
func owns_cosmetic(cosmetic_id: String) -> bool:
	return cosmetics.owns(cosmetic_id)


func is_cosmetic_equipped(cosmetic_id: String) -> bool:
	return cosmetics.is_equipped(cosmetic_id)


func get_equipped_cosmetic(slot: String) -> String:
	return cosmetics.get_equipped(slot)


func buy_cosmetic_with_coins(cosmetic_id: String) -> String:
	return cosmetics.buy_with_coins(cosmetic_id)


func equip_cosmetic(cosmetic_id: String) -> bool:
	return cosmetics.equip(cosmetic_id)


func get_cosmetic_shop_entries() -> Array[Dictionary]:
	return cosmetics.shop_entries()


func get_booster_count(booster_id: String) -> int:
	return boosters.count(booster_id)


func add_booster(booster_id: String, count: int = 1) -> void:
	boosters.add(booster_id, count)


func use_booster(booster_id: String) -> String:
	return boosters.use(booster_id)


func consume_merge_hint_booster() -> bool:
	return boosters.consume_merge_hint()


func get_merge_hint_message(chip_data: Dictionary) -> String:
	return boosters.get_merge_hint_message(chip_data)
