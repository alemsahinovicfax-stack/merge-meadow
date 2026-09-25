extends SceneTree

## design_handoff_hub_chrome_v2: novcic koji skupljas u runu je ISTA ikona koja stoji
## u headeru, Campu i Shopu — vise nije proceduralni krug. Kolizija ostaje r 18.

const COIN_SCENE := "res://scenes/run/coin.tscn"
const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")
const UI_RUN := preload("res://scripts/visual/ui_run.gd")

var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var icon := UI_ASSETS.get_chrome_icon("icon_coin")
	if icon == null:
		_fail("icon_coin.svg not importable")
		quit(1)
		return
	var packed := load(COIN_SCENE) as PackedScene
	if packed == null:
		_fail("coin.tscn missing")
		quit(1)
		return
	var coin := packed.instantiate()
	get_root().add_child(coin)
	for _i in 4:
		await process_frame
	var visual := coin.get_node_or_null("CoinVisual") as Sprite2D
	if visual == null:
		_fail("CoinVisual missing")
	else:
		var tex := visual.get("_tex") as Texture2D
		if tex != icon:
			_fail("CoinVisual should draw icon_coin.svg, got %s" % str(tex))
		if visual.texture != null:
			_fail("CoinVisual keeps texture null — sjena se crta ispod novcica")
	var shape := coin.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var circle := shape.shape as CircleShape2D if shape else null
	if circle == null or not is_equal_approx(circle.radius, 18.0):
		_fail("coin collision must stay r 18")
	if UI_RUN.COIN_SIZE != 96:
		_fail("coin draws at 96 px, got %d" % UI_RUN.COIN_SIZE)
	coin.queue_free()
	if _failed:
		quit(1)
		return
	print("run_coin_texture_smoke OK")
	quit(0)


func _fail(msg: String) -> void:
	_failed = true
	push_error("run_coin_texture_smoke: " + msg)
