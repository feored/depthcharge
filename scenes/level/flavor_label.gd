extends Label
var tween
var time_elapsed = 0.0
const TIME_TO_HIDE = 2.0
@onready var parent = get_parent().get_parent()


func _physics_process(delta: float) -> void:
	if self.visible:
		time_elapsed += delta
		if self.text == "" and time_elapsed > TIME_TO_HIDE:
			hide_box()


func hide_box() -> void:
	parent.visible = false
	self.text = ""


func show_box() -> void:
	parent.visible = true
	self.text = ""


func flavor_text(text: String) -> void:
	cleanup()
	show_box()
	self.text = text
	tween = create_tween()
	tween.tween_property(self, "visible_characters", self.text.length(), self.text.length() * 0.025)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 2)
	tween.tween_callback(cleanup)


func cleanup() -> void:
	if tween != null:
		self.tween.kill()
		self.tween = null
	self.visible_characters = 0
	self.text = ""
	self.time_elapsed = 0.0
