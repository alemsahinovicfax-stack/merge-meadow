class_name LevelPathView
extends Control

## Level Path sezone (design_handoff_level_path): cijela stranica 1080 x 1633 između headera i
## tab bara. Sadržaj 1080 x 4900 se crta JEDNOM (SeasonBackdrop iz kits[id].path); skrol samo
## pomjera sadržaj. Pređeni put (Line2D, 2–3 poteza) se mijenja samo kad se promijeni level.
## Kamenje (20) i sanduci (4) su statični crteži; animira se samo transformom: skok i klimanje
## reward_ready sanduka + 3 iskre, skok Pipa, pop kamena, prsten i prašina.
## Play i ‹ Field su u donjem redu (SeasonStage / MainMenu) — ovdje nisu.
## Pojasevi težine (design_handoff_leveli_endless · A1): pločica pojasa na svakom kamenu (crta se
## s kamenom), zastavica s imenom uz prvi kamen pojasa (1 / 6 / 11 / 16). Spreman sanduk (C):
## frejmovi closed / peek, odvojena sjena, ravna pločica sadržaja ispod, bez „Claim".

signal reward_claimed(n: int)
signal hop_finished
## Skok 15 → 16 prvi put u sezoni: Endless je otključan (MainMenu animira dugme — CD B2).
signal endless_unlocked(season_id: String)

const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const DRAG_START := 14.0
const FRICTION := 5.0
const MIN_FLING := 40.0
const LOCATOR := Rect2(880, 1316, 176, 96)
## Toast sistema na y 1393 artboarda = 1250 stranice.
const TOAST_Y := 1250.0
const TITLE_Y := 24.0
const BANNER_Y := 150.0
## Sanduk koji čeka Claim (design_handoff_leveli_endless · chest_ready.json, bez pilule „Claim"):
## ciklus 1,8 s (sanduk 20: 1,5 s, 34 px, ±10°) — skok 0–0,3, doskok sa squashom 0,3–0,42, poklopac
## zaviri (frejm peek) 0,42–0,66, klimanje 0,42–0,78 (1,5 zamaha), mir. Samo transform + zamjena frejma.
const READY_HOP_END := 0.3
const READY_LAND_END := 0.42
const READY_PEEK_END := 0.66
const READY_WIGGLE_END := 0.78
const READY_TIMELINE := 1.8
const BOUNCE_SQUASH := Vector2(0.07, 0.08)
## Dodir sanduka hvata i pločicu sadržaja ispod njega, ne samo crtež.
const CHEST_TAP_H := 270.0
const SPARK_POS: Array[Vector2] = [Vector2(-6, 26), Vector2(164, 6), Vector2(178, 104)]
const SPARK_SIZE := 40.0
const HOP_WAIT := 0.12
const HOP_JUMP := 0.7
const HOP_SETTLE := 0.18
const HOP_ARC := 74.0
const LAND_POP := 1.12
const LAND_POP_SEC := 0.2
const HIGHLIGHT := 1.22
const HIGHLIGHT_SEC := 0.5
const SHAKE_DEG := 7.0
const SHAKE_SEC := 0.3
const FLAG_RAISE_SEC := 0.4
const BANNER_IN_SEC := 0.28
const SCROLL_TO_PIP_SEC := 0.36

var season_id: String = ""
## Level koji se crta (1…21). Za vrijeme skoka zaostaje za GameState dok Pip ne sleti.
var shown_level: int = 1

var _scroll: float = 0.0
var _vel: float = 0.0
var _press: bool = false
var _dragging: bool = false
var _press_pos := Vector2.ZERO
var _last_pos := Vector2.ZERO
var _last_t: int = 0
var _anim_t: float = 0.0
var _hop_running: bool = false
var _scroll_tween: Tween
var _pip_free: bool = true
var _built_season: String = ""
var _claimed: Array[int] = []
var _hop_from: int = 0
var _hop_to: int = 0

var _clip: Control
var _content: Control
var _bg: _Backdrop
var _passed: Node2D
var _pole: TextureRect
var _pennant: TextureRect
var _stones: Array[_Stone] = []
var _flags: Array[_BandFlag] = []
var _chests: Dictionary = {}
var _fx: Node2D
var _banner: _Banner
var _pip_slot: Node2D
var _title: _Title
var _locator: _Locator
var _toast: PopupToast
var _popup: LevelPathRewardPopup
var actor: UiPip


func _init() -> void:
	name = "LevelPath"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(UiHomeField.PAGE)
	_clip = Control.new()
	_clip.name = "PathScroll"
	_clip.clip_contents = true
	_clip.mouse_filter = Control.MOUSE_FILTER_STOP
	_clip.set_anchors_preset(Control.PRESET_FULL_RECT)
	_clip.gui_input.connect(_on_clip_input)
	add_child(_clip)
	_content = Control.new()
	_content.name = "PathContent"
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.size = Vector2(LevelPathKit.W, LevelPathKit.H)
	_clip.add_child(_content)
	_bg = _Backdrop.new()
	_bg.size = _content.size
	_content.add_child(_bg)
	_passed = Node2D.new()
	_passed.name = "PassedRoad"
	_content.add_child(_passed)
	_pole = _tex_rect("GoalPole")
	_content.add_child(_pole)
	_pennant = _tex_rect("Pennant")
	_pole.add_child(_pennant)
	for b in UiLevels.BANDS:
		var f := _BandFlag.new()
		f.band_n = int(b["n"])
		_flags.append(f)
		_content.add_child(f)
	for n in LevelPathDomain.REWARD_LEVELS:
		var ch := _Chest.new()
		ch.n = n
		_chests[n] = ch
		_content.add_child(ch)
	for i in LevelPathDomain.LEVELS:
		var st := _Stone.new()
		st.n = i + 1
		_stones.append(st)
		_content.add_child(st)
	_fx = Node2D.new()
	_fx.name = "PathFx"
	_content.add_child(_fx)
	_banner = _Banner.new()
	_banner.visible = false
	_content.add_child(_banner)
	_pip_slot = Node2D.new()
	_pip_slot.name = "PathPipSlot"
	_clip.add_child(_pip_slot)
	_title = _Title.new()
	add_child(_title)
	_locator = _Locator.new()
	_locator.visible = false
	_locator.pressed.connect(scroll_to_pip)
	add_child(_locator)
	_toast = PopupToast.new().setup(TOAST_Y)
	add_child(_toast)
	_popup = LevelPathRewardPopup.new()
	_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	_popup.claimed.connect(_on_popup_claimed)
	_popup.finished.connect(_on_popup_finished)
	add_child(_popup)


func _ready() -> void:
	if not _clip.is_in_group(BLOCK_HUB_SWIPE_GROUP):
		_clip.add_to_group(BLOCK_HUB_SWIPE_GROUP)
	_ensure_actor()
	set_process(false)


static func _tex_rect(node_name: String) -> TextureRect:
	var t := TextureRect.new()
	t.name = node_name
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	return t


# --- javni API ---

## Put sezone na trenutnom napretku; skrol po pravilu otvaranja (§ Odlučeno 3).
func show_season(p_season_id: String, level: int = -1) -> void:
	season_id = p_season_id
	shown_level = GameState.season_level(season_id) if level < 0 else level
	_claimed = GameState.level_path_domain.claimed_of(season_id)
	if _built_season != season_id:
		_build_season()
	_refresh_states()
	set_scroll(LevelPathKit.open_scroll(shown_level, _ready_for(shown_level)))
	_place_pip_on_stone()
	_sync_process()


func is_busy() -> bool:
	return _hop_running or _popup.is_busy() or (_scroll_tween != null and _scroll_tween.is_running())


func is_popup_open() -> bool:
	return _popup.is_busy()


func get_scroll() -> float:
	return _scroll


func set_scroll(v: float) -> void:
	_scroll = clampf(v, 0.0, LevelPathKit.SCROLL_MAX)
	_content.position.y = -_scroll
	if _pip_free:
		_place_pip_on_stone()
	_update_locator()


## Pipova stopala na kamenu, u koordinatama stranice (za prelaz polje ↔ put).
func pip_page_feet(level: int = -1) -> Vector2:
	var lv := shown_level if level < 0 else level
	return LevelPathKit.pip_feet(lv) - Vector2(0.0, _scroll)


## Prelaz: Pip leti slobodno (stopala u koordinatama stranice, skala boxa).
func set_pip_travel(feet_page: Vector2, scale_k: float) -> void:
	_pip_free = false
	_pip_slot.position = LevelPathKit.pip_origin(feet_page) + Vector2(0.0, LevelPathKit.PIP_BOX * (1.0 - LevelPathKit.PIP_FEET_K)) * (scale_k - 1.0)
	_pip_slot.scale = Vector2.ONE * scale_k


func release_pip_travel() -> void:
	_pip_free = true
	_pip_slot.scale = Vector2.ONE
	_place_pip_on_stone()


func play_pip(anim: String) -> void:
	_ensure_actor()
	if actor:
		actor.play(anim)
		actor.loop_id = "idle"


func set_pip_visible(v: bool) -> void:
	_pip_slot.visible = v


func stone_state(n: int) -> String:
	return _stones[n - 1].state


func chest_state(n: int) -> String:
	return (_chests[n] as _Chest).state


## Frejm spremnog sanduka koji se sad crta: "closed" | "peek" | "" (nije spreman).
func chest_frame(n: int) -> String:
	return (_chests[n] as _Chest).frame


func chest_node(n: int) -> Control:
	return _chests[n] as Control


func band_flag_rects() -> Array[Rect2]:
	var out: Array[Rect2] = []
	for f in _flags:
		out.append(Rect2(f.position, f.size))
	return out


func is_locator_visible() -> bool:
	return _locator.visible


func is_banner_visible() -> bool:
	return _banner.visible


func title_text() -> String:
	return _title.text_for()


func toast_texts() -> PackedStringArray:
	return _toast.get_texts()


func get_popup() -> LevelPathRewardPopup:
	return _popup


func passed_point_count() -> int:
	var line := _passed.get_child(0) as Line2D if _passed.get_child_count() > 0 else null
	return line.get_point_count() if line else 0


## Tap na sanduk / njegov kamen (i smoke testovi).
func tap_reward(n: int) -> void:
	if is_busy() or not _chests.has(n):
		return
	var st := LevelPathDomain.reward_state_for(n, shown_level, _claimed)
	if st == LevelPathDomain.REWARD_READY:
		_popup.open_for(season_id, n)
	elif st == LevelPathDomain.REWARD_LOCKED:
		Sfx.play("ui_denied")
		_shake((_chests[n] as _Chest).art)
		_toast.show_text(LevelPathKit.locked_text(n), null, "lock")


## Pređen level: Pip skoči sa `from` na `to` (≤ 1,2 s). to = 21 → complete (binky, zastavica, traka).
func play_hop(from: int, to: int) -> void:
	if _hop_running:
		return
	_hop_running = true
	_hop_from = from
	_hop_to = to
	shown_level = from
	_refresh_states()
	_place_pip_on_stone()
	var a := LevelPathKit.pip_feet(from)
	var b := LevelPathKit.pip_feet(mini(to, LevelPathKit.cp_count()))
	var top := minf(a.y, b.y)
	var need_scroll := top - 420.0 < _scroll or b.y - _scroll > LevelPathKit.VIEW_SAFE.y
	if need_scroll:
		_scroll_to(top - 760.0, SCROLL_TO_PIP_SEC, _hop_wait.bind(from, to))
	else:
		_hop_wait(from, to)
	_sync_process()


func scroll_to_pip() -> void:
	if _hop_running:
		return
	Sfx.play("ui_tap")
	_scroll_to(LevelPathKit.open_scroll(shown_level, _ready_for(shown_level)), SCROLL_TO_PIP_SEC)


# --- gradnja ---

func _build_season() -> void:
	_built_season = season_id
	_bg.scene = LevelPathKit.scene(season_id)
	_bg.queue_redraw()
	for c in _passed.get_children():
		c.queue_free()
	for s in LevelPathKit.passed_strokes(season_id):
		var line := Line2D.new()
		line.width = float(s[0])
		line.default_color = UiSeasons.col(str(s[1]))
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.round_precision = 6
		_passed.add_child(line)
	var fb := LevelPathKit.flag_bottom()
	_pole.texture = LevelPathKit.tex("path/goal_pole.svg")
	_pole.size = LevelPathKit.FLAG_BOX
	_pole.position = fb - LevelPathKit.FLAG_ANCHOR
	_pennant.texture = LevelPathKit.tex("path/goal_pennant.svg")
	_pennant.size = LevelPathKit.PENNANT_BOX
	for st in _stones:
		st.season_id = season_id
		st.state = ""
	_place_band_flags()
	for n in _chests:
		var ch: _Chest = _chests[n]
		ch.season_id = season_id
		ch.state = ""
		ch.setup_layout()
	_title.season_id = season_id


func _refresh_states() -> void:
	_claimed = GameState.level_path_domain.claimed_of(season_id)
	var lv := shown_level
	for st in _stones:
		st.set_state(LevelPathDomain.cp_state(st.n, lv))
	for n in _chests:
		(_chests[n] as _Chest).set_state(LevelPathDomain.reward_state_for(n, lv, _claimed))
	var pts := LevelPathKit.passed_points(lv)
	for line: Line2D in _passed.get_children():
		line.points = pts
	var complete := lv >= LevelPathDomain.COMPLETE
	_pennant.position = LevelPathKit.PENNANT_UP if complete else LevelPathKit.PENNANT_DOWN
	_banner.visible = complete
	_banner.scale = Vector2.ONE
	_title.level = lv
	_title.queue_redraw()
	_sync_process()


## A1 · zastavica pojasa uz prvi kamen pojasa: dno stuba na kamen.y + 40; x desno (+96) ili lijevo
## (−286), pa dalje (+150 / −340) — prva strana koja ne dira sanduk ni kamen (LevelBands.dc.html).
func _place_band_flags() -> void:
	for f in _flags:
		var b := UiLevels.band(f.band_n)
		var c := LevelPathKit.cp(int(b["from"]))
		var y := c.y + UiLevels.FLAG_DROP - UiLevels.FLAG_FOOT_Y
		var cands: Array[float] = []
		for dx in [96.0, -286.0, 150.0, -340.0]:
			var x := c.x + float(dx)
			if x > 10.0 and x + 200.0 < LevelPathKit.W - 10.0:
				cands.append(x)
		var pick := cands[0] if not cands.is_empty() else c.x + 96.0
		for x in cands:
			if not _flag_hits(x, y):
				pick = x
				break
		f.position = Vector2(pick, y)
		f.size = UiLevels.FLAG
		f.queue_redraw()


func _flag_hits(x: float, y: float) -> bool:
	for n in LevelPathDomain.REWARD_LEVELS:
		var p: Vector2 = LevelPathKit.chest(n)["pos"]
		if x < p.x + 130.0 and x + 200.0 > p.x - 130.0 and y < p.y + 20.0 and y + 214.0 > p.y - 230.0:
			return true
	for i in LevelPathDomain.LEVELS:
		var o := LevelPathKit.cp(i + 1)
		if x < o.x + 90.0 and x + 200.0 > o.x - 90.0 and y < o.y + 60.0 and y + 180.0 > o.y - 60.0:
			return true
	return false


func _ready_for(level: int) -> Array:
	var out: Array = []
	for n in LevelPathDomain.REWARD_LEVELS:
		if LevelPathDomain.reward_state_for(n, level, _claimed) == LevelPathDomain.REWARD_READY:
			out.append(n)
	return out


func _ensure_actor() -> void:
	if actor != null:
		return
	var key := UiPip.equipped_skin_key()
	if not UiPip.atlas_ready(key):
		UiPip.request_atlas(key)
		_await_actor.call_deferred(key)
		return
	_spawn_actor(key)


func _await_actor(key: String) -> void:
	while not UiPip.atlas_ready(key):
		if not is_inside_tree():
			return
		await get_tree().process_frame
		UiPip.request_atlas(key)
	if actor == null:
		_spawn_actor(key)


func _spawn_actor(key: String) -> void:
	actor = UiPip.new()
	actor.name = "PathPip"
	actor.view = "front"
	actor.box_px = LevelPathKit.PIP_BOX
	actor.follow_equipped = true
	actor.skin = key
	_pip_slot.add_child(actor)
	actor.position = Vector2.ZERO
	actor.set_loop("idle")


func _place_pip_on_stone() -> void:
	if not _pip_free:
		return
	_pip_slot.scale = Vector2.ONE
	_pip_slot.position = LevelPathKit.pip_origin(pip_page_feet())


# --- skrol ---

func _on_clip_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if mb.pressed and not _hop_running:
				_kill_scroll_tween()
				set_scroll(_scroll + (-120.0 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 120.0))
			_clip.accept_event()
			return
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		_pointer(mb.position, mb.pressed)
		_clip.accept_event()
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		_pointer(st.position, st.pressed)
		_clip.accept_event()
	elif event is InputEventMouseMotion and _press:
		_move((event as InputEventMouseMotion).position)
		_clip.accept_event()
	elif event is InputEventScreenDrag and _press:
		_move((event as InputEventScreenDrag).position)
		_clip.accept_event()


func _pointer(pos: Vector2, pressed: bool) -> void:
	if pressed:
		_press = true
		_dragging = false
		_press_pos = pos
		_last_pos = pos
		_last_t = Time.get_ticks_msec()
		_vel = 0.0
		return
	if not _press:
		return
	_press = false
	if _dragging:
		_dragging = false
		if absf(_vel) > MIN_FLING:
			_sync_process()
		else:
			_vel = 0.0
		return
	_tap(pos)


func _move(pos: Vector2) -> void:
	if _hop_running or _popup.is_busy():
		return
	if not _dragging and absf(pos.y - _press_pos.y) < DRAG_START:
		return
	if not _dragging:
		_dragging = true
		_kill_scroll_tween()
	var now := Time.get_ticks_msec()
	var dy := pos.y - _last_pos.y
	var dt := maxf(0.001, float(now - _last_t) / 1000.0)
	_vel = lerpf(_vel, -dy / dt, 0.5)
	_last_pos = pos
	_last_t = now
	set_scroll(_scroll - dy)


func _tap(page_pos: Vector2) -> void:
	var p := page_pos + Vector2(0.0, _scroll)
	for n in _chests:
		var ch: _Chest = _chests[n]
		var box := Rect2(ch.position, ch.size)
		box.size.y = maxf(box.size.y, CHEST_TAP_H * ch.label.k)
		var hit := box.has_point(p)
		var st: _Stone = _stones[n - 1]
		if not hit:
			hit = Rect2(st.position, st.size).has_point(p)
		if hit:
			tap_reward(n)
			return


func _scroll_to(target: float, sec: float, done: Callable = Callable()) -> void:
	_kill_scroll_tween()
	_vel = 0.0
	target = clampf(target, 0.0, LevelPathKit.SCROLL_MAX)
	if absf(target - _scroll) < 1.0 or not is_inside_tree():
		set_scroll(target)
		if done.is_valid():
			done.call()
		return
	_scroll_tween = create_tween()
	_scroll_tween.tween_method(set_scroll, _scroll, target, sec).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if done.is_valid():
		_scroll_tween.tween_callback(done)


func _kill_scroll_tween() -> void:
	if _scroll_tween:
		_scroll_tween.kill()
		_scroll_tween = null


func _update_locator() -> void:
	var y := pip_page_feet().y
	var off := 0
	if y < LevelPathKit.VIEW_SAFE.x:
		off = -1
	elif y > LevelPathKit.VIEW_SAFE.y:
		off = 1
	var show := off != 0 and not _hop_running
	if _locator.visible != show or _locator.dir != off:
		_locator.dir = off
		_locator.visible = show
		_locator.queue_redraw()


# --- animacije (samo transform) ---

func _sync_process() -> void:
	set_process(is_visible_in_tree() and (_any_ready() or absf(_vel) > 0.0))


func _any_ready() -> bool:
	if UiPip.reduce_motion():
		return false
	for n in _chests:
		if (_chests[n] as _Chest).state == LevelPathDomain.REWARD_READY:
			return true
	return false


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_sync_process()


func _process(delta: float) -> void:
	if absf(_vel) > 0.0 and not _press:
		set_scroll(_scroll + _vel * delta)
		_vel *= exp(-FRICTION * delta)
		if absf(_vel) < MIN_FLING or _scroll <= 0.0 or _scroll >= LevelPathKit.SCROLL_MAX:
			_vel = 0.0
	_anim_t += delta
	var i := 0
	for n in LevelPathDomain.REWARD_LEVELS:
		var ch: _Chest = _chests[n]
		if ch.state == LevelPathDomain.REWARD_READY and not UiPip.reduce_motion():
			_animate_ready(ch, float(i) * UiLevels.CHEST_PHASE)
		i += 1
	if not _any_ready() and absf(_vel) <= 0.0:
		set_process(false)


## Petlja spremnog sanduka (chest_ready.json → loop), `ph` = pomak faze u s (0,23 po sanduku):
## u (s na liniji od 1,8) = ((t + ph) mod ciklus) / ciklus × 1,8. Sjena ostaje na tlu i skuplja se
## (1 → 0,7) dok je sanduk u zraku; 3 iskre: scale 0,4 → 1,2, rotacija 90°, alfa po zvonu (1,6 s).
func _animate_ready(ch: _Chest, ph: float) -> void:
	if ch.art_busy:
		return
	var cyc := UiLevels.CHEST_CYCLE_BIG if ch.big else UiLevels.CHEST_CYCLE
	var hop_px := UiLevels.CHEST_HOP_BIG if ch.big else UiLevels.CHEST_HOP
	var deg := UiLevels.CHEST_WIGGLE_BIG if ch.big else UiLevels.CHEST_WIGGLE
	var u := fposmod(_anim_t + ph, cyc) / cyc * READY_TIMELINE
	var hop := UiLevels.bell(u, 0.0, READY_HOP_END)
	var sq := UiLevels.bell(u, READY_HOP_END, READY_LAND_END)
	var w := 0.0
	if u > READY_LAND_END and u < READY_WIGGLE_END:
		var k := (u - READY_LAND_END) / (READY_WIGGLE_END - READY_LAND_END)
		w = sin(k * PI * 3.0) * (1.0 - k)
	ch.art.position.y = ch.art_home.y - hop_px * hop
	ch.art.scale = Vector2(1.0 + BOUNCE_SQUASH.x * sq, 1.0 - BOUNCE_SQUASH.y * sq)
	ch.art.rotation = deg_to_rad(deg * w)
	ch.shadow.scale = Vector2.ONE * (1.0 - 0.3 * hop)
	ch.set_frame("peek" if u > READY_LAND_END and u < READY_PEEK_END else "closed")
	for j in ch.sparks.size():
		var s: TextureRect = ch.sparks[j]
		var v := fposmod(_anim_t + float(j) * 0.53 + ph, UiLevels.CHEST_SPARK_SEC) / UiLevels.CHEST_SPARK_SEC
		var b := UiLevels.bell(v, 0.0, 0.5)
		s.scale = Vector2.ONE * (0.4 + 0.8 * b)
		s.rotation = deg_to_rad(90.0 * v)
		s.modulate.a = b


func _hop_wait(from: int, to: int) -> void:
	var t := create_tween()
	t.tween_interval(HOP_WAIT)
	t.tween_callback(_hop_jump.bind(from, to))


func _hop_jump(from: int, to: int) -> void:
	# Stari kamen postaje done i pređeni put se produži do novog; novi kamen je još locked.
	var to_cp := mini(to, LevelPathDomain.LEVELS)
	_stones[from - 1].set_state(LevelPathDomain.STATE_DONE)
	var pts := LevelPathKit.passed_points(to_cp)
	for line: Line2D in _passed.get_children():
		line.points = pts
	if to >= LevelPathDomain.COMPLETE:
		_celebrate(from)
		return
	play_pip("card_jump")
	var a := LevelPathKit.pip_feet(from)
	var b := LevelPathKit.pip_feet(to)
	_dust(a, 2)
	_pip_free = false
	var t := create_tween()
	t.tween_method(func(u: float) -> void:
		var e := _io2(clampf((u * HOP_JUMP - 0.1) / 0.44, 0.0, 1.0))
		var f := a.lerp(b, e) - Vector2(0.0, HOP_ARC * sin(PI * e))
		_pip_slot.position = LevelPathKit.pip_origin(f - Vector2(0.0, _scroll))
	, 0.0, 1.0, HOP_JUMP)
	t.tween_callback(_hop_land.bind(from, to))


func _hop_land(from: int, to: int) -> void:
	shown_level = to
	_refresh_states()
	_pip_free = true
	_place_pip_on_stone()
	var stone := _stones[to - 1]
	_pop(stone, LAND_POP, LAND_POP_SEC)
	var feet := LevelPathKit.pip_feet(to)
	_ring(feet)
	_dust(feet, 2)
	if LevelPathDomain.REWARDS.has(from):
		_pop((_chests[from] as _Chest).art, HIGHLIGHT, HIGHLIGHT_SEC)
	var t := create_tween()
	t.tween_interval(HOP_SETTLE)
	t.tween_callback(_hop_done)


func _celebrate(from: int) -> void:
	shown_level = LevelPathDomain.COMPLETE
	play_pip("binky")
	Sfx.play("unlock")
	_pennant.position = LevelPathKit.PENNANT_DOWN
	var t := create_tween().set_parallel()
	t.tween_property(_pennant, "position", LevelPathKit.PENNANT_UP, FLAG_RAISE_SEC).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_title.level = shown_level
	_title.queue_redraw()
	_banner.visible = true
	_banner.pivot_offset = Vector2(LevelPathKit.W * 0.5, 0.0)
	_banner.scale = Vector2.ONE * 0.6
	t.tween_property(_banner, "scale", Vector2.ONE, BANNER_IN_SEC).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if LevelPathDomain.REWARDS.has(from):
		(_chests[from] as _Chest).set_state(LevelPathDomain.reward_state_for(from, shown_level, _claimed))
		_pop((_chests[from] as _Chest).art, HIGHLIGHT, HIGHLIGHT_SEC)
	var w := create_tween()
	w.tween_interval(1.1)
	w.tween_callback(func() -> void:
		_refresh_states()
		_hop_done()
	)


func _hop_done() -> void:
	_hop_running = false
	_update_locator()
	_sync_process()
	hop_finished.emit()
	if _hop_from == LevelPathDomain.ENDLESS_UNLOCK_LEVEL and _hop_to == LevelPathDomain.ENDLESS_UNLOCK_LEVEL + 1 \
			and GameState.take_endless_unlock_moment(season_id):
		endless_unlocked.emit(season_id)
	_hop_from = 0
	_hop_to = 0


func _pop(c: Control, peak: float, sec: float) -> void:
	if c == null or UiPip.reduce_motion():
		return
	var ch := c.get_parent() as _Chest
	if ch:
		ch.art_busy = true
		c.position = ch.art_home
		c.rotation = 0.0
		ch.set_frame("closed")
	var t := c.create_tween()
	t.tween_method(func(u: float) -> void:
		c.scale = Vector2.ONE * (1.0 + (peak - 1.0) * sin(PI * u))
	, 0.0, 1.0, sec)
	t.tween_callback(func() -> void:
		c.scale = Vector2.ONE
		if ch:
			ch.art_busy = false
	)


func _shake(c: Control) -> void:
	if c == null:
		return
	var ch := c.get_parent() as _Chest
	if ch:
		ch.art_busy = true
		c.position = ch.art_home
		c.scale = Vector2.ONE
	var t := c.create_tween()
	t.tween_method(func(u: float) -> void:
		c.rotation = deg_to_rad(SHAKE_DEG * sin(u * PI * 4.0) * (1.0 - u))
	, 0.0, 1.0, SHAKE_SEC)
	t.tween_callback(func() -> void:
		c.rotation = 0.0
		if ch:
			ch.art_busy = false
	)


## Prašina (2 oblačića lijevo / desno od stopala): alpha + pomak, 0,36 s.
func _dust(feet: Vector2, count: int) -> void:
	if UiPip.reduce_motion():
		return
	var tex := LevelPathKit.fx_tex("hop_dust")
	for i in count:
		var s := _fx_sprite(tex)
		var dir := -1.0 if i % 2 == 0 else 1.0
		s.position = feet + Vector2(dir * 40.0, 34.0)
		s.flip_h = dir > 0.0
		s.scale = Vector2.ONE * 0.8
		var t := s.create_tween().set_parallel()
		t.tween_property(s, "position", s.position + Vector2(dir * 46.0, -10.0), 0.36).set_ease(Tween.EASE_OUT)
		t.tween_property(s, "scale", Vector2.ONE, 0.36)
		t.tween_property(s, "modulate:a", 0.0, 0.36).set_ease(Tween.EASE_IN)
		t.chain().tween_callback(s.hide)


## Prsten na doskoku: scale 0,6 → 1,2 + alpha, 0,4 s.
func _ring(feet: Vector2) -> void:
	if UiPip.reduce_motion():
		return
	var s := _fx_sprite(LevelPathKit.fx_tex("land_ring"))
	s.position = feet + Vector2(0.0, 40.0)
	s.scale = Vector2.ONE * 0.6
	var t := s.create_tween().set_parallel()
	t.tween_property(s, "scale", Vector2.ONE * 1.2, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(s, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	t.chain().tween_callback(s.hide)


## Bazen: najviše 5 sprite-ova efekata (2 + 2 prašine, prsten).
func _fx_sprite(tex: Texture2D) -> Sprite2D:
	for c in _fx.get_children():
		var s := c as Sprite2D
		if not s.visible:
			s.texture = tex
			s.visible = true
			s.modulate.a = 1.0
			s.flip_h = false
			return s
	var n := Sprite2D.new()
	n.texture = tex
	_fx.add_child(n)
	return n


func fx_sprite_count() -> int:
	return _fx.get_child_count()


static func _io2(t: float) -> float:
	return 2.0 * t * t if t < 0.5 else 1.0 - pow(-2.0 * t + 2.0, 2.0) * 0.5


# --- nagrada ---

func _on_popup_claimed(n: int) -> void:
	_claimed = GameState.level_path_domain.claimed_of(season_id)
	reward_claimed.emit(n)


func _on_popup_finished(n: int) -> void:
	_refresh_states()
	if _chests.has(n):
		_pop((_chests[n] as _Chest).art, HIGHLIGHT, HIGHLIGHT_SEC)


# --- dijelovi ---

class _Backdrop extends Control:
	var scene: Dictionary = {}

	func _init() -> void:
		name = "PathBackdrop"
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		SeasonBackdrop.draw(self, scene, Rect2(Vector2.ZERO, size))


## Kamen checkpointa: sprite po sezoni i stanju + broj levela na licu (jedan crtež).
class _Stone extends Control:
	var n: int = 1
	var season_id: String = ""
	var state: String = ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_state(s: String) -> void:
		if s == state:
			return
		state = s
		name = "Stone%d" % n
		var k := LevelPathKit.CURRENT_SCALE if s == LevelPathDomain.STATE_CURRENT else 1.0
		var c := LevelPathKit.cp(n)
		size = LevelPathKit.STONE_BOX * k
		position = c - LevelPathKit.STONE_PIVOT * k
		pivot_offset = Vector2(size.x * 0.5, size.y * 0.4)
		scale = Vector2.ONE
		z_index = 1 if s == LevelPathDomain.STATE_CURRENT else 0
		queue_redraw()

	func _draw() -> void:
		var tex := LevelPathKit.stone_tex(season_id, state)
		if tex:
			draw_texture_rect(tex, Rect2(Vector2.ZERO, size), false)
		var k := size.x / LevelPathKit.STONE_BOX.x
		var px := float(LevelPathKit.NUM_PX_CURRENT if state == LevelPathDomain.STATE_CURRENT else LevelPathKit.NUM_PX)
		var txt := str(n)
		var w := UiHomeV3.text_w(900, px, txt, 0.0, true)
		var cy := LevelPathKit.STONE_PIVOT.y * k
		UiHomeV3.draw_text(self, 900, px, txt, Vector2((size.x - w) * 0.5, cy - px * 0.52), LevelPathKit.number_color(season_id, state), 0.0, true)
		# A1: pločica pojasa preko donjeg ruba kamena (sva stanja); 5/10/15/20 sa zvjezdicom.
		var tag := UiLevels.tag_tex(n)
		if tag:
			draw_texture_rect(tag, UiLevels.stone_tag_rect(n, k), false)


## Sanduk nagrade: sprite (skok i klimanje samo transformom), 3 iskre, oznaka nagrade dok je zaključan.
class _Chest extends Control:
	var n: int = 5
	var season_id: String = ""
	var state: String = ""
	var big: bool = false
	var k: float = 1.0
	var art: TextureRect
	var shadow: TextureRect
	var art_home := Vector2.ZERO
	var art_busy: bool = false
	var sparks: Array[TextureRect] = []
	var label: _ChestLabel
	## Spreman sanduk: "closed" | "peek"; ostala stanja "".
	var frame: String = ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		shadow = LevelPathView._tex_rect("ChestShadow")
		shadow.visible = false
		add_child(shadow)
		art = LevelPathView._tex_rect("ChestArt")
		add_child(art)
		for i in 3:
			var s := LevelPathView._tex_rect("Spark%d" % i)
			s.visible = false
			sparks.append(s)
			add_child(s)
		label = _ChestLabel.new()
		add_child(label)

	func setup_layout() -> void:
		name = "Chest%d" % n
		var ch := LevelPathKit.chest(n)
		big = bool(ch.get("big", false))
		k = LevelPathKit.CHEST_BIG_SCALE if big else 1.0
		size = LevelPathKit.CHEST_BOX * k
		position = (ch["pos"] as Vector2) - LevelPathKit.CHEST_ANCHOR * k
		art.size = size
		art_home = Vector2.ZERO
		art.position = art_home
		art.pivot_offset = Vector2(size.x * 0.5, size.y * 0.92)
		shadow.texture = UiLevels.tex("chest/shadow.svg")
		shadow.position = UiLevels.CHEST_SHADOW.position * k
		shadow.size = UiLevels.CHEST_SHADOW.size * k
		shadow.pivot_offset = shadow.size * 0.5
		var spark_tex := LevelPathKit.fx_tex("ready_spark")
		for i in sparks.size():
			var s := sparks[i]
			s.texture = spark_tex
			s.size = Vector2.ONE * LevelPathView.SPARK_SIZE * k
			s.position = LevelPathView.SPARK_POS[i] * k
			s.pivot_offset = s.size * 0.5
		label.chest = self
		label.k = k

	func set_state(s: String) -> void:
		if s == state:
			return
		state = s
		var ready := s == LevelPathDomain.REWARD_READY
		frame = ""
		if ready and UiLevels.tex("chest/ready_closed.svg") != null:
			set_frame("closed")
		else:
			art.texture = LevelPathKit.chest_tex(s, big)
		art.position = art_home
		art.scale = Vector2.ONE
		art.rotation = 0.0
		shadow.visible = not frame.is_empty()
		shadow.scale = Vector2.ONE
		# Reduce motion: iskre stoje (vidljive, mirne).
		for sp in sparks:
			sp.visible = ready
			sp.scale = Vector2.ONE
			sp.rotation = 0.0
			sp.modulate.a = 1.0
		label.queue_redraw()

	## Frejm spremnog sanduka (closed / peek) — tekstura se mijenja samo kad se frejm promijeni.
	func set_frame(f: String) -> void:
		if state != LevelPathDomain.REWARD_READY or f == frame:
			return
		frame = f
		art.texture = UiLevels.tex("chest/%sready_%s.svg" % ["big_" if big else "", f])


## Ispod sanduka: reward_locked → krem pilula (★3 crtež 52 + N · coin 44 + N). reward_ready →
## ravna RIM pločica sadržaja (h 58, rub 2 ink 18 %, bez sjene — ne liči na dugme; CD C):
## ★3 disk 46 + ×N · coin 40 + N (34/900). Tap na sanduk ili pločicu otvara popup.
class _ChestLabel extends Control:
	var chest: _Chest
	var k: float = 1.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if chest == null:
			return
		var cx := chest.size.x * 0.5
		var r: Array = LevelPathDomain.REWARDS[chest.n]
		if chest.state == LevelPathDomain.REWARD_READY:
			_draw_ready_tag(cx, "×%d" % int(r[0]), str(r[1]))
			return
		if chest.state == LevelPathDomain.REWARD_LOCKED:
			var fl := str(r[0])
			var co := str(r[1])
			var w := 6.0 + 52.0 + 8.0 + UiHomeV3.text_w(900, 38, fl, 0.0, true) + 8.0 + 6.0 + 44.0 + 8.0 + UiHomeV3.text_w(900, 38, co, 0.0, true) + 22.0
			var rect := Rect2(cx - w * 0.5, (LevelPathKit.CHEST_ANCHOR.y + 12.0) * k, w, 64.0)
			UiHomeV3.draw_panel(self, rect, UiHomeField.WARM_WHITE, 32.0, 3.0, UiHomeField.OUTLINE)
			var x := rect.position.x + 6.0
			var cy := rect.get_center().y
			var disc := Rect2(x, cy - 26.0, 52.0, 52.0)
			UiHomeV3.draw_panel(self, disc, UiHomeField.ACTIVE_RIM, 26.0, 2.0, Color(0.176, 0.204, 0.212, 0.18))
			UiPopups.draw_flower(self, disc.get_center(), GameState.star3_type_id_for_season(chest.season_id), 3, 44.0)
			x += 52.0 + 8.0
			UiHomeV3.draw_text(self, 900, 38, fl, Vector2(x, cy - 19.0), UiHomeField.OUTLINE, 0.0, true)
			x += UiHomeV3.text_w(900, 38, fl, 0.0, true) + 8.0 + 6.0
			UiPopups.draw_icon(self, UiPopups.icon("icon_coin"), Vector2(x + 22.0, cy), 44.0)
			x += 44.0 + 8.0
			UiHomeV3.draw_text(self, 900, 38, co, Vector2(x, cy - 19.0), UiHomeField.OUTLINE, 0.0, true)

	func _draw_ready_tag(cx: float, fl: String, co: String) -> void:
		var h := UiLevels.CHEST_TAG_H
		var w := 6.0 + 46.0 + 6.0 + UiHomeV3.text_w(900, 34, fl, 0.0, true) + 6.0 + 6.0 + 40.0 + 6.0 + UiHomeV3.text_w(900, 34, co, 0.0, true) + 20.0
		var rect := Rect2(cx - w * 0.5, chest.size.y + UiLevels.CHEST_TAG_GAP, w, h)
		UiHomeV3.draw_panel(self, rect, UiLevels.RIM, h * 0.5, 2.0, UiLevels.INK_18)
		var x := rect.position.x + 6.0
		var cy := rect.get_center().y
		var disc := Rect2(x, cy - 23.0, 46.0, 46.0)
		UiHomeV3.draw_panel(self, disc, UiLevels.CREAM, 23.0)
		UiPopups.draw_flower(self, disc.get_center(), GameState.star3_type_id_for_season(chest.season_id), 3, 46.0)
		x += 46.0 + 6.0
		UiHomeV3.draw_text(self, 900, 34, fl, Vector2(x, cy - 17.0), UiLevels.INK, 0.0, true)
		x += UiHomeV3.text_w(900, 34, fl, 0.0, true) + 6.0 + 6.0
		UiPopups.draw_icon(self, UiPopups.icon("icon_coin"), Vector2(x + 20.0, cy), 40.0)
		x += 40.0 + 6.0
		UiHomeV3.draw_text(self, 900, 34, co, Vector2(x, cy - 17.0), UiLevels.INK, 0.0, true)


## Zastavica pojasa (180 × 214) + krem pločica „Stroll 1–5" (32/900 + 24/800). Crta se jednom.
class _BandFlag extends Control:
	var band_n: int = 1

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _ready() -> void:
		name = "BandFlag%d" % band_n

	func _draw() -> void:
		var tex := UiLevels.flag_tex(band_n)
		if tex:
			draw_texture_rect(tex, Rect2(Vector2.ZERO, UiLevels.FLAG), false)
		var b := UiLevels.band(band_n)
		var nm := str(b["name"])
		var rng := "%d–%d" % [int(b["from"]), int(b["to"])]
		var w := 18.0 + UiHomeV3.text_w(900, 32, nm) + 8.0 + UiHomeV3.text_w(800, 24, rng) + 18.0
		var r := Rect2(UiLevels.FLAG_LABEL.position, Vector2(w, UiLevels.FLAG_LABEL.size.y))
		UiHomeV3.draw_panel(self, r, UiLevels.CREAM, 26.0, 3.0, UiLevels.INK)
		var x := r.position.x + 18.0
		var cy := r.get_center().y
		UiHomeV3.draw_text(self, 900, 32, nm, Vector2(x, cy - 16.0), UiLevels.INK)
		x += UiHomeV3.text_w(900, 32, nm) + 8.0
		UiHomeV3.draw_text(self, 800, 24, rng, Vector2(x, cy - 10.0), UiLevels.SOFT)


## Pločica s imenom sezone (fiksna na vrhu): ime + „7 / 20", ili mint „✓ 20 / 20".
class _Title extends Control:
	var season_id: String = ""
	var level: int = 1

	func _init() -> void:
		name = "PathTitle"
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(LevelPathKit.W, 120.0)
		position = Vector2(0.0, LevelPathView.TITLE_Y)

	func text_for() -> String:
		var done := level >= LevelPathDomain.COMPLETE
		return "%s %s" % [_name(), ("✓ 20 / 20" if done else "%d / 20" % mini(level, 20))]

	func _name() -> String:
		var def: SeasonDef = GameState.get_season_def(season_id)
		return def.display_name if def else season_id

	func _draw() -> void:
		var name_txt := _name()
		var done := level >= LevelPathDomain.COMPLETE
		var chip_txt := "20 / 20" if done else "%d / 20" % mini(level, 20)
		var chip_w := UiHomeV3.text_w(900, 40, chip_txt, 0.0, true) + (24.0 + 18.0 + 22.0 if done else 48.0)
		var w := 36.0 + UiHomeV3.text_w(900, 46, name_txt) + 22.0 + chip_w + 18.0
		var r := Rect2((size.x - w) * 0.5, 0.0, w, 100.0)
		UiHomeV3.draw_panel(self, r, UiHomeField.WARM_WHITE, 50.0, 3.0, UiHomeField.OUTLINE)
		UiHomeV3.draw_text(self, 900, 46, name_txt, Vector2(r.position.x + 36.0, r.get_center().y - 23.0), UiHomeField.OUTLINE)
		var chip := Rect2(r.end.x - 18.0 - chip_w, r.get_center().y - 32.0, chip_w, 64.0)
		UiHomeV3.draw_panel(self, chip, UiHomeField.MINT if done else UiHomeField.ACTIVE_RIM, 32.0, 3.0, UiHomeField.OUTLINE)
		var x := chip.position.x + 24.0
		if done:
			x = chip.position.x + 18.0
			UiPopups.draw_check(self, Vector2(x + 11.0, chip.get_center().y), 30.0, UiHomeField.OUTLINE, 6.0)
			x += 22.0 + 10.0
		UiHomeV3.draw_text(self, 900, 40, chip_txt, Vector2(x, chip.get_center().y - 20.0), UiHomeField.OUTLINE, 0.0, true)


## „Pip" lokator: pojavi se kad je Pipov kamen van kadra; tap vrati skrol na Pipa.
class _Locator extends Control:
	signal pressed
	var dir: int = 0
	var _down: bool = false

	func _init() -> void:
		name = "PipLocator"
		mouse_filter = Control.MOUSE_FILTER_STOP
		position = LevelPathView.LOCATOR.position
		size = LevelPathView.LOCATOR.size

	func _gui_input(event: InputEvent) -> void:
		var is_press := false
		if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			is_press = (event as InputEventMouseButton).pressed
		elif event is InputEventScreenTouch:
			is_press = (event as InputEventScreenTouch).pressed
		else:
			return
		accept_event()
		if is_press:
			_down = true
		elif _down:
			_down = false
			pressed.emit()
		queue_redraw()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		var sy := 8.0
		if _down:
			r.position.y += 4.0
			sy = 4.0
		UiHomeV3.draw_panel(self, r, UiHomeField.WARM_WHITE, 48.0, 3.0, UiHomeField.OUTLINE, sy, UiHomeField.STICKER_DROP)
		var tw := UiHomeV3.text_w(900, 40, "Pip")
		var row := 30.0 + 14.0 + tw
		var x := r.get_center().x - row * 0.5
		var cy := r.get_center().y
		var tri: PackedVector2Array
		if dir < 0:
			tri = PackedVector2Array([Vector2(x, cy + 12.0), Vector2(x + 30.0, cy + 12.0), Vector2(x + 15.0, cy - 12.0)])
		else:
			tri = PackedVector2Array([Vector2(x, cy - 12.0), Vector2(x + 30.0, cy - 12.0), Vector2(x + 15.0, cy + 12.0)])
		draw_colored_polygon(tri, UiHomeField.OUTLINE)
		UiHomeV3.draw_text(self, 900, 40, "Pip", Vector2(x + 44.0, cy - 20.0), UiHomeField.OUTLINE)


## „Meadow complete!" + „▶ Play repeats Level 20" iznad cilja.
class _Banner extends Control:
	func _init() -> void:
		name = "CompleteBanner"
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		position = Vector2(0.0, LevelPathView.BANNER_Y)
		size = Vector2(LevelPathKit.W, 200.0)

	func _draw() -> void:
		var t1 := LevelPathKit.S_COMPLETE
		var w1 := UiHomeV3.text_w(900, 60, t1) + 96.0
		var r1 := Rect2((size.x - w1) * 0.5, 0.0, w1, 104.0)
		UiHomeV3.draw_panel(self, r1, UiHomeField.MINT, 52.0, 4.0, UiHomeField.OUTLINE, 10.0, UiHomeField.STICKER_DROP)
		UiPopups.draw_text_centered(self, 900, 60, t1, r1, UiHomeField.OUTLINE)
		var t2 := LevelPathKit.S_REPLAY
		var w2 := 20.0 + 21.0 + 12.0 + UiHomeV3.text_w(900, 38, t2) + 26.0
		var r2 := Rect2((size.x - w2) * 0.5, r1.end.y + 12.0, w2, 64.0)
		UiHomeV3.draw_panel(self, r2, UiHomeField.WARM_WHITE, 32.0, 3.0, UiHomeField.OUTLINE)
		var x := r2.position.x + 20.0
		var cy := r2.get_center().y
		draw_colored_polygon(PackedVector2Array([Vector2(x, cy - 13.0), Vector2(x + 21.0, cy), Vector2(x, cy + 13.0)]), UiHomeField.OUTLINE)
		UiHomeV3.draw_text(self, 900, 38, t2, Vector2(x + 33.0, cy - 19.0), UiHomeField.OUTLINE)
