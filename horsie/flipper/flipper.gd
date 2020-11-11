extends Area2D


func _ready():
    self.connect("area_entered", self, "_on_area_entered")


func _on_area_entered(area):
    var sprite: Sprite = area.get_node("../sprite")
    sprite.flip_v = not sprite.flip_v
