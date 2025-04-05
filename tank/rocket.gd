extends Area2D
@export var speed = 100
var ground: TileMapLayer

const SIZE = Vector2(16, 24)

func _physics_process(delta: float) -> void:
	self.position += Vector2(0, speed * delta)
	var closest_cell: Vector2 = ground.local_to_map(self.position)
	if ground.get_cell_source_id(closest_cell) != -1:
		print("Rocket hit: ", closest_cell)
		ground.erase_cell(closest_cell)
		self.speed -= 5


# func _on_body_entered(body: Node2D) -> void:
# 	print("Rocket hit: ", body.name)
# 	if body.is_in_group("ground"):
# 		var tilemap = body as TileMapLayer
# 		tilemap.erase_cell(tilemap.local_to_map(self.position))
