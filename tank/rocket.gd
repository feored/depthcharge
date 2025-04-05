extends Area2D
@export var speed = 100
var ground: TileMapLayer

const SIZE = Vector2(16, 24)

func _physics_process(delta: float) -> void:
	self.position += Vector2(0, speed * delta)
	var closest_cell: Vector2 = ground.local_to_map(self.position)
	if ground.get_cell_source_id(closest_cell) in Constants.DIRT_TILE_IDS:
		print("Rocket hit: ", closest_cell)
		ground.set_cell(closest_cell, Constants.EMPTY_DIRT_TILE_ID, Vector2i.ZERO)
		print("new cell: ", ground.get_cell_source_id(closest_cell))
		self.speed = self.speed * 0.9 - 1
	if speed < 20:
		self.explode()

func explode():
	self.queue_free()


# func _on_body_entered(body: Node2D) -> void:
# 	print("Rocket hit: ", body.name)
# 	if body.is_in_group("ground"):
# 		var tilemap = body as TileMapLayer
# 		tilemap.erase_cell(tilemap.local_to_map(self.position))


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		print("Rocket hit: ", area.name)
		area.queue_free()
		self.explode()
