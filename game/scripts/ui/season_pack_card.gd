class_name SeasonPackCard
extends UiClickButton

## Paid-season card for the Shop 2-col grid (HOME-04 A). Home premium seasons use HomeSeasonCard (2026-09-21).
## Does not call set_active; the Shop decides what a tap does (no-op when owned).

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
