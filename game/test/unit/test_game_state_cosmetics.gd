## Ormar (design_handoff_wardrobe): Cosmetics.apply_wardrobe / unequip / "new".
## Save format se ne mijenja — Default = nema ključa u equipped_cosmetics.
extends "res://test/unit/game_state_test_base.gd"

var _owned_before: Dictionary
var _equipped_before: Dictionary
var _seen_before: int
var _signals: Array = []


func before_each() -> void:
	super.before_each()
	_owned_before = _gs.cosmetics.owned.duplicate()
	_equipped_before = _gs.cosmetics.equipped.duplicate()
	_seen_before = _gs.cosmetics.wardrobe_seen
	_gs.cosmetics.owned = {"pip_blossom": true, "meadow_sunset": true}
	_gs.cosmetics.equipped = {}
	_signals = []
	_gs.cosmetics_changed.connect(_on_changed)


func after_each() -> void:
	_gs.cosmetics_changed.disconnect(_on_changed)
	_gs.cosmetics.owned = _owned_before
	_gs.cosmetics.equipped = _equipped_before
	_gs.cosmetics.wardrobe_seen = _seen_before
	CosmeticCatalog.reload()
	super.after_each()


func _on_changed(slots: Array) -> void:
	_signals.append(slots)


func test_apply_wardrobe_changes_slots_and_emits_once() -> void:
	var changed: Array = _gs.apply_wardrobe({"pip_skin": "pip_blossom", "meadow_bg": "meadow_sunset"})
	assert_eq(changed.size(), 2, "both slots changed")
	assert_eq(_gs.get_equipped_cosmetic("pip_skin"), "pip_blossom")
	assert_eq(_signals.size(), 1, "one cosmetics_changed for the whole wardrobe")


func test_apply_wardrobe_default_erases_key() -> void:
	_gs.cosmetics.equipped = {"pip_skin": "pip_blossom"}
	var changed: Array = _gs.apply_wardrobe({})
	assert_eq(changed, ["pip_skin"], "only pip_skin changed")
	assert_false(_gs.cosmetics.equipped.has("pip_skin"), "Default = missing key")


func test_apply_wardrobe_ignores_unowned_and_wrong_slot() -> void:
	var changed: Array = _gs.apply_wardrobe({"pip_skin": "pip_sky", "meadow_bg": "pip_blossom"})
	assert_eq(changed.size(), 0, "nothing the player does not own, nothing in the wrong slot")
	assert_eq(_signals.size(), 0, "no signal when nothing changed")


func test_unequip_returns_to_default() -> void:
	_gs.cosmetics.equipped = {"meadow_bg": "meadow_sunset"}
	assert_true(_gs.unequip_cosmetic("meadow_bg"))
	assert_eq(_gs.get_equipped_cosmetic("meadow_bg"), "")
	assert_false(_gs.unequip_cosmetic("meadow_bg"), "second unequip is a no-op")


func test_new_flag_follows_catalog_version() -> void:
	var cat: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CosmeticCatalog.PATH))
	cat["catalog_version"] = 2
	for it in cat["items"]:
		if it["id"] == "pip_blossom":
			it["new_since"] = 2
	CosmeticCatalog.load_from_dict(cat)
	_gs.cosmetics.wardrobe_seen = 1
	assert_true(_gs.cosmetics.is_new("pip_blossom"))
	assert_true(_gs.cosmetics.has_new())
	_gs.cosmetics.mark_wardrobe_seen()
	assert_false(_gs.cosmetics.has_new(), "seen after the wardrobe closes")


func test_save_keeps_old_format() -> void:
	_gs.cosmetics.equipped = {"pip_skin": "pip_blossom"}
	var d: Dictionary = _gs.cosmetics.to_save_dict()
	assert_eq(d["owned_cosmetics"], {"pip_blossom": true, "meadow_sunset": true})
	assert_eq(d["equipped_cosmetics"], {"pip_skin": "pip_blossom"})
