## Cosmetics domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 3). Owned by GameState as `cosmetics`; GameState keeps facade methods
## with the original names (owns_cosmetic, buy_cosmetic_with_coins, ...) that
## forward here, so none of the 38 external GameState call sites change.
class_name Cosmetics
extends RefCounted

var owned: Dictionary = {}
var equipped: Dictionary = {}

## Untyped on purpose — needs dynamic access to GameState members that aren't
## part of the Node API (save_player_save, _try_spend_coins). See
## game/test/unit/game_state_test_base.gd for the same pattern/reasoning.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func apply_from_save(data: Dictionary) -> void:
	owned = SaveDictUtils.parse_string_bool_dict(data.get("owned_cosmetics", {}))
	equipped = SaveDictUtils.parse_string_string_dict(data.get("equipped_cosmetics", {}))


func to_save_dict() -> Dictionary:
	return {
		"owned_cosmetics": owned.duplicate(),
		"equipped_cosmetics": equipped.duplicate(),
	}


func owns(cosmetic_id: String) -> bool:
	return bool(owned.get(cosmetic_id, false))


func is_equipped(cosmetic_id: String) -> bool:
	if not owns(cosmetic_id):
		return false
	var slot := CosmeticCatalog.get_slot(cosmetic_id)
	return str(equipped.get(slot, "")) == cosmetic_id


func get_equipped(slot: String) -> String:
	var item_id := str(equipped.get(slot, ""))
	if item_id.is_empty() or not owns(item_id):
		return ""
	return item_id


func buy_with_coins(cosmetic_id: String) -> String:
	if cosmetic_id.is_empty() or CosmeticCatalog.get_item(cosmetic_id).is_empty():
		return "Unknown item."
	if owns(cosmetic_id):
		equip(cosmetic_id)
		return "%s equipped." % CosmeticCatalog.get_title(cosmetic_id)
	var cost: int = CosmeticCatalog.get_coin_cost(cosmetic_id)
	if not _owner._try_spend_coins(cost):
		return "Need %d coins." % cost
	owned[cosmetic_id] = true
	equip(cosmetic_id)
	_owner.save_player_save()
	return "Purchased %s!" % CosmeticCatalog.get_title(cosmetic_id)


func equip(cosmetic_id: String) -> bool:
	if not owns(cosmetic_id):
		return false
	var slot := CosmeticCatalog.get_slot(cosmetic_id)
	if slot.is_empty():
		return false
	equipped[slot] = cosmetic_id
	_owner.save_player_save()
	return true


func shop_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item_id in CosmeticCatalog.all_ids():
		out.append({"id": item_id})
	return out
