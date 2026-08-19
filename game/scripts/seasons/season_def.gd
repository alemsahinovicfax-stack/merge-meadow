class_name SeasonDef
extends RefCounted

## Catalog row — loaded from res://data/seasons/seasons.json.

const KIND_FREE := "free"
const KIND_PAID := "paid"

var id: String = ""
var kind: String = KIND_FREE
var order: int = -1
var display_name: String = ""
var tagline: String = ""
var coins_cost: int = 0
var t3_flowers_required: int = 0
var iap_product_id: String = ""
var seed_type_ids: Array[String] = []
var thumbnail_path: String = ""
var run_bg_path: String = ""
var animal_skin_id: String = ""
var obstacle_theme_id: String = ""
var clear_rabbit_id: String = ""


func is_free() -> bool:
	return kind == KIND_FREE


func is_paid() -> bool:
	return kind == KIND_PAID


static func from_dict(data: Dictionary) -> SeasonDef:
	var def := SeasonDef.new()
	def.id = str(data.get("id", "")).strip_edges()
	var raw_kind := str(data.get("kind", KIND_FREE)).strip_edges()
	def.kind = KIND_PAID if raw_kind == KIND_PAID else KIND_FREE
	if def.is_paid():
		def.order = -1
	else:
		def.order = maxi(1, int(data.get("order", 1)))
	def.display_name = str(data.get("display_name", def.id))
	def.tagline = str(data.get("tagline", ""))
	def.coins_cost = maxi(0, int(data.get("coins_cost", 0)))
	def.t3_flowers_required = maxi(0, int(data.get("t3_flowers_required", 0)))
	def.iap_product_id = str(data.get("iap_product_id", ""))
	def.thumbnail_path = str(data.get("thumbnail_path", ""))
	def.run_bg_path = str(data.get("run_bg_path", ""))
	def.animal_skin_id = str(data.get("animal_skin_id", ""))
	def.obstacle_theme_id = str(data.get("obstacle_theme_id", ""))
	def.clear_rabbit_id = str(data.get("clear_rabbit_id", ""))
	var seeds: Variant = data.get("seed_type_ids", [])
	if seeds is Array:
		for item in seeds:
			var type_id := str(item).strip_edges()
			if not type_id.is_empty() and not def.seed_type_ids.has(type_id):
				def.seed_type_ids.append(type_id)
	return def
