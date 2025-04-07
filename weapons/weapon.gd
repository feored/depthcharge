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


func _ready() -> void:
	self.load_weapon()
	if self.weapon_info.timed:
		self.timedLabel.visible = true
		self.timedLabel.text = str(int(time_elapsed))

func launch():
	if self.timed_launched:
		return
	self.timed_launched = true
	time_until_explode = self.time_elapsed
	
func _physics_process(delta: float) -> void:
	time_elapsed += delta
	if exploded:
		return
	if self.weapon_info.timed:
		if not timed_launched:
			timedLabel.text = str(int(time_elapsed))
			if time_elapsed >= self.weapon_info.max_time:
				self.launch()
			return
		else:
			time_until_explode -= delta
			timedLabel.text = str(int(time_until_explode))
			if time_until_explode <= 0:
				self.area_explode()
	if self.weapon_info.homing:
		var enemies = get_tree().get_nodes_in_group("enemies")
		var closest_enemy: Area2D = null
		var closest_distance = self.weapon_info.homing_range
		for enemy in enemies:
			var distance = self.position.distance_to(enemy.position)
			if distance < closest_distance and enemy.state == Enemy.State.Climb:
				closest_distance = distance
				closest_enemy = enemy
		if closest_enemy != null:
			var angle = (closest_enemy.position - self.position).angle()
			self.global_rotation = lerp_angle(self.global_rotation, angle - PI/2, delta)
			if time_elapsed - last_homing_tone > 0.5:
				last_homing_tone = time_elapsed
				Sfx.play(Sfx.Track.HomingTone)

	self.position += Vector2(0, speed * delta).rotated(self.global_rotation)
	var closest_cell: Vector2 = ground.local_to_map(self.position + Vector2(0, SIZE.y / 2))
	#if self.weapon_info.
	# if ground.get_cell_source_id(closest_cell) in Constants.DIRT_TILE_IDS:
	#     print("Rocket hit: ", closest_cell)
	#     ##ground.set_cell(closest_cell, Constants.EMPTY_DIRT_TILE_ID, Vector2i.ZERO)
	#     ground.erase_cell(closest_cell)
	#     print("new cell: ", ground.get_cell_source_id(closest_cell))
	if out_of_bounds():
		self.queue_free()

func out_of_bounds() -> bool:
	return self.position.y > Constants.SCREEN_SIZE.y +  OFFSET_BOUNDS.y or \
	self.position.x < 0 - OFFSET_BOUNDS.x or \
	self.position.x > Constants.SCREEN_SIZE.x + OFFSET_BOUNDS.x or \
	self.position.y < 0 - OFFSET_BOUNDS.y

# func explode(center = self.position) -> void:
# 	print("Rocket exploded")
# 	exploded = true
# 	Sfx.play(Sfx.Track.Explosion)
# 	var closest_cell: Vector2 = ground.local_to_map(center)
# 	var neighbors = Utils.get_explosion_cells(ground, closest_cell, self.weapon_info.carve_radius)
# 	print("radius: ",  self.weapon_info.exploding_radius, " neighbors: ", neighbors.size())
# 	for cell in neighbors:
# 		if ground.get_cell_source_id(cell) in Constants.DIRT_TILE_IDS:
# 			#ground.set_cell(cell, Constants.EMPTY_DIRT_TILE_ID, Vector2i.ZERO)
# 			ground.erase_cell(cell)
# 	play_explosion()

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
	self.weapon_info = Data.Weapons[id]
	
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
# 	print("Rocket hit: ", body.name)
# 	if body.is_in_group("ground"):
# 		var tilemap = body as TileMapLayer
# 		tilemap.erase_cell(tilemap.local_to_map(self.position))


func hit_enemy(enemy: Node2D) -> void:
	if enemy.is_in_group("enemies"):
		print("Enemy hit: ", enemy.name)
		if enemy.hits_left > 0:
			enemy.hits_left -= 1
		else:
			enemy.queue_free()

func _on_area_entered(area: Area2D) -> void:
	if self.weapon_info.explodes_on_contact and area.is_in_group("enemies"):
		#hit_enemy(area)
		self.area_explode()#area.position)
		
func _enemy_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		enemies_collided.append(area)

func _enemy_exited(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		enemies_collided.erase(area)
