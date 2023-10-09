extends Node2D

signal lap_completed()

const MIN_SPEED := 40.0
const MAX_SPEED := 60.0

export var tint := Color.white

var speed := 50.0  # pixels/second
var acceleration := 5.0  # pixels/second^2
var rank := 1

onready var follow: PathFollow2D = $follow


func _ready():
	$sprite.modulate = self.tint
	self.follow.get_node("remote_transform").remote_path = self.get_path()


func _process(delta: float):
	var previous_unit_offset := self.follow.unit_offset
	var ketchup := 0.1 * (1.0 - 1.0 / self.rank)
	var dspeed := (globals.rng.randf_range(-1, +1) + ketchup) * self.acceleration * delta
	self.speed = clamp(self.speed + dspeed, MIN_SPEED, MAX_SPEED)
	self.follow.offset += self.speed * delta
	if self.follow.unit_offset < previous_unit_offset:
		self.emit_signal("lap_completed")


func setup(track: Path2D, lane: int):
	print("Setting up horsie {0} on lane {1}".format([self.get_path(), lane]))
	self.remove_child(self.follow)
	track.add_child(self.follow)
	self.follow.v_offset = lane * 2
