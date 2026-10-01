class_name CosmeticCatalog
extends RefCounted

## Coin-shop kozmetika — cosmetic-only (Pillar 2 Fair F2P).
## Katalog su podaci: res://data/cosmetics/cosmetics.json (design_handoff_wardrobe).
## Novi slot ili stavka = jedan zapis u JSON-u; Ormar, Shop i Pip ga čitaju odavde.

const PATH := "res://data/cosmetics/cosmetics.json"

const SLOT_PIP_SKIN := "pip_skin"
const SLOT_MEADOW_BG := "meadow_bg"
const SLOT_JOURNAL_FRAME := "journal_frame"

const SOURCE_SHOP := "shop"

static var _loaded: bool = false
static var _data: Dictionary = {}
static var _items: Dictionary = {}       # id -> item dict
static var _item_order: Array[String] = []
static var _slots: Dictionary = {}       # id -> slot dict
static var _slot_order: Array[String] = []


static func _ensure() -> void:
	if _loaded:
		return
	_loaded = true
	var parsed: Variant = null
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file != null:
		parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("CosmeticCatalog: could not read %s" % PATH)
		parsed = {}
	load_from_dict(parsed as Dictionary)


## Puni katalog iz rječnika istog oblika kao cosmetics.json (koriste i smoke testovi
## za dokaz proširivosti — 8 slotova / N stavki bez novog koda).
static func load_from_dict(data: Dictionary) -> void:
	_loaded = true
	_data = data
	_items.clear()
	_item_order.clear()
	_slots.clear()
	_slot_order.clear()
	var slot_list: Array = data.get("slots", [])
	slot_list = slot_list.duplicate()
	slot_list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order", 0)) < int(b.get("order", 0)))
	for s in slot_list:
		var sd: Dictionary = s
		var sid := str(sd.get("id", ""))
		if sid.is_empty():
			continue
		_slots[sid] = sd
		_slot_order.append(sid)
	var item_list: Array = data.get("items", [])
	for it in item_list:
		var d: Dictionary = it
		var iid := str(d.get("id", ""))
		if iid.is_empty():
			continue
		_items[iid] = d
		_item_order.append(iid)


## Vraća katalog na cosmetics.json (poslije testa s load_from_dict).
static func reload() -> void:
	_loaded = false
	_ensure()


static func catalog_version() -> int:
	_ensure()
	return int(_data.get("catalog_version", 1))


static func surfaces() -> Dictionary:
	_ensure()
	return _data.get("surfaces", {})


# ── Stavke (stari API — isti potpisi) ─────────────────────────────────────────

static func all_ids() -> Array[String]:
	_ensure()
	return _item_order.duplicate()


static func get_item(item_id: String) -> Dictionary:
	_ensure()
	return _items.get(item_id, {})


static func get_title(item_id: String) -> String:
	return str(get_item(item_id).get("title", item_id))


static func get_description(item_id: String) -> String:
	return str(get_item(item_id).get("description", ""))


static func get_coin_cost(item_id: String) -> int:
	return maxi(0, int(get_item(item_id).get("coin_cost", 0)))


static func get_slot(item_id: String) -> String:
	return str(get_item(item_id).get("slot", ""))


static func get_source(item_id: String) -> String:
	return str(get_item(item_id).get("source", SOURCE_SHOP))


static func is_shop_item(item_id: String) -> bool:
	return get_source(item_id) == SOURCE_SHOP


static func get_look(item_id: String) -> Dictionary:
	return get_item(item_id).get("look", {})


## new_since: verzija kataloga u kojoj je stavka dodata; null/-1 = nije nova.
static func get_new_since(item_id: String) -> int:
	var v: Variant = get_item(item_id).get("new_since", null)
	return -1 if v == null else int(v)


# ── Slotovi ───────────────────────────────────────────────────────────────────

static func slot_ids() -> Array[String]:
	_ensure()
	return _slot_order.duplicate()


static func slots() -> Array[Dictionary]:
	_ensure()
	var out: Array[Dictionary] = []
	for sid in _slot_order:
		out.append(_slots[sid])
	return out


static func get_slot_def(slot_id: String) -> Dictionary:
	_ensure()
	return _slots.get(slot_id, {})


static func slot_applies_to(slot_id: String) -> Array:
	return get_slot_def(slot_id).get("applies_to", [])


## Stavke slota po `order` (sve, i one koje igrač nema).
static func items_in_slot(slot_id: String) -> Array[Dictionary]:
	_ensure()
	var out: Array[Dictionary] = []
	for iid in _item_order:
		var d: Dictionary = _items[iid]
		if str(d.get("slot", "")) == slot_id:
			out.append(d)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order", 0)) < int(b.get("order", 0)))
	return out


# ── Izgled (look) ─────────────────────────────────────────────────────────────

## Mapa zamjene boja za pip_idle.svg ("#A8E6CF" -> "#FFD3DE"); prazna = klasični Pip.
static func get_recolor(item_id: String) -> Dictionary:
	if item_id.is_empty():
		return {}
	return get_look(item_id).get("recolor", {})


static func get_meadow_modulate(item_id: String) -> Color:
	var t: Variant = get_look(item_id).get("tint", null) if not item_id.is_empty() else null
	if t is Array and (t as Array).size() >= 3:
		var a: Array = t
		return Color(float(a[0]), float(a[1]), float(a[2]), 1.0)
	return Color.WHITE


## Title je pečeni PNG (već zlatan) — ovo je modulate množilac, ne apsolutna boja.
static func get_journal_title_color(item_id: String) -> Color:
	var t: Variant = get_look(item_id).get("title_modulate", null) if not item_id.is_empty() else null
	if t is Array and (t as Array).size() >= 3:
		var a: Array = t
		return Color(float(a[0]), float(a[1]), float(a[2]), 1.0)
	return Color.WHITE


## Okvir albuma {color, width, radius}; prazan = bez okvira.
static func get_album_frame(item_id: String) -> Dictionary:
	if item_id.is_empty():
		return {}
	return get_look(item_id).get("frame", {})
