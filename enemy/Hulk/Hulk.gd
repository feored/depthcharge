extends Enemy


func _ready():
	self.hits_left = 2


func scatter(delta) -> void:
	self.position += self.closest_edge_direction() * delta * Constants.ENEMY_SCATTER_SPEED


func climb(delta: float) -> void:
	self.position -= Vector2(0, speed / 3) * delta


func emerge(delta: float) -> void:
	self.position -= Vector2(0, Constants.ENEMY_EMERGE_SPEED) * delta


func _physics_process(delta: float) -> void:
	# state change
	match state:
		Enemy.State.Climb:
			if is_above_ground():
				self.disable_collision()
				self.z_index = 2
				self.state = Enemy.State.Emerge
		Enemy.State.Emerge:
			if is_emerged():
				if state != Enemy.State.Scatter:
					self.add_mayhem()
				state = Enemy.State.Scatter
		Enemy.State.Scatter:
			if is_disappear():
				print("Sidewinder died")
				self.die()

	# state action

	match state:
		Enemy.State.Emerge:
			emerge(delta)
		Enemy.State.Scatter:
			scatter(delta)
		Enemy.State.Climb:
			climb(delta)
