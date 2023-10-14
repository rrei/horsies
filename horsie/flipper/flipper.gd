extends Area2D


func _ready():
	self.connect("area_entered", self, "_on_area_entered")


func _on_area_entered(area):
	var sprite: Sprite = area.get_node("../sprite")
	sprite.flip_v = not sprite.flip_v
	adjust_face(sprite)
	
func adjust_face(parent_node):
	var face = parent_node.get_node("face")
	face.rotation_degrees = 180 - 12.5 if parent_node.flip_v else 12.5
