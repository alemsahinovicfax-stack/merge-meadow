class_name BackgroundLoad
extends RefCounted

## Pozadinsko učitavanje (`ResourceLoader.load_threaded_request`) koje se sačeka pri izlasku.
## Pri gašenju Godot namjerno prekida učitavanja u toku (zavisnosti se više ne učitavaju), pa
## scena sa skriptom — Shop stranica huba — ispiše „Parse Error … shop_screen.tscn" kad se igra
## ili test ugasi usred njenog učitavanja (greske-katalog #39). Isti obrazac kao UiPip /
## MuncherRig za poslove u threadu (#31): ko pokrene posao, sačeka ga i na izlazu.
## Rezultat se i dalje uzima običnim `ResourceLoader.load_threaded_get` / `_get_status`.

## Putanje tražene preko request() (skup); na izlazu se preuzme sve što vlasnik još nije uzeo.
static var _paths: Dictionary = {}


static func request(path: String) -> bool:
	if ResourceLoader.load_threaded_request(path) != OK:
		return false
	_paths[path] = true
	var loop := Engine.get_main_loop() as SceneTree
	if loop != null and loop.root != null and not loop.root.tree_exiting.is_connected(_drain):
		loop.root.tree_exiting.connect(_drain)
	return true


## Koliko ih je još u threadu (za testove).
static func in_progress() -> int:
	var n := 0
	for path in _paths:
		if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			n += 1
	return n


## Izlaz: preuzmi sve što vlasnik još nije uzeo — u toku (čeka se), gotovo ili neuspjelo. Gotovo a
## nepreuzeto bi ostalo „Resource still in use" pri gašenju (tema dok se čeka Shop). Već preuzeto
## (INVALID_RESOURCE) se preskače.
static func _drain() -> void:
	for path in _paths:
		if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_get(path)
	_paths.clear()
