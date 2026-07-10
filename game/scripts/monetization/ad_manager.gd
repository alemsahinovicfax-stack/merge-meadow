extends Node

## Rewarded AdMob wrapper — stub na desktopu; Poing plugin na Androidu kad je instaliran.

signal rewarded_completed(placement: String)
signal rewarded_failed(placement: String, reason: String)

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

enum Backend { STUB, ADMOB_PLUGIN }

var backend: Backend = Backend.STUB
var backend_name: String = "stub"
var _busy: bool = false
var _pending_placement: String = ""
var _rewarded_loader: Node


func _ready() -> void:
	if _try_init_admob_plugin():
		backend = Backend.ADMOB_PLUGIN
		backend_name = "admob_plugin"
	else:
		backend = Backend.STUB
		backend_name = "stub"


func is_stub_mode() -> bool:
	return backend == Backend.STUB


func can_request_rewarded() -> bool:
	return not _busy


func request_rewarded(placement: String) -> void:
	if _busy:
		rewarded_failed.emit(placement, "busy")
		return
	if placement != CONFIG.PLACEMENT_DOUBLE_LOOT and placement != CONFIG.PLACEMENT_REVIVE:
		rewarded_failed.emit(placement, "invalid_placement")
		return
	if GameState.ads_removed and placement == CONFIG.PLACEMENT_DOUBLE_LOOT:
		# Remove ads ne gasi rewarded (Pillar 2) — samo dokumentirano za buduće interstitiale.
		pass
	_busy = true
	_pending_placement = placement
	match backend:
		Backend.ADMOB_PLUGIN:
			_request_plugin_rewarded(placement)
		_:
			_request_stub_rewarded(placement)


func _request_stub_rewarded(placement: String) -> void:
	var timer := get_tree().create_timer(1.2)
	timer.timeout.connect(func() -> void:
		_finish_rewarded(placement)
	, CONNECT_ONE_SHOT)


func _finish_rewarded(placement: String) -> void:
	_busy = false
	_pending_placement = ""
	rewarded_completed.emit(placement)


func _fail_rewarded(placement: String, reason: String) -> void:
	_busy = false
	_pending_placement = ""
	rewarded_failed.emit(placement, reason)


func _try_init_admob_plugin() -> bool:
	if not DirAccess.dir_exists_absolute("res://addons/admob"):
		return false
	if not ClassDB.class_exists("RewardedAdLoader"):
		return false
	_rewarded_loader = ClassDB.instantiate("RewardedAdLoader")
	if _rewarded_loader == null:
		return false
	add_child(_rewarded_loader)
	return true


func can_show_interstitial(_placement: String) -> bool:
	return not GameState.ads_removed


func show_interstitial(placement: String, on_finished: Callable = Callable()) -> void:
	if not can_show_interstitial(placement):
		if on_finished.is_valid():
			on_finished.call()
		return
	match backend:
		Backend.ADMOB_PLUGIN:
			_show_plugin_interstitial(placement, on_finished)
		_:
			_show_stub_interstitial(placement, on_finished)


func _show_stub_interstitial(_placement: String, on_finished: Callable) -> void:
	var timer := get_tree().create_timer(0.35)
	timer.timeout.connect(func() -> void:
		if on_finished.is_valid():
			on_finished.call()
	, CONNECT_ONE_SHOT)


func _show_plugin_interstitial(placement: String, on_finished: Callable) -> void:
	push_warning("AdManager: interstitial plugin hook pending — skipping for %s" % placement)
	if on_finished.is_valid():
		on_finished.call()


func _request_plugin_rewarded(placement: String) -> void:
	if _rewarded_loader == null:
		_fail_rewarded(placement, "plugin_not_ready")
		return
	# Poing API — load → show; detalji u docs/05-technical/godot/admob-setup.md
	if not _rewarded_loader.has_method("load"):
		_fail_rewarded(placement, "plugin_api_missing")
		return
	push_warning("AdManager: plugin detected but rewarded load not wired — falling back to stub for %s" % placement)
	_request_stub_rewarded(placement)
