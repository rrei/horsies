extends Node

export(int, 0, 10) var n_laps := 5
var laps := {}
var progress := {}
var ranks := {}


func _ready():
	self.process_priority = +1  # to process this node after horsies

	var tree := self.get_tree()
	tree.paused = true

	var track: Path2D = $track
	var horsies := $horsies.get_children()
	for i in range(horsies.size()):
		var horsie = horsies[i]
		horsie.set_process(false)
		horsie.setup(track, i)
		horsie.connect("lap_completed", self, "_on_lap_completed", [horsie])
		self.laps[horsie] = 0
		self.progress[horsie] = 0.0
		self.ranks[horsie] = 1

	$gui/anim.play("countdown")
	$utils/music.play()

	# Display status line every second.
	while true:
		var status := PoolStringArray()
		for horsie in horsies:
			var progress_pct = "%.02f" % (self.progress[horsie] * 100)
			status.append("{0} #{1} {2}%".format([horsie.name, self.ranks[horsie], progress_pct]))
		print(status.join(" | "))
		yield(tree.create_timer(1), "timeout")


func _process(delta):
	# Update horsie progress.
	var horsies := $horsies.get_children()
	for horsie in horsies:
		self.progress[horsie] = (self.laps[horsie] + horsie.follow.unit_offset) / self.n_laps

	# Compute horsie ranks.
	horsies.sort_custom(self, "_horsies_order")
	var rank := 0
	var progress := -1.0
	self.ranks.clear()
	for i in range(horsies.size()):
		var horsie = horsies[i]
		var horsie_progress = self.progress[horsie]
		if horsie_progress != progress:
			progress = horsie_progress
			rank = i + 1
		horsie.rank = rank
		self.ranks[horsie] = rank

	# Update ranks and laps UI.
	var ranks := PoolStringArray()
	var current_lap := 0
	for horsie in horsies:
		ranks.append("[color=#{color}]{rank}. {name}[/color]".format({
			color=horsie.tint.to_html(),
			rank=self.ranks[horsie],
			name=horsie.name
		}))
		current_lap = max(current_lap, self.laps[horsie] + 1)

	if current_lap > 0:
		$gui/ranks.bbcode_text = ranks.join("\n")
		if current_lap <= self.n_laps:
			$gui/laps.text = "Lap {0} of {1}".format([current_lap, self.n_laps])
		else:
			$gui/laps.text = ""


func _horsies_order(h1, h2):
	return self.progress[h1] >= self.progress[h2]


func _on_countdown_finished():
	"""Called during the "countdown" animation when the clock reaches zero. This is done in the
	middle of the animation because it continues after zero to fade out the label."""
	for horsie in $horsies.get_children():
		horsie.set_process(true)


func _on_lap_completed(horsie):
	self.laps[horsie] += 1
	if self.laps[horsie] >= self.n_laps:
		self.call_deferred("finish_race")


func finish_race():
	var camera := $camera as Camera2D
	if not camera:
		return

	var rank1_horsies := []
	for horsie in self.ranks:
		var rank = self.ranks[horsie]
		if rank == 1:
			rank1_horsies.append(horsie)
	assert(rank1_horsies.size() > 0)
	var winner = rank1_horsies[globals.rng.randi() % rank1_horsies.size()]

	var camera_pos := camera.global_position
	self.remove_child(camera)
	winner.add_child(camera)
	camera.global_position = camera_pos

	Engine.time_scale = 0.05

	var tween: Tween = $utils/tween
	tween.interpolate_property(
		camera, "zoom", camera.zoom, Vector2(0.25, 0.25),
		0.25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		camera, "position", camera.position, Vector2.ZERO,
		0.25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)

	var music: AudioStreamPlayer = $utils/music
	tween.interpolate_property(
		music, "pitch_scale", music.pitch_scale, music.pitch_scale-0.5,
		2.5, Tween.TRANS_LINEAR
	)
	tween.interpolate_property(
		music, "volume_db", music.volume_db, music.volume_db-20,
		2.5, Tween.TRANS_LINEAR
	)

	var winner_label: RichTextLabel = $gui/winner
	var text := (
		"[center][shake rate=50 level=30][rainbow]Congratulations[/rainbow]\n"
		+ "[color=#{color}]{name}[/color][/shake][/center]"
	).format({color=winner.tint.to_html(), name=winner.name})
	winner_label.bbcode_text = text
	winner_label.visible_characters = 0
	tween.interpolate_property(
		winner_label, "visible_characters", 0, text.length(),
		0.01 * text.length(), Tween.TRANS_LINEAR
	)
	tween.start()
