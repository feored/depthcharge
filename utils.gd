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
