extends Enemy

var next_behavior_change = Utils.rng.randf_range(0.5, 4)
var currently_drone = Utils.rng.randi() % 2 == 0
var behavior_time = 0.0
var margin = 50

var x_speed = (
	Constants.ENEMY_SPEED * 3
	if Utils.rng.randi() % 2 == 0
	else -Constants.ENEMY_SPEED * 3
)


func _ready():
	self.hits_left = 4
	if Music.currently_playing_track != Music.Track.Conqueror:
		Music.play_track(Music.Track.Conqueror)


func emerge(delta: float) -> void:
	self.position -= Vector2(0, Constants.ENEMY_EMERGE_SPEED) * delta


func scatter(delta) -> void:
	self.position += self.closest_edge_direction() * delta * Constants.ENEMY_SCATTER_SPEED


func climb_drone(delta: float) -> void:
	self.position -= Vector2(0, speed) * delta


func climb_sidewinder(delta: float) -> void:
	if self.position.x > Constants.SCREEN_SIZE.x - margin:
		x_speed = speed * 2.5
	elif self.position.x < margin:
		x_speed = -speed * 3

	self.position -= Vector2(x_speed, speed / 2) * delta


func _physics_process(delta: float) -> void:
	behavior_time += delta
	if behavior_time > next_behavior_change:
		behavior_time = 0
		currently_drone = !currently_drone
		next_behavior_change = Utils.rng.randf_range(0.5, 4)
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
					Sfx.play(Sfx.Track.TectoidBreach)
					self.add_mayhem()
				state = Enemy.State.Scatter
		Enemy.State.Scatter:
			if is_disappear():
				print("Conqueror died")
				self.disappear()

	# state action

	match state:
		Enemy.State.Emerge:
			emerge(delta)
		Enemy.State.Scatter:
			scatter(delta)
		Enemy.State.Climb:
			if currently_drone:
				climb_drone(delta)
			else:
				climb_sidewinder(delta)
