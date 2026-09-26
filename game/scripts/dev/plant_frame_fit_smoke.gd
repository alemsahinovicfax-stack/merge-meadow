extends SceneTree

## Dimenzije plant-frame prenosa: čip, kolizija i okviri ostaju dovoljno veliki
## da biljka stane unutra, a Journal red i dalje stane u 1032 × 200.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var msg := _constants()
	if not msg.is_empty():
		_fail(msg)
		return
	msg = _crop()
	if not msg.is_empty():
		_fail(msg)
		return
	var row := CollectionJournalRow.new()
	get_root().add_child(row)
	row.apply({
		"state": "album_t3",
		"type_id": "clover",
		"rarity": 1,
		"display_name": "Clover",
		"is_new": false,
	})
	await process_frame
	msg = _journal_row(row)
	if not msg.is_empty():
		_fail(msg)
		return
	var packed := load("res://scenes/run/seed_pickup.tscn") as PackedScene
	if packed == null:
		_fail("seed pickup scene missing")
		return
	var pickup := packed.instantiate()
	var shape := pickup.get_node("CollisionShape2D").shape as CircleShape2D
	if shape == null or not is_equal_approx(shape.radius, 26.0):
		_fail("seed collision must stay radius 26")
		return
	pickup.free()
	print("plant_frame_fit_smoke OK")
	quit(0)


func _constants() -> String:
	var diameter := _chip_diameter()
	if not is_equal_approx(diameter, 134.4):
		return "arena chip diameter %.1f, expected 134.4" % diameter
	if UiArena.RIM_BORDER + UiArena.RIM_BAND_T1 != 8:
		return "T1 visible cream must be 8"
	if UiArena.RIM_BORDER + UiArena.RIM_BAND_T2 != 11:
		return "T2 visible cream must be 11"
	if UiArena.HINT_PULSE_W <= float(UiArena.RIM_BORDER + UiArena.RIM_BAND_T2):
		return "hint must be thicker than the T2 cream rim"
	var well_t1 := diameter - float(UiArena.chip_well_inset(1) * 2)
	var well_t2 := diameter - float(UiArena.chip_well_inset(2) * 2)
	if UiArena.FLOWER_SIZE_T1 >= well_t1 - 8.0:
		return "T1 plant %.0f does not fit the well %.0f" % [UiArena.FLOWER_SIZE_T1, well_t1]
	if UiArena.FLOWER_SIZE_T2 >= well_t2 - 8.0:
		return "T2 plant %.0f does not fit the well %.0f" % [UiArena.FLOWER_SIZE_T2, well_t2]
	if not is_equal_approx(CampPlantDraw.FIT_FRAC, 0.36):
		return "Home/basket fit frac must stay 0.36"
	# Red 1032, margine 31+27, razmak 24. Slot 136 mora stati u unutrašnjih 154 px.
	var info_w := 1032.0 - 31.0 - 27.0 - float(UiJournal.ROW_INNER_GAP) - _strip_w()
	if info_w < 480.0:
		return "journal info column %.0f is too narrow" % info_w
	if float(UiJournal.SLOT) > 200.0 - 23.0 - 23.0:
		return "journal slot does not fit the 200 px row"
	if float(UiJournal.ART) > float(UiJournal.SLOT) - 16.0:
		return "journal art does not fit the slot"
	if not _art_fits(float(UiCamp.CHIP_ART_SEED), float(UiCamp.CHIP_ART_FRAME), 3):
		return "camp seed art overflows the frame"
	if not _art_fits(float(UiCamp.CHIP_ART_FLOWER), float(UiCamp.CHIP_ART_FRAME), 3):
		return "camp flower art overflows the frame"
	if not is_equal_approx(float(UiCamp.CHIP_SIZE.x), 489.0) or not is_equal_approx(float(UiCamp.CHIP_SIZE.y), 176.0):
		return "camp chip size changed"
	if not _art_fits(float(UiCamp.TRADE_ART_SEED), float(UiCamp.TRADE_ART), 3):
		return "trade seed art overflows"
	if not _art_fits(float(UiCamp.TRADE_ART_FLOWER), float(UiCamp.TRADE_ART), 3):
		return "trade flower art overflows"
	if not _art_fits(float(UiCamp.SEASON_ART), float(UiCamp.SEASON_ART_FRAME), 2):
		return "season art overflows"
	if UiRun.SEED_FLOWER_SIZE != 120 or UiRun.SEED_PIP_RADIUS != 78:
		return "run plant box or pip radius drifted"
	return ""


## Čita konstante iz fajla da smoke ne kompajlira ArenaSeedChip (GameState autoload).
func _chip_diameter() -> float:
	var text := FileAccess.get_file_as_string("res://scripts/camp/arena_seed_chip.gd")
	var scale := 0.0
	var base := 0.0
	for line in text.split("\n"):
		var trimmed := line.strip_edges()
		if trimmed.begins_with("const DISPLAY_SCALE"):
			scale = float(trimmed.get_slice(":=", 1).strip_edges())
		elif trimmed.begins_with("const CHIP_RADIUS"):
			base = float(trimmed.get_slice("*", 0).get_slice(":=", 1).strip_edges())
	return base * scale * 2.0


func _strip_w() -> float:
	return float(UiJournal.SLOT * 3 + UiJournal.SLOT_GAP * 2)


func _art_fits(art: float, frame: float, border: int) -> bool:
	return art <= frame - float(border * 2) - 4.0


func _crop() -> String:
	var tex := FlowerAssets.get_texture("clover", 1)
	if tex == null:
		return "clover t1 texture missing"
	var image := tex.get_image()
	if image == null:
		return "clover t1 image missing"
	var used := image.get_used_rect()
	if used.size.y >= image.get_height() - 2:
		return "clover t1 crop rect is the full canvas"
	if used.size.y <= used.size.x:
		return "clover t1 crop should be taller than wide"
	return ""


func _journal_row(row: Node) -> String:
	if _find_named(row, "TierLabel") != null:
		return "TierLabel should be gone"
	if _find_named(row, "ArtWell") != null:
		return "ArtWell should be gone"
	var slot := _find_named(row, "SlotBox") as Control
	if slot == null or not is_equal_approx(slot.custom_minimum_size.x, float(UiJournal.SLOT)):
		return "journal slot size"
	var icon := row.call("get_tier_icon", 1) as Control
	if icon == null or not is_equal_approx(icon.size.x, float(UiJournal.ART)):
		return "journal art size"
	return ""


func _find_named(n: Node, wanted: String) -> Node:
	for child in n.get_children():
		if child.name == wanted:
			return child
		var found := _find_named(child, wanted)
		if found != null:
			return found
	return null


func _fail(msg: String) -> void:
	push_error("plant_frame_fit_smoke: %s" % msg)
	quit(1)
