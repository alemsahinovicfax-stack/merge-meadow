extends SceneTree
func _init():
    var tex: Texture2D = load("res://assets/sprites/pip_idle.svg") as Texture2D
    if tex == null:
        push_error("pip export: svg load failed")
        quit(1)
        return
    var img: Image = tex.get_image()
    var err := img.save_png("res://assets/sprites/pip_idle.png")
    print("save_png err=", err, " size=", img.get_size())
    quit()
