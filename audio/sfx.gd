extends Node2D

const LOWEST_VOLUME = -80
const DEFAULT_VOLUME = 0

enum Track {
	Explosion,
	FireDriller,
	Misfire,
	Radar,
	DetonateTone,
	HomingTone,
	SecondTone
}
enum Ambience { CalmWind }

const TRACKS = {
	Track.Explosion: preload("res://audio/sfx/explosion.wav"),
	Track.FireDriller: preload("res://audio/sfx/fire_driller.wav"),
	Track.Misfire: preload("res://audio/sfx/misfire.wav"),
	Track.Radar: preload("res://audio/sfx/radar.wav"),
	Track.DetonateTone: preload("res://audio/sfx/detonate_tone.wav"),
	Track.HomingTone: preload("res://audio/sfx/homing_tone.wav"),
	Track.SecondTone: preload("res://audio/sfx/second_tone.wav")
}

const AMBIENCE_TRACKS = {}#Ambience.CalmWind: preload("res://audio/ambience/wind_calm.wav")}

const RANDOM_PITCH_SCALE = {}

const CUSTOM_VOLUME = {
	Track.Misfire: -10
	}

const CUSTOM_AMBIENCE_VOLUME = {Ambience.CalmWind: 0}

const CUSTOM_POLYPHONY = {}

var players = {}
var ambience_players = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	connect_buttons(get_tree().root)
	get_tree().connect("node_added", Callable(self, "_on_SceneTree_node_added"))
	for key in TRACKS:
		var player = AudioStreamPlayer.new()
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		player.stream = TRACKS[key]
		player.max_polyphony = 10  if key not in CUSTOM_POLYPHONY else CUSTOM_POLYPHONY[key]
		player.bus = "SFX"
		if key in CUSTOM_VOLUME:
			player.volume_db = CUSTOM_VOLUME[key]
		self.add_child(player)
		self.players[key] = player
	for key in AMBIENCE_TRACKS:
		var player = AudioStreamPlayer.new()
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		player.stream = AMBIENCE_TRACKS[key]
		player.bus = "Ambience"
		if key in CUSTOM_AMBIENCE_VOLUME:
			player.volume_db = CUSTOM_AMBIENCE_VOLUME[key]
		self.add_child(player)
		self.ambience_players[key] = player


func stop_all():
	for key in self.players:
		self.players[key].stop()
	for key in self.ambience_players:
		self.ambience_players[key].stop()

func play_ambience(ambience: Ambience):
	self.ambience_players[ambience].play()


func play(track: Track):
	if track in RANDOM_PITCH_SCALE:
		self.players[track].pitch_scale = randf_range(RANDOM_PITCH_SCALE[track][0], RANDOM_PITCH_SCALE[track][1])
	self.players[track].play()


func disable_track(track: Track):
	self.players[track].volume_db = LOWEST_VOLUME


func enable_track(track: Track):
	self.players[track].volume_db = DEFAULT_VOLUME if track not in CUSTOM_VOLUME else CUSTOM_VOLUME[track]


func _on_SceneTree_node_added(node):
	if node is Button:
		connect_to_button(node)


func _on_button_pressed():
	#self.play(Track.Click)
	pass


func on_button_hovered():
	pass
	#self.play(Track.Hover)


# recursively connect all buttons
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)


func connect_to_button(button):
	if not button.is_connected("pressed", Callable(self, "_on_button_pressed")):
		button.connect("pressed", Callable(self, "_on_button_pressed"))
	if not button.is_connected("mouse_entered", Callable(self, "on_button_hovered")):
		button.connect("mouse_entered", Callable(self, "on_button_hovered"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
