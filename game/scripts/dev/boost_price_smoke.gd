extends SceneTree

## FIX-TEL-3 (2026-11-12, na zahtjev) — cijene Boostova (Magnet / Loot Boost / Twin Seeds) po
## levelu, u T3 cvjetovima sezone iz stasha:
##   level 1 = 5 × prvi ljubičasti (★2), level 2 = 10 × drugi ljubičasti (★2),
##   level 3 = 2 × zlatni (★3), level 4 = 5 × zlatni (★3). Coini uz to ostaju 100 / 250 / 500 / 800.
## I pragovi sezona (Journey): Frost 30, Lantern 35, Amber 40 ★3 cvjetova prethodne sezone;
## Themes (plaćene sezone) nemaju prag u cvijeću.

const EXPECT := {
	"country_bloom": ["tulip", "sunflower", "pumpkin", "pumpkin"],
	"frost_orchard": ["winter_camellia", "hoarfrost_rose", "crystal_peony", "crystal_peony"],
	"lantern_meadow": ["foxfire_lily", "glow_wisteria", "midnight_lotus", "midnight_lotus"],
	"amber_canopy": ["cider_dahlia", "golden_oak_bloom", "amber_magnolia", "amber_magnolia"],
	"moonlit_warren": ["lunar_orchid", "star_jasmine", "umbral_lily", "umbral_lily"],
	"coral_tide": ["coral_hibiscus", "pearl_waterlily", "reef_crown", "reef_crown"],
	"starfall_glade": ["aurora_tulip", "galaxy_sunburst", "nova_bloom", "nova_bloom"],
	"ember_fen": ["flame_iris", "smoke_lotus", "fenfire_crown", "fenfire_crown"],
}
const COSTS := [5, 10, 2, 5]
const COINS := [100, 250, 500, 800]
const UNLOCK := {"frost_orchard": 30, "lantern_meadow": 35, "amber_canopy": 40}

var _backup := ""
var _failed := false


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("boost_price_smoke: %s" % msg)


func _run() -> void:
	var gs: Node = root.get_node("GameState")
	await process_frame
	# Tabela cijena.
	if int(UiCamp.UP_LEVELS) != 4:
		_fail("boosts should have 4 levels")
	for lv in 4:
		if UiCamp.upgrade_flower_cost(lv) != COSTS[lv]:
			_fail("level %d should cost %d flowers, got %d" % [lv + 1, COSTS[lv], UiCamp.upgrade_flower_cost(lv)])
		if UiCamp.upgrade_coin_cost(lv) != COINS[lv]:
			_fail("level %d should still cost %d coins, got %d" % [lv + 1, COINS[lv], UiCamp.upgrade_coin_cost(lv)])
	for season_id in EXPECT:
		for lv in 4:
			var got := str(gs.call("upgrade_flower_type", season_id, lv))
			if got != str(EXPECT[season_id][lv]):
				_fail("%s level %d should be paid in %s, got %s" % [season_id, lv + 1, EXPECT[season_id][lv], got])
			if int(gs.call("get_seed_rarity", got)) != (2 if lv < 2 else 3):
				_fail("%s level %d flower %s has the wrong rarity" % [season_id, lv + 1, got])

	# Kupovina kroz sva četiri levela u Country Bloomu: troši pravu vrstu i pravi broj.
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.call("set_active_season", "country_bloom")
	gs.set("season_upgrades", {})
	gs.set("magnet_level", 0)
	gs.set("multiplier_level", 0)
	gs.call("apply_active_upgrade_levels")
	gs.set("wallet_coins", 100000)
	gs.set("garden_crystal_stash", {"pumpkin": 50})
	if str(gs.call("upgrade_button_state", "magnet", "country_bloom")) != "short_flower":
		_fail("level 1 needs the first purple flower — 50 gold ones must not count (state %s)" % gs.call("upgrade_button_state", "magnet", "country_bloom"))
	if bool(gs.call("try_upgrade_magnet")):
		_fail("level 1 must not be buyable with gold flowers only")
	var stash := {"tulip": 5, "sunflower": 10, "pumpkin": 7}
	gs.set("garden_crystal_stash", stash.duplicate())
	var spent_type := ["tulip", "sunflower", "pumpkin", "pumpkin"]
	var left := stash.duplicate()
	var coins := 100000
	for lv in 4:
		if str(gs.call("upgrade_button_state", "magnet", "country_bloom")) != "can":
			_fail("level %d should be buyable, state %s" % [lv + 1, gs.call("upgrade_button_state", "magnet", "country_bloom")])
		if not bool(gs.call("try_upgrade_magnet")):
			_fail("level %d purchase failed" % (lv + 1))
			break
		left[spent_type[lv]] = int(left[spent_type[lv]]) - COSTS[lv]
		coins -= COINS[lv]
		var now: Dictionary = gs.get("garden_crystal_stash")
		for type_id in left:
			if int(now.get(type_id, 0)) != int(left[type_id]):
				_fail("after level %d stash %s should be %d, got %d" % [lv + 1, type_id, left[type_id], int(now.get(type_id, 0))])
		if int(gs.get("wallet_coins")) != coins:
			_fail("after level %d coins should be %d, got %d" % [lv + 1, coins, int(gs.get("wallet_coins"))])
		if int(gs.call("get_upgrade_level", "magnet", "country_bloom")) != lv + 1:
			_fail("magnet level should be %d" % (lv + 1))
	if str(gs.call("upgrade_button_state", "magnet", "country_bloom")) != "max":
		_fail("after four levels the boost is maxed")
	# Nedovoljno: 4 od 5 prvog ljubičastog.
	gs.set("garden_crystal_stash", {"tulip": 4, "sunflower": 99, "pumpkin": 99})
	if str(gs.call("upgrade_button_state", "loot", "country_bloom")) != "short_flower":
		_fail("4 of 5 first-purple flowers should be short")
	# Coini fale.
	gs.set("garden_crystal_stash", {"tulip": 5})
	gs.set("wallet_coins", 99)
	if str(gs.call("upgrade_button_state", "loot", "country_bloom")) != "short_coin":
		_fail("99 coins should be short for level 1 (100)")

	# Kept napomena: ★2 leveli ne diraju ono što čeka sljedeća sezona, ★3 leveli da.
	gs.set("wallet_coins", 100000)
	gs.set("season_upgrades", {})
	gs.set("magnet_level", 0)
	gs.set("multiplier_level", 0)
	gs.call("apply_active_upgrade_levels")
	gs.set("garden_crystal_stash", {"tulip": 5, "pumpkin": 30})
	if bool(gs.call("upgrade_uses_kept_flowers", "country_bloom")):
		_fail("level 1 is paid in purple flowers — it must not touch the gold ones saved for Frost Orchard")
	gs.set("season_upgrades", {"country_bloom": {"magnet": 2, "loot": 0, "twin": 0}})
	gs.call("apply_active_upgrade_levels")
	if not bool(gs.call("upgrade_uses_kept_flowers", "country_bloom")):
		_fail("level 3 costs 2 gold flowers: 30 - 2 is under the 30 Frost Orchard needs")

	# Pragovi sezona.
	for season_id in UNLOCK:
		var def: Object = gs.call("get_season_def", season_id)
		if int(def.get("t3_flowers_required")) != int(UNLOCK[season_id]):
			_fail("%s should need %d flowers, got %d" % [season_id, UNLOCK[season_id], int(def.get("t3_flowers_required"))])
	for season_id in ["moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]:
		var pdef: Object = gs.call("get_season_def", season_id)
		if int(pdef.get("t3_flowers_required")) != 0:
			_fail("theme %s must not need flowers" % season_id)

	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("boost_price_smoke OK")
	quit(1 if _failed else 0)
