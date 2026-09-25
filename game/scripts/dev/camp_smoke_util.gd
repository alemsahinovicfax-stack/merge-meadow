class_name CampSmokeUtil
extends RefCounted

## Zajednicko za camp_*_smoke: backup/restore pravog save-a (Camp na izlazu
## flushuje trade save) i provjera chipa iz design_handoff_camp.

const SAVE_PATH := "user://player_save.json"


static func backup_save() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return ""
	return FileAccess.get_file_as_string(SAVE_PATH)


static func restore_save(tree: SceneTree, backup: String) -> void:
	if backup.is_empty():
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(backup)
		f.close()
	var gs := tree.get_root().get_node_or_null("GameState")
	if gs:
		gs.call("load_player_save")


## Chip: art lijevo, ime bez zvjezdica, ★ pips, count pa price pill ("each").
static func chip_error(chip: Control, kind: String) -> String:
	if chip == null:
		return "%s chip missing" % kind
	if not chip.has_method("get_kind") or str(chip.call("get_kind")) != kind:
		return "%s chip must be CampStashChip of kind %s" % [kind, kind]
	var min_h := chip.custom_minimum_size.y
	# v2: i rezervisan chip je 176 px (badge stoji u redu pipsa).
	if not is_equal_approx(min_h, 176.0):
		return "%s chip min_h %s (expected 176)" % [kind, str(min_h)]
	var art := chip.find_child("ArtFrame", true, false) as Control
	if art == null or art.custom_minimum_size.x < 128.0:
		return "%s ArtFrame must be 128 px" % kind
	var name_lab := chip.find_child("ChipName", true, false) as Label
	if name_lab == null or name_lab.text.is_empty():
		return "%s ChipName missing" % kind
	if name_lab.text.find("★") >= 0:
		return "%s name must not include stars, got '%s'" % [kind, name_lab.text]
	var pips := chip.find_child("RarityPips", true, false) as Label
	var reserved := chip.has_method("is_reserved") and bool(chip.call("is_reserved"))
	if pips == null or (not reserved and (pips.text.length() != 3 or pips.text.count("★") < 1)):
		return "%s RarityPips must read like ★★☆, got '%s'" % [kind, pips.text if pips else ""]
	if reserved and pips.visible:
		return "%s reserved chip shows the badge instead of pips" % kind
	var count_pill := chip.find_child("CountPill", true, false) as Control
	var price_pill := chip.find_child("PricePill", true, false) as Control
	# v2: "each" je obrisan — novcic + broj na zlatnoj pilulici znaci cijenu po komadu.
	if count_pill == null or price_pill == null:
		return "%s CountPill / PricePill missing" % kind
	if chip.find_child("EachLabel", true, false) != null:
		return "%s price pill must not say 'each'" % kind
	if name_lab.global_position.x <= art.global_position.x:
		return "%s name must sit right of art" % kind
	if price_pill.global_position.x <= count_pill.global_position.x:
		return "%s price pill must sit right of count pill" % kind
	if count_pill.size.y < 51.0:
		return "%s pill height %s < 52" % [kind, str(count_pill.size.y)]
	return ""
