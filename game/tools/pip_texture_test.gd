extends SceneTree
func _init():
    var c = load("res://assets/pickups/coin.png") as Texture2D
    var s = load("res://assets/pickups/seed.png") as Texture2D
    print("coin=", c != null, " seed=", s != null)
    quit()
