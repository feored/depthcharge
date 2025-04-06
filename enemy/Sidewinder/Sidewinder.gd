extends Enemy

var margin = 50

var x_speed = (
	Constants.ENEMY_SPEED * 3
	if Utils.rng.randi() % 2 == 0
	else -Constants.ENEMY_SPEED * 3
)


func emerge(delta: float) -> void:
	self.position -= Vector2(0, Constants.ENEMY_EMERGE_SPEED) * delta


func scatter(delta) -> void:
	self.position += self.closest_edge_direction() * delta * Constants.ENEMY_SCATTER_SPEED


func climb(delta: float) -> void:
	if self.position.x > Constants.SCREEN_SIZE.x - margin:
		x_speed = speed * 2.5
	elif self.position.x < margin:
		x_speed = -speed * 3

	self.position -= Vector2(x_speed, speed / 2) * delta


func _physics_process(delta: float) -> void:
	if is_above_ground():
		self.disable_collision()
		self.z_index = 2
		self.state = Enemy.State.Emerge
	if is_emerged():
		state = Enemy.State.Scatter
	if is_disappear():
		print("Sidewinder died")
		self.die()
	match state:
		Enemy.State.Emerge:
			emerge(delta)
		Enemy.State.Scatter:
			scatter(delta)
		Enemy.State.Climb:
			climb(delta)
