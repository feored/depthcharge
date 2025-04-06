extends Label
var tween


func flavor_text(text: String) -> void:
	cleanup()
	self.text = text
	tween = create_tween()
	tween.tween_property(self, "visible_characters", self.text.length(), self.text.length() * 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 2)
	tween.tween_callback(cleanup)


func cleanup() -> void:
	if tween != null:
		self.tween.kill()
		self.tween = null
	self.modulate = Color(1, 1, 1, 1)
	self.visible_characters = 0
	self.text = ""
