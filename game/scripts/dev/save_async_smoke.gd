extends SceneTree

## FIX-TEL-3 (2026-11-12) — odgođeni save piše na disk u pozadinskoj niti (GameState.
## _on_save_soon_timer). Testovi inače rade sinhrono (headless); ovaj pali nit ručno:
##  · odgođeni save stigne na disk, fajl je ispravan JSON s novim stanjem;
##  · sinhroni save odmah poslije pokrenutog pozadinskog ne miješa pisanja — zadnje stanje pobjeđuje;
##  · fajl koji je u međuvremenu promijenio neko drugi (test koji vrati svoju kopiju) se ne prepisuje;
##  · .bak čuva prethodni dobar save.

const SAVE_PATH := "user://player_save.json"
const BAK_PATH := "user://player_save.json.bak"

var _backup := ""
var _failed := false


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("save_async_smoke: %s" % msg)


func _coins_on_disk() -> int:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not parsed is Dictionary:
		return -1
	return int((parsed as Dictionary).get("wallet_coins", -1))


func _wait_task(gs: Node) -> void:
	var guard := 0
	while bool(gs.call("is_save_task_running")) and guard < 600:
		await process_frame
		guard += 1
	gs.call("_join_save_task")


func _run() -> void:
	var gs: Node = root.get_node("GameState")
	await process_frame
	gs.call("save_player_save")
	gs.set("save_async_enabled", true)

	# 1 · odgođeni save u pozadini.
	gs.set("wallet_coins", 4101)
	gs.call("save_player_save_soon")
	if _coins_on_disk() == 4101:
		_fail("a delayed save must not write in the same frame")
	await create_timer(0.8).timeout
	await _wait_task(gs)
	if _coins_on_disk() != 4101:
		_fail("delayed save should reach the disk, wallet on disk is %d" % _coins_on_disk())
	var bak: Variant = JSON.parse_string(FileAccess.get_file_as_string(BAK_PATH))
	if not bak is Dictionary:
		_fail(".bak should hold the previous valid save")

	# 2 · pozadinski pa odmah sinhroni: zadnje stanje pobjeđuje, fajl je cijeli.
	for i in 6:
		gs.set("wallet_coins", 5000 + i)
		gs.set("_save_soon_pending", true)
		gs.call("_on_save_soon_timer")
		gs.set("wallet_coins", 6000 + i)
		gs.call("save_player_save")
		if _coins_on_disk() != 6000 + i:
			_fail("sync save right after a background one must win (round %d, disk %d)" % [i, _coins_on_disk()])
			break
	if bool(gs.call("is_save_task_running")):
		_fail("no background write may be left running after a sync save")

	# 3 · više pozadinskih zaredom.
	for i in 5:
		gs.set("wallet_coins", 7000 + i)
		gs.set("_save_soon_pending", true)
		gs.call("_on_save_soon_timer")
	await _wait_task(gs)
	if _coins_on_disk() != 7004:
		_fail("the last of several background saves should be on disk, got %d" % _coins_on_disk())

	# 4 · tuđa izmjena fajla se ne prepisuje odgođenim saveom.
	var foreign := JSON.stringify({"version": 1, "wallet_coins": 12})
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(foreign)
	f.close()
	gs.set("wallet_coins", 8888)
	gs.set("_save_soon_pending", true)
	gs.call("_on_save_soon_timer")
	await _wait_task(gs)
	if _coins_on_disk() != 12:
		_fail("a delayed save must not overwrite a file someone else changed (disk %d)" % _coins_on_disk())
	gs.set("_save_soon_pending", true)
	gs.call("_on_save_soon_timer")
	await _wait_task(gs)
	if _coins_on_disk() != 12:
		_fail("the next delayed save must skip it too (disk %d)" % _coins_on_disk())
	# Obični save ga smije prepisati (kao i do sada).
	gs.call("save_player_save")
	if _coins_on_disk() != 8888:
		_fail("a plain save writes regardless, disk %d" % _coins_on_disk())

	gs.set("save_async_enabled", false)
	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("save_async_smoke OK")
	quit(1 if _failed else 0)
