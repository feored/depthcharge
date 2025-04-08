extends Area2D

const SIZE = Vector2(16, 24)
const OFFSET_BOUNDS = Vector2(64, 64)


var speed = 50
var exploded = false
var explosion_animation = preload("res://weapons/explosion/explosion.tscn")
var radius_animation = preload("res://weapons/explosion/radius.tscn")

@onready var sprite: AnimatedSprite2D = $WeaponSprite
@onready var timedLabel : Label = %TimedLabel

var ground: TileMapLayer
var weapon_info : Dictionary = {}
var enemies_collided = []

var time_elapsed = 0.0
var last_homing_tone = 0.0

var timed_launched = false;
var time_until_explode = 0.0
var timed_last_digit = 0

var last_ground_pos = Vector2i.ZERO

func apply_upgrades():
	if GameState.upgrades.has("BiggerThruster"):
		if self.weapon_info.id == "Basic Driller":
			self.weapon_info.speed += 25
	
	if GameState.upgrades.has("ImplosionCharge"):
		if self.weapon_info.id == "Basic Driller":
			self.weapon_info.carve_radius += 1

	if GameState.upgrades.has("VolatileExplosive"):
		if self.weapon_info.id == "Timed Driller":
			var chance = Utils.rng.randf()
			if chance <= 0.1:
				print("Double explosion radius")
				self.weapon_info.carve_radius = self.weapon_info.carve_radius * 2
				self.weapon_info.exploding_radius = self.weapon_info.exploding_radius * 2

	if GameState.upgrades.has("BiggerWarhead"):
		if self.weapon_info.id == "Remote Driller":
			self.weapon_info.exploding_radius += 1

	if GameState.upgrades.has("CondensedFuel"):
		if self.weapon_info.id == "Seeker Driller":
			self.weapon_info.lifetime = self.weapon_info.lifetime * 1.25
		
	if GameState.upgrades.has("PassThroughDrill"):
		if self.weapon_info.id == "Seeker Driller":
			self.weapon_info.turning_speed = 1

func _ready() -> void:
	self.apply_upgrades()
	self.load_weapon()
	if self.weapon_info.timed:
		self.timedLabel.visible = true
		self.timedLabel.text = str(int(time_elapsed))
	if self.weapon_info.remote:
		var t = create_tween().set_loops()
		t.tween_callback(Sfx.play.bind(Sfx.Track.DetonateTone)).set_delay(0.5)

func launch():
	if self.timed_launched:
		return
	self.timed_launched = true
	time_until_explode = self.time_elapsed
	timed_last_digit = int(time_until_explode)
	
	
func _physics_process(delta: float) -> void:
	time_elapsed += delta
	if exploded:
		return
	if self.weapon_info.id == "Seeker Driller":
		if time_elapsed > self.weapon_info.lifetime:
			self.area_explode()
	if GameState.upgrades.has("GnasherDrillhead"):
			if self.weapon_info.id == "Remote Driller":
				var map_pos = ground.local_to_map(self.position)
				if self.last_ground_pos != map_pos:
					self.ground.erase_cell(self.ground.local_to_map(self.position))
					self.last_ground_pos = map_pos
	if self.weapon_info.timed:
		if not timed_launched:
			if GameState.upgrades.has("FasterArmingSequence"):
				if self.weapon_info.id == "Timed Driller":
					time_elapsed += delta
			timedLabel.text = str(int(time_elapsed))
			if time_elapsed >= self.weapon_info.max_time:
				self.launch()
			return
		else:
			time_until_explode -= delta
			timedLabel.text = str(int(time_until_explode))
			if timed_last_digit != int(time_until_explode):
				timed_last_digit = int(time_until_explode)
				Sfx.play(Sfx.Track.TimeTone)
			if time_until_explode <= 0:
				self.area_explode()
	if self.weapon_info.homing:
		var enemies = get_tree().get_nodes_in_group("enemies")
		var closest_enemy: Area2D = null
		var closest_distance = self.weapon_info.homing_range
		for enemy in enemies:
			var distance = self.position.distance_to(enemy.position)
			if enemy.glowing and distance < closest_distance and enemy.state == Enemy.State.Climb:
				closest_distance = distance
				closest_enemy = enemy
		if closest_enemy != null:
			var angle = (closest_enemy.position - self.position).angle()
			self.global_rotation = lerp_angle(self.global_rotation, angle - PI/2, delta * self.weapon_info.turning_speed)
			if time_elapsed - last_homing_tone > 0.5:
				last_homing_tone = time_elapsed
				Sfx.play(Sfx.Track.HomingTone)
	self.position += Vector2(0, speed * delta).rotated(self.global_rotation)
	var closest_cell: Vector2 = ground.local_to_map(self.position + Vector2(0, SIZE.y / 2))
	
	if out_of_bounds():
		self.queue_free()

func out_of_bounds() -> bool:
	return self.position.y > Constants.SCREEN_SIZE.y +  OFFSET_BOUNDS.y or \
	self.position.x < 0 - OFFSET_BOUNDS.x or \
	self.position.x > Constants.SCREEN_SIZE.x + OFFSET_BOUNDS.x or \
	self.position.y < 0 - OFFSET_BOUNDS.y


func area_explode() -> void:
	print("Remote explosion")
	exploded = true
	Sfx.play(Sfx.Track.Explosion)
	var closest_cell: Vector2 = ground.local_to_map(self.position)

	var neighbors = Utils.get_explosion_cells(ground, closest_cell, self.weapon_info.carve_radius)
	print("radius: ",  self.weapon_info.exploding_radius, " neighbors: ", neighbors.size())

	for cell in neighbors:
		if ground.get_cell_source_id(cell) in Constants.DIRT_TILE_IDS:
			#ground.set_cell(cell, Constants.EMPTY_DIRT_TILE_ID, Vector2i.ZERO)
			ground.erase_cell(cell)
	
	# print("Remote explosion")
	# print("Collided enemies: ", enemies_collided)
	for enemy in enemies_collided:
		hit_enemy(enemy)
	if enemies_collided.size() > 1:
		Utils.getLevel().try_message("multi_kill")
		if GameState.upgrades.has("MoraleBooster"):
			if self.weapon_info.id == "Timed Driller":
				Utils.getLevel().remove_mayhem(1)
	play_explosion()

func play_explosion():
	var center = ground.map_to_local(ground.local_to_map(self.position))
	var offset = center - self.position
	self.sprite.visible = false
	var radius_animation_instance = radius_animation.instantiate()
	radius_animation_instance.position = offset
	radius_animation_instance.set_radius(self.weapon_info.exploding_radius)
	var explosion = explosion_animation.instantiate()
	explosion.position = offset
	explosion.animation_finished.connect(queue_free)
	self.add_child(explosion)
	self.add_child(radius_animation_instance)
	
	




func set_weapon(id: String) -> void:
	self.weapon_info = Data.Weapons[id].duplicate()
	
func load_weapon():
	self.speed = weapon_info.speed
	self.sprite.sprite_frames = weapon_info.sprites
	self.sprite.play("default")
	# explosion area
	var new_area = Area2D.new()
	var new_collision = CollisionShape2D.new()
	var new_shape = RectangleShape2D.new()
	var extent = (Constants.TILE_SIZE * ((weapon_info.exploding_radius*2)+1))/2
	new_shape.extents = Vector2(extent, extent)
	new_collision.shape = new_shape
	add_child(new_area)
	new_area.add_child(new_collision)
	new_area.monitoring = true
	new_area.monitorable = true
	new_area.area_entered.connect(_enemy_entered)
	new_area.area_exited.connect(_enemy_exited)


# func _on_body_entered(body: Node2D) -> void:
# 	print("Body entered: ", body.name)
# 	if body.is_in_group("ground"):
# 		print("Ground hit: ", body.name)
		


func hit_enemy(enemy: Node2D) -> void:
	if enemy.is_in_group("enemies"):
		print("Enemy hit: ", enemy.name)
		if enemy.id == "Conqueror":
			if enemy.hits_left > 0:
				enemy.hits_left -= 1
			else:
				enemy.queue_free()
				Utils.getLevel().check_conquerors()
		else:
			if enemy.hits_left < 1 or self.weapon_info.onehitkill:
				enemy.queue_free()
			else:
				enemy.hits_left -= 1
			

func _on_area_entered(area: Area2D) -> void:
	if self.weapon_info.explodes_on_contact and area.is_in_group("enemies"):
		#hit_enemy(area)
		self.area_explode()#area.position)
		
func _enemy_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		enemies_collided.append(area)
		if GameState.upgrades.has("MicroGPR"):
			if self.weapon_info.id == "Remote Driller":
				area.glow()

func _enemy_exited(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		enemies_collided.erase(area)
