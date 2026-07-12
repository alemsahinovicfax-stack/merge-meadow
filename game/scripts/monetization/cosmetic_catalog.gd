class_name CosmeticCatalog
extends RefCounted

## Coin-shop kozmetika — cosmetic-only (Pillar 2 Fair F2P).

const SLOT_PIP_SKIN := "pip_skin"
const SLOT_MEADOW_BG := "meadow_bg"
const SLOT_JOURNAL_FRAME := "journal_frame"

const ITEMS: Dictionary = {
	"pip_blossom": {
		"title": "Pip Blossom",
		"description": "Soft pink accents for Pip in runs.",
		"coin_cost": 250,
		"slot": SLOT_PIP_SKIN,
	},
	"pip_sky": {
		"title": "Pip Sky",
		"description": "Cool blue palette for Pip.",
		"coin_cost": 200,
		"slot": SLOT_PIP_SKIN,
	},
	"meadow_sunset": {
		"title": "Sunset Meadow",
		"description": "Warm golden lane background tint.",
		"coin_cost": 150,
		"slot": SLOT_MEADOW_BG,
	},
	"meadow_lavender": {
		"title": "Lavender Meadow",
		"description": "Soft purple lane mood.",
		"coin_cost": 180,
		"slot": SLOT_MEADOW_BG,
	},
	"journal_gold": {
		"title": "Golden Album",
		"description": "Gold accents on the Bloom Album.",
		"coin_cost": 120,
		"slot": SLOT_JOURNAL_FRAME,
	},
}


static func all_ids() -> Array[String]:
	var out: Array[String] = []
	for item_id in ITEMS:
		out.append(str(item_id))
	return out


static func get_item(item_id: String) -> Dictionary:
	return ITEMS.get(item_id, {})


static func get_title(item_id: String) -> String:
	return str(get_item(item_id).get("title", item_id))


static func get_description(item_id: String) -> String:
	return str(get_item(item_id).get("description", ""))


static func get_coin_cost(item_id: String) -> int:
	return maxi(0, int(get_item(item_id).get("coin_cost", 0)))


static func get_slot(item_id: String) -> String:
	return str(get_item(item_id).get("slot", ""))


static func get_pip_palette(item_id: String) -> Dictionary:
	match item_id:
		"pip_blossom":
			return {
				"body": Color(0.98, 0.92, 0.96, 1.0),
				"ear": Color(0.95, 0.78, 0.88, 1.0),
				"ear_inner": Color(1.0, 0.72, 0.82, 1.0),
				"outline": Color(0.55, 0.35, 0.45, 0.9),
			}
		"pip_sky":
			return {
				"body": Color(0.9, 0.96, 1.0, 1.0),
				"ear": Color(0.72, 0.86, 0.98, 1.0),
				"ear_inner": Color(0.82, 0.92, 1.0, 1.0),
				"outline": Color(0.32, 0.45, 0.62, 0.9),
			}
		_:
			return {}


static func get_meadow_modulate(item_id: String) -> Color:
	match item_id:
		"meadow_sunset":
			return Color(1.08, 0.94, 0.86, 1.0)
		"meadow_lavender":
			return Color(0.94, 0.92, 1.06, 1.0)
		_:
			return Color.WHITE


static func get_journal_title_color(item_id: String) -> Color:
	if item_id == "journal_gold":
		return Color(1.0, 0.88, 0.35, 1.0)
	return Color(1.0, 0.92, 0.55, 1.0)
