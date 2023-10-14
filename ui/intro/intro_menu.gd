extends Node2D



func _on_yes_button_pressed():
	globals.turbo_mode=true
	get_tree().change_scene("res://terrain/terrain.tscn")
	queue_free()

func _on_no_button_pressed():
	globals.turbo_mode=false
	get_tree().change_scene("res://terrain/terrain.tscn")
