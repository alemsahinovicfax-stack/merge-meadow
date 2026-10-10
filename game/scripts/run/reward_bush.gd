class_name RewardBush
extends Area2D

## Run HUD v2 · nagradni grm (design_handoff_run_hud_v2): stoji na šavu između dvije staze
## (120 široko → viri 25 px u svaku), pokupi se kad Pip PREĐE šav dok je grm u njegovoj visini.
## Nije prepreka (nikad ne obara run) i nije „pickup" — magnet ga ne vuče.
## Tri dijela (back, reward, front) + Area2D; mirovanje = jedan Tween loop na `visual`.
## Origin čvora = centar crteža 120 × 140; `visual` stoji na pivotu (60, 124).

signal collected(bush: RewardBush)

const GROUP := "reward_bush"

## 0 = šav 405 (staze 0 i 1), 1 = šav 675 (staze 1 i 2).
var seam: int = 0
var reward_kind: String = "coin"
var reward_amount: int = 3
var season_id: String = ""

var visual: Node2D
var _idle: Tween
var _collected: bool = false


func setup(p_seam: int, p_season: String, reward: Dictionary) -> RewardBush:
	seam = p_seam
	season_id = p_season
	reward_kind = str(reward.get("kind", "coin"))
	reward_amount = int(reward.get("amount", 3))
	return self


func _ready() -> void:
	add_to_group(GROUP)
	collision_layer = 2
	collision_mask = 0
	monitoring = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = UiRun.BUSH_HIT
	shape.shape = rect
	add_child(shape)
	_build_visual()
	if not GameState.reduce_motion:
		_idle = UiRun.bush_idle_tween(visual)


func _build_visual() -> void:
	var pivot := UiRun.BUSH_PIVOT
	visual = Node2D.new()
	visual.name = "Visual"
	visual.position = pivot - UiRun.BUSH_SIZE * 0.5
	add_child(visual)
	visual.add_child(_part("Back", "back"))
	var reward_node := _reward_art()
	visual.add_child(reward_node)
	visual.add_child(_part("Front", "front"))


func _part(node_name: String, part: String) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = node_name
	s.centered = false
	s.position = -UiRun.BUSH_PIVOT
	s.texture = bush_texture(season_id, part)
	return s


func _reward_art() -> Node2D:
	var box := UiRun.BUSH_REWARD_COIN if reward_kind == "coin" else UiRun.BUSH_REWARD_SEED
	var center := box.get_center() - UiRun.BUSH_PIVOT
	if reward_kind == "coin":
		var coin := Sprite2D.new()
		coin.name = "Reward"
		coin.texture = UiAssets.get_chrome_icon("icon_coin")
		coin.position = center
		if coin.texture != null:
			coin.scale = Vector2.ONE * (box.size.x / float(coin.texture.get_width()))
		return coin
	var disc := SeedDisc.new()
	disc.name = "Reward"
	disc.diameter = box.size.x
	disc.position = center
	return disc


## Pip je prešao šav preko grma (player.gd → area_entered).
func collect() -> void:
	if _collected:
		return
	_collected = true
	set_deferred("monitorable", false)
	if _idle != null and _idle.is_valid():
		_idle.kill()
	visible = false
	collected.emit(self)
	queue_free()


func is_collected() -> bool:
	return _collected


static func bush_texture(p_season: String, part: String) -> Texture2D:
	var path := UiRun.bush_texture_path(p_season, part)
	if not ResourceLoader.exists(path):
		path = UiRun.bush_texture_path("country_bloom", part)
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


## Krem disk s ikonom sjemena (nagrada u grmu i sjemenka u letu do SeedChipa). Crta se jednom.
class SeedDisc:
	extends Node2D

	var diameter: float = 58.0

	func _ready() -> void:
		var icon := Sprite2D.new()
		icon.texture = UiAssets.get_chrome_icon("icon_seed")
		if icon.texture != null:
			icon.scale = Vector2.ONE * (diameter * 0.69 / float(icon.texture.get_width()))
		add_child(icon)
		queue_redraw()

	func _draw() -> void:
		var r := diameter * 0.5
		draw_circle(Vector2.ZERO, r, UiRun.CHIP_EDGE)
		draw_circle(Vector2.ZERO, r - 3.0, UiRun.CHIP_BG)
