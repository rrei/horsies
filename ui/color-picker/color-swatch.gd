tool
class_name ColorSwatch
extends Control

export var radius := 20 setget set_radius


func _ready():
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "release_focus")

func set_radius(r):
	radius = r
	self.rect_min_size = Vector2(r, r) * 2
	self.update()


func _on_mouse_entered():
	print("mouse entered")
	self.grab_focus()
	self.update()

func _draw():
	self.draw_circle(Vector2.ZERO, self.radius, Color.white)
	if self.has_focus():
		self.draw_circle(Vector2.ZERO, self.radius * 0.75, self.modulate.inverted())
