#AutoLoad Script
#Calculates grid
extends Node

const SIZE: Vector2i = Vector2i(6, 6)
const CELL_SIZE: Vector2 = Vector2(32, 32)

#Converts Pixel Coords to Vector grid locations
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i((world_pos / CELL_SIZE).floor())
	
#converts grid position to the center of that cell in the worldspace
func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell) *CELL_SIZE + CELL_SIZE/2
	
#Returns true if the cell is on the grid
func is_within_grid(cell: Vector2i) -> bool:
	return cell.x >= 0 && cell.x < SIZE.x && cell.y >= 0 && cell.y < SIZE.y
