class_name SeasonField
extends Control

## Home field meadow — v2: livada je CIJELA stranica (1080 x 1633), bez okvira.
## 13 mjesta iz MEADOW_SPOTS (4 dubine, crtaju se nazad → naprijed), Pip FSM u
## pojasu ispred svih cvjetova. Broj izraslih javlja se overlayu signalom.
## Home v3: dok traje prelaz (apply_reveal u < 1) livada ne crta svoje trake —
## kartica JESTE livada — a cvijece i napomena ulaze po svojim prozorima. Pip
## ceka predaju (hold_pip / release_pip): hoda tek kad je prelaz gotov.
## Season Kit (design_handoff_seasons): sezona s kitom crta recept (SeasonBackdrop)
## umjesto traka, 13 mjesta iz kita, ambijent (≤ 24 čestice, samo u = 1) i Pipove
## poze. Mjesto, cvijeće i ambijent žive u rectu livade: u prelazu je to rect kartice
## (apply_reveal(u, rect)), pa cvijeće stoji na svojoj pruzi — na u = 1 rect = stranica.
## Faza 2: njihanje cvijeća ±3° (jedna petlja ovdje, samo na u = 1; Reduce motion je gasi),
## Pip spava → ambijent 0,35; Pip njuši → čestice oblika prvog sloja ambijenta.
## Na polju su najviše 2 stalne petlje: ambijent + njihanje.

const FLOWER_SCRIPT := preload("res://scripts/ui/season_field_flower.gd")
const SOIL_DARK_FILL := Color(0.0, 0.0, 0.039, 0.28)
const SOIL_DARK_EDGE := Color(0.627, 0.659, 0.941, 0.30)
const FLOWER_SHADOW_DARK := Color(0.0, 0.0, 0.039, 0.32)
## Razmak rasta između mjesta kad ih izraste više odjednom (poslije runa).
const GROW_STAGGER := 0.08
const PIP_MIN_MOVE := 80.0
const PIP_WALK_SPEED := 70.0
const PIP_WALK_MIN := 2.2
const PIP_WALK_MAX := 5.5
const PIP_SNIFF_NEAR := 72.0
const PIP_SNIFF_WALK_MAX := 2.5
const PIP_WEIGHT_WALK := 0.50
const PIP_WEIGHT_SNIFF := 0.25
const PIP_WEIGHT_SLEEP := 0.25

enum _PipState { NONE, WALK, SNIFF, SLEEP }

signal grown_changed(grown: int, total: int)

@onready var meadow_ground: Panel = $MeadowGround
@onready var meadow_pip: Control = $MeadowPip
@onready var meadow_note: Label = $MeadowNote

var _open_season_id: String = ""
var _wander_tween: Tween = null
var _pip_state: int = _PipState.NONE
var _last_sniff_id: int = 0
var _spot_count: int = 0
var _grown_count: int = 0
var _laid_out_size: Vector2 = Vector2.ZERO
var _reveal_u: float = 1.0
var _pip_hold: bool = false
var _backdrop: SeasonBackdropView
var _ambient: SeasonAmbient
var _kit: bool = false
var _note_color: Color = Color(0.102, 0.102, 0.078, 1)
## Rect livade u prostoru polja (prelaz: rect kartice; prazno = cijelo polje).
var _meadow_rect: Rect2 = Rect2()
## Mjesta koja su igraču već pokazana kao izrasla (po sezoni, za ovu sesiju): rast
## se pušta samo za mjesto koje je prešlo prag otkad je polje zadnji put građeno.
static var _seen_grown: Dictionary = {}
## Stash rostera kakav je bio kad je polje zadnji put građeno (refresh_growth).
var _built_stash: Dictionary = {}
## Prvi sloj ambijenta sezone — oblik čestica kad Pip njuši cvijet.
var _puff_layer: Dictionary = {}
var _sway_t: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	set_process(false)
	_ensure_kit_nodes()
	_hide_pip_and_stop()
	if meadow_note:
		meadow_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_note_color = meadow_note.get_theme_color("font_color")
	resized.connect(_on_resized)
	visibility_changed.connect(_sync_sway)


## Njihanje radi samo na otvorenom polju kita s izraslim cvijećem, bez Reduce motion.
func is_swaying() -> bool:
	return is_processing()


func _sync_sway() -> void:
	var on := _kit and _reveal_u >= 1.0 and _grown_count > 0 and not _open_season_id.is_empty() \
		and is_visible_in_tree() and not GameState.reduce_motion
	if on == is_processing():
		return
	set_process(on)
	if not on:
		for f in _meadow_flowers():
			(f as SeasonFieldFlower).set_sway(0.0)


## Jedna petlja za sve cvjetove: 3 · sin(2π (t − 0,37 i) / (3 + (i % 5) · 0,5)), pivot = baza.
func _process(delta: float) -> void:
	_sway_t += delta
	for f in _meadow_flowers():
		var i := int(f.get_meta("spot_index", 0))
		var period := UiSeasons.SWAY_SEC + float(i % 5) * UiSeasons.SWAY_STEP
		(f as SeasonFieldFlower).set_sway(UiSeasons.SWAY_DEG * sin(TAU * (_sway_t - 0.37 * float(i)) / period))


func apply_season(season_id: String) -> void:
	_open_season_id = season_id
	_apply_meadow_fill(season_id)
	_rebuild_flowers(season_id)
	call_deferred("_rebuild_flowers_deferred", season_id)


## Home stranica živi u hubu i dok je igrač u Areni: povratak na već otvoreno polje
## ponovo pročita stash i pusti rast mjesta koja su u međuvremenu prešla prag.
func refresh_growth() -> void:
	if _open_season_id.is_empty() or _roster_stash(_open_season_id) == _built_stash:
		return
	_rebuild_flowers(_open_season_id)


func _roster_stash(season_id: String) -> Dictionary:
	var out: Dictionary = {}
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		return out
	for type_id in def.seed_type_ids:
		out[type_id] = int(GameState.garden_crystal_stash.get(type_id, 0))
	return out


func get_meadow_spot_count() -> int:
	return _spot_count


func get_meadow_grown_count() -> int:
	return _grown_count


func has_kit() -> bool:
	return _kit


func get_ambient() -> SeasonAmbient:
	return _ambient


func get_ground_color() -> Color:
	if meadow_ground:
		var sb := meadow_ground.get_theme_stylebox("panel") as StyleBoxFlat
		if sb:
			return sb.bg_color
	return Color.WHITE


func clear_flowers() -> void:
	for child in get_children():
		if _is_shell_child(child):
			continue
		remove_child(child)
		child.queue_free()
	_spot_count = 0
	_grown_count = 0


func dismiss_flowers() -> void:
	_open_season_id = ""
	_laid_out_size = Vector2.ZERO
	_hide_pip_and_stop()
	clear_flowers()
	if meadow_note:
		meadow_note.visible = false
	if _ambient:
		_ambient.visible = false
	_sync_sway()
	grown_changed.emit(0, UiHomeField.MEADOW_SPOTS.size())


## Napredak prelaza Homea (0 = kartica, 1 = livada). Trake livade se vide tek
## na u = 1, u istom frameu u kojem se kartica sakrije (isti pikseli).
## rect = rect livade u prostoru polja (Home: rect kartice); prazno = cijelo polje.
func apply_reveal(u: float, rect: Rect2 = Rect2()) -> void:
	var was_open := _reveal_u >= 1.0
	_reveal_u = clampf(u, 0.0, 1.0)
	_meadow_rect = rect
	if meadow_ground:
		meadow_ground.visible = _reveal_u >= 1.0
	if meadow_note:
		meadow_note.modulate.a = UiHomeV3.win(_reveal_u, UiHomeV3.NOTE_IN.x, UiHomeV3.NOTE_IN.y)
	if _ambient:
		var show := _kit and _reveal_u >= 1.0 and not _open_season_id.is_empty()
		if show and not _ambient.visible:
			_ambient.visible = true
			if not was_open:
				_ambient.fade_in()
		elif not show:
			_ambient.visible = false
	for child in get_children():
		if not child.has_meta("spot_index"):
			continue
		var c := child as Control
		if c == null:
			continue
		if _reveal_u >= 1.0:
			c.modulate.a = 1.0
			_layout_spot(c, 1.0)
			continue
		var start := UiHomeV3.FLOWER_START + float(c.get_meta("spot_index")) * UiHomeV3.FLOWER_STAGGER
		var a := clampf((_reveal_u - start) / UiHomeV3.FLOWER_FADE, 0.0, 1.0)
		var k := UiHomeV3.ease_out(clampf((_reveal_u - start) / UiHomeV3.FLOWER_SETTLE, 0.0, 1.0))
		c.modulate.a = a
		_layout_spot(c, lerpf(UiHomeV3.FLOWER_SCALE_FROM, 1.0, k))
	_sync_sway()


## Mjesto u rectu livade: baza = (x %, dno − y %), veličina × k = w / širina polja.
func _layout_spot(c: Control, entry_scale: float) -> void:
	var spec: Array = c.get_meta("spot_spec", [])
	if spec.size() < 2:
		return
	var bounds := _meadow_bounds()
	var r := _meadow_rect if _meadow_rect.size.x >= 8.0 else bounds
	var k := r.size.x / maxf(1.0, bounds.size.x)
	var base := r.position + Vector2(r.size.x * float(spec[0]) / 100.0, r.size.y * (1.0 - float(spec[1]) / 100.0))
	var pivot := Vector2(c.size.x * 0.5, c.size.y)
	c.pivot_offset = pivot
	c.position = base - pivot
	if c is SeasonFieldFlower:
		(c as SeasonFieldFlower).set_layout_scale(k * entry_scale)
	else:
		c.scale = Vector2.ONE * (k * entry_scale)


## Pip livade se sakrije i stane; Home crta putujuceg Pipa dok traje prelaz.
func hold_pip() -> void:
	_pip_hold = true
	_hide_pip_and_stop()


## Predaja na kraju otvaranja: Pip na kucnim stopalima, pa hodanje.
func release_pip() -> void:
	_pip_hold = false
	_restart_wander()


func is_pip_held() -> bool:
	return _pip_hold


## Stopala Pipa u px livade (za zatvaranje — Pip krece odatle).
func pip_feet() -> Vector2:
	if meadow_pip == null or not meadow_pip.visible:
		var page := Vector2(UiHomeField.PAGE)
		var base := Vector2(UiHomeField.PIP_DEFAULT_BASE)
		var b := _meadow_bounds().size
		return Vector2(b.x * base.x / page.x, b.y * base.y / page.y)
	return meadow_pip.position + Vector2(meadow_pip.size.x * 0.5, meadow_pip.size.y)


## Ormar · ApplyMoment: Pip skoči u novom skinu + prsten oko stopala.
func play_apply_moment() -> bool:
	if meadow_pip == null or not meadow_pip.visible or not meadow_pip.has_method("play_apply"):
		return false
	meadow_pip.call("play_apply")
	return true


func is_pip_wandering() -> bool:
	return _wander_tween != null and _wander_tween.is_running()


func is_pip_alive() -> bool:
	return (
		not _open_season_id.is_empty()
		and meadow_pip != null
		and meadow_pip.visible
		and _pip_state != _PipState.NONE
	)


func _on_resized() -> void:
	_place_pip_home()
	if _open_season_id.is_empty():
		return
	if size.distance_to(_laid_out_size) < 8.0:
		return
	_laid_out_size = size
	_rebuild_flowers(_open_season_id)


func _rebuild_flowers_deferred(season_id: String) -> void:
	if _open_season_id != season_id:
		return
	_rebuild_flowers(season_id)


func _is_shell_child(child: Node) -> bool:
	var n := str(child.name)
	return (
		n == "MeadowGround"
		or n == "SeasonsButton"
		or n == "MeadowPip"
		or n == "MeadowNote"
		or n == "MeadowAmbient"
	)


## SeasonBackdrop (u MeadowGround, ispod svega) i Ambient (iznad cvijeća, ispod Pipa).
func _ensure_kit_nodes() -> void:
	if meadow_ground and _backdrop == null:
		_backdrop = SeasonBackdropView.new()
		_backdrop.name = "SeasonBackdrop"
		_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
		_backdrop.visible = false
		meadow_ground.add_child(_backdrop)
	if _ambient == null:
		_ambient = SeasonAmbient.new()
		_ambient.name = "MeadowAmbient"
		_ambient.set_anchors_preset(Control.PRESET_FULL_RECT)
		_ambient.z_index = 10
		_ambient.visible = false
		add_child(_ambient)


func _apply_meadow_fill(season_id: String) -> void:
	var ground := UiHomeField.meadow_ground(season_id)
	if meadow_ground:
		# v2: bez ruba i radiusa — livada je stranica, ne prozor.
		var sb := StyleBoxFlat.new()
		sb.bg_color = ground
		meadow_ground.add_theme_stylebox_override("panel", sb)
		meadow_ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Season Kit: recept (svih 8 sezona; stare tri trake su obrisane); tekst u boji kita.
	_ensure_kit_nodes()
	var scene := SeasonBackdrop.field_scene(season_id)
	_kit = not scene.is_empty()
	if _backdrop:
		_backdrop.scene = scene
		_backdrop.visible = _kit
		_backdrop.queue_redraw()
	if _ambient:
		_ambient.set_season(season_id if _kit else "")
		_ambient.set_still(GameState.reduce_motion and UiSeasons.REDUCE_MOTION_STOPS_AMBIENT)
		_ambient.visible = _kit and _reveal_u >= 1.0
	var layers := UiSeasons.ambient_layers(UiSeasons.ambient(season_id)) if _kit else []
	_puff_layer = layers[0]["layer"] if not layers.is_empty() else {}
	if meadow_note:
		meadow_note.add_theme_color_override("font_color", UiSeasons.ink_field(season_id, _note_color))


func _rebuild_flowers(season_id: String) -> void:
	clear_flowers()
	_built_stash = _roster_stash(season_id)
	if season_id.is_empty():
		_hide_pip_and_stop()
		return
	var bounds := _meadow_bounds()
	if bounds.size.x < 8.0 or bounds.size.y < 8.0:
		_hide_pip_and_stop()
		return
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null or def.seed_type_ids.is_empty():
		_refresh_meadow_chrome(0)
		_restart_wander()
		return
	var pool: Array[String] = def.seed_type_ids
	var stash: Dictionary = GameState.garden_crystal_stash
	var spots := UiSeasons.spots(season_id)
	var dark := UiSeasons.is_dark(season_id)
	var first_build := not _seen_grown.has(season_id)
	var seen: Dictionary = _seen_grown.get(season_id, {})
	var fresh: Array[SeasonFieldFlower] = []
	_spot_count = spots.size()
	_grown_count = 0
	for i in _spot_count:
		var spec: Array = spots[i]
		var side := float(spec[2])
		var roster_i := clampi(int(spec[3]), 0, pool.size() - 1)
		var need := int(spec[4])
		var type_id := str(pool[roster_i])
		var have := int(stash.get(type_id, 0))
		if have >= need:
			var flower: SeasonFieldFlower = FLOWER_SCRIPT.new()
			flower.name = "MeadowSpot_%d" % i
			flower.dark_kit = dark
			flower.crop_fill = _kit
			flower.puff_layer = _puff_layer
			flower.shadow_color = FLOWER_SHADOW_DARK if dark else UiHomeField.FLOWER_SHADOW
			add_child(flower)
			flower.setup_spot(type_id, side, 3)
			flower.set_meta("spot_index", i)
			flower.set_meta("spot_spec", [float(spec[0]), float(spec[1]), side])
			_grown_count += 1
			if not first_build and not seen.has(i):
				fresh.append(flower)
			seen[i] = true
		else:
			var soil := Panel.new()
			soil.name = "MeadowSoil_%d" % i
			soil.mouse_filter = Control.MOUSE_FILTER_IGNORE
			soil.custom_minimum_size = Vector2(side * 0.68, side * 0.27)
			soil.size = soil.custom_minimum_size
			var h := int(soil.size.y)
			var sb := UiStage.box(SOIL_DARK_FILL, int(h / 2.0), 3, SOIL_DARK_EDGE) if dark else UiHomeField.soil_spot(h)
			soil.add_theme_stylebox_override("panel", sb)
			soil.set_meta("spot_index", i)
			soil.set_meta("spot_spec", [float(spec[0]), float(spec[1]), side])
			add_child(soil)
			seen.erase(i)
	_seen_grown[season_id] = seen
	_refresh_meadow_chrome(_grown_count)
	apply_reveal(_reveal_u, _meadow_rect)
	# Novo izraslo mjesto (prag pređen od zadnjeg prikaza): rast 0 → 1,12 → 1.
	for j in fresh.size():
		fresh[j].play_grow(GROW_STAGGER * j)
	_sync_sway()
	_restart_wander()


func is_any_flower_growing() -> bool:
	for f in _meadow_flowers():
		if (f as SeasonFieldFlower).is_fx_playing():
			return true
	return false


func _refresh_meadow_chrome(grown: int) -> void:
	if meadow_note:
		meadow_note.visible = grown <= 0
		if grown <= 0:
			meadow_note.text = "Nothing has grown here yet. Bring seeds back from a run."
	grown_changed.emit(grown, UiHomeField.MEADOW_SPOTS.size())


func _meadow_bounds() -> Rect2:
	var bounds := size
	if bounds.x < 8.0 and meadow_ground:
		bounds = meadow_ground.size
	return Rect2(Vector2.ZERO, bounds)


func _hide_pip_and_stop() -> void:
	_stop_wander()
	_pip_state = _PipState.NONE
	_last_sniff_id = 0
	_set_pip_pose("walk")
	if meadow_pip:
		meadow_pip.visible = false


func _stop_wander() -> void:
	if _wander_tween:
		_wander_tween.kill()
		_wander_tween = null


func _place_pip_home() -> void:
	if meadow_pip == null or _open_season_id.is_empty():
		return
	meadow_pip.custom_minimum_size = Vector2(UiHomeField.PIP_SIZE, UiHomeField.PIP_SIZE)
	meadow_pip.size = meadow_pip.custom_minimum_size
	var bounds := _meadow_bounds()
	var page := Vector2(UiHomeField.PAGE)
	var base := Vector2(UiHomeField.PIP_DEFAULT_BASE)
	var home := Vector2(
		bounds.size.x * (base.x / page.x) - _pip_size().x * 0.5,
		bounds.size.y * (base.y / page.y) - _pip_size().y
	)
	meadow_pip.position = _clamp_pip_pos(home)


## Pojas u kojem Pip smije stajati — PIP_BASE_ZONE su koordinate NOGU, pa se
## pretvaraju u prostor gornjeg lijevog ugla i skaliraju s livadom.
func _pip_bounds() -> Rect2:
	var bounds := _meadow_bounds()
	var page := Vector2(UiHomeField.PAGE)
	var zone := Rect2(UiHomeField.PIP_BASE_ZONE)
	var sz := _pip_size()
	var left := bounds.size.x * (zone.position.x / page.x) - sz.x * 0.5
	var top := bounds.size.y * (zone.position.y / page.y) - sz.y
	var w := bounds.size.x * (zone.size.x / page.x)
	var h := bounds.size.y * (zone.size.y / page.y)
	return Rect2(Vector2(left, top), Vector2(maxf(w, 1.0), maxf(h, 1.0)))


func _restart_wander() -> void:
	_stop_wander()
	_last_sniff_id = 0
	if meadow_pip == null:
		_pip_state = _PipState.NONE
		return
	if _pip_hold:
		_pip_state = _PipState.NONE
		meadow_pip.visible = false
		return
	meadow_pip.visible = true
	meadow_pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meadow_pip.z_index = 20
	_place_pip_home()
	_enter_pip_state(_PipState.WALK)


func _pip_size() -> Vector2:
	if meadow_pip and meadow_pip.size.x >= 8.0:
		return meadow_pip.size
	return Vector2(UiHomeField.PIP_SIZE, UiHomeField.PIP_SIZE)


func _clamp_pip_pos(pos: Vector2) -> Vector2:
	var safe := _pip_bounds()
	return Vector2(
		clampf(pos.x, safe.position.x, maxf(safe.position.x, safe.end.x)),
		clampf(pos.y, safe.position.y, maxf(safe.position.y, safe.end.y))
	)


func _meadow_flowers() -> Array[Control]:
	var out: Array[Control] = []
	for child in get_children():
		if child.is_in_group("meadow_flower") and child is Control:
			out.append(child as Control)
	return out


func _random_safe_pip_pos() -> Vector2:
	var safe := _pip_bounds()
	return Vector2(
		randf_range(safe.position.x, maxf(safe.position.x, safe.end.x)),
		randf_range(safe.position.y, maxf(safe.position.y, safe.end.y))
	)


func _pip_pos_for_flower(flower: Control) -> Vector2:
	var dest := flower.position + (flower.size - _pip_size()) * 0.5
	return _clamp_pip_pos(dest)


func _enter_pip_state(state: int) -> void:
	_stop_wander()
	_pip_state = state
	match state:
		_PipState.WALK:
			_start_walk()
		_PipState.SNIFF:
			_start_sniff()
		_PipState.SLEEP:
			_start_sleep()
		_:
			_pip_state = _PipState.NONE


func _pick_next_pip_state() -> void:
	if _open_season_id.is_empty() or meadow_pip == null or not meadow_pip.visible:
		_hide_pip_and_stop()
		return
	_enter_pip_state(_weighted_next_state(_pip_state))


func _weighted_next_state(current: int) -> int:
	var options: Array[int] = []
	var weights: Array[float] = []
	if current != _PipState.WALK:
		options.append(_PipState.WALK)
		weights.append(PIP_WEIGHT_WALK)
	if current != _PipState.SNIFF:
		options.append(_PipState.SNIFF)
		weights.append(PIP_WEIGHT_SNIFF)
	if current != _PipState.SLEEP:
		options.append(_PipState.SLEEP)
		weights.append(PIP_WEIGHT_SLEEP)
	if options.is_empty():
		return _PipState.WALK
	var total := 0.0
	for w in weights:
		total += w
	var roll := randf() * total
	var acc := 0.0
	for i in options.size():
		acc += weights[i]
		if roll <= acc:
			return options[i]
	return options[options.size() - 1]


func _pick_walk_dest() -> Vector2:
	var current := meadow_pip.position
	var dest: Vector2
	if randf() < 0.5:
		dest = _random_safe_pip_pos()
	else:
		var flowers := _meadow_flowers()
		if flowers.is_empty():
			dest = _random_safe_pip_pos()
		else:
			var flower: Control = flowers[randi() % flowers.size()]
			dest = _pip_pos_for_flower(flower)
	if dest.distance_to(current) >= PIP_MIN_MOVE:
		return dest
	for _i in 6:
		var alt := _random_safe_pip_pos()
		if alt.distance_to(current) >= PIP_MIN_MOVE:
			return alt
	return dest


func _tween_pip_to(dest: Vector2, duration: float, on_done: Callable) -> void:
	if meadow_pip == null:
		_pip_state = _PipState.NONE
		return
	_stop_wander()
	meadow_pip.position = _clamp_pip_pos(meadow_pip.position)
	dest = _clamp_pip_pos(dest)
	_wander_tween = create_tween()
	_wander_tween.set_trans(Tween.TRANS_SINE)
	_wander_tween.set_ease(Tween.EASE_IN_OUT)
	_wander_tween.tween_property(meadow_pip, "position", dest, duration)
	_wander_tween.finished.connect(on_done, CONNECT_ONE_SHOT)


func _start_walk() -> void:
	if meadow_pip == null:
		_pip_state = _PipState.NONE
		return
	_set_pip_pose("walk", true)
	var dest := _pick_walk_dest()
	var duration := clampf(
		meadow_pip.position.distance_to(dest) / PIP_WALK_SPEED, PIP_WALK_MIN, PIP_WALK_MAX
	)
	_tween_pip_to(dest, duration, _on_pip_move_finished)


func _pick_sniff_flower() -> Control:
	var flowers := _meadow_flowers()
	if flowers.is_empty():
		return null
	var others: Array[Control] = []
	for flower in flowers:
		if flower.get_instance_id() != _last_sniff_id:
			others.append(flower)
	var pool: Array[Control] = others if not others.is_empty() else flowers
	return pool[randi() % pool.size()]


func _start_sniff() -> void:
	if meadow_pip == null:
		_pip_state = _PipState.NONE
		return
	var flower := _pick_sniff_flower()
	if flower == null:
		_start_sniff_idle()
		return
	_last_sniff_id = flower.get_instance_id()
	var dest := _pip_pos_for_flower(flower)
	if meadow_pip.position.distance_to(dest) <= PIP_SNIFF_NEAR:
		_start_sniff_idle()
		return
	var duration := clampf(
		meadow_pip.position.distance_to(dest) / PIP_WALK_SPEED, 0.8, PIP_SNIFF_WALK_MAX
	)
	_set_pip_pose("walk", true)
	_tween_pip_to(dest, duration, _on_pip_move_finished)


func _start_sniff_idle() -> void:
	_stop_wander()
	_pip_state = _PipState.SNIFF
	if meadow_pip:
		meadow_pip.position = _clamp_pip_pos(meadow_pip.position)
	# Season Kit: Pip njuši (poza + nagib prema cvijetu), cvijet se nakloni i pusti polen.
	var flower := instance_from_id(_last_sniff_id) as SeasonFieldFlower if _last_sniff_id != 0 else null
	var dir := 1.0
	if flower != null and is_instance_valid(flower) and meadow_pip:
		dir = 1.0 if flower.position.x + flower.size.x * 0.5 >= meadow_pip.position.x + meadow_pip.size.x * 0.5 else -1.0
		if _kit:
			flower.play_sniff()
	_set_pip_pose("sniff", false, dir)
	_wander_tween = create_tween()
	_wander_tween.tween_interval(randf_range(0.7, 1.4))
	_wander_tween.finished.connect(_on_pip_idle_finished, CONNECT_ONE_SHOT)


func _start_sleep() -> void:
	_stop_wander()
	if meadow_pip:
		meadow_pip.position = _clamp_pip_pos(meadow_pip.position)
	_set_pip_pose("sleep")
	_wander_tween = create_tween()
	_wander_tween.tween_interval(randf_range(2.0, 5.0))
	_wander_tween.finished.connect(_on_pip_idle_finished, CONNECT_ONE_SHOT)


## Poza Pipa po FSM stanju (Season Kit). Sezone bez kita: samo hod (bez poza).
func _set_pip_pose(pose: String, walking: bool = false, tilt_dir: float = 1.0) -> void:
	# Pip spava → ambijent se smiri (0,35 za 1,2 s); budi se → nazad.
	if _ambient:
		_ambient.set_calm(_kit and pose == "sleep")
	if meadow_pip == null or not meadow_pip.has_method("set_pose"):
		return
	meadow_pip.call("set_pose", pose if _kit else "walk", walking and _kit, tilt_dir)


func _on_pip_move_finished() -> void:
	_wander_tween = null
	if _open_season_id.is_empty() or meadow_pip == null or not meadow_pip.visible:
		_hide_pip_and_stop()
		return
	if _pip_state == _PipState.SNIFF:
		_start_sniff_idle()
		return
	_pick_next_pip_state()


func _on_pip_idle_finished() -> void:
	_wander_tween = null
	_pick_next_pip_state()
