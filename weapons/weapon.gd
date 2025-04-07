extends Area2D

const SIZE = Vector2(16, 24)
const OFFSET_BOUNDS = Vector2(64, 64)


var speed = 50
var exploded = false
var explosion_animation = preload("res://weapons/explosion/explosion.tscn")
var radius_animation = preload("res://weapons/explosion/radius.tscn")

@onready var sprite: AnimatedSprite2D = $WeaponSprite
var ground: TileMapLayer
var weapon_info : Dictionary = {}
var enemies_collided = []


func _ready() -> void:
	self.load_weapon()
	
func _physics_process(delta: float) -> void:
	if exploded:
		return
	self.position += Vector2(0, speed * delta)
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

func explode(center = self.position) -> void:
	print("Rocket exploded")
	exploded = true
	Sfx.play(Sfx.Track.Explosion)
	var closest_cell: Vector2 = ground.local_to_map(center)
	var neighbors = Utils.get_explosion_cells(ground, closest_cell, self.weapon_info.carve_radius)
	print("radius: ",  self.weapon_info.exploding_radius, " neighbors: ", neighbors.size())
	for cell in neighbors:
		if ground.get_cell_source_id(cell) in Constants.DIRT_TILE_IDS:
			#ground.set_cell(cell, Constants.EMPTY_DIRT_TILE_ID, Vector2i.ZERO)
			ground.erase_cell(cell)
	play_explosion()

func remote_explode() -> void:
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
	if weapon_info.remote:
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
		hit_enemy(area)
		self.explode(area.position)
		
func _enemy_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		enemies_collided.append(area)

func _enemy_exited(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		enemies_collided.erase(area)
