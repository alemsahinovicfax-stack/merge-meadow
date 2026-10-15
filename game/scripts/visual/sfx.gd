class_name Sfx
extends RefCounted

## Zvuk iz bilo koje klase: AudioManager (autoload) se traži u toku igre, ne statički —
## klase koje `-s` testovi koriste direktno (UiPip, UiPopups, kartice…) se tako kompajliraju i
## prije autoloada (greske-katalog #21), a bez AudioManagera (test bez njega) poziv je tih.


static func _am() -> Node:
	var loop := Engine.get_main_loop() as SceneTree
	if loop == null or loop.root == null:
		return null
	return loop.root.get_node_or_null("AudioManager")


## Efekat iz kataloga; `step` ≥ 0 = korak lanca (combo), −1 = lanac po vremenu.
static func play(sound_id: String, step: int = -1, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	var am := _am()
	if am != null:
		am.call("play", sound_id, step, pitch, volume_db)


## Nivo muzike: "home" (hub, loot), "arena", "run" — tema aktivne sezone, prati promjenu sezone.
static func music_level(level: String) -> void:
	var am := _am()
	if am != null:
		am.call("play_level", level)


## Tema po id-u ("" = tišina) — bez praćenja sezone.
static func music(track_id: String) -> void:
	var am := _am()
	if am != null:
		am.call("play_music", track_id)


static func haptic(ms: int = 30) -> void:
	var am := _am()
	if am != null:
		am.call("haptic", ms)


static func set_ad_playing(on: bool) -> void:
	var am := _am()
	if am != null:
		am.call("set_ad_playing", on)
