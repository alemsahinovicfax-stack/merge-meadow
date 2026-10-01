## Cosmetics domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 3). Owned by GameState as `cosmetics`; GameState keeps facade methods
## with the original names (owns_cosmetic, buy_cosmetic_with_coins, ...) that
## forward here, so none of the 38 external GameState call sites change.
class_name Cosmetics
extends RefCounted

var owned: Dictionary = {}
var equipped: Dictionary = {}
## Zadnja verzija kataloga koju je igrač vidio u Ormaru (WardrobeDot / tab "new").
## Novi ključ, opcionalan — stari save bez njega = 0.
var wardrobe_seen: int = 0

## Untyped on purpose — needs dynamic access to GameState members that aren't
## part of the Node API (save_player_save, _try_spend_coins). See
## game/test/unit/game_state_test_base.gd for the same pattern/reasoning.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func apply_from_save(data: Dictionary) -> void:
	owned = SaveDictUtils.parse_string_bool_dict(data.get("owned_cosmetics", {}))
	equipped = SaveDictUtils.parse_string_string_dict(data.get("equipped_cosmetics", {}))
	wardrobe_seen = maxi(0, int(data.get("wardrobe_seen", 0)))


func to_save_dict() -> Dictionary:
	return {
		"owned_cosmetics": owned.duplicate(),
		"equipped_cosmetics": equipped.duplicate(),
		"wardrobe_seen": wardrobe_seen,
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
	var changed := str(equipped.get(slot, "")) != cosmetic_id
	equipped[slot] = cosmetic_id
	_owner.save_player_save()
	if changed:
		_emit_changed([slot])
	return true


## Default u slotu = nema ključa (save format isti kao prije).
func unequip(slot: String) -> bool:
	if not equipped.has(slot):
		return false
	equipped.erase(slot)
	_owner.save_player_save()
	_emit_changed([slot])
	return true


## Ormar: `pending` = {slot: id}; slot bez ključa = Default. Jedan save za sve
## promjene, pa signal s listom promijenjenih slotova. Stavke koje igrač nema
## se ignorišu (ostaje ono što je bilo).
func apply_wardrobe(pending: Dictionary) -> Array:
	var changed: Array = []
	for slot in CosmeticCatalog.slot_ids():
		var want := str(pending.get(slot, ""))
		if not want.is_empty() and (not owns(want) or CosmeticCatalog.get_slot(want) != slot):
			continue
		if get_equipped(slot) == want:
			continue
		if want.is_empty():
			equipped.erase(slot)
		else:
			equipped[slot] = want
		changed.append(slot)
	if not changed.is_empty():
		_owner.save_player_save()
		_emit_changed(changed)
	return changed


## Nova stavka = tvoja stavka čiji je new_since veći od zadnje viđene verzije.
func is_new(cosmetic_id: String) -> bool:
	return owns(cosmetic_id) and CosmeticCatalog.get_new_since(cosmetic_id) > wardrobe_seen


func has_new() -> bool:
	for item_id in owned:
		if is_new(str(item_id)):
			return true
	return false


func mark_wardrobe_seen() -> void:
	var v := CosmeticCatalog.catalog_version()
	if v <= wardrobe_seen:
		return
	wardrobe_seen = v
	_owner.save_player_save()


func _emit_changed(slots: Array) -> void:
	if _owner is Object and (_owner as Object).has_signal("cosmetics_changed"):
		(_owner as Object).emit_signal("cosmetics_changed", slots)


func shop_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item_id in CosmeticCatalog.all_ids():
		out.append({"id": item_id})
	return out
