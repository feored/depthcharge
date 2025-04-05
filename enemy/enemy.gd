extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
var tween: Tween
var glowing: bool = false
var speed = 20


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

func _physics_process(delta: float) -> void:
	self.position -= Vector2(0, speed) * delta
