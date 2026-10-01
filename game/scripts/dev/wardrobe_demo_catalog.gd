extends RefCounted

## Dev/test: demo zakrpa kataloga Ormara (design_handoff_wardrobe/design/wardrobe_data.js
## → DEMO, demoN). SAMO podaci — ne ulazi u cosmetics.json. Dokaz proširivosti:
## 8 slotova / 12 Pip skinova / N stavki bez ijedne linije novog UI koda.


static func base() -> Dictionary:
	var f := FileAccess.open(CosmeticCatalog.PATH, FileAccess.READ)
	return JSON.parse_string(f.get_as_text()) as Dictionary


static func _lighten(hex: String, k: float) -> String:
	var c := Color(hex)
	return "#" + Color(c.r + (1.0 - c.r) * k, c.g + (1.0 - c.g) * k, c.b + (1.0 - c.b) * k).to_html(false).to_upper()


static func _pip(id: String, title: String, body: String, order: int, extra: Dictionary = {}) -> Dictionary:
	var d := {
		"id": id, "slot": "pip_skin", "title": title, "description": "", "coin_cost": 0,
		"source": "shop", "order": order, "new_since": null,
		"look": {"recolor": {"#A8E6CF": body, "#D4F5E4": _lighten(body, 0.6)}},
	}
	d.merge(extra, true)
	return d


static func _slot(id: String, title: String, order: int, preview: String, args: Dictionary, applies: Array, default_title: String, toast: String, empty: String) -> Dictionary:
	return {
		"id": id, "title": title, "icon": "res://demo/slot_%s.svg" % id, "order": order,
		"preview": preview, "preview_args": args, "applies_to": applies, "allow_default": true,
		"default_title": default_title, "toast": toast, "empty_text": empty,
	}


static func _item(id: String, slot: String, title: String, order: int, look: Dictionary) -> Dictionary:
	return {"id": id, "slot": slot, "title": title, "order": order, "source": "shop", "new_since": null, "look": look}


## cosmetics.json + 5 slotova + 10 Pip skinova (jedan source: season, jedan new_since: 2).
static func catalog() -> Dictionary:
	var cat := base()
	var slots: Array = cat["slots"]
	slots.append(_slot("mochi_skin", "Mochi", 40, "companion", {"subject": "mochi"}, ["camp", "run", "run_hud"], "Classic Mochi", "Mochi wears {title}", "Mochi's looks come from the Shop."))
	slots.append(_slot("album_paper", "Paper", 50, "album", {}, ["journal"], "Cream paper", "Your Album uses {title}", "Album papers come from the Shop."))
	slots.append(_slot("basket_cloth", "Cloth", 60, "swatch", {}, ["arena"], "Peach cloth", "Your basket wears {title}", "Basket cloths come from the Shop."))
	slots.append(_slot("gift_ribbon", "Ribbon", 70, "swatch", {}, ["field"], "Cream ribbon", "Gifts wear {title}", "Ribbons come from the Shop."))
	slots.append(_slot("combo_ring", "Ring", 80, "swatch", {}, ["arena"], "Cream ring", "Combos ring in {title}", "Combo rings come from the Shop."))
	var items: Array = cat["items"]
	items.append_array([
		_pip("demo_pip_peach", "Pip Peach", "#FFD9C4", 30), _pip("demo_pip_lilac", "Pip Lilac", "#E9D6FF", 40),
		_pip("demo_pip_butter", "Pip Butter", "#FFF1BA", 50), _pip("demo_pip_lime", "Pip Lime", "#DDF3B5", 60),
		_pip("demo_pip_coral", "Pip Coral", "#FFD3C9", 70), _pip("demo_pip_snow", "Pip Snow", "#F2F5F8", 80),
		_pip("demo_pip_oat", "Pip Oat", "#F0DFCC", 90), _pip("demo_pip_aqua", "Pip Aqua", "#C6F0EC", 100),
		_pip("demo_pip_honey", "Pip Honey", "#FFE3A8", 110, {"new_since": 2}),
		_pip("demo_pip_frost", "Pip Frost", "#DCE6EE", 120, {"source": "season", "source_ref": "frost_orchard"}),
		_item("demo_mochi_cocoa", "mochi_skin", "Mochi Cocoa", 10, {"recolor": {"#EBE6F0": "#F0DFCC"}}),
		_item("demo_mochi_snow", "mochi_skin", "Mochi Snow", 20, {"recolor": {"#EBE6F0": "#F7F9FB"}}),
		_item("demo_paper_mint", "album_paper", "Mint paper", 10, {"paper": "#E3F6EC"}),
		_item("demo_paper_sky", "album_paper", "Sky paper", 20, {"paper": "#E6F1FC"}),
		_item("demo_cloth_mint", "basket_cloth", "Mint cloth", 10, {"colors": ["#A8E6CF", "#7FC9AC"]}),
		_item("demo_cloth_lilac", "basket_cloth", "Lilac cloth", 20, {"colors": ["#D4A5FF", "#AA84CC"]}),
		_item("demo_ribbon_gold", "gift_ribbon", "Gold ribbon", 10, {"colors": ["#FFD56B", "#D6A82F"]}),
		_item("demo_ribbon_pink", "gift_ribbon", "Pink ribbon", 20, {"colors": ["#FFCCD5", "#E89AAA"]}),
		_item("demo_ring_gold", "combo_ring", "Gold ring", 10, {"colors": ["#FFD56B"]}),
	])
	return cat


static func owned() -> Dictionary:
	var out := {"pip_blossom": true, "meadow_sunset": true, "meadow_lavender": true, "journal_gold": true}
	for id in ["demo_pip_peach", "demo_pip_lilac", "demo_pip_butter", "demo_pip_lime", "demo_pip_coral",
			"demo_pip_snow", "demo_pip_oat", "demo_pip_aqua", "demo_pip_honey", "demo_mochi_cocoa",
			"demo_paper_mint", "demo_cloth_mint", "demo_cloth_lilac", "demo_ribbon_gold", "demo_ring_gold"]:
		out[id] = true
	return out


## Slot Pip zamijenjen s N generisanih skinova (pravilo mreže 1 / 5 / 30).
static func catalog_n(n: int) -> Dictionary:
	var cat := base()
	var items: Array = []
	for it in cat["items"]:
		if str(it.get("slot", "")) != "pip_skin":
			items.append(it)
	for i in n:
		var h := fmod(float(i) * 0.618034, 1.0)
		var c := Color.from_hsv(h, 0.2, 1.0)
		items.append(_pip("n_pip_%d" % i, "Pip No. %d" % (i + 1), "#" + c.to_html(false).to_upper(), 10 + i))
	cat["items"] = items
	return cat


static func owned_n(n: int) -> Dictionary:
	var out := {}
	for i in n:
		out["n_pip_%d" % i] = true
	return out
