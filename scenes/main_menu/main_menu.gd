extends Node2D

@onready var audio_bus = {
	"Master": AudioServer.get_bus_index("Master"),
	"Music": AudioServer.get_bus_index("Music"),
	"SFX": AudioServer.get_bus_index("SFX"),
}
@onready var sfx_volume = %SfxSlider
@onready var music_volume = %MusicSlider

enum State{
	Main,
	Scenario,
	Settings
}

func change_volume(bus_name, new_volume):
	var db_volume =  linear_to_db(new_volume)
	AudioServer.set_bus_volume_db(audio_bus[bus_name], db_volume)


func _ready():
	sfx_volume.value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus["SFX"]))
	music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus["Music"]))
	Music.play_loop(Music.Track.MainMenu)
	#self.show_state(State.Main)
	#Sfx.disable_track(Sfx.Track.Sink)
	# Sfx.play_ambience(Sfx.Ambience.CalmWind)
	# Music.play_loop(Music.Track.Menu)


func _on_play_btn_pressed():
	GameState.reinitialize()
	await SceneTransition.change_scene(SceneTransition.SCENE_LEVEL)

func _on_manual_btn_pressed():
	await SceneTransition.change_scene(SceneTransition.SCENE_INSTRUCTIONS)

	

func _on_music_slider_value_changed(value: float) -> void:
	print("Music slider value changed to: ", value)
	change_volume("Music", value)


func _on_sfx_slider_value_changed(value: float) -> void:
	print("Music slider value changed to: ", value)
	change_volume("SFX", value)
