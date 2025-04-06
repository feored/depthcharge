extends Node

var rng = RandomNumberGenerator.new()


func get_neighboring_cells(tilemap: TileMapLayer, cell: Vector2i) -> Array:
	var neighbors = tilemap.get_surrounding_cells(cell)
	for d in [
		TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
		TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
		TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER,
		TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER
	]:
		neighbors.append(tilemap.get_neighbor_cell(cell, d))

	return neighbors

func get_neighboring_cells_radius(tilemap: TileMapLayer, cell: Vector2i, radius: int) -> Array:
	var neighbors = [[cell]]
	var all_neighbors = [cell]
	for i in range(radius):
		for n in neighbors[i]:
			var new_neighbors = []
			for new_n in get_neighboring_cells(tilemap, n):
				if new_n not in all_neighbors:
					new_neighbors.append(new_n)
					all_neighbors.append(new_n)
			neighbors.append(new_neighbors)
		print("neighbors: ", neighbors)
	return all_neighbors


func get_explosion_cells(tilemap: TileMapLayer, cell: Vector2i, radius: int) -> Array:
	var start_coords = Vector2(cell.x - radius, cell.y - radius)
	var end_coords = Vector2(cell.x + radius, cell.y + radius)
	var explosion_cells = []
	for x in range(start_coords.x, end_coords.x + 1):
		for y in range(start_coords.y, end_coords.y + 1):
			var n = Vector2i(x, y)
			if tilemap.get_cell_source_id(n) in Constants.DIRT_TILE_IDS:
				explosion_cells.append(n)
	return explosion_cells


func getLevel() -> Node:
	return get_tree().get_nodes_in_group("level")[0]

func getLine(trigger: String) -> String:
	var texts = Data.FLAVOR[trigger]
	var success = rng.randf() < texts["chance"]
	if success:
		return texts.lines[rng.randi() % texts.size()]
	else:
		return ""
