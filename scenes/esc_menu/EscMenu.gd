extends CanvasLayer

@onready var esc_panel = $EscPanel
@onready var audio_bus = {
	"Master": AudioServer.get_bus_index("Master"),
	"Music": AudioServer.get_bus_index("Music"),
	"SFX": AudioServer.get_bus_index("SFX"),
}
@onready var sfx_volume = %SfxSlider
@onready var music_volume = %MusicSlider

@onready var upgradeLeftWep = %upgradeLeftWep
@onready var upgradeRightWep = %upgradeRightWep

func _ready():
	sfx_volume.value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus["SFX"]))
	music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus["Music"]))

func change_volume(bus_name, new_volume):
	var db_volume =  linear_to_db(new_volume)
	AudioServer.set_bus_volume_db(audio_bus[bus_name], db_volume)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_menu_button_pressed():
	get_tree().paused = false
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_MENU)

func _on_resume_button_pressed():
	self.disappear()

func appear():
	upgradeLeftWep.set_text(GameState.equipped_weapons[Tank.Slot.Left])
	upgradeRightWep.set_text(GameState.equipped_weapons[Tank.Slot.Right])
	self.get_tree().paused = true
	self.esc_panel.show()

func disappear():
	self.get_tree().paused = false
	self.esc_panel.hide()

func _unhandled_input(event):
	if event.is_action_pressed("escmenu"):
		if self.esc_panel.visible:
			self.disappear()
		else:
			self.appear()

func _on_esc_button_pressed():
	self.appear()


func _on_music_slider_value_changed(value: float) -> void:
	print("Music slider value changed to: ", value)
	change_volume("Music", value)


func _on_sfx_slider_value_changed(value: float) -> void:
	print("Music slider value changed to: ", value)
	change_volume("SFX", value)
