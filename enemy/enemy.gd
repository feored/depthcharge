extends Area2D
class_name Enemy

enum State {
	Climb,
	Emerge,
	Scatter
}
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var collision: CollisionShape2D = $CollisionShape2D

var tween: Tween
var glowing: bool = false
var state: State = State.Climb
var speed = Constants.ENEMY_SPEED
var hits_left = 0


func glow(duration: float = 5.0) -> void:
	# Create a tween to animate the sprite's modulate property
	if glowing:
		unglow()
	self.glowing = true
	flash()
	timer.wait_time = duration
	timer.one_shot = true
	timer.start()

func flash() -> void:
	# Create a tween to animate the sprite's modulate property
	print("flash")
	self.z_index = 1
	tween = create_tween()
	tween.tween_property(sprite, "modulate:v", 5, 0.5)
	tween.tween_property(sprite, "modulate:v", 1, 0.5)
	tween.set_loops(150)

func closest_edge_direction():
	if self.position.x < Constants.SCREEN_SIZE.x / 2:
		return Vector2.LEFT
	else:
		return Vector2.RIGHT

func disable_collision() -> void:
	self.collision.disabled = true

func is_emerged() -> bool:
	return self.position.y + self.collision.shape.size.y / 2 - 12  < Constants.GROUND_LAYER

func is_above_ground() -> bool:
	return self.position.y - self.collision.shape.size.y / 2  < Constants.GROUND_LAYER

func is_disappear() -> bool:
	return self.position.x + self.collision.shape.size.x / 2 < 0 or \
		self.position.x - self.collision.shape.size.x / 2 > Constants.SCREEN_SIZE.x

func unglow() -> void:
	print("unglow")
	timer.stop()
	self.glowing = false
	# Reset the sprite's modulate property to its original color
	tween.kill()
	self.z_index = -2
	sprite.modulate = Color(1, 1, 1, 1)

func _on_timer_timeout() -> void:
	print("Timer timeout")
	unglow()

func add_mayhem():
	# Add mayhem to the enemy
	Utils.getLevel().add_mayhem()
	
func die():
	self.queue_free()
