extends AudioStreamPlayer

const MIN_VOLUME = -80.0
const MIN_CROSSFADE_VOLUME = -50.0
const CROSSFADE_TIME = 1.0
const FAST_CROSSFADE_TIME = 0.1
const DEFAULT_VOLUME = 0.0

## Tracks
enum Track {
	Conqueror,
	GameOver,
	Gameplay,
	MainMenu
}
const BGM_TRACKS = {
	Track.Conqueror: preload("res://audio/music/Conqueror.mp3"),
	Track.GameOver: preload("res://audio/music/GameOver.mp3"),
	Track.Gameplay: preload("res://audio/music/Gameplay.mp3"),
	Track.MainMenu: preload("res://audio/music/MainMenu.mp3")
}


@onready var timer : Timer = Timer.new()

var player: AudioStreamPlayer = null


func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.bus = "Music"
	

func play_track(track: Track, loop = false, fast = false):
	## crossfade
	if self.stream != null:
		var tween = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "volume_db", MIN_CROSSFADE_VOLUME, FAST_CROSSFADE_TIME if fast else CROSSFADE_TIME)
		if loop:
			tween.tween_callback(play_loop.bind(track))
		else:
			tween.tween_callback(_play.bind(track))
		tween.tween_property(self, "volume_db", DEFAULT_VOLUME, FAST_CROSSFADE_TIME if fast else CROSSFADE_TIME)
	else:
		_play(track)


func play_loop(track : Track):
	var length = BGM_TRACKS[track].get_length() - CROSSFADE_TIME
	if self.timer != null:
		self.timer.stop()
		self.timer.queue_free()
	self.timer = Timer.new()
	self.add_child(timer)
	timer.timeout.connect(play_loop.bind(track))
	timer.start(length)
	_play(track)
	


func _play(track: Track):
	print("Now playing track: " + str(track))
	self.stream = BGM_TRACKS[track]
	self.play()
