extends Node


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
	return all_neighbors
