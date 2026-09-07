## Shared GUT base for GameState characterization tests.
## Tests run against the live GameState autoload (same pattern scripts/dev/*_smoke.gd
## already use), which means _ready() has already loaded the developer's REAL
## user://player_save.json into memory before any test runs. Any test whose code
## path calls save_player_save() would otherwise clobber that real save file on
## disk. This base backs up the raw save file before each test and restores it
## after, so running the suite never loses real dev save progress.
extends GutTest

const PLAYER_SAVE_PATH := "user://player_save.json"

## Untyped on purpose: GameState's script members (wallet_coins, SEED_BAG_SOFT_CAP,
## _apply_save_dict, ...) aren't part of the Node API, so a `Node`-typed var would
## fail GDScript's static member check. Variant defers member access to runtime
## (the same reason existing scripts/dev/*_smoke.gd use .get()/.set()/.call()).
var _gs: Variant
var _save_backup: String = ""
var _save_existed: bool = false


func before_each() -> void:
	_gs = get_node("/root/GameState")
	_save_existed = FileAccess.file_exists(PLAYER_SAVE_PATH)
	if _save_existed:
		var f := FileAccess.open(PLAYER_SAVE_PATH, FileAccess.READ)
		_save_backup = f.get_as_text()
		f.close()


func after_each() -> void:
	if _save_existed:
		var f := FileAccess.open(PLAYER_SAVE_PATH, FileAccess.WRITE)
		f.store_string(_save_backup)
		f.close()
	elif FileAccess.file_exists(PLAYER_SAVE_PATH):
		DirAccess.remove_absolute(PLAYER_SAVE_PATH)
