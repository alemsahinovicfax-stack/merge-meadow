extends Node

const SCENE_MAIN := "res://scenes/main_menu.tscn"
const SCENE_RUN := "res://scenes/run/run_scene.tscn"
const SCENE_LOOT := "res://scenes/ui/loot_screen.tscn"
const SCENE_CAMP := "res://scenes/camp/camp_scene.tscn"

const CAMP_SLOT_COUNT := 9
const MAX_MERGE_TIER := 2
const MAGNET_MAX_LEVEL := 4
const MAGNET_COST_T2 := 2

# Magnet efekt u runu: domet automatskog skupljanja orbova (px).
const MAGNET_BASE_RADIUS := 40.0
const MAGNET_RADIUS_PER_LEVEL := 48.0

var last_loot: int = 0
var last_failed: bool = false
var last_raw_orbs: int = 0
var loot_doubled: bool = false
var revive_used_this_run: bool = false

var camp_slots: Array[int] = []
var magnet_level: int = 0
var tutorial_seen: bool = false


func _ready() -> void:
	camp_slots.resize(CAMP_SLOT_COUNT)
	reset_camp_slots()


func reset_camp_slots() -> void:
	for i in CAMP_SLOT_COUNT:
		camp_slots[i] = 0


func go_to_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)


func finish_run(raw_orbs: int, failed: bool) -> void:
	last_raw_orbs = raw_orbs
	last_failed = failed
	loot_doubled = false
	revive_used_this_run = false
	if failed:
		last_loot = int(round(raw_orbs * 0.5))
	else:
		last_loot = raw_orbs


func double_loot_placeholder() -> bool:
	if loot_doubled or last_loot <= 0:
		return false
	last_loot *= 2
	loot_doubled = true
	return true


func revive_placeholder() -> bool:
	if not last_failed or revive_used_this_run:
		return false
	revive_used_this_run = true
	last_loot = last_raw_orbs
	return true


func deposit_loot_to_camp() -> int:
	var deposited := 0
	var remaining := last_loot
	for i in CAMP_SLOT_COUNT:
		if remaining <= 0:
			break
		if camp_slots[i] == 0:
			camp_slots[i] = 1
			remaining -= 1
			deposited += 1
	last_loot = remaining
	return deposited


func try_merge_slots(index_a: int, index_b: int) -> bool:
	if index_a == index_b:
		return false
	var tier_a := camp_slots[index_a]
	var tier_b := camp_slots[index_b]
	if tier_a == 0 or tier_b == 0:
		return false
	if tier_a != tier_b:
		return false
	if tier_a >= MAX_MERGE_TIER:
		return false
	camp_slots[index_b] = tier_a + 1
	camp_slots[index_a] = 0
	return true


func count_tier(tier: int) -> int:
	var total := 0
	for slot_tier in camp_slots:
		if slot_tier == tier:
			total += 1
	return total


func empty_camp_slots() -> int:
	var total := 0
	for slot_tier in camp_slots:
		if slot_tier == 0:
			total += 1
	return total


func try_upgrade_magnet() -> bool:
	if magnet_level >= MAGNET_MAX_LEVEL:
		return false
	if count_tier(2) < MAGNET_COST_T2:
		return false
	var removed := 0
	for i in CAMP_SLOT_COUNT:
		if removed >= MAGNET_COST_T2:
			break
		if camp_slots[i] == 2:
			camp_slots[i] = 0
			removed += 1
	magnet_level += 1
	return true


func get_magnet_radius() -> float:
	return MAGNET_BASE_RADIUS + magnet_level * MAGNET_RADIUS_PER_LEVEL


func mark_tutorial_seen() -> void:
	tutorial_seen = true
