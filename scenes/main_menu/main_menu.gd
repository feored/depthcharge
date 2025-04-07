extends Node2D


enum State{
	Main,
	Scenario,
	Settings
}


func _ready():
	Music.play_loop(Music.Track.MainMenu)
	pass
	#self.show_state(State.Main)
	#Sfx.disable_track(Sfx.Track.Sink)
	# Sfx.play_ambience(Sfx.Ambience.CalmWind)
	# Music.play_loop(Music.Track.Menu)


func _on_play_btn_pressed():
	await SceneTransition.change_scene(SceneTransition.SCENE_LEVEL)

func _on_manual_btn_pressed():
	await SceneTransition.change_scene(SceneTransition.SCENE_INSTRUCTIONS)