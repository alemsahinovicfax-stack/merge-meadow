class_name UiShopV2
extends RefCounted

## Shop v2 — design_handoff_shop_v2/README.md · design/ShopScreen.dc.html
## Px baze 1080x1920. Stranica 1633 između headera 143 i footera 144 (hub chrome v2).
## Ravne boje, jedna tvrda sjena (shadow_size 1 + offset), bez blura/glowa/gradijenata.
## Paste iz paketa; funkcije ispod su prilagođene stvarnom API-ju igre (GameState, IAPManager).

# --- Boje ---
const PAGE := Color("#FBEDD7")
const AWNING_A := Color("#A8E6CF")
const AWNING_B := Color("#FFF8F0")
const CARD := Color("#FFFFFF")
const CARD_YOURS := Color("#FFF6D6")
const INK := Color("#2D3436")
const INK_NAME_SEASON := Color("#1A1A14")
const INK_SUB := Color("#555C5E")
const TAB_ACTIVE := Color("#FFB88C")
const COINS := Color("#FFD56B")
const COINS_SHORT := Color("#F1EAE0")
const MONEY := Color("#D4A5FF")
const MONEY_SOFT := Color("#EAD2FF")
const PLAY := Color("#FFB88C")
const OWNED := Color("#A8E6CF")
const STATUS_FAIL_BG := Color("#FFCCD5")
const STATUS_PENDING_BG := Color("#FFE8B8")
const COIN_TILE := Color("#FFE8B8")
const SEED_TILE := Color("#DCF5EC")
const HINT_BAND := Color("#DCF5EC")
const VEIL := Color(0.890, 0.851, 0.800, 0.84)
const DISC := Color("#FFF8F0")
const SHADOW_CARD := Color(0.102, 0.102, 0.078, 0.22)
const SHADOW_BUTTON := Color(0.102, 0.102, 0.078, 0.28)

# --- Mjere ---
const PAGE_H := 1633
const PAGE_PAD_X := 24
const CONTENT_TOP := 196
const CONTENT_BOTTOM := 64
const CARD_GAP := 32
const LOOKS_SLOT_GAP := 44
const CARD_W := 1032
const RADIUS_CARD := 36
const RADIUS_PREVIEW := 24
const RADIUS_BUTTON := 60
const BORDER := 4
const SHADOW_CARD_Y := 10
const SHADOW_BUTTON_Y := 8

const TABBAR_H := 172
const AWNING_STRIPE_W := 60
const AWNING_H := 160
const TAB_X0 := 24
const TAB_Y := 10
const TAB_W := 249
const TAB_H := 120
const TAB_STEP := 261
const T_TAB := 0.2
const TAB_SLIDE_PX := 48

const BUTTON_H := 120
const BUTTON_MIN_W := 280
const FONT_NAME := 52
const FONT_PRICE := 52
const FONT_PRICE_LONG := 44
const PRICE_LONG_CHARS := 7
const FONT_TAB := 44
const FONT_SUB := 36
const FONT_STATUS := 34

const SEASON_CARD_H := 364
const PORTRAIT_D := 148
const PORTRAIT_D_STAR3 := 172
const PORTRAIT_ART := 0.78
const PREVIEW_SIZE := Vector2(984, 300)
const LOOT_VISUAL_H := 260
const LOOT_PORTRAIT := 204
const STARTER_DAYS := 7

const T_PRESS := 0.08
const T_POP := 0.22
const T_SHAKE := 0.32
const T_CONFIRM_TIMEOUT := 3.0
const T_COIN_POP := 0.7
const T_TOAST := 1.6
const T_BUSY_DOT := 0.9          # jedini loop

const HINT_FRAME := 156
const HINT_ARM := 40
const HINT_INK_W := 18
const HINT_BAND_W := 10
const HINT_HYSTERESIS := 24.0
const T_HINT_IN := 0.18
const T_HINT_MOVE := 0.14
const T_HINT_OUT := 0.12

# --- Tekst (strings_en iz exporta) ---
const S_COMING_SOON := "Coming soon"
const S_PLAY := "Play"
const S_YOURS := "Yours"
const S_WEARING := "Wearing"
const S_OWNED := "Owned"
const S_ADS_OFF := "Ads off"
const S_CLAIMED := "Claimed"
const S_EXPIRED := "Expired"
const S_MERGE_HINT := "Merge Hint"
const S_MERGE_HINT_SUB := "Marks the closest match"
const S_LOOT_BURST := "Loot Burst"
const S_REMOVE_ADS := "Remove Ads"
const S_REMOVE_ADS_SUB := "No ads between runs"
const S_STARTER_PACK := "Starter Pack"
const S_RESTORE := "Restore purchases"
const S_FAILED := "Didn’t go through"
const S_RESTORING := "Restoring…"
const S_WARDROBE := "Wardrobe"
const S_ALL_SET := "All set here"
const S_TOAST_RESTORED := "Purchases restored"
const S_TOAST_ADS := "Ads are off"
const S_TOAST_PACK := "Pack added"
const S_TOAST_LOOT := "+5 %s"

const TABS: Array[String] = ["seasons", "looks", "boosters", "support"]
const TAB_LABELS: Array[String] = ["Seasons", "Looks", "Boosters", "Support"]

# --- Stanja dugmeta ---
const COINS_BUY := "coins.buy"
const COINS_CONFIRM := "coins.confirm"
const COINS_SHORT_STATE := "coins.short"
const MONEY_BUY := "money.buy"
const MONEY_BUSY := "money.busy"
const MONEY_DIM := "money.dim"
const PLAY_STATE := "play"
const OWNED_STATE := "owned"

const STARTER_AVAILABLE := "available"
const STARTER_BUSY := "busy"
const STARTER_BOUGHT := "bought"
const STARTER_EXPIRED := "expired"


static func price_font_px(text: String) -> int:
	return FONT_PRICE_LONG if text.length() > PRICE_LONG_CHARS else FONT_PRICE


## Pravi novac: jedna kupovina u isto vrijeme.
static func money_state(sku: String, busy_sku: String, pending: bool, restoring: bool) -> String:
	if IAPManager.owns_product(sku):
		return OWNED_STATE
	if busy_sku == sku:
		return MONEY_BUSY
	if busy_sku != "" or restoring or pending or IAPManager.is_busy():
		return MONEY_DIM
	return MONEY_BUY


static func cosmetic_state(item: Dictionary, confirm_id: String) -> String:
	var id: String = str(item.get("id", ""))
	if GameState.owns_cosmetic(id):
		return OWNED_STATE
	if confirm_id == id:
		return COINS_CONFIRM
	if GameState.wallet_coins >= int(item.get("coin_cost", 0)):
		return COINS_BUY
	return COINS_SHORT_STATE


static func season_state(def: SeasonDef, busy_sku: String, pending: bool, restoring: bool) -> String:
	if GameState.is_test_locked_season(def.id) or def.iap_product_id.is_empty():
		return "soon"
	if IAPManager.owns_product(def.iap_product_id):
		return PLAY_STATE
	return money_state(def.iap_product_id, busy_sku, pending, restoring)


static func starter_state(busy_sku: String) -> String:
	if GameState.starter_pack_owned:
		return STARTER_BOUGHT
	if GameState.is_starter_pack_expired():
		return STARTER_EXPIRED
	return STARTER_BUSY if busy_sku == MonetizationConfig.SKU_STARTER_PACK else STARTER_AVAILABLE


static func starter_time_text() -> String:
	var s: int = GameState.starter_pack_seconds_left()
	if s >= 86400:
		return "%dd left" % ceili(s / 86400.0)
	return "%dh left" % maxi(1, ceili(s / 3600.0))


## purchase_failed reason -> [tekst, boja]. [] = samo refresh.
static func status_for(reason: String) -> Array:
	match reason:
		"purchase_cancelled":
			return ["Cancelled", STATUS_FAIL_BG]
		"purchase_pending", "ack_failed":
			return ["Pending", STATUS_PENDING_BG]
		"already_owned", "busy", "test_locked", "expired", "unavailable":
			return []
		_:
			return ["Didn’t go through", STATUS_FAIL_BG]


# --- Merge Hint u Areni ---

## Najbliža ista sjemenka (tip + tier, centar–centar); histereza čuva trenutnu dok
## nova nije bliža za >= 24 px. chips = ArenaSeedChip (type_id, tier, get_center()).
static func merge_hint_target(held: Node, chips: Array, current: Node) -> Node:
	var held_pos: Vector2 = held.call("get_center")
	var best: Node = null
	var bd := INF
	for c in chips:
		if c == held or not is_instance_valid(c):
			continue
		if c.type_id != held.type_id or c.tier != held.tier:
			continue
		var d: float = held_pos.distance_to(c.call("get_center"))
		if d < bd:
			bd = d
			best = c
	if current != null and is_instance_valid(current) and best != current and current != held \
			and current.type_id == held.type_id and current.tier == held.tier:
		var dc: float = held_pos.distance_to(current.call("get_center"))
		if dc - bd < HINT_HYSTERESIS:
			return current
	return best


## 4 kutne zagrade: prvo ink traka (18), pa svijetla (10). Poziva se iz merge_hint_mark.gd _draw().
static func draw_merge_hint(ci: CanvasItem, center: Vector2) -> void:
	var h := HINT_FRAME / 2.0
	for sx in [-1.0, 1.0]:
		for sy in [-1.0, 1.0]:
			var c := center + Vector2(sx * h, sy * h)
			var a := c - Vector2(sx * HINT_ARM, 0)
			var b := c - Vector2(0, sy * HINT_ARM)
			for pass_ in [[HINT_INK_W, INK], [HINT_BAND_W, HINT_BAND]]:
				ci.draw_line(a, c, pass_[1], pass_[0], true)
				ci.draw_line(c, b, pass_[1], pass_[0], true)
				ci.draw_circle(a, pass_[0] / 2.0, pass_[1])
				ci.draw_circle(b, pass_[0] / 2.0, pass_[1])
				ci.draw_circle(c, pass_[0] / 2.0, pass_[1])


# --- StyleBoxFlat ---

static func box(fill: Color, radius: int, border: int = 0, edge: Color = INK) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.set_corner_radius_all(radius)
	s.corner_detail = 12
	s.anti_aliasing = true
	if border > 0:
		s.set_border_width_all(border)
		s.border_color = edge
	return s


static func hard_shadow(s: StyleBoxFlat, color: Color, y: int) -> StyleBoxFlat:
	s.shadow_color = color
	s.shadow_size = 1  # 1 = tvrda sjena (0 je ne crta)
	s.shadow_offset = Vector2(0, y)
	return s


static func card_style(yours: bool = false) -> StyleBoxFlat:
	var s := box(CARD_YOURS if yours else CARD, RADIUS_CARD, BORDER)
	s.set_content_margin_all(20 + BORDER)
	return hard_shadow(s, SHADOW_CARD, SHADOW_CARD_Y)


static func button_style(state: String, pressed: bool = false) -> StyleBoxFlat:
	var s: StyleBoxFlat
	match state:
		COINS_BUY:
			s = box(COINS, RADIUS_BUTTON, BORDER)
		COINS_CONFIRM:
			s = box(INK, RADIUS_BUTTON, BORDER)
		COINS_SHORT_STATE:
			return box(COINS_SHORT, RADIUS_BUTTON, BORDER, Color(INK, 0.35))
		MONEY_BUY:
			s = box(MONEY, RADIUS_BUTTON, BORDER)
		MONEY_BUSY:
			return box(MONEY_SOFT, RADIUS_BUTTON, BORDER)
		MONEY_DIM:
			return box(MONEY_SOFT, RADIUS_BUTTON, BORDER, Color(INK, 0.30))
		PLAY_STATE:
			s = box(PLAY, RADIUS_BUTTON, BORDER)
		_:
			return box(OWNED, RADIUS_BUTTON, BORDER)
	return hard_shadow(s, SHADOW_BUTTON, 4 if pressed else SHADOW_BUTTON_Y)


static func button_ink(state: String) -> Color:
	match state:
		COINS_CONFIRM:
			return COINS
		COINS_SHORT_STATE, MONEY_DIM:
			return INK_SUB
		_:
			return INK


static func tab_style(active: bool) -> StyleBoxFlat:
	if active:
		return hard_shadow(box(TAB_ACTIVE, RADIUS_BUTTON, 4), Color(SHADOW_CARD, 0.24), 6)
	return box(CARD, RADIUS_BUTTON, 3)


static func status_style(bg: Color) -> StyleBoxFlat:
	var s := box(bg, 28, 3)
	s.content_margin_left = 22
	s.content_margin_right = 22
	return s


static func portrait_style() -> StyleBoxFlat:
	return box(DISC, 999, BORDER)


## Trake sezone (Home v3): nebo +30 % bijele, daljina, blizina × 0,93. Season Kit faza 2:
## SeasonCard u Shopu crta recept "shop"; trake ostaju samo u vinjeti Loot Bursta
## (tamni tekst preko trake sljedeće besplatne sezone — van paketa sezona).
static func season_bands(g: Color) -> Array[Color]:
	return [g.lerp(Color.WHITE, 0.30), g, Color(g.r * 0.93, g.g * 0.93, g.b * 0.93)]
