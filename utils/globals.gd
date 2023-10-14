extends Node

var rng := RandomNumberGenerator.new()

var turbo_mode

func _ready():
	self.rng.randomize()
	self.pause_mode = PAUSE_MODE_PROCESS


func _unhandled_input(event: InputEvent):
#    print(event.as_text())
	if event.is_action_pressed("ui_accept"):
		var tree := self.get_tree()
		tree.paused = not tree.paused
	if event.is_action_pressed("ui_focus_next"):
		Engine.time_scale = 0.25 if Engine.time_scale == 1.0 else 1.0
	if event.is_action_pressed("ui_cancel"):
		Engine.time_scale = 1.0
		self.get_tree().reload_current_scene()
