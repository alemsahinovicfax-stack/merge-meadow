extends Node

const SCENE_MAIN := "res://scenes/main_menu.tscn"
const SCENE_RUN := "res://scenes/run/run_scene.tscn"
const SCENE_LOOT := "res://scenes/ui/loot_screen.tscn"
const SCENE_CAMP := "res://scenes/camp/camp_scene.tscn"
const SCENE_SHOP := "res://scenes/ui/shop_screen.tscn"

const CAMP_BED_COUNT := 9
const GREENHOUSE_SLOT_COUNT := 2
const MAX_MERGE_TIER := 2
const MAGNET_MAX_LEVEL := 4
const MAGNET_COST_T2 := 2
const MYTHIC_RARITY := 3

const EXCHANGE_SEED_COUNT := 3
const EXCHANGE_COINS_REWARD := 8

const SEED_TYPE_CLOVER := "clover"

const SEED_DISPLAY_NAMES: Dictionary = {
	SEED_TYPE_CLOVER: "Clover",
}

# Default spawn rarity (★ count). Mythic (3) → staklenik.
const SEED_RARITY: Dictionary = {
	SEED_TYPE_CLOVER: 1,
	"daisy": 1,
	"buttercup": 1,
	"tulip": 2,
	"sunflower": 2,
	"pumpkin": 3,
	"watermelon": 3,
}

const MAGNET_BASE_RADIUS := 40.0
const MAGNET_RADIUS_PER_LEVEL := 48.0

const LOADOUT_SLOT_COUNT := 1
const LOADOUT_SPAWN_BONUS := 0.05

# Playtest — DEBUG seeda samo kad nema save datoteke (prvi boot).
const DEBUG_DEV_RESOURCES := true
const DEBUG_WALLET_COINS := 20
const DEBUG_SEED_COUNT := 20

const TUTORIAL_RUN1_DURATION := 45.0
const TUTORIAL_RUN2_DURATION := 60.0
const POST_TUTORIAL_RUN_DURATION := 60.0

enum TutorialStep { RUN1, CAMP1, RUN2, CAMP_MERGE, FREE }

const TUTORIAL_FLAGS_PATH := "user://tutorial_flags.json"
const PLAYER_SAVE_PATH := "user://player_save.json"
const SAVE_VERSION := 1

var last_seed_bag: Dictionary = {}
var last_run_coins: int = 0
var last_raw_coins: int = 0
var last_loot: int = 0
var wallet_coins: int = 0
var last_failed: bool = false
var last_raw_seed_total: int = 0
var loot_doubled: bool = false
var revive_used_this_run: bool = false

var seed_bag: Dictionary = {}

var resume_pending: bool = false
var carry_seed_bag: Dictionary = {}
var carry_coins: int = 0
var carry_elapsed: float = 0.0
var carry_orbs: int = 0
var carry_seeds: int = 0

# null = prazno; inače { type_id, tier }
var garden_beds: Array = []
var greenhouse_beds: Array = []

var magnet_level: int = 0
var sprinkler_donations: int = 0
var discovered_blooms: Dictionary = {}
var tutorial_step: int = TutorialStep.RUN1
var tutorial_complete: bool = false
var ads_removed: bool = false
var starter_pack_owned: bool = false

# Jedan slot: type_id iz baga → +LOADOUT_SPAWN_BONUS šanse za sjeme u runu.
var loadout_type_id: String = ""


func _ready() -> void:
	# Desktop dev: miš mora ostati miš (emulacija toucha lomi BaseButton.signale).
	Input.emulate_touch_from_mouse = false
	if not load_player_save():
		reset_garden_beds()
		reset_greenhouse_beds()
		_try_migrate_tutorial_flags_only()
		_apply_debug_resources_if_new_game()


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
		"seed_bag": seed_bag.duplicate(),
		"magnet_level": magnet_level,
		"sprinkler_donations": sprinkler_donations,
		"loadout_type_id": loadout_type_id,
		"discovered_blooms": discovered_blooms.duplicate(),
		"garden_beds": _serialize_beds(garden_beds),
		"greenhouse_beds": _serialize_beds(greenhouse_beds),
		"ads_removed": ads_removed,
		"starter_pack_owned": starter_pack_owned,
	}
	var file := FileAccess.open(PLAYER_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GameState: could not write %s" % PLAYER_SAVE_PATH)
		return
	file.store_string(JSON.stringify(data))


func _apply_save_dict(data: Dictionary) -> bool:
	if int(data.get("version", 0)) < SAVE_VERSION:
		return false
	tutorial_complete = bool(data.get("tutorial_complete", false))
	tutorial_step = int(data.get("tutorial_step", TutorialStep.RUN1))
	if tutorial_complete:
		tutorial_step = TutorialStep.FREE
	wallet_coins = maxi(0, int(data.get("wallet_coins", 0)))
	seed_bag = _parse_string_int_dict(data.get("seed_bag", {}))
	magnet_level = clampi(int(data.get("magnet_level", 0)), 0, MAGNET_MAX_LEVEL)
	sprinkler_donations = maxi(0, int(data.get("sprinkler_donations", 0)))
	loadout_type_id = str(data.get("loadout_type_id", ""))
	discovered_blooms = _parse_string_bool_dict(data.get("discovered_blooms", {}))
	garden_beds = _deserialize_beds(data.get("garden_beds", []), CAMP_BED_COUNT)
	greenhouse_beds = _deserialize_beds(data.get("greenhouse_beds", []), GREENHOUSE_SLOT_COUNT)
	ads_removed = bool(data.get("ads_removed", false))
	starter_pack_owned = bool(data.get("starter_pack_owned", false))
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
	seed_bag = {SEED_TYPE_CLOVER: DEBUG_SEED_COUNT}


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


func go_to_camp() -> void:
	deposit_loot_to_camp()
	go_to_scene(SCENE_CAMP)


func get_loadout_type() -> String:
	return loadout_type_id


func format_loadout_label() -> String:
	if loadout_type_id.is_empty():
		return "Basket: empty (tap to equip)"
	var name: String = SEED_DISPLAY_NAMES.get(loadout_type_id, loadout_type_id.capitalize())
	var stars := "★".repeat(get_seed_rarity(loadout_type_id))
	return "Basket: %s %s  (+%.0f%% spawn)" % [name, stars, LOADOUT_SPAWN_BONUS * 100.0]


func set_loadout_from_bag(type_id: String) -> bool:
	if type_id.is_empty():
		return false
	if int(seed_bag.get(type_id, 0)) <= 0:
		return false
	if is_mythic_seed(type_id):
		return false
	loadout_type_id = type_id
	return true


func clear_loadout() -> void:
	loadout_type_id = ""


func toggle_loadout_from_bag() -> String:
	if not loadout_enabled():
		return "Fill your basket later — merge your first flower!"
	if not loadout_type_id.is_empty():
		clear_loadout()
		save_player_save()
		return "Loadout cleared."
	var type_id := first_seed_type_in_bag(false)
	if type_id.is_empty():
		return "No garden seeds in bag for loadout."
	if set_loadout_from_bag(type_id):
		var name: String = SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
		save_player_save()
		return "Equipped %s — more spawns next run!" % name
	return "Could not set loadout."


func ensure_loot_in_camp_bag() -> void:
	if sum_seed_bag(last_seed_bag) > 0:
		deposit_loot_to_camp()


func get_seed_rarity(type_id: String) -> int:
	return int(SEED_RARITY.get(type_id, 1))


func is_mythic_seed(type_id: String) -> bool:
	return get_seed_rarity(type_id) >= MYTHIC_RARITY


func sum_seed_bag(bag: Dictionary) -> int:
	var total := 0
	for count in bag.values():
		total += int(count)
	return total


func format_seed_bag_label() -> String:
	if seed_bag.is_empty():
		return "Seeds in bag: none"
	var parts: PackedStringArray = []
	for type_id in seed_bag:
		var count := int(seed_bag[type_id])
		if count <= 0:
			continue
		var name: String = SEED_DISPLAY_NAMES.get(type_id, str(type_id).capitalize())
		var stars := "★".repeat(get_seed_rarity(type_id))
		parts.append("%d %s %s" % [count, name, stars])
	return "Seeds in bag: " + ", ".join(parts)


func format_collection_label() -> String:
	if discovered_blooms.is_empty():
		return "Collection: none yet"
	var names: PackedStringArray = []
	for type_id in discovered_blooms:
		var name: String = SEED_DISPLAY_NAMES.get(type_id, str(type_id).capitalize())
		names.append(name)
	return "Collection blooms: " + ", ".join(names)


func _halve_seed_bag(bag: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for type_id in bag:
		var n := int(bag[type_id])
		if n > 0:
			# ceil: 1 sjeme na failu ne nestane u 0 (round(0.5)==0 na desktopu).
			out[type_id] = int(ceil(n * 0.5))
	return out


func finish_run(seeds_by_type: Dictionary, raw_coins: int, failed: bool, elapsed: float) -> void:
	last_raw_seed_total = sum_seed_bag(seeds_by_type)
	last_raw_coins = raw_coins
	last_failed = failed
	loot_doubled = false
	carry_seed_bag = seeds_by_type.duplicate()
	carry_coins = raw_coins
	carry_seeds = last_raw_seed_total
	carry_orbs = carry_seeds
	carry_elapsed = elapsed
	if failed:
		last_seed_bag = _halve_seed_bag(seeds_by_type)
		last_run_coins = int(round(raw_coins * 0.5))
	else:
		last_seed_bag = seeds_by_type.duplicate()
		last_run_coins = raw_coins
	last_loot = sum_seed_bag(last_seed_bag)
	wallet_coins += last_run_coins
	_advance_tutorial_after_run()
	save_player_save()


func get_run_duration() -> float:
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
	return not tutorial_complete and tutorial_step == TutorialStep.CAMP1


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
		var display_name: String = SEED_DISPLAY_NAMES.get(type_id, str(type_id).capitalize())
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
		wallet_coins += last_run_coins
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


func add_seeds_to_bag(type_id: String, count: int) -> void:
	if count <= 0:
		return
	seed_bag[type_id] = int(seed_bag.get(type_id, 0)) + count


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
			add_seeds_to_bag(type_id, count)
			deposited += count
		last_seed_bag.erase(type_id)
	last_loot = sum_seed_bag(last_seed_bag)
	save_player_save()
	return deposited


func _bed_array(in_greenhouse: bool) -> Array:
	return greenhouse_beds if in_greenhouse else garden_beds


func _bed_capacity(in_greenhouse: bool) -> int:
	return GREENHOUSE_SLOT_COUNT if in_greenhouse else CAMP_BED_COUNT


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
	var cap := _bed_capacity(in_greenhouse)
	if bed_index < 0 or bed_index >= cap:
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
	for bed in garden_beds:
		if bed == null:
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
	for type_id in seed_bag:
		if int(seed_bag.get(type_id, 0)) >= EXCHANGE_SEED_COUNT:
			return str(type_id)
	return ""


func exchange_seeds_from_bag(type_id: String) -> bool:
	if not take_seeds_from_bag(type_id, EXCHANGE_SEED_COUNT):
		return false
	wallet_coins += EXCHANGE_COINS_REWARD
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


func try_upgrade_magnet() -> bool:
	if magnet_level >= MAGNET_MAX_LEVEL:
		return false
	if sprinkler_donations < MAGNET_COST_T2:
		return false
	sprinkler_donations = 0
	magnet_level += 1
	save_player_save()
	return true


func get_magnet_radius() -> float:
	return MAGNET_BASE_RADIUS + magnet_level * MAGNET_RADIUS_PER_LEVEL
