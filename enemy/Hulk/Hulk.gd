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
	if is_above_ground():
		self.z_index = 2
		self.disable_collision()
		self.state = Enemy.State.Emerge
	if is_emerged():
		state = Enemy.State.Scatter
	if is_disappear():
		print("Hulk died")
		self.die()
	match state:
		Enemy.State.Emerge:
			emerge(delta)
		Enemy.State.Scatter:
			scatter(delta)
		Enemy.State.Climb:
			climb(delta)
