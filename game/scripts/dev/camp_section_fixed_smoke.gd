extends SceneTree

## design_handoff_camp_v2: sekcija Seeds / Flowers ima uvijek istu visinu i stoji
## prikovana uz karticu sezone (razmak tacno 20 px). Prije v2 je razmak rastao s
## 215 na 375 px kad bi sadrzaja bilo manje — to je rupa koju ovaj test cuva.

const HUB_PAGE := Vector2(1080.0, 1597.0)
const TOL := 1.5
const SECTION_H := 1253.0
const SECTION_H_NO_SEASON := 1549.0
const MANY: Array[String] = [
	"clover", "daisy", "buttercup", "tulip", "sunflower", "pumpkin",
	"frost_snowdrop", "ice_crocus", "silver_aconite", "winter_camellia",
	"hoarfrost_rose", "crystal_peony", "copper_leaf", "maple_aster",
]

var _backup: String = ""


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("camp_section_fixed_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _settle() -> void:
	for _i in 6:
		await process_frame


func _bag(types: int) -> Dictionary:
	var out := {}
	for i in mini(types, MANY.size()):
		out[MANY[i]] = 4
	return out


## Sekcija mora biti iste visine i tacno 20 px ispod kartice sezone.
func _check(camp: Control, what: String, hero: bool) -> String:
	var section := camp.get_node("%StashSection") as Control
	var card := camp.get_node("%SeasonLinkCard") as Control
	var bar := camp.get_node("%ExchangeBar") as Control
	var want := SECTION_H if hero else SECTION_H_NO_SEASON
	if absf(section.size.y - want) > TOL:
		return "%s: section %s expected %s" % [what, str(section.size.y), str(want)]
	var page_top := camp.global_position.y
	if hero:
		if not card.visible:
			return "%s: hero card should be visible" % what
		if absf(section.global_position.y - (card.get_global_rect().end.y + 20.0)) > TOL:
			return "%s: gap must be exactly 20 px, got %.1f" % [
				what, section.global_position.y - card.get_global_rect().end.y
			]
	elif absf(section.global_position.y - (page_top + 24.0)) > TOL:
		return "%s: section must start at page padding" % what
	if absf(section.get_global_rect().end.y - (page_top + HUB_PAGE.y - 24.0)) > TOL:
		return "%s: section must end on the bottom padding" % what
	if bar.get_global_rect().end.y > section.get_global_rect().end.y + TOL:
		return "%s: Trade bar must stay inside the section" % what
	return ""


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		_fail("camp scene load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	var gs := get_root().get_node_or_null("GameState")
	if camp == null or gs == null:
		_fail("camp / GameState missing")
		return
	camp.call("set_meta_hub_mode", true)
	camp.set_anchors_preset(Control.PRESET_TOP_LEFT)
	camp.size = HUB_PAGE
	gs.call("reset_seasons_to_s1")
	gs.set("garden_crystal_stash", {})

	# Prazno, 1, 8 i 14 tipova — ista sekcija, isti razmak.
	for types in [0, 1, 8, 14]:
		gs.set("seed_bag", _bag(int(types)))
		camp.call("refresh_for_meta_hub")
		await _settle()
		var e := _check(camp, "%d types" % int(types), true)
		if not e.is_empty():
			_fail(e)
			return

	# Strip upozorenja mijenja Trade bar, ali ne i sekciju.
	gs.set("seed_bag", {})
	gs.set("garden_crystal_stash", {"pumpkin": 23, "clover": 2})
	camp.call("_on_tab_pressed", "flowers")
	camp.set("_force_default_crystal_select", true)
	camp.call("_refresh_crystal_card")
	camp.call("_on_crystal_chip_pressed", "pumpkin")
	await _settle()
	var bar := camp.get_node("%ExchangeBar") as Control
	if bar.size.y < 152.0 - TOL:
		_fail("Trade bar should be at least 152 px, got %s" % str(bar.size.y))
		return
	var warn := _check(camp, "reserved flower", true)
	if not warn.is_empty():
		_fail(warn)
		return

	# Bez kartice sezone sekcija uzima cijelu stranicu.
	var unlocked: Array = gs.get("unlocked_seasons")
	for id in ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy"]:
		if not unlocked.has(id):
			unlocked.append(id)
	gs.set("unlocked_seasons", unlocked)
	gs.set("seed_bag", _bag(3))
	camp.call("_on_tab_pressed", "seeds")
	camp.call("refresh_for_meta_hub")
	await _settle()
	var no_hero := _check(camp, "no season card", false)
	if not no_hero.is_empty():
		_fail(no_hero)
		return

	CampSmokeUtil.restore_save(self, _backup)
	print("camp_section_fixed_smoke OK")
	quit(0)
