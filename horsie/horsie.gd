extends Node2D

signal lap_completed()

const MIN_SPEED := 40.0
const MAX_SPEED := 60.0
const TURBO_MULTIPLIER = 1.618

export var tint := Color.white
export var turbo_probability := 0.003

var speed := 50.0  # pixels/second
var acceleration := 5.0  # pixels/second^2
var rank := 1

var horsie_ketchup_multiplier := 1.0
var horsie_speed_variation := 1.0
var is_last := false
var in_turbo := false
var turbo_sounds = []
onready var turbo_timer = get_node("/root/world/turbo_timer")
onready var follow: PathFollow2D = $follow
onready var anim = $anim

func _ready():
	
	if globals.turbo_mode:
		add_face()
		pump_the_horsie()

	$sprite.self_modulate = self.tint
	self.follow.get_node("remote_transform").remote_path = self.get_path()

# TODO add turbo speed

func _process(delta: float):
	var previous_unit_offset := self.follow.unit_offset
	var ketchup := 0.1 * (1.0 - 1.0 / self.rank)
	var dspeed := (globals.rng.randf_range(-horsie_speed_variation, horsie_speed_variation) + ketchup*horsie_ketchup_multiplier) * self.acceleration * delta
	self.speed = clamp(self.speed + dspeed, MIN_SPEED, MAX_SPEED)
	if can_go_turbo():
		speed*=TURBO_MULTIPLIER
	if not in_turbo:
		$turbo_flames.hide()
	self.follow.offset += self.speed * delta
	if self.follow.unit_offset < previous_unit_offset:
		self.emit_signal("lap_completed")
	anim.playback_speed = self.speed/MAX_SPEED

func setup(track: Path2D, lane: int):
	print("Setting up horsie {0} on lane {1}".format([self.get_path(), lane]))
	self.remove_child(self.follow)
	track.add_child(self.follow)
	self.follow.v_offset = lane * 2

func add_face():
	var face_texture = load("res://horsie/faces/" + str(self.name) + ".png")
	$sprite/face.texture = face_texture
	if self.name == "Fátima": # her face is quite long...
		$sprite/face.offset = Vector2(4, -48)

func pump_the_horsie():
	horsie_ketchup_multiplier = 5.0
	horsie_speed_variation = 20.0
	
func can_go_turbo():
	if globals.turbo_mode and Engine.get_frames_drawn() > 2000: # wait till the end of the song's intro to start turboing...
		if is_last and turbo_timer.is_stopped() and globals.rng.randf() < turbo_probability:
			in_turbo = true
			$turbo_sounds.get_children()[globals.rng.randi_range(0,4)].play()
			$turbo_flames.show()
			turbo_timer.start()
			return true
		elif not turbo_timer.is_stopped() and in_turbo:
			return true
	

