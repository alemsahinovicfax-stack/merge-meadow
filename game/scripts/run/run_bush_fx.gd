class_name RunBushFx
extends Node2D

## Run HUD v2 · grm pokupljen (design_handoff_run_hud_v2 § 5): prsten 160 + 6 listova pukne
## (0,25 s), nagrada iskoči iznad grma pa luči do CoinChip / SeedChip (0,15 s + 0,35 s,
## luk 140, scale 1 → 0,7, razmak 0,04), čip se kratko poveća (1 → 1,08 → 1, 0,18 s).
## Najviše 11 spriteova (1 + 6 + ≤ 4), ukupno ~0,6 s. Bez CPUParticles2D.
## Pool: svi dijelovi se naprave jednom na startu runa (bench: pravljenje 11 čvorova u frejmu
## pickupa dalo je skok ~3 ms), pa play() samo resetuje i pušta tweenove.

const SEED_FLYERS := 2

var ring: Panel
var leaves: Array[Sprite2D] = []
var coins: Array[Sprite2D] = []
var seeds: Array[Node2D] = []
var _tweens: Array[Tween] = []
var _season := ""
var _coin_scale := 1.0


func _init() -> void:
	name = "BushBurst"
	ring = Panel.new()
	ring.name = "Ring"
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var d := UiRun.BUSH_BURST_RING
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.border_color = UiRun.CHIP_BG
	s.set_border_width_all(UiRun.BUSH_BURST_RING_W)
	s.set_corner_radius_all(int(d * 0.5))
	s.corner_detail = 16
	ring.add_theme_stylebox_override("panel", s)
	ring.size = Vector2(d, d)
	ring.pivot_offset = ring.size * 0.5
	add_child(ring)
	for i in UiRun.BUSH_LEAF_ANGLES.size():
		var leaf := Sprite2D.new()
		leaf.name = "Leaf%d" % i
		leaf.rotation_degrees = float(UiRun.BUSH_LEAF_ANGLES[i]) + 90.0
		add_child(leaf)
		leaves.append(leaf)
	var coin_tex := UiAssets.get_chrome_icon("icon_coin")
	if coin_tex != null:
		_coin_scale = UiRun.BUSH_FLY_SIZE / float(coin_tex.get_width())
	for i in UiRun.BUSH_MAX_FLY_SPRITES:
		var coin := Sprite2D.new()
		coin.name = "Coin%d" % i
		coin.texture = coin_tex
		add_child(coin)
		coins.append(coin)
	for i in SEED_FLYERS:
		var disc := RewardBush.SeedDisc.new()
		disc.name = "Seed%d" % i
		disc.diameter = UiRun.BUSH_FLY_SIZE
		add_child(disc)
		seeds.append(disc)
	_hide_all()


static func fly_count(kind: String, amount: int) -> int:
	return clampi(amount, 1, UiRun.BUSH_MAX_FLY_SPRITES) if kind == "coin" else clampi(amount, 1, SEED_FLYERS)


func _hide_all() -> void:
	ring.visible = false
	for n in leaves:
		n.visible = false
	for n in coins:
		n.visible = false
	for n in seeds:
		n.visible = false


func _kill() -> void:
	for t in _tweens:
		if t != null and t.is_valid():
			t.kill()
	_tweens.clear()


## Broj vidljivih dijelova (test budžeta ≤ 12).
func active_parts() -> int:
	var n := 1 if ring.visible else 0
	for arr in [leaves, coins, seeds]:
		for c in arr:
			if (c as CanvasItem).visible:
				n += 1
	return n


## Na startu runa: učita teksture grma te sezone (listovi + back/front) da prvi grm ne čeka disk.
func prepare(season_id: String) -> void:
	if season_id == _season:
		return
	_season = season_id
	var tex := RewardBush.bush_texture(season_id, "leaf")
	for leaf in leaves:
		leaf.texture = tex
	set_meta("warm", [RewardBush.bush_texture(season_id, "back"), RewardBush.bush_texture(season_id, "front")])


## `at` = centar grma u trenutku prelaza (HUD prostor). `target` = čip koji dobija nagradu.
func play(at: Vector2, season_id: String, kind: String, amount: int, target: Control) -> void:
	_kill()
	_hide_all()
	prepare(season_id)
	_play_ring(at)
	_play_leaves(at)
	_play_flyers(at, kind, amount, target)


func _play_ring(at: Vector2) -> void:
	ring.position = at - ring.size * 0.5
	ring.scale = Vector2.ONE * 0.4
	ring.modulate.a = 1.0
	ring.visible = true
	var tw := create_tween().set_parallel(true)
	tw.tween_property(ring, "scale", Vector2.ONE, UiRun.BUSH_BURST_TIME).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, UiRun.BUSH_BURST_TIME)
	tw.chain().tween_callback(ring.hide)
	_tweens.append(tw)


func _play_leaves(at: Vector2) -> void:
	for i in leaves.size():
		var leaf := leaves[i]
		var a := float(UiRun.BUSH_LEAF_ANGLES[i])
		var dist := float(UiRun.BUSH_LEAF_DIST[i % 2])
		leaf.position = at
		leaf.modulate.a = 1.0
		leaf.visible = true
		var dest := at + Vector2.from_angle(deg_to_rad(a)) * dist
		var tw := create_tween().set_parallel(true)
		tw.tween_property(leaf, "position", dest, UiRun.BUSH_BURST_TIME) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(leaf, "modulate:a", 0.0, UiRun.BUSH_BURST_TIME).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(leaf.hide)
		_tweens.append(tw)


func _play_flyers(at: Vector2, kind: String, amount: int, target: Control) -> void:
	var count := fly_count(kind, amount)
	var pool: Array = coins if kind == "coin" else seeds
	var base := _coin_scale if kind == "coin" else 1.0
	var dst := target.get_global_rect().get_center() if target != null else at + Vector2(0, -600)
	for i in count:
		var node := pool[i] as Node2D
		node.position = at
		node.scale = Vector2.ONE * base
		node.visible = true
		var ox := (float(i) - float(count - 1) * 0.5) * 58.0
		var src := at + Vector2(ox, -UiRun.BUSH_FLY_RISE - float(i % 2) * 34.0)
		var tw := create_tween()
		tw.tween_property(node, "position", src, UiRun.BUSH_FLY_DELAY) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_interval(UiRun.BUSH_FLY_STAGGER * float(i))
		tw.tween_method(_arc.bind(node, src, dst, base), 0.0, 1.0, UiRun.BUSH_FLY_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		if i == count - 1 and target != null:
			tw.tween_callback(bump_chip.bind(target))
		tw.tween_callback(node.hide)
		_tweens.append(tw)


func _arc(t: float, node: Node2D, src: Vector2, dst: Vector2, base: float) -> void:
	var p := src.lerp(dst, t)
	p.y -= sin(t * PI) * UiRun.BUSH_FLY_ARC
	node.position = p
	node.scale = Vector2.ONE * lerpf(1.0, 0.7, t) * base


## Čip dobije nagradu: 1 → 1,08 → 1 za 0,18 s.
static func bump_chip(c: Control) -> void:
	if not is_instance_valid(c):
		return
	c.pivot_offset = c.size * 0.5
	var half := UiRun.CHIP_BUMP_TIME * 0.5
	var t := c.create_tween()
	t.tween_property(c, "scale", Vector2.ONE * UiRun.CHIP_BUMP, half).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", Vector2.ONE, half).set_ease(Tween.EASE_IN)
