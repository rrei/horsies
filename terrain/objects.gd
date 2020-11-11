tool
extends YSort


func add_child(node, legible_unique_name=false):
    .add_child(node, legible_unique_name)
    var sprite := node as Sprite
    if not sprite:
        return
    var size := sprite.texture.get_size()
    sprite.offset = Vector2(-size.x / 2, -size.y)
