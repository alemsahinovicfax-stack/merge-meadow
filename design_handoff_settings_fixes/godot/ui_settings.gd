class_name UiSettings
extends RefCounted

## Settings — design_handoff_settings_fixes · D. Sve mjere u px baze 1080 × 1920, prenos 1:1.
## Isti obrazac kao ui_journal.gd / ui_shop_v2.gd: konstante, keširani StyleBoxFlat, bez _draw.
## Kontrole se pomjeraju samo transformom (position / scale), ništa se ne crta po frejmu.

# --- Boje (postojeće: ui_palette / ui_chrome / ui_shop_v2 / ui_popups) ---
const PAGE_BG := Color("#FFF8F0")
const BAR_BG := Color("#2A2233")            # = hub header
const BAR_RULE := Color(1.0, 0.973, 0.941, 0.55)
const INK := Color("#2D3436")
const SUB_INK := Color("#555C5E")           # 7,0 : 1 na bijelo
const CARD := Color("#FFFFFF")
const CARD_SHADOW := Color(0.102, 0.102, 0.078, 0.22)
const SEP := Color(0.176, 0.204, 0.212, 0.10)
const ON := Color("#A8E6CF")                # mint (Wearing / Claimed)
const OFF := Color("#E3DCD3")
const THUMB := Color("#FFFFFF")
const THUMB_MUTED := Color("#F1EAE0")
const BUSY := Color("#EAD2FF")
const FAIL := Color("#FFCCD5")
const DEV_BG := Color("#F1EAE0")

# --- Ekran ---
const BAR_H := 140
const BAR_RULE_H := 3
const TITLE_FONT := 56
const CLOSE := Vector2(120, 120)
const CLOSE_POS := Vector2(950, 10)         # mjesto zupčanika u hub headeru
const PAD := Vector2(24, 40)                # lijevo/desno, vrh liste
const LIST_BOTTOM := 120
const SECTION_GAP := 44
const SECTION_TITLE_FONT := 44
const SECTION_TITLE_GAP := 16
const CARD_R := 36
const CARD_EDGE := 4
const CARD_SHADOW_Y := 10
const CARD_PAD := Vector2(32, 12)
const ROW_PAD_Y := 12
const SEP_H := 3
const LABEL_FONT := 44
const SUB_FONT := 36
const VERSION_FONT := 36
const IN_SEC := 0.24                        # ulaz: y 1920 → 0, cubic-out
const OUT_SEC := 0.20

# --- Slider ---
const MUTE := Vector2(120, 120)
const MUTE_R := 28
const SLIDER_W := 672
const SLIDER_HIT_H := 120
const TRACK_H := 32
const TRACK_Y := 44
const TRACK_R := 16
const THUMB_D := 76
const THUMB_Y := 22
const VALUE_W := 120
const VALUE_FONT := 56
const SAVE_DEBOUNCE := 0.3

# --- Toggle ---
const TOGGLE := Vector2(168, 96)
const KNOB_D := 76
const KNOB_INSET := 6
const KNOB_TRAVEL := 72
const TOGGLE_SEC := 0.15
const ROW_MIN_H := 120
const LINK_ROW_H := 132

# --- Dugmad ---
const BUTTON_H := 120
const BUTTON_R := 60
const BUTTON_SHADOW_Y := 8
const PRESS_SEC := 0.08
const RESULT_POP := 1.06
const RESULT_SEC := 0.22
const CHIP_H := 72

const S := {
	"title": "Settings",
	"sound": "Sound", "music": "Music", "sfx": "Sound effects", "vibration": "Vibration", "off": "Off",
	"gameplay": "Gameplay", "reduce_motion": "Reduce motion",
	"reduce_motion_sub": "Fewer bounces and sparkles. Pip shows feelings with his face.",
	"purchases": "Purchases", "restore": "Restore purchases", "restoring": "Restoring",
	"restored": "✓ Restored", "checked": "✓ Checked", "failed": "Didn’t go through",
	"restore_idle_sub": "Brings back Remove Ads and Starter Pack on this device.",
	"restore_busy_sub": "Talking to the store…", "restore_done_sub": "Remove Ads is back on.",
	"restore_none_sub": "Nothing to restore on this account.",
	"restore_fail_sub": "Check your connection, then tap again.",
	"remove_ads": "Remove Ads", "ads_on": "Ads on", "ads_off": "✓ Ads off",
	"ads_bought": "Bought on this account", "ads_not": "Not bought",
	"privacy": "Privacy & help", "privacy_choices": "Privacy choices", "privacy_choices_sub": "How ads may use your data",
	"privacy_policy": "Privacy policy", "support": "Contact support", "support_sub": "Opens your email app",
	"credits": "Credits", "version": "Merge Meadow · Version %s (%s)",
	"dev": "Developer", "dev_tag": "Debug build",
	"dev_unlock": "Unlock all seasons", "dev_reset_seasons": "Reset seasons",
	"dev_coins": "+1000 coins", "dev_reset_tutorial": "Reset tutorial",
}

enum Restore { IDLE, BUSY, DONE, NONE, FAIL }

const SETTINGS_PATH := "user://settings.cfg"
const DEFAULTS := {
	"music": 80, "music_mute": false, "sfx": 100, "sfx_mute": false,
	"vibration": true, "reduce_motion": false,
}

static var _styles: Dictionary = {}


static func _cached(key: String, make: Callable) -> StyleBoxFlat:
	if not _styles.has(key):
		_styles[key] = make.call()
	return _styles[key]


static func box(bg: Color, radius: int, edge: int = 0, edge_color: Color = INK, shadow_y: int = 0, dashed: bool = false) -> StyleBoxFlat:
	var key := "%s|%d|%d|%s|%d|%s" % [bg.to_html(), radius, edge, edge_color.to_html(), shadow_y, dashed]
	return _cached(key, func() -> StyleBoxFlat:
		var s := StyleBoxFlat.new()
		s.bg_color = bg
		s.set_corner_radius_all(radius)
		if edge > 0:
			s.border_color = edge_color
			s.set_border_width_all(edge)
		if shadow_y > 0:
			s.shadow_color = CARD_SHADOW
			s.shadow_size = 1   # isto kao UiJournal.golden_plaque_style: tvrda sjena
			s.shadow_offset = Vector2(0, shadow_y)
		s.anti_aliasing = true
		return s)


## StyleBoxFlat nema isprekidan rub — Dev kartica = DEV_BG + rub 4 ink (oznaka „Debug build“ nosi razliku).
static func section_card(dev: bool) -> StyleBoxFlat:
	return box(DEV_BG if dev else CARD, CARD_R, CARD_EDGE, INK, 0 if dev else CARD_SHADOW_Y)


static func restore_style(state: Restore) -> StyleBoxFlat:
	match state:
		Restore.BUSY: return box(BUSY, BUTTON_R, 4)
		Restore.DONE, Restore.NONE: return box(ON, BUTTON_R, 4)
		Restore.FAIL: return box(FAIL, BUTTON_R, 4, INK, BUTTON_SHADOW_Y)
	return box(CARD, BUTTON_R, 4, INK, BUTTON_SHADOW_Y)


static func restore_text(state: Restore) -> Array[String]:
	match state:
		Restore.BUSY: return [S.restoring, S.restore_busy_sub]
		Restore.DONE: return [S.restored, S.restore_done_sub]
		Restore.NONE: return [S.checked, S.restore_none_sub]
		Restore.FAIL: return [S.failed, S.restore_fail_sub]
	return [S.restore, S.restore_idle_sub]


## Slider: vrijednost 0–100 → x palca (position.x) i scale.x ispune. Bez _draw.
static func thumb_x(value: int) -> float:
	return float(value) / 100.0 * float(SLIDER_W - THUMB_D)


static func fill_scale(value: int) -> float:
	return clampf(float(value) / 100.0, 0.0, 1.0)


static func value_from_x(local_x: float) -> int:
	return roundi(clampf((local_x - THUMB_D * 0.5) / float(SLIDER_W - THUMB_D), 0.0, 1.0) * 100.0)


static func knob_x(on: bool) -> float:
	return float(KNOB_INSET + (KNOB_TRAVEL if on else 0))


## 0–100 → dB za AudioServer (0 → mute). Busovi „Music“ i „SFX“ postoje i bez zvukova.
static func volume_db(value: int, muted: bool) -> float:
	if muted or value <= 0:
		return -80.0
	return linear_to_db(float(value) / 100.0)


static func load_settings() -> Dictionary:
	var cfg := ConfigFile.new()
	var out := DEFAULTS.duplicate()
	if cfg.load(SETTINGS_PATH) == OK:
		for k in DEFAULTS:
			out[k] = cfg.get_value("settings", k, DEFAULTS[k])
	return out


static func save_settings(values: Dictionary) -> void:
	var cfg := ConfigFile.new()
	for k in values:
		cfg.set_value("settings", k, values[k])
	cfg.save(SETTINGS_PATH)


## Primijeni odmah (i na startu igre iz autoload-a).
static func apply(values: Dictionary) -> void:
	for pair in [["Music", "music"], ["SFX", "sfx"]]:
		var bus := AudioServer.get_bus_index(pair[0])
		if bus >= 0:
			AudioServer.set_bus_volume_db(bus, volume_db(int(values[pair[1]]), bool(values[pair[1] + "_mute"])))
			AudioServer.set_bus_mute(bus, bool(values[pair[1] + "_mute"]) or int(values[pair[1]]) == 0)
	GameState.vibration_enabled = bool(values.vibration)
	GameState.reduce_motion = bool(values.reduce_motion)   # UiPip čita Pip.reduce_motion iz ovoga


static func vibrate(ms: int = 30) -> void:
	if GameState.vibration_enabled:
		Input.vibrate_handheld(ms)
