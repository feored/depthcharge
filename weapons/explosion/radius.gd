extends Sprite2D

const TIME_ANIMATION = 0.25
var radius: int = 0


func set_radius(size: int):
	self.radius = size


func animate(size):
	var tween = create_tween()
	var size_exp = ((2 * radius) + 2) * Constants.TILE_SIZE
	self.texture.height = size_exp
	self.texture.width = size_exp
	print("size_exp: ", size_exp)
	tween.tween_property(self, "modulate:a", 0, TIME_ANIMATION)
	tween.tween_callback(self.queue_free)


func _ready():
	self.texture.height = 1
	self.texture.width = 1
	animate(radius)
