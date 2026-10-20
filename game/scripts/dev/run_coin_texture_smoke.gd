extends SceneTree

## design_handoff_run_pickups: novčić na stazi = regija „coin" atlasa pickupa (96 × 96, isti crtež
## kao icon_coin), sjena ISPOD novčića (prvo dijete), bez _draw. Kolizija ostaje r 18.

const COIN_SCENE := "res://scenes/run/coin.tscn"

var _failed: bool = false
var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _run() -> void:
	if PickupArt.tex("coin") == null:
		_fail("pickup atlas not importable")
		_quit(1)
		return
	var packed := load(COIN_SCENE) as PackedScene
	if packed == null:
		_fail("coin.tscn missing")
		_quit(1)
		return
	var coin := packed.instantiate()
	get_root().add_child(coin)
	for _i in 4:
		await process_frame
	var visual := coin.get_node_or_null("CoinVisual") as Node2D
	if visual == null:
		_fail("CoinVisual missing")
	else:
		var sprites: Array[Sprite2D] = []
		for c in visual.get_children():
			if c is Sprite2D:
				sprites.append(c as Sprite2D)
		if sprites.size() != 3:
			_fail("CoinVisual should be 3 sprites (shadow, coin, glint), got %d" % sprites.size())
		elif sprites[0].texture != PickupArt.tex("shadow"):
			_fail("first sprite must be the shadow (drawn under the coin)")
		elif sprites[1].texture != PickupArt.tex("coin") and sprites[1].texture != PickupArt.tex("coin_edge"):
			_fail("coin sprite should use the atlas coin region, got %s" % str(sprites[1].texture))
		elif sprites[1].texture.get_size() != Vector2(96, 96):
			_fail("coin draws at 96 px, got %s" % str(sprites[1].texture.get_size()))
		if visual.has_method("_draw"):
			_fail("CoinVisual must not draw per frame")
	var shape := coin.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var circle := shape.shape as CircleShape2D if shape else null
	if circle == null or not is_equal_approx(circle.radius, 18.0):
		_fail("coin collision must stay r 18")
	coin.queue_free()
	if _failed:
		_quit(1)
		return
	print("run_coin_texture_smoke OK")
	_quit(0)


func _fail(msg: String) -> void:
	_failed = true
	push_error("run_coin_texture_smoke: " + msg)
