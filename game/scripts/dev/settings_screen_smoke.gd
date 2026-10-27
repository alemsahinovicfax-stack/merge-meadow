extends SceneTree

## design_handoff_settings_fixes · D — Settings u pravom hubu (headless):
##  1. zupčanik otvara SettingsScreen; X stoji tačno na mjestu zupčanika;
##  2. sekcije Sound / Gameplay / Purchases / Privacy & help (+ Developer u debug buildu) —
##     Purchases samo s kupovinama pravim novcem (v1 bez njih: MonetizationConfig.IAP_ENABLED = false);
##  3. slider Music 30 → bus „Music" = linear_to_db(0,3); mute → bus utišan; unmute vraća 30;
##  4. toggle Reduce motion / Vibration mijenja GameState odmah;
##  5. Restore purchases (stub) završi u DONE ili NONE, ne ostaje BUSY (samo s kupovinama);
##  6. zatvaranje sprema user://settings.cfg; Back (ui_cancel) zatvara; Credits → X vraća.
## Postavke se vraćaju na kraju (fajl settings.cfg i stanje GameState).

const HEADER_GEAR := "RootVBox/TopBar/Panel/HBox/SettingsButton"
## Bez statičke reference: UiSettings u funkcijama koristi autoload GameState, a -s skripta se
## kompajlira prije autoloada.
const UI_SETTINGS := "res://scripts/visual/ui_settings.gd"

var UiS: Script

var _backup := ""
var _cfg_backup := ""
var _had_cfg := false
var _fails := 0


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	_fails += 1
	push_error("settings_screen_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _restore() -> void:
	if _had_cfg:
		var f := FileAccess.open(UiS.SETTINGS_PATH, FileAccess.WRITE)
		f.store_string(_cfg_backup)
		f.close()
	elif FileAccess.file_exists(UiS.SETTINGS_PATH):
		DirAccess.remove_absolute(UiS.SETTINGS_PATH)
	UiS.apply(UiS.load_settings())
	CampSmokeUtil.restore_save(self, _backup)


func _open(hub: Node) -> Node:
	(hub.get_node(HEADER_GEAR) as Control).emit_signal("clicked")
	await create_timer(0.6).timeout
	return hub.get_node_or_null("SettingsScreen")


func _run() -> void:
	UiS = load(UI_SETTINGS)
	_backup = CampSmokeUtil.backup_save()
	_had_cfg = FileAccess.file_exists(UiS.SETTINGS_PATH)
	if _had_cfg:
		_cfg_backup = FileAccess.get_file_as_string(UiS.SETTINGS_PATH)
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	get_root().add_child(hub)
	await _frames(30)
	var gear := hub.get_node(HEADER_GEAR) as Control
	var screen := await _open(hub)
	if screen == null:
		_fail("gear did not open SettingsScreen")
		_finish()
		return
	var close := screen.find_child("CloseButton", true, false) as Control
	if close == null or close.get_global_rect().position.distance_to(gear.get_global_rect().position) > 2.0:
		_fail("X is not where the gear is")
	var iap := MonetizationConfig.iap_enabled()
	for sec in ["Section_Sound", "Section_Gameplay", "Section_Purchases", "Section_Privacyhelp"]:
		if sec == "Section_Purchases" and not iap:
			if screen.find_child(sec, true, false) != null:
				_fail("v1 without purchases must not build %s" % sec)
			continue
		if screen.find_child(sec, true, false) == null:
			_fail("missing %s" % sec)
	var dev := screen.find_child("Section_Developer", true, false)
	if (dev != null) != OS.is_debug_build():
		_fail("Developer section must exist only in a debug build")

	# Slider + mute → bus
	screen.call("_on_slider", 30, "music")
	var bus := AudioServer.get_bus_index("Music")
	if bus < 0:
		_fail("no Music bus")
	elif not is_equal_approx(AudioServer.get_bus_volume_db(bus), linear_to_db(0.09)):
		# kvadratna kriva slidera: 30 → 0,3² amplitude (≈ −20,9 dB)
		_fail("Music bus %.2f dB, expected %.2f" % [AudioServer.get_bus_volume_db(bus), linear_to_db(0.09)])
	screen.call("_on_mute", "music")
	if bus >= 0 and not AudioServer.is_bus_mute(bus):
		_fail("mute did not mute the Music bus")
	screen.call("_on_mute", "music")
	if int((screen.get("values") as Dictionary)["music"]) != 30 or (bus >= 0 and AudioServer.is_bus_mute(bus)):
		_fail("unmute should bring back 30")
	if AudioServer.get_bus_index("SFX") < 0:
		_fail("no SFX bus")

	# Toggles
	var rm := bool(gs.get("reduce_motion"))
	screen.call("_on_toggle", "reduce_motion")
	if bool(gs.get("reduce_motion")) == rm:
		_fail("Reduce motion toggle did not reach GameState")
	screen.call("_on_toggle", "reduce_motion")
	var vib := bool(gs.get("vibration_enabled"))
	screen.call("_on_toggle", "vibration")
	if bool(gs.get("vibration_enabled")) == vib:
		_fail("Vibration toggle did not reach GameState")

	# Restore (stub) — samo kad postoji (kupovine pravim novcem uključene)
	if iap:
		screen.call("_on_restore")
		await _frames(10)
		var state := int(screen.get("_restore_state"))
		if state != UiS.Restore.DONE and state != UiS.Restore.NONE:
			_fail("restore ended in state %d" % state)

	# Credits ↔ Settings, pa X zatvara i sprema
	screen.call("_show_credits", true)
	await _frames(2)
	close.emit_signal("clicked")
	await _frames(2)
	if (screen.get_node("CreditsPage") as Control).visible:
		_fail("X on Credits should go back to Settings")
	close.emit_signal("clicked")
	await create_timer(0.6).timeout
	if is_instance_valid(screen) and screen.visible:
		_fail("X did not close Settings")
	var saved: Dictionary = UiS.load_settings()
	if int(saved["music"]) != 30 or bool(saved["vibration"]) == vib:
		_fail("settings.cfg not saved on close: %s" % str(saved))

	# Back (ui_cancel) zatvara
	screen = await _open(hub)
	var ev := InputEventAction.new()
	ev.action = "ui_cancel"
	ev.pressed = true
	Input.parse_input_event(ev)
	await create_timer(0.6).timeout
	if is_instance_valid(screen) and screen.visible:
		_fail("Back did not close Settings")
	_finish()


func _finish() -> void:
	_restore()
	if _fails == 0:
		print("settings_screen_smoke OK")
	quit(_fails)
