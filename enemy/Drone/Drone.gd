extends Enemy


func scatter(delta) -> void:
	self.position += self.closest_edge_direction() * delta * Constants.ENEMY_SCATTER_SPEED


func emerge(delta: float) -> void:
	self.position -= Vector2(0, Constants.ENEMY_EMERGE_SPEED) * delta


func climb(delta: float) -> void:
	self.position -= Vector2(0, speed) * delta


func _physics_process(delta: float) -> void:
	if is_above_ground():
		self.z_index = 2
		self.disable_collision()
		self.state = Enemy.State.Emerge
	if is_emerged():
		state = Enemy.State.Scatter
	if is_disappear():
		print("Drone died")
		self.die()
	match state:
		Enemy.State.Emerge:
			emerge(delta)
		Enemy.State.Scatter:
			scatter(delta)
		Enemy.State.Climb:
			climb(delta)
