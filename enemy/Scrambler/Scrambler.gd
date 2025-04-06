extends Enemy


func scatter(delta) -> void:
	self.position += self.closest_edge_direction() * delta


func climb(delta: float) -> void:
	self.position -= Vector2(0, speed) * delta


func _physics_process(delta: float) -> void:
	match state:
		Enemy.State.Scatter:
			scatter(delta)
		Enemy.State.Climb:
			climb(delta)
