class_name SeedUnlockConfig
extends RefCounted

## Linear seed unlock chain — lifetime on previous type unlocks next; coins skip grind.

const CHAIN: Array[String] = [
	"clover",
	"daisy",
	"buttercup",
	"tulip",
	"sunflower",
	"pumpkin",
	"watermelon",
]

# CHAIN[i] lifetime collected → unlock CHAIN[i + 1]
const LIFETIME_TO_UNLOCK_NEXT: Array[int] = [10, 10, 10, 12, 12, 15, 15]

# Coins to unlock CHAIN[i] early (CHAIN[0] always free at start)
const COIN_UNLOCK_COST: Array[int] = [0, 120, 150, 150, 180, 200, 220]

# Almanac tier milestones — lifetime seeds collected for this type (T1 = spawn unlocked)
const ALMANAC_TIER2_LIFETIME := 10
const ALMANAC_TIER3_LIFETIME := 25


static func chain_size() -> int:
	return CHAIN.size()


static func get_type_at_index(index: int) -> String:
	if index < 0 or index >= CHAIN.size():
		return ""
	return str(CHAIN[index])


static func get_index(type_id: String) -> int:
	return CHAIN.find(type_id)


static func lifetime_required_to_unlock_next(unlock_index: int) -> int:
	if unlock_index < 0 or unlock_index >= LIFETIME_TO_UNLOCK_NEXT.size():
		return 999999
	return int(LIFETIME_TO_UNLOCK_NEXT[unlock_index])


static func coin_cost_to_unlock_index(target_index: int) -> int:
	if target_index < 0 or target_index >= COIN_UNLOCK_COST.size():
		return 999999
	return int(COIN_UNLOCK_COST[target_index])
