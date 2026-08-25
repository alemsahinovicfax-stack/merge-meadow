class_name SeasonPackCard
extends UiClickButton

## Shared paid-season card — Shop 2-col grid and Browser Premium row (HOME-04 A).
## Does not call set_active; parents decide tap (Shop no-op when owned, Browser select).

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

var sku: String = ""


func apply(pack_sku: String) -> void:
	sku = pack_sku
	set_meta("season_sku", pack_sku)
	font_size = 20
	label_autowrap = true
	var title := CONFIG.get_product_title(pack_sku)
	var owned := IAPManager.owns_product(pack_sku)
	if owned:
		label_text = "%s\nOwned" % title
		button_variant = "primary"
		disabled = false
	else:
		label_text = "%s\n%s" % [title, IAPManager.get_price_label(pack_sku)]
		button_variant = "accent"
		disabled = IAPManager.is_busy()
