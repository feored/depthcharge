extends CanvasLayer

@onready var esc_panel = $EscPanel



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_menu_button_pressed():
	get_tree().paused = false
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_MENU)

func _on_resume_button_pressed():
	self.disappear()

func appear():
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
