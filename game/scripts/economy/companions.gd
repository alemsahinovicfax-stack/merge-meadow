## Companions domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 4.1). Owned by GameState as `companions`; GameState keeps facade
## methods (is_companion_unlocked, get_active_companion_id, ...) that forward
## here, so external call sites are unchanged. Reads (not writes)
## get_camp_progress_level() from the owner — that stays GameState's own
## Magnet/Multiplier state, not a Companions concern.
class_name Companions
extends RefCounted

var active_id: String
var mochi_unlock_seen: bool = false

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner
	active_id = _owner.COMPANION_PIP


func apply_from_save(data: Dictionary) -> void:
	active_id = str(data.get("active_companion_id", _owner.COMPANION_PIP))
	mochi_unlock_seen = bool(data.get("mochi_unlock_seen", false))
	if not is_unlocked(active_id):
		active_id = _owner.COMPANION_PIP


func to_save_dict() -> Dictionary:
	return {
		"active_companion_id": active_id,
		"mochi_unlock_seen": mochi_unlock_seen,
	}


func is_unlocked(companion_id: String) -> bool:
	if companion_id == _owner.COMPANION_PIP:
		return true
	if companion_id == _owner.COMPANION_MOCHI:
		return _owner.get_camp_progress_level() >= _owner.MOCHI_UNLOCK_CAMP_LEVEL
	return false


func get_active_id() -> String:
	if is_unlocked(active_id):
		return active_id
	return _owner.COMPANION_PIP


func display_name(companion_id: String = "") -> String:
	var id: String = companion_id if not companion_id.is_empty() else get_active_id()
	return _name(id)


func _name(companion_id: String) -> String:
	if companion_id == _owner.COMPANION_PIP:
		return "Pip"
	elif companion_id == _owner.COMPANION_MOCHI:
		return "Mochi"
	return companion_id.capitalize()


func format_mochi_unlock_hint() -> String:
	if is_unlocked(_owner.COMPANION_MOCHI):
		return "Mochi unlocked — tap to run as cat!"
	var need: int = _owner.MOCHI_UNLOCK_CAMP_LEVEL - _owner.get_camp_progress_level()
	return "Mochi unlocks at camp level %d (%d upgrade%s to go)." % [
		_owner.MOCHI_UNLOCK_CAMP_LEVEL,
		maxi(0, need),
		"" if need == 1 else "s",
	]


func try_set_active(companion_id: String) -> String:
	if not is_unlocked(companion_id):
		return format_mochi_unlock_hint()
	if active_id == companion_id:
		return "%s is already your runner." % _name(companion_id)
	active_id = companion_id
	_owner.save_player_save()
	return "%s will join your next run!" % _name(companion_id)


func poll_mochi_unlock_toast() -> String:
	if mochi_unlock_seen:
		return ""
	if not is_unlocked(_owner.COMPANION_MOCHI):
		return ""
	mochi_unlock_seen = true
	_owner.save_player_save()
	return "Mochi joined the meadow! Pick a companion below."
