## Bloom inbox domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 4.6). Owned by GameState as `bloom_inbox_domain`; the `bloom_inbox`
## GameState property (getter/setter, see game_state.gd) delegates to `inbox`
## here.
##
## A temporary staging queue for Arena T2+ merges: push() appends a chip,
## flush_to_album() (called from merge_arena_controller.gd via GameState)
## auto-keeps every entry into the Collection Journal. There is no per-item
## donate/keep/basket choice left — that UI was dead code, removed in the
## Stage 4.6 prep commit. keep_bloom()/can_keep_bloom_upgrade() stay on
## GameState rather than moving here: they're Collection Journal concerns
## (collection_kept_tiers/discovered_blooms) that keep_at() merely calls
## into, not bloom-inbox-specific.
class_name BloomInboxDomain
extends RefCounted

const BLOOM_INBOX_MAX := 12

var inbox: Array = []

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner


func deserialize(raw: Variant) -> Array:
	var out: Array = []
	if raw is Array:
		for item in raw:
			if item is Dictionary:
				out.append(item.duplicate())
	return out


func count(min_tier: int = 2) -> int:
	var total := 0
	for item in inbox:
		if int(item.get("tier", 0)) >= min_tier:
			total += 1
	return total


## Caller (GameState.push_bloom_inbox) is responsible for save_player_save().
func push(type_id: String, tier: int) -> bool:
	if type_id.is_empty() or tier < 2:
		return false
	if inbox.size() >= BLOOM_INBOX_MAX:
		return false
	inbox.append({"type_id": type_id, "tier": tier})
	_owner.discovered_blooms[type_id] = true
	_owner._mark_collection_journal_new(type_id, 1)
	return true


## _owner.keep_bloom() saves on success; no separate save needed here.
func keep_at(index: int) -> bool:
	if index < 0 or index >= inbox.size():
		return false
	var item: Dictionary = inbox[index]
	var type_id := str(item.get("type_id", ""))
	var tier := int(item.get("tier", 0))
	if not _owner.keep_bloom(type_id, tier):
		return false
	inbox.remove_at(index)
	return true


func flush_to_album() -> int:
	var kept := 0
	for i in range(inbox.size() - 1, -1, -1):
		if keep_at(i):
			kept += 1
	return kept
